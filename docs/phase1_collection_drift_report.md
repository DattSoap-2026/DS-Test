# Phase 1: Collection Drift Report

## Scope
- Sync orchestration and delegate layer
- Firestore rules coverage for active sync collections
- Legacy collection aliasing for controlled migration

## Before (Detected Drift)
1. `trips` used in sync writes/reads while canonical collection is `delivery_trips`.
2. `opening_stock` used in sync writes/reads while canonical collection is `opening_stock_entries`.
3. `production_daily_entries` used in production write path while canonical collection is `production_entries`.
4. `payments` and `payment_links` used by service logic but missing explicit Firestore rules.

## After (Current State)
1. Canonical source introduced: `lib/core/constants/collection_registry.dart`.
2. Sync delegates moved to `CollectionRegistry` constants; raw `db.collection('...')` removed from delegate files.
3. `InventorySyncDelegate` now uses canonical collections:
   - `opening_stock_entries`
   - `delivery_trips`
   - `production_entries`
   with legacy last-sync cursor fallback for `opening_stock` and `trips`.
4. `ProductionService.saveDailyEntry` now writes to `production_entries`.
5. `PaymentsService` and related collection constants now use `CollectionRegistry`.
6. Firestore rules now include:
   - `match /payments/{paymentId}`
   - `match /payment_links/{linkId}`
7. Product rule alignment updated to accept production-team stock writes on `stock` (in addition to `currentStock`) to match active service behavior.

## Verification Notes
- No active sync-path Firestore collection calls remain on legacy names:
  - `collection('trips')`
  - `collection('opening_stock')`
  - `collection('production_daily_entries')`
- `flutter analyze` is clean after Phase 1.
