# Phase 4: Before/After Query Strategy Summary

## 1) Payroll (`lib/modules/hr/services/payroll_service.dart`)

### Before
- `generatePayrollForMonth` performed these inside employee loop:
  - duty-session query
  - attendance query
  - advances query
  - existing payroll record query
  - holiday fetch
- `getPayrolls` performed employee fetch per payroll row.

### After
- `generatePayrollForMonth` now does one-time preloads:
  - month duty sessions (`dutySessions` once) -> grouped by `userId`
  - month attendances (`attendances` once) -> grouped by `employeeId`
  - advances (`advances` once) -> grouped by `employeeId`
  - existing month payroll records (`payrollRecords` once) -> map by `employeeId`
  - holidays fetched once for the month
- `getPayrolls` now hydrates names from one employee map.

## 2) Dispatch (`lib/services/dispatch_service.dart`)

### Before
- `createDeliveryTrip` looped over `salesIds` and queried Isar per sale (`findFirst`) then wrote per sale.

### After
- Added `_loadSalesByIds(...)` batched preload using `anyOf`.
- `createDeliveryTrip` uses preloaded map and writes changed sales with single `putAll`.

## 3) Reporting / Reconciliation (`lib/services/reports_service.dart`)

### Salesman Performance
- Before: full sales pagination scan + in-memory filtering.
- After: `_loadCustomerSalesForPerformance(...)` applies recipient/date predicate in DB query.

### Vehicle Performance
- Before: loaded all diesel logs + filtered in memory + scanned log list for each vehicle.
- After: DB-side date filter and one pass `logsByVehicle` grouping map.

### Stock Movement (Reconciliation)
- Before:
  - loaded all stock-ledger rows in many cases
  - per-movement async DB lookup for product/user names.
- After:
  - date/product-aware DB pre-filter before in-memory movement-type classification
  - batched product/user name preload maps
  - zero per-row Isar queries in result build loop.
