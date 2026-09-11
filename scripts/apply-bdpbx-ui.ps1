Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Set-Location $env:GITHUB_WORKSPACE

# Build the supplied BD PBX logo into the ICO used by the app and installer.
$logoB64 = Join-Path $env:GITHUB_WORKSPACE 'res\bdpbx-logo.png.b64'
$logoPng = Join-Path $env:GITHUB_WORKSPACE 'res\bdpbx-logo.png'
$logoIco = Join-Path $env:GITHUB_WORKSPACE 'res\bdpbx.ico'
if (-not (Test-Path $logoB64)) { throw 'BD PBX logo asset was not found' }
$pngBytes = [Convert]::FromBase64String((Get-Content -Raw -Path $logoB64).Trim())
[System.IO.File]::WriteAllBytes($logoPng, $pngBytes)

$icoHeader = [byte[]](0,0,1,0,1,0)
$entry = New-Object byte[] 16
$entry[0] = 64
$entry[1] = 64
$entry[4] = 1
$entry[6] = 32
[BitConverter]::GetBytes([uint32]$pngBytes.Length).CopyTo($entry, 8)
[BitConverter]::GetBytes([uint32]22).CopyTo($entry, 12)
$ico = New-Object byte[] ($icoHeader.Length + $entry.Length + $pngBytes.Length)
[Array]::Copy($icoHeader, 0, $ico, 0, $icoHeader.Length)
[Array]::Copy($entry, 0, $ico, $icoHeader.Length, $entry.Length)
[Array]::Copy($pngBytes, 0, $ico, 22, $pngBytes.Length)
[System.IO.File]::WriteAllBytes($logoIco, $ico)
if (-not (Test-Path $logoIco)) { throw 'BD PBX ICO was not created' }
Write-Host "BD PBX logo ready: $logoIco"

$dialogPath = Join-Path $env:GITHUB_WORKSPACE 'res\dialog.rc2'
$dialog = Get-Content -Raw -Path $dialogPath
$marker = '//-----------------------------ACCOUNT------------------------------------------'
$start = $dialog.IndexOf($marker)
$next = $dialog.IndexOf('//-----------------------------------------------------------------------', $start + $marker.Length)
if ($start -lt 0 -or $next -lt 0) { throw 'BD PBX account dialog section was not found' }
$end = $dialog.IndexOf('//-----------------------------------------------------------------------', $next + 1)
if ($end -lt 0) { throw 'BD PBX account dialog end marker was not found' }

# Compact account dialog: keep all important fields, but make the window fit normal 768px-height screens.
$accountSection = @'
//-----------------------------ACCOUNT------------------------------------------
#define IDD_ACCOUNT_OFF_FINAL 300

IDD_ACCOUNT DIALOGEX 0, 0, 320, IDD_ACCOUNT_OFF_FINAL
STYLE DS_SETFONT | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | WS_POPUP | WS_VISIBLE
CAPTION "BD PBX - Add Account"
FONT 8, "Microsoft Sans Serif", 400, 0, 0x1
BEGIN
RTEXT           "Account Name", IDC_STATIC, 8, 10, 78, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_ACCOUNT_LABEL, 90, 7, 92, 16, ES_AUTOHSCROLL
RTEXT           "Domain (Subdomain) *", IDC_STATIC, 8, 34, 78, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_EDIT_DOMAIN, 90, 31, 72, 16, ES_AUTOHSCROLL
LTEXT           ".bdpbx.com", IDC_STATIC, 165, 35, 45, 8
RTEXT           "Username *", IDC_STATIC, 8, 58, 78, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_EDIT_USERNAME, 90, 55, 92, 16, ES_AUTOHSCROLL
RTEXT           "Password *", IDC_STATIC, 8, 82, 78, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_EDIT_PASSWORD, 90, 79, 92, 16, ES_AUTOHSCROLL | ES_PASSWORD
CONTROL         "", IDC_SYSLINK_DISPLAY_PASSWORD, "SysLink", WS_TABSTOP, 185, 82, 12, 8
RTEXT           "Display Name", IDC_STATIC, 8, 106, 78, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_EDIT_DISPLAYNAME, 90, 103, 92, 16, ES_AUTOHSCROLL
RTEXT           "Voicemail", IDC_STATIC, 8, 130, 78, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_EDIT_VOICEMAIL, 90, 127, 92, 16, ES_AUTOHSCROLL
RTEXT           "Dialing Prefix", IDC_STATIC, 8, 154, 78, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_ACCOUNT_DIALING_PREFIX, 90, 151, 92, 16, ES_AUTOHSCROLL
RTEXT           "Dial Plan", IDC_STATIC, 8, 178, 78, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_ACCOUNT_DIAL_PLAN, 90, 175, 92, 16, ES_AUTOHSCROLL

GROUPBOX        "Automatic Configuration", IDC_ACCOUNT_WELCOME2, 190, 7, 122, 118
LTEXT           "Enter only subdomain", IDC_STATIC, 198, 25, 105, 10
LTEXT           "Example: company1", IDC_STATIC, 198, 40, 105, 10
LTEXT           "SIP Server", IDC_STATIC, 198, 58, 48, 10
LTEXT           "company1.bdpbx.com", IDC_STATIC, 246, 58, 60, 10
LTEXT           "SIP Proxy", IDC_STATIC, 198, 75, 48, 10
LTEXT           "company1.bdpbx.com", IDC_STATIC, 246, 75, 60, 10
LTEXT           "Domain", IDC_STATIC, 198, 92, 48, 10
LTEXT           "company1.bdpbx.com", IDC_STATIC, 246, 92, 60, 10

CONTROL         "Hide Caller ID", IDC_ACCOUNT_HIDE_CID, "Button", BS_AUTOCHECKBOX | WS_TABSTOP, 198, 135, 105, 12
CONTROL         "Publish Presence", IDC_PUBLISH, "Button", BS_AUTOCHECKBOX | WS_TABSTOP, 198, 153, 105, 12
CONTROL         "Allow IP Rewrite", IDC_REWRITE, "Button", BS_AUTOCHECKBOX | WS_TABSTOP, 198, 171, 105, 12
CONTROL         "ICE", IDC_ICE, "Button", BS_AUTOCHECKBOX | WS_TABSTOP, 198, 189, 105, 12
CONTROL         "Disable Session Timers", IDC_SESSION_TIMER, "Button", BS_AUTOCHECKBOX | WS_TABSTOP, 198, 207, 105, 12

RTEXT           "Media Encryption", IDC_STATIC, 8, 208, 78, 8, SS_WORDELLIPSIS
COMBOBOX        IDC_SRTP, 90, 205, 92, 30, CBS_DROPDOWNLIST | WS_VSCROLL | WS_TABSTOP
RTEXT           "Transport", IDC_STATIC, 8, 236, 78, 8, SS_WORDELLIPSIS
COMBOBOX        IDC_TRANSPORT, 90, 233, 92, 30, CBS_DROPDOWNLIST | WS_VSCROLL | WS_TABSTOP
RTEXT           "Public Address", IDC_STATIC, 8, 264, 78, 8, SS_WORDELLIPSIS
COMBOBOX        IDC_PUBLIC_ADDR, 90, 261, 92, 30, CBS_DROPDOWN | WS_VSCROLL | WS_TABSTOP

CONTROL         "", IDC_SYSLINK_ACCOUNT_DELETE, "SysLink", 0x0, 8, 285, 70, 8, NOT WS_VISIBLE
DEFPUSHBUTTON   "Save", IDOK, 190, 272, 58, 18
PUSHBUTTON      "Cancel", IDCANCEL, 254, 272, 58, 18
END
//-----------------------------------------------------------------------
'@

$dialog = $dialog.Substring(0, $start) + $accountSection + $dialog.Substring($end)
Set-Content -Path $dialogPath -Value $dialog -Encoding utf8

$cppPath = Join-Path $env:GITHUB_WORKSPACE 'AccountDlg.cpp'
$cpp = Get-Content -Raw -Path $cppPath

$initReplacement = @"
CDialog::OnInitDialog();

`tSetWindowText(_T("BD PBX - Add Account"));
"@
if ($cpp -notmatch 'SetWindowText\(_T\("BD PBX - Add Account"\)\)') {
    $cpp = $cpp.Replace('CDialog::OnInitDialog();', $initReplacement.TrimEnd())
}

$cpp = [regex]::Replace($cpp, '(?s)\tGetDlgItem\(IDC_ACCOUNT_REQUIRED_USERNAME\)->ShowWindow\(show\);\r?\n\tGetDlgItem\(IDC_ACCOUNT_REQUIRED_DOMAIN\)->ShowWindow\(show\);\r?\n\tGetDlgItem\(IDC_EDIT_SERVER\)->EnableWindow\(id\);', '', 1)

$oldLoadPattern = '(?s)\tedit = \(CEdit\*\)GetDlgItem\(IDC_ACCOUNT_LABEL\);.*?\tedit->SetWindowText\(m_Account\.username\);\r?\n'
$newLoad = @'
	edit = (CEdit*)GetDlgItem(IDC_ACCOUNT_LABEL);
	if (m_Account.label.IsEmpty()) {
		m_Account.label = _T("Account 1");
	}
	edit->SetWindowText(m_Account.label);

	edit = (CEdit*)GetDlgItem(IDC_EDIT_DOMAIN);
	CString tenantDomain = m_Account.domain;
	CString tenantSuffix = _T(".bdpbx.com");
	if (tenantDomain.Right(tenantSuffix.GetLength()).CompareNoCase(tenantSuffix) == 0) {
		tenantDomain = tenantDomain.Left(tenantDomain.GetLength() - tenantSuffix.GetLength());
	}
	edit->SetWindowText(tenantDomain);

	edit = (CEdit*)GetDlgItem(IDC_EDIT_USERNAME);
	edit->SetWindowText(m_Account.username);
'@
if ($cpp -match $oldLoadPattern) { $cpp = [regex]::Replace($cpp, $oldLoadPattern, $newLoad, 1) }
else { throw 'AccountDlg Load block not found' }

$oldSavePattern = '(?s)\tedit = \(CEdit\*\)GetDlgItem\(IDC_EDIT_SERVER\);.*?\tm_Account\.username=str\.Trim\(\);\r?\n'
$newSave = @'
	edit = (CEdit*)GetDlgItem(IDC_EDIT_DOMAIN);
	edit->GetWindowText(str);
	str = str.Trim();
	str.Trim(_T('.'));
	CString tenantSuffix = _T(".bdpbx.com");
	if (str.Right(tenantSuffix.GetLength()).CompareNoCase(tenantSuffix) == 0) {
		str = str.Left(str.GetLength() - tenantSuffix.GetLength());
		str.Trim(_T('.'));
	}
	if (str.IsEmpty()) {
		AfxMessageBox(_T("Please enter your BD PBX subdomain."));
		GetDlgItem(IDC_EDIT_DOMAIN)->SetFocus();
		return;
	}
	m_Account.domain = str + tenantSuffix;

	edit = (CEdit*)GetDlgItem(IDC_EDIT_USERNAME);
	edit->GetWindowText(str);
	m_Account.username=str.Trim();
	if (m_Account.username.IsEmpty()) {
		AfxMessageBox(_T("Please enter your SIP username."));
		GetDlgItem(IDC_EDIT_USERNAME)->SetFocus();
		return;
	}
	m_Account.authID=m_Account.username;
	m_Account.server=m_Account.domain;
	m_Account.proxy=m_Account.domain;
'@
if ($cpp -match $oldSavePattern) { $cpp = [regex]::Replace($cpp, $oldSavePattern, $newSave, 1) }
else { throw 'AccountDlg save block not found' }

$cpp = $cpp.Replace("`tedt = (CEdit*)", "`tedit = (CEdit*)")
Set-Content -Path $cppPath -Value $cpp -Encoding utf8
Write-Host 'BD PBX account dialog resized to a compact, screen-safe layout.'
