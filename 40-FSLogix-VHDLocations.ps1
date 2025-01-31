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
if($region = "test") {
    Write-Host "[INFO] set fslogix variables"
    $fslogix_regex_storageaccount = "crmecupsans01fxst001"
    $fslogix_regex_share = "crmecupsans01fxst001-share01"
}

# Set FSLogix properties for vhdlocations
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


