; -- DattSoap ERP Windows Installer Script --
; Enhanced for Production: Updates, Version Detection, and Data Safety

#define MyAppName "DattSoap ERP"
#define MyAppVersion "1.0.29"
#define MyAppPublisher "DattSoap"
#define MyAppURL "https://dattsoap.com"
#define MyAppExeName "flutter_app.exe"
; Double braces escape the brace for Inno Setup preprocessor
#define MyAppId "{{D4B3F7A2-1C5E-4D6F-9A8B-C3E2D1A0B9C8}"

[Setup]
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
ArchitecturesInstallIn64BitMode=x64
DisableProgramGroupPage=yes
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupIconFile=..\windows\runner\resources\app_icon.ico
OutputDir=..\installer\output
OutputBaseFilename=DattSoap_ERP_Setup_v{#MyAppVersion}
PrivilegesRequired=admin
CloseApplications=yes
; Prevent "App is already installed" warning, we handle it manually
DisableDirPage=auto

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; Core Executable
Source: "..\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion
; Assets (Static Data) - Safe to overwrite update
Source: "..\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; Documentation
Source: "assets\UserGuide.txt"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall
Filename: "{app}\UserGuide.txt"; Description: "View the User Guide"; Flags: postinstall shellexec unchecked

[Code]
var
  IsUpdate: Boolean;
  InstalledVersion: String;

// Helper to get installed version from Registry
function GetInstalledVersion(): String;
var
  RegKey: String;
  Ver: String;
begin
  Result := '';
  // Check 64-bit Registry first (since we are x64 app)
  RegKey := 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{#MyAppId}_is1';
  if not RegQueryStringValue(HKLM64, RegKey, 'DisplayVersion', Ver) then
  begin
    // Fallback to 32-bit Registry
    if not RegQueryStringValue(HKLM, RegKey, 'DisplayVersion', Ver) then
      // Fallback to User Registry (if installed per-user)
      RegQueryStringValue(HKCU, RegKey, 'DisplayVersion', Ver);
  end;
  Result := Ver;
end;

// Helper to compare versions (Simple String compare for SemVer)
// Returns 1 if V1 > V2, -1 if V1 < V2, 0 if equal
function CompareVersions(V1, V2: String): Integer;
var
  P1, P2, N1, N2: Integer;
  S1, S2: String;
begin
  Result := 0;
  while (Result = 0) and ((V1 <> '') or (V2 <> '')) do
  begin
    P1 := Pos('.', V1);
    if P1 > 0 then
    begin
      S1 := Copy(V1, 1, P1 - 1);
      Delete(V1, 1, P1);
    end
    else
    begin
      S1 := V1;
      V1 := '';
    end;

    P2 := Pos('.', V2);
    if P2 > 0 then
    begin
      S2 := Copy(V2, 1, P2 - 1);
      Delete(V2, 1, P2);
    end
    else
    begin
      S2 := V2;
      V2 := '';
    end;

    if (S1 = '') then N1 := 0 else N1 := StrToIntDef(S1, 0);
    if (S2 = '') then N2 := 0 else N2 := StrToIntDef(S2, 0);

    if N1 > N2 then Result := 1
    else if N1 < N2 then Result := -1;
  end;
end;

function InitializeSetup(): Boolean;
var
  V: String;
  CompareRes: Integer;
begin
  Result := True;
  V := GetInstalledVersion();
  
  if V <> '' then
  begin
    IsUpdate := True;
    CompareRes := CompareVersions('{#MyAppVersion}', V);
    
    // If NewVersion > OldVersion -> Update (Proceed)
    if CompareRes = 1 then
    begin
      // Good to go
    end
    // If NewVersion == OldVersion -> Reinstall or Repair
    else if CompareRes = 0 then
    begin
       if MsgBox('Version ' + V + ' is already installed.' + #13#10 + 
                 'Do you want to reinstall explicitly?', mbConfirmation, MB_YESNO) = IDNO then
       begin
         Result := False;
       end;
    end
    // If NewVersion < OldVersion -> Downgrade (Block)
    else
    begin
       MsgBox('A newer version (' + V + ') is already installed.' + #13#10 +
              'Setup cannot invoke a downgrade to version {#MyAppVersion}.', mbError, MB_OK);
       Result := False;
    end;
  end
  else
  begin
    IsUpdate := False;
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  // Modify UI Text based on Update status
  if IsUpdate then
  begin
    if CurPageID = wpWelcome then
    begin
      WizardForm.WelcomeLabel1.Caption := 'Welcome to the {#MyAppName} Update Wizard';
      WizardForm.WelcomeLabel2.Caption := 'This will update {#MyAppName} on your computer to version {#MyAppVersion}.' + #13#10 + #13#10 + 
                                          'It is recommended that you close all other applications before continuing.';
    end;
    
    if CurPageID = wpReady then
    begin
      WizardForm.ReadyLabel.Caption := 'Setup is now ready to begin updating {#MyAppName} on your computer.';
      // Note: We can't easily change the "Install" button text without hacks, 
      // but changing the label is usually sufficient for context.
    end;
  end;
end;
