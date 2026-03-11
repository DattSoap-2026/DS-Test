import 'package:flutter_test/flutter_test.dart';

// ==========================================
// CURRENT LOGIC REPLICATION (from sales_service.dart)
// ==========================================

double round(double val) {
  return (val * 100).round() / 100;
}

class SaleItem {
  final double quantity;
  final double price;
  final double discount; // 0-100
  // Secondary unit logic omitted for simplicity unless critical

  SaleItem({required this.quantity, required this.price, this.discount = 0});
}

class CalculationResult {
  double subTotal;
  double itemDiscountTotal;
  double primaryDiscountAmount;
  double additionalDiscountAmount;
  double taxableAmount;
  double totalTax;
  double grandTotal;

  CalculationResult({
    required this.subTotal,
    required this.itemDiscountTotal,
    required this.primaryDiscountAmount,
    required this.additionalDiscountAmount,
    required this.taxableAmount,
    required this.totalTax,
    required this.grandTotal,
  });
}

CalculationResult calculateSale({
  required List<SaleItem> items,
  double discountPerformance = 0, // Primary %
  double additionalDiscountPercentage = 0, // Secondary %
  double gstPercentage = 0,
  String gstType = 'None',
}) {
  double recalculatedSubTotal = 0;
  double recalculatedItemDiscountsTotal = 0;

  for (var item in items) {
    // 1. Item Total
    double itemTotal = round(item.price * item.quantity);
    recalculatedSubTotal = round(recalculatedSubTotal + itemTotal);

    // 2. Item Discount
    double itemDiscount = round((itemTotal * item.discount) / 100);
    recalculatedItemDiscountsTotal = round(
      recalculatedItemDiscountsTotal + itemDiscount,
    );
  }

  // 3. Amount after Item Discounts
  double amountAfterItemDiscounts = round(
    recalculatedSubTotal - recalculatedItemDiscountsTotal,
  );

  // 4. Primary Discount
  double recalculatedDiscountAmount = round(
    (amountAfterItemDiscounts * discountPerformance) / 100,
  );
  double amountAfterPrimaryDiscount = round(
    amountAfterItemDiscounts - recalculatedDiscountAmount,
  );

  // 5. Additional Discount
  double recalculatedAdditionalDiscountAmount = round(
    (amountAfterPrimaryDiscount * additionalDiscountPercentage) / 100,
  );
  double taxableAmount = round(
    amountAfterPrimaryDiscount - recalculatedAdditionalDiscountAmount,
  );

  // 6. Tax
  double totalGstAmount = 0;
  if (gstType != 'None' && gstPercentage > 0) {
    totalGstAmount = round((taxableAmount * gstPercentage) / 100);
  }

  // 7. Grand Total
  double recalculatedTotalAmount = round(taxableAmount + totalGstAmount);

  return CalculationResult(
    subTotal: recalculatedSubTotal,
    itemDiscountTotal: recalculatedItemDiscountsTotal,
    primaryDiscountAmount: recalculatedDiscountAmount,
    additionalDiscountAmount: recalculatedAdditionalDiscountAmount,
    taxableAmount: taxableAmount,
    totalTax: totalGstAmount,
    grandTotal: recalculatedTotalAmount,
  );
}

// ==========================================
// TESTS
// ==========================================

void main() {
  group('Mathematical Audit - Sales Logic', () {
    test('Case 1: Standard Rounding (Penny Check)', () {
      // 3 items at 10.11
      final items = [
        SaleItem(quantity: 1, price: 10.11),
        SaleItem(quantity: 1, price: 10.11),
        SaleItem(quantity: 1, price: 10.11),
      ];
      // Total should be 30.33
      final res = calculateSale(items: items);
      expect(res.subTotal, 30.33);
    });

    test('Case 2: Discount Cascading', () {
      // 100.00 base
      // 10% Item Disc -> 90.00
      // 10% Primary -> 81.00
      // 10% Additional -> 72.90
      final items = [SaleItem(quantity: 1, price: 100, discount: 10)];

      final res = calculateSale(
        items: items,
        discountPerformance: 10,
        additionalDiscountPercentage: 10,
      );

      expect(res.subTotal, 100.0);
      expect(res.itemDiscountTotal, 10.0); // 90 Rem
      expect(res.primaryDiscountAmount, 9.0); // 10% of 90 = 9 -> 81 Rem
      expect(res.additionalDiscountAmount, 8.1); // 10% of 81 = 8.1 -> 72.9 Rem
      expect(res.taxableAmount, 72.9);
    });

    test('Case 3: GST Rounding', () {
      // 100 Taxable, 18% GST -> 118 total
      final items = [SaleItem(quantity: 1, price: 100)];
      final res = calculateSale(
        items: items,
        gstPercentage: 18,
        gstType: 'IGST',
      );
      expect(res.totalTax, 18.0);
      expect(res.grandTotal, 118.0);
    });

    test('Case 4: Complex Edge Case (Decimals)', () {
      // Qty 0.33 * Price 100 = 33.00
      final items = [SaleItem(quantity: 0.33, price: 100)];
      final res = calculateSale(items: items);
      expect(res.subTotal, 33.0);
    });

    test('Case 5: GST Split Logic (Manual Calculation Check)', () {
      // If logic is Floor for CGST (half) and Remainder for SGST
      // Taxable: 1.00, GST 5% = 0.05
      // CGST = floor(0.025 * 100)/100 = 0.02
      // SGST = 0.05 - 0.02 = 0.03
      // Total = 0.05 (Correct sum, but uneven split)

      // Replicating split logic manually to verify
      double totalTax = 0.05;
      double cgst = (totalTax / 2 * 100).floorToDouble() / 100;
      double sgst = round(totalTax - cgst);

      expect(cgst, 0.02);
      expect(sgst, 0.03);
      expect(cgst + sgst, 0.05);
    });
  });
}
