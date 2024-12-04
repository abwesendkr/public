$App = "Checkpoint"

#####################
#### Install JDK ####
#####################
$MsiUrl = "https://ibktangaalt.ydns.eu/upload/data/jdk-17_windows-x64_bin.msi"
$TempFolderPath = "C:\Temp"
$MsiPath = "$TempFolderPath\jdk-17_windows-x64_bin.msi"

# create folder if needed
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
Write-Host "Installing $MsiPath"
try {
    Start-Process -Wait -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i", "$MsiPath", "$Switches"
}
catch {
    Write-Host "[ERROR] Error installing $($MsiPath): $_"
    throw $_
}
#####################
#### Install SNX ####
#####################
$MsiUrl = "https://ibktangaalt.ydns.eu/upload/data/SNXComponentsShell.msi"
$TempFolderPath = "C:\Temp"
$MsiPath = "$TempFolderPath\SNXComponentsShell.msi"
# Load Powershell
Write-Host "Attempting to load file from $MsiUrl to $MsiPath"
if (-not(Test-Path $MsiPath)) {
    Load-WebFile $MsiUrl $MsiPath
}

# Install Powershell
$Switches = "/quiet /norestart ALLUSERS=1"
Write-Host "Installing $MsiPath"
try {
    Start-Process -Wait -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i", "$MsiPath", "$Switches"
}
catch {
    Write-Host "[ERROR] Error installing $($MsiPath): $_"
    throw $_
}
##########################
#### Install extender ####
##########################
$MsiUrl = "https://ibktangaalt.ydns.eu/upload/data/cpextender.msi"
$TempFolderPath = "C:\Temp"
$MsiPath = "$TempFolderPath\cpextender.msi"
# Load Powershell
Write-Host "Attempting to load file from $MsiUrl to $MsiPath"
if (-not(Test-Path $MsiPath)) {
    Load-WebFile $MsiUrl $MsiPath
}

# Install Powershell
$Switches = "/quiet /norestart ALLUSERS=1"
Write-Host "Installing $MsiPath"
try {
    Start-Process -Wait -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i", "$MsiPath", "$Switches"
}
catch {
    Write-Host "[ERROR] Error installing $($MsiPath): $_"
    throw $_
}
#####################
#### Install App ####
#####################
$MsiUrl = "https://ibktangaalt.ydns.eu/upload/data/CheckPointMobileAgent.msi"
$TempFolderPath = "C:\Temp"
$MsiPath = "$TempFolderPath\Checkpoint64.msi"

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
