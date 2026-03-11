@echo off
REM Accountant Audit System - Deployment Script (Windows)
REM This script deploys the Firestore rules for Accountant audit system

echo ==========================================
echo   Accountant Audit System Deployment
echo ==========================================
echo.

REM Check if firebase CLI is installed
where firebase >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo X Firebase CLI not found!
    echo    Install: npm install -g firebase-tools
    pause
    exit /b 1
)

echo [OK] Firebase CLI found
echo.

REM Check if logged in
echo Checking Firebase authentication...
firebase projects:list >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo X Not logged in to Firebase
    echo    Run: firebase login
    pause
    exit /b 1
)

echo [OK] Firebase authentication verified
echo.

REM Show current project
echo Current Firebase project:
firebase use
echo.

REM Confirm deployment
set /p CONFIRM="Deploy Firestore rules? (y/n): "
if /i not "%CONFIRM%"=="y" (
    echo X Deployment cancelled
    pause
    exit /b 1
)

echo.
echo Deploying Firestore rules...
echo.

REM Deploy rules
firebase deploy --only firestore:rules

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==========================================
    echo   [OK] Deployment Successful!
    echo ==========================================
    echo.
    echo [WAIT] Wait 30-60 seconds for rules to propagate
    echo.
    echo [NEXT] Next Steps:
    echo    1. Wait 60 seconds
    echo    2. Login as Accountant (account@dattsoap.com^)
    echo    3. Try creating a voucher
    echo    4. Verify no permission errors
    echo    5. Login as Admin
    echo    6. Check Audit Log screen
    echo.
    echo [DOCS] Documentation:
    echo    - ACCOUNTANT_AUDIT_COMPLETE.md
    echo    - ACCOUNTANT_AUDIT_QUICK_REF.md
    echo    - ACCOUNTANT_AUDIT_FLOW.md
    echo.
) else (
    echo.
    echo ==========================================
    echo   X Deployment Failed!
    echo ==========================================
    echo.
    echo Troubleshooting:
    echo    1. Check Firebase project is correct
    echo    2. Verify firestore.rules file exists
    echo    3. Check Firebase permissions
    echo    4. Review error messages above
    echo.
    pause
    exit /b 1
)

pause
