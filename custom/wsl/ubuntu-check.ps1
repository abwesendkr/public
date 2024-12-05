$distro = "Ubuntu"
$test = wsl -l 
#write-host $test
$check = $false
foreach ($item in $test) {
    # Remove all spaces and other whitespace characters
    $cleanedItem = -join ($item.ToCharArray() | Where-Object { $_ -ne ' ' -and $_ -ne [char]0 })
#    Write-Host "item: $item"
#    write-host "cleaneditem: $cleanedItem"
    if ($cleanedItem -match $distro) {
        Write-Output "Found $distro"
        $check =$true
    }
}
if ($check){ 
    Write-host "Starting WSL"
    Invoke-Expression "wsl.exe"
#    sleep 10
}
else{ 
    Write-Host "Installing AppxPackage Ubuntu-22.04.appx"
    try {
#        Start-Process -Wait Add-AppxPackage -Path C:\Users\Public\ubuntu-22.04.appx
        Start-Process -Wait -FilePath "powershell.exe" -ArgumentList "Add-AppxPackage -Path 'C:\Users\Public\ubuntu-22.04.appx'"
    }
    catch {
        Write-host "install closed with: $_"
    }
    Write-host "install successfull with: $_"
    wsl.exe
}
sleep 5