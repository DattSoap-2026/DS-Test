import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/firebase/firebase_config.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../services/database_service.dart';
import '../../services/inventory_movement_engine.dart';
import '../../services/inventory_projection_service.dart';
import '../../services/tank_service.dart';
import '../../utils/storage_unit_helper.dart';
import '../local/base_entity.dart';
import '../local/entities/stock_balance_entity.dart';
import '../local/entities/tank_entity.dart';
import '../local/entities/tank_lot_entity.dart';
import '../local/entities/tank_transaction_entity.dart';

class TankRepository {
  TankRepository(
    this._dbService, {
    FirebaseServices? firebaseServices,
    TankService? tankService,
    InventoryProjectionService? inventoryProjectionService,
    InventoryMovementEngine? inventoryMovementEngine,
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _tankService = tankService ??
           (firebaseServices == null ? null : TankService(firebaseServices, _dbService)),
       _inventoryProjectionService =
           inventoryProjectionService ?? InventoryProjectionService(_dbService),
       _inventoryMovementEngine = inventoryMovementEngine ??
           InventoryMovementEngine(
             _dbService,
             inventoryProjectionService ?? InventoryProjectionService(_dbService),
           ),
       _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  static const Uuid _uuid = Uuid();

  final DatabaseService _dbService;
  final TankService? _tankService;
  final InventoryProjectionService _inventoryProjectionService;
  final InventoryMovementEngine _inventoryMovementEngine;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  String _tankInventoryLocationId(String tankId) => 'virtual:tank:$tankId';

  Future<void> _ensureWarehouseLocationReady() async {
    final existing = await _dbService.inventoryLocations.get(
      fastHash(InventoryProjectionService.warehouseMainLocationId),
    );
    if (existing != null) {
      return;
    }
    await _inventoryProjectionService.ensureCanonicalFoundation();
  }

  Future<void> _seedWarehouseBalanceInTxn({
    required String productId,
    required DateTime occurredAt,
  }) async {
    final balanceId = StockBalanceEntity.composeId(
      InventoryProjectionService.warehouseMainLocationId,
      productId,
    );
    final existing = await _dbService.stockBalances.get(fastHash(balanceId));
    if (existing != null) {
      return;
    }
    final product = await _dbService.products.get(fastHash(productId));
    final balance = StockBalanceEntity()
      ..id = balanceId
      ..locationId = InventoryProjectionService.warehouseMainLocationId
      ..productId = productId
      ..quantity = product?.stock ?? 0.0
      ..updatedAt = occurredAt
      ..syncStatus = product?.syncStatus ?? SyncStatus.pending
      ..isDeleted = false;
    await _dbService.stockBalances.put(balance);
  }

  Future<List<Tank>> getTanks({String? bhattiName}) async {
    var tanks = await getAllTanks();
    if (bhattiName != null && bhattiName.trim().isNotEmpty) {
      tanks = tanks
          .where((tank) => (tank.assignedUnit ?? '') == bhattiName.trim())
          .toList(growable: false);
    }
    final mapped = tanks.map((entity) => entity.toDomain()).toList(growable: false);
    mapped.sort(Tank.compareByDisplayOrder);
    return mapped;
  }

  Future<List<TankEntity>> getAllTanks() {
    return _dbService.tanks
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  Future<TankEntity?> getTankById(String id) {
    return _dbService.tanks
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<List<TankEntity>> getTanksByDepartment(String department) {
    return _dbService.tanks
        .filter()
        .departmentEqualTo(department)
        .and()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  Future<List<TankEntity>> getLowStockTanks(double threshold) {
    return _dbService.tanks
        .filter()
        .currentStockLessThan(threshold)
        .and()
        .isDeletedEqualTo(false)
        .sortByCurrentStock()
        .findAll();
  }

  Future<List<TankTransactionEntity>> getTankTransactions(String tankId) {
    return _dbService.tankTransactions
        .filter()
        .tankIdEqualTo(tankId)
        .and()
        .isDeletedEqualTo(false)
        .sortByTimestampDesc()
        .findAll();
  }

  Future<List<TankLotEntity>> getAllTankLots() {
    return _dbService.tankLots
        .filter()
        .isDeletedEqualTo(false)
        .sortByReceivedDateDesc()
        .findAll();
  }

  Future<List<TankLotEntity>> getLotsByTank(String tankId) {
    return _dbService.tankLots
        .filter()
        .tankIdEqualTo(tankId)
        .and()
        .isDeletedEqualTo(false)
        .sortByReceivedDateDesc()
        .findAll();
  }

  Stream<List<TankEntity>> watchAllTanks() {
    return _dbService.tanks
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true);
  }

  Stream<List<TankTransactionEntity>> watchTankTransactions(String tankId) {
    return _dbService.tankTransactions
        .filter()
        .tankIdEqualTo(tankId)
        .and()
        .isDeletedEqualTo(false)
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  Future<String?> saveTank(Tank tank) async {
    final normalizedId = tank.id.trim().isEmpty ? _uuid.v4() : tank.id.trim();
    final entity = TankEntity.fromDomain(_normalizeTank(tank, forceId: normalizedId));
    await _saveTankEntity(entity);
    return normalizedId;
  }

  Future<void> saveTankEntity(TankEntity tank) async {
    await _saveTankEntity(tank);
  }

  Future<void> updateTank(Tank tank) async {
    final entity = TankEntity.fromDomain(_normalizeTank(tank));
    await _saveTankEntity(entity);
  }

  Future<void> updateTankStock(String tankId, double newStock) async {
    final tank = await _dbService.tanks.getById(tankId);
    if (tank == null || tank.isDeleted) {
      return;
    }
    final adjustedStock = tank.capacity > 0
        ? newStock.clamp(0.0, tank.capacity).toDouble()
        : newStock;
    final fillLevel = tank.capacity > 0 ? (adjustedStock / tank.capacity) * 100 : 0.0;

    tank
      ..currentStock = adjustedStock
      ..fillLevel = fillLevel
      ..status = _statusForFillLevel(fillLevel);

    await _stampForSync(tank, tank);
    await _dbService.db.writeTxn(() async {
      await _dbService.tanks.put(tank);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.tanks,
      documentId: tank.id,
      operation: 'update',
      payload: tank.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> deleteTank(String tankId) async {
    final tank = await _dbService.tanks.getById(tankId);
    if (tank == null || tank.isDeleted) {
      return;
    }

    tank
      ..isDeleted = true
      ..deletedAt = DateTime.now()
      ..status = 'deleted';

    await _stampDeleted(tank);
    await _dbService.db.writeTxn(() async {
      await _dbService.tanks.put(tank);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.tanks,
      documentId: tank.id,
      operation: 'delete',
      payload: tank.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> refillTank({
    required String tankId,
    required double quantity,
    required String referenceId,
    required String operatorId,
    required String operatorName,
    String? supplierId,
    String? supplierName,
  }) async {
    final tank = await _dbService.tanks.getById(tankId);
    if (tank == null || tank.isDeleted) {
      throw Exception('Tank not found: $tankId');
    }

    final now = DateTime.now();
    final lot = TankLotEntity()
      ..id = 'lot_${now.microsecondsSinceEpoch}'
      ..tankId = tankId
      ..materialId = tank.materialId
      ..materialName = tank.materialName
      ..supplierId = supplierId ?? 'Unknown'
      ..supplierName = supplierName ?? 'Manual Refill'
      ..purchaseOrderId = referenceId
      ..receivedDate = now
      ..quantity = quantity
      ..initialQuantity = quantity
      ..status = 'active';

    final transaction = TankTransactionEntity()
      ..id = 'tx_${now.microsecondsSinceEpoch}'
      ..tankId = tankId
      ..tankName = tank.name
      ..type = 'fill'
      ..quantity = quantity
      ..previousStock = tank.currentStock
      ..newStock = tank.currentStock + quantity
      ..materialId = tank.materialId
      ..materialName = tank.materialName
      ..referenceId = referenceId
      ..referenceType = 'tank_refill'
      ..operatorId = operatorId
      ..operatorName = operatorName
      ..lotId = lot.id
      ..timestamp = now;

    await _ensureWarehouseLocationReady();
    await _stampForSync(tank, tank);
    await _stampForSync(lot, null);
    await _stampForSync(transaction, null);

    await _dbService.db.writeTxn(() async {
      final product = (await _dbService.products.where().findAll()).firstWhere(
        (item) => !item.isDeleted && item.name.toLowerCase() == tank.materialName.toLowerCase(),
        orElse: () => throw Exception('Product not found for material: ${tank.materialName}'),
      );
      final currentStock = product.stock ?? 0.0;
      if (currentStock < quantity) {
        throw Exception(
          'Insufficient purchase stock for ${tank.materialName}. Available: $currentStock, Required: $quantity',
        );
      }

      await _seedWarehouseBalanceInTxn(productId: product.id, occurredAt: now);
      final command = InventoryCommand.internalTransfer(
        sourceLocationId: InventoryProjectionService.warehouseMainLocationId,
        destinationLocationId: _tankInventoryLocationId(tankId),
        referenceId: referenceId,
        productId: product.id,
        quantityBase: quantity,
        actorUid: operatorId.trim().isEmpty ? 'system' : operatorId.trim(),
        reasonCode: 'tank_refill',
        referenceType: 'tank_refill',
        createdAt: now,
      );
      await _inventoryMovementEngine.applyCommandInTxn(command);

      final refreshedTank = await _dbService.tanks.getById(tankId) ?? tank;
      final previousStock = refreshedTank.currentStock;
      final newStockRaw = previousStock + quantity;
      final newStock = refreshedTank.capacity > 0
          ? newStockRaw.clamp(0.0, refreshedTank.capacity).toDouble()
          : newStockRaw;
      final fillLevel = refreshedTank.capacity > 0 ? (newStock / refreshedTank.capacity) * 100 : 0.0;

      refreshedTank
        ..currentStock = newStock
        ..fillLevel = fillLevel
        ..status = _statusForFillLevel(fillLevel);

      transaction
        ..previousStock = previousStock
        ..newStock = newStock;

      await _dbService.tanks.put(refreshedTank);
      await _dbService.tankLots.put(lot);
      await _dbService.tankTransactions.put(transaction);

      tank
        ..currentStock = refreshedTank.currentStock
        ..fillLevel = refreshedTank.fillLevel
        ..status = refreshedTank.status
        ..updatedAt = refreshedTank.updatedAt
        ..version = refreshedTank.version
        ..deviceId = refreshedTank.deviceId;
    });

    await _enqueueEntity(
      CollectionRegistry.tanks,
      tank.id,
      'update',
      tank.toJson(),
    );
    await _enqueueEntity(
      CollectionRegistry.tankLots,
      lot.id,
      'create',
      lot.toJson(),
    );
    await _enqueueEntity(
      CollectionRegistry.tankTransactions,
      transaction.id,
      'create',
      transaction.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> saveTankTransaction(TankTransactionEntity transaction) async {
    final id = _ensureId(transaction);
    final existing = await _dbService.tankTransactions.getById(id);
    transaction
      ..id = id
      ..timestamp = _ensureDate(() => transaction.timestamp, existing?.timestamp);

    await _stampForSync(transaction, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.tankTransactions.put(transaction);
    });

    await _enqueueEntity(
      CollectionRegistry.tankTransactions,
      transaction.id,
      existing == null ? 'create' : 'update',
      transaction.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> saveTransaction(TankTransactionEntity transaction) {
    return saveTankTransaction(transaction);
  }

  Future<void> saveTankLot(TankLotEntity lot) async {
    final id = _ensureId(lot);
    final existing = await _dbService.tankLots.getById(id);
    lot
      ..id = id
      ..receivedDate = _ensureDate(() => lot.receivedDate, existing?.receivedDate);

    await _stampForSync(lot, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.tankLots.put(lot);
    });

    await _enqueueEntity(
      CollectionRegistry.tankLots,
      lot.id,
      existing == null ? 'create' : 'update',
      lot.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> transferTank(
    String fromTankId,
    String toTankId,
    double quantity,
    String operatorId,
  ) async {
    final fromTank = await _dbService.tanks.getById(fromTankId);
    final toTank = await _dbService.tanks.getById(toTankId);
    if (fromTank == null || fromTank.isDeleted || toTank == null || toTank.isDeleted) {
      throw Exception('Both tanks must exist for transfer.');
    }
    if (fromTank.currentStock < quantity) {
      throw Exception('Insufficient stock in source tank.');
    }

    final now = DateTime.now();
    final referenceId = 'tank_transfer_${now.microsecondsSinceEpoch}';
    final outTx = TankTransactionEntity()
      ..id = 'tx_out_${now.microsecondsSinceEpoch}'
      ..tankId = fromTank.id
      ..tankName = fromTank.name
      ..type = 'OUT'
      ..quantity = quantity
      ..previousStock = fromTank.currentStock
      ..newStock = fromTank.currentStock - quantity
      ..materialId = fromTank.materialId
      ..materialName = fromTank.materialName
      ..referenceId = referenceId
      ..referenceType = 'tank_transfer'
      ..operatorId = operatorId
      ..operatorName = operatorId
      ..timestamp = now;
    final inTx = TankTransactionEntity()
      ..id = 'tx_in_${now.microsecondsSinceEpoch}'
      ..tankId = toTank.id
      ..tankName = toTank.name
      ..type = 'IN'
      ..quantity = quantity
      ..previousStock = toTank.currentStock
      ..newStock = toTank.currentStock + quantity
      ..materialId = toTank.materialId
      ..materialName = toTank.materialName
      ..referenceId = referenceId
      ..referenceType = 'tank_transfer'
      ..operatorId = operatorId
      ..operatorName = operatorId
      ..timestamp = now;

    await _stampForSync(fromTank, fromTank);
    await _stampForSync(toTank, toTank);
    await _stampForSync(outTx, null);
    await _stampForSync(inTx, null);

    await _dbService.db.writeTxn(() async {
      fromTank
        ..currentStock = outTx.newStock
        ..fillLevel = fromTank.capacity > 0 ? (outTx.newStock / fromTank.capacity) * 100 : 0.0
        ..status = _statusForFillLevel(fromTank.fillLevel);
      toTank
        ..currentStock = toTank.capacity > 0
            ? inTx.newStock.clamp(0.0, toTank.capacity).toDouble()
            : inTx.newStock
        ..fillLevel = toTank.capacity > 0 ? (toTank.currentStock / toTank.capacity) * 100 : 0.0
        ..status = _statusForFillLevel(toTank.fillLevel);

      await _dbService.tanks.put(fromTank);
      await _dbService.tanks.put(toTank);
      await _dbService.tankTransactions.put(outTx);
      await _dbService.tankTransactions.put(inTx);
    });

    await _enqueueEntity(CollectionRegistry.tanks, fromTank.id, 'update', fromTank.toJson());
    await _enqueueEntity(CollectionRegistry.tanks, toTank.id, 'update', toTank.toJson());
    await _enqueueEntity(CollectionRegistry.tankTransactions, outTx.id, 'create', outTx.toJson());
    await _enqueueEntity(CollectionRegistry.tankTransactions, inTx.id, 'create', inTx.toJson());

    await _syncIfOnline();
  }

  Future<void> fetchAndCacheTanks({String? bhattiName}) async {
    final service = _tankService;
    if (service == null) {
      return;
    }
    final remoteTanks = await service.fetchRemoteTanks(bhattiName: bhattiName);
    final remoteIds = remoteTanks.map((tank) => tank.id).toSet();

    await _dbService.db.writeTxn(() async {
      final pendingEntities = await _dbService.tanks
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      final pendingIds = pendingEntities.map((entity) => entity.id).toSet();

      final entitiesToUpdate = remoteTanks
          .where((tank) => !pendingIds.contains(tank.id))
          .map((tank) {
            final entity = TankEntity.fromDomain(_normalizeTank(tank));
            entity
              ..syncStatus = SyncStatus.synced
              ..isSynced = true
              ..lastSynced = DateTime.now();
            return entity;
          })
          .toList(growable: false);
      await _dbService.tanks.putAll(entitiesToUpdate);

      final allLocalSynced = await _dbService.tanks
          .filter()
          .syncStatusEqualTo(SyncStatus.synced)
          .findAll();
      for (final local in allLocalSynced) {
        if (!remoteIds.contains(local.id)) {
          local.isDeleted = true;
          await _dbService.tanks.put(local);
        }
      }
    });
  }

  Future<void> _saveTankEntity(TankEntity entity) async {
    final id = _ensureId(entity);
    final existing = await _dbService.tanks.getById(id);
    entity
      ..id = id
      ..createdAt = _ensureDate(() => entity.createdAt, existing?.createdAt)
      ..unit = _safeString(() => entity.unit, fallback: StorageUnitHelper.tonUnit)
      ..status = _safeString(() => entity.status, fallback: _statusForFillLevel(entity.fillLevel));

    await _stampForSync(entity, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.tanks.put(entity);
    });

    await _enqueueEntity(
      CollectionRegistry.tanks,
      entity.id,
      existing == null ? 'create' : 'update',
      entity.toJson(),
    );

    await _syncIfOnline();
  }

  Tank _normalizeTank(Tank tank, {String? forceId}) {
    final canonicalId = forceId ?? tank.id;
    final boundedFill = tank.capacity > 0
        ? ((tank.currentStock / tank.capacity) * 100).clamp(0.0, 100.0).toDouble()
        : 0.0;

    return Tank(
      id: canonicalId,
      name: tank.name,
      materialId: tank.materialId,
      materialName: tank.materialName,
      capacity: tank.capacity,
      currentStock: tank.currentStock,
      fillLevel: boundedFill,
      status: _statusForFillLevel(boundedFill),
      unit: StorageUnitHelper.tonUnit,
      updatedAt: tank.updatedAt,
      createdAt: tank.createdAt,
      department: tank.department,
      assignedUnit: tank.assignedUnit,
      type: tank.type,
      bags: tank.bags,
      maxBags: tank.maxBags,
      minStockLevel: tank.minStockLevel,
      isBhattiSourced: tank.isBhattiSourced,
    );
  }

  String _statusForFillLevel(double fillLevel) {
    if (fillLevel < 5) return 'critical';
    if (fillLevel < 15) return 'low-stock';
    return 'active';
  }

  Future<void> _stampForSync(BaseEntity entity, BaseEntity? existing) async {
    entity
      ..updatedAt = DateTime.now()
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();
  }

  Future<void> _stampDeleted(BaseEntity entity) async {
    entity
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();
  }

  Future<void> _enqueueEntity(
    String collectionName,
    String documentId,
    String operation,
    Map<String, dynamic> payload,
  ) {
    return _syncQueueService.addToQueue(
      collectionName: collectionName,
      documentId: documentId,
      operation: operation,
      payload: payload,
    );
  }

  String _ensureId(BaseEntity entity) {
    try {
      final id = entity.id.trim();
      if (id.isNotEmpty) {
        return id;
      }
    } catch (_) {
      // Late init fallback.
    }
    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
  }

  DateTime _ensureDate(DateTime Function() reader, DateTime? fallback) {
    try {
      return reader();
    } catch (_) {
      return fallback ?? DateTime.now();
    }
  }

  String _safeString(String Function() reader, {String fallback = ''}) {
    try {
      final value = reader().trim();
      return value.isEmpty ? fallback : value;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
