Set-Location "C:\Users\nstull\Downloads"
$file = "Dell-Command-Update-Application_8D5MC_WIN_4.3.0_A00_04.EXE"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$download = "https://dl.dell.com/FOLDER07582851M/5/Dell-Command-Update-Application_8D5MC_WIN_4.3.0_A00_04.EXE"
Write-Host "Downloading Dell Command Update Installer"
Invoke-WebRequest -Uri $download -OutFile $file

# Run the downloaded .exe file
Write-Host "Running Dell Command Update Installer"
Start-Process -FilePath $file