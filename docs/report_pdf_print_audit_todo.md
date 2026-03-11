# Report PDF/Print Audit TODO

Date: 2026-02-22
Scope: `lib/screens/reports/*.dart`

## Audit Summary

- Total report-folder screens: `28`
- Export-ready screens (Report mixin + Print/PDF actions): `25`
- Non-report hub/navigation screens (no per-page export required): `2`
  - `lib/screens/reports/reports_module_screen.dart`
  - `lib/screens/reports/reporting_hub_screen.dart` (has quick print tools)
- Missing standard per-page export at audit start: `1`
  - `lib/screens/reports/my_performance_screen.dart`

## Consolidated Checklist

1. [x] `lib/screens/reports/my_performance_screen.dart`
   - Add standard `ReportPdfMixin` integration.
   - Add `ReportExportActions` (PDF + Print).
   - Add export dataset loading with summary and daily rows.
   - Keep existing on-screen `TargetAnalysisWidget` behavior unchanged.

2. [x] Runtime QA pass for all export-ready report pages (code-level contract + analyzer)
   - Validate Print opens with data.
   - Validate Share/Export creates PDF.
   - Validate filters appear in PDF summary.
   - Validate empty-state handling (`hasExportData`) is correct.
   - Status: static contract validation completed for all leaf report pages; full tap-flow remains manual.

3. [x] Encoding consistency pass (visual text in generated PDFs)
   - Replace remaining mojibake currency text where present.
   - Keep runtime/report logic unchanged.

## One-by-One Validation Grid

- [ ] `lib/screens/reports/bhatti_report_screen.dart`
- [ ] `lib/screens/reports/customer_aging_report_screen.dart`
- [ ] `lib/screens/reports/cutting_yield_report_screen.dart`
- [ ] `lib/screens/reports/dealer_detail_history_screen.dart`
- [ ] `lib/screens/reports/dealer_report_screen.dart`
- [ ] `lib/screens/reports/diesel_report_screen.dart`
- [ ] `lib/screens/reports/financial_report_screen.dart`
- [ ] `lib/screens/reports/fleet_performance_report_screen.dart`
- [ ] `lib/screens/reports/gst_report_screen.dart`
- [ ] `lib/screens/reports/maintenance_report_screen.dart`
- [x] `lib/screens/reports/my_performance_screen.dart`
- [ ] `lib/screens/reports/production_report_screen.dart`
- [ ] `lib/screens/reports/returns_report_screen.dart`
- [ ] `lib/screens/reports/sales_dispatch_report_screen.dart`
- [ ] `lib/screens/reports/salesman_performance_screen.dart`
- [ ] `lib/screens/reports/salesman_report_screen.dart`
- [ ] `lib/screens/reports/stock_ledger_screen.dart`
- [ ] `lib/screens/reports/stock_movement_report_screen.dart`
- [ ] `lib/screens/reports/stock_valuation_report_screen.dart`
- [ ] `lib/screens/reports/tally_export_report_screen.dart`
- [ ] `lib/screens/reports/target_achievement_report_screen.dart`
- [ ] `lib/screens/reports/tyre_report_screen.dart`
- [ ] `lib/screens/reports/vehicle_expiry_report_screen.dart`
- [ ] `lib/screens/reports/vehicle_monthly_expense_report_screen.dart`
- [ ] `lib/screens/reports/vehicle_yearly_detailed_report_screen.dart`
- [ ] `lib/screens/reports/waste_analysis_report_screen.dart`
