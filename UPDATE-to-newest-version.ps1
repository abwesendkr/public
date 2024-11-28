# Parse JSON file
try {
    $Apps = Get-Content -Path "./apps.json" -Raw | ConvertFrom-Json
}
catch {
    Write-Host "[FATAL] Failed to load apps.json, error message: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}


# Set counters for successful installation
$TotalAppCount = $Apps.Count
$SuccessfulAppCount = $TotalAppCount
$SuccessfulMandatoryAppCount = 0
$InstallStatusTable = @()

# Loop through each app and install it
for ($i = 0; $i -lt $Apps.Count; $i++) {
    $App = $Apps[$i]
    if ($App.mandatory -eq "yes") {
        $SuccessfulMandatoryAppCount += 1
    }
    Write-Host "Update $($App.name)..." -ForegroundColor Green
    try {
        Update-AppVersionToLatest($App)
        $InstallStatus = Create-LogElement -App $App -Success $true  
        $InstallStatusTable += $InstallStatus
    }
    catch {
        Write-Host "Encountered error: $_"
        $InstallStatusTable += Create-LogElement -App $App -Success $false  
        $SuccessfulAppCount -= 1
        if ($App.mandatory -eq "yes") {
            $SuccessfulMandatoryAppCount -= 1
        }        
    }
}

# Move back to root folder
Set-Location ".."

# Log the status table
Write-Host "[INFO] Successfully updated versions $($SuccessfulAppCount)/$($TotalAppCount) applications."
$InstallStatusTable | Format-Table -AutoSize

if ($SuccessfulAppCount -lt $TotalAppCount) {
    Write-Host "[FATAL] Not all apps were installed successfully, failing script."  -ForegroundColor Red
    exit 1
}

ConvertTo-Json -InputObject $Apps | Out-File '.\apps-new.json'
