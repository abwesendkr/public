$test = wsl -l 
write-host $test
if ($test -like "Ubuntu*"){ 
    Write-host "Starting WSL"
    wsl.exe
    sleep 10
} 
else{ 
    Write-Host "Installing AppxPackage Ubuntu-22.04.appx"
    try {
        Start-Process -Wait Add-AppxPackage -Path C:\Users\Public\ubuntu-22.04.appx
    }
    catch {
        Write-host "install closed with: $_"
    }
    Write-host "install successfull with: $_"
    wsl.exe
}
