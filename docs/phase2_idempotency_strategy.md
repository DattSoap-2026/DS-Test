# Phase 2: Idempotency Strategy

## Objective
Prevent duplicate stock and financial mutations during outbox retry/replay while preserving existing business logic.

## Unified Pattern
`DomainCommand -> LocalTxn -> Outbox -> IdempotentApply`

1. DomainCommand
- Command payload is created with deterministic business identity (`collection`, `action`, record key).

2. LocalTxn
- Existing local Isar write flow remains unchanged (offline-first source of truth).

3. Outbox
- Outbox envelope carries command metadata and deterministic command key.
- Critical mutation payloads include `idempotencyKey`.

4. IdempotentApply
- Server mutation handlers short-circuit when mutation is already applied.
- Replay-safe behavior prevents double increment/decrement on stock and balances.

## Technical Mechanism
- Added deterministic command key support in `OutboxCodec`:
  - `idempotencyKey` payload field
  - `commandKey` in outbox meta
  - helper methods:
    - `buildCommandKey(...)`
    - `ensureCommandPayload(...)`
    - `readIdempotencyKey(...)`

- Queue processor now injects/preserves command keys for critical mutations:
  - `payments:add`
  - `returns:approve`
  - `detailed_production_logs:add`

## Why This Prevents Replay Drift
- `payments:add`: payment doc existence guard avoids reapplying customer/sale financial increments.
- `detailed_production_logs:add`: production log existence guard avoids reapplying product stock and target increments.
- `returns:approve`: status guard (`approved`) avoids reapplying stock and customer/sale adjustments.
