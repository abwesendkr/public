## Based on solution from https://serverfault.com/a/725385

## Read env variables and save them in a file
$region = [System.Environment]::GetEnvironmentVariable('region', [System.EnvironmentVariableTarget]::Machine)
$environment = [System.Environment]::GetEnvironmentVariable('environment', [System.EnvironmentVariableTarget]::Machine)
$currentPath = $PSScriptRoot
$bginfoPath = $currentPath+"\Bginfo.exe"
$bginfoConfigPath = $currentPath+"\defi.bgi"
$bginfoShortcutPath = $currentPath+"\Bginfo-Shortcut.lnk"

$filePath = "C:\Temp\region.txt"

# Write the value to the file
"Region:        " + $region | Out-File -FilePath $filePath -Encoding UTF8
"Environment:   " + $environment | Out-File -FilePath $filePath -Encoding UTF8 -Append

# Move files to BGInfo folder in scripts
if (-not(Test-Path "c:\scripts\bginfo")) {
    New-Item -ItemType Directory -Path "c:\scripts\bginfo" -Force
}
Copy-Item $bginfoPath -Destination "c:\scripts\bginfo\Bginfo.exe" -Force
Copy-Item $bginfoConfigPath -Destination "c:\scripts\bginfo\defi.bgi" -Force
Copy-Item $bginfoShortcutPath -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\Bginfo-Shortcut.lnk" -Force