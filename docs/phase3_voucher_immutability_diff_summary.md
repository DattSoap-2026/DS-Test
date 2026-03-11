# Phase 3: Voucher Immutability Diff Summary

## Objective
Enforce append-only financial behavior for vouchers and voucher entries while preserving existing offline-first sync flow.

## Files Changed
- `lib/modules/accounting/posting_service.dart`
- `lib/modules/accounting/voucher_repository.dart`
- `firestore.rules`

## Before vs After
1. Financial year lock parity
- Before: `postSalesVoucher`, `postPurchaseVoucher`, `createManualVoucher` had FY lock checks; `createOpeningBalanceVoucher` did not.
- After: all financial mutation APIs in `PostingService` use a shared FY lock guard.

2. Direct voucher-entry edit path
- Before: `VoucherRepository.updateVoucherEntry(...)` allowed direct debit/credit/narration/dimension edits.
- After: `updateVoucherEntry(...)` is hard-blocked with immutable-policy error.

3. Reversal workflow support
- Before: no dedicated repository/service reversal creation API.
- After:
  - `PostingService.createVoucherReversal(...)`
  - `VoucherRepository.createReversalVoucherBundle(...)`
  - Reversal creates a new voucher with inverted entry legs (append-only correction path).

4. Firestore rule hardening
- Before: `vouchers` and `voucher_entries` allowed unrestricted accountant/admin updates.
- After: updates allowed only if financial core fields remain unchanged; create remains allowed; delete remains blocked.

## Business Logic Drift Check
- Core posting calculations and voucher creation flow are unchanged.
- Correction path is now explicit: reversal voucher, not in-place financial edit.
