$msiUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.5/PowerShell-7.4.5-win-x64.msi"
$path = "C:\Temp"
$msiPath = "$path\PowerShell-7.4.5-win-x64.msi"
$app = "powershell7" #enter package name from https://community.chocolatey.org/packages
$logPath = "C:\ProgramData\Kapsch\ImageBuilding\$($app)"
$installFlag = "$($logPath)\$($app)_installed.txt"

#Start logging in $logpath
if(!(Test-Path $logPath))
{
    mkdir $logPath
}
Start-Transcript -Path "$($logPath)\$($app)_Install.log" -Verbose


# Download PowerShell 7 MSI file
if(!(Test-Path $path))
{
    mkdir $path
}
if(!(Test-Path $msiPath))
{
	Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath
}

# Install PowerShell 7 silently
$muiLang = "en-US" # adjust to your desired language
$switches = "/quiet /norestart"
Start-Process -Wait -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i", $msiPath, "/quiet /norestart"
if($LASTEXITCODE -ne 0)
    {
        $message = $_
        Write-Host "Error installing $($app): $message"
	exit 0 #fails the whole build process
#        exit 1
    }
else 
{
    Write-Host "$($app) updated successfully"
    New-Item $installFlag -Force
}
Stop-Transcript
