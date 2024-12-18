
#####################
### Set Varaibles ###
#####################

# Parameter definieren
param(
    [Parameter(Mandatory=$true)]
    [string]$QuellPfad,

    [Parameter(Mandatory=$true)]
    [string]$ZielPfad,

    [Parameter(Mandatory=$false)]
    [string]$Splitsize,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Fastest", "Optimal", "NoCompression")]
    [string]$Komprimierung = "Optimal",

    [Parameter(Mandatory=$false)]
    [switch]$Ueberschreiben,   
    
    [Parameter(Mandatory=$false)]
    [switch]$decompress
)

$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

# Funktion zum Überprüfen des Pfades
function Test-Pfad {
    param([string]$Pfad)
    if (-not (Test-Path $Pfad)) {
        Write-Error "Der angegebene Pfad existiert nicht: $Pfad"
        exit
    }
}

# Pfade überprüfen
Test-path $QuellPfad

# Zielverzeichnis erstellen, falls es nicht existiert
$ZielVerzeichnis = Split-Path -Path $ZielPfad -Parent
if (-not (Test-Path $ZielVerzeichnis)) {
    New-Item -ItemType Directory -Path $ZielVerzeichnis -Force | Out-Null
}

if ($decompress) {    
    # Befehl zum Zusammenfügen der gesplitteten Dateien
    $command = "& $sevenZipPath x $QuellPfad -o$ZielPfad" 
    Write-Host "$command"
} else {
    # Archivierung durchführen
    try {
        $command = "& ""$sevenZipPath"" a -v$Splitsize -mx=1 ""$ZielPfad"" ""$QuellPfad"""

        if ($Ueberschreiben) {
            $command += " -aoa"
        }
        Invoke-Expression $command
        Write-Host "Archivierung erfolgreich abgeschlossen: $command"
    }
    catch {
        Write-Error "Fehler bei der Archivierung: $_"
    }
}


#####################
#### Split & Move ###
#####################

