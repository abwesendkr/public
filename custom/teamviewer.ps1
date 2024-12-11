#############################
##### Config Teamviewer #####
#############################

$App = "Teamviewer"
$MsiUrl = "space"
$TempFolderPath = "C:\Temp"
$MsiPath = "$TempFolderPath\Teamviewer.msi"
$AssignmentID = "0001CoABChAuA1PAHNAR75DmQRs6vN3rEigIACAAAgAJALtw9S-phXRtsEWayIQsr9hqghaNnMXUKFbc6qeVXR0qGkCNSOddkNoXXCSBYSbdbwqZNykVn-qLicMC26NWB1uhgrT7dJSwQPhnCueq8vLIYg28aai9avB0PSMhL65vJ4PHIAEQlYWS9wo="
$Switches = "/qn CUSTOMCONFIGID=$($AssignmentID) NORESTART=1 "

#############################
### Installing Teamviewer ###
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
