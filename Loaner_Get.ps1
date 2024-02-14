# ============================================================================ #
# Startup
# ============================================================================ #

# Get the download link for the Loaner.ps1 file
function Get-LoanerDownloadLink {
    param (
        [string]$branch = "main",
        [SecureString]$credentials = "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",
        [string]$username = "Nicholas-Stull",
        [string]$repo = "Loaner-Updater",
        [string]$file = "Loaner.ps1",
        [switch]$help = $false
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "token $credentials")
    $headers.Add("Accept", "application/json")
    Return "https://raw.githubusercontent.com/$username/$repo/$branch/$file"
}

# Download the Loaner.ps1 file
function Download-Loaner {
    param (
        [string]$downloadLink,
        [string]$destination
    )
    Invoke-WebRequest -Uri $downloadLink -OutFile $destination
}

# Run the Loaner.ps1 file
function Run-Loaner {
    param (
        [string]$filePath
    )
    & $filePath
}

# Main Script
try {
    $branch = "main" # replace with your branch name
    $downloadLink = Get-LoanerDownloadLink -branch $branch
    $destination = "./Loaner.ps1"

    Write-Host "Downloading Loaner.ps1 from the $branch branch..."
    Download-Loaner -downloadLink $downloadLink -destination $destination

    if (Test-Path $destination) {
        Write-Host "Running Loaner.ps1..."
        Run-Loaner -filePath $destination
    }
    else {
        Write-Host "Loaner.ps1 not found. Please download it first."
    }

    Write-Host "Done."
}
catch {
    Write-Error "An error occurred: $_"
}