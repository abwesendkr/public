Set-Location $PSScriptRoot
$scriptPathroot = "C:\scripts"
if (-not(Test-Path ".\$scriptPathroot")) {
    New-Item $scriptPathroot -ItemType Directory -Force
}



## First script:
$orignalpath = Join-Path -path (get-location).Path -ChildPath "Add-AdminsToFSLogixExcludeList.ps1"  
Copy-Item $orignalpath -Destination "c:\scripts\Add-AdminsToFSLogixExcludeList.ps1" -Force
$scriptPath = "c:\scripts\Add-AdminsToFSLogixExcludeList.ps1"


## Second script:
$orignalpath2 = Join-Path -path (get-location).Path -ChildPath "Set-FSLogix-VHDLocations-set-to-staging.ps1"  
Copy-Item $orignalpath2 -Destination "c:\scripts\Set-FSLogix-VHDLocations-set-to-staging.ps1" -Force
$scriptPath2 = "c:\scripts\Set-FSLogix-VHDLocations-set-to-staging.ps1"
$scriptPath2 = $FilePath

#Write-Host "Add $scriptPath to run each reboot"


# Create a scheduled task to run the script at startup
$taskAction = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -File $scriptPath"
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Write-Host "[INFO] Add ""$($taskAction.Execute) $($taskAction.Arguments)"" to run each reboot"
Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings -TaskName "Add Admins to FSLogix Exclude List" -User "SYSTEM" -RunLevel Highest

# Create a scheduled task to run the script at startup
$taskAction = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -File $scriptPath2"
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Write-Host "[INFO] Add ""$($taskAction.Execute) $($taskAction.Arguments)"" to run each reboot"
Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings -TaskName "Set FSLogix Paths for Environments" -User "SYSTEM" -RunLevel Highest

# Create a scheduled task to run the script at startup
$taskAction = New-ScheduledTaskAction -Execute "msiexec.exe" -Argument "/i c:\temp\wsl_update_x64.msi /quiet"
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Write-Host "[INFO] Add ""$($taskAction.Execute) $($taskAction.Arguments)"" to run each reboot"
Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings -TaskName "Install WSL-kernel-update on startup" -User "SYSTEM" -RunLevel Highest

Write-Host "[INSTALLED] Scheduled Tasks"

