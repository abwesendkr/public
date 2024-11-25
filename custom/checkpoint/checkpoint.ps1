$App = "Checkpoint"
$MsiUrl = "https://ibktangaalt.ydns.eu/upload/data/CheckPointMobileAgent.msi"
$TempFolderPath = "C:\Temp"
$MsiPath = "$TempFolderPath\Checkpoint64.msi"

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
$Switches = "/quiet /norestart"
Write-Host "Installing $App"

try {
    Start-Process -Wait -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i", "$MsiPath", "$Switches"
}
catch {
    Write-Host "[ERROR] Error installing $($App): $_"
    throw $_
}
##extradownloads:
$MsiUrl = "https://ibktangaalt.ydns.eu/upload/data/extender.cab"
$TempFolderPath = "C:\Temp"
$MsiPath = "$TempFolderPath\extender.cab"
# Load Powershell
Write-Host "Attempting to load file from $MsiUrl to $MsiPath"
if (-not(Test-Path $MsiPath)) {
    Load-WebFile $MsiUrl $MsiPath
}

# Install Powershell
$Switches = "-norestart"
Write-Host "Installing $MsiPath"

try {
    Add-WindowsPackage -Online -PackagePath "$MsiPath" -NoRestart
}
catch {
    Write-Host "[ERROR] Error installing $($MsiPath): $_"
    throw $_
}
$MsiUrl = "https://ibktangaalt.ydns.eu/upload/data/SNX.cab"
$TempFolderPath = "C:\Temp"
$MsiPath = "$TempFolderPath\SNX.cab"
# Load Powershell
Write-Host "Attempting to load file from $MsiUrl to $MsiPath"
if (-not(Test-Path $MsiPath)) {
    Load-WebFile $MsiUrl $MsiPath
}

# Install Powershell
$Switches = "/quiet /norestart"
Write-Host "Installing $MsiPath"

try {
    Add-WindowsPackage -Online -PackagePath "$MsiPath" -NoRestart
}
catch {
    Write-Host "[ERROR] Error installing $($MsiPath): $_"
    throw $_
}
$MsiUrl = "https://ibktangaalt.ydns.eu/upload/data/jdk-17_windows-x64_bin.msi"
$TempFolderPath = "C:\Temp"
$MsiPath = "$TempFolderPath\jdk-17_windows-x64_bin.msi"
# Load Powershell
Write-Host "Attempting to load file from $MsiUrl to $MsiPath"
if (-not(Test-Path $MsiPath)) {
    Load-WebFile $MsiUrl $MsiPath
}

# Install Powershell
$Switches = "/quiet /norestart"
Write-Host "Installing $MsiPath"

try {
    Start-Process -Wait -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i", "$MsiPath", "$Switches"
}
catch {
    Write-Host "[ERROR] Error installing $($MsiPath): $_"
    throw $_
}

Write-Host "[INFO] $($App) installed successfully"
