# CONSTANTS
$REPO_NAME = "public"
$GITHUB_REPO = "https://github.com/abwesendkr/public.git"

# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[FATAL] You need to run this script as Administrator!Exiting script." -ForegroundColor Red
    exit 1
}

# Load Git repo
if (-not(Test-Path ".\$REPO_NAME")) {
    git clone $GITHUB_REPO
}

#Set work location
Set-Location $REPO_NAME

#Copy Config files
Copy-Item .\public\config C:\ -Recurse -Force

# Import functions module
Import-Module "./functions.psm1"

# Parse JSON file
try {
    $Apps = Get-Content -Path "./apps.json" -Raw | ConvertFrom-Json
}
catch {
    Write-Host "[FATAL] Failed to load apps.json, error message: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Set counters for successful installation
$TotalAppCount = $Apps | Measure-Object | Select-Object -ExpandProperty Count
$SuccessfulAppCount = $TotalAppCount
$InstallStatusTable = @()


# Loop through each app and install it
for ($i = 0; $i -lt $Apps.Count; $i++) {
    $App = $Apps[$i]
    Write-Host "Installing $($App.name)..." -ForegroundColor Green
    if ($App.installType -eq 'choco') {
        try {
            Install-WithChoco($App)
            $InstallStatus = Create-LogElement -App $App -Success $true  
            $InstallStatusTable += $InstallStatus
        }
        catch {
            Write-Host "Encountered error: $_"
            $InstallStatusTable += Create-LogElement -App $App -Success $false  
            $SuccessfulAppCount -= 1
        }
    }
    else {
        try {
            powershell.exe -File $App.customInstallScript
            $InstallStatusTable += Create-LogElement -App $App -Success $true  
        } 
        catch {
            Write-Host "Encountered error: $_"
            $InstallStatusTable += Create-LogElement -App $App -Success $false  
            $SuccessfulAppCount -= 1
        }
    }
}

# Move back to root folder
Set-Location ".."

# Log the status table
Write-Host "[INFO] Successfully installed $($SuccessfulAppCount)/$($TotalAppCount) applications."
$InstallStatusTable | Format-Table -AutoSize

# Uninstall Chocolatey
Uninstall-Chocolatey

#check if winget is installed:
$winget_exe = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
Write-Host "Winget Path found: $($winget_exe)"
$wingetcommand = Get-Command winget
write-host "winget-command: $($wingetcommand)"

if ($SuccessfulAppCount -lt $TotalAppCount) {
    Write-Host "[FATAL] Not all apps were installed successfully, failing script."  -ForegroundColor Red
    exit 1
}
