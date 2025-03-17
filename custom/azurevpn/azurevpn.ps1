# azurevpn.ps1
# Silent installer for Azure VPN on Windows 11

# Define the URL for the Azure VPN client installer
#$installerUrl = "https://aka.ms/azvpnclientdownload"

# Define the path to download the installer
#$installerPath = "$env:TEMP\AzureVpnClientInstaller.exe"

# Download the installer
#Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

Write-Output "[INFO] Azure VPN client installing"

$installerPath = "AzVpnAppx_3.3.1.0.7z"
# Install the Azure VPN client silently
Start-Process -FilePath $installerPath -ArgumentList "/quiet" -Wait


Write-Output "[INFO] Azure VPN client installed successfully."