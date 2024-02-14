# List of programs you're interested in
$originalPrograms = @(
    "Statdisk 13 version *.*.*",
    "Microsoft Edge",
    "Microsoft Edge Update",
    "Microsoft Edge WebView2 Runtime",
    "PaperCut MF Client",
    "Request Handler Agent",
    "Realtek USB Audio",
    "Patch Management Service Controller",
    "Intel*Software Installer",
    "FileWave Client",
    "Dell Command | Update",
    "Adobe Refresh Manager",
    "Adobe Acrobat Reader DC",
    "Microsoft Visual C++ 2019 X86 Additional Runtime - 14.28.29325",
    "Dell SupportAssist OS Recovery Plugin for Dell Update",
    "Windows Agent",
    "Windows 10 Update Assistant.*",
    "Microsoft Visual C++ 2015-2019 Redistributable (x86) - 14.28.29325",
    "File Cache Service Agent",
    "Microsoft Visual C++ 2019 X86 Minimum Runtime - 14.28.29325.",
    "Realtek Audio Driver"
) | ForEach-Object { [regex]::Escape($_) } # Convert to regex

# Get list of installed programs
$installedPrograms = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName | Where-Object { $_.DisplayName -ne $null } | Select-Object -ExpandProperty DisplayName

# Compare lists and find the difference
$notOnOriginalList = $installedPrograms | Where-Object { $program = $_; -not ($originalPrograms | Where-Object { $program -match $_ }) }

# Check if there is a difference
if ($notOnOriginalList.Count -eq 0) {
    Write-Host "All Good! No new programs installed."
}
else {
    # Output programs not on the original list
    Write-Host "Programs installed that are not on the original list:"
    $notOnOriginalList
}