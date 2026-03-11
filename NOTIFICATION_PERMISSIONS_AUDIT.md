# Notification Permissions - Complete Audit for All Roles

## Current Notification Rule

**File**: `firestore.rules`

```javascript
match /notification_events/{id} { 
  allow read: if isAdmin() || 
    (isAuth() && resource.data.userId == uid()) ||
    (isSalesman() && resource.data.targetRole == 'Salesman') ||
    (isDealerManager() && resource.data.targetRole == 'DealerManager');
  allow write: if isAdmin(); 
}
```

---

## Notification Types in System

### 1. Vehicle Expiry Notifications
- **Type**: `vehicle_expiry`, `puc_expiry`, `insurance_expiry`, `fitness_expiry`
- **Target**: Fleet managers, Admin
- **Should See**: Admin, Fleet Manager, Vehicle Maintenance Manager
- **Should NOT See**: Salesman, Dealer Manager, Production roles

### 2. Sales Notifications
- **Type**: `sale_created`, `sale_completed`
- **Target**: Salesman (own sales), Sales Manager, Admin
- **Should See**: Salesman (own), Sales Manager, Admin
- **Should NOT See**: Production, Dealer Manager (unless dealer sale)

### 3. Dealer Notifications
- **Type**: `dealer_sale`, `dealer_dispatch`, `dealer_return`
- **Target**: Dealer Manager, Admin
- **Should See**: Dealer Manager, Admin
- **Should NOT See**: Salesman, Production roles

### 4. Dispatch Notifications
- **Type**: `dispatch_created`, `dispatch_completed`
- **Target**: Salesman (own), Store Incharge, Admin
- **Should See**: Salesman (own), Store Incharge, Dispatch Manager, Admin
- **Should NOT See**: Production roles (unless production dispatch)

### 5. Return Notifications
- **Type**: `return_submitted`, `return_approved`
- **Target**: Salesman (own), Sales Manager, Admin
- **Should See**: Salesman (own), Sales Manager, Admin
- **Should NOT See**: Production, Dealer Manager (unless dealer return)

### 6. Stock Notifications
- **Type**: `low_stock`, `out_of_stock`, `stock_alert`
- **Target**: Store Incharge, Production Manager, Admin
- **Should See**: Store Incharge, Production Manager, Admin
- **Should NOT See**: Salesman, Dealer Manager

### 7. Production Notifications
- **Type**: `production_completed`, `bhatti_entry`, `cutting_completed`
- **Target**: Production Supervisor, Production Manager, Admin
- **Should See**: Production roles, Admin
- **Should NOT See**: Sales roles, Dealer Manager

### 8. Task Notifications
- **Type**: `task_assigned`, `task_completed`
- **Target**: Assigned user
- **Should See**: Assigned user only
- **Should NOT See**: Others (unless admin)

---

## Role-Based Notification Matrix

| Notification Type | Admin | Salesman | Dealer Mgr | Store | Production | Fleet |
|-------------------|-------|----------|------------|-------|------------|-------|
| **Vehicle Expiry** | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Sales (Customer)** | ✅ | ✅ (own) | ❌ | ❌ | ❌ | ❌ |
| **Sales (Dealer)** | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Dispatch (Customer)** | ✅ | ✅ (own) | ❌ | ✅ | ❌ | ❌ |
| **Dispatch (Dealer)** | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ |
| **Return (Customer)** | ✅ | ✅ (own) | ❌ | ❌ | ❌ | ❌ |
| **Return (Dealer)** | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Stock Alert** | ✅ | ❌ | ❌ | ✅ | ✅ | ❌ |
| **Production** | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Task Assigned** | ✅ | ✅ (own) | ✅ (own) | ✅ (own) | ✅ (own) | ✅ (own) |

---

## Current Issues

### ❌ Problem 1: Role-Based Filtering Too Broad
```javascript
(isSalesman() && resource.data.targetRole == 'Salesman')
```
This shows ALL notifications with `targetRole: 'Salesman'` to ALL salesmen, not just their own.

### ❌ Problem 2: Missing Role Helpers
Only `isSalesman()` and `isDealerManager()` exist. Missing:
- `isStoreIncharge()`
- `isProductionSupervisor()`
- `isFleetManager()`
- etc.

### ❌ Problem 3: No Type-Based Filtering
Vehicle expiry notifications don't check if user should see them.

---

## Recommended Fix

### Option 1: Simple User-Based (Recommended)

```javascript
match /notification_events/{id} { 
  allow read: if isAdmin() || 
    (isAuth() && resource.data.userId == uid());
  allow write: if isAdmin(); 
}
```

**How it works**:
- Notifications are created with `userId` field set to target user
- Each user only sees notifications where `userId == their UID`
- Admin sees all
- Simple and secure

### Option 2: Role + Type Based (Complex)

```javascript
function canReadNotification() {
  let data = resource.data;
  
  // Admin sees all
  if (isAdmin()) return true;
  
  // User-specific notifications
  if (data.userId == uid()) return true;
  
  // Role-based notifications
  if (isSalesman() && data.targetRole == 'Salesman' && data.type in ['sale_created', 'dispatch_created', 'return_approved']) return true;
  
  if (isDealerManager() && data.targetRole == 'DealerManager' && data.type in ['dealer_sale', 'dealer_dispatch', 'dealer_return']) return true;
  
  if (isStoreIncharge() && data.targetRole == 'StoreIncharge' && data.type in ['stock_alert', 'dispatch_created']) return true;
  
  if (isProductionSupervisor() && data.targetRole == 'ProductionSupervisor' && data.type in ['production_completed', 'stock_alert']) return true;
  
  return false;
}

match /notification_events/{id} { 
  allow read: if canReadNotification();
  allow write: if isAdmin(); 
}
```

---

## Recommended Implementation

### Step 1: Update Firestore Rules (Simple Approach)

```javascript
match /notification_events/{id} { 
  allow read: if isAdmin() || (isAuth() && resource.data.userId == uid());
  allow write: if isAdmin(); 
}
```

### Step 2: Update Notification Creation Logic

**File**: `lib/services/alert_service.dart` or notification service

Ensure notifications are created with correct `userId`:

```dart
// For user-specific notifications
await db.collection('notification_events').add({
  'userId': targetUserId,  // ✅ Specific user UID
  'type': 'sale_created',
  'title': 'New Sale Created',
  'message': 'Sale #12345 created',
  'createdAt': DateTime.now().toIso8601String(),
});

// For role-based notifications (create multiple)
for (final user in usersWithRole) {
  await db.collection('notification_events').add({
    'userId': user.uid,  // ✅ Each user gets their own notification
    'type': 'stock_alert',
    'title': 'Low Stock Alert',
    'message': 'Product XYZ is low',
    'createdAt': DateTime.now().toIso8601String(),
  });
}
```

---

## Testing Checklist

### For Each Role

#### Admin
- [ ] Sees all notifications
- [ ] Sees vehicle expiry
- [ ] Sees sales notifications
- [ ] Sees production notifications

#### Salesman
- [ ] Sees only own sales notifications
- [ ] Sees only own dispatch notifications
- [ ] Sees only own return notifications
- [ ] Does NOT see vehicle expiry
- [ ] Does NOT see other salesman's notifications

#### Dealer Manager
- [ ] Sees only dealer sale notifications
- [ ] Sees only dealer dispatch notifications
- [ ] Sees only dealer return notifications
- [ ] Does NOT see vehicle expiry
- [ ] Does NOT see customer sale notifications

#### Store Incharge
- [ ] Sees stock alerts
- [ ] Sees dispatch notifications
- [ ] Does NOT see vehicle expiry
- [ ] Does NOT see sales notifications

#### Production Supervisor
- [ ] Sees production notifications
- [ ] Sees stock alerts
- [ ] Does NOT see vehicle expiry
- [ ] Does NOT see sales notifications

---

## Quick Fix (Immediate)

### Update Firestore Rules Now

```javascript
match /notification_events/{id} { 
  allow read: if isAdmin() || (isAuth() && resource.data.userId == uid());
  allow write: if isAdmin(); 
}
```

This ensures:
- ✅ Each user only sees their own notifications
- ✅ No cross-user notification leakage
- ✅ Simple and secure
- ✅ Works for all roles

### Deploy
```bash
firebase deploy --only firestore:rules
```

---

## Summary

### Current State ❌
- Dealer Manager seeing vehicle expiry (wrong)
- Potential for salesmen to see each other's notifications
- No proper role-based filtering

### After Fix ✅
- Each user sees only their notifications (`userId == uid()`)
- Admin sees all
- No cross-user leakage
- Simple and secure

### Action Required
1. Update notification rule to user-based filtering
2. Ensure notification creation sets correct `userId`
3. Deploy rules
4. Test with each role
