# How to Build the DattSoap ERP Installer

## Prerequisites
1. **Inno Setup**: Download and install [Inno Setup](https://jrsoftware.org/isdl.php).
2. **Flutter**: Ensure you have a working Flutter environment.

## Recommended (Update-Safe) Method
Use the automated script. It reads version from `pubspec.yaml`, builds Windows release, and compiles installer using `dattsoap_installer.iss`.

```powershell
cd installer
.\build_and_package.bat
```

## Manual Method (Only if needed)
1. Build app:
   ```powershell
   flutter build windows --release
   ```
2. Compile `flutter_app\installer\dattsoap_installer.iss` in Inno Setup.

## Output
The installer executable (`DattSoap_ERP_Setup_v<version>.exe`) will be generated in:
`flutter_app\installer\output\`

## Testing
- Run the generated setup exe.
- Follow the installation wizard.
- Verify the app launches correctly from the Desktop shortcut.
- Verify the Uninstaller works via "Add or Remove Programs".
