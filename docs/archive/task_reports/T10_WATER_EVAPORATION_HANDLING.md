# T10 BOM: Water Evaporation & Volatile Materials Handling

**Date**: 2025-01-07  
**Issue**: Water adds hota hai but cooking mein evaporate ho jata hai  
**Solution**: Volatile materials tracking with expected loss

---

## Problem Statement

### Current Bhatti Process

```
Input:
- Caustic Soda: 10 kg (solid)
- Oil: 50 kg (liquid)
- Water: 20 kg (volatile) ← ADDS
- Fragrance: 2 kg (liquid)
Total Input: 82 kg

Process: Cooking (heating)
- Water evaporates: ~5 kg loss ← REDUCES

Output:
- Soap Base: 77 kg (expected)
```

**Challenge**: Simple yield calculation fails because water loss is expected!

---

## Solution: Volatile Materials Concept

### Enhanced Formula Model

```dart
class FormulaInput {
  final String materialId;
  final String materialName;
  final double quantityPerBatch;
  final String unit;
  final double tolerancePercent;
  
  // NEW: Volatile material handling
  final bool isVolatile;
  final double expectedLossPercent; // % of this material that evaporates
  final double lossTolerancePercent; // ±% tolerance on loss
  
  FormulaInput({
    required this.materialId,
    required this.materialName,
    required this.quantityPerBatch,
    required this.unit,
    this.tolerancePercent = 5.0,
    this.isVolatile = false, // Default: non-volatile
    this.expectedLossPercent = 0.0, // Default: no loss
    this.lossTolerancePercent = 10.0, // ±10% on loss
  });
  
  // Calculate expected remaining after loss
  double get expectedRemainingQuantity {
    if (!isVolatile) return quantityPerBatch;
    final loss = quantityPerBatch * (expectedLossPercent / 100);
    return quantityPerBatch - loss;
  }
}
```

---

## Updated Validation Logic

### Step 1: Calculate Effective Input

```dart
class BomValidationService {
  
  /// Calculate total input after accounting for volatile losses
  double _calculateEffectiveInput(List<FormulaInput> formulaInputs) {
    double total = 0.0;
    
    for (final input in formulaInputs) {
      if (input.isVolatile) {
        // Add only the remaining quantity after expected loss
        total += input.expectedRemainingQuantity;
      } else {
        // Add full quantity for non-volatile materials
        total += input.quantityPerBatch;
      }
    }
    
    return total;
  }
  
  /// Validate yield considering volatile materials
  BomValidationResult _validateYield({
    required ProductFormula formula,
    required List<MaterialConsumption> actualInputs,
    required double actualOutput,
  }) {
    // Calculate effective input (after expected losses)
    final effectiveInput = _calculateEffectiveInput(formula.inputs);
    
    // Calculate yield based on effective input
    final yieldPercent = (actualOutput / effectiveInput) * 100;
    
    if (yieldPercent < formula.minYieldPercent) {
      return BomValidationResult.yieldError(
        'Yield too low: ${yieldPercent.toStringAsFixed(1)}% '
        '(minimum: ${formula.minYieldPercent}%)\n'
        'Effective input after losses: ${effectiveInput.toStringAsFixed(2)} kg',
      );
    }
    
    if (yieldPercent > formula.maxYieldPercent) {
      return BomValidationResult.yieldError(
        'Yield too high: ${yieldPercent.toStringAsFixed(1)}% '
        '(maximum: ${formula.maxYieldPercent}%)',
      );
    }
    
    return BomValidationResult.success();
  }
  
  /// NEW: Validate volatile material losses
  BomValidationResult _validateVolatileLosses({
    required ProductFormula formula,
    required List<MaterialConsumption> actualInputs,
    required double actualOutput,
  }) {
    final errors = <String>[];
    
    for (final formulaInput in formula.inputs) {
      if (!formulaInput.isVolatile) continue;
      
      final actualInput = actualInputs.firstWhere(
        (a) => a.materialId == formulaInput.materialId,
        orElse: () => MaterialConsumption.empty(),
      );
      
      if (actualInput.isEmpty) continue;
      
      // Calculate expected loss
      final expectedLoss = formulaInput.quantityPerBatch * 
          (formulaInput.expectedLossPercent / 100);
      
      // Calculate tolerance on loss
      final lossTolerance = expectedLoss * 
          (formulaInput.lossTolerancePercent / 100);
      
      final minLoss = expectedLoss - lossTolerance;
      final maxLoss = expectedLoss + lossTolerance;
      
      // Calculate actual loss (input - what remains in output)
      // This is approximate - actual loss tracking would need more data
      final expectedRemaining = formulaInput.expectedRemainingQuantity;
      
      // Log warning if loss seems unusual
      // (Full validation would need actual loss measurement)
      if (expectedLoss > 0) {
        // Just validate that input was provided
        // Actual loss is implicit in yield calculation
      }
    }
    
    return BomValidationResult.success();
  }
}
```

---

## Example Formula with Water

### Soap Base Production

```dart
ProductFormula(
  id: 'formula_soap_base_sona',
  productId: 'prod_soap_base',
  productName: 'Soap Base',
  departmentId: 'sona bhatti',
  inputs: [
    // Non-volatile materials
    FormulaInput(
      materialId: 'raw_caustic_soda',
      materialName: 'Caustic Soda',
      quantityPerBatch: 10.0,
      unit: 'KG',
      tolerancePercent: 5.0,
      isVolatile: false, // Solid, doesn't evaporate
    ),
    FormulaInput(
      materialId: 'raw_oil',
      materialName: 'Oil',
      quantityPerBatch: 50.0,
      unit: 'KG',
      tolerancePercent: 5.0,
      isVolatile: false, // Liquid, but doesn't evaporate significantly
    ),
    
    // Volatile material - WATER
    FormulaInput(
      materialId: 'raw_water',
      materialName: 'Water',
      quantityPerBatch: 20.0,
      unit: 'KG',
      tolerancePercent: 10.0,
      isVolatile: true, // ← VOLATILE
      expectedLossPercent: 25.0, // 25% evaporates (5 kg out of 20 kg)
      lossTolerancePercent: 20.0, // ±20% tolerance on loss
    ),
    // Remaining water: 20 - 5 = 15 kg
    
    FormulaInput(
      materialId: 'raw_fragrance',
      materialName: 'Fragrance',
      quantityPerBatch: 2.0,
      unit: 'KG',
      tolerancePercent: 10.0,
      isVolatile: false,
    ),
  ],
  output: FormulaOutput(
    productId: 'prod_soap_base',
    productName: 'Soap Base',
    expectedQuantity: 77.0, // 10+50+15+2 = 77 kg
    unit: 'KG',
  ),
  minYieldPercent: 95.0, // Based on effective input (77 kg)
  maxYieldPercent: 100.0,
  maxWastagePercent: 5.0, // Only 5% wastage allowed (excluding water loss)
  isActive: true,
  createdAt: DateTime.now(),
);
```

---

## Calculation Example

### Scenario 1: Normal Production

**Input**:
- Caustic: 10 kg
- Oil: 50 kg
- Water: 20 kg
- Fragrance: 2 kg
- **Total Input**: 82 kg

**Expected Losses**:
- Water evaporation: 5 kg (25% of 20 kg)

**Effective Input**:
- Caustic: 10 kg
- Oil: 50 kg
- Water remaining: 15 kg
- Fragrance: 2 kg
- **Total Effective**: 77 kg

**Output**: 77 kg soap base

**Yield**: 77/77 = 100% ✅ VALID

---

### Scenario 2: High Water Loss

**Input**:
- Caustic: 10 kg
- Oil: 50 kg
- Water: 20 kg
- Fragrance: 2 kg

**Actual Losses**:
- Water evaporation: 8 kg (40% - too high!)

**Effective Input**:
- Total: 74 kg (instead of expected 77 kg)

**Output**: 74 kg soap base

**Yield**: 74/77 = 96% ✅ VALID (within range)

**Warning**: Water loss higher than expected (8 kg vs 5 kg expected)

---

### Scenario 3: Impossible Yield

**Input**:
- Caustic: 10 kg
- Oil: 50 kg
- Water: 20 kg
- Fragrance: 2 kg

**Output**: 85 kg soap base (claimed)

**Yield**: 85/77 = 110% ❌ INVALID

**Error**: "Yield too high: 110% (maximum: 100%) - Check measurements"

---

## UI Enhancement

### Bhatti Entry Screen

```dart
class BhattiBatchEntryScreen extends StatefulWidget {
  // Add water loss tracking
  
  Widget _buildWaterInput() {
    return Column(
      children: [
        // Water quantity input
        TextField(
          decoration: InputDecoration(
            labelText: 'Water (KG)',
            hintText: 'Expected: 20 kg',
          ),
          onChanged: (value) {
            setState(() {
              _waterQuantity = double.tryParse(value) ?? 0;
              _calculateExpectedOutput();
            });
          },
        ),
        
        // Show expected water loss
        if (_waterQuantity > 0)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Expected water loss: ${(_waterQuantity * 0.25).toStringAsFixed(1)} kg (25%)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
  
  void _calculateExpectedOutput() {
    // Calculate effective input
    double effectiveInput = 0;
    effectiveInput += _causticQuantity; // Non-volatile
    effectiveInput += _oilQuantity; // Non-volatile
    effectiveInput += _waterQuantity * 0.75; // 75% remains (25% evaporates)
    effectiveInput += _fragranceQuantity; // Non-volatile
    
    setState(() {
      _expectedOutput = effectiveInput;
    });
  }
  
  Widget _buildOutputInput() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Output (KG)',
            hintText: 'Expected: ${_expectedOutput.toStringAsFixed(1)} kg',
          ),
          onChanged: (value) {
            setState(() {
              _actualOutput = double.tryParse(value) ?? 0;
            });
          },
        ),
        
        // Show yield percentage
        if (_actualOutput > 0 && _expectedOutput > 0)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  _getYieldIcon(),
                  color: _getYieldColor(),
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'Yield: ${(_actualOutput / _expectedOutput * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getYieldColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  IconData _getYieldIcon() {
    final yield = _actualOutput / _expectedOutput * 100;
    if (yield >= 95 && yield <= 100) return Icons.check_circle;
    if (yield >= 90 && yield < 95) return Icons.warning;
    return Icons.error;
  }
  
  Color _getYieldColor() {
    final yield = _actualOutput / _expectedOutput * 100;
    if (yield >= 95 && yield <= 100) return Colors.green;
    if (yield >= 90 && yield < 95) return Colors.orange;
    return Colors.red;
  }
}
```

---

## Advanced: Actual Loss Tracking (Optional)

### If you want to track actual water loss

```dart
class BhattiBatchWithLossTracking {
  final String batchId;
  final List<MaterialInput> inputs;
  final double outputQuantity;
  
  // NEW: Track actual losses
  final Map<String, double> actualLosses; // materialId -> loss quantity
  
  BhattiBatchWithLossTracking({
    required this.batchId,
    required this.inputs,
    required this.outputQuantity,
    this.actualLosses = const {},
  });
}

// In bhatti service
Future<void> createBhattiBatch({
  // ... existing params
  Map<String, double>? measuredLosses, // Optional: actual measured losses
}) async {
  // If losses are measured, validate them
  if (measuredLosses != null) {
    for (final entry in measuredLosses.entries) {
      final materialId = entry.key;
      final actualLoss = entry.value;
      
      final formulaInput = formula.inputs.firstWhere(
        (i) => i.materialId == materialId,
      );
      
      if (formulaInput.isVolatile) {
        final expectedLoss = formulaInput.quantityPerBatch * 
            (formulaInput.expectedLossPercent / 100);
        
        final tolerance = expectedLoss * 
            (formulaInput.lossTolerancePercent / 100);
        
        if ((actualLoss - expectedLoss).abs() > tolerance) {
          // Log warning but don't block
          AppLogger.warning(
            'Water loss unusual: Expected ${expectedLoss.toStringAsFixed(1)} kg, '
            'Actual ${actualLoss.toStringAsFixed(1)} kg',
          );
        }
      }
    }
  }
}
```

---

## Summary

### Key Changes

1. **`isVolatile` flag**: Mark water as volatile material
2. **`expectedLossPercent`**: Define expected evaporation (25%)
3. **`lossTolerancePercent`**: Allow variation in loss (±20%)
4. **Effective Input Calculation**: Subtract expected losses before yield calculation
5. **UI Hints**: Show expected water loss and yield percentage

### Benefits

✅ Accurate yield calculation  
✅ Water evaporation accounted for  
✅ Realistic validation ranges  
✅ Operator guidance in UI  
✅ Optional actual loss tracking

### Implementation

**Time**: Same 4-6 hours (includes volatile materials)

**Complexity**: Medium (but well-defined)

**Value**: HIGH (realistic validation)

---

## Recommendation

**Current Deployment**: Proceed without T10 ✅

**T10 with Volatile Materials**: Implement in next sprint

**Reason**: 
- Volatile materials concept is well-defined
- Implementation is straightforward
- Adds significant value for quality control
- Not blocking current deployment

---

**Kya yeh approach theek hai? Ya koi aur requirement hai water handling ke liye?**

