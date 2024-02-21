<#
.SYNOPSIS
    Downloads the latest version of the Loaner script from the GitHub repository and runs it.
.DESCRIPTION
    This script downloads the latest version of the Loaner script from the GitHub repository and runs it.
    The download location can be specified using the --download option, which accepts a location key or a custom path.
    If no download location is specified, the script will default to the user's temp folder.
    The --location option can be used to display the path for a given location key.
    The --help option displays usage information.
.PARAMETER download
    Specifies the download location key or a custom path.
    If a location key is specified, the script will use the predefined download location associated with the key.
    If a custom path is specified, the script will use the specified path as the download location. 
.PARAMETER location
    Displays the path for a given location key.
.PARAMETER help
    Displays usage information.
.EXAMPLE
    .\pulldown.ps1 --download desktop
    Downloads the latest version of the Loaner script to the user's desktop.
.EXAMPLE
    .\pulldown.ps1 --download C:\Downloads
    Downloads the latest version of the Loaner script to the specified custom path.
#>




# Initial parameter setup with defaults
$Run = $false
$DownloadLocation = $null

# Predefined download locations
$LocationMap = @{
    #admin folder
    'desktop'   = [System.Environment]::GetFolderPath('Desktop')
    'documents' = [System.Environment]::GetFolderPath('MyDocuments')
    'loaner'    = Join-Path -Path $env:USERPROFILE -ChildPath 'Downloads\Loaner_Updater\'
}

# Default to user's temp folder
$DownloadLocation = [System.IO.Path]::GetTempPath()

# Ensure the Temp directory exists
$TempPath = [System.IO.Path]::GetTempPath()
if (-Not (Test-Path -Path $TempPath)) {
    New-Item -ItemType Directory -Path $TempPath | Out-Null
    Write-Host "Temporary directory created: $TempPath" -ForegroundColor Green
}

function Show-Error {
    Write-Host "---------------------------------------------------------" -ForegroundColor Red
    Write-Host "---------------------------------------------------------" -ForegroundColor Red
    Write-Host "-----------------HEY, THERE'S AN ERROR!!-----------------" -ForegroundColor Red
    Write-Host "---------------------------------------------------------" -ForegroundColor Red
    Write-Host "---------------------------------------------------------" -ForegroundColor Red
}

function CheckFolder {
    param (
        [string]$folderPath
    )
    if (-Not (Test-Path -Path $folderPath)) {
        Write-Host "ERROR: The folder '$folderPath' does not exist." -ForegroundColor Red
        $choice = Read-Host "Do you want to create the folder? (Y/N)"
        if ($choice -eq 'Y' -or $choice -eq 'y') {
            New-Item -ItemType Directory -Path $folderPath | Out-Null
            Write-Host "Folder created: $folderPath" -ForegroundColor Green
        }
        else {
            Write-Host "Operation cancelled. Exiting script..." -ForegroundColor Yellow
            exit
        }
    }
}

# Parsing custom command-line arguments
for ($i = 0; $i -lt $args.Count; $i++) {
    switch -Regex ($args[$i]) {
        '^--?help$' {
            # Display usage information and exit
            Write-Host "Usage: down4.ps1 [options]"
            Write-Host "Options:"
            Write-Host "  --download, -download, --down, -down   Specify the download location key or a custom path"
            Write-Host "  --help, -help   Display this help message and exit"
            Write-Host "  --location, -location   Display the path for a given location key"
            Write-Host ""
            Write-Host "Available location keys:"
            $LocationMap.Keys | ForEach-Object { Write-Host "  $_" }
            exit
        }
        
        '^--?(down(load)?|dl)$' {
            $i++  # Move to the next argument which should be the download location key or path
            $locationKey = $args[$i]
            if ($LocationMap.ContainsKey($locationKey)) {
                $DownloadLocation = $LocationMap[$locationKey]
            }
            else {
                $DownloadLocation = $TempPath
            }
        }
        '^--?location$' {
            $i++  # Move to the next argument which should be the location key
            $locationKey = $args[$i]
            if ($LocationMap.ContainsKey($locationKey)) {
                Write-Host "Location for '$locationKey': $($LocationMap[$locationKey])"
            }
            else {
                Write-Host "Invalid location key: '$locationKey'. Available keys are:" -ForegroundColor Red
                $LocationMap.Keys | ForEach-Object { Write-Host "  $_" }
            }
            exit
        }
    }
}
function Invoke-FileDownload {
    $filename = "loaner.ps1"
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/json")
    $url = "https://github.com/Nicholas-Stull/Loaner-Updater/releases/latest/download/loaner.ps1"
    $destinationPath = Join-Path -Path $DownloadLocation -ChildPath $filename
    Write-Host "Downloading to: $destinationPath"

    # Perform the download
    Invoke-WebRequest -Uri $url -Headers $headers -OutFile $destinationPath
    Write-Output "Scanning for file..."
    # Check if the file exists
    if (Test-Path $destinationPath) {
        Write-Output "Download complete."
    }
    else {
        Write-Output "Download failed or the file does not exist."
    }
}
function RunLoaner {
    if ($Run -eq $true) {
        Write-Host "Running Loaner script..."
        & $destinationPath
    }
    else {
        $choice = Read-Host "Run? (Y/N)"
        if ($choice -eq 'Y' -or $choice -eq 'y') {
            Write-Host "Running Loaner script..."
            & $destinationPath
        }
        else {
            Write-Host "Operation cancelled. Exiting script..." -ForegroundColor Yellow
            exit
        }    
    }
}
try {
    CheckFolder $DownloadLocation
    Invoke-FileDownload -url $url  -Headers $headers -destination $DownloadLocation
    RunLoaner 
}
catch {
    Show-Error
    Write-Error "An error occurred: $_"
}
