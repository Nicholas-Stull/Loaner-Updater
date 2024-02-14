$file = "Dell-Command-Update-Application_8D5MC_WIN_4.3.0_A00_04.exe"
$ExeDir = "C:\Users\nstull\downloads"
$destination = "$ExeDir\$file"
$source = "https://dl.dell.com/FOLDER07582851M/5/Dell-Command-Update-Application_8D5MC_WIN_4.3.0_A00_04.exe"
$headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
}
if (-not (Test-Path $destination)) {
    Write-Host "Dowloading Dell Command Update Installer"
    Invoke-WebRequest -Uri $source -Headers $headers -OutFile $destination
} else {
    Write-Host "Dell Command Update Installer already downloaded"
}
Set-Location $ExeDir
Write-Host "Running Dell Command Update Installer"
Start-Process -FilePath $file -Verb RunAs -ArgumentList "/s" -Wait
