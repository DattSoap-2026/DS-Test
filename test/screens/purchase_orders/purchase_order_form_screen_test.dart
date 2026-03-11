import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/types/purchase_order_types.dart';
import 'package:flutter_app/screens/purchase_orders/purchase_order_form_screen.dart';

void main() {
  test('hasDuplicateProductLine detects existing product in order lines', () {
    final items = <PurchaseOrderItem>[
      PurchaseOrderItem(
        productId: 'prod-1',
        name: 'Item 1',
        quantity: 1,
        unit: 'pcs',
        unitPrice: 10,
        taxableAmount: 10,
        gstPercentage: 0,
        gstAmount: 0,
        total: 10,
      ),
    ];

    expect(hasDuplicateProductLine(items, 'prod-1'), isTrue);
    expect(hasDuplicateProductLine(items, 'prod-2'), isFalse);
  });
}
