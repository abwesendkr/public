# azurevpn.ps1
# Silent installer for Azure VPN on Windows 11

# Define the URL for the Azure VPN client installer
#$installerUrl = "https://aka.ms/azvpnclientdownload"

# Define the path to download the installer
#$installerPath = "$env:TEMP\AzureVpnClientInstaller.exe"

# Download the installer
#Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

##########################################
#### important: ##########################
#### make a comment to last execution in failed:
#### add-appdevpackage.ps1
#### near line 718:
#### PrintMessageAndExit $UiStrings.Success $ErrorCodes.Success
#### so that it will no longer be excuted "press enter to continue"
<#
Write-Output "[INFO] Azure VPN client extracting"
$zipFilePath = Join-Path -Path $PSScriptRoot -ChildPath "AzVpnAppx_3.3.1.0.7z"

# Ensure 7-Zip is installed and accessible
try {
    Write-Host "extract via 7zip"
    & "${env:ProgramFiles}\7-Zip\7z.exe" x $zipFilePath -aoa -r
}
catch {
    try {
        Write-Host "install missing 7zip"
        & choco install 7zip -y --no-progress --ignoredetectedreboot        
        Write-Host "extract via 7zip"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x $zipFilePath -aoa -r

    }
    catch {
        Write-Host "missing 7zip couldn´t be installed"
    }
}

Write-Output "[INFO] Azure VPN client installing"
$installerPath = "AzVpnAppx_3.3.1.0\Install.ps1"
# Install the Azure VPN client silently
try {
#    Start-Process -FilePath $installerPath -ArgumentList "/quiet" -Wait
    AzVpnAppx_3.3.1.0\Install.ps1
    Write-Output "[INFO] Azure VPN client installed successfully."
}
catch {
    Write-Output "[INFO] Azure VPN client installed NOT successfully."
}
#>

# Setze die Gruppenrichtlinie, um den Microsoft Store zu deaktivieren
$regKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
$regName = "RemoveWindowsStore"
$regValue = 0

# Erstelle den Registrierungsschlüssel, wenn er nicht existiert
If (-Not (Test-Path $regKeyPath)) {
    New-Item -Path $regKeyPath -Force
}

# Setze den Wert, um den Store zu deaktivieren
Set-ItemProperty -Path $regKeyPath -Name $regName -Value $regValue

Write-Host "Microsoft Store wurde deaktiviert."
write-host $PSScriptRoot
Import-Module c:\scripts2\public\functions.psm1

$App = [PSCustomObject]@{
    name = "azure vpn client"
    chocoVersion = ""
}


$installoutput = Install-WithWingetpowershell7($App)
$exitcode = ($installoutput).InstallerErrorCode
return $exitcode