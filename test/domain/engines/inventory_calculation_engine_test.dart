import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/domain/engines/inventory_calculation_engine.dart';
import 'package:flutter_app/models/types/sales_types.dart';

void main() {
  group('InventoryCalculationEngine', () {
    late InventoryCalculationEngine engine;

    setUp(() {
      engine = InventoryCalculationEngine();
    });

    group('calculateStockUsage', () {
      test('returns empty list when allocatedStock is empty', () {
        final result = engine.calculateStockUsage(
          allocatedStock: {},
          sales: [],
          today: DateTime(2026, 3, 1),
        );

        expect(result, isEmpty);
      });

      test('correctly handles no sales against allocated stock', () {
        final allocated = {
          'p1': AllocatedStockInput(
            productId: 'p1',
            name: 'Nima Soap 100g',
            quantity: 50,
            freeQuantity: 10,
            baseUnit: 'pcs',
            price: 25.0,
          ),
        };

        final result = engine.calculateStockUsage(
          allocatedStock: allocated,
          sales: [],
          today: DateTime(2026, 3, 1),
        );

        expect(result.length, 1);
        final usage = result.first;
        expect(usage.productId, 'p1');
        expect(usage.remainingPaid, 50.0);
        expect(usage.remainingFree, 10.0);
        expect(usage.remainingTotal, 60.0);
        expect(usage.totalSold, 0.0);
        expect(usage.percentageSold, 0.0);
        expect(usage.allocatedPaid, 50.0);
        expect(usage.allocatedFree, 10.0);
      });

      test('calculates mixed paid/free sales correctly', () {
        final allocated = {
          'p1': AllocatedStockInput(
            productId: 'p1',
            name: 'Nima Soap 100g',
            quantity: 40, // remaining after sales
            freeQuantity: 5, // remaining after free
            baseUnit: 'pcs',
            price: 25.0,
          ),
        };

        final sales = [
          Sale(
            id: 's1',
            recipientType: 'customer',
            recipientId: 'c1',
            recipientName: 'Customer A',
            items: [
              SaleItem(
                productId: 'p1',
                name: 'Nima Soap 100g',
                quantity: 10,
                price: 25.0,
                isFree: false,
                baseUnit: 'pcs',
              ),
              SaleItem(
                productId: 'p1',
                name: 'Nima Soap 100g',
                quantity: 5,
                price: 25.0,
                isFree: true,
                baseUnit: 'pcs',
              ),
            ],
            itemProductIds: ['p1'],
            subtotal: 250.0,
            discountPercentage: 0,
            discountAmount: 0,
            taxableAmount: 250.0,
            gstType: 'None',
            gstPercentage: 0,
            totalAmount: 250.0,
            salesmanId: 'sm1',
            salesmanName: 'Salesman A',
            createdAt: '2026-03-01T10:00:00.000',
            month: 3,
            year: 2026,
          ),
        ];

        final result = engine.calculateStockUsage(
          allocatedStock: allocated,
          sales: sales,
          today: DateTime(2026, 3, 1),
        );

        expect(result.length, 1);
        final usage = result.first;
        expect(usage.paidSold, 10.0);
        expect(usage.freeSold, 5.0);
        expect(usage.totalSold, 15.0);
        // allocatedPaid = remaining(40) + paidSold(10) = 50
        expect(usage.allocatedPaid, 50.0);
        // allocatedFree = remaining(5) + freeSold(5) = 10
        expect(usage.allocatedFree, 10.0);
        expect(usage.totalAllocated, 60.0);
        // percentageSold = 15/60 * 100 = 25%
        expect(usage.percentageSold, 25.0);
        expect(usage.todaySold, 15.0); // sale is from today
      });

      test('filters out non-customer sales (e.g., dealer)', () {
        final allocated = {
          'p1': AllocatedStockInput(
            productId: 'p1',
            name: 'Soap',
            quantity: 100,
            baseUnit: 'pcs',
            price: 10.0,
          ),
        };

        final sales = [
          Sale(
            id: 's1',
            recipientType: 'dealer', // Not a customer — should be excluded
            recipientId: 'd1',
            recipientName: 'Dealer A',
            items: [
              SaleItem(
                productId: 'p1',
                name: 'Soap',
                quantity: 50,
                price: 10.0,
                baseUnit: 'pcs',
              ),
            ],
            itemProductIds: ['p1'],
            subtotal: 500.0,
            discountPercentage: 0,
            discountAmount: 0,
            taxableAmount: 500.0,
            gstType: 'None',
            gstPercentage: 0,
            totalAmount: 500.0,
            salesmanId: 'sm1',
            salesmanName: 'Salesman A',
            createdAt: '2026-03-01T10:00:00.000',
            month: 3,
            year: 2026,
          ),
        ];

        final result = engine.calculateStockUsage(
          allocatedStock: allocated,
          sales: sales,
          today: DateTime(2026, 3, 1),
        );

        final usage = result.first;
        expect(usage.totalSold, 0.0); // Dealer sale excluded
        expect(usage.remainingTotal, 100.0);
      });

      test('tracks lastSaleDate as the most recent sale date', () {
        final allocated = {
          'p1': AllocatedStockInput(
            productId: 'p1',
            name: 'Soap',
            quantity: 80,
            baseUnit: 'pcs',
            price: 10.0,
          ),
        };

        final sales = [
          Sale(
            id: 's1',
            recipientType: 'customer',
            recipientId: 'c1',
            recipientName: 'Cust',
            items: [
              SaleItem(
                productId: 'p1',
                name: 'Soap',
                quantity: 10,
                price: 10.0,
                baseUnit: 'pcs',
              ),
            ],
            itemProductIds: ['p1'],
            subtotal: 100.0,
            discountPercentage: 0,
            discountAmount: 0,
            taxableAmount: 100.0,
            gstType: 'None',
            gstPercentage: 0,
            totalAmount: 100.0,
            salesmanId: 'sm1',
            salesmanName: 'SM',
            createdAt: '2026-02-28T10:00:00.000',
            month: 2,
            year: 2026,
          ),
          Sale(
            id: 's2',
            recipientType: 'customer',
            recipientId: 'c2',
            recipientName: 'Cust2',
            items: [
              SaleItem(
                productId: 'p1',
                name: 'Soap',
                quantity: 10,
                price: 10.0,
                baseUnit: 'pcs',
              ),
            ],
            itemProductIds: ['p1'],
            subtotal: 100.0,
            discountPercentage: 0,
            discountAmount: 0,
            taxableAmount: 100.0,
            gstType: 'None',
            gstPercentage: 0,
            totalAmount: 100.0,
            salesmanId: 'sm1',
            salesmanName: 'SM',
            createdAt: '2026-03-01T14:00:00.000',
            month: 3,
            year: 2026,
          ),
        ];

        final result = engine.calculateStockUsage(
          allocatedStock: allocated,
          sales: sales,
          today: DateTime(2026, 3, 1),
        );

        expect(result.first.lastSaleDate, '2026-03-01T14:00:00.000');
      });
    });

    group('calculateReconciliationDiffs', () {
      test('detects positive and negative adjustments', () {
        final physicalCounts = [
          {'productId': 'p1', 'physicalCount': 105.0}, // System 100 → +5
          {'productId': 'p2', 'physicalCount': 45.0}, // System 50 → -5
        ];

        final currentStock = {
          'p1': ProductStockSnapshot(
            productId: 'p1',
            productName: 'Soap A',
            currentStock: 100.0,
          ),
          'p2': ProductStockSnapshot(
            productId: 'p2',
            productName: 'Soap B',
            currentStock: 50.0,
          ),
        };

        final diffs = engine.calculateReconciliationDiffs(
          physicalCounts: physicalCounts,
          currentStockMap: currentStock,
        );

        expect(diffs.length, 2);

        final adjIn = diffs.firstWhere((d) => d.productId == 'p1');
        expect(adjIn.difference, 5.0);
        expect(adjIn.movementType, 'ADJUSTMENT_IN');
        expect(adjIn.systemStock, 100.0);
        expect(adjIn.physicalCount, 105.0);

        final adjOut = diffs.firstWhere((d) => d.productId == 'p2');
        expect(adjOut.difference, -5.0);
        expect(adjOut.movementType, 'ADJUSTMENT_OUT');
      });

      test('ignores differences within floating-point tolerance', () {
        final physicalCounts = [
          {
            'productId': 'p1',
            'physicalCount': 100.0005,
          }, // diff = 0.0005 < tolerance
        ];

        final currentStock = {
          'p1': ProductStockSnapshot(
            productId: 'p1',
            productName: 'Soap A',
            currentStock: 100.0,
          ),
        };

        final diffs = engine.calculateReconciliationDiffs(
          physicalCounts: physicalCounts,
          currentStockMap: currentStock,
        );

        expect(diffs, isEmpty);
      });

      test('skips products not found in currentStockMap', () {
        final physicalCounts = [
          {'productId': 'unknown', 'physicalCount': 50.0},
        ];

        final currentStock = <String, ProductStockSnapshot>{};

        final diffs = engine.calculateReconciliationDiffs(
          physicalCounts: physicalCounts,
          currentStockMap: currentStock,
        );

        expect(diffs, isEmpty);
      });

      test('detects exact match as zero diff (no adjustment)', () {
        final physicalCounts = [
          {'productId': 'p1', 'physicalCount': 100.0},
        ];

        final currentStock = {
          'p1': ProductStockSnapshot(
            productId: 'p1',
            productName: 'Soap A',
            currentStock: 100.0,
          ),
        };

        final diffs = engine.calculateReconciliationDiffs(
          physicalCounts: physicalCounts,
          currentStockMap: currentStock,
        );

        expect(diffs, isEmpty);
      });
    });
  });
}
