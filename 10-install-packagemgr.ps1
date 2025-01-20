# Enable TLS 1.2 (required for connecting to Chocolatey repository)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[FATAL] You need to run this script as Administrator! Exiting script." -ForegroundColor Red
    exit 1
}
#############
# Functions #
#############
function Install-Chocolatey {

    if (Test-Path "C:\ProgramData\chocolatey") {
        Remove-Item -Path "C:\ProgramData\chocolatey" -Recurse -Force
    }

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Chocolatey..." -ForegroundColor Green
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
        try {
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            Write-Host "Chocolatey installation completed." -ForegroundColor Green
        }
        catch {
            Write-Host "[FATAL] Failed to install Chocolatey. Exiting script." -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host "Chocolatey is already installed." -ForegroundColor Yellow
    }
}
function Install-Wingetpowershell {
    Write-Host "Attempting to install winget Powershellmodules Microsoft.WinGet.Client..."

    try {
        # Überprüfen, ob das Modul Microsoft.Winget.Client installiert ist
        if (-not (Get-Module -Name Microsoft.Winget.Client)) {
            Write-Host "Microsoft.WinGet.Client is not installed. Register..."

            # Registrieren des Standard-PSRepositories
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$False -Scope AllUsers
            Register-PSRepository -Default -Verbose -ErrorAction SilentlyContinue
            Write-Host "Set-PSRepository..."
            
            # Setzen des InstallationPolicy auf Trusted
            Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted" -Verbose
            Write-Host "Set-ExecutionPolicy..."
            
            # Setzen der Execution Policy auf RemoteSigned
            #Set-ExecutionPolicy -ExecutionPolicy "RemoteSigned" -Force -Verbose -ErrorAction SilentlyContinue
            Write-Host "Install-Module..."
            
            # Installieren des Moduls PowerShellGet
            Install-Module -Name Microsoft.WinGet.Client -Force -Scope AllUsers -Verbose
            Get-Module
        } else {
            Write-Host "Microsoft.WinGet.Client is already installed."
        }
    } catch {
        # Fehlerbehandlung
        Write-Host "An error occurred: $_"
        Stop-Transcript
        exit 1
    }
}
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
Write-Host "[DEBUG] CMDLets which could be used:"
(Get-Module Microsoft.WinGet.Client).ExportedCommands