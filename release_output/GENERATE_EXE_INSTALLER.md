# Generate Windows EXE Installer

Inno Setup is installed but not found in PATH.

## Manual Steps:

1. Open Inno Setup Compiler GUI
2. File → Open → Browse to:
   `d:\Flutterdattsoap\DattSoap-main\DattSoap-main\flutter_app\installer\installer.iss`
3. Build → Compile
4. Output will be generated at:
   `d:\Flutterdattsoap\DattSoap-main\DattSoap-main\flutter_app\installer\output\DattSoap_ERP_Setup_v1.0.29.exe`

## OR Add ISCC to PATH:

Find iscc.exe location (usually):
- C:\Program Files (x86)\Inno Setup 6\ISCC.exe

Then run:
```
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer\installer.iss
```

## Current Deliverables:

✓ DattSoap_v1.0.29_arm64.apk (46.4 MB) - Android signed APK
✓ DattSoap_v1.0.29_Windows.zip (32.6 MB) - Windows portable package
