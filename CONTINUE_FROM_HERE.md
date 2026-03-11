# ERP Stabilization Handoff

Date: 2026-03-07
Current branch: `fix/T5-canonical-user-identity`

## Completed

- `T1 / R1`: Department issue/return stock symmetry fixed
- `T2 / R2`: Salesman allocation blocked from sales flow
- `T3 / R4`: Opening stock hardened to single-warehouse `Main`
- `T4 / R5`: Opening stock moved to set-balance semantics
- `T5 / R11`: Canonical Firebase UID applied in scoped sales write/filter paths

## Verified

- `flutter analyze` passed for the latest T5 scoped files
- DB-backed integration tests are still expected to require:
  - `--dart-define=RUN_DB_TESTS=true`
  - native Isar runtime available on the machine

## Important residual note

- T5 was implemented with a strict scope boundary.
- Sales write/filter paths now use Firebase UID.
- Some legacy local user lookups in `sales_service.dart` still resolve users by local `users.id`.
- Before expanding salesman customer-sale compatibility, review these local lookup points:
  - `createSale()` local customer deduction path
  - strict-mode compensation path
  - conflict compensation path
  - sale edit path

## Continue next from here

Next planned task: `T6 / R7`

Goal:
- Move production, bhatti, and cutting stock mutations to the same durable outbox queue used by sales and dispatch.

Recommended order:
1. Inspect current immediate-sync calls in `production_service.dart`, `bhatti_service.dart`, and `cutting_batch_service.dart`
2. Reuse the durable queue pattern already used in `sales_service.dart`
3. Add queue handlers in `sync_queue_processor_delegate.dart`
4. Add one offline-to-online regression test for queued production replay

## Pull on another PC

1. `git fetch origin`
2. `git checkout fix/T5-canonical-user-identity`
3. `git pull origin fix/T5-canonical-user-identity`
