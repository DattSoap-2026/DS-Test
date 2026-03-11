import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/inventory_service.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/stock_ledger_entity.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/models/types/sales_types.dart';
import 'package:isar/isar.dart';
import 'dart:convert';
import 'dart:io';

class MockFirebaseServices implements FirebaseServices {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late Isar isar;
  late DatabaseService dbService;
  late InventoryService inventoryService;
  late MockFirebaseServices mockFirebase;

  setUp(() async {
    await Isar.initializeIsarCore(download: true);
    final tempIsar = await Isar.open(
      [
        UserEntitySchema,
        ProductEntitySchema,
        StockLedgerEntitySchema,
        SyncQueueEntitySchema,
      ],
      directory: Directory.systemTemp.path,
      name: 'test_salesman_stock_${DateTime.now().millisecondsSinceEpoch}',
    );
    isar = tempIsar;
    dbService = DatabaseService.instance;
    mockFirebase = MockFirebaseServices();
    inventoryService = InventoryService(mockFirebase, dbService);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('TEST-1: Salesman Dispatch Stock Test', () {
    test('Dispatch 20 units to salesman', () async {
      final now = DateTime.now();
      final product = ProductEntity()
        ..id = 'prod_001'
        ..name = 'Test Product'
        ..sku = 'TEST-001'
        ..stock = 100.0
        ..baseUnit = 'Pcs'
        ..itemType = 'product'
        ..type = 'finished_good'
        ..updatedAt = now;

      await isar.writeTxn(() async {
        await isar.productEntitys.put(product);
      });

      final salesman = UserEntity()
        ..id = 'salesman_001'
        ..name = 'Test Salesman'
        ..email = 'salesman@test.com'
        ..role = 'Salesman'
        ..allocatedStockJson = jsonEncode({})
        ..updatedAt = now;

      await isar.writeTxn(() async {
        await isar.userEntitys.put(salesman);
      });

      final items = [
        SaleItem(
          productId: 'prod_001',
          name: 'Test Product',
          quantity: 20,
          price: 100.0,
          baseUnit: 'Pcs',
          isFree: false,
          discount: 0,
        ),
      ];

      await inventoryService.dispatchToSalesman(
        salesman: AppUser(
          id: 'salesman_001',
          name: 'Test Salesman',
          email: 'salesman@test.com',
          role: UserRole.salesman,
          departments: [],
          createdAt: now.toIso8601String(),
        ),
        vehicleId: 'vehicle_001',
        vehicleNumber: 'TEST-123',
        dispatchRoute: 'Route A',
        salesRoute: 'Route A',
        items: items,
        subtotal: 2000.0,
        totalAmount: 2000.0,
        userId: 'admin_001',
        userName: 'Admin',
      );

      final updatedProduct = await isar.productEntitys.get(product.isarId);
      expect(updatedProduct?.stock, equals(80.0));

      final updatedSalesman = await isar.userEntitys.get(salesman.isarId);
      final allocatedStock = jsonDecode(updatedSalesman!.allocatedStockJson!);
      expect(allocatedStock['prod_001']['quantity'], equals(20));

      final ledgerEntries = await isar.stockLedgerEntitys
          .filter()
          .productIdEqualTo('prod_001')
          .and()
          .transactionTypeEqualTo('DISPATCH_OUT')
          .findAll();
      expect(ledgerEntries.length, greaterThan(0));
      expect(ledgerEntries.first.quantityChange, equals(-20.0));
    });
  });

  group('TEST-2: Salesman Full Return Test', () {
    test('Return all 20 units after dispatch', () async {
      final now = DateTime.now();
      final product = ProductEntity()
        ..id = 'prod_001'
        ..name = 'Test Product'
        ..sku = 'TEST-001'
        ..stock = 80.0
        ..baseUnit = 'Pcs'
        ..itemType = 'product'
        ..type = 'finished_good'
        ..updatedAt = now;

      await isar.writeTxn(() async {
        await isar.productEntitys.put(product);
      });

      final salesman = UserEntity()
        ..id = 'salesman_001'
        ..name = 'Test Salesman'
        ..email = 'salesman@test.com'
        ..role = 'Salesman'
        ..allocatedStockJson = jsonEncode({
          'prod_001': {
            'productId': 'prod_001',
            'name': 'Test Product',
            'quantity': 20,
            'freeQuantity': 0,
            'price': 100.0,
            'baseUnit': 'Pcs',
            'conversionFactor': 1.0,
          }
        })
        ..updatedAt = now;

      await isar.writeTxn(() async {
        await isar.userEntitys.put(salesman);
      });

      await inventoryService.returnFromSalesman(
        salesmanId: 'salesman_001',
        items: [
          {
            'productId': 'prod_001',
            'quantity': 20,
            'isFree': false,
            'unit': 'Pcs',
          }
        ],
        returnedByUserId: 'salesman_001',
        returnedByUserName: 'Test Salesman',
        notes: 'Full return',
      );

      final updatedProduct = await isar.productEntitys.get(product.isarId);
      expect(updatedProduct?.stock, equals(100.0));

      final updatedSalesman = await isar.userEntitys.get(salesman.isarId);
      final allocatedStock = jsonDecode(updatedSalesman!.allocatedStockJson!);
      expect(allocatedStock['prod_001']['quantity'], equals(0));

      final ledgerEntries = await isar.stockLedgerEntitys
          .filter()
          .productIdEqualTo('prod_001')
          .and()
          .transactionTypeEqualTo('RETURN_FROM_SALESMAN')
          .findAll();
      expect(ledgerEntries.length, greaterThan(0));
      expect(ledgerEntries.first.quantityChange, equals(20.0));
    });
  });

  group('TEST-3: Salesman Partial Return Test', () {
    test('Return 8 units out of 20 dispatched', () async {
      final now = DateTime.now();
      final product = ProductEntity()
        ..id = 'prod_001'
        ..name = 'Test Product'
        ..sku = 'TEST-001'
        ..stock = 80.0
        ..baseUnit = 'Pcs'
        ..itemType = 'product'
        ..type = 'finished_good'
        ..updatedAt = now;

      await isar.writeTxn(() async {
        await isar.productEntitys.put(product);
      });

      final salesman = UserEntity()
        ..id = 'salesman_001'
        ..name = 'Test Salesman'
        ..email = 'salesman@test.com'
        ..role = 'Salesman'
        ..allocatedStockJson = jsonEncode({
          'prod_001': {
            'productId': 'prod_001',
            'name': 'Test Product',
            'quantity': 20,
            'freeQuantity': 0,
            'price': 100.0,
            'baseUnit': 'Pcs',
            'conversionFactor': 1.0,
          }
        })
        ..updatedAt = now;

      await isar.writeTxn(() async {
        await isar.userEntitys.put(salesman);
      });

      await inventoryService.returnFromSalesman(
        salesmanId: 'salesman_001',
        items: [
          {
            'productId': 'prod_001',
            'quantity': 8,
            'isFree': false,
            'unit': 'Pcs',
          }
        ],
        returnedByUserId: 'salesman_001',
        returnedByUserName: 'Test Salesman',
        notes: 'Partial return',
      );

      final updatedProduct = await isar.productEntitys.get(product.isarId);
      expect(updatedProduct?.stock, equals(88.0));

      final updatedSalesman = await isar.userEntitys.get(salesman.isarId);
      final allocatedStock = jsonDecode(updatedSalesman!.allocatedStockJson!);
      expect(allocatedStock['prod_001']['quantity'], equals(12));

      final ledgerEntries = await isar.stockLedgerEntitys
          .filter()
          .productIdEqualTo('prod_001')
          .and()
          .transactionTypeEqualTo('RETURN_FROM_SALESMAN')
          .findAll();
      expect(ledgerEntries.length, greaterThan(0));
      expect(ledgerEntries.first.quantityChange, equals(8.0));
    });
  });
}
