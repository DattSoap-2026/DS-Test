# Phase 2: Guarded Mutation Points

## Core Idempotency Infrastructure
- `lib/services/outbox_codec.dart:20`
  - `idempotencyKey` and `commandKey` fields introduced.
- `lib/services/outbox_codec.dart:25`
  - deterministic `buildCommandKey(...)`.
- `lib/services/outbox_codec.dart:50`
  - `ensureCommandPayload(...)` to normalize critical mutation payloads.

## Queue Replay Hardening
- `lib/services/delegates/sync_queue_processor_delegate.dart:160`
  - critical mutations now receive normalized command payload before dispatch.
- `lib/services/delegates/sync_queue_processor_delegate.dart:398`
  - `_applyIdempotencyForCriticalMutation(...)` targets:
    - `payments:add`
    - `returns:approve`
    - `detailed_production_logs:add`

## Payments (Financial Effect Guard)
- `lib/services/payments_service.dart:307`
  - outbox enqueue adds deterministic command payload.
- `lib/services/payments_service.dart:502`
  - transaction short-circuits when payment doc already exists.
- `lib/services/payments_service.dart:555`
  - persisted `idempotencyKey` on payment document.

## Production (Stock + Target Effect Guard)
- `lib/services/production_service.dart:171`
  - detailed production log apply short-circuits if log doc already exists.
- `lib/services/production_service.dart:254`
  - persisted `idempotencyKey` on production log document.
- `lib/services/production_service.dart:750`
  - production command payload normalized before enqueue/sync.

## Returns Approval (Stock + Financial Effect Guard)
- `lib/services/returns_service.dart:158`
  - return queue payload normalized with deterministic command key.
- `lib/services/returns_service.dart:881`
  - approval flow exits if return already approved (replay-safe guard).
- `lib/services/returns_service.dart:977`
  - persisted `approvalIdempotencyKey` on approved return document.
