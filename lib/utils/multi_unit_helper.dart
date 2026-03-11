import '../models/types/product_types.dart';

/// Helper utilities for multi-unit display and calculations
class MultiUnitHelper {
  /// Display stock in human-readable format
  ///
  /// Examples:
  /// - Single unit: "25 Pcs"
  /// - Multi-unit with boxes: "3 Box + 8 Pcs"
  /// - Multi-unit boxes only: "3 Box"
  /// - Multi-unit loose only: "8 Pcs"
  static String getStockDisplay({
    required Product product,
    required double stockInBaseUnits,
  }) {
    if (product.secondaryUnit == null || product.conversionFactor <= 0) {
      // Single unit product
      return '${stockInBaseUnits.toInt()} ${product.baseUnit}';
    }

    // Multi-unit product - convert to boxes + loose
    final boxes = (stockInBaseUnits / product.conversionFactor).floor();
    final loosePcs = (stockInBaseUnits % product.conversionFactor).toInt();

    if (boxes > 0 && loosePcs > 0) {
      return '$boxes ${product.secondaryUnit} + $loosePcs ${product.baseUnit}';
    } else if (boxes > 0) {
      return '$boxes ${product.secondaryUnit}';
    } else {
      return '$loosePcs ${product.baseUnit}';
    }
  }

  /// Get display quantity for sale item
  /// Shows: "2 Box" or "5 Pcs" (not "24 Pcs")
  static String getSaleItemDisplay({
    required double quantity,
    required String unit,
  }) {
    final qtyStr = quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(2);
    return '$qtyStr $unit';
  }

  /// Calculate base quantity from selected unit
  static double calculateBaseQuantity({
    required double quantity,
    required String selectedUnit,
    required String baseUnit,
    double? conversionFactor,
  }) {
    if (selectedUnit == baseUnit) {
      return quantity;
    } else {
      if (conversionFactor == null || conversionFactor <= 0) {
        throw Exception('Conversion factor required for unit: $selectedUnit');
      }
      return quantity * conversionFactor;
    }
  }

  /// Validate conversion consistency
  static void validateConversion({
    required double quantity,
    required String selectedUnit,
    required String baseUnit,
    required double baseQuantity,
    double? conversionFactor,
  }) {
    if (selectedUnit == baseUnit) {
      // Should be equal
      if ((quantity - baseQuantity).abs() > 0.01) {
        throw Exception(
          'Base quantity mismatch: quantity=$quantity, baseQuantity=$baseQuantity',
        );
      }
    } else {
      // Should match conversion
      if (conversionFactor == null || conversionFactor <= 0) {
        throw Exception('Missing conversion factor for $selectedUnit');
      }

      final expected = quantity * conversionFactor;
      if ((baseQuantity - expected).abs() > 0.01) {
        throw Exception(
          'Conversion mismatch: $quantity $selectedUnit should be $expected $baseUnit, got $baseQuantity',
        );
      }
    }
  }
}
