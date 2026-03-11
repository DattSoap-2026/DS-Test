# Stock Flow Analysis - Dispatch & Sales Logic

## Business Logic (Correct Implementation ✅)

### Flow 1: Salesman को Stock Dispatch
```
Admin/Store Incharge → Dispatch (recipientType='salesman') → Salesman Allocated Stock ↑
```

**Code Location:** `sales_service.dart` (lines ~960-980)
```dart
if (recipientType == 'salesman' && recipientRef != null) {
  transaction.set(recipientRef, {
    'allocatedStock': {
      item['productId']: {
        'quantity': FieldValue.increment(qty),  // ✅ Stock add hota hai
        'name': pData['name'],
        'baseUnit': pData['baseUnit'],
        // ... other fields
      },
    },
  }, SetOptions(merge: true));
}
```

### Flow 2: Salesman → Customer Sale
```
Salesman → Sale (recipientType='customer') → Salesman Allocated Stock ↓
```

**Code Location:** `sales_service.dart` (lines ~920-940)
```dart
if (recipientType == 'customer') {
  final allocated = salesmanData['allocatedStock'] as Map<String, dynamic>? ?? {};
  
  for (var item in validatedItems) {
    final available = allocated[pId]['quantity'];
    
    if (available < qty) {
      throw Exception('Insufficient allocated stock');  // ⚠️ Yahan fail ho raha hai
    }
    
    transaction.update(salesmanRef, {
      'allocatedStock.$pId.quantity': FieldValue.increment(-qty),  // ✅ Stock minus hota hai
    });
  }
}
```

### Flow 3: Dealer को Direct Sale
```
Dealer Manager → Sale (recipientType='dealer') → Main Inventory Stock ↓
```

**Code Location:** `sales_service.dart` (lines ~950-970)
```dart
if (recipientType == 'dealer' || recipientType == 'salesman') {
  // Main inventory se stock minus hota hai
  transaction.update(pRef, {
    'stock': FieldValue.increment(-qty),  // ✅ Main stock se deduct
  });
}
```

## Current Problem Diagnosis

### Error Details
```
Sale ID: sales_b154b5ca-12ae-41f2-9aa9-9d4dd0498ea9
Product ID: acb5c4db-a888-4f33-ba08-fb1eab127094
Salesman: sale2@dattsoap.com
Required: 2.0
Available: 0.0
```

### Possible Root Causes

#### 1. Sale Created Before Dispatch ❌
```
Timeline:
1. Salesman creates sale (offline) - Stock check bypassed
2. Sale queued for sync
3. No dispatch happened yet
4. Sync fails - No allocated stock
```

#### 2. Dispatch Not Synced Yet ⏳
```
Timeline:
1. Admin dispatches stock to salesman
2. Dispatch stuck in queue (not synced to Firestore)
3. Salesman creates sale
4. Sale sync fails - Firestore doesn't have allocated stock yet
```

#### 3. Stock Already Consumed 📉
```
Timeline:
1. Salesman had 2.0 stock
2. Created sale (offline)
3. Another sale consumed the stock
4. First sale tries to sync - Stock already 0.0
```

## Verification Steps

### Step 1: Check Salesman's Current Allocated Stock
```dart
// In Firestore Console or Admin Panel
users/sale2@dattsoap.com
  → allocatedStock
    → acb5c4db-a888-4f33-ba08-fb1eab127094
      → quantity: ?
```

### Step 2: Check Pending Dispatches
```sql
-- In sync_queue table
SELECT * FROM sync_queue 
WHERE collection = 'sales' 
  AND action = 'add'
  AND dataJson LIKE '%recipientType":"salesman%'
  AND dataJson LIKE '%sale2@dattsoap.com%';
```

### Step 3: Check Sale Details
```dart
// Get sale from local Isar
final sale = await dbService.sales
    .filter()
    .idEqualTo('b154b5ca-12ae-41f2-9aa9-9d4dd0498ea9')
    .findFirst();

print('Sale Date: ${sale?.saleDate}');
print('Items: ${sale?.items}');
print('Salesman: ${sale?.salesmanId}');
```

## Resolution Options

### Option A: Dispatch Stock First (Recommended) ✅
```
1. Admin login
2. Create dispatch for sale2@dattsoap.com
3. Product: acb5c4db-a888-4f33-ba08-fb1eab127094
4. Quantity: 2.0+
5. Sync dispatch
6. Sale will auto-sync next cycle
```

### Option B: Delete Stuck Sale ⚠️
```dart
// Only if sale is invalid/duplicate
await dbService.db.writeTxn(() async {
  // Delete from sales table
  final sale = await dbService.sales
      .filter()
      .idEqualTo('b154b5ca-12ae-41f2-9aa9-9d4dd0498ea9')
      .findFirst();
  if (sale != null) {
    await dbService.sales.delete(sale.isarId);
  }
  
  // Delete from sync queue
  final queueItem = await dbService.syncQueue
      .getById('sales_b154b5ca-12ae-41f2-9aa9-9d4dd0498ea9');
  if (queueItem != null) {
    await dbService.syncQueue.delete(queueItem.isarId);
  }
});
```

### Option C: Modify Sale Quantity 🔧
```dart
// Reduce quantity to match available stock
await dbService.db.writeTxn(() async {
  final sale = await dbService.sales
      .filter()
      .idEqualTo('b154b5ca-12ae-41f2-9aa9-9d4dd0498ea9')
      .findFirst();
      
  if (sale != null && sale.items.isNotEmpty) {
    // Modify item quantity
    sale.items[0].quantity = 0; // or available quantity
    sale.syncStatus = SyncStatus.pending;
    await dbService.sales.put(sale);
  }
});
```

## Prevention Strategy

### 1. Pre-Sale Stock Validation (UI Level)
```dart
// Before creating sale
Future<void> validateStockBeforeSale(String salesmanId, List<SaleItem> items) async {
  final user = await dbService.users.filter().idEqualTo(salesmanId).findFirst();
  if (user == null) throw Exception('User not found');
  
  final allocated = user.allocatedStockMap;
  
  for (final item in items) {
    final available = allocated[item.productId]?.quantity ?? 0.0;
    if (available < item.quantity) {
      throw Exception(
        'Insufficient stock for ${item.name}.\n'
        'Available: $available\n'
        'Required: ${item.quantity}\n\n'
        'Please request dispatch from admin.'
      );
    }
  }
}
```

### 2. Real-time Stock Display
```dart
// In sales creation screen
Widget buildProductStockInfo(String productId, String salesmanId) {
  return FutureBuilder(
    future: _getAvailableStock(productId, salesmanId),
    builder: (context, snapshot) {
      final available = snapshot.data ?? 0.0;
      return Text(
        'Available: $available',
        style: TextStyle(
          color: available > 0 ? Colors.green : Colors.red,
        ),
      );
    },
  );
}
```

### 3. Dispatch Reminder System
```dart
// Alert salesman when stock is low
if (allocatedStock < 10) {
  await alertService.createAlert(
    title: 'Low Stock Alert',
    message: 'Your allocated stock is running low. Request dispatch from admin.',
    severity: AlertSeverity.warning,
  );
}
```

## Summary

### Logic Status: ✅ CORRECT
- Dispatch to salesman → allocatedStock increases
- Sale to customer → allocatedStock decreases
- Sale to dealer → main inventory decreases

### Current Issue: ⚠️ BUSINESS PROCESS
- Sale created without sufficient allocated stock
- Requires admin action to dispatch stock
- Not a code bug, but a workflow issue

### Recommended Action:
1. Check if dispatch is pending in queue
2. If not, create new dispatch for salesman
3. Sale will automatically sync after dispatch completes
