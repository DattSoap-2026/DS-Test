# Soft Delete + Tombstone Hybrid (Offline-First ERP)

## 1) Firestore Schema Contract

For sync-enabled collections, documents now follow:

```json
{
  "isDeleted": false,
  "deletedAt": null,
  "updatedAt": "2026-02-17T10:15:00.000Z"
}
```

Soft delete mutation:

```json
{
  "isDeleted": true,
  "deletedAt": "<now>",
  "updatedAt": "<now>"
}
```

Tombstone safety collection:

```json
// collection: deleted_records
{
  "entityType": "products",
  "docId": "product_123",
  "deletedAt": "2026-02-17T10:15:00.000Z",
  "createdAt": "2026-02-17T10:15:00.000Z"
}
```

## 2) Local DB Model Update

- `lib/data/local/base_entity.dart`
  - Added nullable `deletedAt`.
- Entity serializers updated to preserve soft-delete flags where missing earlier:
  - `lib/data/local/entities/bhatti_entry_entity.dart`
  - `lib/data/local/entities/production_entry_entity.dart`
  - `lib/data/local/entities/bhatti_batch_entity.dart`
  - `lib/data/local/entities/wastage_log_entity.dart`
  - `lib/data/local/entities/department_stock_entity.dart`

## 3) Sync Manager Changes

- `lib/services/sync_manager.dart`
  - Added tombstone sync step in `syncAll(...)`: `_syncDeletedRecords(...)`.
  - Added force-refresh critical reconcile: `_runCriticalReconcile(...)`.
  - Added delta tombstone pull:
    - reads `deleted_records` with `deletedAt > lastSync`.
    - marks local rows deleted by `entityType/docId`.
    - stores processed tombstone ids locally.
  - Added targeted reconcile for critical modules (manual refresh only):
    - Inventory: `products`, `tanks`, `stock_ledger`
    - Financial: `accounts`, `vouchers`, `voucher_entries`
    - Bhatti reports: `bhatti_entries`, `bhatti_batches`, `wastage_logs`
  - Queue + generic upsert now normalize soft delete payload:
    - `isDeleted`, `deletedAt`, `updatedAt`
  - Financial delete guard:
    - blocks client delete for `accounts`, `vouchers`, `voucher_entries`
    - enforces reversal-only policy.

## 4) Tombstone Pull Algorithm (Pseudocode)

```text
lastSync = getLastSync("deleted_records")
rows = firestore.deleted_records.where(deletedAt > lastSync)

for row in rows:
  if alreadyProcessed(row.id): continue
  applyLocalDelete(row.entityType, row.docId, row.deletedAt)
  markProcessed(row.id)
  maxDeletedAt = max(maxDeletedAt, row.deletedAt)

setLastSync("deleted_records", maxDeletedAt)
persistProcessedIds()
```

## 5) Offline Queue Handling

- `lib/services/offline_first_service.dart`
  - `deleteFromLocal(...)` now marks soft-delete (not physical removal).
  - `performSync('delete', ...)` now does soft delete in Firestore (merge set).
  - Non-delete writes normalize `updatedAt/isDeleted/deletedAt`.
  - Financial delete attempts are blocked.

## 6) Hard Delete Safety Layer

- `lib/services/data_management_service.dart`
  - Before each hard delete, writes tombstone entry in `deleted_records`.
  - Applied to reset/purge flows and collection wipe helpers.
  - Batch sizing adjusted to remain under Firestore write limits.

## 7) UI/Query Visibility Rule

- Active list filters now exclude deleted rows in Bhatti report data reads:
  - `lib/services/bhatti_service.dart`
    - `getBhattiBatches`
    - `getWastageLogs`
    - `getDepartmentStocks`
    - `getDailyEntries`
    - `getBhattiBatchById`

## 8) Business Safety Rules Mapped

- Financial docs: delete blocked at sync layer (reversal-only).
- Production logs: soft-delete path enabled.
- Inventory: hard-delete ghost cleanup handled by tombstones + critical reconcile;
  operational correction remains via stock-ledger adjustments.

## 9) Backward Compatibility

- Existing delta sync remains `updatedAt`-based.
- Missing `isDeleted/deletedAt` in old docs defaults to active behavior.
- Soft delete uses merge writes; no schema-breaking server migration required.
