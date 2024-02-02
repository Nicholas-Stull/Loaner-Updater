$DCU_folder = "C:\Program Files (x86)\Dell\CommandUpdate"
$DCU_report = "C:\Temp\Dell_report"
$DCU_report_log = "C:\Temp\Dell_report\update.log"
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
<# 

function update {
    try {
        Start-Process $DCU_exe -ArgumentList "/applyUpdates -silent -reboot=disable -updateType=$DCU_category -outputlog=$DCU_report_log" -Wait
        Write-Output "Installation completed"
    }
    catch {
        Write-Error $_.Exception
    }
}
#>
