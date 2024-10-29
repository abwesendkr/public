###############
# Install WSL #
###############
# Installiere WSL2 und eine Distribution
Write-Host "Installing WSL, using `"wsl --install -d Ubuntu-24.04`" "
wsl --install -d Ubuntu-24.04

# Warte, bis die Installation abgeschlossen ist
Start-Sleep -Seconds 10

# Starte die WSL-Distribution
wsl -d Ubuntu-24.04 --user root -- bash -c "echo 'rootktc:Hilfe123456#' | chpasswd"