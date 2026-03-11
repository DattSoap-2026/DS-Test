// ignore_for_file: subtype_of_sealed_class

import 'dart:ffi';
import 'dart:io';

import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/department_stock_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/department_master_service.dart';
import 'package:flutter_app/services/inventory_projection_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bool _runDbTests = bool.fromEnvironment(
  'RUN_DB_TESTS',
  defaultValue: false,
);

String? _detectDbSkipReason() {
  if (!_runDbTests) {
    return 'Requires Isar native library. Run with --dart-define=RUN_DB_TESTS=true';
  }

  if (Platform.isWindows) {
    final dllPath =
        '${Directory.current.path}${Platform.pathSeparator}isar.dll';
    try {
      DynamicLibrary.open(dllPath);
    } catch (e) {
      return 'RUN_DB_TESTS=true but Isar native library is unavailable: $e';
    }
  }

  return null;
}

final String? _dbSkipReason = _detectDbSkipReason();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService dbService;
  late Directory tempDir;
  late DepartmentMasterService departmentMasterService;
  late InventoryProjectionService inventoryProjectionService;

  Future<void> seedProduct({
    required String id,
    required String name,
    required double stock,
    String baseUnit = 'Kg',
    double price = 10,
  }) async {
    final now = DateTime.now();
    final product = ProductEntity()
      ..id = id
      ..name = name
      ..sku = 'SKU-$id'
      ..itemType = 'finished_good'
      ..type = 'finished_good'
      ..category = 'Soap'
      ..stock = stock
      ..baseUnit = baseUnit
      ..price = price
      ..status = 'active'
      ..createdAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;

    await dbService.db.writeTxn(() async {
      await dbService.products.put(product);
    });
  }

  Future<void> seedDepartmentStock({
    required String departmentName,
    required String productId,
    required String productName,
    required double stock,
    String unit = 'Kg',
  }) async {
    final now = DateTime.now();
    final entity = DepartmentStockEntity()
      ..id = '${departmentName}_$productId'
      ..departmentName = departmentName
      ..productId = productId
      ..productName = productName
      ..stock = stock
      ..unit = unit
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;

    await dbService.db.writeTxn(() async {
      await dbService.departmentStocks.put(entity);
    });
  }

  Future<void> seedSalesman({
    required String id,
    required String role,
    required bool isActive,
    Map<String, AllocatedStockItem> allocatedStock = const {},
  }) async {
    final now = DateTime.now();
    final user = UserEntity()
      ..id = id
      ..name = 'User $id'
      ..email = '$id@test.local'
      ..role = role
      ..isActive = isActive
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;

    if (allocatedStock.isNotEmpty) {
      user.setAllocatedStock(allocatedStock);
    }

    await dbService.db.writeTxn(() async {
      await dbService.users.put(user);
    });
  }

  setUpAll(() async {
    if (_dbSkipReason != null) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});

    tempDir = await Directory.systemTemp.createTemp('t7_inventory_master_');
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);

    departmentMasterService = DepartmentMasterService(dbService);
    inventoryProjectionService = InventoryProjectionService(
      dbService,
      departmentMasterService: departmentMasterService,
    );
  });

  setUp(() async {
    if (_dbSkipReason != null) return;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await dbService.db.writeTxn(() async {
      await dbService.stockBalances.clear();
      await dbService.inventoryLocations.clear();
      await dbService.departmentMasters.clear();
      await dbService.departmentStocks.clear();
      await dbService.products.clear();
      await dbService.users.clear();
    });
  });

  tearDownAll(() async {
    if (_dbSkipReason != null) return;
    await dbService.db.close();
    if (tempDir.existsSync()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  group('T7 Canonical Inventory Foundation', () {
    test(
      'seeds canonical departments, locations, backfills balances, mirrors warehouse stock, and stays idempotent',
      () async {
        await seedProduct(
          id: 'prod-main-1',
          name: 'Main Soap',
          stock: 120,
        );
        await seedProduct(
          id: 'prod-main-2',
          name: 'Packing Soap',
          stock: 55,
          baseUnit: 'Pcs',
        );

        await seedDepartmentStock(
          departmentName: 'Sona Bhatti',
          productId: 'prod-main-1',
          productName: 'Main Soap',
          stock: 17,
        );
        await seedDepartmentStock(
          departmentName: 'sona',
          productId: 'prod-main-2',
          productName: 'Packing Soap',
          stock: 9,
          unit: 'Pcs',
        );

        await seedSalesman(
          id: 'salesman-uid-1',
          role: 'Salesman',
          isActive: true,
          allocatedStock: {
            'prod-main-1': AllocatedStockItem(
              name: 'Main Soap',
              quantity: 4,
              freeQuantity: 1,
              productId: 'prod-main-1',
              price: 10,
              baseUnit: 'Kg',
              conversionFactor: 1,
            ),
          },
        );
        await seedSalesman(
          id: 'salesman-uid-inactive',
          role: 'Salesman',
          isActive: false,
        );
        await seedSalesman(
          id: 'dispatch-manager-1',
          role: 'Dispatch Manager',
          isActive: true,
        );

        final firstBootstrap =
            await inventoryProjectionService.ensureCanonicalFoundation();

        final departments = await dbService.departmentMasters.where().findAll();
        expect(departments, hasLength(6));
        expect(
          departments.map((entity) => entity.departmentId).toSet(),
          hasLength(6),
        );
        expect(
          departments.map((entity) => entity.departmentCode).toSet(),
          hasLength(6),
        );
        expect(firstBootstrap.departmentSeedCount, 6);
        expect(firstBootstrap.departmentCreatedCount, 6);

        final locations = await dbService.inventoryLocations.where().findAll();
        expect(locations, hasLength(8));
        expect(
          locations.map((entity) => entity.id).toSet(),
          containsAll(<String>[
            DepartmentMasterService.warehouseMainLocationId,
            'dept_sona_bhatti',
            'dept_gita_bhatti',
            'dept_sona_production',
            'dept_gita_production',
            'dept_production',
            'dept_packing',
            'salesman_van_salesman-uid-1',
          ]),
        );
        expect(
          locations.any((entity) => entity.id == 'salesman_van_salesman-uid-inactive'),
          isFalse,
        );
        final warehouseLocation = locations.singleWhere(
          (entity) => entity.id == DepartmentMasterService.warehouseMainLocationId,
        );
        expect(warehouseLocation.type, 'warehouse');
        expect(warehouseLocation.isPrimaryMainWarehouse, isTrue);
        final salesmanLocation = locations.singleWhere(
          (entity) => entity.id == 'salesman_van_salesman-uid-1',
        );
        expect(salesmanLocation.type, 'salesman_van');
        expect(salesmanLocation.ownerUserUid, 'salesman-uid-1');
        expect(firstBootstrap.locationCreatedCount, 8);

        final warehouseBalance1 = await inventoryProjectionService.getBalance(
          locationId: DepartmentMasterService.warehouseMainLocationId,
          productId: 'prod-main-1',
        );
        final warehouseBalance2 = await inventoryProjectionService.getBalance(
          locationId: DepartmentMasterService.warehouseMainLocationId,
          productId: 'prod-main-2',
        );
        expect(warehouseBalance1?.quantity, 120);
        expect(warehouseBalance2?.quantity, 55);

        final departmentBalance =
            await inventoryProjectionService.getBalance(
              locationId: 'dept_sona_bhatti',
              productId: 'prod-main-1',
            );
        final productionAliasBalance =
            await inventoryProjectionService.getBalance(
              locationId: 'dept_sona_production',
              productId: 'prod-main-2',
            );
        final salesmanBalance = await inventoryProjectionService.getBalance(
          locationId: 'salesman_van_salesman-uid-1',
          productId: 'prod-main-1',
        );
        expect(departmentBalance?.quantity, 17);
        expect(productionAliasBalance?.quantity, 9);
        expect(salesmanBalance?.quantity, 5);
        expect(firstBootstrap.stockBalanceCreatedCount, 5);

        await inventoryProjectionService.setBalanceQuantity(
          locationId: DepartmentMasterService.warehouseMainLocationId,
          productId: 'prod-main-1',
          quantity: 88.5,
          syncStatus: SyncStatus.pending,
        );

        final updatedWarehouseBalance =
            await inventoryProjectionService.getBalance(
              locationId: DepartmentMasterService.warehouseMainLocationId,
              productId: 'prod-main-1',
            );
        final updatedProduct = await dbService.products.getById('prod-main-1');
        expect(updatedWarehouseBalance?.quantity, 88.5);
        expect(updatedWarehouseBalance?.syncStatus, SyncStatus.pending);
        expect(updatedProduct?.stock, 88.5);
        expect(updatedProduct?.syncStatus, SyncStatus.pending);

        final secondBootstrap =
            await inventoryProjectionService.ensureCanonicalFoundation();
        final stockBalanceCount = await dbService.stockBalances.count();
        final locationCount = await dbService.inventoryLocations.count();
        final departmentCount = await dbService.departmentMasters.count();

        expect(secondBootstrap.departmentCreatedCount, 0);
        expect(secondBootstrap.locationCreatedCount, 0);
        expect(secondBootstrap.stockBalanceCreatedCount, 0);
        expect(stockBalanceCount, 5);
        expect(locationCount, 8);
        expect(departmentCount, 6);

        final preservedWarehouseBalance =
            await inventoryProjectionService.getBalance(
              locationId: DepartmentMasterService.warehouseMainLocationId,
              productId: 'prod-main-1',
            );
        expect(preservedWarehouseBalance?.quantity, 88.5);
      },
      skip: _dbSkipReason ?? false,
    );
  });
}
