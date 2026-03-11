import 'dart:ffi';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/customer_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/models/inventory/stock_dispatch.dart';
import 'package:flutter_app/models/types/purchase_order_types.dart';
import 'package:flutter_app/models/types/sales_types.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/modules/accounting/financial_year_service.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/inventory_service.dart';
import 'package:flutter_app/services/outbox_codec.dart';
import 'package:flutter_app/services/permission_service.dart';
import 'package:flutter_app/services/production_service.dart';
import 'package:flutter_app/services/purchase_order_service.dart';
import 'package:flutter_app/services/sales_service.dart';
import 'package:flutter_app/services/settings_service.dart';
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
  late PurchaseOrderService purchaseOrderService;
  late SalesService salesService;
  late ProductionService productionService;
  late VehiclesService vehiclesService;
  late SettingsService settingsService;
  late FinancialYearService financialYearService;
  late PermissionService permissionService;

  Future<void> seedProduct({
    required String id,
    required String name,
    required double stock,
    double price = 10,
    String itemType = 'finished_good',
  }) async {
    final now = DateTime.now();
    final product = ProductEntity()
      ..id = id
      ..name = name
      ..sku = 'SKU-$id'
      ..itemType = itemType
      ..type = itemType
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
      ..shopName = 'Test Shop $id'
      ..ownerName = 'Owner $id'
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
        name: 'Allocated Product',
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

  Future<void> seedDispatchSalesman({
    required String id,
    required String name,
    required String email,
  }) async {
    final now = DateTime.now();
    final user = UserEntity()
      ..id = id
      ..name = name
      ..email = email
      ..role = 'salesman'
      ..status = 'active'
      ..isActive = true
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
    await dbService.db.writeTxn(() async {
      await dbService.users.put(user);
    });
  }

  setUpAll(() async {
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});

    tempDir = await Directory.systemTemp.createTemp(
      'sprint3_core_lifecycle_rbac_',
    );
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);

    final firebase = FirebaseServices();
    inventoryService = InventoryService(firebase, dbService);
    purchaseOrderService = PurchaseOrderService(firebase, inventoryService);
    salesService = SalesService(firebase, dbService, inventoryService);
    productionService = ProductionService(
      firebase,
      inventoryService,
      dbService,
    );
    vehiclesService = VehiclesService(firebase);
    settingsService = SettingsService(firebase);
    financialYearService = FinancialYearService(firebase);
    permissionService = PermissionService();
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await dbService.db.writeTxn(() async {
      await dbService.products.clear();
      await dbService.users.clear();
      await dbService.customers.clear();
      await dbService.sales.clear();
      await dbService.stockLedger.clear();
      await dbService.detailedProductionLogs.clear();
      await dbService.productionTargets.clear();
      await dbService.vehicles.clear();
      await dbService.maintenanceLogs.clear();
      await dbService.settingsCache.clear();
      await dbService.syncQueue.clear();
    });
    await settingsService.updateStrictAccountingMode(
      enabled: false,
      userId: 'tester',
      userName: 'Tester',
    );
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
    'purchase lifecycle create -> receive -> rollback preserves last consistent state',
    () async {
      await seedProduct(
        id: 'prod-po-life-1',
        name: 'PO Lifecycle Product',
        stock: 100,
      );

      final poId = await purchaseOrderService.createPurchaseOrder(
        supplierId: 'sup-life-1',
        supplierName: 'Lifecycle Supplier',
        items: [
          PurchaseOrderItem(
            productId: 'prod-po-life-1',
            name: 'PO Lifecycle Product',
            quantity: 10,
            unit: 'pcs',
            unitPrice: 100,
            taxableAmount: 1000,
            gstPercentage: 0,
            gstAmount: 0,
            total: 1000,
            baseUnit: 'pcs',
            conversionFactor: 1,
          ),
        ],
        createdBy: 'tester',
        createdByName: 'Tester',
        status: PurchaseOrderStatus.ordered,
        subtotal: 1000,
        totalGst: 0,
        totalAmount: 1000,
      );

      await purchaseOrderService.receiveStock(
        poId: poId,
        userId: 'tester',
        userName: 'Tester',
        receivedQtys: const [
          {'prod-po-life-1': 4},
        ],
      );

      final productAfterReceive = await dbService.products.getById(
        'prod-po-life-1',
      );
      expect(productAfterReceive, isNotNull);
      expect(productAfterReceive!.stock, 104);

      final poAfterReceiveMap = await purchaseOrderService.findInLocal(poId);
      final poAfterReceive = PurchaseOrder.fromJson(poAfterReceiveMap!);
      expect(poAfterReceive.status, PurchaseOrderStatus.partiallyReceived);
      expect(poAfterReceive.items.first.receivedQuantity, 4);

      await settingsService.updateStrictAccountingMode(
        enabled: true,
        userId: 'tester',
        userName: 'Tester',
      );
      final currentFyId = FinancialYearService.financialYearIdForDate(
        DateTime.now(),
      );
      await financialYearService.setFinancialYearLock(
        financialYearId: currentFyId,
        isLocked: true,
        lockedBy: 'tester',
      );

      Object? rollbackError;
      try {
        await purchaseOrderService.receiveStock(
          poId: poId,
          userId: 'tester',
          userName: 'Tester',
          receivedQtys: const [
            {'prod-po-life-1': 1},
          ],
        );
      } catch (e) {
        rollbackError = e;
      }

      expect(rollbackError, isNotNull);

      final productAfterRollback = await dbService.products.getById(
        'prod-po-life-1',
      );
      expect(productAfterRollback, isNotNull);
      expect(productAfterRollback!.stock, 104);

      final poAfterRollbackMap = await purchaseOrderService.findInLocal(poId);
      final poAfterRollback = PurchaseOrder.fromJson(poAfterRollbackMap!);
      expect(poAfterRollback.status, PurchaseOrderStatus.partiallyReceived);
      expect(poAfterRollback.items.first.receivedQuantity, 4);
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'dispatch lifecycle keeps stock, ledger, and outbox consistent',
    () async {
      await seedProduct(
        id: 'prod-dispatch-life-1',
        name: 'Dispatch Lifecycle Product',
        stock: 100,
      );
      await seedDispatchSalesman(
        id: 'salesman-life-1',
        name: 'Salesman One',
        email: 'salesman1@example.com',
      );

      final salesman = AppUser(
        id: 'salesman-life-1',
        name: 'Salesman One',
        email: 'salesman1@example.com',
        role: UserRole.salesman,
        departments: const [],
        createdAt: DateTime.now().toIso8601String(),
      );

      final dispatchId = await inventoryService.dispatchToSalesman(
        salesman: salesman,
        vehicleId: 'veh-life-1',
        vehicleNumber: 'MH12AA0001',
        dispatchRoute: 'Main Route',
        salesRoute: 'Sales Route',
        items: [
          SaleItem(
            productId: 'prod-dispatch-life-1',
            name: 'Dispatch Lifecycle Product',
            quantity: 15,
            price: 20,
            baseUnit: 'pcs',
          ),
        ],
        subtotal: 300,
        totalAmount: 300,
        userId: 'admin-1',
        userName: 'Admin',
      );

      expect(dispatchId, matches(RegExp(r'^DSP-\d{13}-[A-F0-9]{6}$')));

      final product = await dbService.products.getById('prod-dispatch-life-1');
      expect(product, isNotNull);
      expect(product!.stock, 85);

      final salesmanEntity = await dbService.users.getById('salesman-life-1');
      expect(salesmanEntity, isNotNull);
      final allocated = salesmanEntity!.getAllocatedStock();
      expect(allocated.containsKey('prod-dispatch-life-1'), isTrue);
      expect(allocated['prod-dispatch-life-1']!.quantity, 15);

      final ledgerEntries = await dbService.stockLedger.where().findAll();
      final dispatchLedgers = ledgerEntries
          .where((entry) => entry.referenceId == dispatchId)
          .toList();
      expect(dispatchLedgers, isNotEmpty);
      expect(
        dispatchLedgers.any(
          (entry) =>
              entry.transactionType == 'DISPATCH_OUT' &&
              entry.quantityChange == -15,
        ),
        isTrue,
      );

      final dispatchQueueItems = await dbService.syncQueue
          .filter()
          .collectionEqualTo(dispatchesCollection)
          .actionEqualTo('add')
          .findAll();
      expect(dispatchQueueItems, isNotEmpty);
      final payload = OutboxCodec.decode(
        dispatchQueueItems.first.dataJson,
        fallbackQueuedAt: dispatchQueueItems.first.createdAt,
      ).payload;
      expect(payload['dispatchId'], dispatchId);
      expect(payload['status'], DispatchStatus.received.name);
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'production batch lifecycle applies stock movements atomically',
    () async {
      await seedProduct(
        id: 'raw-semi-1',
        name: 'Semi Material',
        stock: 100,
        itemType: 'semi_finished_good',
      );
      await seedProduct(
        id: 'raw-pack-1',
        name: 'Packaging Material',
        stock: 50,
        itemType: 'raw_material',
      );
      await seedProduct(
        id: 'prod-fg-life-1',
        name: 'Finished Batch Product',
        stock: 10,
        itemType: 'finished_good',
      );

      final ok = await productionService.addDetailedProductionLog(
        AddDetailedProductionLogPayload(
          batchNumber: 'BATCH-LIFE-1',
          productId: 'prod-fg-life-1',
          productName: 'Finished Batch Product',
          totalBatchQuantity: 20,
          unit: 'pcs',
          supervisorId: 'sup-1',
          supervisorName: 'Supervisor One',
          semiFinishedGoodsUsed: const [
            {
              'productId': 'raw-semi-1',
              'productName': 'Semi Material',
              'quantity': 8,
              'unit': 'kg',
            },
          ],
          packagingMaterialsUsed: const [
            {
              'materialId': 'raw-pack-1',
              'materialName': 'Packaging Material',
              'quantity': 5,
              'unit': 'pcs',
            },
          ],
        ),
      );
      expect(ok, isTrue);

      final rawSemi = await dbService.products.getById('raw-semi-1');
      final rawPack = await dbService.products.getById('raw-pack-1');
      final finished = await dbService.products.getById('prod-fg-life-1');
      expect(rawSemi, isNotNull);
      expect(rawPack, isNotNull);
      expect(finished, isNotNull);
      expect(rawSemi!.stock, 92);
      expect(rawPack!.stock, 45);
      expect(finished!.stock, 30);

      final logs = await dbService.detailedProductionLogs.where().findAll();
      expect(logs.length, 1);
      final log = logs.first;
      expect(log.batchNumber, 'BATCH-LIFE-1');
      expect(log.issueId, isNotEmpty);

      final ledgerEntries = await dbService.stockLedger.where().findAll();
      final batchLedgers = ledgerEntries
          .where((entry) => entry.referenceId == log.id)
          .toList();
      expect(batchLedgers.length, 3);

      final queueItems = await dbService.syncQueue
          .filter()
          .collectionEqualTo(detailedProductionLogsCollection)
          .actionEqualTo('add')
          .findAll();
      expect(queueItems, isNotEmpty);
      final payload = OutboxCodec.decode(
        queueItems.first.dataJson,
        fallbackQueuedAt: queueItems.first.createdAt,
      ).payload;
      expect(payload['batchNumber'], 'BATCH-LIFE-1');
      expect((payload['issueId'] as String?)?.isNotEmpty ?? false, isTrue);
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'sale cancel rollback is symmetric for stock and customer balance',
    () async {
      await seedProduct(
        id: 'prod-sale-sym-1',
        name: 'Sale Symmetry Product',
        stock: 300,
      );
      await seedCustomer(id: 'customer-sym-1', balance: 100);
      await seedOfflineUserWithStock(
        productId: 'prod-sale-sym-1',
        quantity: 50,
      );

      final saleId = await salesService.createSale(
        recipientType: 'customer',
        recipientId: 'customer-sym-1',
        recipientName: 'Customer Symmetry',
        items: [
          SaleItemForUI(
            productId: 'prod-sale-sym-1',
            name: 'Sale Symmetry Product',
            quantity: 10,
            price: 20,
            baseUnit: 'pcs',
            stock: 50,
          ),
        ],
        discountPercentage: 0,
      );

      final userAfterSale = await dbService.users.getById('offline_user');
      expect(userAfterSale, isNotNull);
      expect(
        userAfterSale!.getAllocatedStock()['prod-sale-sym-1']!.quantity,
        40,
      );

      final customerAfterSale = await dbService.customers.getById(
        'customer-sym-1',
      );
      expect(customerAfterSale, isNotNull);
      expect(customerAfterSale!.balance, 300);

      await salesService.cancelSale(
        saleId: saleId,
        reason: 'Symmetry validation',
        userId: 'tester',
      );

      final userAfterCancel = await dbService.users.getById('offline_user');
      expect(userAfterCancel, isNotNull);
      expect(
        userAfterCancel!.getAllocatedStock()['prod-sale-sym-1']!.quantity,
        50,
      );

      final customerAfterCancel = await dbService.customers.getById(
        'customer-sym-1',
      );
      expect(customerAfterCancel, isNotNull);
      expect(customerAfterCancel!.balance, 100);

      final saleEntity = await dbService.sales.get(fastHash(saleId));
      expect(saleEntity, isNotNull);
      expect(saleEntity!.status, 'cancelled');
      expect(saleEntity.paymentStatus, 'cancelled');
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'vehicle maintenance sync consistency keeps aggregate and outbox aligned',
    () async {
      await vehiclesService.addVehicle({
        'id': 'veh-sync-1',
        'name': 'Vehicle One',
        'number': 'MH12XY1234',
        'type': 'Truck',
        'status': 'active',
        'totalDistance': 100,
      });

      await vehiclesService.addMaintenanceLog({
        'id': '',
        'vehicleId': 'veh-sync-1',
        'vehicleNumber': 'MH12XY1234',
        'serviceDate': DateTime(2026, 2, 10).toIso8601String(),
        'vendor': 'Vendor A',
        'description': 'Initial service',
        'totalCost': 1000.0,
        'type': 'Regular',
      });

      final logsAfterAdd = await dbService.maintenanceLogs.where().findAll();
      expect(logsAfterAdd.length, 1);
      final logId = logsAfterAdd.first.id;
      expect(logId, isNotEmpty);

      final vehicleAfterAdd = await dbService.vehicles.get(
        fastHash('veh-sync-1'),
      );
      expect(vehicleAfterAdd, isNotNull);
      expect(vehicleAfterAdd!.totalMaintenanceCost, 1000);
      expect(vehicleAfterAdd.costPerKm, 10);

      await vehiclesService.updateMaintenanceLog(logId, {
        'description': 'Updated service',
        'totalCost': 1500.0,
        'serviceDate': DateTime(2026, 2, 11).toIso8601String(),
      });

      final vehicleAfterUpdate = await dbService.vehicles.get(
        fastHash('veh-sync-1'),
      );
      expect(vehicleAfterUpdate, isNotNull);
      expect(vehicleAfterUpdate!.totalMaintenanceCost, 1500);
      expect(vehicleAfterUpdate.costPerKm, 15);

      await vehiclesService.deleteMaintenanceLog(logId, 'veh-sync-1', 1500.0);

      final vehicleAfterDelete = await dbService.vehicles.get(
        fastHash('veh-sync-1'),
      );
      expect(vehicleAfterDelete, isNotNull);
      expect(vehicleAfterDelete!.totalMaintenanceCost, 0);
      expect(vehicleAfterDelete.costPerKm, 0);

      final maintenanceQueueItems = await dbService.syncQueue
          .filter()
          .collectionEqualTo(maintenanceLogsCollection)
          .findAll();
      expect(maintenanceQueueItems, isNotEmpty);

      // Durable outbox deduplicates by queue id (collection + record id),
      // so add -> update -> delete should collapse to the latest intent.
      final matchingQueueItems = <SyncQueueEntity>[];
      for (final queueItem in maintenanceQueueItems) {
        final payload = OutboxCodec.decode(
          queueItem.dataJson,
          fallbackQueuedAt: queueItem.createdAt,
        ).payload;
        if (payload['id'] == logId) {
          matchingQueueItems.add(queueItem);
        }
      }

      expect(matchingQueueItems.length, 1);
      final latest = matchingQueueItems.single;
      expect(latest.action, 'delete');
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'rbac route protection follows frozen final role policy',
    () async {
      AppUser userFor(UserRole role) => AppUser(
        id: role.name,
        name: role.value,
        email: '${role.name}@test.local',
        role: role,
        departments: const [],
        createdAt: '2026-01-01T00:00:00.000Z',
      );

      final admin = userFor(UserRole.admin);
      final manager = userFor(UserRole.storeIncharge);
      final production = userFor(UserRole.productionSupervisor);
      final salesman = userFor(UserRole.salesman);
      final legacy = userFor(UserRole.driver);

      expect(
        permissionService.canAccessPathLayered(
          admin,
          '/dashboard/settings/general',
        ),
        isTrue,
      );
      expect(
        permissionService.canAccessPathLayered(admin, '/dashboard/hr'),
        isTrue,
      );
      expect(
        permissionService.canAccessPathLayered(admin, '/dashboard/accounting'),
        isTrue,
      );

      expect(
        permissionService.canAccessPathLayered(
          manager,
          '/dashboard/management/formulas',
        ),
        isTrue,
      );
      expect(
        permissionService.canAccessPathLayered(
          manager,
          '/dashboard/reports/stock-ledger',
        ),
        isTrue,
      );
      expect(
        permissionService.canAccessPathLayered(manager, '/dashboard/settings'),
        isFalse,
      );
      expect(
        permissionService.canAccessPathLayered(
          manager,
          '/dashboard/reports/financial',
        ),
        isFalse,
      );

      expect(
        permissionService.canAccessPathLayered(
          production,
          '/dashboard/inventory/stock-overview',
        ),
        isTrue,
      );
      expect(
        permissionService.canAccessPathLayered(
          production,
          '/dashboard/inventory/adjust',
        ),
        isFalse,
      );
      expect(
        permissionService.canAccessPathLayered(
          production,
          '/dashboard/reports/production',
        ),
        isTrue,
      );
      expect(
        permissionService.canAccessPathLayered(
          production,
          '/dashboard/reports/stock-movement',
        ),
        isFalse,
      );

      expect(
        permissionService.canAccessPathLayered(
          salesman,
          '/dashboard/salesman-sales/new',
        ),
        isTrue,
      );
      expect(
        permissionService.canAccessPathLayered(
          salesman,
          '/dashboard/orders/route-management',
        ),
        isTrue,
      );
      expect(
        permissionService.canAccessPathLayered(
          salesman,
          '/dashboard/management',
        ),
        isFalse,
      );
      expect(
        permissionService.canAccessPathLayered(
          salesman,
          '/dashboard/reports/production',
        ),
        isFalse,
      );

      expect(
        permissionService.canAccessPathLayered(
          legacy,
          '/dashboard/coming-soon',
        ),
        isTrue,
      );
      expect(
        permissionService.canAccessPathLayered(
          legacy,
          '/dashboard/orders/route-management',
        ),
        isFalse,
      );
      expect(
        permissionService.canAccessPathLayered(legacy, '/dashboard/dispatch'),
        isFalse,
      );
    },
    skip: _dbSkipReason ?? false,
  );
}
