import '../../models/bom/product_formula.dart';

/// Formula Repository - Manages product formulas
/// 
/// Phase 1: In-memory storage
/// Future: Migrate to Isar/Firestore
class FormulaRepository {
  final Map<String, ProductFormula> _formulas = {};

  /// Adds or updates a formula
  void saveFormula(ProductFormula formula) {
    _formulas[formula.productId] = formula;
  }

  /// Gets formula by product ID
  ProductFormula? getFormula(String productId) {
    return _formulas[productId];
  }

  /// Gets all formulas
  List<ProductFormula> getAllFormulas() {
    return _formulas.values.toList();
  }

  /// Checks if formula exists
  bool hasFormula(String productId) {
    return _formulas.containsKey(productId);
  }

  /// Removes a formula
  void deleteFormula(String productId) {
    _formulas.remove(productId);
  }

  /// Clears all formulas
  void clear() {
    _formulas.clear();
  }

  /// Example: Bhatti soap formula with water evaporation
  static ProductFormula createBhattiSoapFormula({
    required String productId,
    required String productName,
  }) {
    return ProductFormula(
      id: 'formula_$productId',
      productId: productId,
      productName: productName,
      departmentId: 'dept_bhatti',
      inputs: [
        FormulaInput(
          materialId: 'mat_oil',
          materialName: 'Oil',
          quantityPerBatch: 50.0,
          unit: 'Kg',
          isVolatile: false,
        ),
        FormulaInput(
          materialId: 'mat_caustic',
          materialName: 'Caustic Soda',
          quantityPerBatch: 12.0,
          unit: 'Kg',
          isVolatile: false,
        ),
        FormulaInput(
          materialId: 'mat_water',
          materialName: 'Water',
          quantityPerBatch: 20.0,
          unit: 'Kg',
          isVolatile: true,
          expectedLossPercent: 25.0, // 25% evaporates during cooking
          lossTolerancePercent: 5.0,
        ),
      ],
      outputs: [
        FormulaOutput(
          productId: productId,
          productName: productName,
          quantityPerBatch: 77.0, // 50 + 12 + (20 - 5) = 77 Kg
          unit: 'Kg',
        ),
      ],
      expectedYieldPercent: 100.0, // 77 / 77 = 100%
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
