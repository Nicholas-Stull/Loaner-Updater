<#
.SYNOPSIS
    loaner.ps1 - A script for updating loaners for the next semester

.DESCRIPTION
    This script updates loaners to be sent out for the next semester. It essentially performs a user wipe.

.AUTHOR
    Nick Stull (https://www.github.com/nicholas-stull)

.DATE
    Creation Date:  
.RESOURCES
New-LocalUser - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/new-localuser?view=powershell-5.1
Remove-LocalUser - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/remove-localuser?view=powershell-5.1
Add-GroupMember - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/add-localgroupmember?view=powershell-5.1
OOBE Bypass : https://www.reddit.com/r/PowerShell/comments/15ui9jg/add_new_local_user/?rdt=35761&onetap_auto=true
Dell Command Update - https://www.reddit.com/r/PowerShell/comments/yfiplr/comment/iu3leno/?utm_source=share&utm_medium=web2x&context=3
.NOTES
    Version:        1.0
    Prerequisites:  PowerShell 5.1
    Purpose/Change: This script was created to automate the process of updating loaners for the next semester.
    Check next Visit/Change:
    2. Clean up and organzie script. Including Typos. 
        - Will do at some point. Will need to block it up and clean it up.


#>
$version = "1.1.0"
$Branch = "main"
# Script starts here
# Parameters
$VerbosePreference = "Continue"

# change date here for when the loaner is to be locked by.
$LoanerUseByDate = Get-Date -Year 2024 -Month 05 -Day 17 -Hour 00 -Minute 00 -Second 00

# Log Variables
$Loaner_Update_Dir = "C:\Users\Administrator\Documents\Loaner_Updater"
$logdirname = "logfiles"
$logDir = "$Loaner_Update_Dir\$logdirname"
$timestamp = (Get-Date).toString("yyyy_MM_dd HH:mm:ss")
$LogFileName = "Loaner_Log_" + (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss") + "_log.txt"
$logFile = "$LogDir\$LogFileName"
$CompName = "$env:COMPUTERNAME"

# Functions
Function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string] $message,
        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "WARN", "ERROR")]
        [string] $level = "INFO",
        [string] $line = "Line:",
        $LineNumber = $MyInvocation.ScriptLineNumber
    )
    
    if (-not (Test-Path -Path $logDir)) {
        New-Item -Path "$LogDir" -Name "$logdirname" -ItemType "directory"
    }

    Add-Content -Path $logFile -Value "[$CompName] - $timestamp [$level] - $line $LineNumber - $message"
}
$PragueCheck = { 
<# This function group is used to 
* Check the loaner for any new programs installed
* Install and uninstall programs
* Install/Uninstall Dell Command Update
* Check for Java, FileWave Client, and Windows Agent
#>
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
    
    function SoftwareInstalled {
        param (
            [string]$softwareName,
            [string]$vendorName
        )

        $softwareInstalled = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like $softwareName -and $_.Vendor -eq $vendorName }

        if ($softwareInstalled) {
            Write-Host "$softwareName is installed."
        }
        else {
            Write-Host "$softwareName is not installed."
        }
    }
    function LoanerCheck {
        # Get list of installed programs
        $installedPrograms = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName | Where-Object { $null -ne $_.DisplayName } | Select-Object -ExpandProperty DisplayName

        # Compare lists and find the difference
        $notOnLoanerList = @()
        foreach ($program in $installedPrograms) {
            $matched = $false
            foreach ($LoanerProgram in $LoanerPrograms) {
                if ($program -like $LoanerProgram) {
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
    }
    function UninstallSoftware {
        param (
            [string]$softwareName,
            [string]$vendorName
        )

        $softwareInstalled = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like $softwareName -and $_.Vendor -eq $vendorName }

        if ($softwareInstalled) {
            Write-Host "$softwareName is installed. Uninstalling..."
            Write-Log -message "$softwareName is installed. Uninstalling..."
            $softwareInstalled.Uninstall()
        
            Write-Host "Uninstalled $softwareName"
            Write-Log -message "Uninstalled $softwareName"
        }
        else {
            Write-Host "$softwareName is not installed."
        }
    }
    
    function DellInstall {
        $file = "Dell-Command-Update-Application_8D5MC_WIN_4.3.0_A00_04.exe"
        $ExeDir = "C:\Users\Administrator\downloads"
        $destination = "$ExeDir\$file"
        $source = "https://dl.dell.com/FOLDER07582851M/5/Dell-Command-Update-Application_8D5MC_WIN_4.3.0_A00_04.exe"
        $headers = @{
            "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
        }
        if (-not (Test-Path $destination)) {
            Write-Host "Dowloading Dell Command Update Installer"
            Invoke-WebRequest -Uri $source -Headers $headers -OutFile $destination
        }
        else {
            Write-Host "Dell Command Update Installer already downloaded"
        }
        Set-Location $ExeDir
        Write-Host "Running Dell Command Update Installer"
        Start-Process -FilePath $file -Verb RunAs -ArgumentList "/s" -Wait
    }
    function RunPragueCheck {
        $softwareList = @(
            @{ Name = "Java"; Vendor = "Oracle Corporation" },
            @{ Name = "FileWave Client"; Vendor = "FileWave" },
            @{ Name = "Windows Agent"; Vendor = "N-able Technologies" }
        )

        foreach ($software in $softwareList) {
            SoftwareInstalled -softwareName $software.Name -vendorName $software.Vendor
        }
        LoanerCheck
        UninstallSoftware -softwareName "Dell Command | Update" -vendorName "Dell Inc."
        DellInstall
    }
    RunPragueCheck
    
    
}
$UserRemake = { # This function is used to create the loaner user and delete the old one. 
    # Loaner User Variables
    $LoanerUser = "smcloaner"
    $LoanerPass = ConvertTo-SecureString "Smcloaner1" -AsPlainText -Force  # Super strong plane text password here (yes this isn't secure at all)
    $LoanerName = "SMC Loaner"
    $LoanerDesc = 'Local Account for the SMC loaners' 
    $LoanerGroup = "Administrators"
    Function delete_loaneruser {
        process {
            try {
                #removes smcloaner user from computer cleaning files up
                Remove-LocalUser $LoanerUser
                Write-Log -message "$LoanerUser deleted"
                Write-Verbose "$LoanerUser deleted"
            }
            catch {
                Write-log -message "Deleting local account failed" -level "ERROR"
                Write-Verbose "Deleting local account failed" -level "ERROR"
            }
        }
    }
    Function create_loaneruser {
        <# 
        Another part can be added for updating the task/new task or account can be disbled on date. 
        If you want to re-enable it use the following commands:
        net user username /expires:never
        
        #>
        process {
            try { 
                New-LocalUser -name "$LoanerUser" -Password $LoanerPass -FullName "$LoanerName"-Description "$LoanerDesc" -AccountExpires $LoanerUseByDate -UserMayNotChangePassword -ErrorAction stop 
                Write-Log -message "$LoanerUser local user created"
                Write-Verbose "$LoanerUser local user created"
                # Add new user to Users group
                Add-LocalGroupMember -Group "$LoanerGroup" -Member "$LoanerUser" -ErrorAction stop
                Write-Log -message "$LoanerUser added to the local group"
                Write-Verbose "$LoanerUser added to the local group"
            }
            catch {
                Write-log -message "Creating local account failed" -level "ERROR"
                Write-Verbose "Creating local account failed ERROR"
            }
        }
    }
    ##--Bypass OOBE + Privacy Experience

    Function RunUserRemake {
        delete_loaneruser
        create_loaneruser
        Set-OOBEbypass
    }
    RunUserRemake
}
$PreLoginSetup = { 
    function Set-OOBEbypass {
        ###---Declare RegKey variables
        $RegKey = @{
            Path         = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            Name         = "EnableFirstLogonAnimation"
            Value        = 0
            PropertyType = "DWORD"
        }
        if (-not (Test-Path $RegKey.Path)) {
            Write-Verbose "$($RegKey.Path) does not exist. Creatng path."
            New-Item -Path $RegKey.Path -Force
            Write-Verbose "$($RegKey.Path) path has been created."
        }
        New-ItemProperty @RegKey -Force
        Write-Verbose "Registry key has been added/modified"
        ###---Clear and redeclare RegKey variables
        $RegKey = @{}
        $RegKey = @{
            Path         = "HKLM:\Software\Policies\Microsoft\Windows\OOBE"
            Name         = "DisablePrivacyExperience"
            Value        = 1
            PropertyType = "DWORD"
        }
        if (-not (Test-Path $RegKey.Path)) {
            Write-Verbose "$($RegKey.Path) does not exist. Creatng path."
            New-Item -Path $RegKey.Path -Force
            Write-Verbose "$($RegKey.Path) path has been created."
        }
        New-ItemProperty @RegKey -Force
        Write-Verbose "Registry key has been added/modified"
        ###---Clear and redeclare RegKey variables    
        $RegKey = @{}
        $RegKey = @{
            Path         = "HKCU:\Software\Policies\Microsoft\Windows\OOBE"
            Name         = "DisablePrivacyExperience"
            Value        = 1
            PropertyType = "DWORD"
        }
        if (-not (Test-Path $RegKey.Path)) {
            Write-Verbose "$($RegKey.Path) does not exist. Creatng path."
            New-Item -Path $RegKey.Path -Force
            Write-Verbose "$($RegKey.Path) path has been created."
        }
        New-ItemProperty @RegKey -Force
        Write-Verbose "Registry key has been added/modified"
    }
    function Set-PreLoginSetup {
        Set-OOBEbypass
    }
    Set-PreLoginSetup
}
$DellUpdates = {
    $DCU_folder = "C:\Program Files (x86)\Dell\CommandUpdate"
    $DCU_report = "$Loaner_Update_Dir\Dell_report"
    $DCU_report_log = "$DCU_report\update.log"
    $DCU_exe = "$DCU_folder\dcu-cli.exe"
    $DCU_category = "firmware,driver"  # bios,firmware,driver,application,others

    function detect {
        Try {
            if ([System.IO.File]::Exists($DCU_exe)) {
                if (Test-Path "$DCU_report\DCUApplicableUpdates.xml") { Remove-Item "$DCU_report\DCUApplicableUpdates.xml" -Recurse -Force }
                Start-Process $DCU_exe -ArgumentList "/scan -updateType=$DCU_category -report=$DCU_report" -Wait
            
                $DCU_analyze = if (Test-Path "$DCU_report\DCUApplicableUpdates.xml") { [xml](get-content "$DCU_report\DCUApplicableUpdates.xml") }
            
                if ($DCU_analyze.updates.update.Count -lt 1) {
                    Write-Output "Compliant, no drivers needed"
                    Exit 0
                }
                else {
                    Write-Warning "Found drivers to download/install: $($DCU_analyze.updates.update.name)"
                    Exit 1
                }
            
            
            }
            else {
                Write-Error "DELL Command Update missing"
                Exit 1
            }
        } 
        Catch {
            Write-Error $_.Exception
            Exit 1
        }
    }


    function update {
        try {
            Start-Process $DCU_exe -ArgumentList "/applyUpdates -silent -reboot=enable -updateType=$DCU_category -outputlog=$DCU_report_log" -Wait
            Write-Output "Installation completed"
        }
        catch {
            Write-Error $_.Exception
        }
    }

    function DellCommandUpdateRun {
        detect
        update
    }
    DellCommandUpdateRun
}
Function RunForestRun {
    Function Log {
        Write-Log -message "#########"
        Write-Log -message "Initialization in Progress..."
        Write-Log -message "System configuration underway..."    
    }
    Log
    Write-Output "This script is from the $Branch branch and is version $version"
    Write-Output "The user will be locked out of the loaner on $LoanerUseByDate"
    & $PragueCheck
    & $UserRemake
    & $PreLoginSetup
    & $DellUpdates
}
RunForestRun
