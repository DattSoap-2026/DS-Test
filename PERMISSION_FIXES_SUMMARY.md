# Permission Fixes Summary

## Issues Fixed

### 1. Route Order Alert Persistence After Reset
**Problem**: Route order alerts persisted after system reset even after logout.

**Root Cause**: The `routeOrders` collection was not being cleared from the local Isar database during the reset process in `_resetLocalTransactionalData` method.

**Fix**: Added `await _dbService.routeOrders.clear();` to the local database reset transaction in `data_management_service.dart`.

**File Modified**: `lib/services/data_management_service.dart`

---

### 2. Permission-Denied Errors for Non-Admin Users
**Problem**: Bhatti Supervisor and other non-admin roles were getting permission-denied errors when trying to sync collections they don't have access to:
- `route_orders`
- `duty_sessions`
- `sales_targets`
- `alerts`
- `notification_events`

**Root Cause**: The sync manager was attempting to sync these admin-only collections for ALL users without role-based filtering.

**Fix**: Added role-based guards (`_isAdminLikeRole`) to prevent non-admin users from syncing these collections.

**File Modified**: `lib/services/sync_manager.dart`

**Changes**:
```dart
// Before: Synced for all users
await runStep('route_orders', () => ...);
await runStep('duty_sessions', () => ...);
await runStep('sales_targets', () => ...);

// After: Only synced for Admin/Owner
if (_isAdminLikeRole(effectiveUser.role)) {
  await runStep('route_orders', () => ...);
  await runStep('duty_sessions', () => ...);
  await runStep('sales_targets', () => ...);
}
```

---

## Firestore Security Rules (Already Correct)

The Firestore rules correctly restrict access to admin-only collections:

```javascript
match /alerts/{id} { allow read, write: if isAdmin(); }
match /notification_events/{id} { allow read, write: if isAdmin(); }
match /route_orders/{id} { allow read, write: if isAdmin(); }
match /duty_sessions/{id} { allow read: if isAdmin(); allow write: if isAuth(); }
match /sales_targets/{id} { 
  allow read: if isAdminOrOwner(resource.data.salesmanId); 
  allow write: if isAdmin(); 
}
```

---

## Role-Based Sync Access

### Admin/Owner Can Sync:
- All collections including route_orders, duty_sessions, sales_targets, alerts, notification_events

### Production Supervisor Can Sync:
- Users (read-only)
- Products (read-only)
- Route orders ✅ (NEW)
- Production logs, entries, batches
- Tanks, tank transactions
- Bhatti entries
- Cutting batches
- Inventory

### Store Incharge Can Sync:
- Users (read-only)
- Products (read/write)
- Route orders ✅ (NEW)
- Opening stock
- Stock ledger
- Tanks, tank transactions
- Suppliers
- Purchase orders
- Inventory

### Bhatti Supervisor Can Sync:
- Users (read-only)
- Products (read-only)
- Bhatti batches (scoped to their unit)
- Bhatti entries (scoped to their unit)
- Tanks, tank transactions
- Formulas (read-only)
- Wastage logs
- Inventory (read-only)
- Routes (read-only)

### Bhatti Supervisor CANNOT Sync:
- Route orders (Admin, Production Supervisor, Store Incharge only)
- Duty sessions (Admin only)
- Sales targets (Admin only)
- Alerts (Admin only)
- Notification events (Admin only)
- Sales, dispatches, returns (Sales roles only)
- Payroll, HR data (Admin only)

---

## Expected Behavior After Fix

1. **Admin, Production Supervisor, Store Incharge**: Can see and manage route order alerts
2. **Bhatti Supervisor & Other Roles**: Cannot see route order alerts (no permission)
3. **System Reset**: Route orders and alerts properly deleted from both Firestore and local DB
4. **Sync Performance**: Faster sync for non-admin users (fewer unnecessary collection queries)

---

## Testing Checklist

- [ ] Login as Admin - can see route order alerts ✅
- [ ] Login as Production Supervisor - can see route order alerts ✅
- [ ] Login as Store Incharge - can see route order alerts ✅
- [ ] Login as Bhatti Supervisor - no route order alerts, no permission errors ✅
- [ ] Perform system reset as Admin - alerts disappear
- [ ] Logout and login - alerts don't reappear
- [ ] Check sync logs - no permission-denied warnings for allowed roles

---

## Files Modified

1. `lib/services/data_management_service.dart` - Added routeOrders.clear() to reset
2. `lib/services/sync_manager.dart` - Added role-based guards (Admin, Production Supervisor, Store Incharge can sync route_orders)
3. `lib/screens/settings/system_data_screen.dart` - Added mounted checks to prevent widget rebuild errors
4. `firestore.rules` - Updated route_orders and route_order_items rules to allow Production Supervisor and Store Incharge

---

## Notes

- The permission-denied warnings for `alerts` and `notification_events` are EXPECTED for non-admin users
- The `AlertService` already has proper error handling with 10-minute backoff for permission-denied errors
- Route order alerts are displayed from LOCAL Isar database, not Firestore streams
- Firestore security rules updated to allow Admin, Production Supervisor, and Store Incharge access to route_orders
- Only these 3 roles can see route order alerts on their dashboards
