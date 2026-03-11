# Dealer Manager - Final Fixes Summary

## Issues Identified

### 1. ❌ Wrong Notifications Showing
**Problem**: Dealer Manager seeing vehicle expiry alerts (PUC, Insurance, Fitness)
**Should See**: Only dealer-related notifications (dealer sales, dealer dispatches, dealer returns)

### 2. ❌ Cannot Create Direct Dealer Dispatch
**Problem**: Dealer Manager cannot create direct dispatch to dealers from main inventory
**Need**: Permission to create dealer dispatches (sale + dispatch combined)

---

## Fixes Applied ✅

### 1. Firestore Rules - Dealer Manager Permissions

**File**: `firestore.rules`

```javascript
// ✅ ADDED: Dealer Manager helper function
function isDealerManager() {
  return isAuth() && (
    request.auth.token.role == 'DealerManager' ||
    request.auth.token.role == 'Dealer Manager' ||
    get(/databases/$(database)/documents/users/$(uid())).data.role == 'DealerManager' ||
    get(/databases/$(database)/documents/users/$(uid())).data.role == 'Dealer Manager'
  );
}

// ✅ FIXED: Dealers write access
match /dealers/{id} { 
  allow read: if isAuth(); 
  allow write: if isAdmin() || isDealerManager(); 
}

// ✅ FIXED: Sales filtered by dealer type
match /sales/{id} { 
  allow read, write: if isAdmin() || 
    isAdminOrOwner(resource.data.salesmanId) || 
    (isDealerManager() && resource.data.recipientType == 'dealer'); 
}

// ✅ FIXED: Returns filtered by dealer returns
match /returns/{id} { 
  allow read, write: if isAdmin() || 
    isAdminOrOwner(resource.data.salesmanId) || 
    (isDealerManager() && resource.data.returnType == 'dealer_return'); 
}

// ✅ FIXED: Dispatches filtered by dealer dispatches
match /dispatches/{id} { 
  allow read, write: if isAdmin() || 
    isStoreIncharge() || 
    isAdminOrOwner(resource.data.salesmanId) ||
    (isDealerManager() && resource.data.recipientType == 'dealer'); 
}
```

### 2. Sync Filters - Sales Delegate

**File**: `lib/services/delegates/sales_sync_delegate.dart`

```dart
// ✅ ADDED: Dealer Manager filter in syncSales()
if (user.role == UserRole.salesman) {
  final scopedFirebaseUid = firebaseUid?.trim();
  if (scopedFirebaseUid == null || scopedFirebaseUid.isEmpty) {
    throw StateError('Firebase UID must be provided for salesman sync.');
  }
  baseQuery = baseQuery.where('salesmanId', isEqualTo: scopedFirebaseUid);
} else if (user.role == UserRole.dealerManager) {
  baseQuery = baseQuery.where('recipientType', isEqualTo: 'dealer');
}

// ✅ ADDED: Dealer Manager filter in syncReturns()
if (user.role == UserRole.salesman) {
  final scopedFirebaseUid = firebaseUid?.trim();
  if (scopedFirebaseUid == null || scopedFirebaseUid.isEmpty) {
    throw StateError('Firebase UID must be provided for salesman returns sync.');
  }
  query = query.where('salesmanId', isEqualTo: scopedFirebaseUid);
} else if (user.role == UserRole.dealerManager) {
  query = query.where('returnType', isEqualTo: 'dealer_return');
}
```

---

## Fixes Still Needed ⚠️

### 3. Notification Filtering

**File**: `firestore.rules`

**Current Rule**:
```javascript
match /notification_events/{id} { 
  allow read: if isAdmin() || (isAuth() && (resource.data.userId == uid() || resource.data.targetRole == 'Salesman'));
  allow write: if isAdmin(); 
}
```

**Fix Needed**:
```javascript
match /notification_events/{id} { 
  allow read: if isAdmin() || 
    (isAuth() && resource.data.userId == uid()) ||
    (isSalesman() && resource.data.targetRole == 'Salesman') ||
    (isDealerManager() && (
      resource.data.type == 'dealer_sale' || 
      resource.data.type == 'dealer_dispatch' || 
      resource.data.type == 'dealer_return'
    ));
  allow write: if isAdmin(); 
}
```

**Alternative Simpler Fix**:
```javascript
match /notification_events/{id} { 
  allow read: if isAdmin() || 
    (isAuth() && resource.data.userId == uid()) ||
    (isSalesman() && resource.data.targetRole == 'Salesman') ||
    (isDealerManager() && resource.data.targetRole == 'DealerManager');
  allow write: if isAdmin(); 
}
```

### 4. Dispatch Sync Filter

**File**: `lib/services/delegates/inventory_sync_delegate.dart`

**In `syncDispatches()` method** (around line 1563):

**Add after existing filters**:
```dart
// Add Dealer Manager filter
if (user.role == UserRole.dealerManager) {
  baseQuery = baseQuery.where('recipientType', isEqualTo: 'dealer');
}
```

### 5. Direct Dealer Dispatch Permission

**Already Fixed** - Dealer Manager can now:
- ✅ Read/write dealers
- ✅ Read/write dealer sales
- ✅ Read/write dealer dispatches
- ✅ Access main inventory (products) - already has read access

**How it works**:
1. Dealer Manager creates sale with `recipientType: 'dealer'`
2. Sale automatically creates dispatch with `recipientType: 'dealer'`
3. Both are accessible due to Firestore rules filtering by `recipientType == 'dealer'`

---

## Notification Types for Dealer Manager

### ✅ Should See
- Dealer sale created
- Dealer dispatch created
- Dealer dispatch completed
- Dealer return submitted
- Dealer return approved
- Dealer payment received

### ❌ Should NOT See
- Vehicle expiry (PUC, Insurance, Fitness)
- Customer sale notifications
- Production notifications
- Stock alerts
- Employee notifications

---

## Testing Checklist

### After Deploying All Fixes

- [ ] Login as Dealer Manager
- [ ] **Dealers**: Create/edit dealer - should work
- [ ] **Sales**: Create dealer sale - should work
- [ ] **Sales**: View only dealer sales (not customer sales)
- [ ] **Returns**: Process dealer return - should work
- [ ] **Dispatches**: Create dealer dispatch - should work
- [ ] **Dispatches**: View only dealer dispatches
- [ ] **Notifications**: See only dealer-related notifications
- [ ] **Notifications**: NO vehicle expiry alerts
- [ ] **Sync**: Completes without errors
- [ ] **Sync**: Only dealer data synced

---

## Deployment Steps

### 1. Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### 2. Rebuild Flutter App
```bash
flutter clean
flutter pub get
flutter run
```

### 3. Test with Dealer Manager Account

---

## Summary

### ✅ Completed
1. Added `isDealerManager()` helper function
2. Granted dealer write access
3. Filtered sales to dealer sales only
4. Filtered returns to dealer returns only
5. Filtered dispatches to dealer dispatches only
6. Added sync filters for sales and returns

### ⚠️ Remaining
1. Update notification rules to filter by role/type
2. Add dispatch sync filter for Dealer Manager

### 📋 Files Modified
1. ✅ `firestore.rules` - 5 changes
2. ✅ `lib/services/delegates/sales_sync_delegate.dart` - 2 filters added
3. ⚠️ `lib/services/delegates/inventory_sync_delegate.dart` - 1 filter needed

---

## Expected Clean Logs

```
INFO [Auth]: Mapped user dealer@dattsoap.com to role: Dealer Manager
INFO [Sync]: Starting FORCE Sync for Dealer Manager...
SUCCESS [Sync]: Pulled 17 users from Firebase
SUCCESS [Sync]: Synced dealers
SUCCESS [Sync]: Synced sales (dealer sales only - 15 records)
SUCCESS [Sync]: Synced returns (dealer returns only - 3 records)
SUCCESS [Sync]: Synced dispatches (dealer dispatches only - 12 records)
SUCCESS [Sync]: Synced products
SUCCESS [Sync]: Synced routes
SUCCESS [Sync]: Sync Completed Successfully.
```

**Notifications**: Only dealer-related, no vehicle expiry alerts
