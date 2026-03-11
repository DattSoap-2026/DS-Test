# Inventory Module

**Module:** Stock Management  
**Version:** 2.7  
**Status:** Active

---

## Overview

Manages all inventory operations including stock tracking, adjustments, transfers, and real-time stock levels across warehouses.

---

## Features

- Real-time stock tracking
- Stock adjustments
- Stock transfers between warehouses
- Opening stock management
- Low stock alerts
- Stock valuation

---

## User Roles

**Store Incharge:** Full inventory access  
**Admin:** Full access  
**Others:** Read-only access

---

## Screens

**Stock Inventory** `/dashboard/inventory`  
**Stock Adjustments** `/dashboard/inventory/adjustments`  
**Stock Transfers** `/dashboard/inventory/transfers`  
**Liquid Tanks** `/dashboard/inventory/tanks`

---

## Business Logic

### Stock Flow
- **Inward:** Purchase GRN, Production output, Returns
- **Outward:** Sales, Dispatch, Material issue, Production consumption
- **Adjustments:** Manual corrections, Physical verification

### Opening Stock (T3-T4)
- Single warehouse: "Main"
- Set-balance semantics
- One-time initialization

### Stock Calculation
```
Current Stock = Opening + Inward - Outward + Adjustments
```

---

## Database Schema

**Collection:** `stock_movements`

```json
{
  "id": "uuid",
  "productId": "product_id",
  "warehouseId": "warehouse_id",
  "movementType": "in|out|adjustment",
  "quantity": 100.0,
  "referenceType": "purchase|sale|production",
  "referenceId": "ref_id",
  "createdAt": "timestamp"
}
```

**Collection:** `stock_levels`

```json
{
  "productId": "product_id",
  "warehouseId": "warehouse_id",
  "quantity": 500.0,
  "lastUpdated": "timestamp"
}
```

---

## API Reference

**File:** `lib/services/stock_service.dart`

```dart
Future<double> getStockLevel(String productId, String warehouseId);
Future<bool> adjustStock(String productId, double quantity, String reason);
Future<bool> transferStock(String productId, String fromWarehouse, String toWarehouse, double quantity);
```

---

## Integration Points

- **Production:** Stock deduction/addition
- **Sales:** Stock deduction
- **Dispatch:** Stock movement
- **Purchase:** Stock addition via GRN

---

## Known Issues

**Department Stock Symmetry (T1):** Fixed - Issue/return flow now symmetric

---

## References

- [Architecture](../architecture.md)
- [Production Module](production_module.md)
- [Sales Module](sales_module.md)
