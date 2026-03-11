# DattSoap ERP - Data Model

**Version:** 2.7  
**Last Updated:** March 2026

---

## 📊 Collections Overview

### Core Collections (5)
- users, products, customers, dealers, suppliers

### Transaction Collections (8)
- sales, payments, returns, dispatches, delivery_trips, purchase_orders, route_orders, stock_movements

### Production Collections (10)
- production_batches, production_entries, bhatti_batches, bhatti_entries, cutting_batches, wastage_logs, department_stocks, tanks, tank_transactions, formulas

### HR Collections (7)
- employees, attendances, payroll_records, advances, leave_requests, performance_reviews, duty_sessions

### Fleet Collections (6)
- vehicles, diesel_logs, fuel_purchases, vehicle_maintenance_logs, tyre_items, tyre_logs

### Accounting Collections (5)
- accounts, vouchers, voucher_entries, financial_years, tax_config

### System Collections (8)
- audit_logs, tasks, alerts, notification_events, sync_metrics, settings, deleted_records, locations

---

## 👥 Core Collections

### users
```json
{
  "id": "firebase_uid",
  "email": "user@example.com",
  "name": "User Name",
  "phone": "1234567890",
  "role": "admin|storeIncharge|productionSupervisor|bhattiSupervisor|salesman|fuelIncharge|driver|accountant",
  "departmentId": "dept_id",
  "isActive": true,
  "vanStock": {},
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### products
```json
{
  "id": "uuid",
  "code": "PROD-001",
  "name": "Product Name",
  "itemType": "raw|semi_finished|finished|traded",
  "category": "category_id",
  "unit": "kg|ltr|pcs",
  "displayUnit": "kg|gm|ltr|ml",
  "conversionFactor": 1000,
  "currentStock": 100.0,
  "reorderLevel": 50.0,
  "costPrice": 50.0,
  "sellingPrice": 100.0,
  "isActive": true,
  "isDeleted": false,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### customers
```json
{
  "id": "uuid",
  "code": "CUST-001",
  "name": "Customer Name",
  "phone": "1234567890",
  "address": "Address",
  "route": "route_id",
  "salesmanId": "salesman_id",
  "creditLimit": 50000.0,
  "outstandingBalance": 0.0,
  "isActive": true,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### dealers
```json
{
  "id": "uuid",
  "code": "DEALER-001",
  "name": "Dealer Name",
  "phone": "1234567890",
  "address": "Address",
  "gstNumber": "GST123",
  "creditLimit": 100000.0,
  "outstandingBalance": 0.0,
  "isActive": true,
  "createdAt": "timestamp"
}
```

### suppliers
```json
{
  "id": "uuid",
  "code": "SUP-001",
  "name": "Supplier Name",
  "phone": "1234567890",
  "address": "Address",
  "gstNumber": "GST123",
  "isActive": true,
  "createdAt": "timestamp"
}
```

---

## 💰 Transaction Collections

### sales
```json
{
  "id": "uuid",
  "saleNumber": "SAL-20260307-001",
  "saleDate": "2026-03-07",
  "salesmanId": "firebase_uid",
  "recipientId": "customer_id|dealer_id",
  "recipientType": "customer|dealer",
  "items": [
    {
      "productId": "product_id",
      "productName": "Product Name",
      "quantity": 10,
      "unit": "kg",
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
  "isDeleted": false,
  "createdAt": "timestamp"
}
```

### payments
```json
{
  "id": "uuid",
  "paymentNumber": "PAY-20260307-001",
  "paymentDate": "2026-03-07",
  "customerId": "customer_id",
  "amount": 500.0,
  "paymentMode": "cash|cheque|online",
  "reference": "CHQ123",
  "salesmanId": "salesman_id",
  "createdAt": "timestamp"
}
```

### returns
```json
{
  "id": "uuid",
  "returnNumber": "RET-20260307-001",
  "returnDate": "2026-03-07",
  "salesmanId": "salesman_id",
  "dealerId": "dealer_id",
  "items": [
    {
      "productId": "product_id",
      "quantity": 5,
      "reason": "damaged"
    }
  ],
  "status": "pending|approved|rejected",
  "createdAt": "timestamp"
}
```

### dispatches
```json
{
  "id": "uuid",
  "dispatchNumber": "DSP-20260307-001",
  "dispatchDate": "2026-03-07",
  "type": "stock|dealer",
  "salesmanId": "salesman_id",
  "destinationId": "warehouse_id|dealer_id",
  "items": [
    {
      "productId": "product_id",
      "quantity": 100,
      "rate": 50.0,
      "amount": 5000.0
    }
  ],
  "vehicleId": "vehicle_id",
  "driverId": "driver_id",
  "status": "pending|in_transit|delivered",
  "createdAt": "timestamp"
}
```

### delivery_trips
```json
{
  "id": "uuid",
  "tripNumber": "TRIP-20260307-001",
  "tripDate": "2026-03-07",
  "vehicleId": "vehicle_id",
  "driverId": "driver_id",
  "route": "route_name",
  "status": "pending|in_progress|completed",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "createdAt": "timestamp"
}
```

### purchase_orders
```json
{
  "id": "uuid",
  "poNumber": "PO-20260307-001",
  "poDate": "2026-03-07",
  "supplierId": "supplier_id",
  "items": [
    {
      "productId": "product_id",
      "quantity": 100,
      "rate": 50.0,
      "amount": 5000.0
    }
  ],
  "total": 5000.0,
  "status": "pending|received|cancelled",
  "createdAt": "timestamp"
}
```

### route_orders
```json
{
  "id": "uuid",
  "orderNumber": "RO-20260307-001",
  "orderDate": "2026-03-07",
  "routeId": "route_id",
  "salesmanId": "salesman_id",
  "items": [
    {
      "productId": "product_id",
      "quantity": 50
    }
  ],
  "dispatchStatus": "pending|dispatched|delivered",
  "productionStatus": "pending|in_production|completed",
  "dispatchBeforeDate": "2026-03-10",
  "isDeleted": false,
  "createdAt": "timestamp"
}
```

### stock_movements
```json
{
  "id": "uuid",
  "productId": "product_id",
  "warehouseId": "warehouse_id",
  "type": "in|out|transfer|adjustment|return|wastage|production_in|production_out|dispatch|opening",
  "quantity": 100.0,
  "referenceType": "purchase|sale|production|dispatch",
  "referenceId": "ref_id",
  "performedBy": "user_id",
  "createdAt": "timestamp"
}
```

---

## 🏭 Production Collections

### production_batches
```json
{
  "id": "uuid",
  "batchNumber": "PB-20260307-001",
  "batchDate": "2026-03-07",
  "productId": "product_id",
  "bomId": "bom_id",
  "inputs": [
    {
      "materialId": "material_id",
      "quantityKg": 100.0,
      "unitCost": 50.0
    }
  ],
  "outputKg": 95.0,
  "wasteKg": 5.0,
  "yieldPercent": 95.0,
  "operatorId": "user_id",
  "supervisorId": "user_id",
  "status": "completed",
  "createdAt": "timestamp"
}
```

### bhatti_batches
```json
{
  "id": "uuid",
  "batchNumber": "BH-20260307-001",
  "batchDate": "2026-03-07",
  "formulaId": "formula_id",
  "departmentId": "dept_id",
  "materials": [
    {
      "materialId": "material_id",
      "issuedKg": 100.0,
      "consumedKg": 95.0,
      "returnedKg": 5.0
    }
  ],
  "outputKg": 90.0,
  "wasteKg": 5.0,
  "yieldPercent": 90.0,
  "operatorId": "user_id",
  "supervisorId": "user_id",
  "status": "active|completed",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "createdAt": "timestamp"
}
```

### cutting_batches
```json
{
  "id": "uuid",
  "batchNumber": "CT-20260307-001",
  "batchDate": "2026-03-07",
  "shift": "morning|evening|night",
  "semiFinishedProductId": "product_id",
  "totalBatchWeightKg": 50.0,
  "finishedGoodId": "product_id",
  "standardWeightGm": 200,
  "actualAvgWeightGm": 198,
  "unitsProduced": 250,
  "cuttingWasteKg": 0.5,
  "wasteType": "scrap|reprocess",
  "yieldPercent": 95.0,
  "operatorId": "user_id",
  "supervisorId": "user_id",
  "status": "completed",
  "createdAt": "timestamp"
}
```

### formulas
```json
{
  "id": "uuid",
  "code": "FORM-001",
  "name": "Formula Name",
  "productId": "product_id",
  "ingredients": [
    {
      "materialId": "material_id",
      "percentage": 40.0,
      "quantityKg": 40.0
    }
  ],
  "totalQuantity": 100.0,
  "isActive": true,
  "createdAt": "timestamp"
}
```

### tanks
```json
{
  "id": "uuid",
  "tankNumber": "T-001",
  "name": "Tank 1",
  "capacity": 1000.0,
  "currentLevel": 500.0,
  "materialId": "material_id",
  "status": "active|inactive",
  "createdAt": "timestamp"
}
```

### tank_transactions
```json
{
  "id": "uuid",
  "tankId": "tank_id",
  "type": "in|out|transfer",
  "quantity": 100.0,
  "materialId": "material_id",
  "referenceId": "ref_id",
  "timestamp": "timestamp",
  "performedBy": "user_id"
}
```

---

## 👔 HR Collections

### employees
```json
{
  "id": "uuid",
  "employeeCode": "EMP-001",
  "name": "Employee Name",
  "phone": "1234567890",
  "email": "emp@example.com",
  "designation": "Manager",
  "department": "Production",
  "joiningDate": "2025-01-01",
  "salary": 50000.0,
  "isActive": true,
  "createdAt": "timestamp"
}
```

### attendances
```json
{
  "id": "uuid",
  "employeeId": "employee_id",
  "userId": "user_id",
  "date": "2026-03-07",
  "checkInTime": "timestamp",
  "checkOutTime": "timestamp",
  "duration": 480,
  "status": "present|absent|leave",
  "createdAt": "timestamp"
}
```

### payroll_records
```json
{
  "id": "uuid",
  "employeeId": "employee_id",
  "month": "2026-03",
  "basicSalary": 50000.0,
  "allowances": 5000.0,
  "deductions": 2000.0,
  "netSalary": 53000.0,
  "status": "pending|paid",
  "createdAt": "timestamp"
}
```

### leave_requests
```json
{
  "id": "uuid",
  "employeeId": "employee_id",
  "leaveType": "casual|sick|earned",
  "fromDate": "2026-03-10",
  "toDate": "2026-03-12",
  "days": 3,
  "reason": "Personal",
  "status": "pending|approved|rejected",
  "createdAt": "timestamp"
}
```

---

## 🚗 Fleet Collections

### vehicles
```json
{
  "id": "uuid",
  "vehicleNumber": "MH-12-AB-1234",
  "name": "Truck 1",
  "type": "truck|van|car",
  "capacity": 5000.0,
  "status": "active|maintenance|inactive",
  "purchaseDate": "2025-01-01",
  "createdAt": "timestamp"
}
```

### diesel_logs
```json
{
  "id": "uuid",
  "vehicleId": "vehicle_id",
  "purchaseDate": "2026-03-07",
  "quantity": 50.0,
  "rate": 90.0,
  "amount": 4500.0,
  "odometer": 50000,
  "createdAt": "timestamp"
}
```

### vehicle_maintenance_logs
```json
{
  "id": "uuid",
  "vehicleId": "vehicle_id",
  "maintenanceDate": "2026-03-07",
  "type": "service|repair|inspection",
  "description": "Oil change",
  "cost": 2000.0,
  "nextServiceDate": "2026-06-07",
  "createdAt": "timestamp"
}
```

---

## 💼 Accounting Collections

### accounts
```json
{
  "id": "uuid",
  "accountCode": "1000",
  "accountName": "Cash",
  "accountType": "asset|liability|income|expense|equity",
  "parentAccountId": "parent_id",
  "isActive": true,
  "createdAt": "timestamp"
}
```

### vouchers
```json
{
  "id": "uuid",
  "voucherNumber": "V-20260307-001",
  "date": "2026-03-07",
  "transactionType": "sale|purchase|payment|receipt",
  "transactionRefId": "ref_id",
  "totalDebit": 1000.0,
  "totalCredit": 1000.0,
  "isBalanced": true,
  "financialYearId": "fy_id",
  "createdAt": "timestamp"
}
```

### voucher_entries
```json
{
  "id": "uuid",
  "voucherId": "voucher_id",
  "accountCode": "1000",
  "debit": 1000.0,
  "credit": 0.0,
  "description": "Sale payment",
  "transactionRefId": "ref_id",
  "createdAt": "timestamp"
}
```

---

## ⚙️ System Collections

### audit_logs
```json
{
  "id": "uuid",
  "userId": "user_id",
  "action": "create|update|delete",
  "collection": "sales",
  "documentId": "doc_id",
  "changes": {},
  "ipAddress": "192.168.1.1",
  "createdAt": "timestamp"
}
```

### tasks
```json
{
  "id": "uuid",
  "title": "Task Title",
  "description": "Task Description",
  "assignedTo": {
    "id": "user_id",
    "name": "User Name"
  },
  "createdBy": {
    "id": "user_id",
    "name": "User Name"
  },
  "status": "pending|in_progress|completed",
  "priority": "low|medium|high",
  "dueDate": "2026-03-10",
  "createdAt": "timestamp"
}
```

### sync_metrics
```json
{
  "id": "user_id",
  "lastSyncAt": "timestamp",
  "pendingItems": 5,
  "failedItems": 0,
  "totalSynced": 100,
  "updatedAt": "timestamp"
}
```

---

## 📊 Data Relationships

### One-to-Many
- users → sales (salesmanId)
- customers → sales (recipientId)
- products → stock_movements (productId)
- vehicles → diesel_logs (vehicleId)
- employees → attendances (employeeId)

### Many-to-Many
- sales ↔ products (via items array)
- production_batches ↔ products (via inputs/outputs)
- formulas ↔ products (via ingredients)

### Hierarchical
- accounts (parent-child tree)
- departments (organizational hierarchy)

---

## 🔑 Key Fields

### Common Fields (All Collections)
- `id`: Unique identifier (UUID or Firebase UID)
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp (where applicable)

### Soft Delete
- `isDeleted`: Boolean flag
- `deletedAt`: Deletion timestamp
- `deletedBy`: User who deleted

### Sync Status
- `syncStatus`: "synced" | "pending" | "failed"
- `lastSyncAt`: Last sync timestamp

### Audit Trail
- `createdBy`: User who created
- `updatedBy`: User who last updated
- `performedBy`: User who performed action

---

**Complete data model for 50+ collections**  
**Maintained by:** DattSoap Development Team
