###############
# Install WSL #
###############
trap {
    # NOTE: This trap will handle all errors. There should be no need to use a catch below in this
    #       script, unless you want to ignore a specific error.
    $message = $Error[0].Exception.Message
    if ($message) {
        Write-Host -Object "`nERROR: $message" -ForegroundColor Red
    }

    Write-Host "`nThe script failed to run.`n"

    # IMPORTANT NOTE: Throwing a terminating error (using $ErrorActionPreference = "Stop") still
    # returns exit code zero from the PowerShell script when using -File. The workaround is to
    # NOT use -File when calling this script and leverage the try-catch-finally block and return
    # a non-zero exit code from the catch block.
    exit -1
}

try {
    #download update and ubuntu 22.04 
    #wget https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
    #wget https://aka.ms/wslubuntu2204


    # Installiere WSL2 und eine Distribution
    
    Write-Host "Installing WSL, using `"wsl --install -d Ubuntu-24.04`" "
    wsl --install -d Ubuntu-24.04

    # Warte, bis die Installation abgeschlossen ist
    Start-Sleep -Seconds 10

    # Starte die WSL-Distribution
    Write-Host "Installing WSL, using `"wsl --install -d Ubuntu-24.04`" "
    wsl -d Ubuntu-24.04 --user root -- bash -c "echo 'rootktc:Hilfe123456#' | chpasswd"
}