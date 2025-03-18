# azurevpn.ps1
# Silent installer for Azure VPN on Windows 11

# Define the URL for the Azure VPN client installer
#$installerUrl = "https://aka.ms/azvpnclientdownload"

# Define the path to download the installer
#$installerPath = "$env:TEMP\AzureVpnClientInstaller.exe"

# Download the installer
#Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

Write-Output "[INFO] Azure VPN client extracting"
$zipFilePath = "AzVpnAppx_3.3.1.0.7z"

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
