import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/bom/bom_validation_service.dart';
import 'package:flutter_app/models/bom/product_formula.dart';

void main() {
  late BomValidationService service;
  late ProductFormula soapFormula;

  setUp(() {
    service = BomValidationService();
    
    soapFormula = ProductFormula(
      id: 'formula_soap',
      productId: 'prod_soap',
      productName: 'Bhatti Soap',
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
          expectedLossPercent: 25.0,
          lossTolerancePercent: 5.0,
        ),
      ],
      outputs: [
        FormulaOutput(
          productId: 'prod_soap',
          productName: 'Bhatti Soap',
          quantityPerBatch: 77.0,
          unit: 'Kg',
        ),
      ],
      expectedYieldPercent: 100.0,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  });

  group('BomValidationService - Valid Batches', () {
    test('T10.1: Perfect batch passes validation', () {
      final result = service.validateBatch(
        formula: soapFormula,
        actualInputs: {
          'mat_oil': 50.0,
          'mat_caustic': 12.0,
          'mat_water': 20.0,
        },
        actualOutputs: {
          'prod_soap': 77.0,
        },
        tolerancePercent: 5.0,
      );

      expect(result.isValid, true);
      expect(result.effectiveInputKg, 77.0); // 50 + 12 + 15
      expect(result.actualOutputKg, 77.0);
      expect(result.yieldPercent, 100.0);
    });

    test('T10.2: Batch within tolerance passes', () {
      final result = service.validateBatch(
        formula: soapFormula,
        actualInputs: {
          'mat_oil': 51.0, // +2% deviation
          'mat_caustic': 12.5, // +4.2% deviation
          'mat_water': 20.0,
        },
        actualOutputs: {
          'prod_soap': 78.5, // Adjusted for extra input
        },
        tolerancePercent: 5.0,
      );

      expect(result.isValid, true);
    });
  });

  group('BomValidationService - Missing Materials', () {
    test('T10.3: Missing material fails validation', () {
      final result = service.validateBatch(
        formula: soapFormula,
        actualInputs: {
          'mat_oil': 50.0,
          'mat_caustic': 12.0,
          // mat_water missing
        },
        actualOutputs: {
          'prod_soap': 77.0,
        },
      );

      expect(result.isValid, false);
      expect(result.violationType, 'MISSING_MATERIALS');
      expect(result.message, contains('mat_water'));
    });
  });

  group('BomValidationService - Ratio Violations', () {
    test('T10.4: Excessive deviation fails validation', () {
      final result = service.validateBatch(
        formula: soapFormula,
        actualInputs: {
          'mat_oil': 60.0, // +20% deviation (exceeds 5% tolerance)
          'mat_caustic': 12.0,
          'mat_water': 20.0,
        },
        actualOutputs: {
          'prod_soap': 87.0,
        },
        tolerancePercent: 5.0,
      );

      expect(result.isValid, false);
      expect(result.violationType, 'RATIO_VIOLATION');
      expect(result.message, contains('mat_oil'));
    });
  });

  group('BomValidationService - Yield Violations', () {
    test('T10.5: Low yield fails validation', () {
      final result = service.validateBatch(
        formula: soapFormula,
        actualInputs: {
          'mat_oil': 50.0,
          'mat_caustic': 12.0,
          'mat_water': 20.0,
        },
        actualOutputs: {
          'prod_soap': 70.0, // Only 90.9% yield (expected 100%)
        },
        tolerancePercent: 5.0,
      );

      expect(result.isValid, false);
      expect(result.violationType, 'YIELD_VIOLATION');
      expect(result.actualYield, closeTo(90.9, 0.1));
    });
  });

  group('BomValidationService - Volatile Material Handling', () {
    test('T10.6: Water evaporation calculated correctly', () {
      final waterInput = soapFormula.inputs.firstWhere(
        (i) => i.materialId == 'mat_water',
      );

      final consumption = service.calculateConsumption(
        input: waterInput,
        actualQuantity: 20.0,
      );

      expect(consumption.actualQuantity, 20.0);
      expect(consumption.lossQuantity, 5.0); // 25% of 20
      expect(consumption.effectiveQuantity, 15.0);
      expect(consumption.lossPercent, 25.0);
    });

    test('T10.7: Volatile loss validation within tolerance', () {
      final waterInput = soapFormula.inputs.firstWhere(
        (i) => i.materialId == 'mat_water',
      );

      // 26% loss (within 5% tolerance of 25%)
      final isValid = service.validateVolatileLoss(
        input: waterInput,
        actualQuantity: 20.0,
        actualLossQuantity: 5.2,
      );

      expect(isValid, true);
    });

    test('T10.8: Excessive volatile loss fails validation', () {
      final waterInput = soapFormula.inputs.firstWhere(
        (i) => i.materialId == 'mat_water',
      );

      // 35% loss (exceeds 5% tolerance)
      final isValid = service.validateVolatileLoss(
        input: waterInput,
        actualQuantity: 20.0,
        actualLossQuantity: 7.0,
      );

      expect(isValid, false);
    });
  });
}
