# Warehouse Backend - Quick Reference

## 🔐 Security Rules

### Warehouses Collection
```javascript
match /warehouses/{id} { 
  allow read: if isAuth();      // ✅ All users
  allow write: if isAdmin();    // ✅ Admin only
}
```

### Warehouse Transfers Collection
```javascript
match /warehouse_transfers/{id} { 
  allow read: if isStoreOrAdmin();        // ✅ Store Incharge, Admin
  allow create: if isStoreOrAdmin();      // ✅ Store Incharge, Admin
  allow update, delete: if isAdmin();     // ✅ Admin only
}
```

---

## 📊 Firestore Indexes

| Index | Fields | Use Case |
|-------|--------|----------|
| 1 | `fromWarehouseId` ↑, `transferDate` ↓ | Transfers FROM warehouse |
| 2 | `toWarehouseId` ↑, `transferDate` ↓ | Transfers TO warehouse |
| 3 | `productId` ↑, `transferDate` ↓ | Product transfer history |
| 4 | `transferredBy` ↑, `transferDate` ↓ | User audit trail |

---

## 🔍 Common Queries

### Get Active Warehouses
```dart
final warehouses = await warehouseService.getAllWarehouses();
```

### Get Transfer History
```dart
final transfers = await transferService.getTransferHistory(
  startDate: DateTime.now().subtract(Duration(days: 30)),
  warehouseId: 'Gita_Shed', // optional
);
```

### Check Stock at Warehouse
```dart
final balanceId = '${warehouseId}_${productId}';
final balance = await db.stockBalances.getById(balanceId);
final stock = balance?.quantity ?? 0.0;
```

### Perform Transfer
```dart
await transferService.transferStock(
  productId: product.id,
  productName: product.name,
  fromWarehouseId: 'Gita_Shed',
  fromWarehouseName: 'Gita Shed',
  toWarehouseId: 'Main',
  toWarehouseName: 'Main Warehouse',
  quantity: 50.0,
  unit: 'Box',
  transferredBy: user.id,
  transferredByName: user.name,
  notes: 'Shed full, moving to main storage',
);
```

---

## 🚀 Deployment

### Deploy Rules & Indexes
```bash
cd e:\DattSoap-main\flutter_app
firebase deploy --only firestore:rules,firestore:indexes
```

### Or use PowerShell script
```powershell
.\scripts\deploy_warehouse_backend.ps1
```

---

## 🧪 Testing

### Test Rule: Store Incharge Can Transfer
```dart
// Login as Store Incharge
await auth.signInWithEmailAndPassword(email, password);

// Should succeed
await transferService.transferStock(...);
```

### Test Rule: Regular User Cannot Transfer
```dart
// Login as regular user (not Store Incharge or Admin)
await auth.signInWithEmailAndPassword(email, password);

// Should fail with permission denied
await transferService.transferStock(...); // ❌ Permission denied
```

### Test Index: Query Transfers
```dart
// Should execute without "index required" error
final transfers = await FirebaseFirestore.instance
  .collection('warehouse_transfers')
  .where('fromWarehouseId', isEqualTo: 'Gita_Shed')
  .orderBy('transferDate', descending: true)
  .limit(10)
  .get();
```

---

## 📦 Data Structure

### Warehouse Document
```json
{
  "id": "Gita_Shed",
  "name": "Gita Shed",
  "location": "Production Shed - Gita",
  "isActive": true
}
```

### Warehouse Transfer Document
```json
{
  "id": "uuid-v4",
  "productId": "PROD123",
  "productName": "Posh DW Liq. 500ml Yellow",
  "fromWarehouseId": "Gita_Shed",
  "fromWarehouseName": "Gita Shed",
  "toWarehouseId": "Main",
  "toWarehouseName": "Main Warehouse",
  "quantity": 50,
  "unit": "Box",
  "transferredBy": "user-uid",
  "transferredByName": "John Doe",
  "transferDate": "2024-01-15T10:30:00Z",
  "notes": "Shed full",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

---

## 🔧 Troubleshooting

### Error: "Index required"
**Solution**: Deploy indexes with `firebase deploy --only firestore:indexes`

### Error: "Permission denied"
**Solution**: Check user role (must be Admin or StoreIncharge)

### Error: "Insufficient stock"
**Solution**: Verify stock_balances collection has correct quantity

---

## 📚 Full Documentation
See `WAREHOUSE_BACKEND_CONFIG.md` for complete details.
