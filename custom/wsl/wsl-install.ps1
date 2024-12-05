###############
# Install WSL #
###############


function CreateUbuntuShortcut {
    param ()
    
    # Define the paths
#    $appxPath = "C:\Users\public\ubuntu-22.04.appx"
    $appxPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" 
    $Arguments = "-ExecutionPolicy Bypass -file C:\Users\Public\ubuntu-check.ps1"
    $shortcutPath = "C:\Users\public\desktop\Ubuntu-22.04.lnk"
    $iconPath = "C:\Users\Public\ubuntu-22.04.ico" # Path to your converted icon file
 
    Write-Host "start download Ubuntu Icon"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/abwesendkr/public/refs/heads/main/custom/wsl/ubuntu-22.04.ico" -OutFile $iconPath

    # Create a WScript Shell COM object
    $WshShell = New-Object -ComObject WScript.Shell

    # Create the shortcut
    $shortcut = $WshShell.CreateShortcut($shortcutPath)
    $shortcut.Arguments = $Arguments
    $shortcut.TargetPath = $appxPath
    $shortcut.IconLocation = $iconPath # Set the icon location
    $shortcut.Save()
    Write-Host "shortcut created"
}

Write-Host "start script install WSL"
try {
    
    Write-Host "start download WSL-kernel-update"
    # Download WSL update 
    # this guide https://learn.microsoft.com/de-de/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package
    Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile "c:\temp\wsl_update_x64.msi"
    Write-Host "Finished download WSL-kernel-update to c:\temp"

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
    Write-Host "start download ubuntu-check.ps1"
    # Download WSL update 
    # this guide https://learn.microsoft.com/de-de/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/abwesendkr/public/refs/heads/main/custom/wsl/ubuntu-check.ps1" -OutFile "c:\users\public\ubuntu-check.ps1"
    Write-Host "Finished download ubuntu-check.ps1 to c:\user\public\"
    # Warte, bis die Installation abgeschlossen ist
    Start-Sleep -Seconds 10

    CreateUbuntuShortcut
    Write-Host "Successfull, installing WSL only for each user, not in system-context" 
    exit 0
}
catch {
    $message = $Error[0].Exception.Message
    if ($message) {
        Write-Host -Object "`nERROR: $message" -ForegroundColor Red
    }

    Write-Host "`nThe script failed to run.`n"
}

