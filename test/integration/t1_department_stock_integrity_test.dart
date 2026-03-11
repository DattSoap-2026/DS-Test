import 'dart:ffi';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/inventory_service.dart';
import 'package:flutter_app/services/outbox_codec.dart';

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
  late InventoryService inventoryService;

  Future<void> seedProduct({
    required String id,
    required String name,
    required double stock,
  }) async {
    final now = DateTime.now();
    final product = ProductEntity()
      ..id = id
      ..name = name
      ..sku = 'SKU-$id'
      ..itemType = 'raw_material'
      ..type = 'raw_material'
      ..category = 'Raw Material'
      ..stock = stock
      ..baseUnit = 'pcs'
      ..price = 10
      ..status = 'active'
      ..createdAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    await dbService.db.writeTxn(() async {
      await dbService.products.put(product);
    });
  }

  setUpAll(() async {
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});

    tempDir = await Directory.systemTemp.createTemp(
      't1_department_stock_integrity_',
    );
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);

    final firebase = FirebaseServices();
    inventoryService = InventoryService(firebase, dbService);
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await dbService.db.writeTxn(() async {
      await dbService.products.clear();
      await dbService.departmentStocks.clear();
      await dbService.stockLedger.clear();
      await dbService.syncQueue.clear();
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

  test(
    'department issue and return keep main stock net unchanged and queue both commands',
    () async {
      await seedProduct(
        id: 'prod-dept-1',
        name: 'Department Material',
        stock: 100,
      );

      await inventoryService.transferToDepartment(
        departmentName: 'Sona Bhatti',
        items: const [
          {
            'productId': 'prod-dept-1',
            'productName': 'Department Material',
            'quantity': 10.0,
            'unit': 'pcs',
          },
        ],
        issuedByUserId: 'admin-1',
        issuedByUserName: 'Admin',
        referenceId: 'dept-ref-1',
      );

      await inventoryService.returnFromDepartment(
        departmentName: 'Sona Bhatti',
        items: const [
          {
            'productId': 'prod-dept-1',
            'productName': 'Department Material',
            'quantity': 10.0,
            'unit': 'pcs',
          },
        ],
        returnedByUserId: 'admin-1',
        returnedByUserName: 'Admin',
        referenceId: 'dept-ref-1',
      );

      final product = await dbService.products.getById('prod-dept-1');
      expect(product, isNotNull);
      expect(product!.stock, 100);

      final deptStocks = await dbService.departmentStocks.where().findAll();
      final matchingDeptStocks = deptStocks
          .where((entry) => entry.id == 'sona_bhatti_prod-dept-1')
          .toList();
      final deptStock = matchingDeptStocks.isEmpty
          ? null
          : matchingDeptStocks.first;
      expect(deptStock, isNotNull);
      expect(deptStock!.stock, 0);

      final ledgerEntries = (await dbService.stockLedger.where().findAll())
          .where((entry) => entry.productId == 'prod-dept-1')
          .toList();
      expect(
        ledgerEntries.where((entry) => entry.transactionType == 'ISSUE_DEPT'),
        isNotEmpty,
      );
      expect(
        ledgerEntries.where((entry) => entry.transactionType == 'RETURN_DEPT'),
        isNotEmpty,
      );

      final queueItems = await dbService.syncQueue.where().findAll();
      final issueQueue = queueItems
          .where(
            (entry) =>
                entry.collection == 'department_stocks' &&
                entry.action == 'issue_to_department',
          )
          .toList();
      final returnQueue = queueItems
          .where(
            (entry) =>
                entry.collection == 'department_stocks' &&
                entry.action == 'return_from_department',
          )
          .toList();
      expect(issueQueue.length, 1);
      expect(returnQueue.length, 1);

      final issuePayload = OutboxCodec.decode(
        issueQueue.first.dataJson,
        fallbackQueuedAt: issueQueue.first.createdAt,
      ).payload;
      final returnPayload = OutboxCodec.decode(
        returnQueue.first.dataJson,
        fallbackQueuedAt: returnQueue.first.createdAt,
      ).payload;
      expect(issuePayload['quantity'], 10.0);
      expect(returnPayload['quantity'], 10.0);
      expect(issuePayload['productId'], 'prod-dept-1');
      expect(returnPayload['productId'], 'prod-dept-1');
    },
    skip: _dbSkipReason ?? false,
  );
}
