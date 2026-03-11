# Dealer Manager - Remaining Errors Analysis

## Errors from Logs

### 1. ✅ Working (No Errors)
```
SUCCESS [Sync]: Pulled 17 users from Firebase
INFO [Sync]: Skipping payments sync for Dealer Manager - not authorized
INFO [Sync]: Skipping tank sync for Dealer Manager - not authorized
INFO [Sync]: Skipping opening stock for Dealer Manager - not authorized
INFO [Sync]: Skipping stock ledger for Dealer Manager - not authorized
INFO [Sync]: Skipping vehicle sync for Dealer Manager - not authorized
```

### 2. ❌ Still Failing

#### Error 1: Payroll Sync
```
ERROR [Sync]: Sync Payroll Error: [cloud_firestore/permission-denied]
```
**Cause**: Dealer Manager trying to sync payroll (HR data)
**Fix**: Block payroll sync for Dealer Manager

#### Error 2: Bootstrap Service
```
ERROR [Service]: bootstrapFromFirebase failed: [cloud_firestore/permission-denied]
```
**Cause**: Some service trying to read unauthorized collections
**Fix**: Need to check which service and what it's trying to read

#### Error 3: Route Orders
```
ERROR [Service]: getOrders failed: [cloud_firestore/permission-denied]
```
**Cause**: Dealer Manager trying to access route_orders
**Fix**: Grant read access to route_orders OR block the page

---

## Root Causes

### Issue 1: Payroll Sync Not Blocked
**File**: `lib/services/sync_manager.dart`

Payroll sync is running for Dealer Manager but should be blocked.

**Current code** (around line with payroll sync):
```dart
if (_canSyncPayroll(effectiveUser.role)) {
  await runStep('sync_payrolls', ...);
}
```

**Check `_canSyncPayroll()` method**:
```dart
bool _canSyncPayroll(UserRole role) {
  return _isAdminLikeRole(role) || _isManagerLikeRole(role);
}
```

**Problem**: `_isManagerLikeRole()` includes `dealerManager`!

```dart
bool _isManagerLikeRole(UserRole role) {
  return role == UserRole.salesManager ||
      role == UserRole.productionManager ||
      role == UserRole.dealerManager ||  // ❌ This is the problem!
      role == UserRole.dispatchManager;
}
```

### Issue 2: Route Orders Permission
**File**: `firestore.rules`

**Current rule**:
```javascript
match /route_orders/{id} { 
  allow read: if isAdmin() || isProductionSupervisor() || isStoreIncharge() || (isSalesman() && resource.data.salesmanId == uid());
  allow write: if isAdmin() || isProductionSupervisor() || isStoreIncharge(); 
}
```

**Problem**: Dealer Manager not included in read access

### Issue 3: Bootstrap Service
Need to identify which service is calling `bootstrapFromFirebase()`

---

## Fixes Required

### Fix 1: Block Payroll for Dealer Manager

**File**: `lib/services/sync_manager.dart`

**Option A: Update `_canSyncPayroll()` method**:
```dart
bool _canSyncPayroll(UserRole role) {
  return _isAdminLikeRole(role) || 
      role == UserRole.salesManager ||
      role == UserRole.productionManager ||
      role == UserRole.dispatchManager;
  // Explicitly exclude dealerManager
}
```

**Option B: Add check in sync call**:
```dart
if (_canSyncPayroll(effectiveUser.role)) {
  if (effectiveUser.role != UserRole.dealerManager) {
    await runStep('sync_payrolls', ...);
  } else {
    AppLogger.info('Skipping payroll sync for Dealer Manager - not authorized', tag: 'Sync');
  }
}
```

### Fix 2: Route Orders Permission

**File**: `firestore.rules`

**Option A: Grant read access to Dealer Manager**:
```javascript
match /route_orders/{id} { 
  allow read: if isAdmin() || isProductionSupervisor() || isStoreIncharge() || isDealerManager() || (isSalesman() && resource.data.salesmanId == uid());
  allow write: if isAdmin() || isProductionSupervisor() || isStoreIncharge(); 
}
```

**Option B: Block the page for Dealer Manager** (if they don't need it):
Remove "Route Orders" from Dealer Manager's navigation menu.

### Fix 3: Notification Still Not Fixed

**Check**: Did you deploy the rules?
```bash
firebase deploy --only firestore:rules
```

**Verify**: Check Firebase Console → Firestore → Rules
- Look for "Last published" timestamp
- Should be recent (within last few minutes)

**If rules are deployed but still showing vehicle notifications**:
The notifications were created BEFORE the rule change. They still exist in the database.

**Solution**: Clear old notifications OR wait for them to expire

---

## Step-by-Step Fix

### Step 1: Fix Payroll Sync

**File**: `lib/services/sync_manager.dart`

Find the `_canSyncPayroll()` method and update:

```dart
bool _canSyncPayroll(UserRole role) {
  return _isAdminLikeRole(role) || 
      role == UserRole.salesManager ||
      role == UserRole.productionManager ||
      role == UserRole.dispatchManager;
}
```

### Step 2: Fix Route Orders

**File**: `firestore.rules`

Update route_orders rule:

```javascript
match /route_orders/{id} { 
  allow read: if isAdmin() || isProductionSupervisor() || isStoreIncharge() || isDealerManager() || (isSalesman() && resource.data.salesmanId == uid());
  allow write: if isAdmin() || isProductionSupervisor() || isStoreIncharge(); 
}
```

### Step 3: Deploy Rules Again

```bash
firebase deploy --only firestore:rules
```

### Step 4: Clear Old Notifications (Optional)

**Option A: Delete from Firebase Console**
- Go to Firestore
- Find `notification_events` collection
- Delete vehicle expiry notifications for Dealer Manager

**Option B: Add expiry to notifications**
Notifications should have `expiresAt` field and auto-delete after some time.

### Step 5: Rebuild App

```bash
flutter clean
flutter pub get
flutter run
```

---

## Expected Clean Logs After Fix

```
INFO [Auth]: Mapped user dealer@dattsoap.com to role: Dealer Manager
INFO [Sync]: Starting FORCE Sync for Dealer Manager...
SUCCESS [Sync]: Pulled 17 users from Firebase
SUCCESS [Sync]: Synced dealers
SUCCESS [Sync]: Synced sales (dealer sales only)
SUCCESS [Sync]: Synced returns (dealer returns only)
SUCCESS [Sync]: Synced dispatches (dealer dispatches only)
INFO [Sync]: Skipping payments sync for Dealer Manager - not authorized
INFO [Sync]: Skipping tank sync for Dealer Manager - not authorized
INFO [Sync]: Skipping opening stock for Dealer Manager - not authorized
INFO [Sync]: Skipping stock ledger for Dealer Manager - not authorized
INFO [Sync]: Skipping vehicle sync for Dealer Manager - not authorized
INFO [Sync]: Skipping payroll sync for Dealer Manager - not authorized
SUCCESS [Sync]: Synced products
SUCCESS [Sync]: Synced routes
SUCCESS [Sync]: Synced route orders
SUCCESS [Sync]: Sync Completed Successfully.
```

---

## Summary

### Remaining Issues
1. ❌ Payroll sync not blocked
2. ❌ Route orders permission denied
3. ⚠️ Old notifications still visible (need to clear)

### Fixes
1. Update `_canSyncPayroll()` to exclude Dealer Manager
2. Add Dealer Manager to route_orders read permission
3. Deploy rules again
4. Clear old notifications (optional)
5. Rebuild app

### Files to Modify
1. `lib/services/sync_manager.dart` - Fix payroll check
2. `firestore.rules` - Add route_orders permission
3. Deploy and rebuild
