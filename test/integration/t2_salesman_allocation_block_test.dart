import 'dart:ffi';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/exceptions/business_rule_exception.dart';
import 'package:flutter_app/models/types/sales_types.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/inventory_service.dart';
import 'package:flutter_app/services/sales_service.dart';

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
  late SalesService salesService;

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
      ..itemType = 'finished_good'
      ..type = 'finished_good'
      ..category = 'Soap'
      ..stock = stock
      ..baseUnit = 'pcs'
      ..price = 25
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
      't2_salesman_allocation_block_',
    );
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);

    final firebase = FirebaseServices();
    inventoryService = InventoryService(firebase, dbService);
    salesService = SalesService(firebase, dbService, inventoryService);
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await dbService.db.writeTxn(() async {
      await dbService.products.clear();
      await dbService.sales.clear();
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
    'salesman recipient type is blocked before stock, ledger, sale, or queue mutation',
    () async {
      await seedProduct(
        id: 'prod-salesman-block-1',
        name: 'Blocked Transfer Product',
        stock: 100,
      );

      await expectLater(
        salesService.createSale(
          recipientType: 'salesman',
          recipientId: 'salesman-1',
          recipientName: 'Salesman One',
          items: [
            SaleItemForUI(
              productId: 'prod-salesman-block-1',
              name: 'Blocked Transfer Product',
              quantity: 5,
              price: 25,
              baseUnit: 'pcs',
              stock: 100,
            ),
          ],
          discountPercentage: 0,
        ),
        throwsA(
          isA<BusinessRuleException>().having(
            (e) => e.toString(),
            'message',
            contains('dispatch workflow'),
          ),
        ),
      );

      final product = await dbService.products.getById('prod-salesman-block-1');
      expect(product, isNotNull);
      expect(product!.stock, 100);

      final sales = await dbService.sales.where().findAll();
      expect(sales, isEmpty);

      final ledger = await dbService.stockLedger.where().findAll();
      expect(ledger, isEmpty);

      final queue = await dbService.syncQueue.where().findAll();
      expect(queue, isEmpty);
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'salesman recipient type is blocked case-insensitively before any mutation',
    () async {
      await seedProduct(
        id: 'prod-salesman-block-2',
        name: 'Blocked Transfer Product Mixed Case',
        stock: 100,
      );

      await expectLater(
        salesService.createSale(
          recipientType: 'Salesman',
          recipientId: 'salesman-2',
          recipientName: 'Salesman Two',
          items: [
            SaleItemForUI(
              productId: 'prod-salesman-block-2',
              name: 'Blocked Transfer Product Mixed Case',
              quantity: 5,
              price: 25,
              baseUnit: 'pcs',
              stock: 100,
            ),
          ],
          discountPercentage: 0,
        ),
        throwsA(
          isA<BusinessRuleException>().having(
            (e) => e.toString(),
            'message',
            contains('dispatch workflow'),
          ),
        ),
      );

      final product = await dbService.products.getById('prod-salesman-block-2');
      expect(product, isNotNull);
      expect(product!.stock, 100);

      final sales = await dbService.sales.where().findAll();
      expect(sales, isEmpty);

      final ledger = await dbService.stockLedger.where().findAll();
      expect(ledger, isEmpty);

      final queue = await dbService.syncQueue.where().findAll();
      expect(queue, isEmpty);
    },
    skip: _dbSkipReason ?? false,
  );
}
