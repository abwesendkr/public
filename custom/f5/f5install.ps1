$App = "F5 VPN"
$MSIFile = Join-Path -path $PSScriptRoot -ChildPath "f5fpclients.msi"
$Switches = "REBOOT=ReallySuppress /QN"

# Überprüfen, ob das ZIP-File existiert
if (-Not (Test-Path -Path $MSIFile)) {
    write-host "[ERROR] '$MSIFile' wurde nicht gefunden."
}

# MSI install
try {
    Write-Host "[INFO] Install $MSIFile"
    Start-Process -Wait -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i", "$MSIFile", "$Switches"
    # Erfolgreiches Ende
    Write-Host " $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Installation $App erfolgreich abgeschlossen."
} catch {
    write-host "[ERROR] Install of $MSIFile Error sent back: $_"
}

exit 0
