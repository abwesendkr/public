###############
# Install WSL #
###############

try {
    # Download WSL update
    Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile "wsl_update_x64.msi"

    # Installiere WSL2 und eine Distribution

    Invoke-WebRequest -Uri "https://aka.ms/wslubuntu2204" -OutFile "ubuntu-22.04.appx"

    Write-Host "Installing WSL, using `"wsl --install -d Ubuntu-24.04`" "
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i wsl_update_x64.msi /quiet" -Wait
    Add-AppxPackage -Path ".\ubuntu-22.04.appx"
    
    #wsl --install -d Ubuntu-24.04

    # Warte, bis die Installation abgeschlossen ist
    Start-Sleep -Seconds 10

    # Starte die WSL-Distribution
    Write-Host "Installing WSL, using `"wsl --install -d Ubuntu-24.04`" "
    wsl --user root -- bash -c "echo 'rootktc:Hilfe123456#' | chpasswd"
#    wsl -d Ubuntu-24.04 --user root -- bash -c "echo 'rootktc:Hilfe123456#' | chpasswd"
}
catch {
    $message = $Error[0].Exception.Message
    if ($message) {
        Write-Host -Object "`nERROR: $message" -ForegroundColor Red
    }

    Write-Host "`nThe script failed to run.`n"
}
