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
CONTROL         "", IDC_SYSLINK_ACCOUNT_DELETE, "SysLink", 0x0, 10, 352, 75, 8, NOT WS_VISIBLE
DEFPUSHBUTTON   "Save", IDOK, 110, 370, 80, 18
PUSHBUTTON      "Cancel", IDCANCEL, 195, 370, 80, 18
END
//-----------------------------------------------------------------------
'@

# Compact the lower controls so the complete dialog, including Save/Cancel, fits on a normal 768-1080px desktop.
$accountSection = $accountSection.Replace('RTEXT           "Public Address", IDC_STATIC, 10, 345, 90, 8, SS_WORDELLIPSIS', 'RTEXT           "Public Address", IDC_STATIC, 10, 310, 90, 8, SS_WORDELLIPSIS')
$accountSection = $accountSection.Replace('COMBOBOX        IDC_PUBLIC_ADDR, 105, 342, 105, 30', 'COMBOBOX        IDC_PUBLIC_ADDR, 105, 307, 105, 30')
$accountSection = $accountSection.Replace('RTEXT           "Register Refresh", IDC_STATIC, 10, 379, 90, 8, SS_WORDELLIPSIS', 'RTEXT           "Register Refresh", IDC_STATIC, 10, 344, 90, 8, SS_WORDELLIPSIS')
$accountSection = $accountSection.Replace('EDITTEXT        IDC_ACCOUNT_REGISTER_REFRESH, 105, 376, 45, 16', 'EDITTEXT        IDC_ACCOUNT_REGISTER_REFRESH, 105, 341, 45, 16')
$accountSection = $accountSection.Replace('RTEXT           "Keep-Alive", IDC_STATIC, 155, 379, 55, 8, SS_WORDELLIPSIS', 'RTEXT           "Keep-Alive", IDC_STATIC, 155, 344, 55, 8, SS_WORDELLIPSIS')
$accountSection = $accountSection.Replace('EDITTEXT        IDC_ACCOUNT_KEEP_ALIVE, 212, 376, 35, 16', 'EDITTEXT        IDC_ACCOUNT_KEEP_ALIVE, 212, 341, 35, 16')

$dialog = $dialog.Substring(0, $start) + $accountSection + $dialog.Substring($end)
Set-Content -Path $dialogPath -Value $dialog -Encoding utf8

$cppPath = Join-Path $env:GITHUB_WORKSPACE 'AccountDlg.cpp'
$cpp = Get-Content -Raw -Path $cppPath

$cpp = $cpp.Replace('CDialog::OnInitDialog();', 'CDialog::OnInitDialog();\n\n\tSetWindowText(_T("BD PBX - Add Account"));')
$cpp = $cpp -replace '(?s)\tGetDlgItem\(IDC_ACCOUNT_REQUIRED_USERNAME\)->ShowWindow\(show\);\r?\n\tGetDlgItem\(IDC_ACCOUNT_REQUIRED_DOMAIN\)->ShowWindow\(show\);\r?\n\tGetDlgItem\(IDC_EDIT_SERVER\)->EnableWindow\(id\);', ''

$oldLoad = @'
\tedit = (CEdit*)GetDlgItem(IDC_ACCOUNT_LABEL);
\tedit->SetWindowText(m_Account.label);

\tedit = (CEdit*)GetDlgItem(IDC_EDIT_SERVER);
\tedit->SetWindowText(m_Account.server);
\tedit = (CEdit*)GetDlgItem(IDC_EDIT_PROXY);
\tedit->SetWindowText(m_Account.proxy);
\tedit = (CEdit*)GetDlgItem(IDC_EDIT_DOMAIN);
\tedit->SetWindowText(m_Account.domain);

\tedit = (CEdit*)GetDlgItem(IDC_EDIT_AUTHID);
\tedit->SetWindowText(m_Account.authID);

\tedit = (CEdit*)GetDlgItem(IDC_EDIT_USERNAME);
\tedit->SetWindowText(m_Account.username);
'@
$newLoad = @'
\tedit = (CEdit*)GetDlgItem(IDC_ACCOUNT_LABEL);
\tif (m_Account.label.IsEmpty()) {
\t\tm_Account.label = _T("Account 1");
\t}
\tedit->SetWindowText(m_Account.label);

\tedit = (CEdit*)GetDlgItem(IDC_EDIT_DOMAIN);
\tCString tenantDomain = m_Account.domain;
\tCString tenantSuffix = _T(".bdpbx.com");
\tif (tenantDomain.Right(tenantSuffix.GetLength()).CompareNoCase(tenantSuffix) == 0) {
\t\ttenantDomain = tenantDomain.Left(tenantDomain.GetLength() - tenantSuffix.GetLength());
\t}
\tedit->SetWindowText(tenantDomain);

\tedit = (CEdit*)GetDlgItem(IDC_EDIT_USERNAME);
\tedit->SetWindowText(m_Account.username);
'@
if (-not $cpp.Contains($oldLoad)) { throw 'AccountDlg Load block not found' }
$cpp = $cpp.Replace($oldLoad, $newLoad)

$oldSave = @'
\tedit = (CEdit*)GetDlgItem(IDC_EDIT_SERVER);
\tedit->GetWindowText(str);
\tm_Account.server=str.Trim();
\tedit = (CEdit*)GetDlgItem(IDC_EDIT_PROXY);
\tedit->GetWindowText(str);
\tm_Account.proxy=str.Trim();
\tedit = (CEdit*)GetDlgItem(IDC_EDIT_DOMAIN);
\tedit->GetWindowText(str);
\tm_Account.domain=str.Trim();

\tedit = (CEdit*)GetDlgItem(IDC_EDIT_AUTHID);
\tedit->GetWindowText(str);
\tm_Account.authID=str.Trim();

\tedit = (CEdit*)GetDlgItem(IDC_EDIT_USERNAME);
\tedit->GetWindowText(str);
\tm_Account.username=str.Trim();
'@
$newSave = @'
\tedit = (CEdit*)GetDlgItem(IDC_EDIT_DOMAIN);
\tedit->GetWindowText(str);
\tstr = str.Trim();
\tstr.Trim(_T('.'));
\tCString tenantSuffix = _T(".bdpbx.com");
\tif (str.Right(tenantSuffix.GetLength()).CompareNoCase(tenantSuffix) == 0) {
\t\tstr = str.Left(str.GetLength() - tenantSuffix.GetLength());
\t\tstr.Trim(_T('.'));
\t}
\tif (str.IsEmpty()) {
\t\tAfxMessageBox(_T("Please enter your BD PBX subdomain."));
\t\tGetDlgItem(IDC_EDIT_DOMAIN)->SetFocus();
\t\treturn;
\t}
\tm_Account.domain = str + tenantSuffix;

\tedit = (CEdit*)GetDlgItem(IDC_EDIT_USERNAME);
\tedit->GetWindowText(str);
\tm_Account.username=str.Trim();
\tif (m_Account.username.IsEmpty()) {
\t\tAfxMessageBox(_T("Please enter your SIP username."));
\t\tGetDlgItem(IDC_EDIT_USERNAME)->SetFocus();
\t\treturn;
\t}
\tm_Account.authID=m_Account.username;
\tm_Account.server=m_Account.domain;
\tm_Account.proxy=m_Account.domain;
'@
if (-not $cpp.Contains($oldSave)) { throw 'AccountDlg save block not found' }
$cpp = $cpp.Replace($oldSave, $newSave)
Set-Content -Path $cppPath -Value $cpp -Encoding utf8

Write-Host 'BD PBX account dialog layout and Save handling applied successfully.'
