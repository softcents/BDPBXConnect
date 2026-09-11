#define MyAppName "BD PBX"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "SoftCents"
#define MyAppExeName "BDPBXConnect.exe"

[Setup]
AppId={{7B4B2A3C-0F6D-4D70-A8A5-123456789001}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=..\installer-output
OutputBaseFilename=BDPBX-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
Uninstallable=yes
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\BDPBXConnect.exe
SetupIconFile=..\res\bdpbx.ico
ArchitecturesInstallIn64BitMode=x64compatible

[Files]
Source: "..\output\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
