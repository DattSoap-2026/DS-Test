# Log Audit Report - Critical Issues
**Date**: 2026-02-02  
**User**: store@dattsoap.com (Store Incharge)  
**Status**: 🔴 2 Critical Issues Found

---

## Issue #1: Stock Validation Bypass (CRITICAL)

### Error Log
```
ERROR [Sync]: SalesService.performSync FAILED
Exception: Insufficient allocated stock for acb5c4db-a888-4f33-ba08-fb1eab127094
Available: 0.0, Required: 2.0
```

### Root Cause
Sale creation bypasses stock validation at UI level, fails only during Firestore sync.

### Impact
- ❌ Failed transactions stuck in sync queue
- ❌ Data inconsistency between local and remote
- ❌ Poor user experience (sale appears successful but fails silently)

### Fix Required
**File**: `lib/screens/sales/new_sale_screen.dart`

**Location**: `_addToCart()` method (around line 1050)

**Current Code**:
```dart
if (availableStock <= 0) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Product out of stock'))
  );
  return;
}
```

**Issue**: Check happens only on first add, not on quantity updates

**Required Fix**:
1. Add stock validation in `_updateCartItemQty()` method
2. Add pre-sync validation before `_saveSale()` 
3. Show clear error message to user before attempting save

---

## Issue #2: Firestore Permission Denied (CRITICAL)

### Error Log
```
ERROR: [cloud_firestore/permission-denied] Missing or insufficient permissions
Entity: customers (action: set)
User: Store Incharge
```

### Root Cause
Firestore security rules don't allow Store Incharge to create/update customers.

### Impact
- ❌ Customer data not syncing to Firestore
- ❌ Queue items permanently stuck
- ❌ Data loss risk

### Fix Required
**File**: `firestore.rules` (Backend)

**Current Rules** (assumed):
```javascript
match /customers/{customerId} {
  allow read: if isAuthenticated();
  allow write: if hasRole('admin') || hasRole('salesman');
}
```

**Required Fix**:
```javascript
match /customers/{customerId} {
  allow read: if isAuthenticated();
  allow write: if hasRole('admin') || 
                 hasRole('salesman') || 
                 hasRole('store_incharge');
}
```

**Alternative**: If Store Incharge shouldn't create customers, disable customer creation in UI for this role.

---

## Issue #3: User Profile Lookup Fallback (WARNING)

### Warning Log
```
WARNING: User profile not found by UID (kqBbm1c9AVOfEzpNMBSXV5gQa1w1)
INFO: Attempting fallback lookups for store@dattsoap.com
INFO: Mapped user store@dattsoap.com to role: Store Incharge
```

### Root Cause
User document in Firestore missing or UID mismatch between Auth and Firestore.

### Impact
- ⚠️ Slower authentication (fallback lookup adds latency)
- ⚠️ Potential data inconsistency

### Fix Required
**Action**: Data cleanup

1. Check Firestore `users` collection for UID `kqBbm1c9AVOfEzpNMBSXV5gQa1w1`
2. Ensure document exists with correct email `store@dattsoap.com`
3. If missing, create user document:
```javascript
{
  id: "store@dattsoap.com",
  uid: "kqBbm1c9AVOfEzpNMBSXV5gQa1w1",
  email: "store@dattsoap.com",
  role: "store_incharge",
  name: "Store Incharge",
  // ... other fields
}
```

---

## Issue #4: Sync Queue Retention (INFORMATIONAL)

### Log
```
SUCCESS [Sync]: Sync Queue Processed: 0 success, 2 failed, 0 delayed, 0 permanent
WARNING [Sync]: sync_queue: 2 queue item(s) retained
```

### Status
Expected behavior - failed items retained for retry.

### Action Required
Once Issues #1 and #2 are fixed:
1. Clear failed queue items manually OR
2. Wait for automatic retry (if implemented)

---

## Priority Action Plan

### Immediate (Today)
1. ✅ **Fix Firestore Rules** - Add Store Incharge permission for customers
2. ✅ **Add Stock Validation** - Pre-sync validation in new_sale_screen.dart

### Short Term (This Week)
3. ✅ **Fix User Profile** - Ensure UID mapping is correct in Firestore
4. ✅ **Clear Sync Queue** - Remove failed items after fixes

### Long Term (Next Sprint)
5. ⚠️ **Add Pre-flight Checks** - Validate all data before sync attempt
6. ⚠️ **Improve Error Messages** - Show actionable errors to users
7. ⚠️ **Add Retry Logic** - Automatic retry with exponential backoff

---

## Code Changes Required

### 1. Stock Validation Fix
**File**: `lib/screens/sales/new_sale_screen.dart`

Add before `_saveSale()`:
```dart
bool _validateStockBeforeSave() {
  for (final item in _cart) {
    if (item.isFree) continue;
    final available = _isSalesman
        ? (_salesmanStockMap[item.productId]?.remainingTotal ?? 0.0)
        : item.stock.toDouble();
    
    if (item.quantity > available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.name}: Stock insufficient (Available: $available, Required: ${item.quantity})'
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }
  }
  return true;
}
```

Call in `_saveSale()`:
```dart
Future<void> _saveSale() async {
  // ... existing validation ...
  
  if (!_validateStockBeforeSave()) return; // ADD THIS
  
  // ... rest of save logic ...
}
```

### 2. Firestore Rules Fix
**File**: `firestore.rules`

```javascript
match /customers/{customerId} {
  allow read: if isAuthenticated();
  allow write: if hasRole('admin') || 
                 hasRole('salesman') || 
                 hasRole('store_incharge'); // ADD THIS
}
```

---

## Testing Checklist

After fixes:
- [ ] Store Incharge can create customers without permission error
- [ ] Sale creation fails immediately if stock insufficient
- [ ] User profile loads without fallback warning
- [ ] Sync queue processes successfully (0 failed items)
- [ ] No error logs in console after sync

---

## Conclusion

**Current Status**: 🔴 Production Issues Detected  
**Severity**: HIGH (data loss risk, poor UX)  
**Estimated Fix Time**: 2-4 hours  
**Recommended Action**: Apply fixes immediately before next deployment

---

**Audited By**: Amazon Q Developer  
**Audit Date**: 2026-02-02  
**Next Review**: After fixes applied
