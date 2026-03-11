# Warehouse System - Firebase Backend Configuration

## Overview
This document describes the Firebase Firestore security rules and indexes added for the multi-warehouse inventory management system.

## Collections Added

### 1. `warehouses`
Stores warehouse/location master data (Main Warehouse, Gita Shed, Sona Shed).

**Fields:**
- `id` (string): Warehouse ID (e.g., "Main", "Gita_Shed", "Sona_Shed")
- `name` (string): Display name (e.g., "Main Warehouse (Godown)")
- `location` (string): Physical location description
- `isActive` (boolean): Whether warehouse is active

**Security Rules:**
```javascript
match /warehouses/{id} { 
  allow read: if isAuth();      // All authenticated users can read
  allow write: if isAdmin();    // Only admins can create/update/delete
}
```

**Rationale:**
- All users need to see warehouse options for transfers and inventory views
- Only admins should manage warehouse master data

---

### 2. `warehouse_transfers`
Records all stock transfers between warehouses.

**Fields:**
- `id` (string): Transfer record ID
- `productId` (string): Product being transferred
- `productName` (string): Product name (denormalized)
- `fromWarehouseId` (string): Source warehouse ID
- `fromWarehouseName` (string): Source warehouse name
- `toWarehouseId` (string): Destination warehouse ID
- `toWarehouseName` (string): Destination warehouse name
- `quantity` (number): Quantity transferred
- `unit` (string): Unit of measurement
- `transferredBy` (string): User ID who performed transfer
- `transferredByName` (string): User name (denormalized)
- `transferDate` (timestamp): When transfer occurred
- `notes` (string, optional): Transfer notes
- `batchNumber` (string, optional): Batch reference
- `createdAt` (timestamp): Record creation time

**Security Rules:**
```javascript
match /warehouse_transfers/{id} { 
  allow read: if isStoreOrAdmin();        // Store Incharge and Admin can read
  allow create: if isStoreOrAdmin();      // Store Incharge and Admin can create
  allow update, delete: if isAdmin();     // Only Admin can modify/delete
}
```

**Rationale:**
- Store Incharge needs to perform transfers between warehouses
- Only admins should be able to modify historical transfer records
- Prevents unauthorized stock movements

---

## Firestore Indexes

### Index 1: Transfers by Source Warehouse
```json
{
  "collectionGroup": "warehouse_transfers",
  "fields": [
    { "fieldPath": "fromWarehouseId", "order": "ASCENDING" },
    { "fieldPath": "transferDate", "order": "DESCENDING" }
  ]
}
```
**Use Case:** Query all transfers FROM a specific warehouse, sorted by date
**Query Example:**
```dart
await _firestore
  .collection('warehouse_transfers')
  .where('fromWarehouseId', isEqualTo: 'Gita_Shed')
  .orderBy('transferDate', descending: true)
  .get();
```

---

### Index 2: Transfers by Destination Warehouse
```json
{
  "collectionGroup": "warehouse_transfers",
  "fields": [
    { "fieldPath": "toWarehouseId", "order": "ASCENDING" },
    { "fieldPath": "transferDate", "order": "DESCENDING" }
  ]
}
```
**Use Case:** Query all transfers TO a specific warehouse, sorted by date
**Query Example:**
```dart
await _firestore
  .collection('warehouse_transfers')
  .where('toWarehouseId', isEqualTo: 'Main')
  .orderBy('transferDate', descending: true)
  .get();
```

---

### Index 3: Transfers by Product
```json
{
  "collectionGroup": "warehouse_transfers",
  "fields": [
    { "fieldPath": "productId", "order": "ASCENDING" },
    { "fieldPath": "transferDate", "order": "DESCENDING" }
  ]
}
```
**Use Case:** Track transfer history for a specific product
**Query Example:**
```dart
await _firestore
  .collection('warehouse_transfers')
  .where('productId', isEqualTo: 'PROD123')
  .orderBy('transferDate', descending: true)
  .get();
```

---

### Index 4: Transfers by User
```json
{
  "collectionGroup": "warehouse_transfers",
  "fields": [
    { "fieldPath": "transferredBy", "order": "ASCENDING" },
    { "fieldPath": "transferDate", "order": "DESCENDING" }
  ]
}
```
**Use Case:** Audit trail - see all transfers performed by a specific user
**Query Example:**
```dart
await _firestore
  .collection('warehouse_transfers')
  .where('transferredBy', isEqualTo: userId)
  .orderBy('transferDate', descending: true)
  .get();
```

---

## Related Existing Collections

### `inventory_locations`
Already exists in the system. Warehouses are stored here with `type: 'warehouse'`.

**Existing Index:**
```json
{
  "collectionGroup": "inventory_locations",
  "fields": [
    { "fieldPath": "type", "order": "ASCENDING" },
    { "fieldPath": "isActive", "order": "ASCENDING" }
  ]
}
```
**Use Case:** Query active warehouses
```dart
await db.inventoryLocations
  .filter()
  .typeEqualTo('warehouse')
  .isActiveEqualTo(true)
  .findAll();
```

---

### `stock_balances`
Already exists. Stores current stock quantity per location per product.

**Existing Index:**
```json
{
  "collectionGroup": "stock_balances",
  "fields": [
    { "fieldPath": "locationId", "order": "ASCENDING" },
    { "fieldPath": "productId", "order": "ASCENDING" }
  ]
}
```
**Use Case:** Get stock balance for a product at a specific warehouse
```dart
final balanceId = '${warehouseId}_${productId}';
final balance = await db.stockBalances.getById(balanceId);
```

---

### `department_stocks`
Already exists. Used for warehouse stock breakdown in inventory overview.

**Existing Index:**
```json
{
  "collectionGroup": "department_stocks",
  "fields": [
    { "fieldPath": "departmentId", "order": "ASCENDING" },
    { "fieldPath": "productId", "order": "ASCENDING" }
  ]
}
```
**Note:** Currently uses `departmentName` field to match warehouse names.

---

## Deployment Instructions

### 1. Deploy Firestore Rules
```bash
cd e:\DattSoap-main\flutter_app
firebase deploy --only firestore:rules
```

### 2. Deploy Firestore Indexes
```bash
firebase deploy --only firestore:indexes
```

### 3. Verify Deployment
1. Go to Firebase Console → Firestore Database → Rules
2. Verify warehouse rules are present
3. Go to Indexes tab
4. Verify 4 new warehouse_transfers indexes are created/building

---

## Testing Checklist

### Security Rules Testing

#### Warehouses Collection
- [ ] ✅ Authenticated user can read warehouses
- [ ] ✅ Non-admin cannot create warehouse
- [ ] ✅ Admin can create warehouse
- [ ] ✅ Admin can update warehouse
- [ ] ✅ Admin can delete warehouse

#### Warehouse Transfers Collection
- [ ] ✅ Store Incharge can read transfers
- [ ] ✅ Store Incharge can create transfer
- [ ] ✅ Store Incharge cannot update existing transfer
- [ ] ✅ Store Incharge cannot delete transfer
- [ ] ✅ Admin can read transfers
- [ ] ✅ Admin can create transfer
- [ ] ✅ Admin can update transfer
- [ ] ✅ Admin can delete transfer
- [ ] ❌ Regular user (non-store, non-admin) cannot read transfers
- [ ] ❌ Regular user cannot create transfer

### Index Testing

#### Test Query 1: Transfers from Gita Shed
```dart
final transfers = await FirebaseFirestore.instance
  .collection('warehouse_transfers')
  .where('fromWarehouseId', isEqualTo: 'Gita_Shed')
  .orderBy('transferDate', descending: true)
  .limit(10)
  .get();
```
- [ ] Query executes without "index required" error
- [ ] Results are sorted by date (newest first)

#### Test Query 2: Transfers to Main Warehouse
```dart
final transfers = await FirebaseFirestore.instance
  .collection('warehouse_transfers')
  .where('toWarehouseId', isEqualTo: 'Main')
  .orderBy('transferDate', descending: true)
  .limit(10)
  .get();
```
- [ ] Query executes successfully
- [ ] Results show transfers TO Main warehouse

#### Test Query 3: Product Transfer History
```dart
final transfers = await FirebaseFirestore.instance
  .collection('warehouse_transfers')
  .where('productId', isEqualTo: productId)
  .orderBy('transferDate', descending: true)
  .get();
```
- [ ] Query executes successfully
- [ ] Shows complete transfer history for product

#### Test Query 4: User Transfer Audit
```dart
final transfers = await FirebaseFirestore.instance
  .collection('warehouse_transfers')
  .where('transferredBy', isEqualTo: userId)
  .orderBy('transferDate', descending: true)
  .get();
```
- [ ] Query executes successfully
- [ ] Shows all transfers by specific user

---

## Performance Considerations

### Index Size Estimation
- **warehouse_transfers**: ~1000 transfers/month
- **Index overhead**: 4 indexes × 1000 docs = 4000 index entries/month
- **Storage impact**: Minimal (~50KB/month)

### Query Performance
- All queries use composite indexes → O(log n) lookup
- Expected query time: <100ms for 10K records
- Pagination recommended for large result sets

---

## Monitoring & Alerts

### Metrics to Track
1. **Transfer Volume**: Number of transfers per day/week
2. **Transfer Errors**: Failed transfers due to insufficient stock
3. **Warehouse Utilization**: Stock levels per warehouse
4. **User Activity**: Transfers per user (audit trail)

### Recommended Alerts
- Alert if transfer volume drops to 0 for 24 hours (system issue?)
- Alert if single warehouse exceeds 90% capacity
- Alert if unauthorized access attempts on warehouse_transfers

---

## Migration Notes

### Existing Data
- No migration needed - this is a new feature
- Existing `inventory_locations` with `type='warehouse'` will work seamlessly
- Existing `stock_balances` already support warehouse-level tracking

### Backward Compatibility
- ✅ No breaking changes to existing collections
- ✅ Existing inventory queries continue to work
- ✅ New warehouse columns in UI are additive

---

## Security Best Practices

### Role-Based Access
- **Admin**: Full access to all warehouse operations
- **Store Incharge**: Can perform transfers, view history
- **Production Supervisor**: Can view warehouses (for production assignment)
- **Regular Users**: No access to transfer operations

### Audit Trail
- All transfers record `transferredBy` and `transferredByName`
- `createdAt` timestamp for forensic analysis
- Immutable records (only admin can modify)

### Data Validation
- Client-side: Validate sufficient stock before transfer
- Server-side: Use inventory commands for atomic operations
- Firestore rules: Prevent unauthorized modifications

---

## Future Enhancements

### Potential Indexes (Add if needed)
1. **Date Range Queries**:
   ```json
   {
     "fields": [
       { "fieldPath": "transferDate", "order": "ASCENDING" }
     ]
   }
   ```

2. **Multi-Warehouse Queries**:
   ```json
   {
     "fields": [
       { "fieldPath": "fromWarehouseId", "order": "ASCENDING" },
       { "fieldPath": "toWarehouseId", "order": "ASCENDING" },
       { "fieldPath": "transferDate", "order": "DESCENDING" }
     ]
   }
   ```

3. **Product + Warehouse Queries**:
   ```json
   {
     "fields": [
       { "fieldPath": "productId", "order": "ASCENDING" },
       { "fieldPath": "fromWarehouseId", "order": "ASCENDING" },
       { "fieldPath": "transferDate", "order": "DESCENDING" }
     ]
   }
   ```

### Feature Roadmap
- [ ] Warehouse capacity limits
- [ ] Auto-transfer rules (when shed reaches X% capacity)
- [ ] Transfer approval workflow
- [ ] Warehouse-wise reorder points
- [ ] Transfer cost tracking
- [ ] Warehouse performance analytics

---

## Support & Troubleshooting

### Common Issues

**Issue 1: "Index required" error**
- **Cause**: Query uses fields not covered by existing indexes
- **Solution**: Check error message for required index, add to firestore.indexes.json, deploy

**Issue 2: Permission denied on warehouse_transfers**
- **Cause**: User role doesn't have access
- **Solution**: Verify user has Admin or StoreIncharge role

**Issue 3: Transfer fails with "Insufficient stock"**
- **Cause**: Stock balance not updated or query timing issue
- **Solution**: Check stock_balances collection, verify inventory command was applied

### Debug Queries

**Check warehouse stock:**
```dart
final balanceId = '${warehouseId}_${productId}';
final balance = await db.stockBalances.getById(balanceId);
print('Stock: ${balance?.quantity ?? 0}');
```

**Check recent transfers:**
```dart
final transfers = await FirebaseFirestore.instance
  .collection('warehouse_transfers')
  .orderBy('transferDate', descending: true)
  .limit(5)
  .get();
transfers.docs.forEach((doc) => print(doc.data()));
```

---

## Contact & Maintenance

**Last Updated**: 2024
**Maintained By**: DattSoap Development Team
**Documentation Version**: 1.0
