# LoanerPullDown.ps1
[![GitHub Release Date](https://img.shields.io/github/release-date/Nicholas-Stull/Loaner-Updater)](https://github.com/Nicholas-Stull/Loaner-Updater/releases/)
[![GitHub Downloads](https://img.shields.io/github/downloads/Nicholas-Stull/Loaner-Updater/total)](https://github.com/Nicholas-Stull/Loaner-Updater/releases/)

# Brief Description

This PowerShell script is used to download the latest version of the `Loaner.ps1` script from the `Loaner-Updater` repository on GitHub. It supports custom download locations and branch selection.

## How it works

-   The script initializes parameters with default values.
-   It defines a map of predefined download locations.
-   It checks if the Temp directory exists, if not, it creates one.
-   It defines functions to show errors, check if a folder exists, get the GitHub download link, and download the file.
-   It parses custom command-line arguments.
-   It downloads the file from GitHub to the specified location.

## Usage

The URL [raw.githubusercontent.com/Nicholas-Stull/Loaner-Updater/main/LoanerPullDown.ps1](https://raw.githubusercontent.com/Nicholas-Stull/Loaner-Updater/main/LoanerPullDown.ps1) always redirects to the latest version of the script.

### PowerShell

Simply run this command with **PowerShell**.

```powershell
irm loaners.nicholasstull.com | iex
```

Due to the nature of how PowerShell works, passing arguments to the script is a bit harder. To do it as a one-line command, you can run this:
```powershell
iex "& { $(iwr loaners.nicholasstull.com) } --servers"
``` 
## Parameters
- For more informatrion run 'LoanerPullDown.ps1 --help'
The 'LoanerPullDown.ps1` script accepts the following parameters:

- `-Path`: Specifies the path where the `Loaner.ps1` script will be downloaded. If not provided, the script will be downloaded to the temp directory.
- `-Branch`: Specifies the branch of the `Loaner-Updater` repository to download the `Loaner.ps1` script from. If not provided, the script will be downloaded from the `main` branch.

You can use these parameters like so:

```powershell
# Download the script to a specific directory
LoanerPullDown.ps1 -Path "C:\MyScripts"

# Download the script from a specific branch
LoanerPullDown.ps1 -Branch "dev"
```
