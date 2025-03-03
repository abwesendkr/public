#####################################
# Install FSLogix with VHDLocations #
#####################################

# Import functions module
Write-Host "[INFO] Import powershell functions"  -ForegroundColor Yellow

function Read-Environment {
    # Hole den Hostnamen des Computers
    $hostname = $env:COMPUTERNAME

    # Überprüfe, ob der Hostname "vms" oder "vss" enthält
    if ($hostname -match "vms" -or $hostname -match "vss") {
        # Setze die Systemvariable "environment"
        [System.Environment]::SetEnvironmentVariable("environment", "staging", [System.EnvironmentVariableTarget]::Machine)
        Write-Output "Systemvariable 'environment' set to: $([System.Environment]::GetEnvironmentVariable("environment", [System.EnvironmentVariableTarget]::Machine))."
    } else {
        Write-Output "[INFO] No 'vms' or 'vss' found in hostname = no staging."
        [System.Environment]::SetEnvironmentVariable("environment", "production", [System.EnvironmentVariableTarget]::Machine)
    }
    return [System.Environment]::GetEnvironmentVariable("environment", [System.EnvironmentVariableTarget]::Machine)
}

# Read region from environment variable 
Write-Host "[INFO] Read region and environment variable"  -ForegroundColor Yellow
$region = Read-Region
$environment = Read-Environment

# Set test FSLogix to staging for all
if($environment -eq "staging") {
    Write-Host "[INFO] Set Staging fslogix variables" -ForegroundColor Yellow
    if($region -eq "test") {
        $fslogix_regex_storageaccount = "crmecupsans01fxst001"
        $fslogix_regex_share = "crmecupsans01fxst001-share01"
    } elseif ($region -eq "apac-single") {
        $fslogix_regex_storageaccount = "crmecupaes01fxst001"
        $fslogix_regex_share = "singlesession"
    } elseif ($region -eq "apac-multi") {
        $fslogix_regex_storageaccount = "crmecupaes01fxst001"
        $fslogix_regex_share = "multisession"
    } elseif ($region -eq "africa-single") {
        $fslogix_regex_storageaccount = "crmecupsans01fxst001"
        $fslogix_regex_share = "singlesession"
    } elseif ($region -eq "africa-multi") {
        $fslogix_regex_storageaccount = "crmecupsans01fxst001"
        $fslogix_regex_share = "multisession"
    }
} elseif ($environment -eq "production") {
    Write-Host "[INFO] Set Production fslogix variables" -ForegroundColor Yellow
    if($region -eq "test") {
        $fslogix_regex_storageaccount = "crmecupae001fxst002"
        $fslogix_regex_share = "test"
    } elseif ($region -eq "apac-single") {
        $fslogix_regex_storageaccount = "crmecupae001fxst002"
        $fslogix_regex_share = "singlesession"
    } elseif ($region -eq "apac-multi") {
        $fslogix_regex_storageaccount = "crmecupae001fxst002"
        $fslogix_regex_share = "multisession"
    }
}

Write-Host "[INFO] Set share to: $($fslogix_regex_storageaccount) and $($fslogix_regex_share)" -ForegroundColor Yellow

# Set FSLogix properties for vhdlocations
Write-Host "[INFO] try set registry " -ForegroundColor Yellow
if($region -and $environment) {
    try {
        $regPath = "HKLM:\SOFTWARE\FSLogix\Profiles"
        New-ItemProperty -Path $regPath -Name Enabled -PropertyType DWORD -Value 1 -Force
        New-ItemProperty -Path $regPath -Name VHDLocations -PropertyType MultiString -Value "\\$fslogix_regex_storageaccount.privatelink.file.core.windows.net\$fslogix_regex_share" -Force
        New-ItemProperty -Path $regPath -Name SizeInMBs -PropertyType DWORD -Value 30000 -Force
        New-ItemProperty -Path $regPath -Name IsDynamic -PropertyType DWORD -Value 1 -Force
        New-ItemProperty -Path $regPath -Name VolumeType -PropertyType String -Value "vhdx" -Force
        New-ItemProperty -Path $regPath -Name FlipFlopProfileDirectoryName -PropertyType DWORD -Value 1 -Force
        New-ItemProperty -Path $regPath -Name DeleteLocalProfileWhenVHDShouldApply -PropertyType DWORD -Value 1 -Force
        New-ItemProperty -Path $regPath -Name "PreventLoginWithFailure" -PropertyType DWORD -Value 1 -Force
        New-ItemProperty -Path $regPath -Name "PreventLoginWithTempProfile" -PropertyType DWORD -Value 1 -Force
        Write-Host "[INSTALLED] Registriy set" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Error installing $($App): $_"  -ForegroundColor Red
        throw $_
    }
} else {
    Write-Host "[ERROR] Region or Environment not set"  -ForegroundColor Red
}





