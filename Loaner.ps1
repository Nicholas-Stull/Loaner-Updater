<#
.SYNOPSIS
    LoanerTimeout.ps1 - A script for updating loaners for the next semester

.DESCRIPTION
    This script updates loaners to be sent out for the next semester. It essentially performs a wipe.

.AUTHOR
    Nick Stull (https://www.github.com/nicholas-stull)

.DATE
    Creation Date:  
.RESOURCES
New-LocalUser - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/new-localuser?view=powershell-5.1
Remove-LocalUser - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/remove-localuser?view=powershell-5.1
Add-GroupMember - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/add-localgroupmember?view=powershell-5.1
.NOTES
    Version:        1.0
    Prerequisites:  PowerShell 5.1
    Purpose/Change: This script was created to automate the process of updating loaners for the next semester.
    Check next Visit/Change:
    2. Clean up and organzie script. Including Typos. 
        - Will do at some point. Will need to block it up and clean it up.
    3. Fix F&S Connection - Virt Router? Rasap? Or People just Connect computer to F&S When Login before running Script?
    4. Reseach more into Dell Command Update - https://www.reddit.com/r/sysadmin/comments/12jpdcr/dell_command_update/

#>

# Script starts here
# Parameters
$VerbosePreference = "Continue"

# change date here for when the loaner is to be locked by.
$LoanerUseByDate = Get-Date -Year 2024 -Month 01 -Day 24 -Hour 14 -Minute 45 -Second 00
$LoanerUseByDateString = $LoanerUseByDate.ToString("yyyy-MM-ddTHH:mm:ss")

# Loaner User Variables
$LoanerUser = "smcloaner"
$LoanerPass = ConvertTo-SecureString "Smcloaner1" -AsPlainText -Force  # Super strong plane text password here (yes this isn't secure at all)
$LoanerName = "SMC Loaner"
$LoanerDesc = 'Local Account for the SMC loaners' 
$LoanerGroup = "Users"

# Log Variables
$timestamp = (Get-Date).toString("yyyy_MM_dd HH:mm:ss")
$LogFileName = "Loaner_Log_" + (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss") + "_log.txt"
$logFile = "d:\logfiles\$LogFileName"
$logDir = "d:\logfiles"
$CompName = "$env:COMPUTERNAME"

# Task Scheduler Variables
$PassoutFilePath = "C:\Users\Administrator\Documents\Loaner Password Timeout.bat"
$action = New-ScheduledTaskAction -Execute $PassoutFilePath
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
$trigger = New-ScheduledTaskTrigger -Once -At $LoanerUseByDateString
$taskName = "LoanerTimeout"
$taskDescription = "This task is for changing the password on the loaner computer."

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
        New-Item -Path "d:\" -Name "logfiles" -ItemType "directory"
    }

    Add-Content -Path $logFile -Value "[$CompName] - $timestamp [$level] - $line $LineNumber - $message"
}
$LukeUseTheForce = {
    # Define the Wi-Fi network name
    $networkName = "Faculty & Staff"

    # Check if connected to the specified network
    $connectedToNetwork = (netsh wlan show interfaces) -match "SSID\s+:\s+$networkName"

    if (-not ($connectedToNetwork)) {
        # Remove Wi-Fi profile

        # Prompt user for new credentials
        $username = Read-Host "Enter your Wi-Fi username"
        $password = Read-Host -AsSecureString "Enter your Wi-Fi password"

        # Connect to Wi-Fi network with new credentials
        netsh wlan add profile filename="$networkName.xml" interface="Wi-Fi"
        netsh wlan connect name="$networkName" user="$username" keyMaterial=(ConvertFrom-SecureString $password -AsPlainText)
    }

}
$CipherShift = {
    Function PassoutFile {
        if (-not (Test-Path -Path $PassoutFilePath)) { # checks to see if the file exists. If it does not, it creates it.
            # File does not exist
            Write-Verbose "File does not exist. Creating and adding text."
            Write-Log -message "File does not exist. Creating and adding text."
            New-Item -Path $PassoutFilePath -ItemType File | Out-Null
            Add-Content -Path $PassoutFilePath -Value "@echo off" | Add-Content -Path $PassoutFilePath -Value ""
            Add-Content -Path $PassoutFilePath -Value "net user smcloaner 5MC256*Xc!" | Add-Content -Path $PassoutFilePath -Value ""
            Add-Content -Path $PassoutFilePath -Value "exit"
            Write-Verbose "Password batch file created."
        }
        else {
            # File already exists
            Write-Verbose "File already exists."
        }
    }
    PassoutFile
    Write-Verbose "Deleting LoanerTimeout and updating Date/Time"
    Unregister-ScheduledTask -TaskName LoanerTimeout -Confirm:$false
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description $taskDescription -Settings $settings -RunLevel Highest -Force
}
$UserRemake = { # This function is used to create the loaner user and delete the old one. Used to be called UserSwap
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
    Function RunUserRemake {
        delete_loaneruser
        create_loaneruser
    }
    RunUserRemake
}
$DellUpdates = {
    Write-Verbose "Starting Dell Updates...."
    $file = "C:\PROGRAM FILES\Dell\CommandUpdate\dcu-cli.exe"
    $schedule = "/configure -scheduleMonthly=06,23:00 -userConsent=disable -autoSuspendBitLocker=enable -outputLog=c:\temp\dell.log -silent"
    $command = "/applyUpdates -autoSuspendBitLocker=enable -reboot=enable -outputLog=c:\temp\dell.log -silent"
    $base = "/driverinstall -silent"
    If (!(test-path -PathType Container "c:\temp")) {
        New-Item -ItemType Directory -Path "c:\temp"
    }
    if ([System.IO.File]::Exists($file)) {
        Start-Process -FilePath $file -ArgumentList $schedule
        Start-Process -FilePath $file -ArgumentList $base
        Start-Process -FilePath $file -ArgumentList $command 
        Write-Verbose "Starting Dell updates."
    }
    else {
        Write-Verbose "Dell Command Update not installed"
        exit
    }
}
$WarpCoreUpdate = {
    Write-Verbose "Warp Core Updates Engaged, Please stay clear...."
    Write-Log -message "Warp Core Updates Engaged, Please stay clear"
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
    Install-PackageProvider -Name NuGet -Force
    Import-PackageProvider -Name NuGet
    
    # Update the PSGallery (the Default) PSRepository
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Get-PSRepository -Name PSGallery | Format-List * -Force
    
    # List all modules installed
    Write-Output "Running:  Get-InstalledModule"
    Write-Log -message "Running:  Get-InstalledModule"
    Get-InstalledModule
    
    # Install the module we need
    Write-Output "Running:  Install-Module -Name PSWindowsUpdate -Force"
    Write-Log -message "Running:  Install-Module -Name PSWindowsUpdate -Force"
    Install-Module -Name PSWindowsUpdate -Force
    
    # Import the module
    Import-Module -Name PSWindowsUpdate
    
    # List support commands from the module:
    Get-Command -Module PSWindowsUpdate
    
    # Now, check if the Microsoft Update service is available.
    # If not, we need to add it.
    $MicrosoftUpdateServiceId = "7971f918-a847-4430-9279-4a52d1efe18d"
    If ((Get-WUServiceManager -ServiceID $MicrosoftUpdateServiceId).ServiceID -eq $MicrosoftUpdateServiceId) { 
        Write-Output "Confirmed that Microsoft Update Service is registered...",
        Write-Log -message "Confirmed that Microsoft Update Service is registered..." 
    }
    Else { Add-WUServiceManager -ServiceID $MicrosoftUpdateServiceId -Confirm:$true }
    # Now, check again to ensure it is available.  If not -- fail the script:
    If (!((Get-WUServiceManager -ServiceID $MicrosoftUpdateServiceId).ServiceID -eq $MicrosoftUpdateServiceId)) { Throw "ERROR:  Microsoft Update Service is not registered." }
    Get-WUInstall -MicrosoftUpdate -AcceptAll -AutoReboot 
    Get-WUInstall -MicrosoftUpdate -AcceptAll -Download -Install -AutoReboot
}

Function RunForestRun {
    Function Log {
        Write-Log -message "#########"
        Write-Log -message "Initialization in Progress..."
        Write-Log -message "System configuration underway..."    
    }
    Log
    #& $CipherShift
    #& $LukeUseTheForce
    & $UserRemake
    #& $DellUpdates
    #& $WarpCoreUpdate
}
RunForestRun
