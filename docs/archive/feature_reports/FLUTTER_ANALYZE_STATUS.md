# Flutter Analyze Status

## Production Code Status

### ReconciliationService
✅ **CLEAN** - No issues

### Main.dart Issues (5 remaining)

1. **Line 288-289: InventoryMovementEngine constructor**
   - Error: Passing `null` for second parameter
   - Expected: `SyncManager?` (nullable)
   - Issue: Constructor signature mismatch

2. **Line 294: ProductionRepository**
   - Error: Passing `InventoryMovementEngine` but expects `InventoryService`
   - ProductionRepository still uses old InventoryService

3. **Line 301-302: CuttingBatchService**
   - Error: Passing `InventoryService` but expects `InventoryMovementEngine`
   - Too many arguments (4 instead of 3)

### Test Files (Skipped)
- t4_opening_stock_set_balance_test.dart
- t6_production_outbox_test.dart
- t10_lifecycle_simulation_test.dart
- t10_reconciliation_service_test.dart

## Summary

**Production Code:** 1 file clean (ReconciliationService), 1 file with 5 issues (main.dart)

**Root Cause:** Constructor signature mismatches after T9 migration. Services need to be updated to use InventoryMovementEngine instead of InventoryService.

**Next Steps:**
1. Fix InventoryMovementEngine constructor call
2. Update ProductionRepository to use InventoryMovementEngine
3. Fix CuttingBatchService parameters

**Test files can be fixed later as they are not blocking production deployment.**
