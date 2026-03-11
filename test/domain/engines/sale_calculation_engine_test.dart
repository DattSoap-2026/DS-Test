import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/domain/engines/sale_calculation_engine.dart';
import 'package:flutter_app/models/types/sales_types.dart';

void main() {
  group('SaleCalculationEngine', () {
    late SaleCalculationEngine engine;

    setUp(() {
      engine = SaleCalculationEngine();
    });

    test('calculates pure sale with no discounts or taxes', () {
      final items = [
        SaleItemForUI(
          productId: 'p1',
          name: 'Soap A',
          quantity: 10,
          price: 15.0,
          isFree: false,
          baseUnit: 'pcs',
          stock: 100,
        ),
      ];

      final result = engine.calculateSale(
        items: items,
        discountPercentage: 0,
        additionalDiscountPercentage: 0,
        gstPercentage: 0,
        gstType: 'None',
      );

      expect(result.subtotal, 150.0);
      expect(result.totalAmount, 150.0);
      expect(result.taxableAmount, 150.0);
      expect(result.totalGstAmount, 0.0);
      expect(result.discountAmount, 0.0);
    });

    test('allocates proportional values correctly', () {
      final items = [
        SaleItemForUI(
          productId: 'p1',
          name: 'Soap A',
          quantity: 10,
          price: 10.0, // Subtotal 100
          isFree: false,
          baseUnit: 'pcs',
          stock: 100,
        ),
        SaleItemForUI(
          productId: 'p2',
          name: 'Soap B',
          quantity: 5,
          price: 20.0, // Subtotal 100
          isFree: false,
          baseUnit: 'pcs',
          stock: 100,
        ),
      ];

      // Total subtotal = 200
      // 10% discount -> Total discount = 20
      final result = engine.calculateSale(
        items: items,
        discountPercentage: 10,
        additionalDiscountPercentage: 0,
        gstPercentage: 0,
        gstType: 'None',
      );

      expect(result.subtotal, 200.0);
      expect(result.discountAmount, 20.0);
      expect(result.totalAmount, 180.0);
    });

    test('calculates CGST+SGST correctly', () {
      final items = [
        SaleItemForUI(
          productId: 'p1',
          name: 'Soap A',
          quantity: 10,
          price: 100.0, // Subtotal 1000
          isFree: false,
          baseUnit: 'pcs',
          stock: 100,
        ),
      ];

      final result = engine.calculateSale(
        items: items,
        discountPercentage: 0,
        additionalDiscountPercentage: 0,
        gstPercentage: 18,
        gstType: 'CGST+SGST',
      );

      // Taxable = 1000
      // GST = 1000 * 0.18 = 180
      // CGST = 90, SGST = 90
      // Total = 1000 + 180 = 1180
      expect(result.subtotal, 1000.0);
      expect(result.taxableAmount, 1000.0);
      expect(result.totalGstAmount, 180.0);
      expect(result.cgstAmount, 90.0);
      expect(result.sgstAmount, 90.0);
      expect(result.igstAmount, 0.0);
      expect(result.totalAmount, 1180.0);
    });

    test('calculates IGST with discount correctly', () {
      final items = [
        SaleItemForUI(
          productId: 'p1',
          name: 'Soap A',
          quantity: 10,
          price: 100.0, // Subtotal 1000
          isFree: false,
          baseUnit: 'pcs',
          stock: 100,
        ),
      ];

      final result = engine.calculateSale(
        items: items,
        discountPercentage: 10, // 100 discount
        additionalDiscountPercentage: 0,
        gstPercentage: 18,
        gstType: 'IGST',
      );

      // Subtotal = 1000
      // Discount = 100
      // Taxable = 900
      // GST = 900 * 0.18 = 162
      // Total = 900 + 162 = 1062
      expect(result.taxableAmount, 900.0);
      expect(result.igstAmount, 162.0);
      expect(result.cgstAmount, 0.0);
      expect(result.sgstAmount, 0.0);
      expect(result.totalAmount, 1062.0);
    });

    test('calculates free items as 0 value', () {
      final items = [
        SaleItemForUI(
          productId: 'p1',
          name: 'Soap A',
          quantity: 10,
          price: 100.0,
          isFree: true,
          baseUnit: 'pcs',
          stock: 100,
        ),
      ];

      final result = engine.calculateSale(
        items: items,
        discountPercentage: 0,
        additionalDiscountPercentage: 0,
        gstPercentage: 0,
        gstType: 'None',
      );

      expect(result.subtotal, 0.0);
      expect(result.totalAmount, 0.0);
      expect(result.lines.first.total, 0.0);
    });
  });
}
