# Dealer Manager Bootstrap Permission Error - Fix

## Problem
```
ERROR [Service]: bootstrapFromFirebase failed: [cloud_firestore/permission-denied]
```

Dealer Manager is seeing this error when navigating through the app because `vehicles_service.dart` is trying to refresh vehicle data from Firebase, but Dealer Manager doesn't have permission to access vehicle collections.

## Root Cause

The `vehicles_service.dart` has methods like:
- `getMaintenanceLogs()` with `forceRefresh` parameter
- `getTyreLogs()` with `forceRefresh` parameter  
- `getAllTyres()` with `forceRefresh` parameter
- `getAvailableTyres()` with `forceRefresh` parameter

These methods call `bootstrapFromFirebase()` which tries to fetch data from Firebase collections that Dealer Manager doesn't have access to:
- `vehicle_maintenance_logs`
- `tyre_logs`
- `tyre_items`
- `vehicles`

## Solution

The `bootstrapFromFirebase()` method in `offline_first_service.dart` already has error handling that catches permission-denied errors and returns empty list. This is working correctly.

**The error is informational only** - it's being logged but not breaking the app. The service correctly falls back to local data when Firebase access is denied.

## Why This Is Not a Bug

1. **Error Handling Works**: The try-catch in `bootstrapFromFirebase()` catches the permission error and returns `[]`
2. **Fallback to Local**: After the error, the service uses local Isar database data
3. **No App Crash**: The error is logged but doesn't break functionality
4. **Expected Behavior**: Dealer Manager shouldn't access vehicle data, so permission-denied is correct

## Verification

Looking at the code in `vehicles_service.dart`:

```dart
Future<List<MaintenanceLog>> getMaintenanceLogs({
  bool forceRefresh = false,
}) async {
  if (forceRefresh) {
    try {
      final payloads = await bootstrapFromFirebase(
        collectionName: maintenanceLogsCollection,
      );
      // ... process payloads
    } catch (e) {
      debugPrint('Error bootstrapping maintenance logs: $e');
      // Fallback to local  ← THIS WORKS CORRECTLY
    }
  }
  
  // Always returns local data if Firebase fails
  var query = _dbService.maintenanceLogs.where();
  var entities = await query.sortByServiceDateDesc().findAll();
  return entities.map((e) => MaintenanceLog.fromEntity(e)).toList();
}
```

## Why Logs Show Error

The error appears in logs because:
1. `offline_first_service.dart` calls `handleError(e, 'bootstrapFromFirebase')` 
2. This logs the error for debugging purposes
3. But it doesn't throw - it returns `[]` gracefully

## Recommended Action

**NO CODE CHANGES NEEDED**

The error is:
- ✅ Expected (Dealer Manager shouldn't access vehicles)
- ✅ Handled correctly (fallback to local data)
- ✅ Non-breaking (app continues working)
- ✅ Informational (helps debugging)

## Optional: Suppress Log for Known Permission Denials

If you want to reduce log noise, you can update `offline_first_service.dart` to suppress permission-denied errors:

```dart
Future<List<Map<String, dynamic>>> bootstrapFromFirebase({
  required String collectionName,
}) async {
  try {
    final firestore = db;
    if (firestore == null) return [];

    final snapshot = await firestore
        .collection(collectionName)
        .get()
        .timeout(const Duration(seconds: 3));
    final items = snapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();

    if (items.isNotEmpty && !useIsar) {
      await saveToLocal(items);
    }

    return items;
  } catch (e) {
    // Suppress permission-denied errors (expected for role-based access)
    final errorMsg = e.toString().toLowerCase();
    if (!errorMsg.contains('permission-denied') && 
        !errorMsg.contains('insufficient permissions')) {
      handleError(e, 'bootstrapFromFirebase');
    }
    return [];
  }
}
```

## Summary

✅ **Current behavior is correct**
✅ **No fix needed**
✅ **Error is informational, not breaking**
✅ **Dealer Manager permissions are working as designed**

The logs showing "ERROR [Service]: bootstrapFromFirebase failed" are expected when a role tries to access collections they don't have permission for. The service correctly handles this by falling back to local data.

