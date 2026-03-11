import 'dart:ffi';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/customer_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/models/types/purchase_order_types.dart';
import 'package:flutter_app/models/types/sales_types.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/inventory_service.dart';
import 'package:flutter_app/services/outbox_codec.dart';
import 'package:flutter_app/services/production_service.dart';
import 'package:flutter_app/services/purchase_order_service.dart';
import 'package:flutter_app/services/sales_service.dart';
import 'package:flutter_app/services/vehicles_service.dart';

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
  late VehiclesService vehiclesService;
  late PurchaseOrderService purchaseOrderService;
  late SalesService salesService;
  late ProductionService productionService;

  Future<void> seedProduct({
    required String id,
    required String name,
    required double stock,
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
      ..baseUnit = 'pcs'
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

  Future<void> seedCustomer({
    required String id,
    required double balance,
  }) async {
    final now = DateTime.now();
    final customer = CustomerEntity()
      ..id = id
      ..shopName = 'Test Shop'
      ..ownerName = 'Test Owner'
      ..mobile = '9999999999'
      ..address = 'Test Address'
      ..route = 'Route 1'
      ..status = 'active'
      ..balance = balance
      ..createdAt = now.toIso8601String()
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    await dbService.db.writeTxn(() async {
      await dbService.customers.put(customer);
    });
  }

  Future<void> seedOfflineUserWithStock({
    required String productId,
    required int quantity,
  }) async {
    final now = DateTime.now();
    final user = UserEntity()
      ..id = 'offline_user'
      ..name = 'Offline Salesman'
      ..email = 'offline@example.com'
      ..role = 'salesman'
      ..status = 'active'
      ..isActive = true
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;

    user.setAllocatedStock({
      productId: AllocatedStockItem(
        name: 'Sale Product',
        quantity: quantity,
        productId: productId,
        price: 50,
        baseUnit: 'pcs',
        conversionFactor: 1,
        freeQuantity: 0,
      ),
    });

    await dbService.db.writeTxn(() async {
      await dbService.users.put(user);
    });
  }

  setUpAll(() async {
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});

    tempDir = await Directory.systemTemp.createTemp(
      'sprint1_data_integrity_hotfix_',
    );
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);

    final firebase = FirebaseServices();
    inventoryService = InventoryService(firebase, dbService);
    vehiclesService = VehiclesService(firebase);
    purchaseOrderService = PurchaseOrderService(firebase, inventoryService);
    salesService = SalesService(firebase, dbService, inventoryService);
    productionService = ProductionService(
      firebase,
      inventoryService,
      dbService,
    );
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await dbService.db.writeTxn(() async {
      await dbService.maintenanceLogs.clear();
      await dbService.sales.clear();
      await dbService.users.clear();
      await dbService.customers.clear();
      await dbService.products.clear();
      await dbService.stockLedger.clear();
      await dbService.productionTargets.clear();
      await dbService.detailedProductionLogs.clear();
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
    'maintenance log add normalizes empty ID and queues same ID to outbox',
    () async {
      await vehiclesService.addMaintenanceLog({
        'id': '',
        'vehicleId': 'veh-1',
        'vehicleNumber': 'MH12AB1234',
        'serviceDate': DateTime(2026, 2, 1).toIso8601String(),
        'vendor': 'Vendor A',
        'description': 'Oil change',
        'totalCost': 1250.0,
        'type': 'Regular',
      });

      final localLogs = await dbService.maintenanceLogs.where().findAll();
      expect(localLogs.length, 1);
      final localId = localLogs.first.id;
      expect(localId, isNotEmpty);

      final queueItems = await dbService.syncQueue
          .filter()
          .collectionEqualTo(maintenanceLogsCollection)
          .actionEqualTo('add')
          .findAll();
      expect(queueItems.length, 1);

      final decoded = OutboxCodec.decode(
        queueItems.first.dataJson,
        fallbackQueuedAt: queueItems.first.createdAt,
      );
      expect(decoded.payload['id'], localId);
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'sales rollback keeps stock and customer balance unchanged on failure',
    () async {
      await seedProduct(id: 'prod-sale-1', name: 'Sale Product', stock: 100);
      await seedCustomer(id: 'customer-1', balance: 250.0);
      await seedOfflineUserWithStock(productId: 'prod-sale-1', quantity: 100);

      await expectLater(
        salesService.createSale(
          recipientType: 'customer',
          recipientId: 'customer-1',
          recipientName: 'Customer One',
          items: [
            SaleItemForUI(
              productId: 'prod-sale-1',
              name: 'Sale Product',
              quantity: 10,
              price: 50,
              baseUnit: 'pcs',
              stock: 100,
            ),
            SaleItemForUI(
              productId: 'prod-not-allocated',
              name: 'Not Allocated Product',
              quantity: 1,
              price: 20,
              baseUnit: 'pcs',
              stock: 0,
            ),
          ],
          discountPercentage: 0,
        ),
        throwsA(isA<Exception>()),
      );

      final product = await dbService.products.getById('prod-sale-1');
      expect(product, isNotNull);
      expect(product!.stock, 100);

      final customer = await dbService.customers
          .filter()
          .idEqualTo('customer-1')
          .findFirst();
      expect(customer, isNotNull);
      expect(customer!.balance, 250.0);

      final offlineUser = await dbService.users
          .filter()
          .idEqualTo('offline_user')
          .findFirst();
      expect(offlineUser, isNotNull);
      final allocated =
          offlineUser!.getAllocatedStock()['prod-sale-1']?.quantity ?? -1;
      expect(allocated, 100);

      final sales = await dbService.sales.where().findAll();
      expect(sales, isEmpty);

      // ignore: avoid_print
      print(
        'ROLLBACK_PROOF: stock=${product.stock}, balance=${customer.balance}, allocated=$allocated, salesCount=${sales.length}',
      );
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'PO receive rejects invalid incoming quantities (non-positive, unknown, over-receipt)',
    () async {
      await seedProduct(id: 'prod-po-1', name: 'Raw Material', stock: 50);

      final po = PurchaseOrder(
        id: 'po-1',
        poNumber: 'PO-TEST-001',
        supplierId: 'sup-1',
        supplierName: 'Supplier One',
        status: PurchaseOrderStatus.ordered,
        paymentStatus: PurchaseOrderPaymentStatus.pending,
        items: [
          PurchaseOrderItem(
            productId: 'prod-po-1',
            name: 'Raw Material',
            quantity: 10,
            unit: 'pcs',
            unitPrice: 100,
            taxableAmount: 1000,
            gstPercentage: 0,
            gstAmount: 0,
            total: 1000,
            receivedQuantity: 8,
            baseUnit: 'pcs',
            conversionFactor: 1,
          ),
        ],
        subtotal: 1000,
        totalGst: 0,
        totalAmount: 1000,
        createdAt: DateTime(2026, 2, 1).toIso8601String(),
        createdBy: 'u1',
        createdByName: 'User 1',
      );
      await purchaseOrderService.addToLocal(po.toJson());

      await expectLater(
        purchaseOrderService.receiveStock(
          poId: po.id,
          userId: 'u1',
          userName: 'User 1',
          receivedQtys: [
            {'prod-po-1': 0},
          ],
        ),
        throwsA(isA<Exception>()),
      );

      await expectLater(
        purchaseOrderService.receiveStock(
          poId: po.id,
          userId: 'u1',
          userName: 'User 1',
          receivedQtys: [
            {'unknown-product': 1},
          ],
        ),
        throwsA(isA<Exception>()),
      );

      Object? overReceiptError;
      try {
        await purchaseOrderService.receiveStock(
          poId: po.id,
          userId: 'u1',
          userName: 'User 1',
          receivedQtys: [
            {'prod-po-1': 3},
          ],
        );
      } catch (e) {
        overReceiptError = e;
      }

      expect(overReceiptError, isNotNull);
      final overReceiptMessage = overReceiptError.toString();
      expect(overReceiptMessage, contains('Invalid receive quantity'));
      // ignore: avoid_print
      print('PO_OVER_RECEIPT_PROOF: $overReceiptMessage');

      final poMap = await purchaseOrderService.findInLocal(po.id);
      expect(poMap, isNotNull);
      final after = PurchaseOrder.fromJson(poMap!);
      expect(after.items.first.receivedQuantity, 8);
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'PO update queues deterministic id in sync payload',
    () async {
      final po = PurchaseOrder(
        id: 'po-sync-1',
        poNumber: 'PO-SYNC-001',
        supplierId: 'sup-sync-1',
        supplierName: 'Sync Supplier',
        status: PurchaseOrderStatus.ordered,
        paymentStatus: PurchaseOrderPaymentStatus.pending,
        items: [
          PurchaseOrderItem(
            productId: 'prod-sync-1',
            name: 'Sync Item',
            quantity: 5,
            unit: 'pcs',
            unitPrice: 10,
            taxableAmount: 50,
            gstPercentage: 0,
            gstAmount: 0,
            total: 50,
          ),
        ],
        subtotal: 50,
        totalGst: 0,
        totalAmount: 50,
        createdAt: DateTime(2026, 2, 2).toIso8601String(),
        createdBy: 'u1',
        createdByName: 'User 1',
      );
      await purchaseOrderService.addToLocal(po.toJson());

      await purchaseOrderService.updatePurchaseOrder(po.id, {
        'notes': 'updated for sync',
      });

      final queueItems = await dbService.syncQueue
          .filter()
          .collectionEqualTo(purchaseOrdersCollection)
          .actionEqualTo('update')
          .findAll();
      expect(queueItems, isNotEmpty);

      final decoded = OutboxCodec.decode(
        queueItems.first.dataJson,
        fallbackQueuedAt: queueItems.first.createdAt,
      );
      expect(decoded.payload['id'], po.id);
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'PO partial receive then full receive closes order as received',
    () async {
      await seedProduct(id: 'prod-po-flow-1', name: 'PO Flow Item', stock: 20);

      final poId = await purchaseOrderService.createPurchaseOrder(
        supplierId: 'sup-flow-1',
        supplierName: 'Supplier Flow',
        items: [
          PurchaseOrderItem(
            productId: 'prod-po-flow-1',
            name: 'PO Flow Item',
            quantity: 10,
            unit: 'pcs',
            unitPrice: 50,
            taxableAmount: 500,
            gstPercentage: 0,
            gstAmount: 0,
            total: 500,
            baseUnit: 'pcs',
            conversionFactor: 1,
          ),
        ],
        createdBy: 'u1',
        createdByName: 'User 1',
        status: PurchaseOrderStatus.ordered,
        subtotal: 500,
        totalGst: 0,
        totalAmount: 500,
      );

      await purchaseOrderService.receiveStock(
        poId: poId,
        userId: 'u1',
        userName: 'User 1',
        receivedQtys: const [
          {'prod-po-flow-1': 4},
        ],
      );

      var poMap = await purchaseOrderService.findInLocal(poId);
      expect(poMap, isNotNull);
      var poAfterPartial = PurchaseOrder.fromJson(poMap!);
      expect(poAfterPartial.status, PurchaseOrderStatus.partiallyReceived);
      expect(poAfterPartial.items.first.receivedQuantity, 4);

      await purchaseOrderService.receiveStock(
        poId: poId,
        userId: 'u1',
        userName: 'User 1',
        receivedQtys: const [
          {'prod-po-flow-1': 6},
        ],
      );

      poMap = await purchaseOrderService.findInLocal(poId);
      expect(poMap, isNotNull);
      final poAfterFull = PurchaseOrder.fromJson(poMap!);
      expect(poAfterFull.status, PurchaseOrderStatus.received);
      expect(poAfterFull.items.first.receivedQuantity, 10);
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'PO receive replay with same payload is idempotent for stock and received qty',
    () async {
      await seedProduct(
        id: 'prod-po-idem-1',
        name: 'PO Idempotent Item',
        stock: 30,
      );

      final poId = await purchaseOrderService.createPurchaseOrder(
        supplierId: 'sup-idem-1',
        supplierName: 'Supplier Idempotent',
        items: [
          PurchaseOrderItem(
            productId: 'prod-po-idem-1',
            name: 'PO Idempotent Item',
            quantity: 10,
            unit: 'pcs',
            unitPrice: 20,
            taxableAmount: 200,
            gstPercentage: 0,
            gstAmount: 0,
            total: 200,
            baseUnit: 'pcs',
            conversionFactor: 1,
          ),
        ],
        createdBy: 'u1',
        createdByName: 'User 1',
        status: PurchaseOrderStatus.ordered,
        subtotal: 200,
        totalGst: 0,
        totalAmount: 200,
      );

      await purchaseOrderService.receiveStock(
        poId: poId,
        userId: 'u1',
        userName: 'User 1',
        receivedQtys: const [
          {'prod-po-idem-1': 4},
        ],
      );

      final productAfterFirst = await dbService.products.getById(
        'prod-po-idem-1',
      );
      expect(productAfterFirst, isNotNull);
      expect(productAfterFirst!.stock, 34);

      await purchaseOrderService.receiveStock(
        poId: poId,
        userId: 'u1',
        userName: 'User 1',
        receivedQtys: const [
          {'prod-po-idem-1': 4},
        ],
      );

      final productAfterReplay = await dbService.products.getById(
        'prod-po-idem-1',
      );
      expect(productAfterReplay, isNotNull);
      expect(productAfterReplay!.stock, 34);

      final poMap = await purchaseOrderService.findInLocal(poId);
      expect(poMap, isNotNull);
      final poAfterReplay = PurchaseOrder.fromJson(poMap!);
      expect(poAfterReplay.items.first.receivedQuantity, 4);
      expect(poAfterReplay.status, PurchaseOrderStatus.partiallyReceived);
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'PO stores supplier invoice reference fields as metadata only',
    () async {
      final invoiceDate = DateTime(2026, 2, 15);
      final poId = await purchaseOrderService.createPurchaseOrder(
        supplierId: 'sup-inv-1',
        supplierName: 'Invoice Supplier',
        items: [
          PurchaseOrderItem(
            productId: 'prod-inv-1',
            name: 'Invoice Item',
            quantity: 1,
            unit: 'pcs',
            unitPrice: 100,
            taxableAmount: 100,
            gstPercentage: 0,
            gstAmount: 0,
            total: 100,
          ),
        ],
        createdBy: 'u1',
        createdByName: 'User 1',
        status: PurchaseOrderStatus.draft,
        subtotal: 100,
        totalGst: 0,
        totalAmount: 100,
        supplierInvoiceNumber: 'SUP-INV-001',
        invoiceDate: invoiceDate.toIso8601String(),
      );

      final poMap = await purchaseOrderService.findInLocal(poId);
      expect(poMap, isNotNull);
      final saved = PurchaseOrder.fromJson(poMap!);
      expect(saved.supplierInvoiceNumber, 'SUP-INV-001');
      expect(saved.invoiceDate, invoiceDate.toIso8601String());
      expect(saved.status, PurchaseOrderStatus.draft);
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'dispatch ID uses full epoch plus random suffix format',
    () async {
      await seedProduct(
        id: 'prod-dispatch-1',
        name: 'Dispatch Product',
        stock: 100,
      );

      final now = DateTime.now();
      final salesmanEntity = UserEntity()
        ..id = 'salesman-1'
        ..name = 'Salesman One'
        ..email = 'salesman1@example.com'
        ..role = 'salesman'
        ..status = 'active'
        ..isActive = true
        ..updatedAt = now;
      await dbService.db.writeTxn(() async {
        await dbService.users.put(salesmanEntity);
      });

      final salesman = AppUser(
        id: 'salesman-1',
        name: 'Salesman One',
        email: 'salesman1@example.com',
        role: UserRole.salesman,
        departments: const [],
        createdAt: now.toIso8601String(),
      );

      final dispatchId = await inventoryService.dispatchToSalesman(
        salesman: salesman,
        vehicleId: 'veh-1',
        vehicleNumber: 'MH12AA0001',
        dispatchRoute: 'Main Route',
        salesRoute: 'Sales Route',
        items: [
          SaleItem(
            productId: 'prod-dispatch-1',
            name: 'Dispatch Product',
            quantity: 10,
            price: 20,
            baseUnit: 'pcs',
          ),
        ],
        subtotal: 200,
        totalAmount: 200,
        userId: 'admin-1',
        userName: 'Admin',
      );

      expect(dispatchId, matches(RegExp(r'^DSP-\d{13}-[A-F0-9]{6}$')));
      // ignore: avoid_print
      print('DISPATCH_ID_PROOF: $dispatchId');
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'production log uses same issueId in local record and outbox payload',
    () async {
      await seedProduct(
        id: 'prod-production-1',
        name: 'Finished Product',
        stock: 0,
      );

      final result = await productionService.addDetailedProductionLog(
        AddDetailedProductionLogPayload(
          batchNumber: 'BATCH-001',
          productId: 'prod-production-1',
          productName: 'Finished Product',
          totalBatchQuantity: 12,
          unit: 'pcs',
          supervisorId: 'sup-1',
          supervisorName: 'Supervisor One',
        ),
      );

      expect(result, isTrue);

      final logs = await dbService.detailedProductionLogs.where().findAll();
      expect(logs.length, 1);
      final localIssueId = logs.first.issueId;
      expect(localIssueId, isNotNull);
      expect(localIssueId, isNotEmpty);

      final queueItems = await dbService.syncQueue
          .filter()
          .collectionEqualTo(detailedProductionLogsCollection)
          .actionEqualTo('add')
          .findAll();
      expect(queueItems.length, 1);

      final decoded = OutboxCodec.decode(
        queueItems.first.dataJson,
        fallbackQueuedAt: queueItems.first.createdAt,
      );
      expect(decoded.payload['issueId'], localIssueId);
    },
    skip: _dbSkipReason ?? false,
  );
}
