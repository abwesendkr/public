#############################
##### Config Fortigate ######
#############################

<#
how to get to newest version:
1. original download and start: https://links.fortinet.com/forticlient/win/vpnagent
2. go to C:\ProgramData\Applications\Cache and search in subfolders for correct forticlientVPN.msi.
3. upload it to MSI url below
4. change MSI-Path
#>

$App = "FortigateVPN"
$MsiUrl = "https://ibktangaalt.ydns.eu/upload/data/FortiClientVPN.msi"
$TempFolderPath = "C:\Temp"
$MsiPath = "$TempFolderPath\Fortinet-7.4.2.1737.msi"
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
