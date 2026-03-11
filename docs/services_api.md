# Services & API Reference

**Version:** 2.7  
**Last Updated:** March 2026

---

## Overview

DattSoap ERP uses a service layer architecture for all business logic and data operations. Services handle CRUD operations, business rules, and integration with Firebase.

---

## Service Architecture

### Base Service Pattern

**File:** `lib/services/base_service.dart`

All services extend BaseService for common functionality:
- CRUD operations
- Error handling
- Logging
- Transaction support

```dart
abstract class BaseService {
  Future<T?> getById<T>(String id);
  Future<List<T>> getAll<T>();
  Future<bool> create<T>(T entity);
  Future<bool> update<T>(String id, T entity);
  Future<bool> delete(String id);
}
```

---

## Core Services

### 1. Authentication Service

**File:** `lib/services/auth_service.dart`

**Purpose:** User authentication and session management

**Methods:**
```dart
Future<User?> signIn(String email, String password);
Future<void> signOut();
Future<User?> getCurrentUser();
Future<bool> resetPassword(String email);
```

**Firebase Integration:** Firebase Auth

---

### 2. Products Service

**File:** `lib/services/products_service.dart`

**Purpose:** Product master data management

**Methods:**
```dart
Future<List<Product>> getProducts({ProductType? type});
Future<Product?> getProductById(String id);
Future<bool> createProduct(Product product);
Future<bool> updateProduct(String id, Product product);
```

**Collections:** `products` (Firestore), `products` (Isar)

---

### 3. Customers Service

**File:** `lib/services/customers_service.dart`

**Purpose:** Customer management

**Methods:**
```dart
Future<List<Customer>> getCustomers({String? routeId});
Future<Customer?> getCustomerById(String id);
Future<bool> createCustomer(Customer customer);
Future<bool> updateCustomer(String id, Customer customer);
```

**Collections:** `customers` (Firestore), `customers` (Isar)

---

### 4. Stock Service

**File:** `lib/services/stock_service.dart`

**Purpose:** Inventory management

**Methods:**
```dart
Future<double> getStockLevel(String productId, String warehouseId);
Future<bool> adjustStock(String productId, double quantity, String reason);
Future<bool> transferStock(String productId, String from, String to, double qty);
Future<List<StockMovement>> getMovements(String productId, DateTime start, DateTime end);
```

**Collections:** `stock_levels`, `stock_movements`

---

## Business Services

### 5. Sales Service

**File:** `lib/services/sales_service.dart`

**Purpose:** Sales order management

**Methods:**
```dart
Future<bool> createSale({
  required String customerId,
  required List<SaleItem> items,
  required double paymentReceived,
});
Future<List<Sale>> getSalesByUser(String userId);
Future<SalesPerformance> getPerformance(String userId, DateTime start, DateTime end);
```

**Collections:** `sales`, `sync_queue`  
**Features:** Durable queue, offline support, Firebase UID

---

### 6. Production Service

**File:** `lib/services/production_service.dart`

**Purpose:** Production batch management

**Methods:**
```dart
Future<bool> createProductionBatch({
  required DateTime batchDate,
  required String productId,
  required String bomId,
  required List<MaterialInput> inputs,
  required double outputKg,
});
Future<List<ProductionBatch>> getHistory(DateTime start, DateTime end);
```

**Collections:** `production_batches`  
**Note:** T6 migration to queue planned

---

### 7. Bhatti Service

**File:** `lib/services/bhatti_service.dart`

**Purpose:** Bhatti cooking operations

**Methods:**
```dart
Future<bool> createBhattiBatch({
  required String formulaId,
  required String departmentId,
  required List<MaterialInput> materials,
  required double outputKg,
});
Future<bool> issueMaterials(String batchId, List<MaterialIssue> materials);
Future<bool> returnMaterials(String issueId, List<MaterialReturn> materials);
```

**Collections:** `bhatti_batches`, `material_issues`

---

### 8. Cutting Batch Service

**File:** `lib/services/cutting_batch_service.dart`

**Purpose:** Cutting operations

**Methods:**
```dart
Future<bool> createCuttingBatch({
  required String semiFinishedProductId,
  required double totalBatchWeightKg,
  required String finishedGoodId,
  required int unitsProduced,
  required double cuttingWasteKg,
});
Future<CuttingYieldReport> getYieldReport(DateTime start, DateTime end);
Future<WasteAnalysisReport> getWasteAnalysis(DateTime start, DateTime end);
```

**Collections:** `cutting_batches`

---

### 9. Dispatch Service

**File:** `lib/services/dispatch_service.dart`

**Purpose:** Dispatch management

**Methods:**
```dart
Future<bool> createStockDispatch({
  required String destinationWarehouse,
  required List<DispatchItem> items,
  required String vehicleId,
});
Future<bool> createDealerDispatch({
  required String dealerId,
  required List<DispatchItem> items,
  required String vehicleId,
});
```

**Collections:** `dispatches`, `sync_queue`

---

### 10. Payments Service

**File:** `lib/services/payments_service.dart`

**Purpose:** Payment tracking

**Methods:**
```dart
Future<bool> recordPayment({
  required String customerId,
  required double amount,
  required PaymentMode mode,
});
Future<List<Payment>> getPaymentHistory(String customerId);
Future<double> getOutstanding(String customerId);
```

**Collections:** `payments`

---

## Sync Services

### 11. Sync Queue Service

**File:** `lib/services/sync_queue_service.dart`

**Purpose:** Offline sync queue management

**Methods:**
```dart
Future<bool> addToQueue(SyncQueueItem item);
Future<void> processQueue();
Future<List<SyncQueueItem>> getPendingItems();
Future<bool> retryFailed();
```

**Collections:** `sync_queue` (Isar)

---

### 12. Sync Processor Delegate

**File:** `lib/services/sync_queue_processor_delegate.dart`

**Purpose:** Collection-specific sync logic

**Methods:**
```dart
Future<bool> syncSale(SyncQueueItem item);
Future<bool> syncDispatch(SyncQueueItem item);
Future<bool> syncPayment(SyncQueueItem item);
```

---

## Firebase Services

### Firebase Auth
- Email/password authentication
- Token management
- Session handling

### Cloud Firestore
- Real-time database
- Offline persistence
- Security rules

### Firebase Storage
- Image uploads
- File storage
- CDN delivery

### Cloud Functions
- Server-side logic
- Triggers
- Scheduled tasks

---

## Service Usage Patterns

### Basic CRUD
```dart
final service = ProductsService(firebaseServices);
final products = await service.getProducts();
```

### With Error Handling
```dart
try {
  final success = await service.createSale(...);
  if (success) {
    // Show success
  }
} catch (e) {
  // Handle error
}
```

### With Offline Support
```dart
// Writes to local DB immediately
// Adds to sync queue
// Syncs when online
await salesService.createSale(...);
```

---

## Transaction Support

### Stock Adjustments
```dart
await firestore.runTransaction((transaction) async {
  // Deduct stock
  // Add to production
  // Create audit log
});
```

### ACID Compliance
- Atomic operations
- Consistent state
- Isolated transactions
- Durable writes

---

## Error Handling

### Service-Level Errors
```dart
try {
  await service.operation();
} on FirebaseException catch (e) {
  // Firebase error
} on NetworkException catch (e) {
  // Network error
} catch (e) {
  // Generic error
}
```

### User-Friendly Messages
- Network errors: "Check connection"
- Permission errors: "Access denied"
- Validation errors: Specific field errors

---

## Performance Optimization

### Caching
- Local Isar cache for master data
- In-memory cache for frequent queries
- Cache invalidation on updates

### Pagination
```dart
Future<List<T>> getPage(int page, int size);
```

### Lazy Loading
- Load data on demand
- Infinite scroll support
- Background prefetch

---

## API Conventions

### Naming
- `get*` - Read operations
- `create*` - Create operations
- `update*` - Update operations
- `delete*` - Delete operations

### Parameters
- Required parameters first
- Optional parameters with defaults
- Named parameters for clarity

### Return Types
- `Future<bool>` - Success/failure
- `Future<T?>` - Single entity (nullable)
- `Future<List<T>>` - Multiple entities

---

## Testing Services

### Unit Tests
```dart
test('createSale should add to queue', () async {
  final service = SalesService(mockFirebase);
  final result = await service.createSale(...);
  expect(result, true);
});
```

### Integration Tests
- Test with real Firestore emulator
- Test offline scenarios
- Test sync queue processing

---

## References

- [Architecture](architecture.md)
- [Sync System](sync_system.md)
- [Module Documentation](modules/)
