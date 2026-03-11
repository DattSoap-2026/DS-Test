# Phase 3: Migration Plan

## Schema Migration Requirement
- Isar schema migration: **Not required**.
- Firestore schema migration: **Not required**.

## Behavior Migration Notes
1. Voucher correction policy moves to reversal-only:
- in-place voucher-entry edit API is blocked.

2. FY lock consistency:
- opening-balance voucher creation now honors FY lock like other financial mutations.

3. Rules hardening:
- vouchers and voucher_entries updates are allowed only when financial core fields are unchanged.

## Rollout Steps
1. Deploy app build containing Phase 3 code.
2. Deploy updated `firestore.rules`.
3. Validate with `docs/phase3_financial_regression_checklist.md`.

## Backward Compatibility
- Existing voucher reads/reports are compatible.
- Existing queue/offline create flow remains compatible.
- No data backfill is required.

## Rollback Note
- If emergency rollback is needed:
1. Revert app changes in `PostingService` and `VoucherRepository`.
2. Revert rules update for voucher/voucher_entries.
3. Re-run smoke tests on posting + queue replay.
