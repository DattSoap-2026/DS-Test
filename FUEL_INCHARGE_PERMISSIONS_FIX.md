# Fuel Incharge Permissions Fix

## Problem
Fuel Incharge was getting permission denied errors when trying to access:
- Diesel logs (diesel_logs collection)
- Fuel purchases (fuel_purchases collection)  
- Fuel stock (public_settings/fuel_stock document)

**Error Logs**:
```
ERROR [Sync]: Error pulling diesel logs: [cloud_firestore/permission-denied]
ERROR [Service]: bootstrapFromFirebase failed: [cloud_firestore/permission-denied]
```

## Root Cause
1. Fuel Incharge role was not defined in firestore.rules
2. diesel_logs only allowed Admin and Store Incharge
3. fuel_purchases only allowed Admin
4. public_settings only allowed Admin for write

## Solution Applied ✅

### 1. Added Fuel Incharge Helper Function
**File**: `firestore.rules`

```javascript
function isFuelIncharge() {
  return isAuth() && (
    request.auth.token.role == 'FuelIncharge' ||
    request.auth.token.role == 'Fuel Incharge' ||
    get(/databases/$(database)/documents/users/$(uid())).data.role == 'FuelIncharge' ||
    get(/databases/$(database)/documents/users/$(uid())).data.role == 'Fuel Incharge'
  );
}
```

### 2. Updated Collection Permissions

**Diesel Logs**:
```javascript
// BEFORE
match /diesel_logs/{id} { 
  allow read, write: if isAdmin() || isStoreIncharge(); 
}

// AFTER
match /diesel_logs/{id} { 
  allow read, write: if isAdmin() || isStoreIncharge() || isFuelIncharge(); 
}
```

**Fuel Purchases**:
```javascript
// BEFORE
match /fuel_purchases/{id} { 
  allow read, write: if isAdmin(); 
}

// AFTER
match /fuel_purchases/{id} { 
  allow read, write: if isAdmin() || isFuelIncharge(); 
}
```

**Public Settings (for fuel_stock)**:
```javascript
// BEFORE
match /public_settings/{id} { 
  allow read: if isAuth(); 
  allow write: if isAdmin(); 
}

// AFTER
match /public_settings/{id} { 
  allow read: if isAuth(); 
  allow write: if isAdmin() || isFuelIncharge(); 
}
```

### 3. Sync Permissions (Already Correct)
**File**: `sync_manager.dart`

```dart
bool _canSyncFleetData(UserRole role) {
  return _isAdminLikeRole(role) ||
      role == UserRole.dispatchManager ||
      role == UserRole.storeIncharge ||
      role == UserRole.fuelIncharge ||  // ✅ Already included
      role == UserRole.vehicleMaintenanceManager;
}
```

## Fuel Incharge Permissions Summary

### ✅ Can Access:
- **Diesel Logs** (diesel_logs) - Read & Write
- **Fuel Purchases** (fuel_purchases) - Read & Write
- **Fuel Stock** (public_settings/fuel_stock) - Read & Write
- **Vehicles** (vehicles) - Read only
- **Users** (users) - Read only
- **Products** (products) - Read only

### ❌ Cannot Access:
- Vehicle Maintenance Logs
- Tyre Logs
- Vehicle Issues
- Sales/Dispatches
- Production Data
- Payroll/HR Data

## Deployment

```bash
firebase deploy --only firestore:rules
```

Wait 30-60 seconds for rules to propagate.

## Testing

1. Login as Fuel Incharge (fuel@dattsoap.com)
2. Navigate to Fuel Management pages:
   - Current Fuel Stock ✅
   - Add Fuel Log ✅
   - Fuel History ✅
   - Fuel Report ✅
3. Verify no permission errors in logs
4. Test adding diesel log
5. Test adding fuel purchase

## Expected Behavior After Fix

**Sync Logs**:
```
INFO [Sync]: Starting FORCE Sync for Fuel Incharge...
SUCCESS [Sync]: Pulled X diesel logs from Firebase
SUCCESS [Sync]: Pulled X fuel purchases from Firebase
SUCCESS [Sync]: Sync Completed Successfully
```

**No More Errors**:
- ❌ ERROR [Sync]: Error pulling diesel logs
- ❌ ERROR [Service]: bootstrapFromFirebase failed

## Files Modified
1. `firestore.rules` - Added Fuel Incharge permissions
2. `data_management_service.dart` - Added fuel stock reset in Full Transaction Reset

