# Salesman - Complete Access Audit & Sync Fix

## User Profile
- **Role**: Salesman
- **Department**: Sales
- **Primary Functions**: Sales, Customer visits, Route management, Dispatch tracking

## Accessible Pages

### 1. Dashboard
| Page | Route | Access | Purpose |
|------|-------|--------|---------|
| Salesman Dashboard | `/dashboard` | ✅ Yes | Landing page, KPIs, daily summary |

### 2. Sales Module
| Page | Route | Access | Purpose |
|------|-------|--------|---------|
| New Sale | `/dashboard/sales/new` | ✅ Yes | Create new sale |
| Sales History | `/dashboard/sales/history` | ✅ Yes | View own sales |
| Sale Details | `/dashboard/sales/:id` | ✅ Yes | View sale details (own sales only) |

### 3. Customers Module
| Page | Route | Access | Purpose |
|------|-------|--------|---------|
| Customer Management | `/dashboard/customers` | ✅ Yes | View/manage customers on assigned routes |
| Customer Details | `/dashboard/customers/:id` | ✅ Yes | View customer details |
| Customer Form | Dialog | ✅ Yes | Add/edit customers |
| Customer Visits | `/dashboard/customers/visits` | ✅ Yes | Log customer visits |

### 4. Dispatch Module
| Page | Route | Access | Purpose |
|------|-------|--------|---------|
| Salesman Dispatch History | `/dashboard/dispatch/history` | ✅ Yes | View own dispatches |
| Dispatch Details | `/dashboard/dispatch/:id` | ✅ Yes | View dispatch details (own only) |

### 5. Returns Module
| Page | Route | Access | Purpose |
|------|-------|--------|---------|
| Salesman Returns | `/dashboard/returns` | ✅ Yes | View/create returns |
| Add Return Request | `/dashboard/returns/add` | ✅ Yes | Create return request |
| Return Details | `/dashboard/returns/:id` | ✅ Yes | View return details (own only) |

### 6. Payments Module
| Page | Route | Access | Purpose |
|------|-------|--------|---------|
| Add Payment | `/dashboard/payments/add` | ✅ Yes | Record customer payment |
| Payments History | `/dashboard/payments` | ✅ Yes | View payment history (own only) |

### 7. Inventory Module (Limited)
| Page | Route | Access | Purpose |
|------|-------|--------|---------|
| My Stock | `/dashboard/inventory/my-stock` | ✅ Yes | View allocated stock |

### 8. Reports Module (Limited)
| Page | Route | Access | Purpose |
|------|-------|--------|---------|
| My Performance | `/dashboard/reports/my-performance` | ✅ Yes | View own performance |
| Salesman KPI Drilldown | `/dashboard/reports/kpi` | ✅ Yes | Detailed KPI analysis |

### 9. Map Module
| Page | Route | Access | Purpose |
|------|-------|--------|---------|
| Customers Map | `/dashboard/map/customers` | ✅ Yes | View customers on map (assigned routes) |
| Route Planner | `/dashboard/map/route-planner` | ✅ Yes | Plan route for the day |

### 10. Tasks Module
| Page | Route | Access | Purpose |
|------|-------|--------|---------|
| Tasks | `/dashboard/tasks` | ✅ Yes | View/manage assigned tasks |
| Task History | `/dashboard/tasks/history` | ✅ Yes | View task history |

## Restricted Pages (Should NOT Access)

### 1. Admin/Management
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| Admin Dashboard | `/dashboard/admin` | ❌ No | Admin only |
| Users Management | `/dashboard/management/users` | ❌ No | Admin only |
| Products Management | `/dashboard/management/products` | ❌ No | Admin/Store only |
| Routes Management | `/dashboard/management/routes` | ❌ No | Admin only |
| Sales Targets | `/dashboard/management/targets` | ❌ No | Admin/Manager only |
| Dealers Management | `/dashboard/management/dealers` | ❌ No | Admin/Dealer Manager only |

### 2. Production Module
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| Production Dashboard | `/dashboard/production` | ❌ No | Production team only |
| Bhatti Dashboard | `/dashboard/bhatti` | ❌ No | Bhatti Supervisor only |
| Cutting Batches | `/dashboard/production/cutting` | ❌ No | Production Supervisor only |
| Production Stock | `/dashboard/production/stock` | ❌ No | Production team only |

### 3. Inventory Management
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| Inventory Overview | `/dashboard/inventory/overview` | ❌ No | Store Incharge only |
| Department Stock | `/dashboard/inventory/department` | ❌ No | Store Incharge only |
| Opening Stock | `/dashboard/inventory/opening-stock` | ❌ No | Store Incharge only |
| Stock Adjustment | `/dashboard/inventory/adjustment` | ❌ No | Store Incharge only |
| Tanks Management | `/dashboard/inventory/tanks` | ❌ No | Bhatti/Store only |

### 4. Vehicle Management
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| Vehicle Management | `/dashboard/vehicles` | ❌ No | Fleet managers only |
| Fuel Management | `/dashboard/fuel` | ❌ No | Fuel Incharge only |
| Vehicle Analytics | `/dashboard/vehicles/analytics` | ❌ No | Fleet managers only |

### 5. Procurement
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| Purchase Orders | `/dashboard/procurement/po` | ❌ No | Store Incharge only |
| Goods Receipt | `/dashboard/procurement/gr` | ❌ No | Store Incharge only |

### 6. Reports (Admin)
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| Sales Report (All) | `/dashboard/reports/sales` | ❌ No | Admin/Manager only |
| Production Report | `/dashboard/reports/production` | ❌ No | Production team only |
| Financial Report | `/dashboard/reports/financial` | ❌ No | Admin/Accountant only |
| Stock Valuation | `/dashboard/reports/stock-valuation` | ❌ No | Admin/Store only |

### 7. Settings
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| General Settings | `/dashboard/settings/general` | ❌ No | Admin only |
| Company Profile | `/dashboard/settings/company` | ❌ No | Admin only |
| Custom Roles | `/dashboard/settings/roles` | ❌ No | Admin only |
| System Data | `/dashboard/settings/system` | ❌ No | Admin only |

## Data Access Permissions

### Read Access (View Only)
- ✅ Own sales records
- ✅ Own dispatch records
- ✅ Own return records
- ✅ Own payment records
- ✅ Customers on assigned routes
- ✅ Own allocated stock
- ✅ Own performance metrics
- ✅ Own tasks
- ✅ Products (for sales)
- ✅ Routes (assigned only)

### Write Access (Create/Update)
- ✅ Sales (own)
- ✅ Returns (own)
- ✅ Payments (own)
- ✅ Customer visits
- ✅ Customers (on assigned routes)
- ✅ Tasks (assigned to self)

### No Access (Restricted)
- ❌ Other salesman's sales
- ❌ Other salesman's dispatches
- ❌ Other salesman's stock
- ❌ Production data
- ❌ Bhatti data
- ❌ Vehicle data
- ❌ Fuel data
- ❌ Purchase orders
- ❌ Stock adjustments
- ❌ Opening stock
- ❌ Department stock
- ❌ Tanks
- ❌ Financial reports (all)
- ❌ Admin settings
- ❌ User management
- ❌ Product management

## Sync Permissions

### Collections That SHOULD Sync
1. **users** (read-only) - To see team info
2. **products** (read-only) - For sales
3. **customers** (assigned routes only) - Customer management
4. **sales** (own only) - Own sales records
5. **dispatches** (own only) - Own dispatch records
6. **returns** (own only) - Own return records
7. **payments** (own only) - Own payment records
8. **customer_visits** (own only) - Own visit logs
9. **route_sessions** (own only) - Own route sessions
10. **duty_sessions** (own only) - Own duty sessions
11. **stock_ledger** (own only) - Own stock movements
12. **routes** (assigned only) - Assigned routes info
13. **sales_targets** (own only) - Own targets
14. **schemes** (read-only) - Active schemes
15. **master_data** (read-only) - Categories, units, etc.

### Collections That SHOULD NOT Sync
1. **vehicles** ❌
2. **diesel_logs** ❌
3. **tanks** ❌
4. **tank_transactions** ❌
5. **bhatti_entries** ❌
6. **production_entries** ❌
7. **cutting_batches** ❌
8. **opening_stock** ❌
9. **department_stocks** ❌
10. **purchase_orders** ❌
11. **goods_received** ❌
12. **dealers** ❌
13. **payroll** ❌
14. **attendance** (other users) ❌
15. **vouchers** ❌
16. **accounts** ❌

## Current Sync Issues

### Issue 1: Syncing Unnecessary Data
Salesman is currently syncing data that is not relevant to their role:
- ❌ Vehicles
- ❌ Diesel logs
- ❌ Production data
- ❌ Bhatti data
- ❌ Tanks

### Issue 2: Missing Route-Based Filtering
Salesman should only sync customers on their assigned routes, but currently syncing all customers.

### Issue 3: Missing Ownership Filtering
Salesman should only sync their own sales/dispatches/returns, but filtering may not be strict enough.

## Required Fixes

### Fix 1: Remove Vehicle Sync for Salesman
```dart
bool _canSyncFleetData(UserRole role) {
  return _isAdminLikeRole(role) ||
      role == UserRole.dispatchManager ||
      role == UserRole.storeIncharge ||
      role == UserRole.fuelIncharge ||
      role == UserRole.vehicleMaintenanceManager;
  // Salesman should NOT be here
}
```

### Fix 2: Remove Production Sync for Salesman
```dart
bool _canSyncProductionInventory(UserRole role) {
  return _isAdminLikeRole(role) || 
      role == UserRole.productionManager ||
      role == UserRole.bhattiSupervisor;
  // Salesman should NOT be here
}
```

### Fix 3: Add Route-Based Customer Filtering
Customers sync should filter by assigned routes for salesman.

### Fix 4: Add Ownership Filtering
Sales, dispatches, returns, payments should filter by salesman ID.

## Firestore Rules Audit

### Current Rules for Salesman
```javascript
// Sales - Own records only
match /sales/{id} { 
  allow read, write: if isAdminOrOwner(resource.data.salesmanId); 
}

// Dispatches - Own records only
match /dispatches/{id} { 
  allow read, write: if isAdminOrOwner(resource.data.salesmanId); 
}

// Returns - Own records only
match /returns/{id} { 
  allow read, write: if isAdminOrOwner(resource.data.salesmanId); 
}

// Customers - All authenticated (needs route filtering)
match /customers/{id} { 
  allow read: if isAuth(); 
  allow write: if isAdmin(); 
}

// Products - Read only
match /products/{id} { 
  allow read: if isAuth(); 
  allow write: if isStoreOrAdmin(); 
}
```

### Rules That Need Update
1. **Customers** - Should filter by assigned routes for salesman
2. **Vehicles** - Salesman should NOT have access
3. **Production** - Salesman should NOT have access

## Expected Sync Behavior After Fix

### ✅ Success Messages
```
INFO [Sync]: Starting Sync for Salesman (John)...
SUCCESS [Sync]: Pulled 16 users from Firebase
SUCCESS [Sync]: Pulled 45 products from Firebase
SUCCESS [Sync]: Pulled 23 customers from assigned routes
SUCCESS [Sync]: Pulled 12 own sales from Firebase
SUCCESS [Sync]: Pulled 5 own dispatches from Firebase
INFO [Sync]: Skipping vehicle sync for Salesman - not authorized
INFO [Sync]: Skipping production sync for Salesman - not authorized
SUCCESS [Sync]: Sync Completed Successfully.
```

### ⚠️ Expected Warnings (Normal)
```
WARNING [Sync]: Skipping vehicle sync for Salesman - not authorized
WARNING [Sync]: Skipping production sync for Salesman - not authorized
WARNING [Sync]: Skipping tank sync for Salesman - not authorized
```

## Summary

### ✅ Salesman CAN:
- Access sales, customers, returns, payments pages
- View own sales, dispatches, returns, payments
- View customers on assigned routes
- View own allocated stock
- View own performance reports
- Create sales, returns, payments
- Log customer visits
- Sync own transactional data

### ❌ Salesman CANNOT:
- Access production, bhatti, vehicle pages
- View other salesman's data
- Access admin/management pages
- Modify products, routes, users
- Access financial reports
- Sync vehicle, production, tank data
- View/modify system settings

### 🎯 Required Actions:
1. Remove vehicle sync for Salesman
2. Remove production sync for Salesman
3. Add route-based customer filtering
4. Add ownership filtering for all transactional data
5. Update Firestore rules for customer route filtering
6. Test sync with Salesman account
7. Verify page access restrictions
