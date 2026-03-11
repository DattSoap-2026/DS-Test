# Project Rules (DattSoap)

## Core Product Rules

- Project is **offline-first**.
- Project is **mobile-first**.
- UI changes must be tested for mobile breakpoints first.

## Release Rules (Mandatory)

- Every release must be update-safe (no signature/package conflicts).
- Keep Android package id fixed: `com.dattsoap.flutter_app`.
- For Android release builds, use release keystore from `android/key.properties`.
- Do not ship debug-signed release APK.
- Android mobile artifact: `arm64-v8a` only.

## Standard Release Commands

- Android:
  - `flutter build apk --release --target-platform android-arm64 --split-per-abi`
- Windows setup:
  - `cd installer && .\build_and_package.bat`

## Reference

- See `docs/release_update_runbook.md` for full workflow and conflict troubleshooting.
