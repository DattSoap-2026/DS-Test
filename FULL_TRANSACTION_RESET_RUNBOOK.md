# Full Transaction Reset Runbook

Purpose: Verify and document the complete transactional wipe while preserving master data.

## Scope (Confirmed)
Keep (do not reset):
- Users / Employees (profiles, roles, vehicle assignment)
- Routes
- Business Partners (Customers, Dealers, Suppliers)
- Product Master
- Vehicles
- All Master Data (Units, Categories, Product Types, Schemes, Departments, Tax & Transaction Series, Roles, Company Profile)
- Employee documents (ID proofs, contracts, certificates)

Reset (wipe completely):
- Sales, Sale Items, Sales History, Sales Payments, Sales Returns
- Dispatches, Dispatch Items, Dispatch History, Delivery Trips
- Salesman Allocated Stock, Salesman Stock Transactions, Salesman Stock History
- Purchases / Purchase Orders
- Returns, Payments, Approvals
- Production logs, targets, detailed logs
- Bhatti batches & wastage logs
- Cutting batches
- Stock ledger, stock movements, department stock
- Tank transactions, tank lots, tank levels
- Diesel logs, fuel purchases, vehicle maintenance logs
- Duty sessions, route sessions, customer visits
- Sales targets, payroll, attendance, leave, advances, performance reviews
- Alerts, sync queue, conflicts, sync metrics
- GPS locations & history
- Route Orders, Route Order Items, Tasks, Task History
- Vouchers, Voucher Entries, Schemes
- Notifications, Notification Events
- All offline (Isar) + SharedPreferences transactional caches

Stock rule:
- Recompute `products.stock` from Opening Stock
- Clear all users `allocatedStock`

## Preconditions
1. Admin/Owner account is logged in.
2. Internet is available (required for Firebase reset and resync).
3. Backup is taken (System Data -> Backups & Restore -> Download Full Backup).

## Execution Steps (UI)
1. Navigate to System Data -> Data Buckets.
2. Click `Run Full Transaction Reset`.
3. Type `RESET TRANSACTIONS` and confirm.
4. Wait for reset status to finish and the completion summary dialog.
5. Allow the forced resync to complete.

## Validation Checklist (Firebase)
- Collections empty: `sales`, `sale_items`, `sales_history`, `sales_payments`, `sales_returns`
- Collections empty: `dispatches`, `dispatch_items`, `dispatch_history`, `delivery_trips`
- Collections empty: `salesman_allocated_stock`, `salesman_stock_transactions`, `salesman_stock_history`
- Collections empty: `purchase_orders`, `returns`
- Collections empty: `payments`, `payment_links`, `approvals`
- Collections empty: `production_logs`, `production_targets`, `detailed_production_logs`
- Collections empty: `production_entries`, `production_daily_entries`
- Collections empty: `bhatti_batches`, `bhatti_entries`, `bhatti_daily_entries`, `wastage_logs`
- Collections empty: `cutting_batches`
- Collections empty: `stock_ledger`, `stock_movements`, `department_stocks`
- Collections empty: `tanks`, `tank_transactions`, `tank_transfers`, `tank_lots`
- Collections empty: `diesel_logs`, `fuel_purchases`, `vehicle_maintenance_logs`
- Collections empty: `duty_sessions`, `route_sessions`, `customer_visits`
- Collections empty: `sales_targets`, `payroll_records`, `attendances`
- Collections empty: `route_orders`, `route_order_items`, `tasks`, `task_history`
- Collections empty: `vouchers`, `voucher_entries`, `schemes`
- Collections empty: `notification_events`, `alerts`
- `locations` collection empty
- `locations/{id}/history` subcollections deleted
- `users.allocatedStock` is empty for all users
- `products.stock` equals sum of `opening_stock_entries` by productId
- `employee_documents` collection PRESERVED (NOT empty)

## Validation Checklist (Local / UI)
- My Stock shows stock from Opening Stock only.
- Dispatch, Dispatch Items, Sales, Sales Items, Returns, Production history screens are empty.
- Salesman Stock page shows 0 allocated stock.
- Approvals and Fuel Purchases screens are empty.
- Tanks list is empty.
- Employee Documents are PRESERVED and visible.
- Keep-list screens still show data (Users, Routes, Business Partners, Products, Vehicles, Master Data).

## Expected Outcomes
- Transactional data fully wiped from Firebase and Isar.
- Cached transactional SharedPreferences keys removed.
- Master data preserved and re-synced.
- No residual allocated stock or stale stock movements.

## Failure Handling
- If reset fails:
  - Verify Firebase permissions and admin access.
  - Check internet connectivity.
  - Retry after ensuring user is authenticated.
  - Review logs for the failing collection.
