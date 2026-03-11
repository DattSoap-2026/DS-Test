# SYNC ERROR FIX GUIDE

## Problem Summary
Banner shows: **"Sync completed with issues. Errors: 7, Pending outbox: 0, Conflicts: 0"**

The 7 errors are sync queue items with `SyncStatus.conflict` - permanent failures after multiple retry attempts.

## Root Cause
Items in the sync queue failed permanently due to:
1. Permission denied (Firestore rules blocking write)
2. Missing required fields (null userId, documentId, etc.)
3. Invalid document IDs
4. Missing Firestore indexes
5. Network timeouts incorrectly marked as permanent
6. Items stuck >7 days

## How to View the Errors

### Option 1: Use the Diagnostic Screen (RECOMMENDED)
1. Navigate to Settings → Conflicts (or add route to app_router.dart)
2. Or manually navigate to the new screen:
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(
       builder: (context) => const SyncErrorViewerScreen(),
     ),
   );
   ```

### Option 2: Run Diagnostic Script
```dart
import 'package:flutter_app/services/sync_error_diagnostic.dart';

// In your debug code:
final dbService = ref.read(databaseServiceProvider);
await diagnoseSyncErrors(dbService);
```

### Option 3: Query Directly
```dart
final dbService = ref.read(databaseServiceProvider);
final conflicts = await dbService.syncQueue
    .where()
    .filter()
    .syncStatusEqualTo(SyncStatus.conflict)
    .findAll();

for (final item in conflicts) {
  final decoded = OutboxCodec.decode(item.dataJson, fallbackQueuedAt: item.createdAt);
  print('Collection: ${item.collection}');
  print('Action: ${item.action}');
  print('Error: ${decoded.meta['lastError']}');
}
```

## Fixes by Root Cause

### RC1: Permission Denied
**Symptom:** Error contains "permission-denied" or "insufficient permissions"

**Fix:**
1. Check `firestore.rules` for the failing collection
2. Verify user role has write access
3. Deploy updated rules: `firebase deploy --only firestore:rules`

**Example:** If `sales_voucher_posts` fails with permission denied:
```javascript
// firestore.rules
match /sales_voucher_posts/{postId} {
  allow write: if isAuthenticated() && 
    (isAdmin() || isSalesTeam() || isAccountant());
}
```

### RC2: Missing Required Field
**Symptom:** Error contains "null" or "required field"

**Fix:**
1. Find where the command is enqueued (search for collection name + `.enqueue`)
2. Add validation before enqueuing:
```dart
if (userId == null || userId.trim().isEmpty) {
  throw ValidationException('User ID is required');
}
if (documentId == null || documentId.trim().isEmpty) {
  throw ValidationException('Document ID is required');
}
```

### RC3: Wrong User ID (AppUser.id vs Firebase UID)
**Symptom:** Permission denied on user-scoped collections

**Fix:**
Replace all `AppUser.id` with `canonicalUserId()`:
```dart
// BAD
final userId = appUser.id;

// GOOD
import 'package:flutter_app/utils/auth_utils.dart';
final userId = canonicalUserId(appUser);
```

### RC4: Invalid Document ID
**Symptom:** Error contains "invalid-argument" or "document path"

**Fix:**
Validate document ID before enqueuing:
```dart
String sanitizeDocumentId(String id) {
  if (id.isEmpty) return uuid.v4();
  return id.replaceAll(RegExp(r'[/\s]'), '_');
}
```

### RC5: Go-Live Lock Blocking Opening Stock
**Symptom:** Opening stock commands failing after Go-Live

**Fix:**
Check Go-Live status before enqueuing:
```dart
// In opening_stock_service.dart
Future<void> setOpeningStock(...) async {
  final isLocked = await _settingsService.isGoLiveLocked();
  if (isLocked) {
    throw BusinessRuleException(
      'Opening stock is locked after Go-Live. Contact admin.',
    );
  }
  // ... proceed with enqueue
}
```

### RC6: Missing Firestore Index
**Symptom:** Error contains "FAILED_PRECONDITION" with index URL

**Fix:**
1. Copy the index URL from error message
2. Open in browser to create index
3. Or add to `firestore.indexes.json` and deploy

### RC7: Network Timeout Marked as Permanent
**Symptom:** Error contains "timeout" or "deadline exceeded"

**Fix:**
Update error classification in `sync_queue_processor_delegate.dart`:
```dart
bool _isTransientError(Object error) {
  final normalized = error.toString().toLowerCase();
  return normalized.contains('timeout') ||
         normalized.contains('deadline') ||
         normalized.contains('unavailable') ||
         normalized.contains('network');
}

// In catch block:
if (_isTransientError(e)) {
  // Re-enqueue for retry, don't mark as permanent
  updatedMeta = OutboxCodec.markFailure(meta, e);
} else {
  // Mark as permanent
  updatedMeta = {...meta, 'permanentFailure': true};
}
```

## How to Clear Errors After Fixing

### Option 1: Delete Individual Errors (via UI)
Use the SyncErrorViewerScreen to review and delete each error after fixing the root cause.

### Option 2: Delete All Errors (Programmatic)
```dart
final dbService = ref.read(databaseServiceProvider);
final conflicts = await dbService.syncQueue
    .where()
    .filter()
    .syncStatusEqualTo(SyncStatus.conflict)
    .findAll();

await dbService.db.writeTxn(() async {
  for (final item in conflicts) {
    await dbService.syncQueue.delete(item.isarId);
  }
});

print('Deleted ${conflicts.length} sync errors');
```

### Option 3: Retry Failed Commands
If the data still needs to be synced:
1. Fix the root cause
2. Extract the payload from the conflict item
3. Re-trigger the original action with corrected data

## Prevention: Add Command Validator

Create `lib/services/outbox_command_validator.dart`:
```dart
class CommandValidator {
  static void validate({
    required String collection,
    required String action,
    required Map<String, dynamic> payload,
  }) {
    // Validate userId
    final userId = payload['userId'] ?? payload['salesmanId'] ?? payload['createdBy'];
    if (userId == null || userId.toString().trim().isEmpty) {
      throw ValidationException('User ID is required for $collection/$action');
    }

    // Validate documentId
    if (action != 'add') {
      final docId = payload['id'];
      if (docId == null || docId.toString().trim().isEmpty) {
        throw ValidationException('Document ID is required for $collection/$action');
      }
    }

    // Collection-specific validation
    if (collection == 'sales') {
      if (payload['customerId'] == null) {
        throw ValidationException('Customer ID is required for sales');
      }
    }
  }
}
```

Use before enqueuing:
```dart
CommandValidator.validate(
  collection: 'sales',
  action: 'add',
  payload: saleData,
);
await _dbService.enqueueCommand(...);
```

## Testing

After fixes, verify:
```dart
// 1. Check error count
final conflicts = await dbService.syncQueue
    .where()
    .filter()
    .syncStatusEqualTo(SyncStatus.conflict)
    .findAll();
print('Remaining errors: ${conflicts.length}'); // Should be 0

// 2. Trigger sync
await syncManager.syncAll(user);

// 3. Verify banner
// Should show: "Sync completed successfully"
```

## Files Created
1. `lib/services/sync_error_diagnostic.dart` - Diagnostic script
2. `lib/screens/sync/sync_error_viewer_screen.dart` - UI to view/delete errors
3. This guide

## Next Steps
1. Run diagnostic to identify the 7 specific errors
2. Apply fixes based on root cause
3. Delete cleared errors
4. Add CommandValidator to prevent future errors
5. Monitor sync banner - should show 0 errors
