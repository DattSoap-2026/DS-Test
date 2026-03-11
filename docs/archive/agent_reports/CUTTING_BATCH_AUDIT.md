# Cutting Batch Entry - Issues Audit

## Issues Identified

### Issue 1: Wrong Unit Display (BAG instead of BOX)
**Location:** Line 1088 - `_buildInputCard()`
```dart
'${p.name} (${p.stock.toStringAsFixed(1)} ${p.baseUnit.isEmpty ? 'KG' : p.baseUnit.toUpperCase()})'
```

**Problem:** 
- Semi-finished product shows stock with `baseUnit` (e.g., "BAG")
- Should show "BOX" for semi-finished soap base
- User sees "Gita (5.0 BAG)" instead of "Gita (5.0 BOX)"

**Root Cause:**
- Using `p.baseUnit` directly without checking product type
- Semi-finished products should display in BOX units

---

### Issue 2: Wrong Average Box Weight Calculation
**Location:** Line 367 - `_resolveBoxesPerBatch()` and Line 375 - `_resolveSemiBoxWeightKg()`

**Current Logic:**
```dart
double _resolveSemiBoxWeightKg() {
  final grams = _selectedSemiProduct?.unitWeightGrams ?? 0;
  if (grams <= 0) return 0;
  return grams / 1000;
}
```

**Problem:**
- Uses `unitWeightGrams` which is per-piece weight
- Should use total box weight (190 KG per box for semi-finished)
- Calculation: `_avgBoxWeight = totalWeight / boxCount`
- Shows 31.67 KG instead of 190 KG

**Expected:**
- 1 Box = 190 KG (for semi-finished soap base)
- Gita: 7 boxes/batch = 1330 KG total
- Sona: 6 boxes/batch = 1140 KG total

---

### Issue 3: Stock Deduction Not Happening
**Location:** Service layer - `cutting_batch_service.dart`

**Problem:**
- When batch is created, semi-finished stock should reduce
- Currently no stock deduction logic visible in screen
- Need to verify service layer handles this

**Expected Flow:**
1. User selects "Gita (5.0 BOX)" 
2. Creates 1 batch (7 boxes)
3. After save, stock should become: "Gita (-2.0 BOX)" or show error if insufficient

---

## Fixes Required

### Fix 1: Display BOX for Semi-Finished Products
```dart
// BEFORE
'${p.name} (${p.stock.toStringAsFixed(1)} ${p.baseUnit.isEmpty ? 'KG' : p.baseUnit.toUpperCase()})'

// AFTER
'${p.name} (${p.stock.toStringAsFixed(1)} ${_isSemiProduct(p) ? 'BOX' : (p.baseUnit.isEmpty ? 'KG' : p.baseUnit.toUpperCase())})'
```

### Fix 2: Correct Box Weight Calculation
```dart
// Add new field to Product or use boxWeightKg
double _resolveSemiBoxWeightKg() {
  // For semi-finished soap base, 1 box = 190 KG
  final boxWeight = _selectedSemiProduct?.boxWeightKg ?? 190.0;
  return boxWeight;
}

// Update batch calculation
void _refreshBatchDerivedValues() {
  final perBatch = _resolveBoxesPerBatch();
  final totalBoxes = perBatch > 0 ? perBatch * _batchCount : 0;
  final boxWeightKg = _resolveSemiBoxWeightKg(); // 190 KG per box
  final inputWeightKg = totalBoxes * boxWeightKg; // Total weight

  setState(() {
    _boxesPerBatch = perBatch;
    _boxesCountController.text = totalBoxes.toString();
    _totalBatchWeightController.text = inputWeightKg > 0
        ? inputWeightKg.toStringAsFixed(3)
        : '0';
  });

  _onBoxesCountChanged(_boxesCountController.text);
  // ... rest of code
}
```

### Fix 3: Stock Validation & Deduction
```dart
// Add validation before submit
bool _validateForm() {
  // ... existing validations

  // Check semi-finished stock availability
  if (_selectedSemiProduct != null) {
    final requiredBoxes = int.tryParse(_boxesCountController.text) ?? 0;
    final availableStock = _selectedSemiProduct!.stock;
    
    if (requiredBoxes > availableStock) {
      _showError(
        'Insufficient stock! Required: $requiredBoxes BOX, Available: ${availableStock.toStringAsFixed(1)} BOX'
      );
      return false;
    }
  }

  return true;
}
```

---

## Summary

| Issue | Current Behavior | Expected Behavior | Priority |
|-------|-----------------|-------------------|----------|
| Unit Display | Shows "BAG" | Should show "BOX" | HIGH |
| Avg Box Weight | Shows 31.67 KG | Should show 190 KG | CRITICAL |
| Stock Deduction | Not visible | Should reduce stock | CRITICAL |

---

## Testing Checklist

- [ ] Semi-finished product shows "BOX" unit
- [ ] Average box weight shows 190 KG (not 31.67 KG)
- [ ] Gita batch (7 boxes) shows 1330 KG total
- [ ] Sona batch (6 boxes) shows 1140 KG total
- [ ] Stock validation prevents over-consumption
- [ ] After batch creation, semi-finished stock reduces correctly
- [ ] Stock ledger entry created for semi-finished deduction
- [ ] Stock ledger entry created for finished goods addition
