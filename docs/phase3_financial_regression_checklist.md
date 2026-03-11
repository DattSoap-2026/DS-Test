# Phase 3: Financial Regression Checklist

## Voucher Creation Paths
1. Post sales voucher and verify:
- voucher created once
- balanced entries
- FY lock blocks mutation when year is locked

2. Post purchase voucher and verify:
- voucher created once
- balanced entries
- FY lock blocks mutation when year is locked

3. Create manual voucher and verify:
- voucher created with expected type/series
- FY lock guard enforced

4. Create opening balance voucher and verify:
- FY lock guard now enforced
- existing posting behavior unchanged when year is open

## Immutability
1. Call `updateVoucherEntry(...)` and verify:
- operation fails with immutable-policy error

2. Attempt Firestore update on voucher financial fields (`totalDebit/totalCredit/amount`) and verify:
- rule denial

3. Attempt Firestore update on voucher entry `debit/credit/accountCode` and verify:
- rule denial

## Reversal
1. Create reversal for existing voucher and verify:
- new voucher is created (no overwrite of original)
- entry legs are inverted
- original voucher remains unchanged
- linked reference fields present (`linkedId`, `reversalOfVoucherId`)

## Sync / Offline Safety
1. Create voucher offline, sync later:
- still syncs via existing queue path
- no duplicate side effects

2. Replay same queue payload:
- no financial core mutation drift on existing docs
