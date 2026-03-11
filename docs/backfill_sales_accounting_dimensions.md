# Sales Accounting Dimensions Backfill

This runbook backfills historical sales accounting context without changing UI.

## What it updates

- Sales document metadata in `sales`:
  - `route`, `district`, `division`, `salesmanId`, `salesmanName`, `saleDate`
  - dealer context (`dealerId`, `dealerName`) where applicable
  - `accountingDimensions` + `dimensionVersion`
- Related `vouchers` (sales vouchers):
  - dimension-aware narration
  - `accountingDimensions` + `dimensionVersion`
- Related `voucher_entries`:
  - dimension-aware narration
  - `accountingDimensions` + `dimensionVersion`

## Command

```powershell
flutter run -d windows -t scripts/backfill_sales_accounting_dimensions.dart --no-resident -- --dry-run
```

Then run actual patch:

```powershell
flutter run -d windows -t scripts/backfill_sales_accounting_dimensions.dart --no-resident
```

## Options

- `--dry-run`: no writes, only summary output
- `--sync-now`: initialize Firebase and push immediately
- `--include-cancelled`: include cancelled sales
- `--limit=<N>`: process only first N historical sales

## Recommended sequence

1. Dry run:
   `flutter run -d windows -t scripts/backfill_sales_accounting_dimensions.dart --no-resident -- --dry-run`
2. Limited live run:
   `flutter run -d windows -t scripts/backfill_sales_accounting_dimensions.dart --no-resident -- --limit=200`
3. Full live run:
   `flutter run -d windows -t scripts/backfill_sales_accounting_dimensions.dart --no-resident`
