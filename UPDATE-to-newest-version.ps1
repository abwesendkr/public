###############
#### INPUT ####
###############

### run install-packagemgr before and open a new powershell!
$Appjson = "apps-africa-single.json"

###############
#### CODE #####
###############


# Parse JSON file
try {
    $Apps = Get-Content -Path $Appjson -Raw | ConvertFrom-Json
}
catch {
    Write-Host "[FATAL] Failed to load apps.json, error message: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
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

Import-Module "./functions.psm1"

# Set counters for successful installation
$TotalAppCount = $Apps.Count
$SuccessfulAppCount = $TotalAppCount
$SuccessfulMandatoryAppCount = 0
$InstallStatusTable = @()

# Loop through each app and install it
for ($i = 0; $i -lt $Apps.Count; $i++) {
    $App = $Apps[$i]
    if ($App.mandatory -eq "yes") {
        $SuccessfulMandatoryAppCount += 1
    }
    Write-Host "Update $($App.name)..." -ForegroundColor Green
    try {
        Update-AppVersionToLatest($App)
        $InstallStatus = Create-LogElement -App $App -Success $true  
        $InstallStatusTable += $InstallStatus
    }
    catch {
        Write-Host "Encountered error: $_"
        $InstallStatusTable += Create-LogElement -App $App -Success $false  
        $SuccessfulAppCount -= 1
        if ($App.mandatory -eq "yes") {
            $SuccessfulMandatoryAppCount -= 1
        }        
    }
}
 
$Apps | ConvertTo-Json | Out-File -FilePath $Appjson