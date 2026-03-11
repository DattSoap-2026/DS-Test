@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

echo ===================================================
echo     DattSoap ERP - Build ^& Installer Generator
echo ===================================================

:: 1. Check for Inno Setup Compiler
set "ISCC_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if not exist "%ISCC_PATH%" (
    echo [ERROR] Inno Setup 6 not found at: "%ISCC_PATH%"
    echo Please install Inno Setup 6 from https://jrsoftware.org/isdl.php
    pause
    exit /b 1
)

:: 2. Extract Version from pubspec.yaml
echo [INFO] Reading version from pubspec.yaml...
set "PUBSPEC=..\pubspec.yaml"
if not exist "%PUBSPEC%" (
    echo [ERROR] pubspec.yaml not found at: %PUBSPEC%
    pause
    exit /b 1
)

for /f "tokens=2 delims=:" %%a in ('findstr /R "^version:" "%PUBSPEC%"') do set "RAW_VER=%%a"
set "RAW_VER=!RAW_VER: =!"
for /f "tokens=1 delims=+" %%b in ("!RAW_VER!") do set "APP_VERSION=%%b"

echo [INFO] Detected Version: %APP_VERSION%
echo.

:: 3. Build Flutter App (Release Mode)
echo [INFO] Switching to Project Root to build...
pushd ..
echo [CURRENT DIR] %CD%

echo [INFO] Closing running app instances to prevent file locks...
taskkill /F /IM flutter_app.exe /T >nul 2>&1

if exist "build\windows" (
    echo [INFO] Cleaning previous Windows build cache...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$path='build\\windows';" ^
        "for($i=0;$i -lt 6;$i++){" ^
        "  try { Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop; exit 0 }" ^
        "  catch { Start-Sleep -Milliseconds 700 }" ^
        "}" ^
        "exit 1"
    if exist "build\windows" (
        echo [WARN] Could not fully remove build\windows. Continuing with incremental build.
    ) else (
        echo [INFO] Previous Windows build cache removed.
    )
)

echo [INFO] Fetching dependencies...
call flutter pub get

echo [INFO] Building Windows Release (v%APP_VERSION%)...
call flutter build windows --release --no-pub
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter build failed!
    popd
    pause
    exit /b 1
)
popd
echo [SUCCESS] Build completed.
echo.

:: 4. Compile Installer
echo [INFO] Compiling Installer...
"%ISCC_PATH%" /DMyAppVersion="%APP_VERSION%" "dattsoap_installer.iss"

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Installer compilation failed!
    pause
    exit /b 1
)

echo.
echo ===================================================
echo [SUCCESS] Installer Generated Successfully!
echo Location: installer\Output\DattSoap_ERP_Setup_v%APP_VERSION%.exe
echo ===================================================
