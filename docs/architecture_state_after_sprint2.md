# Architecture State After Sprint 2

Date: 2026-02-19
Scope: Offline Stability + Financial Accuracy safety controls only.

## 1) Vehicle Offline-First Invariant Rules

- Local Isar write is the source-of-truth write for vehicle create/update paths.
- Remote sync is always best-effort via outbox (`syncStatus: pending`), never required for local success.
- Vehicle payload normalization is deterministic:
  - Stable `id` always present.
  - `createdAt` preserved for existing records.
  - `updatedAt` always refreshed.
  - Deletion/sync flags are explicit and consistent.

## 2) Maintenance Aggregate Recompute Contract

- Aggregate fields are derived-state, not incrementally trusted state.
- `totalMaintenanceCost` and dependent `costPerKm` are recomputed from maintenance logs for the target vehicle.
- Recompute runs after maintenance add/update/delete and can be invoked explicitly for one vehicle or all vehicles.
- Recompute result is persisted locally first, then queued for remote sync.

## 3) Route Stream Error Propagation Policy

- `watchOrders()` no longer swallows failures into empty streams.
- Query-stream errors are surfaced through stream error channel and logged with context.
- Query construction failures return error streams (`Stream.error`) so consumers can handle degraded state explicitly.

## 4) HR Migration Non-Destructive Rule

- Attendance schema migration must not clear local attendance history.
- On schema version bump, existing attendance records are preserved and marked pending for safe resync.
- Migration is idempotent and version-gated by shared preference key.

## 5) Rollback Safety Execution Model (Txn-Safe Internal Calls)

- Rollback helpers support in-transaction execution mode to prevent nested transaction failures.
- `cancelSale()` executes rollback inside parent write transaction using txn-safe inventory calls.
- PO strict-mode compensation path restores stock and PO snapshot when posting fails.
- Rollback tests validate:
  - PO receive rollback restores stock and ordered-state snapshot.
  - Sale cancel rollback restores stock and cancellation financial flags.

