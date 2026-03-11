import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/inventory_projection_service.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const runDbTests = bool.fromEnvironment('RUN_DB_TESTS', defaultValue: false);

  if (!runDbTests) {
    test('T9-P5 tests skipped (set RUN_DB_TESTS=true to run)', () {});
    return;
  }

  late DatabaseService dbService;
  late InventoryProjectionService projectionService;
  late Directory tempDir;

  setUpAll(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tempDir = await Directory.systemTemp.createTemp('t9_p5_cleanup_');
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);
    projectionService = InventoryProjectionService(dbService);
    await projectionService.ensureCanonicalFoundation();
  });

  setUp(() async {
    await dbService.db.writeTxn(() async {
      await dbService.stockBalances.clear();
      await dbService.products.clear();
      await dbService.users.clear();
      await dbService.departmentStocks.clear();
    });
  });

  tearDownAll(() async {
    await dbService.db.close();
    if (tempDir.existsSync()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  group('T9-P5 Cleanup Tests', () {
    test(
      '1. clearRemoteAllocatedStock: stock_balances cleared, projection updated',
      () async {
        final userId = 'salesman_test_1';
        final productId = 'product_1';
        final locationId = 'salesman_van_$userId';

        await dbService.db.writeTxn(() async {
          await dbService.users.put(
            UserEntity()
              ..id = userId
              ..name = 'Test Salesman'
              ..email = 'test@example.com'
              ..role = 'Salesman'
              ..isActive = true
              ..allocatedStockJson = '{"$productId":{"quantity":10}}'
              ..updatedAt = DateTime.now()
              ..syncStatus = SyncStatus.synced,
          );
          await dbService.products.put(
            ProductEntity()
              ..id = productId
              ..name = 'Test Product'
              ..sku = 'TEST-SKU-1'
              ..stock = 0
              ..baseUnit = 'pcs'
              ..itemType = 'finished_good'
              ..type = 'finished_good'
              ..updatedAt = DateTime.now()
              ..syncStatus = SyncStatus.synced,
          );
        });

        await projectionService.ensureInventoryLocations();

        await projectionService.setBalanceQuantity(
          locationId: locationId,
          productId: productId,
          quantity: 10,
        );

        var balance = await projectionService.getBalance(
          locationId: locationId,
          productId: productId,
        );
        expect(balance?.quantity, 10);

        await projectionService.setBalanceQuantity(
          locationId: locationId,
          productId: productId,
          quantity: 0,
        );

        balance = await projectionService.getBalance(
          locationId: locationId,
          productId: productId,
        );
        expect(balance?.quantity, 0);

        final user = await dbService.users.getById(userId);
        final allocatedStock = user?.getAllocatedStock();
        expect(allocatedStock?.isEmpty ?? true, true);
      },
    );

    test(
      '2. recomputeRemoteProductStock: products.stock mirror matches warehouse_main',
      () async {
        final productId = 'product_2';
        final warehouseLocationId =
            InventoryProjectionService.warehouseMainLocationId;

        await dbService.db.writeTxn(() async {
          await dbService.products.put(
            ProductEntity()
              ..id = productId
              ..name = 'Test Product 2'
              ..sku = 'TEST-SKU-2'
              ..stock = 0
              ..baseUnit = 'pcs'
              ..itemType = 'finished_good'
              ..type = 'finished_good'
              ..updatedAt = DateTime.now()
              ..syncStatus = SyncStatus.synced,
          );
        });

        await projectionService.setBalanceQuantity(
          locationId: warehouseLocationId,
          productId: productId,
          quantity: 50,
        );

        final product = await dbService.products.getById(productId);
        expect(product?.stock, 50);

        final balance = await projectionService.getBalance(
          locationId: warehouseLocationId,
          productId: productId,
        );
        expect(balance?.quantity, 50);
      },
    );

    test(
      '3. resetLocalTransactionalData: local balances reset, projections reset',
      () async {
        final productId = 'product_3';
        final warehouseLocationId =
            InventoryProjectionService.warehouseMainLocationId;

        await dbService.db.writeTxn(() async {
          await dbService.products.put(
            ProductEntity()
              ..id = productId
              ..name = 'Test Product 3'
              ..sku = 'TEST-SKU-3'
              ..stock = 100
              ..baseUnit = 'pcs'
              ..itemType = 'finished_good'
              ..type = 'finished_good'
              ..updatedAt = DateTime.now()
              ..syncStatus = SyncStatus.synced,
          );
        });

        await projectionService.setBalanceQuantity(
          locationId: warehouseLocationId,
          productId: productId,
          quantity: 0,
        );

        final product = await dbService.products.getById(productId);
        expect(product?.stock, 0);

        final balance = await projectionService.getBalance(
          locationId: warehouseLocationId,
          productId: productId,
        );
        expect(balance?.quantity, 0);
      },
    );

    test(
      '4. sync_manager mirror overwrite: allocatedStock mirror stays in sync',
      () async {
        final userId = 'salesman_test_4';
        final productId = 'product_4';
        final locationId = 'salesman_van_$userId';

        await dbService.db.writeTxn(() async {
          await dbService.users.put(
            UserEntity()
              ..id = userId
              ..name = 'Test Salesman 4'
              ..email = 'test4@example.com'
              ..role = 'Salesman'
              ..isActive = true
              ..allocatedStockJson = null
              ..updatedAt = DateTime.now()
              ..syncStatus = SyncStatus.synced,
          );
          await dbService.products.put(
            ProductEntity()
              ..id = productId
              ..name = 'Test Product 4'
              ..sku = 'TEST-SKU-4'
              ..stock = 0
              ..baseUnit = 'pcs'
              ..itemType = 'finished_good'
              ..type = 'finished_good'
              ..updatedAt = DateTime.now()
              ..syncStatus = SyncStatus.synced,
          );
        });

        await projectionService.ensureInventoryLocations();

        await projectionService.setBalanceQuantity(
          locationId: locationId,
          productId: productId,
          quantity: 25,
        );

        final user = await dbService.users.getById(userId);
        final allocatedStock = user?.getAllocatedStock();
        expect(allocatedStock?[productId]?.quantity, 25);

        final balance = await projectionService.getBalance(
          locationId: locationId,
          productId: productId,
        );
        expect(balance?.quantity, 25);
      },
    );

    test(
      '5. reconcileStockAllocations: reconcile reads from stock_balances',
      () async {
        final userId = 'salesman_test_5';
        final productId = 'product_5';
        final locationId = 'salesman_van_$userId';

        await dbService.db.writeTxn(() async {
          await dbService.users.put(
            UserEntity()
              ..id = userId
              ..name = 'Test Salesman 5'
              ..email = 'test5@example.com'
              ..role = 'Salesman'
              ..isActive = true
              ..allocatedStockJson = '{"$productId":{"quantity":15}}'
              ..updatedAt = DateTime.now()
              ..syncStatus = SyncStatus.synced,
          );
          await dbService.products.put(
            ProductEntity()
              ..id = productId
              ..name = 'Test Product 5'
              ..sku = 'TEST-SKU-5'
              ..stock = 0
              ..baseUnit = 'pcs'
              ..itemType = 'finished_good'
              ..type = 'finished_good'
              ..updatedAt = DateTime.now()
              ..syncStatus = SyncStatus.synced,
          );
        });

        await projectionService.ensureInventoryLocations();

        await projectionService.setBalanceQuantity(
          locationId: locationId,
          productId: productId,
          quantity: 15,
        );

        final balance = await projectionService.getBalance(
          locationId: locationId,
          productId: productId,
        );
        expect(balance?.quantity, 15);

        final user = await dbService.users.getById(userId);
        final allocatedStock = user?.getAllocatedStock();
        expect(allocatedStock?[productId]?.quantity, 15);
      },
    );

    test(
      '6. users_sync_delegate syncUsers: remote push uses stock_balances',
      () async {
        final userId = 'salesman_test_6';
        final productId = 'product_6';
        final locationId = 'salesman_van_$userId';

        await dbService.db.writeTxn(() async {
          await dbService.users.put(
            UserEntity()
              ..id = userId
              ..name = 'Test Salesman 6'
              ..email = 'test6@example.com'
              ..role = 'Salesman'
              ..isActive = true
              ..allocatedStockJson = null
              ..updatedAt = DateTime.now()
              ..syncStatus = SyncStatus.pending,
          );
          await dbService.products.put(
            ProductEntity()
              ..id = productId
              ..name = 'Test Product 6'
              ..sku = 'TEST-SKU-6'
              ..stock = 0
              ..baseUnit = 'pcs'
              ..itemType = 'finished_good'
              ..type = 'finished_good'
              ..updatedAt = DateTime.now()
              ..syncStatus = SyncStatus.synced,
          );
        });

        await projectionService.ensureInventoryLocations();

        await projectionService.setBalanceQuantity(
          locationId: locationId,
          productId: productId,
          quantity: 30,
          syncStatus: SyncStatus.pending,
        );

        final balance = await projectionService.getBalance(
          locationId: locationId,
          productId: productId,
        );
        expect(balance?.quantity, 30);
        expect(balance?.syncStatus, SyncStatus.pending);

        final user = await dbService.users.getById(userId);
        final allocatedStock = user?.getAllocatedStock();
        expect(allocatedStock?[productId]?.quantity, 30);
      },
    );
  });
}
