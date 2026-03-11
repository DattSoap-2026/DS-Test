# Production Supervisor - Complete Page Access Audit

## User Profile
- **Name**: Sona
- **Email**: sona@dattsoap.com
- **Role**: Production Supervisor
- **Department**: Production
- **Team**: Sona (if assigned)

## Landing Page
- **Default Route**: `/dashboard/production`
- **Redirect Logic**: Defined in `user_types.dart` → `landingPath` getter

## Accessible Pages

### 1. Dashboard & Overview
| Page | Route | Access | Notes |
|------|-------|--------|-------|
| Main Dashboard | `/dashboard` | ✅ Yes | Shows production metrics |
| Production Dashboard | `/dashboard/production` | ✅ Yes | Landing page, full access |

### 2. Production Module
| Page | Route | Access | Notes |
|------|-------|--------|-------|
| Production Logs | `/dashboard/production/logs` | ✅ Yes | View/add daily logs |
| Production Entries | `/dashboard/production/entries` | ✅ Yes | View/add production entries |
| Cutting Batches | `/dashboard/production/cutting` | ✅ Yes | Manage cutting operations |
| Cutting Entry | `/dashboard/production/cutting/entry` | ✅ Yes | Add new cutting batch |

### 3. Inventory Module (Limited)
| Page | Route | Access | Notes |
|------|-------|--------|-------|
| Stock Overview | `/dashboard/inventory/stock-overview` | ✅ Yes | View production materials only |
| Products | `/dashboard/management/products` | ✅ Yes | Read-only access |

### 4. Orders Module
| Page | Route | Access | Notes |
|------|-------|--------|-------|
| Route Orders | `/dashboard/orders/route-management` | ✅ Yes | Mark orders ready for production |

### 5. Reports Module
| Page | Route | Access | Notes |
|------|-------|--------|-------|
| Reports Dashboard | `/dashboard/reports` | ✅ Yes | Production reports only |
| Production Reports | `/dashboard/reports/production` | ✅ Yes | Full access |

## Restricted Pages (Should NOT Access)

### 1. Sales Module
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| Sales Dashboard | `/dashboard/sales` | ❌ No | Sales team only |
| Add Sale | `/dashboard/sales/add` | ❌ No | Sales team only |
| Sale Details | `/dashboard/sales/:id` | ❌ No | Sales team only |
| Returns | `/dashboard/returns` | ❌ No | Sales team only |

### 2. Dispatch Module
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| Dispatch Dashboard | `/dashboard/dispatch` | ❌ No | Dispatch Manager only |
| Create Dispatch | `/dashboard/dispatch/create` | ❌ No | Dispatch Manager only |
| Dispatch Details | `/dashboard/dispatch/:id` | ❌ No | Dispatch Manager only |

### 3. Vehicle Management
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| Vehicle Management | `/dashboard/vehicles` | ❌ No | Fleet managers only |
| Add Vehicle | `/dashboard/vehicles/add` | ❌ No | Fleet managers only |
| Vehicle Details | `/dashboard/vehicles/:id` | ❌ No | Fleet managers only |
| Diesel Logs | `/dashboard/vehicles/diesel` | ❌ No | Fuel Incharge only |
| Maintenance Logs | `/dashboard/vehicles/maintenance` | ❌ No | Vehicle Maintenance Manager only |

### 4. Customer Management
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| Customers | `/dashboard/customers` | ❌ No | Sales team only |
| Add Customer | `/dashboard/customers/add` | ❌ No | Sales team only |
| Customer Details | `/dashboard/customers/:id` | ❌ No | Sales team only |

### 5. Dealer Management
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| Dealers | `/dashboard/dealers` | ❌ No | Admin/Dealer Manager only |
| Add Dealer | `/dashboard/dealers/add` | ❌ No | Admin/Dealer Manager only |
| Dealer Details | `/dashboard/dealers/:id` | ❌ No | Admin/Dealer Manager only |

### 6. HR & Payroll
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| HR Dashboard | `/dashboard/hr` | ❌ No | Admin only |
| Attendance | `/dashboard/hr/attendance` | ❌ No | Admin only |
| Payroll | `/dashboard/hr/payroll` | ❌ No | Admin only |
| Leave Requests | `/dashboard/hr/leaves` | ❌ No | Admin only |

### 7. Accounting
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| Accounts | `/dashboard/accounting/accounts` | ❌ No | Admin/Accountant only |
| Vouchers | `/dashboard/accounting/vouchers` | ❌ No | Admin/Accountant only |
| Ledger | `/dashboard/accounting/ledger` | ❌ No | Admin/Accountant only |

### 8. Settings & Admin
| Page | Route | Access | Reason |
|------|-------|--------|--------|
| User Management | `/dashboard/settings/users` | ❌ No | Admin only |
| Role Management | `/dashboard/settings/roles` | ❌ No | Admin only |
| System Settings | `/dashboard/settings/system` | ❌ No | Admin only |

## Data Access Permissions

### Read Access (View Only)
- ✅ Users (team members)
- ✅ Products (production materials)
- ✅ Inventory (production materials only)
- ✅ Route Orders (for production planning)
- ✅ Trips (for production planning)
- ✅ Master Data (categories, units, product types)

### Write Access (Create/Update)
- ✅ Production Entries
- ✅ Production Logs
- ✅ Cutting Batches
- ✅ Route Order Status (mark ready for production)
- ✅ Tank Transactions (if assigned to bhatti)

### No Access (Restricted)
- ❌ Vehicles
- ❌ Diesel Logs
- ❌ Sales Transactions
- ❌ Dispatches
- ❌ Returns
- ❌ Customers
- ❌ Dealers
- ❌ Duty Sessions
- ❌ Sales Targets
- ❌ Payroll
- ❌ Attendance
- ❌ Accounts
- ❌ Vouchers
- ❌ Alerts (system-level)
- ❌ Notification Events

## Sync Permissions

### Collections That SHOULD Sync
1. users (read-only)
2. products (read-only)
3. route_orders
4. production_entries
5. production_logs
6. detailed_production_logs
7. cutting_batches
8. inventory (production materials)
9. opening_stock
10. stock_ledger (production-related)
11. trips (read-only)
12. master_data (categories, units, product types)

### Collections That SHOULD NOT Sync
1. tanks ❌
2. tank_transactions ❌
3. bhatti_entries ❌
4. vehicles ❌
5. diesel_logs ❌
3. sales ❌
4. dispatches ❌
5. returns ❌
6. customers ❌
7. dealers ❌
8. duty_sessions ❌
9. sales_targets ❌
10. payroll ❌
11. attendance ❌
12. accounts ❌
13. vouchers ❌
14. alerts ❌
15. notification_events ❌

## Router Guards

### Implementation Location
- **File**: `lib/routes/app_router.dart`
- **Guard**: `AuthGuard` checks user authentication
- **Role Check**: Each route has `canAccess()` method

### Example Guard Logic
```dart
// Production pages - accessible by Production Supervisor
if (user.role == UserRole.productionSupervisor) {
  return route.startsWith('/dashboard/production') ||
         route == '/dashboard/orders/route-management' ||
         route == '/dashboard/inventory/stock-overview' ||
         route == '/dashboard/reports/production';
}

// Vehicle pages - NOT accessible by Production Supervisor
if (route.startsWith('/dashboard/vehicles')) {
  return user.role == UserRole.admin ||
         user.role == UserRole.dispatchManager ||
         user.role == UserRole.fuelIncharge ||
         user.role == UserRole.vehicleMaintenanceManager;
}
```

## UI Element Visibility

### Navigation Menu
- ✅ Dashboard
- ✅ Production
- ✅ Orders (Route Orders only)
- ✅ Inventory (Limited)
- ✅ Reports (Production only)
- ❌ Sales
- ❌ Dispatch
- ❌ Vehicles
- ❌ Customers
- ❌ Dealers
- ❌ HR
- ❌ Accounting
- ❌ Settings

### Action Buttons
- ✅ Add Production Entry
- ✅ Add Cutting Batch
- ✅ Mark Order Ready
- ❌ Add Sale
- ❌ Create Dispatch
- ❌ Add Vehicle
- ❌ Add Customer
- ❌ Add Dealer

## Testing Scenarios

### Positive Tests (Should Work)
1. Login as Production Supervisor
2. Navigate to Production Dashboard
3. View production logs
4. Add new production entry
5. Create cutting batch
6. View route orders
7. Mark order as ready for production
8. View inventory (production materials)
9. View products (read-only)
10. Generate production reports

### Negative Tests (Should Fail/Redirect)
1. Try to access `/dashboard/vehicles` → Should redirect or show "Access Denied"
2. Try to access `/dashboard/sales` → Should redirect or show "Access Denied"
3. Try to access `/dashboard/customers` → Should redirect or show "Access Denied"
4. Try to access `/dashboard/hr` → Should redirect or show "Access Denied"
5. Try to modify product data → Should be read-only
6. Try to add vehicle → Should not have button/access
7. Try to create sale → Should not have button/access
8. Try to view payroll → Should redirect or show "Access Denied"

## Error Handling

### Expected Errors (Normal)
```
WARNING [AlertService]: Alerts collection permission-denied. Backoff for 10 minutes.
INFO [Sync]: Skipping vehicle sync for Production Supervisor - not authorized
```

### Unexpected Errors (Need Investigation)
```
ERROR [Sync]: Permission denied for production_entries
ERROR [Router]: Access denied to /dashboard/production
ERROR [Firestore]: Missing or insufficient permissions for route_orders
```

## Security Considerations

### Firestore Rules
- Production Supervisor can read `users` collection
- Production Supervisor can read `products` collection
- Production Supervisor can read/write `production_entries` collection
- Production Supervisor can read/write `cutting_batches` collection
- Production Supervisor can read/write `route_orders` collection (status updates only)
- Production Supervisor CANNOT access `vehicles` collection
- Production Supervisor CANNOT access `sales` collection
- Production Supervisor CANNOT access `customers` collection

### Data Isolation
- Department-based filtering applied to all queries
- Production Supervisor can only see production department data
- Cross-department data access is blocked at Firestore level
- Sensitive data (payroll, accounting) is completely hidden

## Monitoring & Audit

### Logs to Monitor
1. Sync logs - ensure no vehicle sync attempts
2. Router logs - ensure no unauthorized page access
3. Firestore logs - ensure no permission-denied errors for authorized collections
4. Error logs - catch any unexpected access attempts

### Metrics to Track
1. Sync success rate for production collections
2. Page load times for production pages
3. Number of permission-denied errors (should be minimal)
4. User session duration on production pages

## Summary

### ✅ Production Supervisor CAN:
- Access production dashboard and all production pages
- View and add production entries, logs, and cutting batches
- View route orders and mark them ready for production
- View inventory (production materials only)
- View products (read-only)
- Generate production reports
- Sync production-related data

### ❌ Production Supervisor CANNOT:
- Access vehicle management pages
- Sync vehicle or diesel log data
- Access sales, dispatch, or customer pages
- Access HR, payroll, or accounting pages
- Modify master data (products, categories, etc.)
- Access admin settings or user management

### 🎯 Expected Behavior:
- Fast, department-specific sync
- No vehicle-related sync messages
- Clean navigation with only authorized pages visible
- Read-only access to shared resources (products, users)
- Full write access to production data
