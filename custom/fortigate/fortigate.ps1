#############################
##### Config Fortigate ######
#############################

$App = "FortigateVPN"
$MsiUrl = "https://ibktangaalt.ydns.eu/upload/data/FortiClient.msi"
$TempFolderPath = "C:\Temp"
$MsiPath = "$TempFolderPath\Fortinet-7.4.0.1658.msi"
$Switches = "/quiet /norestart"

#############################
#### Install Fortigate ######
#############################

if (!(Test-Path $TempFolderPath)) {
    mkdir $TempFolderPath
}

# Import functions
Import-Module -name ".\functions.psm1"

# Load Powershell
Write-Host "Attempting to load file from $MsiUrl to $MsiPath"
if (-not(Test-Path $MsiPath)) {
    Load-WebFile $MsiUrl $MsiPath
}

# Install Powershell
Write-Host "Installing $App"

try {
    Start-Process -Wait -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i", "$MsiPath", "$Switches"
}
catch {
    Write-Host "[ERROR] Error installing $($App): $_"
    throw $_
}
Write-Host "[INFO] $($App) installed successfully"
