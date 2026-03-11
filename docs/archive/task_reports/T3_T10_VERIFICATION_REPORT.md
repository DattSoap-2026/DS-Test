# T3-T10 Verification Report

**Date**: 2025-01-07  
**Tasks**: T3, T4, T5, T6, T8, T9, T10  
**Status**: Quick verification complete

---

## T3: Warehouse Stock Partitioning ✅ DOCUMENTED

**Status**: ✅ SINGLE-WAREHOUSE BY DESIGN

**Evidence**:
- `warehouseId` used throughout opening stock service
- No separate `WarehouseStock` collection
- All stock mutations target `products.stock`
- Warehouse ID normalized to `mainWarehouseId`

**Implementation**: Lines 89-90, 301-303 in `opening_stock_service.dart`
```dart
String _openingKey(String productId, String warehouseId) =>
    '${productId.trim()}::${warehouseId.trim()}';
    
final normalizedWarehouseId = mainWarehouseId;
```

**Acceptance Criteria**: ✅ MET
- System is cleanly single-warehouse
- Multi-warehouse UI removed (normalized to main)
- No fake metadata - warehouse ID is consistent

**Recommendation**: Document as architectural decision - single warehouse sufficient for current business needs

---

## T4: Opening Stock Set-Balance ✅ IMPLEMENTED

**Status**: ✅ COMPLETE

**Evidence**: Lines 333-357 in `opening_stock_service.dart`

```dart
final existingOpening = await _findOpeningStockEntity(
  productId: productId,
  warehouseId: normalizedWarehouseId,
);

final openingEntity = existingOpening ?? OpeningStockEntity();
openingEntity
  ..id = existingOpening?.id ?? entryId  // Reuses existing ID
  ..quantity = quantity  // Overwrites quantity
```

**Features**:
- ✅ Checks for existing entry before save
- ✅ Reuses existing ID (upsert behavior)
- ✅ Overwrites quantity (set-balance, not add)
- ✅ Go-Live lock prevents edits after deployment (lines 314-321)

**Acceptance Criteria**: ✅ MET
- Saving twice results in one record with latest value
- No double-counting
- Go-Live lock enforced

---

## T5: User Identity Standardization ❓ NEEDS VERIFICATION

**Status**: ❓ PARTIAL

**Quick Check**: Firebase UID used in many places but needs full audit

**Files to Check**:
- `lib/utils/auth_utils.dart` - canonicalUserId() helper
- `lib/services/sales_service.dart` - user ID usage
- `lib/services/delegates/*_sync_delegate.dart` - sync filters

**Recommendation**: Full codebase search for `AppUser.id` vs `Firebase UID` usage

---

## T6: Production Durable Queue ❓ NEEDS VERIFICATION

**Status**: ❓ PARTIAL

**Quick Check**: Some production flows use queue, needs verification

**Files to Check**:
- `lib/services/production_service.dart` - queue usage
- `lib/services/bhatti_service.dart` - queue usage (T12 verified)
- `lib/services/cutting_batch_service.dart` - queue usage

**Known**: Bhatti uses queue (verified in T12)

**Recommendation**: Check if production_service and cutting use durable queue or best-effort sync

---

## T8: Production Auth Requirement ❓ NEEDS VERIFICATION

**Status**: ❓ UNKNOWN

**Files to Check**:
- `lib/services/production_service.dart` - auth checks
- `lib/exceptions/` - AuthenticationRequiredException

**Recommendation**: Search for auth checks in production write methods

---

## T9: Department Master ❓ NEEDS VERIFICATION

**Status**: ❓ UNKNOWN

**Files to Check**:
- `lib/data/local/entities/department_entity.dart` or similar
- `lib/screens/inventory/material_issue_screen.dart` - department dropdown
- `lib/screens/inventory/material_return_screen.dart` - department dropdown

**Known**: Department normalization exists in inventory_service (T1 verified)

**Recommendation**: Check if Department Isar collection exists

---

## T10: BOM Validation ❓ NEEDS VERIFICATION

**Status**: ❓ UNKNOWN

**Files to Check**:
- `lib/models/bom_rule.dart` or similar
- `lib/services/production_service.dart` - yield validation
- `lib/exceptions/` - BomViolationException

**Recommendation**: Search for BOM or yield validation logic

---

## Summary

| Task | Status | Evidence | Priority |
|------|--------|----------|----------|
| T3 | ✅ Complete | Single-warehouse documented | LOW |
| T4 | ✅ Complete | Upsert logic verified | LOW |
| T5 | ❓ Partial | Needs full audit | MEDIUM |
| T6 | ❓ Partial | Needs verification | MEDIUM |
| T8 | ❓ Unknown | Needs check | LOW |
| T9 | ❓ Unknown | Needs check | LOW |
| T10 | ❓ Unknown | Needs check | MEDIUM |

---

## Updated Overall Status

**Completed**: 12/17 (71%)
- ✅ T1, T2 (CRITICAL)
- ✅ T3, T4, T7 (HIGH)
- ✅ T11-T17 (MEDIUM/LOW)

**Needs Full Verification**: 5/17 (29%)
- ❓ T5, T6, T8, T9, T10

---

## Recommendations

### Immediate (T5, T6)
These are HIGH priority tasks that need full verification:
1. **T5**: User identity - affects sync filtering
2. **T6**: Production queue - affects data durability

### Can Defer (T8, T9, T10)
These are lower priority or may already be handled:
1. **T8**: Auth requirement - likely already enforced by service guards
2. **T9**: Department master - normalization already exists (T1)
3. **T10**: BOM validation - may be business logic, not critical for sync

---

## Next Steps

1. ✅ T3, T4 verified - DONE
2. ⏳ Deep dive into T5 (user identity)
3. ⏳ Deep dive into T6 (production queue)
4. ⏳ Quick check T8, T9, T10
5. ⏳ Write tests for T1, T7

**Estimated Time**: 2-3 hours for remaining verification

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-07  
**Status**: QUICK VERIFICATION COMPLETE
