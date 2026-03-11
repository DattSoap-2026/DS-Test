# Production Supervisor Permission Fixes

## Current Issues

Production Supervisor (sona@dattsoap.com) is getting permission-denied errors for:
1. ✅ `route_orders` - FIXED in code, needs Firestore rules deployment
2. ❌ `alerts` - Expected (Admin only)
3. ❌ `notification_events` - Expected (Admin only)

## Fixes Applied in Code

### 1. Firestore Rules Updated (`firestore.rules`)
```javascript
// BEFORE
match /route_orders/{id} { allow read, write: if isAdmin(); }

// AFTER  
match /route_orders/{id} { 
  allow read, write: if isAdmin() || isProductionSupervisor() || isStoreIncharge(); 
}
```

### 2. Sync Manager Updated (`sync_manager.dart`)
```dart
// BEFORE
if (_isAdminLikeRole(effectiveUser.role)) {
  await runStep('route_orders', ...);
}

// AFTER
if (_isAdminLikeRole(effectiveUser.role) || 
    effectiveUser.role == UserRole.productionSupervisor ||
    effectiveUser.role == UserRole.storeIncharge) {
  await runStep('route_orders', ...);
}
```

## ⚠️ IMPORTANT: Firestore Rules Deployment Required

The Firestore rules changes are in `firestore.rules` file but **NOT YET DEPLOYED** to Firebase.

### To Deploy Firestore Rules:

**Option 1: Firebase Console (Recommended)**
1. Go to https://console.firebase.google.com
2. Select your project
3. Go to **Firestore Database** → **Rules** tab
4. Copy the updated rules from `firestore.rules` file
5. Click **Publish**

**Option 2: Firebase CLI**
```bash
firebase deploy --only firestore:rules
```

## Production Supervisor Pages & Required Permissions

### Pages Production Supervisor Can Access:
1. ✅ **Dashboard** (`/dashboard`)
2. ✅ **Production Dashboard** (`/dashboard/production`) - Landing page
3. ✅ **Production Logs** (`/dashboard/production/logs`)
4. ✅ **Production Entries** (`/dashboard/production/entries`)
5. ✅ **Cutting Batches** (`/dashboard/production/cutting`)
6. ✅ **Route Orders** (`/dashboard/orders/route-management`) - NEEDS FIRESTORE RULES DEPLOYMENT
7. ✅ **Inventory Overview** (`/dashboard/inventory/stock-overview`)
8. ✅ **Products** (`/dashboard/management/products`) - Read only
9. ✅ **Reports** (`/dashboard/reports`)

### Collections Production Supervisor Can Sync:
- ✅ `users` (read-only)
- ✅ `products` (read-only)
- ✅ `route_orders` ⚠️ (needs Firestore rules deployment)
- ✅ `production_entries`
- ✅ `production_logs`
- ✅ `detailed_production_logs`
- ✅ `cutting_batches`
- ✅ `bhatti_entries`
- ✅ `tanks`
- ✅ `tank_transactions`
- ✅ `inventory` (stock overview)

### Collections Production Supervisor CANNOT Sync (Expected):
- ❌ `alerts` - Admin only (warning is normal)
- ❌ `notification_events` - Admin only (warning is normal)
- ❌ `duty_sessions` - Admin only
- ❌ `sales_targets` - Admin only
- ❌ `sales` - Sales roles only
- ❌ `dispatches` - Sales/Store roles only
- ❌ `payroll` - Admin only

## Expected Behavior After Firestore Rules Deployment

### ✅ Should Work:
```
INFO [Sync]: Starting FORCE Sync for Production Supervisor...
SUCCESS [Sync]: Pulled 16 users from Firebase
SUCCESS [Sync]: Pulled route orders from Firebase  ← This will work
SUCCESS [Sync]: Sync Completed Successfully.
```

### ⚠️ Expected Warnings (Normal):
```
WARNING [AlertService]: Alerts collection permission-denied. Backoff for 10 minutes.
```
This is NORMAL and EXPECTED for non-admin users.

## Testing Checklist

After deploying Firestore rules:

- [ ] Login as Production Supervisor (sona@dattsoap.com)
- [ ] Check sync logs - should see SUCCESS for route_orders
- [ ] Navigate to Route Orders page - should load without errors
- [ ] Can view route orders list
- [ ] Can mark orders as ready for production
- [ ] Can view production dashboard
- [ ] Can access all production-related pages
- [ ] Alerts warning still appears (this is normal)

## Summary

**Code Changes**: ✅ Complete
**Firestore Rules**: ⚠️ Need deployment
**Expected Result**: Production Supervisor can access route orders after Firestore rules are deployed

**Action Required**: Deploy Firestore rules using Firebase Console or CLI
