# 🔧 ERP CRITICAL ISSUES - FIX IMPLEMENTATION PLAN

**Document Type:** Technical Fix Specification  
**Priority:** Production-Critical  
**Target:** DattSoap Offline-First ERP System  
**Date:** 2026-02-05  

---

## 📋 FIX PRIORITY MATRIX

| Priority | Issue | Risk Level | Fix Complexity |
|----------|-------|------------|----------------|
| 🔴 P1 | SKU Uniqueness | CRITICAL | Low |
| 🔴 P1 | Direct Stock Edit Prevention | CRITICAL | Medium |
| 🔴 P1 | Negative Stock Prevention | CRITICAL | Medium |
| 🔴 P1 | Stock Ledger Running Balance | CRITICAL | Low |
| 🔴 P1 | Van Sale Stock Re-validation | CRITICAL | Medium |
| 🟠 P2 | Duplicate Invoice Prevention | HIGH | Low |
| 🟠 P2 | Sale Cancel/Edit Rollback | HIGH | High |
| 🟠 P2 | Partial PO Receipt | HIGH | Medium |
| 🟡 P3 | Inventory Reconciliation | MEDIUM | Medium |
| 🟡 P3 | In-Memory Filter Optimization | MEDIUM | Medium |

---

## 🔴 CRITICAL ISSUE #1: Missing SKU Uniqueness Enforcement

### Why It's Dangerous
- Multiple products with same SKU break inventory tracking
- Purchase orders reference wrong products
- Sales reports aggregate incorrect products
- Barcode scanning fails (multiple matches)

### Root Cause
**Location:** `products_service.dart` → `createProduct()` (Line ~100-150)  
**Problem:** No validation before inserting new product.

```dart
// CURRENT CODE (BAD):
Future<Product> createProduct({required String name, required String sku, ...}) async {
  final productId = const Uuid().v4();
  final entity = _mapToEntity(...);
  await _dbService.products.put(entity);  // ❌ No SKU check!
}
```

### Exact Fix Strategy

**Step 1:** Add SKU validation helper to `ProductsService`

```dart
// ADD to products_service.dart (new method)

/// Validates that SKU is unique among active products.
/// Returns null if valid, or error message if duplicate exists.
Future<String?> _validateSkuUnique(String sku, {String? excludeId}) async {
  if (sku.trim().isEmpty) return null; // Empty SKUs allowed (auto-generated)
  
  final existing = await _dbService.products
      .filter()
      .skuEqualTo(sku.trim())
      .and()
      .isDeletedEqualTo(false)
      .findFirst();
  
  if (existing != null && existing.id != excludeId) {
    return 'SKU "$sku" already exists for product: ${existing.name}';
  }
  
  return null;
}
```

**Step 2:** Add validation to `createProduct()`

```dart
// MODIFY createProduct() - add after parameter validation, before DB write
Future<Product> createProduct({required String name, required String sku, ...}) async {
  // NEW: SKU Uniqueness Validation
  final skuError = await _validateSkuUnique(sku);
  if (skuError != null) {
    throw Exception(skuError);
  }
  
  // ... rest of existing code
}
```

**Step 3:** Add validation to `updateProduct()` (for SKU changes)

```dart
// MODIFY updateProduct() - add SKU check if sku parameter is provided
Future<void> updateProduct({required String id, String? sku, ...}) async {
  // NEW: SKU Uniqueness Validation (exclude current product)
  if (sku != null) {
    final skuError = await _validateSkuUnique(sku, excludeId: id);
    if (skuError != null) {
      throw Exception(skuError);
    }
  }
  
  // ... rest of existing code
}
```

### Files to Modify
- `lib/services/products_service.dart` (Lines 100-200)

### Locking Rule
```
🔒 LOCK: After this fix, SKU uniqueness is ENFORCED.
- Never remove this validation
- Never allow bypass for non-admins
- SKU field LOCKED for edit after product is used in transactions
```

---

## 🔴 CRITICAL ISSUE #2: Product Stock Can Be Edited Directly

### Why It's Dangerous
- Direct stock edit bypasses Stock Ledger → Audit trail broken
- Stock figure desyncs from ledger entries
- Financial reconciliation impossible
- Fraud detection fails

### Root Cause
**Location:** `products_service.dart` → `updateProduct()` (Line ~350-450)  
**Problem:** Stock parameter is accepted and directly written.

```dart
// CURRENT CODE (BAD):
if (stock != null) entity.stock = stock;  // ❌ DANGEROUS!
```

### Exact Fix Strategy

**Step 1:** Remove `stock` parameter from `updateProduct()` signature

```dart
// MODIFY updateProduct() signature - REMOVE stock parameter

// BEFORE:
Future<void> updateProduct({
  required String id,
  double? stock,  // ❌ REMOVE THIS
  // ... other params
}) async { ... }

// AFTER:
Future<void> updateProduct({
  required String id,
  // stock REMOVED - Use InventoryService.addStockMovement() instead
  // ... other params
}) async { ... }
```

**Step 2:** Add documentation comment at method start

```dart
/// Updates a product's master data.
/// 
/// ⚠️ ARCHITECTURE LOCK: Stock cannot be modified via this method.
/// Stock MUST only be updated through:
/// - InventoryService.processBulkGRN() for purchases
/// - SalesService._createSaleLocal() for sales
/// - InventoryService.adjustStock() for adjustments
/// 
/// Any attempt to modify stock directly will be ignored.
Future<void> updateProduct({...}) async {
  // Remove any stock-related code inside
}
```

**Step 3:** Clean up UI that passes stock to updateProduct

**Location:** `product_add_edit_screen.dart` (Line ~392-425)

```dart
// CURRENT CODE (BAD) in product_add_edit_screen.dart:
await inventoryRepo.saveProduct(entity);  // ❌ This sets stock directly!

// FIX: Remove stock setting from entity creation for EDIT mode
// Stock should only be set for NEW products (initial = 0)
if (widget.product == null) {
  // NEW product - stock is 0 by default, that's fine
  entity.stock = 0;
} else {
  // EXISTING product - preserve existing stock, don't overwrite
  final existingProduct = await inventoryRepo.getProduct(result.id);
  entity.stock = existingProduct?.stock ?? widget.product!.stock;
}
```

### Files to Modify
- `lib/services/products_service.dart`
- `lib/screens/management/product_add_edit_screen.dart`

### Locking Rule
```
🔒 ABSOLUTE LOCK: Product.stock is READONLY in ProductsService.
- NEVER add stock parameter to updateProduct()
- ALL stock changes MUST go through InventoryService
- EVERY stock change MUST create a StockLedgerEntity
```

---

## 🔴 CRITICAL ISSUE #3: Negative Stock Possible (Race Condition)

### Why It's Dangerous
- Offline sales can overdraw stock when synced
- Multiple devices selling same product simultaneously
- Reports show impossible negative quantities
- Financial statements corrupted

### Root Cause
**Locations:**  
1. `sales_service.dart` → `_createSaleLocal()` - Has check but sync can still cause negative
2. `inventory_service.dart` → `processBulkGRN()` - No issue (addition)
3. `inventory_service.dart` → `adjustStock()` - Has check ✅
4. `inventory_service.dart` → `dispatchToSalesman()` - Has check ✅
5. `inventory_service.dart` → `transferToDepartment()` - Missing check!

**Problem:** Some paths check stock, others don't. Sync doesn't re-validate.

### Exact Fix Strategy

**Step 1:** Create centralized stock validation helper

```dart
// ADD to inventory_service.dart (new method)

/// Validates that sufficient stock exists for a deduction.
/// Throws exception if stock would go negative.
/// 
/// MUST be called inside transaction BEFORE any stock deduction.
Future<void> _validateSufficientStock({
  required String productId,
  required String productName,
  required double quantityNeeded,
}) async {
  final product = await _dbService.products.get(fastHash(productId));
  if (product == null) {
    throw Exception('Product not found: $productName');
  }
  
  final currentStock = product.stock ?? 0.0;
  if (currentStock < quantityNeeded) {
    throw Exception(
      'Insufficient stock for $productName.\n'
      'Available: ${currentStock.toStringAsFixed(2)} ${product.baseUnit}\n'
      'Required: ${quantityNeeded.toStringAsFixed(2)} ${product.baseUnit}\n'
      'Shortfall: ${(quantityNeeded - currentStock).toStringAsFixed(2)}'
    );
  }
}
```

**Step 2:** Add validation to `transferToDepartment()` (currently missing)

```dart
// MODIFY transferToDepartment() - add validation inside transaction
Future<bool> transferToDepartment({...}) async {
  await _dbService.db.writeTxn(() async {
    for (final item in items) {
      final productId = item['productId'] as String;
      final quantity = (item['quantity'] as num).toDouble();
      final productName = item['name'] as String? ?? 'Unknown';
      
      // NEW: Validate stock BEFORE deduction
      await _validateSufficientStock(
        productId: productId,
        productName: productName,
        quantityNeeded: quantity,
      );
      
      // ... rest of existing deduction logic
    }
  });
}
```

**Step 3:** Enhance `SalesService.performSync()` to re-validate stock

```dart
// MODIFY sales_service.dart → performSync() for 'add' action
// After the items loop, before commit:

// RE-VALIDATE: Ensure stock still sufficient at sync time
for (var item in items) {
  final pRef = firestore.collection('products').doc(item['productId']);
  final pSnap = await transaction.get(pRef);
  
  if (!pSnap.exists) {
    // Product was deleted - reject sale
    throw Exception('Product ${item['name']} no longer exists. Sale rejected.');
  }
  
  final pData = pSnap.data() as Map<String, dynamic>;
  final serverStock = (pData['stock'] as num? ?? 0).toDouble();
  final qtyNeeded = (item['quantity'] as num).toDouble();
  
  if (serverStock < qtyNeeded && recipientType != 'customer') {
    // For direct sales, reject if stock insufficient
    throw Exception(
      'Stock depleted since sale was created offline. '
      '${item['name']}: Available $serverStock, Need $qtyNeeded'
    );
  }
}
```

**Step 4:** Add absolute minimum stock constraint at DB level (Isar index observer)

```dart
// ADD to base_entity.dart or inventory_service.dart
// This is a safety net - should never trigger if validations work

extension ProductStockSafety on ProductEntity {
  /// Ensures stock never goes below zero.
  /// Call this before any save operation.
  void enforceNonNegativeStock() {
    if ((stock ?? 0) < 0) {
      throw StateError(
        'CRITICAL: Attempted to save negative stock for product $name. '
        'This indicates a bug in the calling code. Stock: $stock'
      );
    }
  }
}
```

### Files to Modify
- `lib/services/inventory_service.dart` (add helper + calls)
- `lib/services/sales_service.dart` (sync re-validation)
- `lib/data/local/entities/product_entity.dart` (safety extension)

### Locking Rule
```
🔒 INVARIANT: stock >= 0 ALWAYS
- EVERY deduction path MUST call _validateSufficientStock()
- Sync operations MUST re-validate at server time
- Negative stock save MUST throw exception (never silent)
```

---

## 🔴 CRITICAL ISSUE #4: Stock Ledger Running Balance Incorrect

### Why It's Dangerous
- Ledger reports show wrong balances
- Cannot reconcile ledger vs actual stock
- Audit trail is misleading
- Compliance failures

### Root Cause
**Location:** `inventory_service.dart` → `_createLedgerEntry()` (Line 582-624)  
**Problem:** The comment says "after update" but code reads stock BEFORE caller updates it in some paths.

```dart
// CURRENT CODE (AMBIGUOUS):
final product = await _dbService.products.get(fastHash(productId));
final double currentStock = product?.stock ?? 0.0;
// ...
..runningBalance = currentStock // ← This is BEFORE update if called first!
```

**Analysis:** The current implementation assumes caller updates stock FIRST, then calls `_createLedgerEntry()`. This is correct in most places but not all.

### Exact Fix Strategy

**Step 1:** Change `_createLedgerEntry()` to accept explicit running balance

```dart
// MODIFY _createLedgerEntry() signature and logic

Future<void> _createLedgerEntry({
  required String productId,
  required String warehouseId,
  required String transactionType,
  required double quantityChange,
  required double runningBalanceAfter, // NEW: Caller MUST provide final balance
  String? unit,
  required String performedBy,
  required String reason,
  String? referenceId,
  String? notes,
}) async {
  try {
    final now = DateTime.now();
    
    // Get unit from product if not provided
    final product = await _dbService.products.get(fastHash(productId));
    final effectiveUnit = unit ?? product?.baseUnit ?? 'Unit';

    final entry = StockLedgerEntity()
      ..id = generateId()
      ..productId = productId
      ..warehouseId = warehouseId
      ..transactionDate = now
      ..transactionType = transactionType
      ..referenceId = referenceId
      ..quantityChange = quantityChange
      ..runningBalance = runningBalanceAfter // ✅ Explicit from caller
      ..unit = effectiveUnit
      ..performedBy = performedBy
      ..notes = notes
      ..syncStatus = SyncStatus.pending
      ..updatedAt = now;

    await _dbService.stockLedger.put(entry);
  } catch (e) {
    handleError(e, '_createLedgerEntry');
    rethrow;
  }
}
```

**Step 2:** Update ALL callers to pass explicit `runningBalanceAfter`

**Example for `processBulkGRN()` (Line 1176):**

```dart
// CURRENT (implicit):
await _createLedgerEntry(
  productId: item['productId'],
  warehouseId: 'Main',
  transactionType: 'GRN',
  quantityChange: (item['quantity'] as num).toDouble(),
  performedBy: userId,
  reason: 'Purchase',
  referenceId: referenceId,
  notes: 'GRN for PO: $referenceNumber',
);

// FIXED (explicit):
product.stock = oldStock + incomingQty;  // First update stock
await _dbService.products.put(product);   // Save product

await _createLedgerEntry(
  productId: item['productId'],
  warehouseId: 'Main',
  transactionType: 'GRN',
  quantityChange: incomingQty,
  runningBalanceAfter: product.stock,     // ✅ Pass the AFTER balance
  performedBy: userId,
  reason: 'Purchase',
  referenceId: referenceId,
  notes: 'GRN for PO: $referenceNumber',
);
```

**Step 3:** Update all 9 caller locations:
1. Line 558 - `addStockMovement()`
2. Line 774 - `transferToDepartment()` 
3. Line 839 - `returnFromDepartment()`
4. Line 915 - `adjustStock()`
5. Line 1059 - `dispatchToSalesman()`
6. Line 1176 - `processBulkGRN()`
7. Line 1244 - `processGRN()`
8. Line 1334 - Additional caller

### Files to Modify
- `lib/services/inventory_service.dart` (signature + 9 call sites)

### Locking Rule
```
🔒 MANDATORY: runningBalanceAfter MUST be provided explicitly
- Caller MUST update product.stock FIRST
- Caller MUST pass product.stock as runningBalanceAfter
- Order: Update → Put → CreateLedger
```

---

## 🔴 CRITICAL ISSUE #5: Van Sale Stock Sync Re-validation Missing

### Why It's Dangerous
- Salesman sells entire allocated stock offline
- Another salesman's sale syncs first, depletes shared product
- First salesman's sale syncs → stock goes negative
- Firebase corrupt, Isar corrupt

### Root Cause
**Location:** `sales_service.dart` → `performSync()` (Line 32-210)  
**Problem:** For `recipientType == 'customer'` (van sale), we validate allocated stock but there's still a race condition between check and update.

### Exact Fix Strategy

**Step 1:** Use Firestore transaction locking properly

```dart
// MODIFY performSync() for customer sales
// Use get() BEFORE any update to lock the document

if (recipientType == 'customer') {
  // Get fresh allocated stock snapshot INSIDE transaction
  final sData = salesmanSnap.data() as Map<String, dynamic>;
  final allocated = Map<String, dynamic>.from(
    sData['allocatedStock'] as Map<String, dynamic>? ?? {}
  );

  // VALIDATE ALL ITEMS FIRST (fail fast)
  for (var item in items) {
    final pId = item['productId'];
    final qty = (item['quantity'] as num).toDouble();
    final isFree = item['isFree'] == true;

    final stockItem = allocated[pId] as Map<String, dynamic>? ?? {};
    final available = isFree
        ? (stockItem['freeQuantity'] as num? ?? 0).toDouble()
        : (stockItem['quantity'] as num? ?? 0).toDouble();

    if (available < qty) {
      // REJECT the sale - stock was sold by another device
      throw Exception(
        'SYNC CONFLICT: Allocated stock depleted for $pId. '
        'Available: $available, Required: $qty. '
        'This sale ID ${data['id']} is rejected. '
        'Please create a new sale with available stock.'
      );
    }
  }

  // NOW proceed with updates (all validated)
  for (var item in items) {
    // ... existing update logic
  }
}
```

**Step 2:** Add sync conflict status to Sale

```dart
// ADD to sales_types.dart - new status
enum SaleStatus { 
  created, 
  delivered, 
  completed, 
  cancelled,
  syncFailed,  // NEW: Sale rejected during sync
}
```

**Step 3:** Handle sync failure gracefully

```dart
// In SalesService, catch sync failure and update local record

try {
  await firestore.runTransaction((transaction) async {
    // ... existing sync logic
  });
  
  // Update local record to synced
  await updateInLocal(data['id'], {'isSynced': true});
} catch (e) {
  if (e.toString().contains('SYNC CONFLICT')) {
    // Mark sale as failed, don't retry
    await updateInLocal(data['id'], {
      'status': 'syncFailed',
      'syncError': e.toString(),
      'isSynced': false,
    });
    
    // Rollback local stock changes
    await _rollbackLocalSale(data);
    
    // Notify user
    throw Exception(
      'Sale could not sync: Stock was sold by another device. '
      'Please review and re-create this sale.'
    );
  }
  rethrow;
}
```

### Files to Modify
- `lib/services/sales_service.dart`
- `lib/models/types/sales_types.dart`

### Locking Rule
```
🔒 SYNC SAFETY: Van sales MUST be re-validated at sync time
- Always check allocated stock inside Firestore transaction
- REJECT stale sales (don't force through)
- Mark rejected sales as 'syncFailed' with reason
```

---

## 🟠 PRIORITY 2: Duplicate Invoice Prevention

### Why It's Dangerous
- Same supplier invoice processed twice
- Double stock addition
- Double payment made
- Financial loss

### Root Cause
**Location:** `purchase_order_service.dart` → `createPurchaseOrder()`  
**Problem:** No field for supplier invoice, no uniqueness check.

### Exact Fix Strategy

**Step 1:** Add supplier invoice fields to `PurchaseOrder` model

```dart
// MODIFY purchase_order_types.dart - add fields

class PurchaseOrder {
  // Existing fields...
  
  final String? supplierInvoiceNumber;  // NEW
  final String? supplierInvoiceDate;    // NEW
  
  // Update constructor, fromJson, toJson, copyWith
}
```

**Step 2:** Add validation to `createPurchaseOrder()`

```dart
Future<String> createPurchaseOrder({
  String? supplierInvoiceNumber,
  String? supplierInvoiceDate,
  // ... existing params
}) async {
  // NEW: Check for duplicate invoice
  if (supplierInvoiceNumber != null && supplierInvoiceNumber.isNotEmpty) {
    final allPOs = await getAllPurchaseOrders();
    final duplicate = allPOs.where((po) => 
      po.supplierId == supplierId &&
      po.supplierInvoiceNumber == supplierInvoiceNumber
    ).firstOrNull;
    
    if (duplicate != null) {
      throw Exception(
        'Duplicate invoice: $supplierInvoiceNumber already exists for this supplier.\n'
        'Existing PO: ${duplicate.poNumber} dated ${duplicate.createdAt}'
      );
    }
  }
  
  // ... rest of creation logic
}
```

### Files to Modify
- `lib/models/types/purchase_order_types.dart`
- `lib/services/purchase_order_service.dart`
- `lib/screens/procurement/purchase_order_screen.dart` (UI field)
- `lib/data/local/entities/purchase_order_entity.dart` (if exists)

### Locking Rule
```
🔒 UNIQUE CONSTRAINT: (supplierId + supplierInvoiceNumber) is UNIQUE
- Validation at creation time
- Cannot edit invoice number after creation
```

---

## 🟠 PRIORITY 2: Sale Cancel/Edit with Rollback

### Why It's Dangerous
- Wrong sale cannot be corrected
- Stock remains deducted forever
- Customer balance incorrect
- Reports include erroneous data

### Root Cause
**Location:** `sales_service.dart`  
**Problem:** No `cancelSale()` or `editSale()` methods exist.

### Exact Fix Strategy

**Step 1:** Add `cancelSale()` method to SalesService

```dart
/// Cancels a sale and reverses all stock/balance changes.
/// 
/// Requirements:
/// - Sale must exist
/// - Sale must not already be cancelled
/// - Stock must be returned atomically
/// - Customer balance must be restored
/// 
/// Creates audit trail for the cancellation.
Future<void> cancelSale({
  required String saleId,
  required String cancelledBy,
  required String cancelledByName,
  required String reason,
}) async {
  final saleMap = await findInLocal(saleId);
  if (saleMap == null) throw Exception('Sale not found: $saleId');
  
  final sale = Sale.fromJson(saleMap);
  
  if (sale.status == SaleStatus.cancelled) {
    throw Exception('Sale is already cancelled');
  }
  
  final now = DateTime.now();
  
  // ATOMIC TRANSACTION: Rollback everything
  await _dbService.db.writeTxn(() async {
    final items = sale.items;
    
    if (sale.recipientType == RecipientType.customer) {
      // VAN SALE: Restore salesman allocated stock
      final user = await _dbService.users
          .filter()
          .idEqualTo(sale.salesmanId)
          .findFirst();
      
      if (user != null) {
        final allocatedMap = user.getAllocatedStock();
        
        for (var item in items) {
          final stockItem = allocatedMap[item.productId];
          if (stockItem != null) {
            if (item.isFree) {
              allocatedMap[item.productId] = stockItem.copyWith(
                freeQuantity: (stockItem.freeQuantity ?? 0) + item.quantity.toInt(),
              );
            } else {
              allocatedMap[item.productId] = stockItem.copyWith(
                quantity: stockItem.quantity + item.quantity.toInt(),
              );
            }
          }
        }
        
        user.setAllocatedStock(allocatedMap);
        user.syncStatus = SyncStatus.pending;
        user.updatedAt = now;
        await _dbService.users.put(user);
      }
      
      // Restore customer balance
      final customer = await _dbService.customers
          .filter()
          .idEqualTo(sale.recipientId)
          .findFirst();
      
      if (customer != null) {
        customer.balance -= sale.totalAmount;
        customer.updatedAt = now;
        customer.syncStatus = SyncStatus.pending;
        await _dbService.customers.put(customer);
      }
      
    } else {
      // DIRECT SALE: Restore warehouse stock
      for (var item in items) {
        final product = await _dbService.products.get(fastHash(item.productId));
        if (product != null) {
          product.stock = (product.stock ?? 0) + item.quantity;
          product.syncStatus = SyncStatus.pending;
          product.updatedAt = now;
          await _dbService.products.put(product);
          
          // Create reversal ledger entry
          final ledger = StockLedgerEntity()
            ..id = generateId()
            ..productId = item.productId
            ..warehouseId = 'Main'
            ..transactionDate = now
            ..transactionType = 'SALE_CANCEL_RETURN'
            ..quantityChange = item.quantity.toDouble()
            ..runningBalance = product.stock!
            ..unit = item.baseUnit
            ..performedBy = cancelledBy
            ..notes = 'Sale cancelled: $saleId - $reason'
            ..referenceId = saleId
            ..syncStatus = SyncStatus.pending
            ..updatedAt = now;
          await _dbService.stockLedger.put(ledger);
        }
      }
    }
  });
  
  // Update sale record
  await updateInLocal(saleId, {
    'status': 'cancelled',
    'cancelledBy': cancelledBy,
    'cancelledByName': cancelledByName,
    'cancelReason': reason,
    'cancelledAt': now.toIso8601String(),
  });
  
  // Sync cancellation
  await syncToFirebase('update', {
    'id': saleId,
    'status': 'cancelled',
    'cancelledBy': cancelledBy,
    'cancelReason': reason,
    'cancelledAt': now.toIso8601String(),
  }, collectionName: salesCollection);
}
```

### Files to Modify
- `lib/services/sales_service.dart`
- `lib/models/types/sales_types.dart` (add cancelledBy, cancelReason fields)
- `lib/screens/sales/sale_detail_screen.dart` (add Cancel button)

### Locking Rule
```
🔒 CANCEL AUDIT: Cancelled sales create reverse ledger entries
- Original sale preserved (status changed)
- New ledger entries with type SALE_CANCEL_RETURN
- Customer balance restored
- Full audit trail maintained
```

---

## 🟠 PRIORITY 2: Partial PO Receipt Support

### Why It's Dangerous
- Can only receive full quantity
- Partial shipments force workarounds
- Business flexibility lost
- Data doesn't match real-world receipts

### Root Cause
**Location:** `purchase_order_service.dart` → `receiveStock()`  
**Problem:** Logic supports partial qty but status always becomes 'received'.

### Exact Fix Strategy

**Step 1:** Track received quantities per item

```dart
// MODIFY receiveStock() logic

Future<void> receiveStock({...}) async {
  // ... existing validation
  
  // Calculate total ordered vs total received
  double totalOrdered = 0;
  double totalReceiving = 0;
  
  final updatedItems = <Map<String, dynamic>>[];
  
  for (final item in po.items) {
    totalOrdered += item.quantity;
    
    final previouslyReceived = item.receivedQuantity ?? 0;
    final receivingNow = receivedQtys?[item.productId] ?? (item.quantity - previouslyReceived);
    
    // Validate not over-receiving
    if (previouslyReceived + receivingNow > item.quantity) {
      throw Exception(
        'Over-receiving for ${item.name}: '
        'Ordered ${item.quantity}, already received $previouslyReceived, '
        'trying to receive $receivingNow'
      );
    }
    
    totalReceiving += previouslyReceived + receivingNow;
    
    updatedItems.add({
      ...item.toJson(),
      'receivedQuantity': previouslyReceived + receivingNow,
    });
  }
  
  // Determine final status
  final newStatus = (totalReceiving >= totalOrdered)
      ? PurchaseOrderStatus.received
      : PurchaseOrderStatus.partiallyReceived;  // NEW STATUS
  
  // Update PO
  await updatePurchaseOrder(poId, {
    'status': newStatus.value,
    'items': updatedItems,
    'lastReceivedAt': getCurrentTimestamp(),
  });
}
```

**Step 2:** Add new status to enum

```dart
// MODIFY purchase_order_types.dart

enum PurchaseOrderStatus {
  draft,
  ordered,
  partiallyReceived,  // NEW
  received,
  cancelled,
}
```

### Files to Modify
- `lib/services/purchase_order_service.dart`
- `lib/models/types/purchase_order_types.dart`

### Locking Rule
```
🔒 PARTIAL RECEIPT: PO remains editable until fully received
- 'partiallyReceived' allows additional GRNs
- Only 'received' status is final
- Items track individual receivedQuantity
```

---

## 🟡 PRIORITY 3: Inventory Reconciliation Report

### Why It's Dangerous
- Cannot detect stock discrepancies
- Manual counts don't reconcile
- Shrinkage/theft undetected
- Financial audits fail

### Root Cause
**Location:** No reconciliation method exists  
**Problem:** No automated check for `product.stock == SUM(ledger.quantityChange)`

### Exact Fix Strategy

**Step 1:** Add reconciliation method to InventoryService

```dart
/// Reconciles product stock against stock ledger entries.
/// Returns list of discrepancies where product.stock != ledger sum.
Future<List<StockDiscrepancy>> reconcileInventory({
  List<String>? productIds,  // Optional filter
}) async {
  final discrepancies = <StockDiscrepancy>[];
  
  // Get products to check
  List<ProductEntity> products;
  if (productIds != null && productIds.isNotEmpty) {
    products = await Future.wait(
      productIds.map((id) => _dbService.products.get(fastHash(id)))
    ).then((list) => list.whereType<ProductEntity>().toList());
  } else {
    products = await _dbService.products
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
  }
  
  for (final product in products) {
    // Sum all ledger entries for this product
    final ledgerEntries = await _dbService.stockLedger
        .filter()
        .productIdEqualTo(product.id)
        .findAll();
    
    final ledgerSum = ledgerEntries.fold<double>(
      0.0,
      (sum, entry) => sum + entry.quantityChange,
    );
    
    final productStock = product.stock ?? 0.0;
    final difference = productStock - ledgerSum;
    
    // Allow small floating point tolerance
    if (difference.abs() > 0.001) {
      discrepancies.add(StockDiscrepancy(
        productId: product.id,
        productName: product.name ?? 'Unknown',
        productSku: product.sku ?? '',
        systemStock: productStock,
        ledgerStock: ledgerSum,
        difference: difference,
        ledgerEntryCount: ledgerEntries.length,
      ));
    }
  }
  
  return discrepancies;
}

// Model class
class StockDiscrepancy {
  final String productId;
  final String productName;
  final String productSku;
  final double systemStock;
  final double ledgerStock;
  final double difference;
  final int ledgerEntryCount;
  
  StockDiscrepancy({...});
  
  String get explanation {
    if (difference > 0) {
      return 'Stock is HIGHER than ledger by ${difference.abs().toStringAsFixed(2)}. '
             'Possible: Missing OUT entries or manual stock increase.';
    } else {
      return 'Stock is LOWER than ledger by ${difference.abs().toStringAsFixed(2)}. '
             'Possible: Missing IN entries or data corruption.';
    }
  }
}
```

### Files to Modify
- `lib/services/inventory_service.dart`
- `lib/models/types/inventory_types.dart` (new file or add to existing)
- New screen: `lib/screens/reports/stock_reconciliation_screen.dart`

### Locking Rule
```
🔒 RECONCILIATION: Run weekly/monthly as standard practice
- Discrepancy > 0.001 is flagged
- Create adjustment entries to fix discrepancies
- Log all reconciliation runs
```

---

## 📋 IMPLEMENTATION CHECKLIST

### Week 1 (CRITICAL)
- [ ] Fix #1: SKU Uniqueness (`products_service.dart`)
- [ ] Fix #2: Block Direct Stock Edit (`products_service.dart`, `product_add_edit_screen.dart`)
- [ ] Fix #3: Negative Stock Prevention (`inventory_service.dart`, `sales_service.dart`)
- [ ] Fix #4: Running Balance Fix (`inventory_service.dart` - 9 call sites)
- [ ] Fix #5: Van Sale Sync Validation (`sales_service.dart`)

### Week 2 (HIGH)
- [ ] Fix #6: Duplicate Invoice Prevention (`purchase_order_service.dart`)
- [ ] Fix #7: Sale Cancellation (`sales_service.dart`)
- [ ] Fix #8: Partial PO Receipt (`purchase_order_service.dart`)

### Week 3 (MEDIUM)
- [ ] Fix #9: Reconciliation Report (`inventory_service.dart`)
- [ ] Fix #10: Query Optimization (`products_service.dart`, `sales_service.dart`)

---

## 🔒 MASTER LOCKING RULES

After implementing all fixes, these modules should be **LOCKED**:

```
🔒 ProductEntity.stock
   → READONLY via ProductsService
   → ONLY modifiable via InventoryService atomic transactions

🔒 StockLedgerEntity
   → APPEND-ONLY (no edits/deletes)
   → EVERY stock change creates entry
   → runningBalanceAfter is MANDATORY

🔒 SKU Uniqueness
   → ENFORCED on create and update
   → SKU LOCKED after first transaction

🔒 Invoice Uniqueness
   → (supplierId + invoiceNumber) UNIQUE
   → Checked at PO creation

🔒 Negative Stock
   → INVARIANT: stock >= 0
   → Validated at all deduction points
   → Re-validated at sync time
```

---

**Document Version:** 1.0  
**Last Updated:** 2026-02-05  
**Author:** Senior ERP Architect
