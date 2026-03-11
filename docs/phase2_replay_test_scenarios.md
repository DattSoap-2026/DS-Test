# Phase 2: Replay Test Scenarios

## Test Goal
Verify queue replay does not duplicate stock or financial effects.

## Scenario 1: Payment Replay (Financial)
1. Create one manual payment offline.
2. Force network restore and let first sync succeed.
3. Simulate crash before queue delete (or reinsert same queue item).
4. Re-run queue processor.

Expected:
- Payment document remains single.
- Customer balance decrement applied exactly once.
- Sale `paidAmount` increment applied exactly once.

## Scenario 2: Production Detailed Log Replay (Stock + Target)
1. Create one detailed production log offline.
2. First sync applies stock movements and target increment.
3. Replay the same outbox item.

Expected:
- Production log remains single.
- Raw material deductions applied once.
- Finished goods/wastage stock updates applied once.
- Production target achieved quantity increment applied once.

## Scenario 3: Return Approval Replay (Stock + Financial)
1. Approve one pending return offline.
2. First sync marks remote return `approved` and applies stock/customer/sale effects.
3. Replay same approval queue item.

Expected:
- No additional stock movement from replay.
- No additional customer balance adjustment from replay.
- No additional `returnedQuantity` updates from replay.
- Return remains `approved`; `approvalIdempotencyKey` present.

## Scenario 4: Mixed Queue Retry Under Backoff
1. Keep a critical mutation item failing until backoff metadata increments.
2. Ensure item retries after backoff window.
3. Ensure command key persists across retries.

Expected:
- Same command key used across retries.
- Once remote apply succeeds, further replay does not duplicate effects.

## Scenario 5: Legacy Queue Item Without Command Key
1. Seed queue item (payments/returns approve/production log) without `idempotencyKey`.
2. Run queue processor.

Expected:
- Queue processor injects deterministic command key for critical mutation.
- Apply succeeds once and remains replay-safe on subsequent retry.
