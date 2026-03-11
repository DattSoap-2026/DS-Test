# Sync Delegate Optimization TODO

## Rules
- Optimization only (no business logic drift)
- No sync order/queue behavior changes
- No per-document Isar query inside loops
- Keep `flutter analyze` clean after each pass

## Completed
- [x] `SyncQueueProcessorDelegate`
  - Fixed `dispatches` local mapping/cache ownership
  - Replaced unresolved unit fallback full scan with indexed batch lookup
  - Parallelized hashed preload phase with `Future.wait`
- [x] `QueueModulesSyncDelegate`
  - Replaced full queue scan with filtered queue-only collection query
- [x] `PartnerOutboxDelegate`
  - Optimized outbox delete path to `deleteById` (removed pre-read)
- [x] `MasterDataSyncDelegate`
  - Batched local push-side updates (`putAll`) + queue deletions (`deleteAll`)
- [x] `HRSyncDelegate`
  - Batched local push-side updates (`putAll`) + queue deletions (`deleteAll`)
  - Covered: `attendances`, `employees`, `leave_requests`, `advances`, `performance_reviews`, `employee_documents`

## Remaining
- [x] `SalesSyncDelegate`
  - Batched local push updates (`putAll`) across sales/returns/payments/route_sessions/customer_visits
  - Batched sales targets local updates + queue deletions (`putAll` + `deleteAll`)
- [x] `InventorySyncDelegate`
  - Batched local push updates (`putAll`) across inventory push modules
- [x] `AccountingSyncDelegate`
  - Batched chunk push local writes to `putAll` for `accounts`, `vouchers`, `voucher_entries`
- [x] `UsersSyncDelegate`
  - Batched push-side local writes (`putAll`) for user chunks
- [x] `CustomersSyncDelegate`
  - Batched pull-side local writes (`putAll`) for resolved customer docs
- [x] `DealersSyncDelegate`
  - Batched pull-side local writes (`putAll`) for resolved dealer docs
- [x] `DutySessionsSyncDelegate`
  - Batched push-side local writes (`putAll`) and pull-side upserts (`putAll`)
