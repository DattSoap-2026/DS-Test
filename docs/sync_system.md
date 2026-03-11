# DattSoap ERP - Sync System

**Version:** 2.7  
**Last Updated:** March 2026

---

## Overview

The DattSoap ERP uses an offline-first architecture with a durable outbox queue pattern for reliable data synchronization between local (Isar) and cloud (Firestore) databases.

---

## Sync Architecture

### Components

1. **Local Database (Isar)**
   - Primary data store for offline operations
   - High-performance NoSQL database
   - Supports complex queries and indexes

2. **Sync Queue**
   - Durable outbox pattern
   - Stores pending operations
   - Automatic retry with backoff

3. **Cloud Database (Firestore)**
   - Source of truth for multi-user data
   - Real-time updates
   - Conflict resolution

4. **Sync Processor**
   - Background processing
   - Batch operations
   - Error handling and retry

---

## Sync Flow

### Write Operations

```
User Action
    ↓
Service Layer (validates)
    ↓
Local DB Write (Isar) ← Immediate success to user
    ↓
Sync Queue Entry (pending)
    ↓
[When Online]
    ↓
Sync Processor
    ↓
Firestore Write
    ↓
Queue Entry (completed)
```

### Read Operations

```
Firestore Stream
    ↓
Local Cache Update
    ↓
UI Rebuild (Provider)
```

---

## Queue Management

### Queue Entry Structure

```dart
{
  "id": "uuid",
  "operation": "create|update|delete",
  "collection": "sales|dispatch|production",
  "documentId": "doc_id",
  "data": {...},
  "status": "pending|processing|completed|failed",
  "retryCount": 0,
  "createdAt": "timestamp",
  "lastAttempt": "timestamp",
  "error": "error_message"
}
```

### Queue States

1. **Pending** - Waiting to be processed
2. **Processing** - Currently being synced
3. **Completed** - Successfully synced
4. **Failed** - Sync failed after retries

---

## Retry Strategy

### Exponential Backoff

```
Attempt 1: Immediate
Attempt 2: 5 seconds
Attempt 3: 15 seconds
Attempt 4: 45 seconds
Attempt 5: 2 minutes
Attempt 6+: 5 minutes
```

### Max Retries
- Default: 10 attempts
- After max retries: Manual intervention required

---

## Conflict Resolution

### Strategy: Last-Write-Wins

1. Compare timestamps
2. Keep most recent version
3. Log conflict for audit

### Conflict Detection

```dart
if (localTimestamp > firestoreTimestamp) {
  // Local version is newer, push to Firestore
} else {
  // Firestore version is newer, update local
}
```

---

## Sync Triggers

### Automatic Triggers

1. **App Launch** - Process pending queue
2. **Network Available** - Resume sync
3. **Periodic** - Every 5 minutes (when online)
4. **User Action** - After critical operations

### Manual Triggers

1. **Pull to Refresh** - Force sync
2. **Sync Button** - Manual sync request
3. **Settings** - Sync configuration

---

## Sync Status Indicators

### UI Indicators

- **Synced** ✅ - All data synced
- **Syncing** 🔄 - Sync in progress
- **Pending** ⏳ - Items in queue
- **Error** ❌ - Sync failed

### Status Bar

```dart
"Synced" | "Syncing (3 items)" | "Offline (5 pending)" | "Error"
```

---

## Data Synchronization

### Collections Synced

1. **Sales** - Sales orders and invoices
2. **Dispatch** - Stock and dealer dispatch
3. **Production** - Production batches (T6 planned)
4. **Bhatti** - Cooking batches (T6 planned)
5. **Cutting** - Cutting batches (T6 planned)
6. **Payments** - Payment vouchers
7. **Stock** - Stock adjustments

### Collections Not Synced (Read-Only)

1. **Products** - Master data
2. **Customers** - Master data
3. **Users** - Master data
4. **Settings** - Configuration

---

## Offline Support

### Offline Capabilities

✅ Create sales orders
✅ Record dispatch
✅ Log production
✅ View reports (cached data)
✅ Search products/customers
✅ View history

❌ User management (requires online)
❌ Master data changes (requires online)
❌ Real-time reports (requires online)

### Offline Limitations

- Reports show cached data
- No real-time updates from other users
- Master data changes not available
- Image uploads queued

---

## Sync Performance

### Metrics

- **Queue Depth** - Number of pending items
- **Drain Time** - Time to process queue
- **Success Rate** - Percentage of successful syncs
- **Error Rate** - Percentage of failed syncs

### Targets

- Queue depth: < 100 items
- Drain time: < 5 minutes for 100 items
- Success rate: > 95%
- Error rate: < 5%

---

## Error Handling

### Common Errors

1. **Network Timeout**
   - Retry with backoff
   - User notification after 3 attempts

2. **Permission Denied**
   - Check user role
   - Log security event
   - Notify user

3. **Document Not Found**
   - Check if deleted
   - Remove from queue
   - Log event

4. **Validation Error**
   - Log error details
   - Notify user
   - Require manual fix

### Error Recovery

```dart
try {
  await syncToFirestore(queueItem);
  markAsCompleted(queueItem);
} catch (e) {
  if (isRetryable(e)) {
    incrementRetryCount(queueItem);
    scheduleRetry(queueItem);
  } else {
    markAsFailed(queueItem);
    notifyUser(e);
  }
}
```

---

## Monitoring

### Firebase Console

- **Firestore Usage** - Read/write operations
- **Storage Usage** - Database size
- **Performance** - Query performance

### App Monitoring

- **Queue Depth** - Dashboard widget
- **Sync Status** - Status bar
- **Error Logs** - Crashlytics

---

## Sync Configuration

### Settings

```dart
{
  "autoSync": true,
  "syncInterval": 300, // seconds
  "maxRetries": 10,
  "batchSize": 50,
  "wifiOnly": false
}
```

### User Preferences

- Auto-sync on/off
- Sync frequency
- WiFi-only mode
- Background sync

---

## Best Practices

### For Developers

1. Always write to local DB first
2. Add to sync queue immediately
3. Handle offline gracefully
4. Show sync status to user
5. Log errors for debugging

### For Users

1. Keep app updated
2. Sync regularly when online
3. Check sync status before critical operations
4. Report sync errors promptly

---

## Troubleshooting

### Queue Stuck

**Symptoms:** Items not syncing
**Solution:**
1. Check network connectivity
2. Check Firestore rules
3. Check user permissions
4. Clear failed items manually

### Slow Sync

**Symptoms:** Long drain time
**Solution:**
1. Check network speed
2. Reduce batch size
3. Optimize Firestore indexes
4. Check for large documents

### Conflicts

**Symptoms:** Data inconsistency
**Solution:**
1. Check timestamps
2. Review conflict logs
3. Manual reconciliation if needed

---

## Future Enhancements

### Planned (T6)

- Production queue migration
- Bhatti queue migration
- Cutting queue migration

### Roadmap

- Selective sync (by date range)
- Compression for large payloads
- Delta sync (only changes)
- Multi-device sync coordination

---

## Technical Details

### Queue Processor

**File:** `lib/services/sync_queue_processor.dart`

**Key Methods:**
- `processQueue()` - Main processing loop
- `syncItem()` - Sync single item
- `handleError()` - Error handling
- `scheduleRetry()` - Retry scheduling

### Sync Delegate

**File:** `lib/services/sync_delegate.dart`

**Responsibilities:**
- Collection-specific sync logic
- Data transformation
- Validation
- Conflict resolution

---

## References

- [Architecture Overview](architecture.md)
- [Offline Support](offline_support.md)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Isar Database](https://isar.dev)

---

**Maintained by DattSoap Development Team**
