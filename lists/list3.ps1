# List of programs you're interested in
$LoanerPrograms = @(
    "Statdisk 13 version *.*.*",
    "Microsoft Edge*",
    "Microsoft Edge Update*",
    "Microsoft Edge WebView2 Runtime*",
    "PaperCut MF Client*",
    "Request Handler Agent*",
    "Realtek USB Audio*",
    "Patch Management Service Controller*",
    "Intel*Software Installer*",
    "FileWave Client*",
    "Dell Command | Update*",
    "Adobe Refresh Manager*",
    "Adobe Acrobat Reader DC*",
    "Microsoft Visual C++ 2019 X86 Additional Runtime - *.*.*",
    "Dell SupportAssist OS Recovery Plugin for Dell Update*",
    "Windows Agent*",
    "Windows 10 Update Assistant*",
    "Microsoft Visual C++ 2015-2019 Redistributable (x86) - *.*.*",
    "File Cache Service Agent*",
    "Microsoft Visual C++ 2019 X86 Minimum Runtime - *.*.*",
    "Realtek Audio Driver*"
)

# Get list of installed programs
$installedPrograms = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName | Where-Object { $_.DisplayName -ne $null } | Select-Object -ExpandProperty DisplayName

# Compare lists and find the difference
$notOnLoanerList = @()
foreach ($program in $installedPrograms) {
    $matched = $false
    foreach ($LoanerPrograms in $LoanerPrograms) {
        if ($program -like $LoanerPrograms) {
            $matched = $true
            break
        }
    }
    if (-not $matched) {
        $notOnLoanerList += $program
    }
}

# Check if there is a difference
if ($notOnLoanerList.Count -eq 0) {
    Write-Host "All Good! No new programs installed."
}
else {
    # Output programs not on the original list
    Write-Host "Programs installed that are not on the original list:"
    $notOnLoanerList
}