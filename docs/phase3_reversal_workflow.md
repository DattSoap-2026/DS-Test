# Phase 3: Reversal Workflow

## Why
Financial documents must remain append-only for auditability. Corrections should never mutate original debit/credit effects.

## API Entry Point
Use:
- `PostingService.createVoucherReversal(...)`

Inputs:
- `originalVoucherId`
- `reason`
- `postedByUserId`
- optional `postedByName`
- optional `reversalDate`
- optional strict-mode override

## Flow
1. Validate strict mode and ensure default accounts.
2. Validate FY is not locked for reversal date.
3. Reserve reversal voucher number (`voucherType = reversal`).
4. Load original voucher and its entries.
5. Create new reversal voucher with:
- new `transactionRefId`
- `transactionType = reversal`
- link to original voucher (`linkedId`, `reversalOfVoucherId`)
- explicit reason (`reversalReason`)
6. Create reversal entries by inverting original legs:
- `debit -> credit`
- `credit -> debit`
7. Persist through existing `createVoucherBundle(...)` path (local + queue/strict sync).

## Guardrails
- No edit-in-place for voucher entries.
- Delete for financial docs remains blocked.
- Firestore updates cannot alter financial core fields for vouchers/voucher_entries.
