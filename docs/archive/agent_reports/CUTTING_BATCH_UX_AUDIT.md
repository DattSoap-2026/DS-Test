# CUTTING BATCH UI/UX AUDIT - Stock Validation & Calculations

**Date**: 2024
**Scope**: Stock validation, box count editing, scrap calculation, and weight reconciliation

---

## 🔍 ISSUES IDENTIFIED FROM SCREENSHOTS

### Issue #1: Stock Display Format
**Current**: Shows "5.0 BOX" 
**Expected**: Show "5 BOX" (no decimal if whole number)

### Issue #2: No Low Stock Warning
**Current**: No warning when available stock < required boxes
**Problem**: User can see 5.0 BOX available but system auto-fills 6 boxes
**Expected**: Show warning icon/message when stock insufficient

### Issue #3: Boxes Field Always Locked
**Current**: Boxes field is always read-only (auto-calculated)
**Problem**: Cannot manually adjust if stock is sufficient
**Expected**: 
- LOCKED when stock < required boxes (show warning)
- EDITABLE when stock ≥ required boxes (allow manual override)

### Issue #4: Weight Reconciliation Shows 100% Difference
**Current**: Shows "1140.000 KG (100.00%)" in red
**Problem**: 
- INPUT (SF): 1140.00 KG
- OUTPUT (FG): 1102.50 KG
- CUTTING SCRAP: 0.00 KG
- Difference should be: 1140 - 1102.5 - 0 = 37.5 KG (3.29%)
**Root Cause**: Scrap weight is 0, but actual scrap should be ~37.5 KG

### Issue #5: Cutting Scrap Not Auto-Calculated
**Current**: User must manually enter scrap weight
**Expected**: 
- Auto-calculate: INPUT - OUTPUT = SCRAP
- Show calculated value in read-only field
- Provide "Actual Scrap Weight" field for manual override
- Use actual value if provided, otherwise use calculated

---

## ✅ REQUIRED FIXES

### Fix #1: Stock Display Format
**Location**: Dropdown display text
**Change**: Format stock as integer if whole number
```dart
// BEFORE:
'${p.name} (${p.stock.toStringAsFixed(1)} BOX)'

// AFTER:
'${p.name} (${_formatStock(p.stock)} BOX)'

String _formatStock(double stock) {
  return stock == stock.toInt() 
    ? stock.toInt().toString() 
    : stock.toStringAsFixed(1);
}
```

### Fix #2: Low Stock Warning
**Location**: Material Input card, after boxes field
**Add**: Warning banner when stock < required boxes
```dart
if (_selectedSemiProduct != null && _boxesCountController.text.isNotEmpty) {
  final required = int.tryParse(_boxesCountController.text) ?? 0;
  final available = _selectedSemiProduct!.stock;
  if (required > available) {
    // Show warning banner
  }
}
```

### Fix #3: Conditional Boxes Field Lock
**Location**: Boxes field in Material Input
**Logic**:
```dart
bool _canEditBoxes() {
  if (_selectedSemiProduct == null) return false;
  final required = int.tryParse(_boxesCountController.text) ?? 0;
  final available = _selectedSemiProduct!.stock;
  return available >= required; // Editable only if stock sufficient
}
```

### Fix #4: Auto-Calculate Cutting Scrap
**Location**: Wastage card
**Logic**:
```dart
double _calculateExpectedScrap() {
  final input = double.tryParse(_totalBatchWeightController.text) ?? 0;
  final output = _totalFinishedWeightKg;
  return input - output; // Expected scrap
}

// Show in UI:
// "Expected Scrap: 37.5 KG (Auto)"
// "Actual Scrap Weight: [editable field]"
```

### Fix #5: Correct Weight Reconciliation
**Location**: Production Progress card
**Logic**:
```dart
void _calculateWeightBalance() {
  final inputWeight = double.tryParse(_totalBatchWeightController.text) ?? 0;
  final outputWeight = _totalFinishedWeightKg;
  
  // Use actual scrap if provided, otherwise use calculated
  final actualScrap = double.tryParse(_cuttingWasteController.text) ?? 0;
  final expectedScrap = inputWeight - outputWeight;
  final wasteWeight = actualScrap > 0 ? actualScrap : expectedScrap;
  
  final balance = _cuttingBatchService.calculateWeightBalance(
    inputWeightKg: inputWeight,
    outputWeightKg: outputWeight,
    wasteWeightKg: wasteWeight,
  );
  
  setState(() {
    _weightBalance = balance;
    _weightBalanceValid = balance['weightBalanceValid'] as bool;
  });
}
```

---

## 🎯 IMPLEMENTATION PLAN

### Step 1: Add Helper Methods
```dart
String _formatStock(double stock) {
  return stock == stock.toInt() 
    ? stock.toInt().toString() 
    : stock.toStringAsFixed(1);
}

bool _canEditBoxes() {
  if (_selectedSemiProduct == null) return false;
  final required = int.tryParse(_boxesCountController.text) ?? 0;
  final available = _selectedSemiProduct!.stock;
  return available >= required;
}

double _calculateExpectedScrap() {
  final input = double.tryParse(_totalBatchWeightController.text) ?? 0;
  final output = _totalFinishedWeightKg;
  return input - output;
}

bool _hasLowStock() {
  if (_selectedSemiProduct == null) return false;
  final required = int.tryParse(_boxesCountController.text) ?? 0;
  final available = _selectedSemiProduct!.stock;
  return required > available;
}
```

### Step 2: Update Stock Display
```dart
// In _buildInputCard(), dropdown items:
items: _semiProducts
  .map((p) => DropdownMenuItem(
    value: p,
    child: Text('${p.name} (${_formatStock(p.stock)} BOX)'),
  ))
  .toList(),
```

### Step 3: Add Low Stock Warning
```dart
// In _buildInputCard(), after boxes field:
if (_hasLowStock()) ...[
  const SizedBox(height: 12),
  Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.error, width: 1),
    ),
    child: Row(
      children: [
        const Icon(Icons.warning_rounded, size: 16, color: AppColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'INSUFFICIENT STOCK! Required: ${_boxesCountController.text} BOX, Available: ${_formatStock(_selectedSemiProduct!.stock)} BOX',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.error,
              fontSize: 10,
            ),
          ),
        ),
      ],
    ),
  ),
],
```

### Step 4: Make Boxes Field Conditionally Editable
```dart
// In _buildInputCard(), boxes field:
Expanded(
  child: _buildTextField(
    controller: _boxesCountController,
    label: _canEditBoxes() ? 'Boxes (Editable)' : 'Boxes (Auto)',
    readOnly: !_canEditBoxes(),
    onChanged: (value) {
      _onBoxesCountChanged(value);
      _calculateWeightBalance();
    },
    keyboardType: TextInputType.number,
    inputFormatters: [
      NormalizedNumberInputFormatter.integer(keepZeroWhenEmpty: true),
    ],
  ),
),
```

### Step 5: Update Wastage Card with Auto-Calculated Scrap
```dart
// In _buildWasteCard():
Column(
  children: [
    // Show expected scrap (read-only)
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'EXPECTED SCRAP (AUTO)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.info,
            ),
          ),
          Text(
            '${_calculateExpectedScrap().toStringAsFixed(2)} KG',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.info,
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 12),
    // Actual scrap weight (editable)
    Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _cuttingWasteController,
            label: 'Actual Scrap Weight (Optional)',
            suffix: 'KG',
            onChanged: _onCuttingWasteChanged,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            inputFormatters: [
              NormalizedNumberInputFormatter.decimal(
                keepZeroWhenEmpty: true,
                maxDecimalPlaces: 3,
              ),
            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: 8),
    Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Leave empty to use auto-calculated scrap weight',
        style: TextStyle(
          fontSize: 10,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
    ),
  ],
)
```

### Step 6: Fix Weight Reconciliation Calculation
```dart
void _calculateWeightBalance() {
  final inputWeight = double.tryParse(_totalBatchWeightController.text) ?? 0;
  final outputWeight = _totalFinishedWeightKg;
  
  // Use actual scrap if provided, otherwise use calculated
  final actualScrapText = _cuttingWasteController.text.trim();
  final actualScrap = actualScrapText.isEmpty 
    ? 0.0 
    : (double.tryParse(actualScrapText) ?? 0.0);
  
  final expectedScrap = inputWeight - outputWeight;
  final wasteWeight = actualScrap > 0 ? actualScrap : expectedScrap;
  
  if (inputWeight > 0) {
    final balance = _cuttingBatchService.calculateWeightBalance(
      inputWeightKg: inputWeight,
      outputWeightKg: outputWeight,
      wasteWeightKg: wasteWeight,
    );

    setState(() {
      _weightBalance = balance;
      _weightBalanceValid = balance['weightBalanceValid'] as bool;
    });
  }
}
```

### Step 7: Update Validation Logic
```dart
bool _validateForm() {
  // ... existing validation ...
  
  // Remove strict scrap > 0 validation
  // Allow 0 scrap if auto-calculated
  final wasteWeight = double.tryParse(_cuttingWasteController.text) ?? 0;
  final expectedScrap = _calculateExpectedScrap();
  
  if (wasteWeight <= 0 && expectedScrap <= 0) {
    _showError('Scrap weight cannot be zero');
    return false;
  }
  
  // ... rest of validation ...
}
```

---

## 🧪 TESTING SCENARIOS

### Test Case 1: Low Stock Warning
- Stock: 5 BOX
- Required: 6 BOX
- Expected: 
  - ✅ Show "5 BOX" (not "5.0 BOX")
  - ✅ Show red warning banner
  - ✅ Boxes field locked (read-only)
  - ✅ Cannot submit form

### Test Case 2: Sufficient Stock
- Stock: 10 BOX
- Required: 6 BOX
- Expected:
  - ✅ Show "10 BOX"
  - ✅ No warning
  - ✅ Boxes field editable
  - ✅ Can manually change to 7, 8, etc.

### Test Case 3: Auto-Calculated Scrap
- Input: 1140 KG
- Output: 1102.5 KG
- Expected Scrap: 37.5 KG
- Expected:
  - ✅ Show "Expected Scrap: 37.5 KG"
  - ✅ Actual scrap field empty
  - ✅ Difference: 0 KG (0%)

### Test Case 4: Manual Scrap Override
- Input: 1140 KG
- Output: 1102.5 KG
- Expected Scrap: 37.5 KG
- Actual Scrap: 40 KG (user enters)
- Expected:
  - ✅ Show "Expected Scrap: 37.5 KG"
  - ✅ Show "Actual Scrap: 40 KG"
  - ✅ Difference: 2.5 KG (0.22%)

### Test Case 5: Decimal Stock Display
- Stock: 5.5 BOX
- Expected: Show "5.5 BOX" (with decimal)

---

## 📋 SUMMARY OF CHANGES

1. ✅ Stock display: Integer format for whole numbers
2. ✅ Low stock warning: Red banner when stock < required
3. ✅ Conditional boxes lock: Editable only when stock sufficient
4. ✅ Auto-calculate scrap: INPUT - OUTPUT
5. ✅ Manual scrap override: Optional field
6. ✅ Correct reconciliation: Use actual or calculated scrap
7. ✅ Validation: Allow auto-calculated scrap

**Impact**: Better UX, accurate calculations, prevents stock errors
