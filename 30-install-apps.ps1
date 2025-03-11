# CONSTANTS
$REPO_NAME = "public"
$GITHUB_REPO = "https://github.com/abwesendkr/public.git"
#$GITHUB_REPO = "https://crmestorageglobal.blob.core.windows.net/repo/repo.tar.gz"
$scriptPathroot = "C:\scripts2"
$repofile = Join-Path -path $scriptPathroot -ChildPath "repo.tar.gz"  

# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[FATAL] You need to run this script as Administrator!Exiting script." -ForegroundColor Red
    exit 1
}

# Load Git repo
if (-not(Test-Path ".\$REPO_NAME")) {
    & git clone $GITHUB_REPO
}

if (-not(Test-Path ".\$scriptPathroot")) {
    New-Item $scriptPathroot -ItemType Directory -Force
}

#"20.209.77.161 crmestorageglobal.blob.core.windows.net" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding UTF8 -Append
#Invoke-WebRequest $GITHUB_REPO -OutFile $repofile
#Set work location
Set-Location $scriptPathroot

#expand archive:
#tar -xvzf $repofile
Write-Host "Cloned this:"
tree /f

#Copy Config files
Copy-Item .\config C:\ -Recurse -Force

#Make Functions system wide accessible after reboot for all users
$functionsfolder = "C:\windows\System32\WindowsPowerShell\v1.0\Modules\functions\"
if (-not(Test-Path $functionsfolder)) {
    New-Item $functionsfolder -ItemType Directory -Force
}
Copy-Item .\functions.psm1 C:\windows\System32\WindowsPowerShell\v1.0\Modules\functions\functions.psm1 -Recurse -Force

# Import functions module
Import-Module "./functions.psm1"

# Parse JSON file

try {
    $region = Read-Region
<#    $region = [System.Environment]::GetEnvironmentVariable("region", [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Try to read set 'region': $($region)"
#>
    if (-not [string]::IsNullOrWhiteSpace($region)) {
        $Apps = Get-Content -Path "./apps-$($region).json" -Raw | ConvertFrom-Json
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
    $InstallStatusTable += Create-LogElement -App $App -exitcode $exitcode
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
