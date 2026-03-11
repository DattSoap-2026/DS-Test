# Dispatch Module

**Module:** Stock & Dealer Dispatch  
**Version:** 2.7  
**Status:** Active

---

## Overview

Manages dispatch operations for stock transfers and dealer deliveries with trip management and vehicle tracking.

---

## Features

- Stock dispatch to warehouses
- Dealer dispatch with invoicing
- Trip creation and tracking
- Vehicle assignment
- Discount management
- Delivery confirmation

---

## User Roles

**Store Incharge:** Create dispatch, manage trips  
**Driver:** View assigned trips  
**Admin:** Full access

---

## Screens

**Stock Dispatch** `/dashboard/dispatch/stock`  
**Dealer Dispatch** `/dashboard/dispatch/dealer`  
**Create Trip** `/dashboard/dispatch/trip`  
**Trip Management** `/dashboard/dispatch/trips`

---

## Business Logic

### Stock Dispatch Flow
1. Select destination warehouse
2. Add products and quantities
3. Assign vehicle and driver
4. Create dispatch record
5. Deduct stock from source
6. Add to sync queue
7. Update stock at destination (on confirmation)

### Dealer Dispatch Flow
1. Select dealer
2. Add products
3. Apply discounts
4. Calculate totals
5. Assign vehicle
6. Create invoice
7. Deduct stock
8. Add to sync queue

### Discount Management
- Dealer-specific discounts
- Product-specific discounts
- Combined discount calculation
- Audit trail

---

## Database Schema

**Collection:** `dispatches`

```json
{
  "id": "uuid",
  "dispatchNumber": "DSP-20260307-001",
  "dispatchDate": "2026-03-07",
  "type": "stock|dealer",
  "destinationId": "warehouse_id|dealer_id",
  "items": [
    {
      "productId": "product_id",
      "quantity": 100,
      "rate": 50.0,
      "discount": 5.0,
      "amount": 4750.0
    }
  ],
  "vehicleId": "vehicle_id",
  "driverId": "driver_id",
  "status": "pending|in_transit|delivered",
  "createdAt": "timestamp"
}
```

---

## API Reference

**File:** `lib/services/dispatch_service.dart`

```dart
Future<bool> createStockDispatch({
  required String destinationWarehouse,
  required List<DispatchItem> items,
  required String vehicleId,
  required String driverId,
});

Future<bool> createDealerDispatch({
  required String dealerId,
  required List<DispatchItem> items,
  required String vehicleId,
});
```

---

## Integration Points

- **Inventory:** Stock deduction/addition
- **Vehicle Management:** Vehicle assignment
- **Payments:** Dealer payment tracking

---

## Known Issues

**Discount Audit (Fixed):** Dealer dispatch discount calculation corrected

---

## References

- [Architecture](../architecture.md)
- [Inventory Module](inventory_module.md)
- [Vehicle Module](vehicle_module.md)
