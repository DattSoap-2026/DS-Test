import '../../models/types/sales_types.dart';

/// Pure Dart result type for stock usage calculation.
/// Mirrors [StockUsageData] from InventoryService but lives
/// in the domain layer with zero Flutter/DB dependencies.
class StockUsageResult {
  final String productId;
  final String productName;
  final double allocatedPaid;
  final double allocatedFree;
  final double totalAllocated;
  final double paidSold;
  final double freeSold;
  final double totalSold;
  final double remainingPaid;
  final double remainingFree;
  final double remainingTotal;
  final double percentageSold;
  final String? lastSaleDate;
  final String baseUnit;
  final String? secondaryUnit;
  final double conversionFactor;
  final double price;
  final double? secondaryPrice;
  final double todayAllocated;
  final double todaySold;
  final double availableToday;

  StockUsageResult({
    required this.productId,
    required this.productName,
    required this.allocatedPaid,
    required this.allocatedFree,
    required this.totalAllocated,
    required this.paidSold,
    required this.freeSold,
    required this.totalSold,
    required this.remainingPaid,
    required this.remainingFree,
    required this.remainingTotal,
    required this.percentageSold,
    this.lastSaleDate,
    required this.baseUnit,
    this.secondaryUnit,
    required this.conversionFactor,
    required this.price,
    this.secondaryPrice,
    required this.todayAllocated,
    required this.todaySold,
    required this.availableToday,
  });
}

/// Pure Dart result type for a single reconciliation stock adjustment.
class StockAdjustmentRecord {
  final String productId;
  final String productName;
  final double systemStock;
  final double physicalCount;
  final double difference;
  final String movementType; // 'ADJUSTMENT_IN' or 'ADJUSTMENT_OUT'

  StockAdjustmentRecord({
    required this.productId,
    required this.productName,
    required this.systemStock,
    required this.physicalCount,
    required this.difference,
    required this.movementType,
  });
}

/// Input data for allocated stock — engine-friendly mirror of AllocatedStockItem.
class AllocatedStockInput {
  final String productId;
  final String name;
  final double quantity;
  final double freeQuantity;
  final String baseUnit;
  final String? secondaryUnit;
  final double conversionFactor;
  final double price;
  final double? secondaryPrice;

  AllocatedStockInput({
    required this.productId,
    required this.name,
    required this.quantity,
    this.freeQuantity = 0,
    required this.baseUnit,
    this.secondaryUnit,
    this.conversionFactor = 1.0,
    required this.price,
    this.secondaryPrice,
  });
}

/// Input data for a single product's stock during reconciliation.
class ProductStockSnapshot {
  final String productId;
  final String productName;
  final double currentStock;

  ProductStockSnapshot({
    required this.productId,
    required this.productName,
    required this.currentStock,
  });
}

/// [InventoryCalculationEngine] contains pure business logic
/// for inventory calculations. It has:
/// - Zero Flutter dependencies
/// - Zero database dependencies
/// - Zero service dependencies
///
/// All required data is passed as parameters, making it
/// fully deterministic and unit-testable.
class InventoryCalculationEngine {
  /// Floating-point tolerance for reconciliation comparisons.
  static const double _tolerance = 0.001;

  /// Calculates real-time stock usage for a salesman by comparing
  /// allocated stock against sales data.
  ///
  /// Pure function: takes pre-fetched data, returns computed results.
  List<StockUsageResult> calculateStockUsage({
    required Map<String, AllocatedStockInput> allocatedStock,
    required List<Sale> sales,
    required DateTime today,
  }) {
    if (allocatedStock.isEmpty) return [];

    final todayStart = DateTime(today.year, today.month, today.day);
    final todayStr = todayStart.toIso8601String();

    // Aggregate sold quantities per product
    final soldQuantities = <String, Map<String, dynamic>>{};

    for (final sale in sales) {
      // Only process customer sales
      if (sale.recipientType != 'customer') continue;

      final isTodaySale = sale.createdAt.compareTo(todayStr) >= 0;

      for (final item in sale.items) {
        if (!soldQuantities.containsKey(item.productId)) {
          soldQuantities[item.productId] = {
            'paid': 0.0,
            'free': 0.0,
            'todaySold': 0.0,
            'lastSaleDate': null,
          };
        }

        if (item.isFree) {
          soldQuantities[item.productId]!['free'] += item.quantity;
        } else {
          soldQuantities[item.productId]!['paid'] += item.quantity;
        }

        if (isTodaySale) {
          soldQuantities[item.productId]!['todaySold'] += item.quantity;
        }

        final currentLastDate = soldQuantities[item.productId]!['lastSaleDate'];
        if (currentLastDate == null ||
            sale.createdAt.compareTo(currentLastDate) > 0) {
          soldQuantities[item.productId]!['lastSaleDate'] = sale.createdAt;
        }
      }
    }

    // Build stock usage results
    return allocatedStock.entries.map((entry) {
      final productId = entry.key;
      final stock = entry.value;
      final sold =
          soldQuantities[productId] ??
          {'paid': 0.0, 'free': 0.0, 'todaySold': 0.0};

      final remainingPaid = stock.quantity;
      final remainingFree = stock.freeQuantity;
      final remainingTotal = remainingPaid + remainingFree;

      final paidSold = (sold['paid'] as double? ?? 0.0);
      final freeSold = (sold['free'] as double? ?? 0.0);
      final totalSold = paidSold + freeSold;

      // Reconstruct "Start" allocation for display
      final allocatedPaid = remainingPaid + paidSold;
      final allocatedFree = remainingFree + freeSold;
      final totalAllocated = allocatedPaid + allocatedFree;
      final percentageSold = totalAllocated > 0
          ? (totalSold / totalAllocated) * 100
          : 0.0;

      final todaySold = (sold['todaySold'] as double? ?? 0.0);
      final availableToday = remainingTotal.clamp(0.0, double.infinity);

      return StockUsageResult(
        productId: productId,
        productName: stock.name,
        allocatedPaid: allocatedPaid,
        allocatedFree: allocatedFree,
        totalAllocated: totalAllocated,
        paidSold: paidSold,
        freeSold: freeSold,
        totalSold: totalSold,
        remainingPaid: remainingPaid,
        remainingFree: remainingFree,
        remainingTotal: remainingTotal,
        percentageSold: percentageSold,
        lastSaleDate: sold['lastSaleDate'] as String?,
        baseUnit: stock.baseUnit,
        secondaryUnit: stock.secondaryUnit,
        conversionFactor: stock.conversionFactor,
        price: stock.price,
        secondaryPrice: stock.secondaryPrice,
        todayAllocated: totalAllocated,
        todaySold: todaySold,
        availableToday: availableToday,
      );
    }).toList();
  }

  /// Calculates reconciliation differences between physical counts
  /// and system stock. Returns only items with material differences
  /// (beyond floating-point tolerance).
  ///
  /// Pure function: takes pre-fetched data, returns adjustment records.
  List<StockAdjustmentRecord> calculateReconciliationDiffs({
    required List<Map<String, dynamic>> physicalCounts,
    required Map<String, ProductStockSnapshot> currentStockMap,
  }) {
    final adjustments = <StockAdjustmentRecord>[];

    for (final item in physicalCounts) {
      final productId = item['productId'] as String;
      final physicalCount = (item['physicalCount'] as num).toDouble();

      final snapshot = currentStockMap[productId];
      if (snapshot == null) continue;

      final currentStock = snapshot.currentStock;
      final diff = physicalCount - currentStock;

      if (diff.abs() > _tolerance) {
        adjustments.add(
          StockAdjustmentRecord(
            productId: productId,
            productName: snapshot.productName,
            systemStock: currentStock,
            physicalCount: physicalCount,
            difference: diff,
            movementType: diff > 0 ? 'ADJUSTMENT_IN' : 'ADJUSTMENT_OUT',
          ),
        );
      }
    }

    return adjustments;
  }
}
