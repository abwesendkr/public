###############
# Install WSL #
###############

function CreateUbuntuShortcut {
    param ()
    Invoke-WebRequest -Uri c:\users\public\ubuntu-22.04.png
}

Write-Host "start script install WSL"
try {
    
    Write-Host "start download WSL-kernel-update"
    # Download WSL update 
    # this guide https://learn.microsoft.com/de-de/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package
    Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile "wsl_update_x64.msi"
    Write-Host "Finished download WSL-kernel-update"

    # Installiere WSL2 und eine Distribution
    # Possible WSL images: https://learn.microsoft.com/de-de/windows/wsl/install-manual#downloading-distributions
    Write-Host "start download WSL-appx"
    Invoke-WebRequest -Uri "https://aka.ms/wslubuntu2204" -OutFile "ubuntu-22.04.appx"
    Write-Host "Finished download WSL-appx, create c:\temp"
    New-Item -ItemType Directory -Path "C:\temp" -Force
    Write-Host "copy ubuntu-22.04.appx to C:\Users\Public\"
    Copy-Item -Path ".\ubuntu-22.04.appx" -Destination "C:\Users\Public\ubuntu-22.04.appx"
    
    
    Write-Host "Installing WSL, using `"msiexec.exe /i wsl_update_x64.msi /quiet`" "
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i wsl_update_x64.msi /quiet" -Wait
    Write-Host "Successfull, installing WSL only for each user, not in system-context"
    #Add-AppxPackage -Path ".\ubuntu-22.04.appx"
    
    #wsl --install -d Ubuntu-24.04

    # Warte, bis die Installation abgeschlossen ist
    Start-Sleep -Seconds 10

    # Starte die WSL-Distribution
#    Write-Host "Installing WSL, using `"wsl --install -d Ubuntu-24.04`" "
#    wsl --user root -- bash -c "echo 'rootktc:Hilfe123456#' | chpasswd"
#    wsl -d Ubuntu-24.04 --user root -- bash -c "echo 'rootktc:Hilfe123456#' | chpasswd"
    exit 0
}
catch {
    $message = $Error[0].Exception.Message
    if ($message) {
        Write-Host -Object "`nERROR: $message" -ForegroundColor Red
    }

    Write-Host "`nThe script failed to run.`n"
}

