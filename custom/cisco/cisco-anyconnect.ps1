# Skript Pfad: C:\Scripts\Install-SQLDeveloper.ps1

$App = "Cisco Anyconnect"
$MSIFile = "anyconnect-win-4.10.08029-core-vpn-predeploy-k9.msi"
$Switches = "REBOOT=ReallySuppress /QN"

# Überprüfen, ob das ZIP-File existiert
if (-Not (Test-Path -Path $MSIFile)) {
    write-host "[ERROR] Das ZIP-File '$MSIFile' wurde nicht gefunden."
}

# ZIP-Datei entpacken
try {
    Write-Host "[INFO] Install $MSIFile"
    Start-Process -Wait -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i", "$MsiPath", "$Switches"
    Copy-File -Path "preferences_global.xml" -Destination "$envProgramdata\Cisco\Cisco AnyConnect Secure Mobility Client"
    # Erfolgreiches Ende
    Write-Host " $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Installation $App erfolgreich abgeschlossen."
} catch {
    write-host "[ERROR] Fehler beim Entpacken der ZIP-Datei: $_"
}

exit 0
