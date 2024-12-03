# Skript Pfad: C:\Scripts\Install-SQLDeveloper.ps1


$App = "Oracle-SQLDeveloper"
# newest version: https://www.oracle.com/database/sqldeveloper/technologies/download/
$MsiUrl = "https://download.oracle.com/otn_software/java/sqldeveloper/sqldeveloper-24.3.0.284.2209-x64.zip"
$TempFolderPath = "C:\Temp"
$MsiPath = "$TempFolderPath\sqldeveloper-24.3.0.284.2209-x64.zip"

if (!(Test-Path $TempFolderPath)) {
    mkdir $TempFolderPath
}

# Import functions
Import-Module -name ".\functions.psm1"

# Load Powershell
Write-Host "[INFO] Attempting to load file from $MsiUrl to $MsiPath"
if (-not(Test-Path $MsiPath)) {
    Load-WebFile $MsiUrl $MsiPath
}

# Allgemeine Einstellungen

$zipFile = $MsiPath
$destinationBase = "C:\Oracle-SQLDeveloper"
$desktopShortcut = "C:\Users\Public\Desktop\sqldeveloper.lnk"

# Überprüfen, ob das ZIP-File existiert
if (-Not (Test-Path -Path $zipFile)) {
    write-host "[ERROR] Das ZIP-File '$zipFile' wurde nicht gefunden."
}

# Versionsnummer auslesen
$versionMatch = [regex]::Match($zipFile, '(\d+\.\d+\.\d+\.\d+)')
if ($versionMatch.Success) {
    $version = $versionMatch.Value
    Write-Host "[INFO] Extracted version: $($version)"
} else {
    write-host "[ERROR] Konnte die Versionsnummer nicht aus dem Dateinamen extrahieren."
}

# Zielverzeichnis mit Versionsnummer erstellen
$destination = "$destinationBase-$version"
if (-Not (Test-Path -Path $destination)) {
    New-Item -ItemType Directory -Path $destination | Out-Null
}

# ZIP-Datei entpacken
try {
    Write-Host "[INFO] Extract Zip-File"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $destination)
    Write-Host "[INFO] Zip-File extracted"
} catch {
    write-host "[ERROR] Fehler beim Entpacken der ZIP-Datei: $_"
}

# Verknüpfung erstellen
$exePath = Join-Path -Path $destination -ChildPath "sqldeveloper\sqldeveloper.exe"
if (-Not (Test-Path -Path $exePath)) {
    write-host "[ERROR] Die Datei 'sqldeveloper.exe' wurde nicht im entpackten Verzeichnis gefunden."
}

$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut($desktopShortcut)
$shortcut.TargetPath = $exePath
$shortcut.Save()

# Erfolgreiches Ende
Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Installation erfolgreich abgeschlossen."
exit 0
