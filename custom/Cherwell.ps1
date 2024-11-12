$App = "Cherwell 10.1.4"
$MsiUrl = "https://ibktangaalt.ydns.eu/upload/data/Cherwell%20Client_10.1.4.msi"
$ConfigUrl = "https://ibktangaalt.ydns.eu/upload/data/Connections.xml"
$TempFolderPath = "C:\Temp"
$ConfigFolder = "$env:ProgramData\Trebuchet"
$MsiPath = "$TempFolderPath\Cherwell_Client_10.1.4.msi"
$ConfigPath = "$TempFolderPath\Connections.xml"

###################
### Test Begin ####
###################
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
Write-Host "Cloned this:"
tree /f

#Copy Config files
Copy-Item .\config C:\ -Recurse -Force

# Import functions module
Import-Module "./functions.psm1"

##################
#### Test End ####
##################

if (!(Test-Path $TempFolderPath)) {
    mkdir $TempFolderPath
}

# Import functions
Import-Module -name ".\functions.psm1"

# Load Powershell
Write-Host "Attempting to load files from $MsiUrl and $ConfigUrl to $MsiPath"
if (-not(Test-Path $MsiPath)) {
    Load-WebFile $MsiUrl $MsiPath
    Load-WebFile $ConfigUrl $ConfigPath
}

# Install Powershell
$Switches = "REBOOT=ReallySuppress /QN ALLUSERS=1 INSTALLLEVEL=1"
Write-Host "Installing $App"

try {
    Start-Process -Wait -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i", "$MsiPath", "$Switches"
}
catch {
    Write-Host "[ERROR] Error installing $($App): $_"
    throw $_
}
Write-Host "[INFO] Move $ConfigPath to $env:ProgramData\Trebuchet"
if (!(Test-Path $ConfigFolder)) {
    mkdir $ConfigFolder
}
Copy-Item -Path "$ConfigPath" -Destination "$ConfigFolder\Connections.xml"
Write-Host "[INFO] $($App) installed successfully"
