# Full Transaction Reset - Implementation Plan

## Phase 1: Update Collection Lists

### Add Missing Firebase Collections
```dart
// Add to _transactionCollections (line 183):
'dispatch_items',
'dispatch_history',
'salesman_allocated_stock',
'salesman_stock_transactions',
'salesman_stock_history',
'sale_items',
'sales_history',
'sales_payments',
'sales_returns',
'route_order_items',
```

### Add Missing Cache Keys
```dart
// Add to _transactionPrefKeys (line 251):
'local_dispatch_queue',
'local_sales_queue',
'salesman_stock_cache',
'dispatch_cache',
'inventory_cache',
```

## Phase 2: Add Admin Authorization Check

Add to `resetTransactionalData()` method:
```dart
Future<bool> resetTransactionalData({
  required String userId,
  required bool isAdmin,
  void Function(String message)? onProgress,
}) async {
  if (!isAdmin) {
    throw Exception('Only Admin/Owner can perform full transaction reset');
  }
  // ... rest of implementation
}
```

## Phase 3: Add Audit Logging

Add audit log creation at start of reset:
```dart
await createAuditLog(
  collectionName: 'system',
  docId: 'full_reset_${DateTime.now().millisecondsSinceEpoch}',
  action: 'full_transaction_reset',
  changes: {'status': 'started'},
  userId: userId,
  userName: userName,
);
```

## Phase 4: Update UI Screen

Update `system_data_screen.dart`:
- Add admin check before calling service
- Update confirmation dialog text
- Update summary text to include new modules

## Phase 5: Testing Checklist

- [ ] Verify dispatches cleared
- [ ] Verify sales cleared
- [ ] Verify salesman stock = 0
- [ ] Verify master data intact (products, users, routes)
- [ ] Verify app opens without crash
- [ ] Verify audit log created
