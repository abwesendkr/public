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
    $fslogix_regex_storageaccount = "random-stg-account"
    $fslogix_regex_share = "random-share"
}

# Set FSLogix properties for vhdlocations
$regPath = "HKLM:\SOFTWARE\FSLogix\Profiles"
New-ItemProperty -Path $regPath -Name Enabled -PropertyType DWORD -Value 1 -Force
New-ItemProperty -Path $regPath -Name VHDLocations -PropertyType MultiString -Value "\\$fslogix_regex_storageaccount.file.core.windows.net\$fslogix_regex_share" -Force
\\crmecupaes01fxst001.privatelink.file.core.windows.net\singlessession
