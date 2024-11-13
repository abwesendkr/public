Set-Location $PSScriptRoot
$scriptPath = Join-Path -path (get-location).Path -ChildPath "Add-AdminsToFSLogixExcludeList.ps1"  
Write-Host "Add $scriptPath to run each reboot"
# Create a scheduled task to run the script at startup
$taskAction = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -File $scriptPath"
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings -TaskName "Add Admins to FSLogix Exclude List" -User "SYSTEM" -RunLevel Highest
