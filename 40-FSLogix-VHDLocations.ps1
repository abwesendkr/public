#####################################
# Install FSLogix with VHDLocations #
#####################################

# Import functions module
Write-Host "[INFO] import powershell functions"
Import-Module "./functions.psm1"

# Read region from environment variable 
Write-Host "[INFO] read region variable"
$region = Read-Region

# Set test FSLogix 
Write-Host "[INFO] set fslogix variables"
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
Write-Host "[INFO] Set share to: $($fslogix_regex_storageaccount) and $($fslogix_regex_share)"

# Set FSLogix properties for vhdlocations
Write-Host "[INFO] try set registry "
if($region) {
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
        Write-Host "[INSTALLED] Registriy set"
    }
    catch {
        Write-Host "[ERROR] Error installing $($App): $_"
        throw $_
    }
} else {
    Write-Host "[ERROR] Region not set"
}





