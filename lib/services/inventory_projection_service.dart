import 'package:isar/isar.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/department_stock_entity.dart';
import 'package:flutter_app/data/local/entities/inventory_location_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/stock_balance_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/utils/app_logger.dart';

import 'database_service.dart';
import 'department_master_service.dart';

class InventoryProjectionBootstrapResult {
  final int departmentSeedCount;
  final int departmentCreatedCount;
  final int locationCreatedCount;
  final int stockBalanceCreatedCount;

  const InventoryProjectionBootstrapResult({
    required this.departmentSeedCount,
    required this.departmentCreatedCount,
    required this.locationCreatedCount,
    required this.stockBalanceCreatedCount,
  });
}

class InventoryProjectionService {
  InventoryProjectionService(
    this._dbService, {
    DepartmentMasterService? departmentMasterService,
  }) : _departmentMasterService =
           departmentMasterService ?? DepartmentMasterService(_dbService);

  final DatabaseService _dbService;
  final DepartmentMasterService _departmentMasterService;

  static const String warehouseMainLocationId =
      DepartmentMasterService.warehouseMainLocationId;
  static const String virtualSoldLocationId = 'virtual:sold';

  Future<InventoryProjectionBootstrapResult> ensureCanonicalFoundation() async {
    final departmentSeedResult = await _departmentMasterService.ensureSeeded();
    final locationCreatedCount = await ensureInventoryLocations();
    final stockBalanceCreatedCount = await backfillMissingStockBalances();

    AppLogger.info(
      'Inventory projection ready: departments=${departmentSeedResult.totalSeedCount}, '
      'locationsCreated=$locationCreatedCount, balancesCreated=$stockBalanceCreatedCount',
      tag: 'InventoryProjection',
    );

    return InventoryProjectionBootstrapResult(
      departmentSeedCount: departmentSeedResult.totalSeedCount,
      departmentCreatedCount: departmentSeedResult.createdCount,
      locationCreatedCount: locationCreatedCount,
      stockBalanceCreatedCount: stockBalanceCreatedCount,
    );
  }

  Future<int> ensureInventoryLocations() async {
    final departments = await _departmentMasterService.getCanonicalDepartments();
    final users = await _dbService.users.where().findAll();
    final existing = await _dbService.inventoryLocations.where().findAll();
    final existingById = {
      for (final location in existing) location.id: location,
    };

    final desired = <InventoryLocationEntity>[
      _buildWarehouseLocation(existingById[warehouseMainLocationId]),
      ...departments.map(
        (department) => _buildDepartmentLocation(
          departmentId: department.departmentId,
          departmentCode: department.departmentCode,
          departmentName: department.departmentName,
          isActive: department.isActive,
          existing: existingById[department.departmentId],
        ),
      ),
    ];

    final activeSalesmen = users.where(_isActiveSalesman).toList();
    final activeSalesmanIds = activeSalesmen.map((user) => user.id).toSet();

    for (final user in activeSalesmen) {
      final locationId = salesmanLocationIdForUser(user.id);
      desired.add(
        _buildSalesmanLocation(
          user: user,
          existing: existingById[locationId],
        ),
      );
    }

    for (final location in existing.where(
      (item) =>
          item.type == InventoryLocationEntity.salesmanVanType &&
          (item.ownerUserUid?.trim().isNotEmpty ?? false) &&
          !activeSalesmanIds.contains(item.ownerUserUid),
    )) {
      desired.add(_cloneLocation(location)..isActive = false);
    }

    final createdCount = desired
        .where((location) => !existingById.containsKey(location.id))
        .length;

    await _dbService.db.writeTxn(() async {
      await _dbService.inventoryLocations.putAll(desired);
    });

    return createdCount;
  }

  Future<int> backfillMissingStockBalances() async {
    final existing = await _dbService.stockBalances.where().findAll();
    final existingIds = existing.map((balance) => balance.id).toSet();
    final created = <StockBalanceEntity>[];

    final products = await _dbService.products.where().findAll();
    for (final product in products.where((item) => !item.isDeleted)) {
      final balanceId = StockBalanceEntity.composeId(
        warehouseMainLocationId,
        product.id,
      );
      if (existingIds.contains(balanceId)) continue;
      existingIds.add(balanceId);
      created.add(
        _buildBalance(
          locationId: warehouseMainLocationId,
          productId: product.id,
          quantity: product.stock ?? 0.0,
          updatedAt: product.updatedAt,
        ),
      );
    }

    final departmentTotals = <String, _AggregatedBalance>{};
    final departmentStocks = await _dbService.departmentStocks.where().findAll();
    for (final stock in departmentStocks.where((item) => !item.isDeleted)) {
      final departmentId = _departmentMasterService.resolveCanonicalDepartmentId(
        stock.departmentName,
      );
      if (departmentId == null) continue;
      final locationId = departmentId;
      final balanceId = StockBalanceEntity.composeId(locationId, stock.productId);
      departmentTotals.update(
        balanceId,
        (existingBalance) => existingBalance.merge(
          quantity: stock.stock,
          updatedAt: stock.updatedAt,
        ),
        ifAbsent: () => _AggregatedBalance(
          locationId: locationId,
          productId: stock.productId,
          quantity: stock.stock,
          updatedAt: stock.updatedAt,
        ),
      );
    }
    for (final aggregate in departmentTotals.values) {
      final balanceId = StockBalanceEntity.composeId(
        aggregate.locationId,
        aggregate.productId,
      );
      if (existingIds.contains(balanceId)) continue;
      existingIds.add(balanceId);
      created.add(
        _buildBalance(
          locationId: aggregate.locationId,
          productId: aggregate.productId,
          quantity: aggregate.quantity,
          updatedAt: aggregate.updatedAt,
        ),
      );
    }

    final users = await _dbService.users.where().findAll();
    for (final user in users.where(_isActiveSalesman)) {
      final locationId = salesmanLocationIdForUser(user.id);
      final allocatedStock = user.getAllocatedStock();
      for (final entry in allocatedStock.entries) {
        final totalQuantity =
            entry.value.quantity + (entry.value.freeQuantity ?? 0);
        final balanceId = StockBalanceEntity.composeId(locationId, entry.key);
        if (existingIds.contains(balanceId)) continue;
        if (totalQuantity == 0) continue;
        existingIds.add(balanceId);
        created.add(
          _buildBalance(
            locationId: locationId,
            productId: entry.key,
            quantity: totalQuantity.toDouble(),
            updatedAt: user.updatedAt,
          ),
        );
      }
    }

    if (created.isEmpty) {
      return 0;
    }

    await _dbService.db.writeTxn(() async {
      await _dbService.stockBalances.putAll(created);
    });

    return created.length;
  }

  Future<StockBalanceEntity?> getBalance({
    required String locationId,
    required String productId,
  }) {
    final balanceId = StockBalanceEntity.composeId(locationId, productId);
    return _dbService.stockBalances.getById(balanceId);
  }

  Future<void> setBalanceQuantity({
    required String locationId,
    required String productId,
    required double quantity,
    SyncStatus syncStatus = SyncStatus.synced,
    bool updateCompatibilityMirror = true,
  }) async {
    final now = DateTime.now();
    final balanceId = StockBalanceEntity.composeId(locationId, productId);
    final existingBalance = await _dbService.stockBalances.getById(balanceId);

    await _dbService.db.writeTxn(() async {
      final balance = existingBalance ?? StockBalanceEntity();
      balance
        ..id = balanceId
        ..locationId = locationId
        ..productId = productId
        ..quantity = quantity
        ..updatedAt = now
        ..syncStatus = syncStatus
        ..isDeleted = false;
      await _dbService.stockBalances.put(balance);

      if (updateCompatibilityMirror) {
        await applyCompatibilityProjectionInTxn(
          locationId: locationId,
          productId: productId,
          quantity: quantity,
          updatedAt: now,
          syncStatus: syncStatus,
        );
      }
    });
  }

  Future<void> applyCompatibilityProjectionInTxn({
    required String locationId,
    required String productId,
    required double quantity,
    required DateTime updatedAt,
    SyncStatus syncStatus = SyncStatus.pending,
  }) async {
    final location = await _dbService.inventoryLocations.getById(locationId);
    final product = await _dbService.products.getById(productId);

    if (locationId == warehouseMainLocationId) {
      await _projectWarehouseStockInTxn(
        product: product,
        productId: productId,
        quantity: quantity,
        updatedAt: updatedAt,
        syncStatus: syncStatus,
      );
      return;
    }

    if (location == null) {
      return;
    }

    switch (location.type) {
      case InventoryLocationEntity.departmentType:
        await _projectDepartmentStockInTxn(
          location: location,
          product: product,
          productId: productId,
          quantity: quantity,
          updatedAt: updatedAt,
          syncStatus: syncStatus,
        );
        return;
      case InventoryLocationEntity.salesmanVanType:
        await _projectSalesmanStockInTxn(
          location: location,
          product: product,
          productId: productId,
          quantity: quantity,
          updatedAt: updatedAt,
          syncStatus: syncStatus,
        );
        return;
    }
  }

  static String salesmanLocationIdForUid(String ownerUserUid) {
    return 'salesman_van_${ownerUserUid.trim()}';
  }

  String salesmanLocationIdForUser(String ownerUserUid) {
    return salesmanLocationIdForUid(ownerUserUid);
  }

  InventoryLocationEntity _buildWarehouseLocation(
    InventoryLocationEntity? existing,
  ) {
    final entity = existing == null
        ? InventoryLocationEntity()
        : _cloneLocation(existing);
    entity
      ..id = warehouseMainLocationId
      ..type = InventoryLocationEntity.warehouseType
      ..name = 'Main Warehouse'
      ..code = 'WAREHOUSE_MAIN'
      ..parentLocationId = null
      ..ownerUserUid = null
      ..isActive = true
      ..isPrimaryMainWarehouse = true
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    return entity;
  }

  InventoryLocationEntity _buildDepartmentLocation({
    required String departmentId,
    required String departmentCode,
    required String departmentName,
    required bool isActive,
    InventoryLocationEntity? existing,
  }) {
    final entity = existing == null
        ? InventoryLocationEntity()
        : _cloneLocation(existing);
    entity
      ..id = departmentId
      ..type = InventoryLocationEntity.departmentType
      ..name = departmentName
      ..code = departmentCode
      ..parentLocationId = warehouseMainLocationId
      ..ownerUserUid = null
      ..isActive = isActive
      ..isPrimaryMainWarehouse = false
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    return entity;
  }

  InventoryLocationEntity _buildSalesmanLocation({
    required UserEntity user,
    InventoryLocationEntity? existing,
  }) {
    final entity = existing == null
        ? InventoryLocationEntity()
        : _cloneLocation(existing);
    final uid = user.id.trim();
    final label = _displayLabelForUser(user);
    entity
      ..id = salesmanLocationIdForUser(uid)
      ..type = InventoryLocationEntity.salesmanVanType
      ..name = '$label Van'
      ..code = 'VAN_${_toCodeToken(uid)}'
      ..parentLocationId = warehouseMainLocationId
      ..ownerUserUid = uid
      ..isActive = user.isActive
      ..isPrimaryMainWarehouse = false
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    return entity;
  }

  InventoryLocationEntity _cloneLocation(InventoryLocationEntity source) {
    return InventoryLocationEntity()
      ..id = source.id
      ..type = source.type
      ..name = source.name
      ..code = source.code
      ..parentLocationId = source.parentLocationId
      ..ownerUserUid = source.ownerUserUid
      ..isActive = source.isActive
      ..isPrimaryMainWarehouse = source.isPrimaryMainWarehouse
      ..updatedAt = source.updatedAt
      ..syncStatus = source.syncStatus
      ..isDeleted = source.isDeleted
      ..deletedAt = source.deletedAt;
  }

  StockBalanceEntity _buildBalance({
    required String locationId,
    required String productId,
    required double quantity,
    required DateTime updatedAt,
  }) {
    return StockBalanceEntity()
      ..id = StockBalanceEntity.composeId(locationId, productId)
      ..locationId = locationId
      ..productId = productId
      ..quantity = quantity
      ..updatedAt = updatedAt
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
  }

  bool _isActiveSalesman(UserEntity user) {
    if (!user.isActive || user.isDeleted) {
      return false;
    }
    final role = user.role
        ?.trim()
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
    return role == 'salesman';
  }

  String _displayLabelForUser(UserEntity user) {
    final name = user.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }
    return user.id;
  }

  String _toCodeToken(String value) {
    final normalized = value
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return normalized.isEmpty ? 'UNKNOWN' : normalized;
  }

  Future<void> _projectWarehouseStockInTxn({
    required ProductEntity? product,
    required String productId,
    required double quantity,
    required DateTime updatedAt,
    required SyncStatus syncStatus,
  }) async {
    if (product == null) {
      return;
    }

    product
      ..stock = quantity
      ..updatedAt = updatedAt
      ..syncStatus = syncStatus;
    await _dbService.products.put(product);
  }

  Future<void> _projectDepartmentStockInTxn({
    required InventoryLocationEntity location,
    required ProductEntity? product,
    required String productId,
    required double quantity,
    required DateTime updatedAt,
    required SyncStatus syncStatus,
  }) async {
    final seed =
        _departmentMasterService.resolveSeed(location.id) ??
        _departmentMasterService.resolveSeed(location.name);
    final legacyDepartmentName =
        seed?.legacyMirrorKey ??
        DepartmentMasterService.normalizeDepartmentToken(location.name);
    final entityId = '${legacyDepartmentName}_$productId';
    final existing = await _dbService.departmentStocks.getById(entityId);

    final entity = existing ?? DepartmentStockEntity();
    entity
      ..id = entityId
      ..departmentName = legacyDepartmentName
      ..productId = productId
      ..productName = product?.name ?? existing?.productName ?? 'Unknown'
      ..stock = quantity
      ..unit = product?.baseUnit ?? existing?.unit ?? 'Unit'
      ..updatedAt = updatedAt
      ..syncStatus = syncStatus
      ..isDeleted = false;
    await _dbService.departmentStocks.put(entity);
  }

  Future<void> _projectSalesmanStockInTxn({
    required InventoryLocationEntity location,
    required ProductEntity? product,
    required String productId,
    required double quantity,
    required DateTime updatedAt,
    required SyncStatus syncStatus,
  }) async {
    final ownerUserUid = location.ownerUserUid?.trim();
    if (ownerUserUid == null || ownerUserUid.isEmpty) {
      return;
    }

    final user = await _dbService.users.getById(ownerUserUid);
    if (user == null) {
      return;
    }

    final allocatedStock = user.getAllocatedStock();
    if (quantity <= 0) {
      allocatedStock.remove(productId);
    } else {
      final existing = allocatedStock[productId];
      final normalizedQuantity = _toLegacySalesmanQuantity(
        quantity,
        locationId: location.id,
        productId: productId,
      );
      allocatedStock[productId] = AllocatedStockItem(
        name: product?.name ?? existing?.name ?? 'Unknown Product',
        quantity: normalizedQuantity,
        productId: productId,
        price: product?.price ?? existing?.price ?? 0.0,
        secondaryPrice: product?.secondaryPrice ?? existing?.secondaryPrice,
        baseUnit: product?.baseUnit ?? existing?.baseUnit ?? 'Unit',
        secondaryUnit:
            product?.secondaryUnit ?? existing?.secondaryUnit,
        conversionFactor:
            product?.conversionFactor ?? existing?.conversionFactor ?? 1.0,
        freeQuantity: 0,
        defaultDiscount:
            product?.defaultDiscount ?? existing?.defaultDiscount,
        itemType: product?.itemType ?? existing?.itemType,
      );
    }

    user
      ..setAllocatedStock(allocatedStock)
      ..updatedAt = updatedAt
      ..syncStatus = syncStatus;
    await _dbService.users.put(user);
  }

  int _toLegacySalesmanQuantity(
    double quantity, {
    required String locationId,
    required String productId,
  }) {
    final rounded = quantity.round();
    if ((quantity - rounded).abs() > 1e-9) {
      AppLogger.warning(
        'Salesman compatibility mirror rounded non-integer quantity=$quantity '
        'for location=$locationId product=$productId',
        tag: 'InventoryProjection',
      );
    }
    return rounded;
  }
}

class _AggregatedBalance {
  final String locationId;
  final String productId;
  final double quantity;
  final DateTime updatedAt;

  const _AggregatedBalance({
    required this.locationId,
    required this.productId,
    required this.quantity,
    required this.updatedAt,
  });

  _AggregatedBalance merge({
    required double quantity,
    required DateTime updatedAt,
  }) {
    final nextUpdatedAt = this.updatedAt.isAfter(updatedAt)
        ? this.updatedAt
        : updatedAt;
    return _AggregatedBalance(
      locationId: locationId,
      productId: productId,
      quantity: this.quantity + quantity,
      updatedAt: nextUpdatedAt,
    );
  }
}
