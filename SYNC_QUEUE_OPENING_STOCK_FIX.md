# Sync Queue Opening Stock Fix - Updated

## Problem Analysis

### Issue
- 6 opening stock entries stuck in sync queue with "delayed" status
- Items in exponential backoff (retry delay active)
- Salesman role user unable to process these queue items
- Orange banner showing "Pending outbox: 1, Conflicts: 0"

### Root Causes
1. **Ownership Mismatch**: Queue items had actor metadata from original creator
2. **Session Validation**: Cross-user processing was blocked
3. **Backoff Period**: Items had failed multiple times and were in retry delay

## Solution Implemented

### 1. Allow Cross-User Processing (sync_queue_processor_delegate.dart)

```dart
bool _shouldProcessQueueItemForCurrentSession(
  _QueueWorkItem item,
  firebase_auth.User authUser,
) {
  // Special handling for opening stock entries
  if (item.collection == 'opening_stock_entries' || 
      item.collection == 'inventory_commands') {
    return true;
  }
  // ... rest of logic
}
```

### 2. Bypass Backoff for System Operations (sync_queue_processor_delegate.dart)

```dart
if (!OutboxCodec.shouldRetryNow(meta)) {
  // Special case: Opening stock items should retry immediately
  if (collection == 'opening_stock_entries' || 
      collection == 'inventory_commands') {
    AppLogger.info(
      'Bypassing backoff for system-level operation: $collection',
      tag: 'Sync',
    );
  } else {
    skippedBackoff++;
    continue;
  }
}
```

### 3. Fix Actor Metadata (opening_stock_service.dart)

```dart
final actorMeta = {
  OutboxCodec.actorUidMetaField: userId.trim(),
  if (user?.email != null) OutboxCodec.actorEmailMetaField: user!.email!.trim(),
};
```

### 4. Manual Reset Utilities (sync_manager.dart)

**Reset Retry State:**
```dart
Future<int> resetStuckOpeningStockRetry() async {
  // Resets backoff timers for immediate retry
}
```

**Clear Queue Items:**
```dart
Future<int> clearStuckOpeningStockQueue() async {
  // Completely removes stuck items
}
```

### 5. UI Helper Widget (opening_stock_queue_reset_button.dart)

Button widget for manual queue reset from admin panel.

## How to Fix Immediately

### Option 1: Automatic (Restart App)
1. Close and restart the app
2. Backoff bypass will automatically apply
3. Items will process on next sync

### Option 2: Manual Reset (Recommended)

Add this to your admin/debug screen:

```dart
import 'package:flutter_app/widgets/debug/opening_stock_queue_reset_button.dart';

// In your widget:
OpeningStockQueueResetButton()
```

Or call directly:

```dart
final syncManager = context.read<SyncManager>();
await syncManager.resetStuckOpeningStockRetry();
syncManager.scheduleDebouncedSync();
```

### Option 3: Clear Queue (Nuclear Option)

```dart
final syncManager = context.read<SyncManager>();
await syncManager.clearStuckOpeningStockQueue();
```

## Expected Behavior After Fix

- ✅ Opening stock items bypass backoff period
- ✅ Any authenticated user can process opening stock queue
- ✅ Items retry immediately instead of waiting
- ✅ Orange banner disappears after successful sync
- ✅ Log shows: `SUCCESS [Sync]: Sync Queue Processed: 6 success, 0 failed`

## Files Modified

1. `lib/services/delegates/sync_queue_processor_delegate.dart`
   - Cross-user processing for opening stock
   - Backoff bypass for system operations

2. `lib/services/opening_stock_service.dart`
   - Fixed actor metadata

3. `lib/services/sync_manager.dart`
   - Added `resetStuckOpeningStockRetry()`
   - Added `clearStuckOpeningStockQueue()`

4. `lib/widgets/debug/opening_stock_queue_reset_button.dart` (NEW)
   - UI widget for manual reset

## Testing

1. **Verify backoff bypass:**
   ```
   INFO [Sync]: Bypassing backoff for system-level operation: opening_stock_entries
   ```

2. **Verify processing:**
   ```
   SUCCESS [Sync]: Sync Queue Processed: 6 success, 0 failed, 0 delayed
   ```

3. **Verify UI:**
   - Orange banner should disappear
   - Pending count should be 0 (or 1 for the dispatch item)

## Prevention

- Opening stock entries now have proper actor metadata
- System operations bypass backoff automatically
- Manual reset tools available for edge cases

## Rollback

If issues occur:
1. Revert sync_queue_processor_delegate.dart changes
2. Use `clearStuckOpeningStockQueue()` to remove problematic items
3. Re-create opening stock entries if needed
