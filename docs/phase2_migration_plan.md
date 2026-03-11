# Phase 2: Migration Plan

## Schema Migration Requirement
- Isar schema migration: **Not required**.
- Firestore schema migration: **Not required** (only additive fields).

## New Additive Fields
- `idempotencyKey` on payment and production-log mutation payload/doc.
- `approvalIdempotencyKey` on approved return docs.
- `commandKey` stored in outbox envelope metadata.

## Rollout Notes
1. Deploy app update with Phase 2 code.
2. Existing queue items without idempotency key remain supported:
   - queue processor injects deterministic command key for critical mutations.
3. No backfill required for existing Firestore documents.

## Backward Compatibility
- Missing idempotency fields on legacy docs do not break reads.
- Existing sync semantics and conflict handling remain unchanged.
