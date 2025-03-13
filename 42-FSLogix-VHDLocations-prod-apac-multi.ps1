#####################################
# Install FSLogix with VHDLocations #
#####################################

# Read region from environment variable 
Write-Host "[INFO] read region variable"
$region = "apac-multi"

# Set test FSLogix 
Write-Host "[INFO] set fslogix variables"
if($region -eq "test") {
    $fslogix_regex_storageaccount = "crmecupsan001fxst001"
    $fslogix_regex_share = "image-test"
} elseif ($region -eq "apac-single") {
    $fslogix_regex_storageaccount = "crmecupae001fxst002"
    $fslogix_regex_share = "singlesession"
} elseif ($region -eq "apac-multi") {
    $fslogix_regex_storageaccount = "crmecupae001fxst002"
    $fslogix_regex_share = "multisession"
} elseif ($region -eq "africa-single") {
    $fslogix_regex_storageaccount = "crmecupsans01fxst001"
    $fslogix_regex_share = "singlesession"
} elseif ($region -eq "africa-multi") {
    $fslogix_regex_storageaccount = "crmecupsans01fxst001"
    $fslogix_regex_share = "multisession"
}
Write-Host "[INFO] Set share to: $($fslogix_regex_storageaccount) and $($fslogix_regex_share)" -ForegroundColor Black

# Set FSLogix properties for vhdlocations
Write-Host "[INFO] try set registry " -ForegroundColor Black
if($region) {
    try {
        $regPath = "HKLM:\SOFTWARE\FSLogix\Profiles"
        New-ItemProperty -Path $regPath -Name Enabled -PropertyType DWORD -Value 1 -Force
        New-ItemProperty -Path $regPath -Name VHDLocations -PropertyType MultiString -Value "\\$fslogix_regex_storageaccount.file.core.windows.net\$fslogix_regex_share" -Force
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
        Write-Host "[ERROR] Error installing $($App): $_"
        throw $_
    }
} else {
    Write-Host "[ERROR] Region not set"
}

Remove-Item -path "C:\scripts\Set-FSLogix-VHDLocations-set-to-staging.ps1"-Force

## Based on solution from https://serverfault.com/a/725385

## Read env variables and save them in a file

########## added bginfo

"20.209.77.161 crmestorageglobal.blob.core.windows.net" | Out-File -FilePath C:\Windows\System32\drivers\etc\hosts -Encoding UTF8 -Append

if (-not(Test-Path "c:\scripts\bginfo")) {
    New-Item -ItemType Directory -Path "c:\scripts\bginfo" -Force
}

Invoke-WebRequest https://crmestorageglobal.blob.core.windows.net/repo/custom/bginfo/Bginfo-Shortcut.lnk -OutFile "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\Bginfo-Shortcut.lnk"
Invoke-WebRequest https://crmestorageglobal.blob.core.windows.net/repo/custom/bginfo/Bginfo.exe -OutFile "c:\scripts\bginfo\Bginfo.exe"
Invoke-WebRequest https://crmestorageglobal.blob.core.windows.net/repo/custom/bginfo/defi.bgi -OutFile "c:\scripts\bginfo\defi.bgi"

$environment = "production"

if (-not(Test-Path "c:\Temp")) {
    New-Item -ItemType Directory -Path "c:\Temp" -Force
}

$filePath = "C:\Temp\region.txt"

# Write the value to the file
"Region:        " + $region | Out-File -FilePath $filePath -Encoding UTF8
"Environment:   " + $environment | Out-File -FilePath $filePath -Encoding UTF8 -Append

# Move files to BGInfo folder in scripts



 