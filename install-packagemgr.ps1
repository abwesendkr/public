# Enable TLS 1.2 (required for connecting to Chocolatey repository)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[FATAL] You need to run this script as Administrator! Exiting script." -ForegroundColor Red
    exit 1
}
Import-Module "./functions.psm1"

# Install Chocolatey if not already installed
Install-Chocolatey

# Refresh env
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv

# Install git
$GitInstallCommand = "choco install git -y --no-progress"
if ($env:TERM_PROGRAM -eq "vscode") {
    $GitInstallCommand += " --noop"
}
Write-Host "Executing '$($GitInstallCommand)'"
powershell.exe -Command $GitInstallCommand

# Install Powershellmodule Winget
Install-Wingetpowershell

