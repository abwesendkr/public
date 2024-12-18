<#

# Azure VMs which are nested possbile can be found here: https://learn.microsoft.com/en-us/azure/virtual-machines/acu

The MIT License (MIT)
Copyright (c) Microsoft Corporation  
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publi
sh, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, sub
ject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.  
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF ME
RCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WI
TH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
.SYNOPSIS
This script prepares a Windows Server machine to use virtualization.  This includes enabling Hyper-V, enabling DHCP and setting up a 
switch to allow client virtual machines to have internet access.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)][bool] $InstallDhcp = $true,
    [Parameter(Mandatory=$false)][switch]$Force = $true
)

###################################################################################################
#
# PowerShell configurations
#

# NOTE: Because the $ErrorActionPreference is "Stop", this script will stop on first failure.
#       This is necessary to ensure we capture errors inside the try-catch-finally block.
$ErrorActionPreference = "Stop"

# Hide any progress bars, due to downloads and installs of remote components.
$ProgressPreference = "SilentlyContinue"

# Ensure we set the working directory to that of the script.
Push-Location $PSScriptRoot

# Discard any collected errors from a previous execution.
$Error.Clear()

# Configure strict debugging.
Set-PSDebug -Strict

# Configure variables for ShouldContinue prompts
$YesToAll = $Force
$NoToAll = $false

###################################################################################################
#
# Handle all errors in this script.
#

trap {
    # NOTE: This trap will handle all errors. There should be no need to use a catch below in this
    #       script, unless you want to ignore a specific error.
    $message = $Error[0].Exception.Message
    if ($message) {
        Write-Host -Object "`nERROR: $message" -ForegroundColor Red
    }

    Write-Host "`nThe script failed to run.`n"

    # IMPORTANT NOTE: Throwing a terminating error (using $ErrorActionPreference = "Stop") still
    # returns exit code zero from the PowerShell script when using -File. The workaround is to
    # NOT use -File when calling this script and leverage the try-catch-finally block and return
    # a non-zero exit code from the catch block.
    exit -1
}

###################################################################################################
#
# Functions used in this script.
#             

<#
.SYNOPSIS
Returns true is script is running with administrator privileges and false otherwise.
#>
function Get-RunningAsAdministrator {
    [CmdletBinding()]
    param()
    
    $isAdministrator = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    Write-Verbose "Running with Administrator privileges (t/f): $isAdministrator"
    return $isAdministrator
}

<#
.SYNOPSIS
Returns true is current machine is a Windows Server machine and false otherwise.
#>
function Get-RunningServerOperatingSystem {
    [CmdletBinding()]
    param()

    return ($null -ne $(Get-Module -ListAvailable -Name 'servermanager') )
}

<#
.SYNOPSIS
Enables Hyper-V role, including PowerShell cmdlets for Hyper-V and management tools.
#>
function Install-HypervAndTools {
    [CmdletBinding()]
    param()

    if (Get-RunningServerOperatingSystem) {
        Install-HypervAndToolsServer
    } else
    {
        Install-HypervAndToolsClient
    }
}

<#
.SYNOPSIS
Enables Hyper-V role for server, including PowerShell cmdlets for Hyper-V and management tools.
#>
function Install-HypervAndToolsServer {
    [CmdletBinding()]
    param()

    
    if ($null -eq $(Get-WindowsFeature -Name 'Hyper-V')) {
        Write-Error "This script only applies to machines that can run Hyper-V."
    }
    else {
        $roleInstallStatus = Install-WindowsFeature -Name Hyper-V -IncludeManagementTools
        if ($roleInstallStatus.RestartNeeded -eq 'Yes') {
            Write-Error "Restart required to finish installing the Hyper-V role .  Please restart and re-run this script."
        }  
    } 

    # Install PowerShell cmdlets
    $featureStatus = Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell
    if ($featureStatus.RestartNeeded -eq $true) {
        Write-Host "Restart required to finish installing the Hyper-V PowerShell Module.  Please restart and re-run this script."
    }
}

<#
.SYNOPSIS
Enables Hyper-V role and Windows for client (Win10), including PowerShell cmdlets for Hyper-V and management tools.
#>
function Install-HypervAndToolsClient {
    [CmdletBinding()]
    param()
    
    if ($null -eq $(Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Hyper-V-All')) {
        Write-Error "This script only applies to machines that can run Hyper-V."
    }
    else {
        $roleInstallStatus = Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'Microsoft-Hyper-V-All'
        if ($roleInstallStatus.RestartNeeded) {
            Write-Host "Restart required to finish installing the Hyper-V role.  Please restart and re-run this script."
        }

        $featureEnableStatus = Get-WmiObject -Class Win32_OptionalFeature -Filter "name='Microsoft-Hyper-V-All'"
        if ($featureEnableStatus.InstallState -ne 1) {
            Write-Host "This script only applies to machines that can run Microsoft-Hyper-V-All."
            goto(finally)
        }
    }
    Write-Host "Installing VirtualMachinePlatform:"
    $roleInstallStatus = Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'VirtualMachinePlatform'
    Write-Host "thats the status of virtualmachineplatform: $roleInstallStatus"

    Write-Host "Installing Microsoft-Windows-Subsystem-Linux"
    $roleInstallStatus = Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'Microsoft-Windows-Subsystem-Linux'
    Write-Host "thats the status of Microsoft-Windows-Subsystem-Linux: $roleInstallStatus"
#    if ($null -eq $(Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux')) {
#        Write-Error "This script only applies to machines that can run Microsoft-Windows-Subsystem-Linux."
#    }
#    else {
        Write-Host "Install Feature Microsoft-Windows-Subsystem-Linux   "
        $roleInstallStatus = Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'Microsoft-Windows-Subsystem-Linux'
        if ($roleInstallStatus.RestartNeeded) {
            Write-Host "Restart required to finish installing the Microsoft-Windows-Subsystem-Linux role.  Please restart and re-run this script."
        }

        $featureEnableStatus = Get-WmiObject -Class Win32_OptionalFeature -Filter "name='Microsoft-Windows-Subsystem-Linux'"
        if ($featureEnableStatus.InstallState -ne 1) {
            Write-Host "This script only applies to machines that can run Microsoft-Windows-Subsystem-Linux."
            goto(finally)
        }
#    }

#    if ($null -eq $(Get-WindowsOptionalFeature -Online -FeatureName 'VirtualMachinePlatform')) {
#        Write-Error "This script only applies to machines that can run Hyper-V."
#    }
#    else {
#        $roleInstallStatus = Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName 'VirtualMachinePlatform'
#        if ($roleInstallStatus.RestartNeeded) {
#            Write-Host "Restart required to finish installing the Hyper-V role.  Please restart and re-run this script."
#        }
#
#        $featureEnableStatus = Get-WmiObject -Class Win32_OptionalFeature -Filter "name='VirtualMachinePlatform'"
#        if ($featureEnableStatus.InstallState -ne 1) {
#            Write-Host "This script only applies to machines that can run VirtualMachinePlatform."
#            goto(finally)
#        }
#    }
}

<#
.SYNOPSIS
Enables DHCP role, including management tools.
#>
function Install-DHCP {
    [CmdletBinding()]
    param()
   
    if ($null -eq $(Get-WindowsFeature -Name 'DHCP')) {
        Write-Error "This script only applies to machines that can run DHCP."
    }
    else {
        $roleInstallStatus = Install-WindowsFeature -Name DHCP -IncludeManagementTools
        if ($roleInstallStatus.RestartNeeded -eq 'Yes') {
            Write-Error "Restart required to finish installing the DHCP role .  Please restart and re-run this script."
        }  
    } 

    # Tell Windows we are done installing DHCP
    Set-ItemProperty -Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2
}

function Install-DhcpScope {
    param (
        [Parameter(Mandatory=$true)][string] $RouterIpAddress,
        [Parameter(Mandatory=$true)][string] $StartRangeForClientIps,
        [Parameter(Mandatory=$true)][string] $EndRangeForClientIps,
        [Parameter(Mandatory=$true)][string] $SubnetMaskForClientIps
    )
    $dnsServerIp = "168.63.129.16"
    
    # Add scope for client vm ip address
    $scopeName = "LabServicesDhcpScope"

    $dhcpScope = Select-ResourceByProperty `
        -PropertyName 'Name' -ExpectedPropertyValue $scopeName `
        -List @(Get-DhcpServerV4Scope) `
        -NewObjectScriptBlock { Add-DhcpServerv4Scope -name $scopeName -StartRange $StartRangeForClientIps -EndRange $EndRangeForClientIps -SubnetMask $SubnetMaskForClientIps -State Active
                                Set-DhcpServerV4OptionValue -DnsServer $dnsServerIp -Router $RouterIpAddress
                            }
    Write-Host "Using $dhcpScope"
}

<#
.SYNOPSIS
Funtion will find object in given list with specified property of the specified expected value.  If object cannot be found, a new one
 is created by executing scropt in the NewObjectScriptBlock parameter.
.PARAMETER PropertyName
Property to check with looking for object.
.PARAMETER ExpectedPropertyValue
Expected value of property being checked.
.PARAMETER List
List of objects in which to look.
.PARAMETER NewObjectScriptBlock
Script to run if object with the specified value of specified property name is not found.

#>
function Select-ResourceByProperty {
    param(
        [Parameter(Mandatory = $true)][string]$PropertyName ,
        [Parameter(Mandatory = $true)][string]$ExpectedPropertyValue,
        [Parameter(Mandatory = $false)][array]$List = @(),
        [Parameter(Mandatory = $true)][scriptblock]$NewObjectScriptBlock,
        [Parameter(Mandatory = $false)][string] $ShouldContinuePrompt
    )
    
    $returnValue = $null
    $items = @($List | Where-Object $PropertyName -Like $ExpectedPropertyValue)
    
    if ($items.Count -eq 0) {
        Write-Verbose "Creating new item with $PropertyName =  $ExpectedPropertyValue."
        if (-not [String]::IsNullOrEmpty($ShouldContinuePrompt) -and  $PSCmdlet.ShouldContinue($ShouldContinuePrompt, $env:COMPUTERNAME, [ref] $YesToAll, [ref] $NoToAll)){
            $returnValue = & $NewObjectScriptBlock
        }else{
            return $null
        }
    }
    elseif ($items.Count -eq 1) {
        $returnValue = $items[0]
    }
    else {
        $choice = -1
        $choiceTable = New-Object System.Data.DataTable
        $choiceTable.Columns.Add($(new-object System.Data.DataColumn("Option Number")))
        $choiceTable.Columns[0].AutoIncrement = $true
        $choiceTable.Columns[0].ReadOnly = $true
        $choiceTable.Columns.Add($(New-Object System.Data.DataColumn($PropertyName)))
        $choiceTable.Columns.Add($(New-Object System.Data.DataColumn("Details")))
           
        $choiceTable.Rows.Add($null, "\< Exit \>", "Choose this option to exit the script.") | Out-Null
        $items | ForEach-Object { $choiceTable.Rows.Add($null, $($_ | Select-Object -ExpandProperty $PropertyName), $_.ToString()) } | Out-Null

        Write-Host "Found multiple items with $PropertyName = $ExpectedPropertyValue.  Please choose on of the following options."
        $choiceTable | ForEach-Object { Write-Host "$($_[0]): $($_[1]) ($($_[2]))" }

        while (-not (($choice -ge 0 ) -and ($choice -le $choiceTable.Rows.Count - 1 ))) {     
            $choice = Read-Host "Please enter option number. (Between 0 and $($choiceTable.Rows.Count - 1))"           
        }
    
        if ($choice -eq 0) {
            Write-Error "User cancelled script."
        }
        else {
            $returnValue = $items[$($choice - 1)]
        }
          
    }

    return $returnValue
}

###################################################################################################
#
# Main execution block.
#

try {

    # Check that script is being run with Administrator privilege.
    Write-Host "Verify running as administrator."
    if (-not (Get-RunningAsAdministrator)) { Write-Error "Please re-run this script as Administrator." }

    # Install HyperV service and client tools
    if ($PSCmdlet.ShouldContinue("Install Hyper-V feature and tools.", $env:COMPUTERNAME, [ref] $YesToAll, [ref] $NoToAll )){
        Write-Host "Installing Hyper-V, if needed."
        Install-HypervAndTools
    }else{
        Write-Error "Hyper-V feature and tools not installed."
        exit;
    }

    # Pin Hyper-V to the user's desktop.
    if ($PSCmdlet.ShouldContinue("Install Hyper-V feature and tools.", $env:COMPUTERNAME, [ref] $YesToAll, [ref] $NoToAll)){
        #Write-Host "Creating shortcut to Hyper-V Manager on desktop."
        #$Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($(Join-Path "$env:UserProfile\Desktop" "Hyper-V Manager.lnk"))
        #$Shortcut.TargetPath = "$env:SystemRoot\System32\virtmgmt.msc"
        #$Shortcut.Save()
    }

    if (Get-RunningServerOperatingSystem) {

        # Ip addresses and range information.
        $ipAddress = "192.168.0.1"
        $ipAddressPrefixRange = "24"
        $ipAddressPrefix = "192.168.0.0/$ipAddressPrefixRange"
        $startRangeForClientIps = "192.168.0.100"
        $endRangeForClientIps = "192.168.0.200"
        $subnetMaskForClientIps = "255.255.255.0"
       

        if ($InstallDhcp){
            # Install DHCP so client vms will automatically get an IP address.
            Write-Warning "Installing DHCP role on an Azure VM is not a supported scenario.  It is recommended to manually set the ip address for Hyper-V VMs.  See https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#can-i-deploy-a-dhcp-server-in-a-vnet"
            if ($PSCmdlet.ShouldContinue("Install DHCP role and scope.", $env:COMPUTERNAME, [ref] $YesToAll, [ref] $NoToAll)) {
                Write-Host "Installing DHCP, if needed."
                Install-DHCP 
                Install-DhcpScope -RouterIpAddress $ipAddress -StartRangeForClientIps $startRangeForClientIps -EndRangeForClientIps $endRangeForClientIps -SubnetMaskForClientIps $subnetMaskForClientIps
            }
        }

        # Create Switch
        Write-Host "Setting up network for client virtual machines."
        $switchName = "LabServicesSwitch"
        $vmSwitch = Select-ResourceByProperty `
            -PropertyName 'Name' -ExpectedPropertyValue $switchName `
            -List (Get-VMSwitch -SwitchType Internal) `
            -NewObjectScriptBlock { New-VMSwitch -Name $switchName -SwitchType Internal } `
            -ShouldContinuePrompt "Create switch named $switchName."
        if ($null -eq $vmSwitch) { Write-Error "VM switch $switchName not created or found"}
        Write-Host "Using switch '$vmSwitch'"

        # Get network adapter information
        $netAdapter = Select-ResourceByProperty `
            -PropertyName "Name" -ExpectedPropertyValue "*$switchName*"  `
            -List @(Get-NetAdapter) `
            -NewObjectScriptBlock { Write-Error "No network adapaters with name $switchName found." } 
        Write-Host "Using network adapter '$netAdapter'"
        Write-Host "Adapter found is $($netAdapter.ifAlias) and Interface Index is $($netAdapter.ifIndex)"

        # Create IP Address 
        $netIpAddr = Select-ResourceByProperty  `
            -PropertyName 'IPAddress' -ExpectedPropertyValue $ipAddress `
            -List @(Get-NetIPAddress) `
            -NewObjectScriptBlock { New-NetIPAddress -IPAddress $ipAddress -PrefixLength $ipAddressPrefixRange -InterfaceIndex $netAdapter.ifIndex } `
            -ShouldContinuePrompt "Create IP address $ipAddress"
        if ($null -eq $netIpAddr) {
            Write-Error "Couldn't create or find IP address $ipAddress."
        }elseif (($netIpAddr.PrefixLength -ne $ipAddressPrefixRange) -or ($netIpAddr.InterfaceIndex -ne $netAdapter.ifIndex)) {
            Write-Error "Found Net IP Address $netIpAddr, but prefix $ipAddressPrefix ifIndex not $($netAdapter.ifIndex)."
        }else{
            Write-Host "Net ip address found is $ipAddress"
        }

        # Create NAT
        $natName = "LabServicesNat"
        $netNat = Select-ResourceByProperty `
            -PropertyName 'Name' `
            -ExpectedPropertyValue $natName `
            -List @(Get-NetNat) `
            -NewObjectScriptBlock { New-NetNat -Name $natName -InternalIPInterfaceAddressPrefix $ipAddressPrefix } `
            -ShouldContinuePrompt "Create NAT network $ipAddressPrefix"
        if ($null -eq $netNat){
            Write-Error "Couldn't create or find NAT network $ipAddressPrefix"
        }elseif ($netNat.InternalIPInterfaceAddressPrefix -ne $ipAddressPrefix) {
            Write-Error "Found nat with name $natName, but InternalIPInterfaceAddressPrefix is not $ipAddressPrefix."
        }else{
            Write-Host "Nat found is $netNat"
        }

        #Make sure WinNat will start automatically so Hyper-V VMs will have internet connectivity.
        if (((Get-Service -Name WinNat | Select-Object -ExpandProperty StartType) -ne 'Automatic') -and $PSCmdlet.ShouldContinue($env:COMPUTERNAME, "Automatically start WinNat service.", [ref] $YesToAll, [ref] $NoToAll)) {
            Set-Service -Name WinNat -StartupType Automatic
        }
        if ($(Get-Service -Name WinNat | Select-Object -ExpandProperty StartType) -ne 'Automatic')
        {
            Write-Warning "Unable to set WinNat service to Automatic.  Hyper-V virtual machines will not have internet connectivity w
hen service is not running."
        }              
    }
    else {
        Write-Host -Object "On Windows 10 and later, use 'Default Switch' when configuring network connection for Hyper-V VMs." -ForegroundColor Yellow
    }
    # Tell the user script is done.    
    Write-Host "Script completed." -ForegroundColor Green
    exit 0
}
finally {
    # Restore system to state prior to execution of this script.
    Pop-Location
}


