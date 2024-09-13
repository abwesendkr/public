#############
# writen by Benno Kronawitter, with help from:
# https://github.com/stevecapacity/IntunePowershell/blob/main/Chocolatey%20scripts/choco.ps1
# https://www.youtube.com/watch?v=ghSa--QMZXQ
###########

#!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!
#
# Check Install folder, choco folder will be removed (c:\programdata\choco*) 
# e.g. putty is only portable, so use putty.install
#!!!!!!!!!!!!!!!!!!!!!!

# version v0.1.0
# changlog below

#########
# Input #
#########

$app = "vlc" #enter package name from https://community.chocolatey.org/packages
$version = "3.0.21" #version
$installArgumentsstring = "INSTALLSTRING" #set $null if not in use
$logPath = "C:\ProgramData\Kapsch\ImageBuilding\$($app)"
$keepchoco = $False
$installFlag = "$($logPath)\$($app)_installed.txt"

########
# Code #
########

#Start logging in $logpath
if(!(Test-Path $logPath))
{
    mkdir $logPath
}
Start-Transcript -Path "$($logPath)\$($app)_Install.log" -Verbose

#Check if chocolatey is installed
$choco = "C:\ProgramData\chocolatey"
Write-Host "Checking if Chocolatey is installed on $($env:COMPUTERNAME)..."
if(!(Test-Path $choco))
{
    Write-Host "Chocolatey not found; installing now..."
    try 
    {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Write-Host "Chocolatey was successfully installed."            
    }
    catch 
    {
        $message = $_
        Write-Host "Error installing Chocolatey: $message"
    }
}
else
{
    Write-Host "Chocolatey is installed."
}

#set arguments string
$arguments = ""
if($version -ne "latest") {
    $arguments += "--version $version"
    }
if($installArgumentsstring -ne "INSTALLSTRING") {
    $arguments += " --install-arguments=""$installArgumentsstring"""
    }

#Check for app and install
Write-Host "Running choco-upgrade"
Write-Host "Checking if $($app) is installed on $($env:COMPUTERNAME)..."
$installed = Start-Process -Wait -FilePath "$($choco)\choco.exe" -ArgumentList "list" | Select-String $app
if($installed -eq $null)
{
    if($arguments -eq $null)
    {
        Write-Host "$($app) not detected; installing now..."
#        Start-Process -Wait -FilePath "$($choco)\choco.exe" -ArgumentList "install $($app) -y"
        & $choco\choco.exe install $app -y
        if($LASTEXITCODE -ne 0)
        {
            $message = $_
            Write-Host "Error installing $($app): $message"
            exit 1
        }
        else 
        {
            Write-Host "$($app) installed successfully"
            New-Item $installFlag -Force
        }
    }
    else
    {
        Write-Host "$($app) not detected; installing with Arguments $($arguments) now..."
        #Start-Process -Wait -FilePath "$($choco)\choco.exe" -ArgumentList "install $($app) $arguments) -y"
        & $choco\choco.exe install $app $arguments -y
        if($LASTEXITCODE -ne 0)
        {
            $message = $_
            Write-Host "Error installing $($app): $message"
            exit 1
        }
        else 
        {
            Write-Host "$($app) installed successfully"
            New-Item $installFlag -Force
        }
    }
}
else
{
    Write-Host "$($app) already installed.  Updating to latest version..."
    Start-Process -Wait -FilePath "$($choco)\choco.exe" -ArgumentList "upgrade $($app) -y"
    if($LASTEXITCODE -ne 0)
    {
        $message = $_
        Write-Host "Error installing $($app): $message"
        exit 1
    }
    else 
    {
        Write-Host "$($app) updated successfully"
        New-Item $installFlag -Force
    }
}


#uninstall choco after install
if($keepchoco -eq $False)
{
    $path = $env:ChocolateyInstall + "\bin\choco.exe"
    & $path uninstall chocolatey -y
    Remove-Item -Recurse -Force C:\ProgramData\chocolatey*
    #remove folder
    Write-Host "copied logs, deleted choco folders"
    [System.Environment]::SetEnvironmentVariable('ChocolateyInstall', $null, 'Machine')
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') -replace ';C:\\ProgramData\\chocolatey\\bin', ''
    [System.Environment]::SetEnvironmentVariable('Path', $env:Path, 'Machine')
}

Stop-Transcript

# v0.9.2
# added uninstal wmi object solution

# v0.9.1
# changed 
# intune: 
# -%WINDIR%\sysnative\WindowsPowershell\v1.0\powershell.exe -executionpolicy bypass -file .\0-install-general.ps1 7zip
# +%WINDIR%\sysnative\WindowsPowershell\v1.0\powershell.exe -executionpolicy bypass -command {}.\0-install-general.ps1 7zip}
