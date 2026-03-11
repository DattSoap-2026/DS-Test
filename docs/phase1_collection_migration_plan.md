# Phase 1: Collection Migration Plan

## Objective
Migrate legacy Firestore collections to canonical collection names without business logic drift.

## Canonical Mapping
- `trips` -> `delivery_trips`
- `opening_stock` -> `opening_stock_entries`
- `production_daily_entries` -> `production_entries`

## Migration Strategy
1. Freeze writes briefly (maintenance window) or enforce queue-only mode.
2. Run one-time backfill copy in Firestore:
   - Read each legacy collection in chunks.
   - Upsert into canonical collection using the same document ID.
   - Preserve `createdAt`, `updatedAt`, `updatedAtEpoch`, `syncStatus`, and domain fields.
3. Validate counts:
   - `legacy_count == canonical_count` per migrated collection.
4. Validate spot-check samples:
   - At least 25 random docs per collection for field parity.
5. Keep read compatibility during cutover:
   - `InventorySyncDelegate` already supports legacy cursor keys (`opening_stock`, `trips`) and moves them to canonical keys.
6. After successful verification:
   - Stop writing legacy collections (already done in active sync paths).
   - Keep legacy collections read-only for rollback window.
7. Decommission:
   - After rollback window, archive/delete legacy collections.

## Timestamp Normalization Guidance
- Ensure migrated docs keep ISO8601 string for `createdAt`/`updatedAt`.
- Ensure `updatedAtEpoch` is numeric where present.
- Avoid mixed string/Timestamp writes for migrated canonical collections.

## Rollout Safety Checks
- Sync queue drain before cutover.
- Queue retry metadata unchanged.
- Conflict flags unchanged.
- Cursor progression verified after first sync cycle.

## Rollback Plan
1. Re-enable reads from legacy collections (temporary fallback mode if needed).
2. Keep canonical writes disabled.
3. Restore pre-cutover rules snapshot.
4. Re-run validation and resume migration only after root-cause fix.
