import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/modules/accounting/compensation_strategy.dart';

void main() {
  group('CompensationStrategy', () {
    test('builds sales rollback plan with customer balance reversal', () {
      final plan = CompensationStrategy.salesRollbackPlan(
        saleData: {
          'id': 'S-1',
          'recipientType': 'customer',
          'recipientId': 'C-1',
          'totalAmount': 500.0,
        },
        itemLines: [
          {'productId': 'P1', 'quantity': 5},
        ],
      );

      expect(plan.module, 'sales');
      expect(plan.transactionRefId, 'S-1');
      expect(
        plan.operations.any((op) => op['type'] == 'reverse_customer_balance'),
        isTrue,
      );
      expect(
        plan.operations.any((op) => op['type'] == 'delete_local_sale'),
        isTrue,
      );
    });

    test('builds purchase receive rollback plan with stock reversal', () {
      final plan = CompensationStrategy.purchaseReceiveRollbackPlan(
        purchaseOrderId: 'PO-1',
        appliedBulkItems: [
          {'productId': 'P1', 'quantity': 10.0},
        ],
      );

      expect(plan.module, 'purchase_orders');
      expect(plan.transactionRefId, 'PO-1');
      expect(
        plan.operations.any((op) => op['type'] == 'reverse_grn_stock'),
        isTrue,
      );
      expect(
        plan.operations.any(
          (op) => op['type'] == 'restore_purchase_order_snapshot',
        ),
        isTrue,
      );
    });
  });
}
