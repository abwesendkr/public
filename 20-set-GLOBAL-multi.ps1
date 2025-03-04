# Skript zum Setzen und Auslesen von Umgebungsvariablen

# Definiere den Namen der Umgebungsvariablen und ihren Wert
$variableName = "region"
$variableValue = "global-multi"

# Setze die Umgebungsvariable systemweit
[System.Environment]::SetEnvironmentVariable($variableName, $variableValue, [System.EnvironmentVariableTarget]::Machine)

# Bestätige, dass die Umgebungsvariable gesetzt wurde
Write-Host "Umgebungsvariable '$variableName' wurde gesetzt mit dem Wert: '$variableValue'"

# Lese die Umgebungsvariable aus
$readValue = [System.Environment]::GetEnvironmentVariable($variableName, [System.EnvironmentVariableTarget]::Machine)

# Zeige den aktuellen Wert der Umgebungsvariable an
Write-Host "Aktueller Wert der Umgebungsvariable '$variableName': $readValue"
