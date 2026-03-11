# Role UI Walkthrough Runbook

## One-Command Run
```bash
dart run scripts/role_ui_walkthrough.dart
```

## Stable Role Credentials (Recommended First Step)
```bash
dart run scripts/provision_role_test_credentials.dart
```

This provisions persistent QA accounts for all 15 roles with one shared password and writes:
- `run_role_test_credentials_matrix.json`
- `docs/role_test_credentials_matrix.md`

## What It Runs
1. RBAC test suite:
   - `test/services/permission_service_test.dart`
   - `test/constants/nav_items_rbac_test.dart`
   - `test/constants/role_access_matrix_test.dart`
2. Bhatti guard:
   - `scripts/bhatti_supervisor_smoke_guard.dart`
3. Live Firebase checks:
   - Existing active role sample login probe
   - Temporary 15-role user creation -> login -> cleanup walkthrough
   - User count baseline vs post-cleanup integrity check

## Optional Env Vars
- `DATT_SKIP_LIVE_ROLE_QA=true`
  - Skip all live Firebase checks; run local checks only.
- `DATT_FIREBASE_API_KEY`
- `DATT_FIREBASE_PROJECT_ID`
- `DATT_ADMIN_EMAIL`
- `DATT_ADMIN_PASSWORD`
- `DATT_TEST_PASSWORD`
- `DATT_SAMPLE_PASSWORD`
- `DATT_MATRIX_PASSWORD` (used by credential matrix provisioning script)

If not provided, script uses defaults suitable for current DattSoap setup.

## Outputs
- JSON: `run_role_ui_walkthrough_report.json`
- Markdown: `docs/role_ui_walkthrough_report_YYYY-MM-DD.md`

## Exit Code
- `0`: no open Critical/Normal findings
- `1`: Critical or Normal open finding detected
