# Sales Module

**Module:** Sales & Customer Management  
**Version:** 2.7  
**Status:** Active

---

## Overview

Manages sales orders, customer relationships, salesman routes, and sales tracking with offline-first support.

---

## Features

- Create sales orders
- Customer management
- Salesman route planning
- Target tracking
- Payment collection
- Offline sales support
- Durable sync queue

---

## User Roles

**Salesman:** Create sales, manage customers, view own performance  
**Store Incharge:** View all sales, reports  
**Admin:** Full access

---

## Screens

**New Sale** `/salesman/new-sale` (Mobile)  
**Sales History** `/salesman/sales` (Mobile)  
**Customers** `/salesman/customers` (Mobile)  
**Performance Report** `/salesman/performance` (Mobile)  
**Sales Management** `/dashboard/sales` (Desktop)

---

## Business Logic

### Sales Flow
1. Select customer
2. Add products
3. Calculate totals (with discounts)
4. Record payment
5. Deduct stock
6. Add to sync queue
7. Sync to Firestore when online

### Stock Deduction (T2)
- Salesman allocation blocked from sales flow
- Direct stock deduction only
- No intermediate allocation

### Canonical User Identity (T5)
- Uses Firebase UID for sales write/filter
- Consistent user identification
- Scoped sales operations

---

## Database Schema

**Collection:** `sales`

```json
{
  "id": "uuid",
  "saleNumber": "SAL-20260307-001",
  "saleDate": "2026-03-07",
  "customerId": "customer_id",
  "salesmanId": "firebase_uid",
  "items": [
    {
      "productId": "product_id",
      "quantity": 10,
      "rate": 100.0,
      "discount": 5.0,
      "amount": 950.0
    }
  ],
  "subtotal": 950.0,
  "discount": 50.0,
  "total": 900.0,
  "paymentReceived": 500.0,
  "outstanding": 400.0,
  "status": "completed",
  "syncStatus": "synced|pending",
  "createdAt": "timestamp"
}
```

---

## API Reference

**File:** `lib/services/sales_service.dart`

```dart
Future<bool> createSale({
  required String customerId,
  required List<SaleItem> items,
  required double paymentReceived,
  String? remarks,
});

Future<List<Sale>> getSalesByUser(String userId);
Future<SalesPerformance> getPerformance(String userId, DateTime startDate, DateTime endDate);
```

---

## Sync Queue

Sales use durable outbox queue pattern:
- Immediate local save
- Background sync to Firestore
- Automatic retry on failure
- Conflict resolution

---

## Reports

**Salesman Performance:** Sales, targets, achievement %  
**Customer Analysis:** Top customers, outstanding  
**Product Analysis:** Best sellers, trends

---

## Known Issues

**Legacy Local Lookups:** Some paths still use local user ID (documented in T5)

---

## References

- [Architecture](../architecture.md)
- [Sync System](../sync_system.md)
- [Inventory Module](inventory_module.md)
