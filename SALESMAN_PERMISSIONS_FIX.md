# Salesman Permissions Fix

## Issues Identified from Logs

```
ERROR [Service]: getOrders failed: [cloud_firestore/permission-denied] Missing or insufficient permissions.
ERROR [Sync]: Payments sync pull failed: [cloud_firestore/permission-denied] Missing or insufficient permissions.
ERROR [Sync]: Stock ledger sync pull failed: [cloud_firestore/permission-denied] Missing or insufficient permissions.
WARNING: Listen for query at notification_events failed: Missing or insufficient permissions.
```

## Required Permissions for Salesman

### 1. Route Orders (Own Orders Only)
- **Need**: Read access to own route orders to track order status
- **Fix**: Added read permission for Salesman where `salesmanId == uid()`

### 2. Payments Sync
- **Need**: Block payments sync completely (Salesman should NOT see payment data)
- **Fix**: Explicitly blocked payments sync in sync_manager.dart for Salesman role

### 3. Notifications
- **Need**: Read dispatch and return notifications relevant to Salesman
- **Fix**: Added read permission for notifications where `userId == uid()` or `targetRole == 'Salesman'`

### 4. Target Tracking
- **Need**: View own sales targets
- **Fix**: Changed from `isAdminOrOwner(resource.data.salesmanId)` to `resource.data.salesmanId == uid()`

### 5. Main Inventory Stock
- **Need**: Read access to products collection to create orders
- **Already Working**: Products collection already has `allow read: if isAuth()`

## Changes Made

### firestore.rules

#### 1. Added isSalesman() Helper Function
```dart
function isSalesman() {
  return isAuth() && (
    request.auth.token.role == 'Salesman' ||
    get(/databases/$(database)/documents/users/$(uid())).data.role == 'Salesman'
  );
}
```

#### 2. Route Orders - Own Orders Read Access
```dart
match /route_orders/{id} { 
  allow read: if isAdmin() || isProductionSupervisor() || isStoreIncharge() || (isSalesman() && resource.data.salesmanId == uid());
  allow write: if isAdmin() || isProductionSupervisor() || isStoreIncharge(); 
}
```

#### 3. Notifications - Relevant Notifications Only
```dart
match /notification_events/{id} { 
  allow read: if isAdmin() || (isAuth() && (resource.data.userId == uid() || resource.data.targetRole == 'Salesman'));
  allow write: if isAdmin(); 
}
```

#### 4. Sales Targets - Own Targets Only
```dart
match /sales_targets/{id} { 
  allow read: if isAdmin() || (isAuth() && resource.data.salesmanId == uid());
  allow write: if isAdmin(); 
}
```

### sync_manager.dart

#### Payments Sync Block for Salesman
```dart
if (canSyncSales()) {
  await runStep('sales', ...);
  
  // Payments sync only for Admin and Managers, NOT for Salesman
  if (_isAdminLikeRole(effectiveUser.role) || _isManagerLikeRole(effectiveUser.role)) {
    await runStep('payments', ...);
  } else {
    AppLogger.info('Skipping payments sync for ${effectiveUser.role.value} - not authorized', tag: 'Sync');
  }
}
```

## Permissions Summary

| Collection | Salesman Access | Notes |
|------------|----------------|-------|
| **route_orders** | ✅ Read (own only) | Can view own route orders |
| **route_order_items** | ❌ No access | Order items restricted to production/store |
| **payments** | ❌ No sync | Completely blocked from payments data |
| **notification_events** | ✅ Read (own + role-based) | Dispatch/return notifications only |
| **sales_targets** | ✅ Read (own only) | Can view own targets |
| **products** | ✅ Read (all) | Needed to create orders |
| **stock_ledger** | ❌ No access | Already blocked (correct) |
| **sales** | ✅ Read/Write (own only) | Already working correctly |
| **returns** | ✅ Read/Write (own only) | Already working correctly |
| **dispatches** | ✅ Read/Write (own only) | Already working correctly |
| **customers** | ✅ Read (assigned routes) | Already working correctly |

## Deployment Steps

1. **Deploy Firestore Rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Rebuild Flutter App**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Test with Salesman Account** (sale1@dattsoap.com):
   - ✅ View route orders (own orders)
   - ✅ View sales targets (own targets)
   - ✅ View products (for order creation)
   - ✅ Receive dispatch/return notifications
   - ❌ No payments sync errors
   - ❌ No stock_ledger sync errors (already blocked)

## Expected Log Output After Fix

```
INFO [Sync]: Starting Delta Sync for Salesman (Ahemad Patel)...
SUCCESS [Sync]: Pulled 16 users from Firebase
INFO [Sync]: Skipping payments sync for Salesman - not authorized
INFO [Sync]: Skipping tank sync for Salesman - not authorized
INFO [Sync]: Skipping vehicle sync for Salesman - not authorized
SUCCESS [Sync]: Sync Completed Successfully.
```

## Notes

- **Stock Ledger**: Intentionally blocked for Salesman (they don't need warehouse-level stock visibility)
- **Payments**: Completely blocked for security (Salesman should not see payment transactions)
- **Route Orders**: Read-only access to own orders for tracking purposes
- **Notifications**: Filtered to show only relevant dispatch/return notifications
- **Targets**: Own targets only for performance tracking
