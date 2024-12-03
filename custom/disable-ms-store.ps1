# Setze die Gruppenrichtlinie, um den Microsoft Store zu deaktivieren
$regKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
$regName = "RemoveWindowsStore"
$regValue = 1

# Erstelle den Registrierungsschlüssel, wenn er nicht existiert
If (-Not (Test-Path $regKeyPath)) {
    New-Item -Path $regKeyPath -Force
}

# Setze den Wert, um den Store zu deaktivieren
Set-ItemProperty -Path $regKeyPath -Name $regName -Value $regValue

Write-Host "Microsoft Store wurde deaktiviert."
