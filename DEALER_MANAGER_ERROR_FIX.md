# Dealer Manager - Error Analysis & Fix

## Current Errors from Logs

```
ERROR [Sync]: Error pulling sales: [cloud_firestore/permission-denied]
ERROR [Sync]: Payments sync pull failed: [cloud_firestore/permission-denied]
ERROR [Sync]: Error pulling returns: [cloud_firestore/permission-denied]
ERROR [Sync]: Error pulling opening stock: [cloud_firestore/permission-denied]
ERROR [Sync]: Stock ledger sync pull failed: [cloud_firestore/permission-denied]
ERROR [Sync]: Sync Payroll Error: [cloud_firestore/permission-denied]
ERROR [Service]: bootstrapFromFirebase failed: [cloud_firestore/permission-denied]
```

## Root Cause

**Firestore rules NOT deployed yet!** The new rules we created are still in the file but not active on Firebase.

## What Dealer Manager Should Sync

### ✅ Should Sync
1. **users** - Reference data
2. **dealers** - Full access
3. **sales** (dealer only) - Filtered
4. **returns** (dealer only) - Filtered
5. **dispatches** (dealer only) - Filtered
6. **products** - Read for sales
7. **routes** - Reference data
8. **customers** - Reference data
9. **schemes** - For sales

### ❌ Should NOT Sync
1. **payments** - Finance only
2. **opening_stock** - Warehouse only
3. **stock_ledger** - Warehouse only
4. **tanks** - Production only
5. **vehicles** - Fleet only
6. **payroll** - HR only

## Additional Fixes Needed

### 1. Sync Manager - Block Unnecessary Syncs

**File**: `lib/services/sync_manager.dart`

**Add after line where sync methods are called**:

```dart
// In syncAll() method, update conditions:

// Sales - allow for dealer manager
if (canSyncSales()) {
  await runStep('sales', ...);
  
  // Payments - BLOCK for dealer manager
  if (_isAdminLikeRole(effectiveUser.role) || _isManagerLikeRole(effectiveUser.role)) {
    if (effectiveUser.role != UserRole.dealerManager) {  // ✅ ADD THIS CHECK
      await runStep('payments', ...);
    }
  }
}

// Returns - allow for dealer manager
if (canSyncReturns()) {
  await runStep('returns', ...);
}

// Opening stock - BLOCK for dealer manager
if (canSyncWarehouseReferenceData()) {
  if (effectiveUser.role != UserRole.dealerManager) {  // ✅ ADD THIS CHECK
    await runStep('opening_stock', ...);
  }
}

// Stock ledger - BLOCK for dealer manager
if (canSyncStockLedger()) {
  if (effectiveUser.role != UserRole.dealerManager) {  // ✅ ADD THIS CHECK
    await runStep('stock_ledger', ...);
  }
}

// Payroll - already blocked by _canSyncPayroll()
```

### 2. Update Permission Check Methods

**File**: `lib/services/sync_manager.dart`

```dart
// Update these methods:

bool _canSyncStockLedger(UserRole role) {
  return _isAdminLikeRole(role) ||
      _isManagerLikeRole(role) ||
      role == UserRole.salesman;
  // Dealer Manager should NOT sync stock ledger
}

// Should be:
bool _canSyncStockLedger(UserRole role) {
  return _isAdminLikeRole(role) ||
      role == UserRole.salesManager ||
      role == UserRole.productionManager ||
      role == UserRole.dispatchManager ||
      role == UserRole.salesman;
  // Explicitly exclude dealerManager
}
```

## Correct Sync Flow for Dealer Manager

```
INFO [Sync]: Starting Sync for Dealer Manager...
SUCCESS [Sync]: Pulled 17 users from Firebase
SUCCESS [Sync]: Synced dealers (15 records)
SUCCESS [Sync]: Synced sales (dealer sales only - 25 records)
SUCCESS [Sync]: Synced returns (dealer returns only - 5 records)
SUCCESS [Sync]: Synced dispatches (dealer dispatches only - 20 records)
SUCCESS [Sync]: Synced products (read-only)
SUCCESS [Sync]: Synced routes (read-only)
SUCCESS [Sync]: Synced customers (read-only)
INFO [Sync]: Skipping payments sync for Dealer Manager - not authorized
INFO [Sync]: Skipping opening stock for Dealer Manager - not authorized
INFO [Sync]: Skipping stock ledger for Dealer Manager - not authorized
INFO [Sync]: Skipping tank sync for Dealer Manager - not authorized
INFO [Sync]: Skipping vehicle sync for Dealer Manager - not authorized
INFO [Sync]: Skipping payroll sync for Dealer Manager - not authorized
SUCCESS [Sync]: Sync Completed Successfully.
```

## Deployment Steps (IN ORDER)

### Step 1: Deploy Firestore Rules FIRST
```bash
firebase deploy --only firestore:rules
```

**Wait for deployment to complete** (usually 30-60 seconds)

### Step 2: Update Sync Manager Code
Add the checks to block unnecessary syncs for Dealer Manager

### Step 3: Rebuild App
```bash
flutter clean
flutter pub get
flutter run
```

### Step 4: Test
Login as Dealer Manager and verify:
- ✅ No permission errors
- ✅ Only dealer data syncs
- ✅ Can create dealer sales
- ✅ Can view dealers

## Why Errors Are Happening

1. **Rules not deployed** - New Firestore rules are in code but not on Firebase server
2. **Sync trying to access blocked collections** - Need to add explicit checks to skip
3. **Bootstrap service** - Trying to read collections Dealer Manager shouldn't access

## Quick Fix Summary

### Immediate (Deploy Rules)
```bash
firebase deploy --only firestore:rules
```

### Code Changes (Add Checks)
```dart
// Block payments for dealer manager
if (effectiveUser.role != UserRole.dealerManager) {
  await runStep('payments', ...);
}

// Block opening stock for dealer manager
if (effectiveUser.role != UserRole.dealerManager) {
  await runStep('opening_stock', ...);
}

// Block stock ledger for dealer manager
if (effectiveUser.role != UserRole.dealerManager) {
  await runStep('stock_ledger', ...);
}
```

## Expected Result After Fix

```
✅ No permission errors
✅ Dealers sync working
✅ Sales sync working (dealer only)
✅ Returns sync working (dealer only)
✅ Dispatches sync working (dealer only)
✅ Products readable
✅ No vehicle notifications
✅ Can create dealer sales
```
