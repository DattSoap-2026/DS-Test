import 'dart:ffi';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/models/types/purchase_order_types.dart';
import 'package:flutter_app/models/types/sales_types.dart';
import 'package:flutter_app/modules/accounting/financial_year_service.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/inventory_service.dart';
import 'package:flutter_app/services/purchase_order_service.dart';
import 'package:flutter_app/services/sales_service.dart';
import 'package:flutter_app/services/settings_service.dart';

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
  late SettingsService settingsService;
  late FinancialYearService financialYearService;

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

  setUpAll(() async {
    if (_shouldSkipDbTests) return;
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});

    tempDir = await Directory.systemTemp.createTemp(
      'sprint2_offline_stability_financial_',
    );
    dbService = DatabaseService();
    await dbService.init(directory: tempDir.path);

    final firebase = FirebaseServices();
    inventoryService = InventoryService(firebase, dbService);
    purchaseOrderService = PurchaseOrderService(firebase, inventoryService);
    salesService = SalesService(firebase, dbService, inventoryService);
    settingsService = SettingsService(firebase);
    financialYearService = FinancialYearService(firebase);
  });

  setUp(() async {
    if (_shouldSkipDbTests) return;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await dbService.db.writeTxn(() async {
      await dbService.products.clear();
      await dbService.sales.clear();
      await dbService.stockLedger.clear();
      await dbService.syncQueue.clear();
      await dbService.settingsCache.clear();
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
    'PO receive strict-mode failure triggers rollback and restores local stock/PO snapshot',
    () async {
      await seedProduct(
        id: 'prod-po-rb-1',
        name: 'PO Rollback Item',
        stock: 100,
      );

      final poId = await purchaseOrderService.createPurchaseOrder(
        supplierId: 'sup-rb-1',
        supplierName: 'Supplier Rollback',
        items: [
          PurchaseOrderItem(
            productId: 'prod-po-rb-1',
            name: 'PO Rollback Item',
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

      Object? receiveError;
      try {
        await purchaseOrderService.receiveStock(
          poId: poId,
          userId: 'tester',
          userName: 'Tester',
          receivedQtys: const [
            {'prod-po-rb-1': 5},
          ],
        );
      } catch (e) {
        receiveError = e;
      }

      expect(receiveError, isNotNull);

      final product = await dbService.products.getById('prod-po-rb-1');
      expect(product, isNotNull);
      expect(product!.stock, 100);

      final poMap = await purchaseOrderService.findInLocal(poId);
      expect(poMap, isNotNull);
      final poAfter = PurchaseOrder.fromJson(poMap!);
      expect(poAfter.status, PurchaseOrderStatus.ordered);
      expect(poAfter.items.first.receivedQuantity ?? 0, 0);

      // ignore: avoid_print
      print(
        'PO_ROLLBACK_PROOF: stock=${product.stock}, status=${poAfter.status.value}, receivedQty=${poAfter.items.first.receivedQuantity ?? 0}, error=$receiveError',
      );
    },
    skip: _dbSkipReason ?? false,
  );

  test(
    'sale cancel rollback restores direct-sale warehouse stock and marks sale cancelled',
    () async {
      await seedProduct(
        id: 'prod-sale-cancel-1',
        name: 'Sale Cancel Item',
        stock: 100,
      );

      final saleId = await salesService.createSale(
        recipientType: 'dealer',
        recipientId: 'dealer-1',
        recipientName: 'Dealer One',
        items: [
          SaleItemForUI(
            productId: 'prod-sale-cancel-1',
            name: 'Sale Cancel Item',
            quantity: 10,
            price: 25,
            baseUnit: 'pcs',
            stock: 100,
          ),
        ],
        discountPercentage: 0,
      );

      final afterSale = await dbService.products.getById('prod-sale-cancel-1');
      expect(afterSale, isNotNull);
      expect(afterSale!.stock, 90);

      await salesService.cancelSale(
        saleId: saleId,
        reason: 'Customer cancelled order',
        userId: 'tester',
      );

      final afterCancel = await dbService.products.getById(
        'prod-sale-cancel-1',
      );
      expect(afterCancel, isNotNull);
      expect(afterCancel!.stock, 100);

      final saleEntity = await dbService.sales.get(fastHash(saleId));
      expect(saleEntity, isNotNull);
      expect(saleEntity!.status, 'cancelled');
      expect(saleEntity.paymentStatus, 'cancelled');
      expect(saleEntity.paidAmount, 0);

      // ignore: avoid_print
      print(
        'SALE_CANCEL_ROLLBACK_PROOF: saleId=$saleId, stockBeforeCancel=90.0, stockAfterCancel=${afterCancel.stock}, status=${saleEntity.status}',
      );
    },
    skip: _dbSkipReason ?? false,
  );
}
