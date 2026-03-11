# Phase 4: Performance Hotspot Comparison

## Scope
- Payroll (`lib/modules/hr/services/payroll_service.dart`)
- Dispatch (`lib/services/dispatch_service.dart`)
- Reporting/Reconciliation (`lib/services/reports_service.dart`)

## Hotspot Table
| Module | Hotspot (Before) | Optimization (After) | Impact |
|---|---|---|---|
| Payroll generation | Per-employee queries inside loop for duty sessions, attendances, advances, and existing payroll record lookup | Single month-wide preload + in-memory maps (`sessionsByUserId`, `attendancesByEmployee`, `advancesByEmployee`, `existingByEmployee`) | Removes repeated per-employee DB scans; stable at large employee counts |
| Payroll listing | `getPayrolls` did `getEmployee` call per payroll row | Single employee preload map before row hydration | Removes N+1 employee lookups |
| Dispatch trip create | Per-sale `findFirst` inside `salesIds` loop, then per-item `put` | Batched sale preload (`_loadSalesByIds`) + single `putAll` | Removes per-sale query/write loop overhead |
| Salesman performance report | Full sales scan (`_fetchAllSalesPaged`) then in-memory recipient/date filtering | DB-side recipient/date predicate via `_loadCustomerSalesForPerformance` | Reduces full-scan pressure on sales table |
| Vehicle performance report | Full diesel log scan + per-vehicle repeated `logs.where(...)` scans | DB-side date predicate + pre-group `logsByVehicle` map | Eliminates repeated O(V*L) in-memory scans |
| Stock movement/reconciliation report | Full stock-ledger scan + per-row product/user DB gets inside loop | Date/product-aware pre-filter + batched name preload maps (`_loadProductNameMap`, `_loadUserNameMap`) | Eliminates per-row lookup N+1 and reduces all-time scan usage |
