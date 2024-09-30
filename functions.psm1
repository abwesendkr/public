function Uninstall-Chocolatey {

    if ($env:TERM_PROGRAM -eq "vscode") {
        Write-Host "Skipping chocolatey uninstall"
    }
    else {
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Host "Uninstalling Chocolatey..." -ForegroundColor Yellow
            try {
                # Uninstall Chocolatey using the built-in uninstall command
                & "C:\ProgramData\chocolatey\choco.exe" uninstall chocolatey -y

                # Optionally remove the Chocolatey folder and registry keys
                Remove-Item -Recurse -Force "C:\ProgramData\chocolatey" -ErrorAction SilentlyContinue
                Remove-Item -Recurse -Force "$env:ChocolateyInstall" -ErrorAction SilentlyContinue

                # Clean up environment variables
                [System.Environment]::SetEnvironmentVariable('ChocolateyInstall', $null, [System.EnvironmentVariableTarget]::Machine)

                Write-Host "Chocolatey uninstalled successfully." -ForegroundColor Green
            }
            catch {
                Write-Host "[ERROR] Failed to uninstall Chocolatey." -ForegroundColor Red
            }
        }
        else {
            Write-Host "Chocolatey is not installed." -ForegroundColor Yellow
        }
    }
}
function Install-WithWinget {
    param (
        [object]$App
    )
    #check if winget is installed:
    $winget_exe = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
    Write-Host "Winget Path found: $($winget_exe)"
    #scope needs to be set to machine --scope machine
    $InstallCommand = "install --exact --id $($App.name) --silent --accept-package-agreements --accept-source-agreements"
    
    #set sources and environment:
    Write-Host "DEBUG: Try to run programm: $winget_exe list --accept-source-agreements:"
    & $winget_exe list --accept-source-agreements
    Write-Host "DEBUG: Try to run programm: $winget_exe settings --set region=US:"
    & $winget_exe settings --set region=US
    Write-Host "DEBUG: Try to run programm: $winget_exe source list:"
    & $winget_exe source list
    Write-Host "DEBUG: Try to run programm: $winget_exe source update:"
    & $winget_exe source update
    Write-Host "DEBUG: Try to run programm: $winget_exe source export:"
    & $winget_exe source export
    Write-Host "DEBUG: Try to run programm: get-winsystemlocale:"
    get-winsystemlocale

   # Ensures to not install any applications when running in vscode
    if ($env:TERM_PROGRAM -eq "vscode") {
        $InstallCommand += " --noop"
    }
    if ($App.chocoVersion) {
        $InstallCommand += " --version $($App.chocoVersion)"
    }
    if ($App.chocoArgumentString) {
        $InstallCommand += " --install-arguments='$($App.chocoArgumentString)'"
    }

    Write-Host "Executing command: $winget_exe $InstallCommand"
    try {
        # Execute the command
        $env:WINGET_DOWNLOAD_PROGRESS = $false
        Invoke-Expression "& `"$winget_exe`" $InstallCommand"
        
        # Check the exit code or validate the installation
        if ($LASTEXITCODE -eq 1) {
            throw "[ERROR] Error encountered: $_"
        }
        Write-Host "[INFO] Successfully installed $($App.name)"  -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Failed to install $($App.name)."  -ForegroundColor Red
        throw "[ERROR] Error encountered: $_"
    }
}
function Install-WithWingetpowershell {
    param (
        [object]$App
    )
    try {
        if ($App.chocoVersion) {
            Write-Host "Starting installation of $($App.name) with winget and Version $($App.chocoVersion)..."
            # Installation mit spezifischer Version
            Install-WingetPackage -Id $App.name -Version $App.chocoVersion -Mode Silent -Scope System -Force  
        } else {
            Write-Host "Starting installation of $($App.name) with winget..."
            # Installation ohne spezifischer Version
            Install-WingetPackage -Id $App.name -Mode Silent -Scope System -Force 
        }
        
        Write-Host "Installation completed."
#        exit 0  # Erfolgreiche Beendigung
    }
    catch {
        Write-Error "Installation failed: $_"
        Get-Module
#        exit 1  # Fehler
    }
}
function Install-WithChoco {
    param (
        [object]$App
    )
    $InstallCommand = "choco install $($App.name) -y --no-progress --ignoredetectedreboot"

    # Ensures to not install any applications when running in vscode
    if ($env:TERM_PROGRAM -eq "vscode") {
        $InstallCommand += " --noop"
    }
    if ($App.chocoVersion) {
        $InstallCommand += " --version $($App.chocoVersion)"
    }
    if ($App.chocoArgumentString) {
        $InstallCommand += " --install-arguments='$($App.chocoArgumentString)'"
    }

    Write-Host "Executing command: $InstallCommand"
    try {
        # Execute the command
        Invoke-Expression $InstallCommand
    
        # Check the exit code or validate the installation
        if ($LASTEXITCODE -eq 1) {
            throw "[ERROR] Error encountered: $_"
        }
        Write-Host "[INFO] Successfully installed $($App.name)"  -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Failed to install $($App.name)."  -ForegroundColor Red
        throw "[ERROR] Error encountered: $_"
    }
}

function Load-WebFile {
    param (
        [string]$Url,
        [string]$FilePath
    )

    # Check if file already exists in temp directory
    try {
        Write-Host "Downloading from Url: $Url"
        Invoke-WebRequest -Uri $Url -OutFile $FilePath -ErrorAction Stop
        Write-Host "Downloaded: $FilePath"
    }
    catch {
        Write-Host "Error downloading $FilePath from $Url" -ForegroundColor Red
        throw "Error: $_"
    }
}

function Create-LogElement {
    param(
        [object]$App,
        [boolean]$Success
    )
    $LogElement = [pscustomobject]@{
        Name    = $($App.name)
        Version = $($App.chocoVersion)
        Success = $Success
    }
    return $LogElement

}