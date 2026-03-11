@echo off
REM Documentation Cleanup Script
REM Moves old documentation files to archive folders

echo ========================================
echo DattSoap Documentation Cleanup
echo ========================================
echo.

REM Create archive subdirectories
echo Creating archive directories...
mkdir docs\archive\audit_reports 2>nul
mkdir docs\archive\implementation_reports 2>nul
mkdir docs\archive\task_reports 2>nul
mkdir docs\archive\feature_reports 2>nul
mkdir docs\archive\migration_reports 2>nul
mkdir docs\archive\dev_notes 2>nul
mkdir docs\archive\agent_reports 2>nul
mkdir docs\archive\misc 2>nul

echo.
echo ========================================
echo Moving Audit Reports...
echo ========================================

move "ABSOLUTE_FINAL_AUDIT_REPORT.md" "docs\archive\audit_reports\" 2>nul
move "ABSOLUTE_FINAL_HINDI.md" "docs\archive\audit_reports\" 2>nul
move "AUDIT_FIXES_COMPLETION_SUMMARY.md" "docs\archive\audit_reports\" 2>nul
move "BHATTI_AUDIT_FEATURE.md" "docs\archive\audit_reports\" 2>nul
move "BHATTI_AUDIT_REPORT.md" "docs\archive\audit_reports\" 2>nul
move "BHATTI_MOBILE_FIRST_AUDIT.md" "docs\archive\audit_reports\" 2>nul
move "BHATTI_SUPERVISOR_COMPLETE_AUDIT_2024.md" "docs\archive\audit_reports\" 2>nul
move "BHATTI_TECHNICAL_AUDIT.md" "docs\archive\audit_reports\" 2>nul
move "BHATTI_UX_QUICK_BUTTONS_AUDIT.md" "docs\archive\audit_reports\" 2>nul
move "COMPLETE_AUDIT_FINAL_REPORT.md" "docs\archive\audit_reports\" 2>nul
move "COMPLETE_AUDIT_HINDI_FINAL.md" "docs\archive\audit_reports\" 2>nul
move "COMPLETE_PROJECT_AUDIT_2024.md" "docs\archive\audit_reports\" 2>nul
move "DEALER_DISPATCH_DISCOUNT_AUDIT.md" "docs\archive\audit_reports\" 2>nul
move "DEEP_MATHEMATICAL_AUDIT_REPORT.md" "docs\archive\audit_reports\" 2>nul
move "DEEP_TECHNICAL_AUDIT.md" "docs\archive\audit_reports\" 2>nul
move "FINAL_AUDIT_SUMMARY.md" "docs\archive\audit_reports\" 2>nul
move "FINAL_AUDIT_SUMMARY_HINDI.md" "docs\archive\audit_reports\" 2>nul
move "IMPORT_EXPORT_AUDIT.md" "docs\archive\audit_reports\" 2>nul
move "INTEGRATION_AUDIT.md" "docs\archive\audit_reports\" 2>nul
move "LOG_AUDIT_ISSUES.md" "docs\archive\audit_reports\" 2>nul
move "NOTIFICATION_ROUTING_AUDIT.md" "docs\archive\audit_reports\" 2>nul
move "OFFLINE_AUDIT_SUMMARY.md" "docs\archive\audit_reports\" 2>nul
move "PRODUCTION_READINESS_AUDIT.md" "docs\archive\audit_reports\" 2>nul
move "PRODUCTION_REPORT_AUDIT.md" "docs\archive\audit_reports\" 2>nul
move "PRODUCT_IMAGES_AUDIT.md" "docs\archive\audit_reports\" 2>nul
move "PRODUCT_IMAGES_AUDIT_FINAL.md" "docs\archive\audit_reports\" 2>nul
move "PROJECT_AUDIT_SUMMARY.md" "docs\archive\audit_reports\" 2>nul
move "SALESMAN_PAGES_FINAL_AUDIT.md" "docs\archive\audit_reports\" 2>nul
move "SALESMAN_REPORT_AUDIT.md" "docs\archive\audit_reports\" 2>nul
move "SECURITY_AUDIT_NOTIFICATION_ROUTING.md" "docs\archive\audit_reports\" 2>nul
move "SYNC_AUDIT_REPORT.md" "docs\archive\audit_reports\" 2>nul
move "T1_T17_FINAL_AUDIT_REPORT.md" "docs\archive\audit_reports\" 2>nul
move "T1_T17_IMPLEMENTATION_AUDIT.md" "docs\archive\audit_reports\" 2>nul

echo.
echo ========================================
echo Moving Implementation Reports...
echo ========================================

move "IMPLEMENTATION_COMPLETE.md" "docs\archive\implementation_reports\" 2>nul
move "IMPLEMENTATION_COMPLETE_100_PERCENT.md" "docs\archive\implementation_reports\" 2>nul
move "IMPLEMENTATION_PROGRESS.md" "docs\archive\implementation_reports\" 2>nul
move "IMPLEMENTATION_ROADMAP_100_PERCENT.md" "docs\archive\implementation_reports\" 2>nul
move "IMPLEMENTATION_STATUS.md" "docs\archive\implementation_reports\" 2>nul
move "FINAL_IMPLEMENTATION_SUMMARY.md" "docs\archive\implementation_reports\" 2>nul
move "V2_IMPLEMENTATION_COMPLETE.md" "docs\archive\implementation_reports\" 2>nul
move "V2_IMPLEMENTATION_SUMMARY.md" "docs\archive\implementation_reports\" 2>nul
move "V2_PHASE_SUMMARY.md" "docs\archive\implementation_reports\" 2>nul
move "INTEGRATION_STATUS.md" "docs\archive\implementation_reports\" 2>nul
move "DEPLOYMENT_READINESS_FINAL.md" "docs\archive\implementation_reports\" 2>nul
move "HANDOVER_COMPLETE.md" "docs\archive\implementation_reports\" 2>nul
move "FINAL_CLEAN_STATUS.md" "docs\archive\implementation_reports\" 2>nul
move "FINAL_VALIDATION_REPORT.md" "docs\archive\implementation_reports\" 2>nul
move "TEST_RESULTS_FINAL.md" "docs\archive\implementation_reports\" 2>nul
move "FINAL_PRODUCTION_CLOSURE_EXECUTIVE_SUMMARY.md" "docs\archive\implementation_reports\" 2>nul
move "FINAL_PRODUCTION_CLOSURE_REPORT.md" "docs\archive\implementation_reports\" 2>nul

echo.
echo ========================================
echo Moving Task Reports...
echo ========================================

move "T1_T17_AUDIT_HINDI_SUMMARY.md" "docs\archive\task_reports\" 2>nul
move "T2_FIX_COMPLETE_SUMMARY.md" "docs\archive\task_reports\" 2>nul
move "T2_IMPLEMENTATION_SUMMARY.md" "docs\archive\task_reports\" 2>nul
move "T3_T10_VERIFICATION_REPORT.md" "docs\archive\task_reports\" 2>nul
move "T5_T6_VERIFICATION_SUMMARY.md" "docs\archive\task_reports\" 2>nul
move "T8_T9_T10_QUICK_CHECK.md" "docs\archive\task_reports\" 2>nul
move "T9_P5_CLOSEOUT_REPORT.md" "docs\archive\task_reports\" 2>nul
move "T10_BOM_COMPLETE.md" "docs\archive\task_reports\" 2>nul
move "T10_BOM_IMPLEMENTATION_PLAN.md" "docs\archive\task_reports\" 2>nul
move "T10_CLOSEOUT_REPORT.md" "docs\archive\task_reports\" 2>nul
move "T10_IMPLEMENTATION_PROGRESS.md" "docs\archive\task_reports\" 2>nul
move "T10_WATER_EVAPORATION_HANDLING.md" "docs\archive\task_reports\" 2>nul
move "T11_TASK_SPEC.md" "docs\archive\task_reports\" 2>nul
move "T13_IMPLEMENTATION_SUMMARY.md" "docs\archive\task_reports\" 2>nul
move "T13_T17_IMPLEMENTATION_SUMMARY.md" "docs\archive\task_reports\" 2>nul

echo.
echo ========================================
echo Moving Feature Reports...
echo ========================================

move "BHATTI_COOKING_MOBILE_CRITICAL.md" "docs\archive\feature_reports\" 2>nul
move "BHATTI_COOKING_MOBILE_IMPLEMENTED.md" "docs\archive\feature_reports\" 2>nul
move "BHATTI_ISSUE_MATERIAL_COMPLETE.md" "docs\archive\feature_reports\" 2>nul
move "BHATTI_ISSUE_MATERIAL_FEATURE.md" "docs\archive\feature_reports\" 2>nul
move "BHATTI_ISSUE_MATERIAL_TAB_HIDDEN.md" "docs\archive\feature_reports\" 2>nul
move "BHATTI_MOBILE_IMPROVEMENTS_IMPLEMENTED.md" "docs\archive\feature_reports\" 2>nul
move "BHATTI_SUPERVISOR_DEPARTMENT_FIX.md" "docs\archive\feature_reports\" 2>nul
move "BOTTOM_SAFE_AREA_IMPLEMENTATION.md" "docs\archive\feature_reports\" 2>nul
move "BOTTOM_SAFE_AREA_QUICK_REFERENCE.md" "docs\archive\feature_reports\" 2>nul
move "DASHBOARD_IMPLEMENTATION_SUMMARY.md" "docs\archive\feature_reports\" 2>nul
move "DASHBOARD_QUICK_START.md" "docs\archive\feature_reports\" 2>nul
move "DEALER_DISPATCH_DISCOUNT_FIX_SUMMARY.md" "docs\archive\feature_reports\" 2>nul
move "DISPATCH_CRASH_FIXES.md" "docs\archive\feature_reports\" 2>nul
move "FLUTTER_ANALYZE_FIXES.md" "docs\archive\feature_reports\" 2>nul
move "FLUTTER_ANALYZE_STATUS.md" "docs\archive\feature_reports\" 2>nul
move "GLOBALKEY_ERROR_FIX.md" "docs\archive\feature_reports\" 2>nul
move "HR_IMPROVEMENTS.md" "docs\archive\feature_reports\" 2>nul
move "HR_MODULE_IMPROVEMENTS.md" "docs\archive\feature_reports\" 2>nul
move "IMAGE_LOAD_BUG_FIX.md" "docs\archive\feature_reports\" 2>nul
move "IMAGE_STORAGE_IMPLEMENTATION.md" "docs\archive\feature_reports\" 2>nul
move "LOGOUT_PERMISSION_FIX.md" "docs\archive\feature_reports\" 2>nul
move "MATERIAL_ISSUE_COMPLETE.md" "docs\archive\feature_reports\" 2>nul
move "MATERIAL_ISSUE_IMPROVEMENTS.md" "docs\archive\feature_reports\" 2>nul
move "NOTIFICATION_ROUTING_IMPLEMENTATION.md" "docs\archive\feature_reports\" 2>nul
move "PRODUCT_IMAGES_COMPLETE.md" "docs\archive\feature_reports\" 2>nul
move "PRODUCT_IMAGES_IMPLEMENTATION.md" "docs\archive\feature_reports\" 2>nul
move "PRODUCT_IMAGE_ADD_GUIDE.md" "docs\archive\feature_reports\" 2>nul
move "PRODUCT_IMAGE_ADD_IMPLEMENTATION.md" "docs\archive\feature_reports\" 2>nul
move "SALESMAN_PAGES_FIXES_COMPLETE.md" "docs\archive\feature_reports\" 2>nul
move "SALES_IMPORT_EXPORT_IMPLEMENTATION.md" "docs\archive\feature_reports\" 2>nul
move "SALES_IMPORT_EXPORT_UI_COMPLETE.md" "docs\archive\feature_reports\" 2>nul
move "SECURITY_FIXES_SUMMARY.md" "docs\archive\feature_reports\" 2>nul
move "SECURITY_VALIDATION_COMPLETE.md" "docs\archive\feature_reports\" 2>nul
move "SYNC_FIX_SUMMARY.md" "docs\archive\feature_reports\" 2>nul
move "SYNC_QUEUE_STUCK_SALE_FIX.md" "docs\archive\feature_reports\" 2>nul
move "SYNC_STABILIZATION_COMPLETE.md" "docs\archive\feature_reports\" 2>nul
move "TRANSACTION_RESET_IMPLEMENTATION_PLAN.md" "docs\archive\feature_reports\" 2>nul
move "TRANSACTION_RESET_IMPLEMENTATION_SUMMARY.md" "docs\archive\feature_reports\" 2>nul
move "VEHICLE_MODULE_FIXES.md" "docs\archive\feature_reports\" 2>nul
move "TRANSACTION_RESET_TESTING_CHECKLIST.md" "docs\archive\feature_reports\" 2>nul

echo.
echo ========================================
echo Moving Migration Reports...
echo ========================================

move "MIGRATION_V2-7_REPORT.md" "docs\archive\migration_reports\" 2>nul
move "MIGRATION_V2-7_SUMMARY.md" "docs\archive\migration_reports\" 2>nul
move "MIGRATION_V2-7_VERIFICATION_CHECKLIST.md" "docs\archive\migration_reports\" 2>nul
move "V2_PHASE_AUDIT_REPORT.md" "docs\archive\migration_reports\" 2>nul
move "V2_UPGRADE_AUDIT_REPORT.md" "docs\archive\migration_reports\" 2>nul
move "V2_UPGRADE_CORRECTED_AUDIT.md" "docs\archive\migration_reports\" 2>nul
move "V2_UPGRADE_FINAL_AUDIT.md" "docs\archive\migration_reports\" 2>nul
move "V2_UPGRADE_QUICK_FIX.md" "docs\archive\migration_reports\" 2>nul
move "VERSION_1.0.22_BUILD.md" "docs\archive\migration_reports\" 2>nul

echo.
echo ========================================
echo Moving Development Notes...
echo ========================================

move "7-3-25 implementation plan.md" "docs\archive\dev_notes\" 2>nul
move "7-3-25 task.md" "docs\archive\dev_notes\" 2>nul
move "AGENTS.md" "docs\archive\dev_notes\" 2>nul
move "CLEANUP_REPORT.md" "docs\archive\dev_notes\" 2>nul
move "DASHBOARD_FILE_REFERENCE.md" "docs\archive\dev_notes\" 2>nul
move "DISPLAY_UNIT_CHANGE_GUIDE.md" "docs\archive\dev_notes\" 2>nul
move "FRAMEWORK_ERROR_ANALYSIS.md" "docs\archive\dev_notes\" 2>nul
move "HR_QUICK_REFERENCE.md" "docs\archive\dev_notes\" 2>nul
move "IMAGE_HANDLING_TECHNICAL_REVIEW.md" "docs\archive\dev_notes\" 2>nul
move "INTEGRATIONS.md" "docs\archive\dev_notes\" 2>nul
move "MATERIAL_ISSUE_VISUAL_GUIDE.md" "docs\archive\dev_notes\" 2>nul
move "PRAGMATIC_HANDOVER_STRATEGY.md" "docs\archive\dev_notes\" 2>nul
move "PRODUCTION_DASHBOARD_CARDS.md" "docs\archive\dev_notes\" 2>nul
move "PRODUCTION_STOCK_ANALYSIS.md" "docs\archive\dev_notes\" 2>nul
move "SALESMAN_TARGET_REPORT_IMPLEMENTATION_HINDI.md" "docs\archive\dev_notes\" 2>nul
move "SERVICES_ANALYSIS_COMPLETE.md" "docs\archive\dev_notes\" 2>nul
move "STOCK_FLOW_ANALYSIS.md" "docs\archive\dev_notes\" 2>nul
move "TIMESTAMP_ID_REPLACEMENT_LOG.md" "docs\archive\dev_notes\" 2>nul

echo.
echo ========================================
echo Moving Miscellaneous Files...
echo ========================================

move "DOCUMENTATION_INDEX.md" "docs\archive\misc\" 2>nul
move "COMPLETE_NAVIGATION_MAP.md" "docs\archive\misc\" 2>nul
move "FILE_MANIFEST.md" "docs\archive\misc\" 2>nul
move "QUICK_REFERENCE.md" "docs\archive\misc\" 2>nul
move "CUTTING_MODULE_IMPLEMENTATION.md" "docs\archive\misc\" 2>nul
move "README_CUTTING_MODULE.md" "docs\archive\misc\" 2>nul

echo.
echo ========================================
echo Moving .agent folder...
echo ========================================

if exist ".agent" (
    xcopy /E /I /Y ".agent" "docs\archive\agent_reports" >nul
    rmdir /S /Q ".agent"
    echo .agent folder moved successfully
) else (
    echo .agent folder not found
)

echo.
echo ========================================
echo Creating Archive README...
echo ========================================

(
echo # Documentation Archive
echo.
echo This folder contains historical documentation files that have been superseded by the new structured documentation system.
echo.
echo ## Archive Structure
echo.
echo - **audit_reports/** - Historical audit reports from various iterations
echo - **implementation_reports/** - Progress and status reports
echo - **task_reports/** - Task-specific documentation ^(T1-T17^)
echo - **feature_reports/** - Feature implementation reports
echo - **migration_reports/** - Version migration documentation
echo - **dev_notes/** - Temporary development notes
echo - **agent_reports/** - Agent-generated analysis reports
echo - **misc/** - Miscellaneous superseded files
echo.
echo ## Purpose
echo.
echo These files are preserved for historical reference but are no longer actively maintained.
echo For current documentation, see the main docs/ folder.
echo.
echo **Archived:** March 2026
) > "docs\archive\README.md"

echo.
echo ========================================
echo Cleanup Complete!
echo ========================================
echo.
echo Summary:
echo - Audit reports moved to docs\archive\audit_reports\
echo - Implementation reports moved to docs\archive\implementation_reports\
echo - Task reports moved to docs\archive\task_reports\
echo - Feature reports moved to docs\archive\feature_reports\
echo - Migration reports moved to docs\archive\migration_reports\
echo - Development notes moved to docs\archive\dev_notes\
echo - Agent reports moved to docs\archive\agent_reports\
echo - Miscellaneous files moved to docs\archive\misc\
echo.
echo New documentation structure is in docs/ folder
echo See docs\README.md for the master index
echo.
pause
