# T11: Fix Cutting Batch Unit Mismatch (R8)

## Problem Statement
UI validates semi-finished stock in `BOX` unit, but service may consume in `Kg`, `Box`, or fallback weight depending on product metadata. This causes the screen to appear valid while real stock consumption is different.

## Root Cause
- UI: Lines 685-695 in `cutting_batch_entry_screen.dart` validate stock in BOX
- Service: `cutting_batch_service.dart` resolves consumption unit dynamically
- No synchronization between UI validation and service consumption

## Acceptance Criteria
1. Service exposes a method to resolve stock plan before submission
2. UI calls this method and displays the resolved unit and quantity
3. Stock validation uses the same unit as service consumption
4. User sees exact unit that will be consumed (BOX or KG)

## Implementation Plan

### Step 1: Add Stock Plan Resolution Method to Service
```dart
// In cutting_batch_service.dart
Future<Map<String, dynamic>> resolveStockPlan({
  required String semiFinishedProductId,
  required int boxesCount,
}) async {
  // Returns: {
  //   'consumptionUnit': 'BOX' or 'KG',
  //   'consumptionQuantity': double,
  //   'availableStock': double,
  //   'isAvailable': bool,
  // }
}
```

### Step 2: Update UI to Use Resolved Plan
- Call `resolveStockPlan()` when boxes count changes
- Display resolved unit in stock validation message
- Use resolved quantity for availability check

### Step 3: Write Unit Test
- Test BOX-based products
- Test KG-based products
- Test products with missing metadata

## Files to Modify
1. `lib/services/cutting_batch_service.dart` - Add resolveStockPlan method
2. `lib/screens/production/cutting_batch_entry_screen.dart` - Use resolved plan
3. `test/services/cutting_batch_service_test.dart` - Add unit tests

## Testing Checklist
- [ ] BOX-based semi-finished product shows "Required: X BOX, Available: Y BOX"
- [ ] KG-based semi-finished product shows "Required: X KG, Available: Y KG"
- [ ] Stock validation matches actual service consumption
- [ ] Unit tests pass

## Git Branch
`fix/T11-cutting-batch-unit`
