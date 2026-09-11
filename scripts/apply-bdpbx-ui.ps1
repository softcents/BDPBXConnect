Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Set-Location $env:GITHUB_WORKSPACE

$dialogPath = Join-Path $env:GITHUB_WORKSPACE 'res\dialog.rc2'
$dialog = Get-Content -Raw -Path $dialogPath
$marker = '//-----------------------------ACCOUNT------------------------------------------'
$start = $dialog.IndexOf($marker)
$next = $dialog.IndexOf('//-----------------------------------------------------------------------', $start + $marker.Length)
if ($start -lt 0 -or $next -lt 0) { throw 'BD PBX account dialog section was not found' }
$end = $dialog.IndexOf('//-----------------------------------------------------------------------', $next + 1)
if ($end -lt 0) { throw 'BD PBX account dialog end marker was not found' }

$accountSection = @'
//-----------------------------ACCOUNT------------------------------------------
#define IDD_ACCOUNT_OFF_FINAL 400

IDD_ACCOUNT DIALOGEX 0, 0, 360, IDD_ACCOUNT_OFF_FINAL
STYLE DS_SETFONT | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | WS_POPUP | WS_VISIBLE
CAPTION "BD PBX - Add Account"
FONT 8, "Microsoft Sans Serif", 400, 0, 0x1
BEGIN
RTEXT           "Account Name", IDC_STATIC, 10, 12, 90, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_ACCOUNT_LABEL, 105, 9, 105, 16, ES_AUTOHSCROLL
RTEXT           "Domain (Subdomain) *", IDC_STATIC, 10, 39, 90, 18, SS_WORDELLIPSIS
EDITTEXT        IDC_EDIT_DOMAIN, 105, 36, 105, 16, ES_AUTOHSCROLL
LTEXT           ".bdpbx.com", IDC_STATIC, 214, 40, 58, 8
LTEXT           "Full domain: company1.bdpbx.com", IDC_STATIC, 105, 56, 165, 10
GROUPBOX        "Automatic Configuration", IDC_ACCOUNT_WELCOME2, 225, 8, 125, 145
LTEXT           "Enter only your subdomain.", IDC_STATIC, 234, 27, 108, 15
LTEXT           "Example: company1", IDC_STATIC, 234, 48, 108, 10
LTEXT           "SIP Server -> company1.bdpbx.com", IDC_STATIC, 234, 68, 108, 25
LTEXT           "SIP Proxy -> company1.bdpbx.com", IDC_STATIC, 234, 96, 108, 25
LTEXT           "Domain -> company1.bdpbx.com", IDC_STATIC, 234, 124, 108, 18
RTEXT           "Username *", IDC_STATIC, 10, 86, 90, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_EDIT_USERNAME, 105, 83, 105, 16, ES_AUTOHSCROLL
LTEXT           "(used as Username and Login)", IDC_STATIC, 105, 101, 110, 18
RTEXT           "Password *", IDC_STATIC, 10, 124, 90, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_EDIT_PASSWORD, 105, 121, 105, 16, ES_AUTOHSCROLL | ES_PASSWORD
CONTROL         "", IDC_SYSLINK_DISPLAY_PASSWORD, "SysLink", WS_TABSTOP, 105, 140, 105, 8
RTEXT           "Display Name", IDC_STATIC, 10, 164, 90, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_EDIT_DISPLAYNAME, 105, 161, 105, 16, ES_AUTOHSCROLL
RTEXT           "Voicemail Number", IDC_STATIC, 10, 187, 90, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_EDIT_VOICEMAIL, 105, 184, 105, 16, ES_AUTOHSCROLL
RTEXT           "Dialing Prefix", IDC_STATIC, 10, 210, 90, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_ACCOUNT_DIALING_PREFIX, 105, 207, 105, 16, ES_AUTOHSCROLL
RTEXT           "Dial Plan", IDC_STATIC, 10, 233, 90, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_ACCOUNT_DIAL_PLAN, 105, 230, 105, 16, ES_AUTOHSCROLL
CONTROL         "Hide Caller ID", IDC_ACCOUNT_HIDE_CID, "Button", BS_AUTOCHECKBOX | WS_TABSTOP, 105, 252, 105, 12
RTEXT           "Media Encryption", IDC_STATIC, 10, 277, 90, 8, SS_WORDELLIPSIS
COMBOBOX        IDC_SRTP, 105, 274, 105, 30, CBS_DROPDOWNLIST | WS_VSCROLL | WS_TABSTOP
RTEXT           "Transport", IDC_STATIC, 10, 311, 90, 8, SS_WORDELLIPSIS
COMBOBOX        IDC_TRANSPORT, 105, 308, 105, 30, CBS_DROPDOWNLIST | WS_VSCROLL | WS_TABSTOP
RTEXT           "Public Address", IDC_STATIC, 10, 345, 90, 8, SS_WORDELLIPSIS
COMBOBOX        IDC_PUBLIC_ADDR, 105, 342, 105, 30, CBS_DROPDOWN | WS_VSCROLL | WS_TABSTOP
RTEXT           "Register Refresh", IDC_STATIC, 10, 379, 90, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_ACCOUNT_REGISTER_REFRESH, 105, 376, 45, 16, ES_AUTOHSCROLL
RTEXT           "Keep-Alive", IDC_STATIC, 155, 379, 55, 8, SS_WORDELLIPSIS
EDITTEXT        IDC_ACCOUNT_KEEP_ALIVE, 212, 376, 35, 16, ES_AUTOHSCROLL
CONTROL         "Publish Presence", IDC_PUBLISH, "Button", BS_AUTOCHECKBOX | WS_TABSTOP, 250, 175, 100, 12
CONTROL         "Allow IP Rewrite", IDC_REWRITE, "Button", BS_AUTOCHECKBOX | WS_TABSTOP, 250, 198, 100, 12
CONTROL         "ICE", IDC_ICE, "Button", BS_AUTOCHECKBOX | WS_TABSTOP, 250, 221, 100, 12
CONTROL         "Disable Session Timers", IDC_SESSION_TIMER, "Button", BS_AUTOCHECKBOX | WS_TABSTOP, 250, 244, 100, 12
CONTROL         "", IDC_SYSLINK_ACCOUNT_DELETE, "SysLink", 0x0, 10, 342, 75, 8, NOT WS_VISIBLE
DEFPUSHBUTTON   "Save", IDOK, 110, 365, 80, 18
PUSHBUTTON      "Cancel", IDCANCEL, 195, 365, 80, 18
END
//-----------------------------------------------------------------------
'@

# Move the final controls upward so Save/Cancel are always visible.
$accountSection = $accountSection.Replace('RTEXT           "Public Address", IDC_STATIC, 10, 345, 90, 8, SS_WORDELLIPSIS', 'RTEXT           "Public Address", IDC_STATIC, 10, 300, 90, 8, SS_WORDELLIPSIS')
$accountSection = $accountSection.Replace('COMBOBOX        IDC_PUBLIC_ADDR, 105, 342, 105, 30', 'COMBOBOX        IDC_PUBLIC_ADDR, 105, 297, 105, 30')
$accountSection = $accountSection.Replace('RTEXT           "Register Refresh", IDC_STATIC, 10, 379, 90, 8, SS_WORDELLIPSIS', 'RTEXT           "Register Refresh", IDC_STATIC, 10, 334, 90, 8, SS_WORDELLIPSIS')
$accountSection = $accountSection.Replace('EDITTEXT        IDC_ACCOUNT_REGISTER_REFRESH, 105, 376, 45, 16', 'EDITTEXT        IDC_ACCOUNT_REGISTER_REFRESH, 105, 331, 45, 16')
$accountSection = $accountSection.Replace('RTEXT           "Keep-Alive", IDC_STATIC, 155, 379, 55, 8, SS_WORDELLIPSIS', 'RTEXT           "Keep-Alive", IDC_STATIC, 155, 334, 55, 8, SS_WORDELLIPSIS')
$accountSection = $accountSection.Replace('EDITTEXT        IDC_ACCOUNT_KEEP_ALIVE, 212, 376, 35, 16', 'EDITTEXT        IDC_ACCOUNT_KEEP_ALIVE, 212, 331, 35, 16')
$accountSection = $accountSection.Replace('CONTROL         "", IDC_SYSLINK_ACCOUNT_DELETE, "SysLink", 0x0, 10, 342, 75, 8, NOT WS_VISIBLE', 'CONTROL         "", IDC_SYSLINK_ACCOUNT_DELETE, "SysLink", 0x0, 10, 345, 75, 8, NOT WS_VISIBLE')
$accountSection = $accountSection.Replace('DEFPUSHBUTTON   "Save", IDOK, 110, 365, 80, 18', 'DEFPUSHBUTTON   "Save", IDOK, 110, 365, 80, 18')
$accountSection = $accountSection.Replace('PUSHBUTTON      "Cancel", IDCANCEL, 195, 365, 80, 18', 'PUSHBUTTON      "Cancel", IDCANCEL, 195, 365, 80, 18')

$dialog = $dialog.Substring(0, $start) + $accountSection + $dialog.Substring($end)
Set-Content -Path $dialogPath -Value $dialog -Encoding utf8

$cppPath = Join-Path $env:GITHUB_WORKSPACE 'AccountDlg.cpp'
$cpp = Get-Content -Raw -Path $cppPath

if ($cpp -notmatch 'SetWindowText\(_T\("BD PBX - Add Account"\)\)') {
    $cpp = [regex]::Replace($cpp, 'CDialog::OnInitDialog\(\);', "CDialog::OnInitDialog();`r`n`r`n`tSetWindowText(_T(\"BD PBX - Add Account\"));", 1)
}

$oldLoadPattern = '(?s)\tedit = \(CEdit\*\)GetDlgItem\(IDC_ACCOUNT_LABEL\);.*?\tedit->SetWindowText\(m_Account\.username\);\r?\n'
$newLoad = @'
	edt = (CEdit*)GetDlgItem(IDC_ACCOUNT_LABEL);
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

Set-Content -Path $cppPath -Value $cpp -Encoding utf8
Write-Host 'BD PBX account dialog layout and Save handling applied successfully.'
