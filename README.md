# LoanerPullDown.ps1
[![GitHub Release Date](https://img.shields.io/github/release-date/Nicholas-Stull/Loaner-Updater)](https://github.com/Nicholas-Stull/Loaner-Updater/releases/)
[![GitHub Downloads](https://img.shields.io/github/downloads/Nicholas-Stull/Loaner-Updater/total)](https://github.com/Nicholas-Stull/Loaner-Updater/releases/)

### PowerShell

Simply run this command with **PowerShell**.

```powershell
irm loaners.thetinkeringnerd.com | iex
```

Due to the nature of how PowerShell works, passing arguments to the script is a bit harder. To do it as a one-line command, you can run this:
```powershell
iex "& { $(iwr loaners.thetinkeringnerd.com) } --servers"
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
