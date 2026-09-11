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

# Compact BD PBX account dialog. Only controls that exist in this resource are
# used by AccountDlg.cpp; the old server/proxy/auth/register controls are not
# touched by the dialog code anymore, preventing null-control crashes.
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

# Keep the BD PBX title independent of the original MicroSIP title.
if ($cpp -notmatch 'SetWindowText\(_T\("BD PBX - Add Account"\)\)') {
    $cpp = $cpp.Replace('CDialog::OnInitDialog();', 'CDialog::OnInitDialog();\r\n\r\n\tSetWindowText(_T("BD PBX - Add Account"));', 1)
}

# Replace the complete Load/Save implementations so no code dereferences
# controls that were removed from the redesigned dialog.
$loadPattern = '(?s)void AccountDlg::Load\(int id\)\s*\{.*?\n\}\s*\n\s*void AccountDlg::OnBnClickedOk\(\)'
$loadAndStartSave = @'
void AccountDlg::Load(int id)
{
	CEdit* edit;
	CComboBox* combobox;
	CString str;
	int i;
	int n;
	bool found;

	accountId = id;
	if (accountSettings.AccountLoad(id, &m_Account)) {
		accountId = id;
		if (accountId && accountSettings.accountId == accountId && !accountSettings.account.rememberPassword) {
			m_Account.username = accountSettings.account.username;
			m_Account.password = accountSettings.account.password;
			m_Account.rememberPassword = false;
		}
	}
	else {
		accountId = -1;
	}

	bool isEdit = (accountId > 0 && (!m_Account.username.IsEmpty() || accountId > 1));

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

	edit = (CEdit*)GetDlgItem(IDC_EDIT_PASSWORD);
	if (accountId == -1 || m_Account.password.IsEmpty()) {
		GetDlgItem(IDC_SYSLINK_DISPLAY_PASSWORD)->ShowWindow(SW_SHOW);
	}
	else {
		GetDlgItem(IDC_SYSLINK_DISPLAY_PASSWORD)->ShowWindow(SW_HIDE);
	}
	edit->SetPasswordChar('*');
	edit->SetWindowText(m_Account.password);

	edit = (CEdit*)GetDlgItem(IDC_EDIT_DISPLAYNAME);
	edit->SetWindowText(m_Account.displayName);
	edit = (CEdit*)GetDlgItem(IDC_ACCOUNT_DIALING_PREFIX);
	edit->SetWindowText(m_Account.dialingPrefix);
	edit = (CEdit*)GetDlgItem(IDC_ACCOUNT_DIAL_PLAN);
	edit->SetWindowText(m_Account.dialPlan);
	((CButton*)GetDlgItem(IDC_ACCOUNT_HIDE_CID))->SetCheck(m_Account.hideCID);
	edit = (CEdit*)GetDlgItem(IDC_EDIT_VOICEMAIL);
	edit->SetWindowText(m_Account.voicemailNumber);

	combobox = (CComboBox*)GetDlgItem(IDC_SRTP);
	if (m_Account.srtp == _T("optional")) i = 1;
	else if (m_Account.srtp == _T("mandatory")) i = 2;
	else if (m_Account.srtp == _T("dtls-sdes")) i = 3;
	else if (m_Account.srtp == _T("dtls")) i = 4;
	else i = 0;
	combobox->SetCurSel(i);

	combobox = (CComboBox*)GetDlgItem(IDC_TRANSPORT);
	n = sizeof(transportItems) / sizeof(transportItems[0]);
	found = false;
	for (i = 0; i < n; i++) {
		if (m_Account.transport == transportItems[i]) {
			combobox->SetCurSel(i);
			found = true;
			break;
		}
	}
	if (!found) combobox->SetCurSel(0);

	combobox = (CComboBox*)GetDlgItem(IDC_PUBLIC_ADDR);
	if (combobox->IsWindowEnabled()) {
		str = get_public_addr(&m_Account);
		if (!str.IsEmpty()) combobox->SetWindowText(str);
	}

	((CButton*)GetDlgItem(IDC_PUBLISH))->SetCheck(m_Account.publish);
	((CButton*)GetDlgItem(IDC_REWRITE))->SetCheck(m_Account.allowRewrite);
	((CButton*)GetDlgItem(IDC_ICE))->SetCheck(m_Account.ice);
	((CButton*)GetDlgItem(IDC_SESSION_TIMER))->SetCheck(m_Account.disableSessionTimer);
	GetDlgItem(IDC_SYSLINK_ACCOUNT_DELETE)->ShowWindow(isEdit ? SW_SHOW : SW_HIDE);
}

void AccountDlg::OnBnClickedOk()
'@
if ($cpp -notmatch $loadPattern) { throw 'AccountDlg Load/Save boundary not found' }
$cpp = [regex]::Replace($cpp, $loadPattern, $loadAndStartSave, 1)

$savePattern = '(?s)void AccountDlg::OnBnClickedOk\(\)\s*\{.*?\n\}\s*\n\s*void AccountDlg::OnNMClickSyslinkSipServer'
$safeSave = @'
void AccountDlg::OnBnClickedOk()
{
	CEdit* edit;
	CComboBox* combobox;
	CString str;
	int i;

	edit = (CEdit*)GetDlgItem(IDC_ACCOUNT_LABEL);
	edit->GetWindowText(str);
	m_Account.label = str.Trim();
	if (m_Account.label.IsEmpty()) m_Account.label = _T("Account 1");

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
	m_Account.server = m_Account.domain;
	m_Account.proxy = m_Account.domain;

	edit = (CEdit*)GetDlgItem(IDC_EDIT_USERNAME);
	edit->GetWindowText(str);
	m_Account.username = str.Trim();
	if (m_Account.username.IsEmpty()) {
		AfxMessageBox(_T("Please enter your SIP username."));
		GetDlgItem(IDC_EDIT_USERNAME)->SetFocus();
		return;
	}
	m_Account.authID = m_Account.username;

	edit = (CEdit*)GetDlgItem(IDC_EDIT_PASSWORD);
	edit->GetWindowText(str);
	m_Account.password = str.Trim();

	edit = (CEdit*)GetDlgItem(IDC_EDIT_DISPLAYNAME);
	edit->GetWindowText(str);
	m_Account.displayName = str.Trim();
	edit = (CEdit*)GetDlgItem(IDC_ACCOUNT_DIALING_PREFIX);
	edit->GetWindowText(str);
	m_Account.dialingPrefix = str.Trim();
	edit = (CEdit*)GetDlgItem(IDC_ACCOUNT_DIAL_PLAN);
	edit->GetWindowText(str);
	m_Account.dialPlan = str.Trim();
	m_Account.hideCID = ((CButton*)GetDlgItem(IDC_ACCOUNT_HIDE_CID))->GetCheck();
	edit = (CEdit*)GetDlgItem(IDC_EDIT_VOICEMAIL);
	edit->GetWindowText(str);
	m_Account.voicemailNumber = str.Trim();

	combobox = (CComboBox*)GetDlgItem(IDC_SRTP);
	i = combobox->GetCurSel();
	if (i == 1) m_Account.srtp = _T("optional");
	else if (i == 2) m_Account.srtp = _T("mandatory");
	else if (i == 3) m_Account.srtp = _T("dtls-sdes");
	else if (i == 4) m_Account.srtp = _T("dtls");
	else m_Account.srtp = _T("");

	combobox = (CComboBox*)GetDlgItem(IDC_TRANSPORT);
	i = combobox->GetCurSel();
	if (i < 0 || i >= (int)(sizeof(transportItems) / sizeof(transportItems[0]))) i = 0;
	m_Account.transport = transportItems[i];

	combobox = (CComboBox*)GetDlgItem(IDC_PUBLIC_ADDR);
	if (combobox->IsWindowEnabled()) {
		combobox->GetWindowText(m_Account.publicAddr);
		if (m_Account.publicAddr == Translate(_T("Auto"))) m_Account.publicAddr = _T("");
	}

	m_Account.rememberPassword = 1;
	if (m_Account.registerRefresh <= 0) m_Account.registerRefresh = PJSUA_REG_INTERVAL;
	if (m_Account.keepAlive < 0) m_Account.keepAlive = 15;
	m_Account.publish = ((CButton*)GetDlgItem(IDC_PUBLISH))->GetCheck();
	m_Account.allowRewrite = ((CButton*)GetDlgItem(IDC_REWRITE))->GetCheck();
	m_Account.ice = ((CButton*)GetDlgItem(IDC_ICE))->GetCheck();
	m_Account.disableSessionTimer = ((CButton*)GetDlgItem(IDC_SESSION_TIMER))->GetCheck();

	this->ShowWindow(SW_HIDE);
	mainDlg->accountDlg = NULL;
	if (accountId == -1) {
		Account dummy;
		int newId = 1;
		while (accountSettings.AccountLoad(newId, &dummy)) newId++;
		accountId = newId;
	}
	accountSettings.AccountSave(accountId, &m_Account);

	if (accountId) {
		mainDlg->PJAccountDelete(true);
		accountSettings.accountId = accountId;
		accountSettings.account = m_Account;
		accountSettings.AccountLoad(accountSettings.accountId, &accountSettings.account);
		if (!m_Account.rememberPassword) {
			accountSettings.account.username = m_Account.username;
			accountSettings.account.password = m_Account.password;
			accountSettings.account.rememberPassword = false;
		}
		mainDlg->OnAccountChanged();
		mainDlg->InitUI();
		accountSettings.SettingsSave();
		mainDlg->PJAccountAdd();
	}
	else {
		mainDlg->PJAccountDeleteLocal();
		accountSettings.AccountLoad(0, &accountSettings.accountLocal);
		mainDlg->PJAccountAddLocal();
	}
	OnClose();
}

void AccountDlg::OnNMClickSyslinkSipServer
'@
if ($cpp -notmatch $savePattern) { throw 'AccountDlg OnBnClickedOk boundary not found' }
$cpp = [regex]::Replace($cpp, $savePattern, $safeSave, 1)

Set-Content -Path $cppPath -Value $cpp -Encoding utf8
Write-Host 'BD PBX account dialog runtime crash fix applied: no removed controls are dereferenced.'
