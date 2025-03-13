$currentPath = $PSScriptRoot
$exepath = $currentPath+"\frxtray.exe"

# Move files to BGInfo folder in scripts
if (-not(Test-Path "c:\scripts\fslogix-tray")) {
    New-Item -ItemType Directory -Path "c:\scripts\fslogix-tray" -Force
}
Copy-Item $exepath -Destination "c:\scripts\fslogix-tray\frxtray.exe" -Force
