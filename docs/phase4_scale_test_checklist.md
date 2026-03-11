# Phase 4: Scale Test Checklist (10k / 50k)

## Goal
Validate performance stabilization without business-logic drift.

## Dataset Tiers
1. Tier A: ~10k sales, ~10k stock-ledger rows, ~2k diesel logs, ~500 employees
2. Tier B: ~50k sales, ~50k stock-ledger rows, ~10k diesel logs, ~2k employees

## Test Scenarios
1. Payroll generation (`generatePayrollForMonth`)
- Measure total execution time per month run.
- Verify net salary, deductions, and draft-update behavior match baseline.
- Confirm no per-employee query spikes in profiler.

2. Payroll listing (`getPayrolls`)
- Measure response time for month view.
- Confirm employee name hydration is correct for all rows.

3. Dispatch trip creation (`createDeliveryTrip`)
- Use 50, 200, 500 `salesIds` batches.
- Measure DB transaction time and queue creation latency.
- Verify all linked sales become `in_transit` with same `tripId`.

4. Salesman performance report
- Compare runtime before/after for same date range.
- Verify totals: sales count, revenue, items sold, target percentages.

5. Vehicle performance report
- Compare runtime before/after under same diesel-log volume.
- Verify totals: distance, liters, cost, mileage, cost/km.

6. Stock movement report
- Run with:
  - no filters
  - date range only
  - date + product + movement type
- Verify no per-row lookup spikes and correct product/user names.

## Integrity Checks
1. Business logic parity:
- payroll net salary unchanged for same input
- dispatch status updates unchanged
- report totals unchanged within floating-point tolerance

2. Sync/queue parity:
- outbox entries still generated where applicable
- no duplicate or missing queue records

3. Analyzer gate:
- `flutter analyze` must remain clean after each optimization batch.
