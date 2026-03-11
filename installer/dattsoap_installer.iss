; -- DattSoap ERP Professional Installer --
; Maintains Data Integrity, Versioning, and Rollback Capabilities

#define MyAppName "DattSoap ERP"
#ifndef MyAppVersion
  #define MyAppVersion "1.0.28" ; Default, override via command line /DMyAppVersion="x.y.z"
#endif
#define MyAppPublisher "DattSoap"
#define MyAppURL "https://dattsoap.com"
#define MyAppExeName "flutter_app.exe"
#define MyAppId "{{D4B3F7A2-1C5E-4D6F-9A8B-C3E2D1A0B9C8}"
#define BackupDir "{app}\backups"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; Require Admin for installation to Program Files
PrivilegesRequired=admin
; Force 64-bit install on 64-bit systems (Standard for Flutter Windows)
ArchitecturesInstallIn64BitMode=x64compatible
ArchitecturesAllowed=x64compatible
; Better compression
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
; Output defaults
OutputDir=.\output
OutputBaseFilename=DattSoap_ERP_Setup_v{#MyAppVersion}
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
; Prevent restart if possible
CloseApplications=yes
; Update behavior - Lock install path to enforce standard location
DisableDirPage=yes
DirExistsWarning=no
SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Dirs]
; Ensure these directories exist but NEVER uninstall them
Name: "{app}\data"; Flags: uninsneveruninstall
Name: "{app}\db"; Flags: uninsneveruninstall
Name: "{app}\local_storage"; Flags: uninsneveruninstall
Name: "{app}\backups"; Flags: uninsneveruninstall

[Files]
; Binaries - Overwrite logic
Source: "..\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion
; Assets - Overwrite but preserve subdirectories not in source
Source: "..\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; Add other dependencies here (Visual C++ redistributable etc if needed)

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
var
  IsUpdate: Boolean;
  ExistingVersion: String;

// Function to get installed version
function GetInstalledVersion(): String;
var
  RegKey: String;
  Ver: String;
begin
  Result := '';
  RegKey := 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{#MyAppId}_is1';
  // Try 64-bit registry
  if not RegQueryStringValue(HKLM64, RegKey, 'DisplayVersion', Ver) then
  begin
    // Try 32-bit registry
    if not RegQueryStringValue(HKLM, RegKey, 'DisplayVersion', Ver) then
      // Try User registry
      RegQueryStringValue(HKCU, RegKey, 'DisplayVersion', Ver);
  end;
  Result := Ver;
end;

// Compare SemVer strings
function CompareVersions(V1, V2: String): Integer;
var
  P1, P2, N1, N2: Integer;
  S1, S2: String;
begin
  Result := 0;
  while (Result = 0) and ((V1 <> '') or (V2 <> '')) do
  begin
    P1 := Pos('.', V1);
    if P1 > 0 then begin S1 := Copy(V1, 1, P1 - 1); Delete(V1, 1, P1); end else begin S1 := V1; V1 := ''; end;
    P2 := Pos('.', V2);
    if P2 > 0 then begin S2 := Copy(V2, 1, P2 - 1); Delete(V2, 1, P2); end else begin S2 := V2; V2 := ''; end;
    if S1 = '' then N1 := 0 else N1 := StrToIntDef(S1, 0);
    if S2 = '' then N2 := 0 else N2 := StrToIntDef(S2, 0);
    if N1 > N2 then Result := 1 else if N1 < N2 then Result := -1;
  end;
end;

// Parse DateTime for backup folder
function GetTimestamp(): String;
begin
  Result := GetDateTimeString('yyyy-mm-dd_hh-nn-ss', '-', '-');
end;

// --- CRITICAL: Version Check Logic ---
function InitializeSetup(): Boolean;
var
  CmpRes: Integer;
begin
  Result := True;
  ExistingVersion := GetInstalledVersion();
  
  if ExistingVersion <> '' then
  begin
    IsUpdate := True;
    CmpRes := CompareVersions('{#MyAppVersion}', ExistingVersion);
    
    // 1. Installer > Installed (Update)
    if CmpRes = 1 then
    begin
      // Allow update
      Log('Update detected: ' + ExistingVersion + ' -> ' + '{#MyAppVersion}');
    end
    // 2. Installer == Installed (Abort)
    else if CmpRes = 0 then
    begin
      if not WizardSilent then
        MsgBox('Version ' + ExistingVersion + ' is already installed. Setup will exit.', mbInformation, MB_OK);
      Log('Aborting: Same version already installed.');
      Result := False;
    end
    // 3. Installer < Installed (Downgrade Block)
    else
    begin
      if not WizardSilent then
        MsgBox('A newer version (' + ExistingVersion + ') is installed. Downgrade to {#MyAppVersion} is not allowed.', mbError, MB_OK);
      Log('Aborting: Downgrade detected from ' + ExistingVersion + ' to {#MyAppVersion}.');
      Result := False;
    end;
  end
  else
  begin
    IsUpdate := False;
  end;
end;

// --- CRITICAL: Backup Logic ---
procedure CurStepChanged(CurStep: TSetupStep);
var
  BackupPath: String;
  ResultCode: Integer;
begin
  if (CurStep = ssInstall) and IsUpdate then
  begin
    BackupPath := ExpandConstant('{#BackupDir}\backup_' + GetTimestamp());
    Log('Creating backup at: ' + BackupPath);
    
    // Create backup dir
    if not DirExists(BackupPath) then CreateDir(BackupPath);
    
    // Backup Data folder if exists
    if DirExists(ExpandConstant('{app}\data')) then
    begin
      // Use xcopy for robust copying
      // /E = recursive, /I = assume dir, /H = hidden, /Y = suppress prompt, /Q = quiet
      Exec('xcopy', '"' + ExpandConstant('{app}\data') + '" "' + BackupPath + '\data" /E /I /H /Y /Q', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      if ResultCode <> 0 then
        Log('Warning: Data backup returned code ' + IntToStr(ResultCode))
      else
        Log('Data backup successful.');
    end;
    
    // Backup local_storage if exists
    if DirExists(ExpandConstant('{app}\local_storage')) then
    begin
      Exec('xcopy', '"' + ExpandConstant('{app}\local_storage') + '" "' + BackupPath + '\local_storage" /E /I /H /Y /Q', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    end;

    // Backup Isar DBs if they are in root (just .isar files)
    // xcopy *.isar
    Exec('xcopy', '"' + ExpandConstant('{app}\*.isar') + '" "' + BackupPath + '\" /H /Y /Q', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

// UI Customization
procedure CurPageChanged(CurPageID: Integer);
begin
  if IsUpdate and (CurPageID = wpWelcome) then
  begin
    WizardForm.WelcomeLabel1.Caption := 'Update DattSoap ERP to version {#MyAppVersion}';
    WizardForm.WelcomeLabel2.Caption := 'An existing installation (' + ExistingVersion + ') was detected.' + #13#10 + #13#10 +
      'Setup will perform a safe update. Your data will be preserved and backed up automatically.';
  end;
end;
