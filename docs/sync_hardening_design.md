# Sync Hardening Design

## Scope
- Durable outbox for all offline-first write paths.
- Per-record push with retry/backoff and permanent failure marking.
- Push + pull pipeline for modules that previously relied on pull-only sync.
- Forensic visibility for pending state, permanent failures, and last sync attempt.

## Core Invariants
- Every local write must produce:
  - Local entity mutation with `syncStatus = pending`
  - Durable queue entry in `syncQueue`
- Queue items are deterministic and idempotent:
  - Queue id generated from collection + record key
  - Rewrites upsert the same queue row
- Queue processing is non-destructive:
  - Item removed only after successful push
  - Failures increment attempt count and backoff delay
  - Permanent failures retained with `permanentFailure = true`
- Pull never overwrites pending/conflict local state silently:
  - Conflicts are flagged and local record remains retained

## Outbox Envelope
- Stored in `syncQueue.dataJson`:
  - `__outbox`: metadata (`attemptCount`, `nextRetryAt`, `permanentFailure`, timestamps)
  - `payload`: sync payload
- Metadata updates:
  - Success: reset retry state
  - Failure: exponential backoff + permanent failure after max attempts

## Pipeline Changes
- `SyncManager.syncAll` now includes:
  - Master data sync: `units`, `product_categories`, `product_types`
  - HR sync: `employees`, `leave_requests`, `advances`, `performance_reviews`, `employee_documents`
- `SyncManager.processSyncQueue`:
  - Skips delayed retry windows and permanent failures
  - Pushes per record (no batch cascade failure)
  - Marks local records synced only after successful push

## Service Write Path Changes
- HR services now enqueue outbox on writes:
  - `hr_service.dart`
  - `leave_service.dart`
  - `advance_service.dart`
  - `performance_review_service.dart`
  - `document_service.dart`
- `master_data_service.dart`:
  - Delete operations switched to tombstone (`isDeleted = true`)
  - Local records retained and queued for delete sync
  - Read APIs filter soft-deleted records

## Forensic Visibility
- `ForensicAuditSnapshot` expanded with:
  - `outboxPermanentFailures`
  - `lastSyncAttempt`
  - module audits for HR + master data modules
- Analytics UI now shows:
  - Permanent outbox failures
  - Last sync attempt status
  - Module-wise pending/outbox/conflict summary
  - Risk flags

## Validation Matrix
- Offline create -> restart -> online sync -> remote row exists.
- Offline update -> restart -> online sync -> remote row updated.
- Offline delete -> restart -> online sync -> remote tombstone (`isDeleted=true`).
- Conflict path:
  - Local pending + remote newer update -> conflict flagged, no silent overwrite.
- Queue durability:
  - Forced push failure -> queue retained with retry metadata.
  - Repeated failures -> permanent failure flagged and visible in forensic UI.
