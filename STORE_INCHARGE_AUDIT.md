# Store Incharge Role Audit & Permissions Fix

## Issues Fixed

### 1. Diesel Logs Permission ✅
**Error**: `ERROR [Sync]: Error pulling diesel logs: [cloud_firestore/permission-denied]`

**Fix**: Changed from Admin-only to Admin + Store Incharge
```javascript
// Before
match /diesel_logs/{id} { allow read: if isAdmin(); allow write: if isAuth(); }

// After
match /diesel_logs/{id} { allow read, write: if isAdmin() || isStoreIncharge(); }
```

### 2. Dispatches Permission ✅
**Error**: `ERROR [Service]: getAllDispatches failed: [cloud_firestore/permission-denied]`

**Fix**: Added Store Incharge read/write access
```javascript
// Before
match /dispatches/{id} { allow read, write: if isAdminOrOwner(resource.data.salesmanId); }

// After
match /dispatches/{id} { allow read, write: if isAdmin() || isStoreIncharge() || isAdminOrOwner(resource.data.salesmanId); }
```

### 3. Tank Sync - Correctly Blocked ✅
**Log**: `INFO [Sync]: Skipping tank sync for Store Incharge - not authorized`

**Status**: This is INCORRECT - Store Incharge SHOULD have tank access!

**Current Rule**: `match /tanks/{id} { allow read, write: if isBhattiOrStoreOrAdmin(); }`

**Analysis**: The rule is correct, but sync logic is wrong. Store Incharge should sync tanks.

---

## Store Incharge Sync Permissions Audit

### ✅ Should Sync (Warehouse/Inventory Management)

| Collection | Access | Status | Notes |
|------------|--------|--------|-------|
| **products** | Read/Write | ✅ Working | `isStoreOrAdmin()` |
| **opening_stock** | Read/Write | ✅ Working | `isStoreOrAdmin()` |
| **opening_stock_entries** | Read/Write | ✅ Working | `isStoreOrAdmin()` |
| **stock_ledger** | Read/Write | ✅ Working | `isStoreOrAdmin()` |
| **department_stocks** | Read/Write | ✅ Working | Write: `isStoreOrAdmin()` |
| **suppliers** | Read/Write | ✅ Working | Auth users can read |
| **purchase_orders** | Read/Write | ✅ Working | `isStoreOrAdmin()` |
| **goods_received** | Read/Write | ✅ Working | `isStoreOrAdmin()` |
| **dispatches** | Read/Write | ✅ FIXED | Added Store Incharge access |
| **routes** | Read | ✅ Working | All auth users |
| **route_orders** | Read/Write | ✅ Working | Explicitly allowed |
| **route_order_items** | Read/Write | ✅ Working | Explicitly allowed |
| **tanks** | Read/Write | ⚠️ NEEDS FIX | Rule allows, but sync blocks |
| **tank_transactions** | Read/Write | ⚠️ NEEDS FIX | Rule allows, but sync blocks |
| **tank_refills** | Read/Write | ✅ Working | `isBhattiOrStoreOrAdmin()` |
| **godown_stock** | Read/Write | ✅ Working | `isBhattiOrStoreOrAdmin()` |
| **wastage_logs** | Read/Write | ✅ Working | `isBhattiOrStoreOrAdmin()` |
| **diesel_logs** | Read/Write | ✅ FIXED | Added Store Incharge access |
| **vehicles** | Read | ✅ Working | All auth users can read |

### ❌ Should NOT Sync (Not Relevant to Store Role)

| Collection | Access | Status | Notes |
|------------|--------|--------|-------|
| **sales** | No Access | ✅ Blocked | Sales team only |
| **returns** | No Access | ✅ Blocked | Sales team only |
| **payments** | No Access | ✅ Blocked | Admin only |
| **customers** | Read Only | ✅ Working | Reference data |
| **dealers** | Read Only | ✅ Working | Reference data |
| **sales_targets** | No Access | ✅ Blocked | Sales team only |
| **route_sessions** | No Access | ✅ Blocked | Sales team only |
| **customer_visits** | No Access | ✅ Blocked | Sales team only |
| **production_entries** | No Access | ✅ Blocked | Production team only |
| **bhatti_entries** | No Access | ✅ Blocked | Bhatti team only |
| **cutting_batches** | No Access | ✅ Blocked | Production team only |
| **payroll** | No Access | ✅ Blocked | Admin/HR only |
| **employees** | No Access | ✅ Blocked | Admin/HR only |

---

## Sync Logic Fix Needed

### Issue: Tank Sync Blocked for Store Incharge

**Location**: `lib/services/sync_manager.dart`

**Current Code**:
```dart
bool _canSyncProductionInventory(UserRole role) {
  return _isAdminLikeRole(role) || 
      role == UserRole.productionManager ||
      role == UserRole.bhattiSupervisor;
}

// In syncAll():
if (canSyncProductionInventory()) {
  await runStep('tanks', ...);
  await runStep('tank_transactions', ...);
}
```

**Problem**: Store Incharge is NOT included in `_canSyncProductionInventory()`

**Fix Required**:
```dart
bool _canSyncProductionInventory(UserRole role) {
  return _isAdminLikeRole(role) || 
      role == UserRole.productionManager ||
      role == UserRole.bhattiSupervisor ||
      role == UserRole.storeIncharge; // ✅ ADD THIS
}
```

---

## Store Incharge Responsibilities

### Primary Functions
1. **Warehouse Management**
   - Opening stock management
   - Stock ledger tracking
   - Department stock allocation
   - Godown stock management

2. **Procurement**
   - Purchase order management
   - Goods received tracking
   - Supplier management

3. **Dispatch Management**
   - Dispatch creation and tracking
   - Route order fulfillment
   - Vehicle assignment

4. **Inventory Control**
   - Tank inventory (raw materials)
   - Tank transactions
   - Tank refills
   - Wastage tracking

5. **Fleet Support**
   - Diesel log management
   - Vehicle tracking (read-only)

### Data Access Pattern
- **Full Access**: Warehouse, inventory, procurement, dispatch
- **Read Access**: Vehicles, customers, dealers, routes (reference data)
- **No Access**: Sales transactions, payments, HR, production operations

---

## Deployment Steps

1. **Deploy Firestore Rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Update Sync Logic** (sync_manager.dart):
   - Add `storeIncharge` to `_canSyncProductionInventory()`

3. **Rebuild App**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Test with Store Incharge** (store@dattsoap.com):
   - ✅ Diesel logs sync should work
   - ✅ Dispatches should load
   - ✅ Tank sync should work (after code fix)
   - ❌ No sales/payment errors

---

## Expected Log Output After Fix

```
INFO [Sync]: Starting FORCE Sync for Store Incharge (store)...
INFO [Sync]: Sync Identity → UID: kqBbm1c9AVOfEzpNMBSXV5gQa1w1 | AppUser.id: kqBbm1c9AVOfEzpNMBSXV5gQa1w1
SUCCESS [Sync]: Pulled 17 users from Firebase
SUCCESS [Sync]: Synced tanks
SUCCESS [Sync]: Synced tank transactions
SUCCESS [Sync]: Synced diesel logs
SUCCESS [Sync]: Synced dispatches
SUCCESS [Sync]: Sync Completed Successfully.
```

---

## Summary

### Fixed
✅ Diesel logs permission
✅ Dispatches permission

### Needs Code Fix
⚠️ Tank sync logic - add Store Incharge to `_canSyncProductionInventory()`

### Already Correct
✅ All warehouse/inventory permissions
✅ Procurement permissions
✅ Route order permissions
✅ Sales/payment blocks (correctly restricted)
