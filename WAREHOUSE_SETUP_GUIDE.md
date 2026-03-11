# Multi-Warehouse Quick Setup Guide

## 🚀 5-Minute Setup

### Step 1: Seed Warehouses (One-time)

Run this code once to create initial warehouses:

```dart
// In your main.dart or bootstrap function
final warehouseService = WarehouseService();
await warehouseService.seedInitialWarehouses();
```

This creates:
- **Main** - Main Warehouse (Godown)
- **Gita_Shed** - Gita Shed (Production)
- **Sona_Shed** - Sona Shed (Production)

### Step 2: Assign Warehouses to Supervisors

Update supervisor users in Firestore `users` collection:

**For Gita Shed Supervisor:**
```json
{
  "assignedWarehouseId": "Gita_Shed",
  "assignedWarehouseName": "Gita Shed"
}
```

**For Sona Shed Supervisor:**
```json
{
  "assignedWarehouseId": "Sona_Shed",
  "assignedWarehouseName": "Sona Shed"
}
```

### Step 3: Set Opening Stock

1. Login as Admin
2. Go to **Inventory → Opening Stock**
3. Select warehouse from dropdown
4. Enter quantities for products
5. Click ✓ to save

**Example:**
- Warehouse: **Gita Shed**
- Product: Soap Bar 175g
- Quantity: 500 PCS
- Rate: 25 INR

### Step 4: Production Entry (Auto-Warehouse)

1. Supervisor logs in (e.g., Gita Shed supervisor)
2. Goes to **Production → Cutting Entry**
3. Creates production batch
4. **Stock automatically goes to Gita Shed** ✅

### Step 5: Transfer Stock (When Shed is Full)

```dart
// In your transfer screen/service
await warehouseTransferService.transferStock(
  productId: product.id,
  productName: product.name,
  fromWarehouseId: 'Gita_Shed',
  fromWarehouseName: 'Gita Shed',
  toWarehouseId: 'Main',
  toWarehouseName: 'Main Warehouse',
  quantity: 200,
  unit: 'PCS',
  transferredBy: currentUser.id,
  transferredByName: currentUser.name,
  notes: 'Shed full, moving to main warehouse',
);
```

## 📋 Verification Checklist

After setup, verify:

- [ ] 3 warehouses exist in Firestore `warehouses` collection
- [ ] Supervisors have `assignedWarehouseId` field
- [ ] Opening stock shows warehouse dropdown
- [ ] Production entry creates stock in supervisor's warehouse
- [ ] Stock ledger shows correct warehouse in notes

## 🔍 Quick Queries

### Check Warehouse Stock:
```dart
final gitaStock = await dbService.stockBalances
  .filter()
  .locationIdEqualTo('Gita_Shed')
  .findAll();
```

### Check Transfer History:
```dart
final transfers = await transferService.getTransferHistory(
  warehouseId: 'Gita_Shed',
);
```

### Check Supervisor Assignment:
```dart
final supervisor = await dbService.users.get(fastHash(supervisorId));
print('Assigned Warehouse: ${supervisor?.assignedWarehouseId}');
```

## ⚡ Common Issues

### Issue: Production still going to "Main"
**Solution**: Check supervisor's `assignedWarehouseId` in Firestore

### Issue: Warehouse dropdown empty
**Solution**: Run `seedInitialWarehouses()` again

### Issue: Transfer fails with "Insufficient stock"
**Solution**: Check stock balance in source warehouse first

## 🎯 Next Steps

1. ✅ Setup complete
2. 🔄 Create Warehouse Transfer UI screen
3. 📊 Add warehouse filter to reports
4. 📈 Dashboard warehouse cards

## 📞 Need Help?

Check `MULTI_WAREHOUSE_IMPLEMENTATION.md` for detailed documentation.
