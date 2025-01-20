$fslogix_regex_storageaccount = "random-stg-account"
$fslogix_regex_share = "random-share"
# Remove AVD specific programs
$RDS_SxS = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Remote Desktop Services SxS Network Stack"}
$RDS_SxS.uninstall()

Start-Sleep -Seconds 10

$RDA_boot_loader = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Remote Desktop Agent Boot Loader"}
$RDA_boot_loader.uninstall()

Start-Sleep -Seconds 10

$RDS_infra_agent = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Remote Desktop Services Infrastructure Agent"}
$RDS_infra_agent.uninstall()

Start-Sleep -Seconds 10

$RDS_infra_geneva_agent = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -Match "^Remote Desktop Services Infrastructure Geneva Agent"}
$RDS_infra_geneva_agent.uninstall()

Start-Sleep -Seconds 10

# Disjoin Entra ID Domain
Start-Process -FilePath "C:\Windows\system32\dsregcmd.exe" -ArgumentList "/leave"
Remove-Computer  -PassThru -Verbose -WorkgroupName Domain -Force
C:\Windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown

# Set FSLogix properties
$regPath = "HKLM:\SOFTWARE\FSLogix\Profiles"
New-ItemProperty -Path $regPath -Name Enabled -PropertyType DWORD -Value 1 -Force
New-ItemProperty -Path $regPath -Name VHDLocations -PropertyType MultiString -Value "\\$fslogix_regex_storageaccount.file.core.windows.net\$fslogix_regex_share" -Force