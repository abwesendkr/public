# Download PowerShell 7 MSI file
$msiUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.5/PowerShell-7.4.5-win-x64.msi"
$msiPath = "C:\Temp\PowerShell-7.2.2-win-x64.msi"
Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath

# Install PowerShell 7 silently
$muiLang = "en-US" # adjust to your desired language
$switches = "/quiet /norestart"
Start-Process -FilePath $msiPath -ArgumentList @($switches, $muiLang) -Wait -NoNewWindow
