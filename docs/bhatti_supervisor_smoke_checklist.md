# Bhatti Supervisor Smoke Checklist

This checklist validates the bhatti supervisor flow end-to-end after changes.

## 1. Static Guard (quick root check)

Run:

```bash
dart run scripts/bhatti_supervisor_smoke_guard.dart
```

Expected:
- All checks pass.
- No missing route/nav/role-specific logic.

## 2. Compile Safety

Run:

```bash
flutter analyze lib/screens/bhatti lib/screens/inventory/inventory_overview_screen.dart lib/widgets/inventory/inventory_analytics_card.dart lib/screens/reports/bhatti_report_screen.dart
```

Expected:
- No analyzer errors.

## 3. Cooking Submission Flow (critical)

Steps:
1. Login as bhatti supervisor.
2. Open `Batch Mgmt`.
3. Select `Sona Bhatti` or `Gita Bhatti`.
4. Select a semi-finish formula.
5. Enter tank consumption (Kg).
6. Add extra ingredient if needed.
7. Set batch count.
8. Click `Submit`.
9. Confirm in dialog and save.

Expected:
- Confirm dialog shows tank-wise and total ingredient consumption.
- Save success toast appears.
- Screen resets formula and batch count.

## 4. Inventory Impact

Steps:
1. Open `Stock Inventory` (bhatti supervisor view).
2. Check semi-finish product stock for formula output.
3. Check relevant tank stocks.
4. Check raw materials used as non-tank ingredients.

Expected:
- Semi-finish stock increments by expected output boxes.
- Tank stocks decrement based on submitted tank consumption.
- Non-tank raw materials decrement from bhatti department stock.
- On bhatti supervisor inventory analytics:
  - `Total Stock Value` not visible.
  - `Stock Availability` not visible.

## 5. Batch History and Edit

Steps:
1. Open `Batch History`.
2. Verify newly submitted batch appears.
3. Tap batch row to open edit.
4. Modify output or materials and save.
5. Return to history.

Expected:
- New batch appears in history list.
- Edit save succeeds.
- Updated values reflect after refresh.

## 6. Report Consistency

Steps:
1. Open `Bhatti Reports`.
2. Select date range including recent submission.
3. Verify overview KPIs and batch list.

Expected:
- Total batches uses actual `batchCount` sum from detailed batches.
- Sona/Gita counts are batch-count sums, not row counts.
- Total output boxes matches detailed batches in selected range.

## 7. Mobile Layout Audit

Check on narrow widths (320-390):
- `Batch Mgmt`: top selector and bottom submit area do not overflow.
- `Batch History`: filters and cards do not overflow.
- `Inventory Overview`: analytics cards do not show bottom overflow.
- `Bhatti Reports`: header, tabs, cards do not overflow.

Expected:
- No `RenderFlex overflow` in console.
