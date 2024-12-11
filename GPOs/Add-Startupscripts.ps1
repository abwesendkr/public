Set-Location $PSScriptRoot
$orignalpath = Join-Path -path (get-location).Path -ChildPath "GPOs\Add-AdminsToFSLogixExcludeList.ps1"  
$scriptPathroot = "C:\scripts"
if (-not(Test-Path ".\$scriptPathroot")) {
    echo "hilfe"
    New-Item $scriptPathroot -ItemType Directory -Force
}
$scriptPath = Copy-Item $orignalpath -Destination "c:\scripts\Add-AdminsToFSLogixExcludeList.ps1" -Force

#Write-Host "Add $scriptPath to run each reboot"

# Create a scheduled task to run the script at startup
$taskAction = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -File $scriptPath"
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Write-Host "[INFO] Add ""$($taskAction.Execute) $($taskAction.Arguments)"" to run each reboot"
Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings -TaskName "Add Admins to FSLogix Exclude List" -User "SYSTEM" -RunLevel Highest

# Create a scheduled task to run the script at startup
$taskAction = New-ScheduledTaskAction -Execute "msiexec.exe" -Argument "/i c:\temp\wsl_update_x64.msi /quiet"
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Write-Host "[INFO] Add ""$($taskAction.Execute) $($taskAction.Arguments)"" to run each reboot"
Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings -TaskName "Install WSL-kernel-update on startup" -User "SYSTEM" -RunLevel Highest

Write-Host "[INSTALLED] Scheduled Tasks"

