# Sync Queue Stuck Sale - Resolution Guide

## समस्या (Problem)

```
ERROR [Sync]: SalesService.performSync FAILED: 
Exception: Insufficient allocated stock for acb5c4db-a888-4f33-ba08-fb1eab127094. 
Available: 0.0, Required: 2.0

WARNING [Sync]: Queue Item Failed (Retention): sales_b154b5ca-12ae-41f2-9aa9-9d4dd0498ea9
```

### Root Cause
1. Salesman ने sale create किया जब उसके पास stock था
2. बाद में stock कम हो गया या reallocate हो गया
3. अब sync queue में sale फंसा हुआ है
4. Firestore transaction fail हो रहा है क्योंकि allocated stock insufficient है

## समाधान विकल्प (Solution Options)

### Option 1: Stock Allocate करें (Recommended)
Admin को salesman को stock allocate करना होगा:

1. **Admin Dashboard** → **Users** → **Salesman (sale2@dattsoap.com)** खोलें
2. **Allocated Stock** section में जाएं
3. Product `acb5c4db-a888-4f33-ba08-fb1eab127094` के लिए **2.0 या अधिक quantity** allocate करें
4. Save करें
5. अगली sync में sale automatically process हो जाएगा

### Option 2: Queue Item Delete करें (Data Loss)
⚠️ **Warning:** यह sale permanently delete हो जाएगा

**Manual Database Cleanup:**
```dart
// Admin-only operation
final queueItem = await dbService.syncQueue
    .getById('sales_b154b5ca-12ae-41f2-9aa9-9d4dd0498ea9');
    
if (queueItem != null) {
  await dbService.db.writeTxn(() async {
    await dbService.syncQueue.delete(queueItem.isarId);
  });
}
```

### Option 3: Sale को Modify करें
Sale की quantity कम करें ताकि available stock के अंदर आ जाए:

1. Local Isar database में sale record खोजें
2. Item quantity को 0.0 से 2.0 के बीच adjust करें
3. Queue item को retry करें

## Prevention (भविष्य में रोकथाम)

### 1. Pre-Sale Stock Validation
Sale create करते समय real-time stock check:

```dart
// In sales creation flow
Future<bool> validateAllocatedStock(String salesmanId, List<SaleItem> items) async {
  final user = await dbService.users.filter().idEqualTo(salesmanId).findFirst();
  if (user == null) return false;
  
  final allocated = user.allocatedStockMap;
  for (final item in items) {
    final available = allocated[item.productId]?.quantity ?? 0.0;
    if (available < item.quantity) {
      throw Exception('Insufficient stock for ${item.name}. Available: $available');
    }
  }
  return true;
}
```

### 2. Queue Item Expiry
Stuck items को auto-expire करें:

```dart
// In sync queue processor
final queueAge = DateTime.now().difference(queueItem.createdAt);
if (queueAge.inDays > 7 && queueItem.retryCount > 10) {
  // Move to permanent failure or alert admin
  await _markQueueItemPermanentFailure(queueItem);
}
```

### 3. Admin Alert System
Stuck queue items के लिए admin को alert भेजें:

```dart
if (failedCount > 0) {
  await alertService.createAlert(
    title: 'Sync Queue Stuck',
    message: '$failedCount sales pending due to stock issues',
    severity: AlertSeverity.high,
    type: AlertType.syncIssue,
  );
}
```

## Technical Details

### Stock Validation Logic
```dart
// From sales_service.dart:930
final allocated = salesmanData['allocatedStock'] as Map<String, dynamic>? ?? {};

for (var item in validatedItems) {
  final pId = item['productId'];
  final qty = (item['quantity'] as num).toDouble();
  final isFree = item['isFree'] == true;

  final stockItem = allocated[pId] as Map<String, dynamic>? ?? {};
  final available = isFree
      ? (stockItem['freeQuantity'] as num? ?? 0).toDouble()
      : (stockItem['quantity'] as num? ?? 0).toDouble();

  if (available < qty) {
    throw Exception(
      'Insufficient allocated stock for $pId. Available: $available, Required: $qty',
    );
  }
}
```

### Queue Retry Logic
```dart
// Queue item retains on failure
// Retry happens on next sync cycle
// No automatic expiry currently implemented
```

## Immediate Action Required

### For Admin:
1. Check salesman's allocated stock
2. Allocate required stock (2.0 units of product `acb5c4db-a888-4f33-ba08-fb1eab127094`)
3. Wait for next sync cycle (or trigger manual sync)

### For Developer:
1. Add admin UI to view stuck queue items
2. Add "Clear Queue Item" button with confirmation
3. Add stock validation before sale creation
4. Implement queue item expiry policy

## Related Files
- `lib/services/sales_service.dart` - Stock validation logic (line 930)
- `lib/services/delegates/sync_queue_processor_delegate.dart` - Queue processing
- `lib/data/local/entities/sync_queue_entity.dart` - Queue data model

## Status
- ✅ Issue identified
- ⚠️ Requires admin action to resolve
- 🔄 Prevention measures recommended
