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
    & git clone $GITHUB_REPO
}

#Set work location
Set-Location $REPO_NAME
Write-Host "Cloned this:"
tree /f

#Copy Config files
Copy-Item .\config C:\ -Recurse -Force

# Import functions module
Import-Module "./functions.psm1"

# Parse JSON file
try {
    $readValue = [System.Environment]::GetEnvironmentVariable("region", [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Try to read set 'region': $($readValue)"
    if (-not [string]::IsNullOrWhiteSpace($readValue)) {
        $Apps = Get-Content -Path "./apps-$($readValue).json" -Raw | ConvertFrom-Json
        Write-Host "App.json 'region' read successfull"
    }
}
catch {
    Write-Error "[FATAL] Failed to load apps.json, error message: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Set counters for successful installation
$TotalAppCount = $Apps | Measure-Object | Select-Object -ExpandProperty Count
$SuccessfulAppCount = $TotalAppCount
$SuccessfulMandatoryAppCount = 0
$InstallStatusTable = @()


# Loop through each app and install it
for ($i = 0; $i -lt $Apps.Count; $i++) {
    $App = $Apps[$i]
    if ($App.mandatory -eq "yes") {
        $SuccessfulMandatoryAppCount += 1
    }
    Write-Host "[INSTALLING] $($App.name)..." -ForegroundColor Green
    if ($App.installType -eq 'choco') {
        try {
            $installoutput = Install-WithChoco($App)
            $exitcode = ($installoutput)[-1]
        }
        catch {
            Write-Host "Encountered error: $_"
            $SuccessfulAppCount -= 1
            if ($App.mandatory -eq "yes") {
                $SuccessfulMandatoryAppCount -= 1
            }        
        }
    }elseif ($App.installType -eq 'winget') {
        try {
            $installoutput = Install-WithWingetpowershell7($App)
            $exitcode = ($installoutput).InstallerErrorCode
        }
        catch {
            Write-Host "Encountered error: $_"
            $SuccessfulAppCount -= 1
            if ($App.mandatory -eq "yes") {
                $SuccessfulMandatoryAppCount -= 1
            }        
        }
    }elseif ($App.installType -eq 'winget-5') {
        try {
            Install-WithWingetpowershell($App)
        }
        catch {
            Write-Host "Encountered error: $_"
            $SuccessfulAppCount -= 1
            if ($App.mandatory -eq "yes") {
                $SuccessfulMandatoryAppCount -= 1
            }        
            }
    }
    else {
        try {
            powershell.exe -File $App.customInstallScript
            $exitcode = $LASTEXITCODE
        } 
        catch {
            Write-Host "Encountered error: $_"
            $SuccessfulAppCount -= 1
            if ($App.mandatory -eq "yes") {
                $SuccessfulMandatoryAppCount -= 1
            }        
        }
    }
    $InstallStatus += Create-LogElement -App $App -exitcode $exitcode
}

# Move back to root folder
Set-Location ".."

# Log the status table
Write-Host "[INFO] Successfully installed $($SuccessfulAppCount)/$($TotalAppCount) applications."
$InstallStatusTable | Format-Table -AutoSize

# Uninstall Chocolatey
Uninstall-Chocolatey

if ($SuccessfulAppCount -lt $TotalAppCount) {
    Write-Host "[FATAL] Not all apps were installed successfully, failing script."  -ForegroundColor Red
    exit 1
}
