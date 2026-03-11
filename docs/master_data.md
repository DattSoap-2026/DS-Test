# Master Data Management

**Version:** 2.7  
**Last Updated:** March 2026

---

## Overview

Master data includes all reference data used across the ERP system: products, customers, suppliers, users, and configuration.

---

## Master Data Types

### 1. Products
- Raw materials
- Semi-finished goods
- Finished products
- Product categories
- Units of measurement

### 2. Customers
- Customer details
- Contact information
- Credit limits
- Payment terms
- Route assignments

### 3. Suppliers
- Supplier details
- Contact information
- Payment terms
- Product mappings

### 4. Users
- User accounts
- Role assignments
- Department assignments
- Permissions

### 5. Configuration
- Warehouses
- Departments
- Vehicles
- Routes
- Formulas/BOMs

---

## Product Management

### Product Types

**Raw Materials:** Input for production  
**Semi-Finished:** Output from production, input for cutting  
**Finished Goods:** Final products for sale

### Product Schema

```json
{
  "id": "uuid",
  "code": "PROD-001",
  "name": "Product Name",
  "type": "raw|semi_finished|finished",
  "category": "category_id",
  "unit": "kg|ltr|pcs",
  "standardWeight": 200.0,
  "costPrice": 50.0,
  "sellingPrice": 100.0,
  "reorderLevel": 100.0,
  "isActive": true
}
```

---

## Customer Management

### Customer Schema

```json
{
  "id": "uuid",
  "code": "CUST-001",
  "name": "Customer Name",
  "phone": "1234567890",
  "address": "Address",
  "routeId": "route_id",
  "salesmanId": "salesman_id",
  "creditLimit": 50000.0,
  "paymentTerms": "cash|credit",
  "isActive": true
}
```

---

## User Management

### User Roles

- **Admin:** Full system access
- **Store Incharge:** Inventory, procurement, dispatch
- **Production Supervisor:** Production, cutting
- **Bhatti Supervisor:** Bhatti operations
- **Salesman:** Sales, customers
- **Fuel Incharge:** Fuel logging
- **Driver:** Task management

### User Schema

```json
{
  "id": "firebase_uid",
  "email": "user@example.com",
  "name": "User Name",
  "role": "admin|storeIncharge|productionSupervisor|...",
  "departmentId": "dept_id",
  "isActive": true
}
```

---

## Configuration Management

### Warehouses

```json
{
  "id": "uuid",
  "code": "WH-001",
  "name": "Main Warehouse",
  "location": "Location",
  "isActive": true
}
```

### Departments

```json
{
  "id": "uuid",
  "code": "DEPT-001",
  "name": "Production",
  "type": "production|bhatti|cutting",
  "isActive": true
}
```

---

## Data Access

### Read Access
- All users can read master data
- Cached locally for offline access
- Real-time sync from Firestore

### Write Access
- Admin only for most master data
- Store Incharge for customers/suppliers
- Restricted by role

---

## API Reference

**File:** `lib/services/products_service.dart`

```dart
Future<List<Product>> getProducts({ProductType? type});
Future<Product?> getProductById(String id);
```

**File:** `lib/services/customers_service.dart`

```dart
Future<List<Customer>> getCustomers({String? routeId});
Future<Customer?> getCustomerById(String id);
```

---

## Data Validation

### Product Validation
- Unique product code
- Valid unit of measurement
- Positive prices
- Valid product type

### Customer Validation
- Unique customer code
- Valid phone number
- Valid credit limit
- Active salesman assignment

---

## Data Import/Export

### Import
- CSV/Excel import for bulk data
- Validation before import
- Error reporting

### Export
- Export to CSV/Excel
- Filtered exports
- Scheduled exports

---

## References

- [Architecture](architecture.md)
- [User Roles](security_rbac.md)
- [Module Documentation](modules/)
