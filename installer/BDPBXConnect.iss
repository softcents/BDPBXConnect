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
; Seamless update: don't ask about an existing install directory.
DirExistsWarning=no
; Automatically close BD PBX when files are in use during an update.
CloseApplications=force
; Do not restart the old instance; [Run] starts the newly installed version.
RestartApplications=no

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
; Remove the installed program directory.
Type: filesandordirs; Name: "{app}"
; Remove all BD PBX configuration, accounts, contacts and cached local data.
Type: filesandordirs; Name: "{userappdata}\BD PBX"
Type: filesandordirs; Name: "{localappdata}\BD PBX"
; Remove legacy/config folders created by previous builds using the executable name.
Type: filesandordirs; Name: "{userappdata}\BDPBXConnect"
Type: filesandordirs; Name: "{localappdata}\BDPBXConnect"
