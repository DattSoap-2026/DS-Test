# T10: BOM Validation Implementation Plan for Bhatti Production

**Date**: 2025-01-07  
**Context**: Raw material → Bhatti Department → Semi-finished goods  
**Estimated Time**: 4-6 hours

---

## Production Flow Understanding

### Current Process

```
Raw Material (Warehouse)
    ↓ (Issue to Department)
Bhatti Department Stock
    ↓ (Consumption in production)
Semi-Finished Product (Output)
    ↓ (Transfer to warehouse)
Warehouse Stock (Semi-finished)
```

### Example: Soap Production

**Input** (Raw Materials):
- Caustic Soda: 10 kg
- Oil: 50 kg
- Fragrance: 2 kg
- Water: 20 kg

**Process**: Bhatti (mixing, heating)

**Output** (Semi-finished):
- Soap Base: 75 kg (some water evaporates)

---

## BOM Validation Requirements

### 1. Formula Definition

**What to validate**:
- Input materials (type + quantity)
- Expected output quantity
- Yield percentage (min/max range)
- Wastage allowance

### 2. Validation Points

**When to validate**:
- ✅ Before production entry
- ✅ During bhatti batch creation
- ✅ On production completion

**What to check**:
- Input materials match formula
- Output quantity within yield range
- Department has sufficient stock
- Wastage within acceptable limits

---

## Implementation Design

### Step 1: Create BOM Models

**File**: `lib/models/bom/product_formula.dart`

```dart
class ProductFormula {
  final String id;
  final String productId;
  final String productName;
  final String departmentId; // 'sona bhatti', 'gita bhatti'
  final List<FormulaInput> inputs;
  final FormulaOutput output;
  final double minYieldPercent; // e.g., 85%
  final double maxYieldPercent; // e.g., 95%
  final double maxWastagePercent; // e.g., 15%
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductFormula({
    required this.id,
    required this.productId,
    required this.productName,
    required this.departmentId,
    required this.inputs,
    required this.output,
    required this.minYieldPercent,
    required this.maxYieldPercent,
    required this.maxWastagePercent,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });
}

class FormulaInput {
  final String materialId;
  final String materialName;
  final double quantityPerBatch; // Base quantity
  final String unit;
  final double tolerancePercent; // ±5% allowed

  FormulaInput({
    required this.materialId,
    required this.materialName,
    required this.quantityPerBatch,
    required this.unit,
    this.tolerancePercent = 5.0,
  });
}

class FormulaOutput {
  final String productId;
  final String productName;
  final double expectedQuantity;
  final String unit;

  FormulaOutput({
    required this.productId,
    required this.productName,
    required this.expectedQuantity,
    required this.unit,
  });
}
```

---

### Step 2: Create Isar Entity

**File**: `lib/data/local/entities/product_formula_entity.dart`

```dart
import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'product_formula_entity.g.dart';

@Collection()
class ProductFormulaEntity extends BaseEntity {
  late String productId;
  late String productName;
  late String departmentId;
  
  // Store as JSON string
  late String inputsJson; // List<FormulaInput>
  late String outputJson; // FormulaOutput
  
  late double minYieldPercent;
  late double maxYieldPercent;
  late double maxWastagePercent;
  
  @Index()
  late bool isActive;
  
  // Composite index for quick lookup
  @Index(composite: [CompositeIndex('departmentId')])
  late String productIdDeptId;
}
```

---

### Step 3: Add Validation Service

**File**: `lib/services/bom_validation_service.dart`

```dart
class BomValidationService {
  final DatabaseService _dbService;

  BomValidationService(this._dbService);

  /// Validates bhatti production against formula
  Future<BomValidationResult> validateBhattiProduction({
    required String productId,
    required String departmentId,
    required List<MaterialConsumption> actualInputs,
    required double actualOutput,
  }) async {
    // 1. Get formula
    final formula = await _getFormula(productId, departmentId);
    if (formula == null) {
      return BomValidationResult.noFormula(
        'No formula defined for $productId in $departmentId',
      );
    }

    // 2. Validate inputs
    final inputValidation = _validateInputs(
      formula.inputs,
      actualInputs,
    );
    if (!inputValidation.isValid) {
      return inputValidation;
    }

    // 3. Validate output yield
    final yieldValidation = _validateYield(
      formula: formula,
      actualInputs: actualInputs,
      actualOutput: actualOutput,
    );
    if (!yieldValidation.isValid) {
      return yieldValidation;
    }

    // 4. Check wastage
    final wastageValidation = _validateWastage(
      formula: formula,
      actualInputs: actualInputs,
      actualOutput: actualOutput,
    );
    if (!wastageValidation.isValid) {
      return wastageValidation;
    }

    return BomValidationResult.success();
  }

  BomValidationResult _validateInputs(
    List<FormulaInput> expected,
    List<MaterialConsumption> actual,
  ) {
    final errors = <String>[];

    // Check all required materials present
    for (final expectedInput in expected) {
      final actualInput = actual.firstWhere(
        (a) => a.materialId == expectedInput.materialId,
        orElse: () => MaterialConsumption.empty(),
      );

      if (actualInput.isEmpty) {
        errors.add(
          'Missing material: ${expectedInput.materialName}',
        );
        continue;
      }

      // Check quantity within tolerance
      final expectedQty = expectedInput.quantityPerBatch;
      final tolerance = expectedQty * (expectedInput.tolerancePercent / 100);
      final minQty = expectedQty - tolerance;
      final maxQty = expectedQty + tolerance;

      if (actualInput.quantity < minQty || actualInput.quantity > maxQty) {
        errors.add(
          '${expectedInput.materialName}: Expected ${expectedQty.toStringAsFixed(2)} ±${expectedInput.tolerancePercent}%, '
          'Got ${actualInput.quantity.toStringAsFixed(2)} ${expectedInput.unit}',
        );
      }
    }

    if (errors.isNotEmpty) {
      return BomValidationResult.inputError(errors);
    }

    return BomValidationResult.success();
  }

  BomValidationResult _validateYield(
    ProductFormula formula,
    List<MaterialConsumption> actualInputs,
    double actualOutput,
  ) {
    final totalInput = actualInputs.fold<double>(
      0.0,
      (sum, input) => sum + input.quantity,
    );

    final yieldPercent = (actualOutput / totalInput) * 100;

    if (yieldPercent < formula.minYieldPercent) {
      return BomValidationResult.yieldError(
        'Yield too low: ${yieldPercent.toStringAsFixed(1)}% '
        '(minimum: ${formula.minYieldPercent}%)',
      );
    }

    if (yieldPercent > formula.maxYieldPercent) {
      return BomValidationResult.yieldError(
        'Yield too high: ${yieldPercent.toStringAsFixed(1)}% '
        '(maximum: ${formula.maxYieldPercent}%) - Check measurements',
      );
    }

    return BomValidationResult.success();
  }

  BomValidationResult _validateWastage(
    ProductFormula formula,
    List<MaterialConsumption> actualInputs,
    double actualOutput,
  ) {
    final totalInput = actualInputs.fold<double>(
      0.0,
      (sum, input) => sum + input.quantity,
    );

    final wastage = totalInput - actualOutput;
    final wastagePercent = (wastage / totalInput) * 100;

    if (wastagePercent > formula.maxWastagePercent) {
      return BomValidationResult.wastageError(
        'Wastage too high: ${wastagePercent.toStringAsFixed(1)}% '
        '(maximum: ${formula.maxWastagePercent}%)',
      );
    }

    return BomValidationResult.success();
  }

  Future<ProductFormula?> _getFormula(
    String productId,
    String departmentId,
  ) async {
    final entity = await _dbService.productFormulas
        .filter()
        .productIdEqualTo(productId)
        .and()
        .departmentIdEqualTo(departmentId)
        .and()
        .isActiveEqualTo(true)
        .findFirst();

    return entity?.toDomain();
  }
}

class BomValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String>? errors;
  final BomValidationType type;

  BomValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.errors,
    required this.type,
  });

  factory BomValidationResult.success() => BomValidationResult._(
        isValid: true,
        type: BomValidationType.success,
      );

  factory BomValidationResult.noFormula(String message) =>
      BomValidationResult._(
        isValid: false,
        errorMessage: message,
        type: BomValidationType.noFormula,
      );

  factory BomValidationResult.inputError(List<String> errors) =>
      BomValidationResult._(
        isValid: false,
        errors: errors,
        type: BomValidationType.inputError,
      );

  factory BomValidationResult.yieldError(String message) =>
      BomValidationResult._(
        isValid: false,
        errorMessage: message,
        type: BomValidationType.yieldError,
      );

  factory BomValidationResult.wastageError(String message) =>
      BomValidationResult._(
        isValid: false,
        errorMessage: message,
        type: BomValidationType.wastageError,
      );
}

enum BomValidationType {
  success,
  noFormula,
  inputError,
  yieldError,
  wastageError,
}

class MaterialConsumption {
  final String materialId;
  final double quantity;
  final String unit;

  MaterialConsumption({
    required this.materialId,
    required this.quantity,
    required this.unit,
  });

  factory MaterialConsumption.empty() => MaterialConsumption(
        materialId: '',
        quantity: 0,
        unit: '',
      );

  bool get isEmpty => materialId.isEmpty;
}
```

---

### Step 4: Integrate with Bhatti Service

**File**: `lib/services/bhatti_service.dart` (modify existing)

```dart
class BhattiService {
  final BomValidationService _bomValidation;
  
  // Add to existing createBhattiBatch method
  Future<String> createBhattiBatch({
    required String productId,
    required String departmentId,
    required List<RawMaterialInput> rawMaterials,
    required double outputQuantity,
    // ... other params
  }) async {
    // STEP 1: BOM Validation (NEW)
    final validationResult = await _bomValidation.validateBhattiProduction(
      productId: productId,
      departmentId: departmentId,
      actualInputs: rawMaterials.map((r) => MaterialConsumption(
        materialId: r.materialId,
        quantity: r.quantity,
        unit: r.unit,
      )).toList(),
      actualOutput: outputQuantity,
    );

    if (!validationResult.isValid) {
      throw BomViolationException(
        message: validationResult.errorMessage ?? 'BOM validation failed',
        errors: validationResult.errors,
        type: validationResult.type,
      );
    }

    // STEP 2: Continue with existing production logic
    // ... existing code ...
  }
}

class BomViolationException implements Exception {
  final String message;
  final List<String>? errors;
  final BomValidationType type;

  BomViolationException({
    required this.message,
    this.errors,
    required this.type,
  });

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return 'BOM Violation:\n${errors!.join('\n')}';
    }
    return 'BOM Violation: $message';
  }
}
```

---

### Step 5: UI Integration

**File**: `lib/screens/bhatti/bhatti_batch_entry_screen.dart`

```dart
// Add validation before save
Future<void> _saveBatch() async {
  try {
    // Show loading
    setState(() => _isValidating = true);

    // Call service (validation happens inside)
    await _bhattiService.createBhattiBatch(
      productId: _selectedProduct!.id,
      departmentId: _selectedDepartment,
      rawMaterials: _rawMaterials,
      outputQuantity: _outputQuantity,
    );

    // Success
    _showSuccess('Batch created successfully');
    Navigator.pop(context);
    
  } on BomViolationException catch (e) {
    // Show validation errors
    _showBomViolationDialog(e);
  } catch (e) {
    _showError(e.toString());
  } finally {
    setState(() => _isValidating = false);
  }
}

void _showBomViolationDialog(BomViolationException e) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Formula Validation Failed'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (e.errors != null)
              ...e.errors!.map((error) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text(error)),
                  ],
                ),
              ))
            else
              Text(e.message),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

---

## Implementation Steps

### Phase 1: Models & Entities (1 hour)

1. Create `ProductFormula` model
2. Create `ProductFormulaEntity` Isar entity
3. Run `flutter pub run build_runner build`

### Phase 2: Validation Service (2 hours)

1. Create `BomValidationService`
2. Implement validation logic
3. Add unit tests

### Phase 3: Integration (1 hour)

1. Modify `BhattiService`
2. Add validation call
3. Handle exceptions

### Phase 4: UI & Testing (1-2 hours)

1. Update bhatti entry screen
2. Add error dialogs
3. Test with real data
4. Add formula management screen (admin)

---

## Formula Management

### Admin Screen (Optional)

**File**: `lib/screens/admin/formula_management_screen.dart`

```dart
// Screen to create/edit formulas
class FormulaManagementScreen extends StatelessWidget {
  // List all formulas
  // Add new formula
  // Edit existing formula
  // Activate/deactivate formula
}
```

### Sample Formula Data

```dart
// Soap Base Production (Sona Bhatti)
ProductFormula(
  id: 'formula_soap_base_sona',
  productId: 'prod_soap_base',
  productName: 'Soap Base',
  departmentId: 'sona bhatti',
  inputs: [
    FormulaInput(
      materialId: 'raw_caustic_soda',
      materialName: 'Caustic Soda',
      quantityPerBatch: 10.0,
      unit: 'KG',
      tolerancePercent: 5.0,
    ),
    FormulaInput(
      materialId: 'raw_oil',
      materialName: 'Oil',
      quantityPerBatch: 50.0,
      unit: 'KG',
      tolerancePercent: 5.0,
    ),
    FormulaInput(
      materialId: 'raw_fragrance',
      materialName: 'Fragrance',
      quantityPerBatch: 2.0,
      unit: 'KG',
      tolerancePercent: 10.0,
    ),
  ],
  output: FormulaOutput(
    productId: 'prod_soap_base',
    productName: 'Soap Base',
    expectedQuantity: 55.0,
    unit: 'KG',
  ),
  minYieldPercent: 85.0,
  maxYieldPercent: 95.0,
  maxWastagePercent: 15.0,
  isActive: true,
  createdAt: DateTime.now(),
);
```

---

## Benefits

### 1. Quality Control
- Impossible yields rejected
- Consistent production quality
- Wastage tracking

### 2. Cost Control
- Material usage monitored
- Wastage alerts
- Formula optimization

### 3. Audit Trail
- Formula changes tracked
- Production compliance verified
- Historical analysis possible

---

## Deployment Strategy

### Option 1: Soft Launch (Recommended)

1. Deploy without validation (current state)
2. Add formulas in background
3. Run validation in "warning mode" (log only)
4. After 1 week, enable strict mode

### Option 2: Immediate Enforcement

1. Create formulas for all products
2. Deploy with validation enabled
3. Train operators
4. Go live

---

## Estimated Timeline

**Total**: 4-6 hours

- Models & Entities: 1 hour
- Validation Service: 2 hours
- Integration: 1 hour
- UI & Testing: 1-2 hours

**Recommended**: Next sprint (not blocking current deployment)

---

## Conclusion

**T10 Implementation**: Feasible and valuable

**Complexity**: Medium

**Value**: HIGH for quality control

**Recommendation**: Implement in next sprint after production deployment

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-07  
**Status**: IMPLEMENTATION PLAN READY
