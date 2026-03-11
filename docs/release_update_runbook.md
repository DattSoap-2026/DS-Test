# Release Update Runbook (Android + Windows)

This project is **offline-first** and **mobile-first**.  
All release builds must be update-safe.

## 1) Android APK Update-Safe Rules (Mandatory)

- Package id must stay same: `com.dattsoap.flutter_app`
- Release must be signed with the **same keystore** as previous installed app.
- Never share/update using debug-signed release.
- Build `arm64-v8a` only for mobile release.

### One-time setup

1. Copy `android/key.properties.example` to `android/key.properties`
2. Fill real keystore values:
   - `storeFile`
   - `storePassword`
   - `keyAlias`
   - `keyPassword`

### Build command (64-bit only)

```powershell
flutter build apk --release --target-platform android-arm64 --split-per-abi
```

Output:

`build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

## 2) Android "package conflicts with an existing package" Fix

If install shows:
"App not installed as package conflicts with an existing package"

Main cause is signing mismatch (different keystore).

Fix:

1. Build with same release keystore used in old installed app.
2. Keep `applicationId` unchanged.
3. Increase `version` in `pubspec.yaml` before each release.

If old keystore is lost, update install is impossible. You must uninstall old app and install fresh.

## 3) Windows EXE Setup Update Rules

- Always use `installer/dattsoap_installer.iss` (same `AppId` for upgrades).
- Build script auto-reads version from `pubspec.yaml`.

```powershell
cd installer
.\build_and_package.bat
```

Output:

`installer/output/DattSoap_ERP_Setup_v<version>.exe`

## 4) Release Checklist

1. Bump `pubspec.yaml` version (`x.y.z+build`).
2. Build Android arm64 release APK.
3. Build Windows release setup EXE.
4. Smoke test install/update on one real Android device and one Windows machine.
