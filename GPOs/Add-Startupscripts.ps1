Set-Location $PSScriptRoot
$Url = "https://raw.githubusercontent.com/abwesendkr/public/refs/heads/main/GPOs/Add-AdminsToFSLogixExcludeList.ps1"
$scriptPath = Join-Path -path (get-location).Path -ChildPath "Add-AdminsToFSLogixExcludeList.ps1"  

Write-Host "Installing Startupscript..." -ForegroundColor Green
try {
    Write-Host "Downloading from Url: $Url"
    Invoke-WebRequest -Uri $Url -OutFile $scriptPath -ErrorAction Stop
    Write-Host "Downloaded: $scriptPath"
}
catch {
    Write-Host "Error downloading $scriptPath from $Url" -ForegroundColor Red
    throw "Error: $_"
}

Write-Host "Add $scriptPath to run each reboot"

# Create a scheduled task to run the script at startup
$taskAction = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -File $scriptPath"
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings -TaskName "Add Admins to FSLogix Exclude List" -User "SYSTEM" -RunLevel Highest

Write-Host "Add msiexec.exe /i c:\temp\wsl_update_x64.msi /quiet to run each reboot"

# Create a scheduled task to run the script at startup
$taskAction = New-ScheduledTaskAction -Execute "msiexec.exe" -Argument "/i c:\temp\wsl_update_x64.msi /quiet"
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings -TaskName "Install WSL-kernel-update on startup" -User "SYSTEM" -RunLevel Highest

