# Phase 4: Migration Plan

## Schema Migration
- Isar schema migration: **Not required**
- Firestore schema migration: **Not required**

## Runtime Rollout Notes
1. Deploy app build containing Phase 4 query optimizations.
2. No data backfill required.
3. Existing sync/outbox semantics remain unchanged.

## Rollback Note
1. Revert:
   - `lib/modules/hr/services/payroll_service.dart`
   - `lib/services/dispatch_service.dart`
   - `lib/services/reports_service.dart`
2. Re-run `flutter analyze`.
3. Re-run payroll/dispatch/report smoke checks.
