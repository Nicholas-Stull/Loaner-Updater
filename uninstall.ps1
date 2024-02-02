function UninstallSoftware {
    param (
        [string]$softwareName,
        [string]$vendorName
    )

    $softwareInstalled = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like $softwareName -and $_.Vendor -eq $vendorName }

    if ($softwareInstalled) {
        Write-Host "$softwareName is installed. Uninstalling..."
        
        $softwareInstalled.Uninstall()
        
        Write-Host "Uninstalled $softwareName"
    }
    else {
        Write-Host "$softwareName is not installed."
    }
}

UninstallSoftware -softwareName "Dell Command | Update" -vendorName "Dell Inc."