import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/core/firebase/firebase_config.dart';
import 'package:flutter_app/models/types/purchase_order_types.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/inventory_service.dart';
import 'package:flutter_app/services/purchase_order_service.dart';

class _FakeInventoryService extends InventoryService {
  _FakeInventoryService(FirebaseServices firebase)
    : super(firebase, DatabaseService.instance);

  final Map<String, double> stockByProduct = <String, double>{};

  @override
  Future<void> processBulkGRN({
    required List<Map<String, dynamic>> items,
    required String referenceId,
    required String referenceNumber,
    required String userId,
    required String userName,
  }) async {
    for (final item in items) {
      final productId = (item['productId'] ?? '').toString();
      final qty = (item['quantity'] as num?)?.toDouble() ?? 0;
      if (productId.isEmpty || qty <= 0) continue;
      stockByProduct[productId] = (stockByProduct[productId] ?? 0) + qty;
    }
  }
}

class _CrashOnFinalizePurchaseOrderService extends PurchaseOrderService {
  _CrashOnFinalizePurchaseOrderService(
    super.firebase,
    super.inventoryService, {
    required this.crashOnFinalize,
  });

  final bool crashOnFinalize;
  bool _didCrash = false;

  @override
  Future<void> syncToFirebase(
    String action,
    Map<String, dynamic> data, {
    String? collectionName,
    bool syncImmediately = true,
  }) async {}

  @override
  Future<void> updatePurchaseOrder(
    String poId,
    Map<String, dynamic> updates,
  ) async {
    final isFinalizeCall =
        updates.containsKey('status') && updates.containsKey('items');
    if (crashOnFinalize && isFinalizeCall && !_didCrash) {
      _didCrash = true;
      throw Exception('Simulated crash after inventory posting');
    }
    await super.updatePurchaseOrder(poId, updates);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'receiveStock replay does not double-post stock after finalize crash window',
    () async {
      final firebase = FirebaseServices();
      final inventory = _FakeInventoryService(firebase);
      final crashingService = _CrashOnFinalizePurchaseOrderService(
        firebase,
        inventory,
        crashOnFinalize: true,
      );

      final poId = await crashingService.createPurchaseOrder(
        supplierId: 'sup-idem',
        supplierName: 'Supplier',
        items: <PurchaseOrderItem>[
          PurchaseOrderItem(
            productId: 'prod-1',
            name: 'Product 1',
            quantity: 10,
            unit: 'pcs',
            unitPrice: 0,
            taxableAmount: 0,
            gstPercentage: 0,
            gstAmount: 0,
            total: 0,
            baseUnit: 'pcs',
            conversionFactor: 1,
          ),
        ],
        createdBy: 'u1',
        createdByName: 'User 1',
        status: PurchaseOrderStatus.ordered,
        subtotal: 0,
        totalGst: 0,
        totalAmount: 0,
      );

      await expectLater(
        crashingService.receiveStock(
          poId: poId,
          userId: 'u1',
          userName: 'User 1',
          receivedQtys: const <Map<String, double>>[
            {'prod-1': 4},
          ],
        ),
        throwsException,
      );

      expect(inventory.stockByProduct['prod-1'], 4);

      final expectedEventId = 'receive_${poId}_prod-1:4.000000';
      final poAfterCrash = await crashingService.findInLocal(poId);
      final markers =
          (poAfterCrash?['appliedReceiveEventIds'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();
      expect(markers, contains('pending:$expectedEventId'));

      final recoveryService = _CrashOnFinalizePurchaseOrderService(
        firebase,
        inventory,
        crashOnFinalize: false,
      );
      await recoveryService.receiveStock(
        poId: poId,
        userId: 'u1',
        userName: 'User 1',
        receivedQtys: const <Map<String, double>>[
          {'prod-1': 4},
        ],
      );

      expect(inventory.stockByProduct['prod-1'], 4);
    },
  );
}
