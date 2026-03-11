---
name: release-update-offline-mobile
description: Use this skill when preparing Android APK or Windows setup releases for DattSoap. Enforces update-safe signing/version rules, arm64 APK output, and offline-first mobile-first release checks.
---

# DattSoap Release Update Skill

## When to use

- User asks to build/release APK or setup EXE.
- User reports update/install conflict.
- User asks for version bump + release packaging workflow.

## Mandatory rules

- Offline-first and mobile-first behavior must not regress.
- Android package id remains `com.dattsoap.flutter_app`.
- Android release builds must use `android/key.properties` with stable keystore.
- Android release output must be arm64 only.
- Windows setup must be built via `installer/build_and_package.bat`.

## Workflow

1. Bump `pubspec.yaml` version.
2. Build Android release:
   - `flutter build apk --release --target-platform android-arm64 --split-per-abi`
3. Build Windows setup:
   - `cd installer && .\build_and_package.bat`
4. Confirm output paths and file sizes.
5. If Android install conflict appears, verify signing key continuity first.

## References

- `docs/release_update_runbook.md`
- `android/key.properties.example`
