# List of programs you're interested in
$originalPrograms = @(
    "Program1",
    "Program2",
    "Program3"
)

# Get list of installed programs
$installedPrograms = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName | Where-Object { $_.DisplayName -ne $null } | Select-Object -ExpandProperty DisplayName

# Compare lists and find the difference
$notOnOriginalList = $installedPrograms | Where-Object { $_ -notin $originalPrograms }

# Output programs not on the original list
Write-Host "Programs installed that are not on the original list:"
$notOnOriginalList
