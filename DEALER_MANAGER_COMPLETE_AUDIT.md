# Dealer Manager (Dealer Incharge) - Complete Role Audit

## Role Overview

**Role Name**: Dealer Manager / Dealer Incharge  
**Primary Function**: Manage dealer network, dealer sales, and dealer dispatches  
**Access Level**: Manager-level access to dealer operations

---

## Accessible Pages & Features

### 1. Dashboard
**Page**: Dealer Dashboard (`/dashboard/dealer`)
**Features**:
- Total revenue (monthly + all-time)
- Active dealers count
- Pending dispatch orders
- Today's orders
- Territory revenue breakdown
- Top performing dealers
- Recent dealer sales
- Monthly sales trend chart

### 2. Dealers Management
**Page**: Dealers Screen (`/dashboard/dealers`)
**Features**:
- View all dealers
- Add new dealer
- Edit dealer details
- Dealer contact information
- Territory assignment
- Commission settings
- Route assignment
- Dealer status management

### 3. Dealer Sales
**Page**: New Dealer Sale Screen (`/dashboard/dealers/new-sale`)
**Features**:
- Create dealer sales orders
- Select dealer
- Add products
- Apply discounts
- Calculate totals
- Generate invoice

### 4. Dealer Dispatch
**Page**: Dealer Dispatch Screen (`/dashboard/dealers/dispatch`)
**Features**:
- View pending dealer dispatches
- Create dispatch for dealer orders
- Assign vehicles
- Track dispatch status
- Dispatch history

### 5. Dealer Reports
**Pages**:
- Dealer Report Screen (`/dashboard/reports/dealers`)
- Dealer Detail History (`/dashboard/reports/dealer-detail`)

**Features**:
- Dealer-wise sales reports
- Territory-wise analysis
- Commission reports
- Payment history
- Outstanding balances

### 6. Sales Management (Dealer Sales Only)
**Access**: Read/Write dealer sales
**Features**:
- View dealer sales
- Edit dealer sales
- Sales history
- Invoice generation

### 7. Returns Management (Dealer Returns)
**Access**: Read/Write dealer returns
**Features**:
- Process dealer returns
- Return approval
- Stock adjustment
- Return history

---

## Firestore Permissions Audit

### ✅ Full Access (Read + Write)

| Collection | Current Rule | Status | Notes |
|------------|-------------|--------|-------|
| **dealers** | `allow read: if isAuth(); allow write: if isAdmin();` | ⚠️ NEEDS FIX | Should allow Dealer Manager write access |
| **sales** (dealer sales) | `allow read, write: if isAdminOrOwner(resource.data.salesmanId);` | ⚠️ PARTIAL | Needs dealer sales filter |
| **returns** (dealer returns) | `allow read, write: if isAdminOrOwner(resource.data.salesmanId);` | ⚠️ PARTIAL | Needs dealer returns filter |
| **dispatches** (dealer) | `allow read, write: if isAdmin() \|\| isStoreIncharge() \|\| isAdminOrOwner(resource.data.salesmanId);` | ⚠️ PARTIAL | Needs dealer dispatch filter |

### 👁️ Read-Only Access

| Collection | Current Rule | Status | Notes |
|------------|-------------|--------|-------|
| **users** | `allow read: if isAuth();` | ✅ Working | Reference data |
| **products** | `allow read: if isAuth();` | ✅ Working | For sales |
| **customers** | `allow read: if isAuth();` | ✅ Working | Reference data |
| **routes** | `allow read: if isAuth();` | ✅ Working | For assignment |
| **vehicles** | `allow read: if isAuth();` | ✅ Working | For dispatch |
| **schemes** | `allow read: if isAuth();` | ✅ Working | For sales |

### ❌ No Access (Correctly Blocked)

| Collection | Reason |
|------------|--------|
| **stock_ledger** | Warehouse operations |
| **opening_stock** | Warehouse operations |
| **tanks** | Production operations |
| **bhatti_entries** | Production operations |
| **production_entries** | Production operations |
| **payroll** | HR operations |
| **employees** | HR operations |
| **payments** | Finance operations |
| **diesel_logs** | Fleet operations |

---

## Sync Permissions Audit

### Current Sync Logic

**Location**: `lib/services/sync_manager.dart`

```dart
bool _canSyncDealers(UserRole role) {
  return _isAdminLikeRole(role) || _isManagerLikeRole(role);
}

bool _isManagerLikeRole(UserRole role) {
  return role == UserRole.salesManager ||
      role == UserRole.productionManager ||
      role == UserRole.dealerManager ||  // ✅ Included
      role == UserRole.dispatchManager;
}
```

### ✅ Should Sync (Currently Working)

| Collection | Sync Method | Status | Notes |
|------------|-------------|--------|-------|
| **users** | `syncUsers()` | ✅ Working | All roles |
| **dealers** | `syncDealers()` | ✅ Working | Manager roles |
| **products** | `syncInventory()` | ✅ Working | All roles |
| **routes** | `syncRoutes()` | ✅ Working | Warehouse roles |
| **schemes** | Master data | ✅ Working | All roles |

### ⚠️ Needs Filtering

| Collection | Issue | Fix Needed |
|------------|-------|------------|
| **sales** | Syncs all sales | Filter dealer sales only |
| **returns** | Syncs all returns | Filter dealer returns only |
| **dispatches** | Syncs all dispatches | Filter dealer dispatches only |

### ❌ Should NOT Sync (Correctly Blocked)

| Collection | Status | Notes |
|------------|--------|-------|
| **stock_ledger** | ✅ Blocked | Not in sync logic |
| **tanks** | ✅ Blocked | Production only |
| **bhatti_entries** | ✅ Blocked | Production only |
| **diesel_logs** | ✅ Blocked | Fleet only |
| **payroll** | ✅ Blocked | HR only |

---

## Required Fixes

### 1. Firestore Rules - Dealer Write Access

**File**: `firestore.rules`

```javascript
// ADD Dealer Manager helper function
function isDealerManager() {
  return isAuth() && (
    request.auth.token.role == 'DealerManager' ||
    request.auth.token.role == 'Dealer Manager' ||
    get(/databases/$(database)/documents/users/$(uid())).data.role == 'DealerManager' ||
    get(/databases/$(database)/documents/users/$(uid())).data.role == 'Dealer Manager'
  );
}

// UPDATE dealers rule
match /dealers/{id} { 
  allow read: if isAuth(); 
  allow write: if isAdmin() || isDealerManager(); 
}
```

### 2. Sales Filtering for Dealer Manager

**File**: `firestore.rules`

```javascript
// UPDATE sales rule
match /sales/{id} { 
  allow read, write: if isAdmin() || 
    isAdminOrOwner(resource.data.salesmanId) || 
    (isDealerManager() && resource.data.recipientType == 'dealer'); 
}
```

### 3. Returns Filtering for Dealer Manager

**File**: `firestore.rules`

```javascript
// UPDATE returns rule
match /returns/{id} { 
  allow read, write: if isAdmin() || 
    isAdminOrOwner(resource.data.salesmanId) || 
    (isDealerManager() && resource.data.returnType == 'dealer_return'); 
}
```

### 4. Dispatches Filtering for Dealer Manager

**File**: `firestore.rules`

```javascript
// UPDATE dispatches rule
match /dispatches/{id} { 
  allow read, write: if isAdmin() || 
    isStoreIncharge() || 
    isAdminOrOwner(resource.data.salesmanId) ||
    (isDealerManager() && resource.data.recipientType == 'dealer'); 
}
```

### 5. Sync Logic - Filter Dealer Sales

**File**: `lib/services/delegates/sales_sync_delegate.dart`

**In `syncSales()` method**:

```dart
// Add dealer manager filter
if (user.role == UserRole.dealerManager) {
  baseQuery = baseQuery.where('recipientType', isEqualTo: 'dealer');
}
```

### 6. Sync Logic - Filter Dealer Returns

**File**: `lib/services/delegates/sales_sync_delegate.dart`

**In `syncReturns()` method**:

```dart
// Add dealer manager filter
if (user.role == UserRole.dealerManager) {
  query = query.where('returnType', isEqualTo: 'dealer_return');
}
```

### 7. Sync Logic - Filter Dealer Dispatches

**File**: `lib/services/delegates/inventory_sync_delegate.dart`

**In `syncDispatches()` method**:

```dart
// Add dealer manager filter
if (user.role == UserRole.dealerManager) {
  baseQuery = baseQuery.where('recipientType', isEqualTo: 'dealer');
}
```

---

## Complete Permissions Matrix

### Data Access Summary

| Category | Collections | Access Level |
|----------|-------------|--------------|
| **Dealer Management** | dealers | Read + Write (NEEDS FIX) |
| **Dealer Sales** | sales (dealer only) | Read + Write (NEEDS FILTER) |
| **Dealer Returns** | returns (dealer only) | Read + Write (NEEDS FILTER) |
| **Dealer Dispatch** | dispatches (dealer only) | Read + Write (NEEDS FILTER) |
| **Reference Data** | users, products, customers, routes, vehicles, schemes | Read Only |
| **Warehouse** | stock_ledger, opening_stock, tanks | No Access |
| **Production** | bhatti_entries, production_entries, cutting_batches | No Access |
| **HR** | employees, payroll, attendances | No Access |
| **Finance** | payments, vouchers | No Access |
| **Fleet** | diesel_logs, vehicle_maintenance | No Access |

---

## Testing Checklist

### After Deploying Fixes

- [ ] Login as Dealer Manager
- [ ] Create new dealer - should work
- [ ] Edit dealer - should work
- [ ] Create dealer sale - should work
- [ ] View only dealer sales (not customer sales)
- [ ] Process dealer return - should work
- [ ] Create dealer dispatch - should work
- [ ] View only dealer dispatches
- [ ] Sync completes without errors
- [ ] No permission denied errors in logs
- [ ] Cannot access warehouse/production data
- [ ] Cannot access HR/payroll data

---

## Expected Clean Logs

```
INFO [Auth]: Mapped user dealer@dattsoap.com to role: Dealer Manager
INFO [Sync]: Starting FORCE Sync for Dealer Manager...
SUCCESS [Sync]: Pulled 17 users from Firebase
SUCCESS [Sync]: Synced dealers
SUCCESS [Sync]: Synced sales (dealer sales only)
SUCCESS [Sync]: Synced returns (dealer returns only)
SUCCESS [Sync]: Synced dispatches (dealer dispatches only)
SUCCESS [Sync]: Synced products
SUCCESS [Sync]: Synced routes
SUCCESS [Sync]: Sync Completed Successfully.
```

---

## Summary

### Current Status
- ✅ Dashboard working
- ✅ Dealer sync working
- ⚠️ Dealer write permission missing
- ⚠️ Sales/returns/dispatches not filtered

### Fixes Required
1. Add `isDealerManager()` helper to Firestore rules
2. Grant dealer write access to Dealer Manager
3. Filter sales to dealer sales only
4. Filter returns to dealer returns only
5. Filter dispatches to dealer dispatches only
6. Update sync delegates with filters

### Priority
🔴 **HIGH** - Dealer Manager cannot currently write dealers or properly filter sales/dispatches

### Files to Modify
1. `firestore.rules` - Add helper + update 4 rules
2. `lib/services/delegates/sales_sync_delegate.dart` - Add 2 filters
3. `lib/services/delegates/inventory_sync_delegate.dart` - Add 1 filter
