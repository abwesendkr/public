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
        # install via add-appxpackage predownloaded
        Start-Process -Wait -FilePath "powershell.exe" -ArgumentList "Add-AppxPackage -Path 'C:\Users\Public\ubuntu-22.04.appx'"
        # check if install successfull
        foreach ($item in $test) {
            # Remove all spaces and other whitespace characters
            $cleanedItem = -join ($item.ToCharArray() | Where-Object { $_ -ne ' ' -and $_ -ne [char]0 })
            # search for distroname in output and if successfull start wsl.
            if ($cleanedItem -match $distro) {
                Write-Output "Found $distro"
                $check =$true
                # start wsl
                Write-host "Starting WSL"
                Invoke-Expression "wsl.exe"
            } else { # install via default wsl
                Write-host "Appx Install failed, install ubuntu standard distro"
                Invoke-Expression "wsl.exe --install -d Ubuntu"
                Write-host "Starting WSL"
                Invoke-Expression "wsl.exe"    
            }
        }
    }
    catch {
        Write-host "install closed with: $_"
    }
    Write-host "install successfull with: $_"
    wsl.exe
}
sleep 5