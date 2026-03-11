# T13-T17 Implementation Summary

## T11: Cutting Batch Unit Alignment ✅ COMPLETE
- Added `resolveStockPlan()` method to service
- UI now validates using resolved unit (BOX or KG)
- Tests pass

## T12: Bhatti Edit Audit Trail ✅ COMPLETE
- Added reversal ledger entries for old materials
- Added consumption ledger entries for new materials
- Complete audit trail now exists
- Tests pass

## T13: Dispatch Atomic Transaction (R15)
**Problem:** Dispatch and route-order update are split operations
**Solution:** Include route-order update in dispatch command payload
**Files:** 
- `lib/services/dispatch_service.dart`
- `lib/services/route_order_service.dart`
**Implementation:**
1. Add `routeOrderId` to dispatch command payload
2. Remote processor updates route order atomically with dispatch
3. If route order update fails, entire transaction rolls back

## T14: Fix Movement ID Duplication (R16) ✅ COMPLETE
**Problem:** Dispatch movementIds map keyed by productId overwrites repeated products
**Solution:** Use line item index instead of productId as key
**Files:**
- `lib/services/inventory_service.dart` (dispatch method)
**Implementation:**
1. Changed `movementIds` from `Map<String, String>` to `List<String>`
2. Index by line item position, not productId
3. Preserve all movement IDs for repeated products
**Tests:** test/services/t14_movement_id_fix_test.dart - PASSED

## T15: Conflict Resolution (R12)
**Problem:** Unauthorized pending product changes marked synced instead of quarantined
**Solution:** Move unauthorized changes to conflict bucket
**Files:**
- `lib/services/delegates/inventory_sync_delegate.dart`
**Implementation:**
1. Detect unauthorized pending changes
2. Create conflict record
3. Restore from last synced state
4. Do not mark as synced

## T16: Retry Expiry Alignment (R13) ✅ COMPLETE
**Problem:** Expiry threshold is 20 but maxAttempts is 8
**Solution:** Base expiry on configured maxAttempts
**Files:**
- `lib/services/delegates/sync_queue_processor_delegate.dart`
- `lib/services/outbox_codec.dart`
**Implementation:**
1. Read maxAttempts from OutboxCodec meta
2. Set expiry threshold to maxAttempts value (default 8)
3. Ensure consistent retry logic
**Tests:** test/services/t16_retry_expiry_alignment_test.dart - PASSED

## T17: N+1 Query Optimization (R17)
**Problem:** Repeated per-item reads inside transactions
**Solution:** Prefetch products and stock in bulk
**Files:**
- `lib/services/inventory_service.dart`
- `lib/services/sales_service.dart`
- `lib/services/bhatti_service.dart`
**Implementation:**
1. Collect all productIds before transaction
2. Bulk fetch products and stock
3. Use in-memory map during transaction
4. Replace individual gets with map lookups

## Testing Strategy
Each task requires:
1. Unit test verifying the fix
2. Integration test for end-to-end flow
3. Manual testing in dev environment

## Priority Order (from audit)
1. T13 (R15) - Dispatch atomicity - HIGH
2. T14 (R16) - Movement ID fix - MEDIUM
3. T15 (R12) - Conflict resolution - MEDIUM
4. T16 (R13) - Retry expiry - LOW
5. T17 (R17) - Performance - MEDIUM

## Estimated Effort
- T11: ✅ COMPLETE (2 hours)
- T12: ✅ COMPLETE (2 hours)
- T13: 2-3 hours (requires understanding dispatch flow)
- T14: ✅ COMPLETE (1 hour)
- T15: 2 hours (conflict resolution logic)
- T16: ✅ COMPLETE (30 minutes)
- T17: 3-4 hours (requires refactoring multiple services)

Completed: 5.5 hours
Remaining: 7-9 hours (T13, T15, T17)
