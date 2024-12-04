$App = "Cherwell 10.1.4"
$MsiUrl = "https://ibktangaalt.ydns.eu/upload/data/Cherwell%20Client_10.1.4.msi"
$ConfigUrl = "https://ibktangaalt.ydns.eu/upload/data/Connections.xml"
$TempFolderPath = "C:\Temp"
$ConfigFolder = "$env:ProgramData\Trebuchet"
$MsiPath = "$TempFolderPath\Cherwell_Client_10.1.4.msi"
$ConfigPath = "$TempFolderPath\Connections.xml"

if (!(Test-Path $TempFolderPath)) {
    mkdir $TempFolderPath
}

# Import functions
Import-Module -name ".\functions.psm1"

# Load Powershell
Write-Host "[Info] Attempting to load files from $MsiUrl and $ConfigUrl to $MsiPath"
if (-not(Test-Path $MsiPath)) {
    Load-WebFile $MsiUrl $MsiPath
    Load-WebFile $ConfigUrl $ConfigPath
}

# Install Powershell
$Switches = "REBOOT=ReallySuppress /QN ALLUSERS=1 INSTALLLEVEL=1"
Write-Host "[Info] Installing $App"

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
