import '../../models/bom/product_formula.dart';
import '../../models/bom/bom_validation_result.dart';

/// BOM Validation Service - Phase 1 (Silent Mode)
/// 
/// Validates production batches against defined formulas.
/// Handles volatile materials (e.g., water evaporation).
class BomValidationService {
  /// Validates a production batch against its formula
  /// 
  /// Returns BomValidationResult with success/failure details
  BomValidationResult validateBatch({
    required ProductFormula formula,
    required Map<String, double> actualInputs,
    required Map<String, double> actualOutputs,
    double tolerancePercent = 5.0,
  }) {
    try {
      // 1. Validate all required inputs are present
      final missingInputs = <String>[];
      for (var input in formula.inputs) {
        if (!actualInputs.containsKey(input.materialId)) {
          missingInputs.add(input.materialId);
        }
      }
      if (missingInputs.isNotEmpty) {
        return BomValidationResult.missingMaterials(
          missingMaterialIds: missingInputs,
        );
      }

      // 2. Calculate effective inputs (after volatile losses)
      final effectiveInputs = <String, double>{};
      double totalEffectiveInput = 0.0;

      for (var input in formula.inputs) {
        final actualQty = actualInputs[input.materialId] ?? 0.0;
        
        if (input.isVolatile) {
          // Apply expected loss
          final lossQty = actualQty * (input.expectedLossPercent / 100);
          final effectiveQty = actualQty - lossQty;
          effectiveInputs[input.materialId] = effectiveQty;
          totalEffectiveInput += effectiveQty;
        } else {
          effectiveInputs[input.materialId] = actualQty;
          totalEffectiveInput += actualQty;
        }
      }

      // 3. Validate input ratios
      for (var input in formula.inputs) {
        final actualQty = actualInputs[input.materialId] ?? 0.0;
        final expectedQty = input.quantityPerBatch;
        final deviation = ((actualQty - expectedQty).abs() / expectedQty) * 100;

        if (deviation > tolerancePercent) {
          return BomValidationResult.ratioViolation(
            materialId: input.materialId,
            expected: expectedQty,
            actual: actualQty,
            deviationPercent: deviation,
          );
        }
      }

      // 4. Calculate total actual output
      double totalActualOutput = 0.0;
      for (var output in formula.outputs) {
        totalActualOutput += actualOutputs[output.productId] ?? 0.0;
      }

      // 5. Calculate yield
      final actualYield = totalEffectiveInput > 0 
          ? (totalActualOutput / totalEffectiveInput) * 100 
          : 0.0;

      // 6. Validate yield within tolerance
      final yieldDeviation = (actualYield - formula.expectedYieldPercent).abs();
      
      if (yieldDeviation > tolerancePercent) {
        return BomValidationResult.yieldViolation(
          expectedYield: formula.expectedYieldPercent,
          actualYield: actualYield,
          deviationPercent: yieldDeviation,
        );
      }

      // 7. Success
      return BomValidationResult.success(
        effectiveInputKg: totalEffectiveInput,
        actualOutputKg: totalActualOutput,
        yieldPercent: actualYield,
      );
    } catch (e) {
      return BomValidationResult.error(
        message: 'Validation failed: ${e.toString()}',
      );
    }
  }

  /// Calculates material consumption with volatile losses
  /// 
  /// Returns MaterialConsumption with effective quantities
  MaterialConsumption calculateConsumption({
    required FormulaInput input,
    required double actualQuantity,
  }) {
    if (!input.isVolatile) {
      return MaterialConsumption(
        materialId: input.materialId,
        materialName: input.materialName,
        plannedQuantity: input.quantityPerBatch,
        actualQuantity: actualQuantity,
        effectiveQuantity: actualQuantity,
        lossQuantity: 0.0,
        lossPercent: 0.0,
      );
    }

    final lossQty = actualQuantity * (input.expectedLossPercent / 100);
    final effective = actualQuantity - lossQty;
    final actualLossPercent = (lossQty / actualQuantity) * 100;

    return MaterialConsumption(
      materialId: input.materialId,
      materialName: input.materialName,
      plannedQuantity: input.quantityPerBatch,
      actualQuantity: actualQuantity,
      effectiveQuantity: effective,
      lossQuantity: lossQty,
      lossPercent: actualLossPercent,
    );
  }

  /// Validates if actual loss is within tolerance
  bool validateVolatileLoss({
    required FormulaInput input,
    required double actualQuantity,
    required double actualLossQuantity,
  }) {
    if (!input.isVolatile) return true;

    final actualLossPercent = (actualLossQuantity / actualQuantity) * 100;
    final deviation = (actualLossPercent - input.expectedLossPercent).abs();

    return deviation <= input.lossTolerancePercent;
  }
}
