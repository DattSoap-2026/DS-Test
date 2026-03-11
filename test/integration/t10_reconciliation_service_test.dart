import 'dart:io';
import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/department_master_service.dart';
import 'package:flutter_app/services/inventory_projection_service.dart';
import 'package:flutter_app/services/reconciliation_service.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/data/local/entities/stock_balance_entity.dart';
import 'package:flutter_app/data/local/entities/inventory_command_entity.dart';
import 'package:flutter_app/data/local/entities/stock_movement_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
bool get _shouldSkipDbTests => _dbSkipReason != null;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService dbService;
  late Directory tempDir;
  late ReconciliationService reconciliationService;

  setUpAll(() async {
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});

    tempDir = await Directory.systemTemp.createTemp('t10_reconciliation_');
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);

    final departmentMasterService = DepartmentMasterService(dbService);
    reconciliationService = ReconciliationService(
      dbService,
      departmentMasterService: departmentMasterService,
    );

    final projectionService = InventoryProjectionService(
      dbService,
      departmentMasterService: departmentMasterService,
    );
    await projectionService.ensureCanonicalFoundation();
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    await dbService.db.writeTxn(() async {
      await dbService.stockBalances.clear();
      await dbService.products.clear();
      await dbService.users.clear();
      await dbService.inventoryCommands.clear();
      await dbService.stockMovements.clear();
      await dbService.departmentStocks.clear();
    });
  });

  tearDownAll(() async {
    if (_shouldSkipDbTests) return;
    await dbService.db.close();
    if (tempDir.existsSync()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  group('T10 ReconciliationService Tests', () {
    test('Clean report when no data exists', () async {
      final report = await reconciliationService.generateReport();
      expect(report.isClean, isTrue);
      expect(report.warehouseMismatches.isEmpty, isTrue);
      expect(report.departmentMismatches.isEmpty, isTrue);
      expect(report.salesmanMismatches.isEmpty, isTrue);
      expect(report.duplicateMovements.isEmpty, isTrue);
      expect(report.stuckQueueItems.isEmpty, isTrue);
    }, skip: _dbSkipReason ?? false);

    test('Detects warehouse mismatch', () async {
      final productId = 'prod-1';
      final now = DateTime.now();

      await dbService.db.writeTxn(() async {
        await dbService.products.put(
          ProductEntity()
            ..id = productId
            ..name = 'Test Product'
            ..sku = 'SKU-1'
            ..itemType = 'finished_good'
            ..type = 'finished_good'
            ..category = 'Test'
            ..stock = 100.0
            ..baseUnit = 'pcs'
            ..price = 10
            ..status = 'active'
            ..createdAt = now
            ..updatedAt = now
            ..syncStatus = SyncStatus.synced
            ..isDeleted = false,
        );

        await dbService.stockBalances.put(
          StockBalanceEntity()
            ..id =
                '${InventoryProjectionService.warehouseMainLocationId}_$productId'
            ..locationId = InventoryProjectionService.warehouseMainLocationId
            ..productId = productId
            ..quantity = 90.0
            ..updatedAt = now
            ..syncStatus = SyncStatus.synced
            ..isDeleted = false,
        );
      });

      final report = await reconciliationService.generateReport();
      expect(report.isClean, isFalse);
      expect(report.warehouseMismatches.length, 1);
      expect(report.warehouseMismatches.first.legacyValue, 100.0);
      expect(report.warehouseMismatches.first.canonicalValue, 90.0);
      expect(report.warehouseMismatches.first.delta, 10.0);
    }, skip: _dbSkipReason ?? false);

    test('Detects salesman mismatch', () async {
      final salesmanId = 'salesman-1';
      final productId = 'prod-1';
      final now = DateTime.now();

      await dbService.db.writeTxn(() async {
        final user = UserEntity()
          ..id = salesmanId
          ..email = 'salesman@test.local'
          ..name = 'Test Salesman'
          ..role = 'Salesman'
          ..isActive = true
          ..updatedAt = now
          ..syncStatus = SyncStatus.synced
          ..isDeleted = false;

        user.setAllocatedStock({
          productId: AllocatedStockItem(
            productId: productId,
            name: 'Test Product',
            quantity: 50,
            price: 10,
            baseUnit: 'pcs',
            conversionFactor: 1,
            freeQuantity: 0,
          ),
        });

        await dbService.users.put(user);

        await dbService.stockBalances.put(
          StockBalanceEntity()
            ..id = 'salesman_van_${salesmanId}_$productId'
            ..locationId = 'salesman_van_$salesmanId'
            ..productId = productId
            ..quantity = 45.0
            ..updatedAt = now
            ..syncStatus = SyncStatus.synced
            ..isDeleted = false,
        );
      });

      final report = await reconciliationService.generateReport();
      expect(report.isClean, isFalse);
      expect(report.salesmanMismatches.length, 1);
      expect(report.salesmanMismatches.first.legacyValue, 50.0);
      expect(report.salesmanMismatches.first.canonicalValue, 45.0);
      expect(report.salesmanMismatches.first.delta, 5.0);
    }, skip: _dbSkipReason ?? false);

    test('Detects stuck queue items', () async {
      final now = DateTime.now();
      final oldTime = now.subtract(const Duration(hours: 25));

      await dbService.db.writeTxn(() async {
        await dbService.inventoryCommands.put(
          InventoryCommandEntity()
            ..commandId = 'stuck-command-1'
            ..commandType = 'dispatch_create'
            ..payload = '{}'
            ..actorUid = 'actor-1'
            ..createdAt = oldTime
            ..updatedAt = oldTime
            ..appliedLocally = true
            ..appliedRemotely = false,
        );
      });

      final report = await reconciliationService.generateReport();
      expect(report.isClean, isFalse);
      expect(report.stuckQueueItems.length, 1);
      expect(report.stuckQueueItems.first, 'stuck-command-1');
    }, skip: _dbSkipReason ?? false);

    test('Detects duplicate movements', () async {
      final commandId = 'command-1';
      final now = DateTime.now();

      await dbService.db.writeTxn(() async {
        await dbService.inventoryCommands.put(
          InventoryCommandEntity()
            ..commandId = commandId
            ..commandType = 'dispatch_create'
            ..payload = '{}'
            ..actorUid = 'actor-1'
            ..createdAt = now
            ..updatedAt = now
            ..appliedLocally = true
            ..appliedRemotely = false,
        );

        // movementId must follow commandId:index format so
        // StockMovementEntity.commandId getter can parse the commandId
        // after Isar deserialization (private _commandIdOverride is NOT stored)
        await dbService.stockMovements.putAll([
          StockMovementEntity()
            ..movementId = '$commandId:0'
            ..commandId = commandId
            ..movementIndex = 0
            ..productId = 'prod-1'
            ..sourceLocationId = 'loc-1'
            ..destinationLocationId = 'loc-2'
            ..quantityBase = 10.0
            ..movementType = 'dispatch_create'
            ..actorUid = 'actor-1'
            ..updatedAt = now
            ..occurredAt = now,
          StockMovementEntity()
            ..movementId = '$commandId:1'
            ..commandId = commandId
            ..movementIndex = 1
            ..productId = 'prod-1'
            ..sourceLocationId = 'loc-1'
            ..destinationLocationId = 'loc-2'
            ..quantityBase = 10.0
            ..movementType = 'dispatch_create'
            ..actorUid = 'actor-1'
            ..updatedAt = now
            ..occurredAt = now,
        ]);
      });

      final report = await reconciliationService.generateReport();
      expect(report.isClean, isFalse);
      expect(report.duplicateMovements.length, 1);
      expect(report.duplicateMovements.first, commandId);
    }, skip: _dbSkipReason ?? false);

    test('Clean report when everything matches', () async {
      final productId = 'prod-1';
      final now = DateTime.now();

      await dbService.db.writeTxn(() async {
        await dbService.products.put(
          ProductEntity()
            ..id = productId
            ..name = 'Test Product'
            ..sku = 'SKU-1'
            ..itemType = 'finished_good'
            ..type = 'finished_good'
            ..category = 'Test'
            ..stock = 100.0
            ..baseUnit = 'pcs'
            ..price = 10
            ..status = 'active'
            ..createdAt = now
            ..updatedAt = now
            ..syncStatus = SyncStatus.synced
            ..isDeleted = false,
        );

        await dbService.stockBalances.put(
          StockBalanceEntity()
            ..id =
                '${InventoryProjectionService.warehouseMainLocationId}_$productId'
            ..locationId = InventoryProjectionService.warehouseMainLocationId
            ..productId = productId
            ..quantity = 100.0
            ..updatedAt = now
            ..syncStatus = SyncStatus.synced
            ..isDeleted = false,
        );
      });

      final report = await reconciliationService.generateReport();
      expect(report.isClean, isTrue);
    }, skip: _dbSkipReason ?? false);
  });
}
