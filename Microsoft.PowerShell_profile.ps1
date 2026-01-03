# PowerShell Profile for Windows
# Contains functions for winget installation and SDK configuration

# Function to run the winget installer
function Start-WingetInstall {
    <#
    .SYNOPSIS
        Installs a predefined set of applications using winget.

    .DESCRIPTION
        This function installs 9 commonly used applications including browsers,
        development tools, and utilities using winget package manager.

    .EXAMPLE
        PS> Start-WingetInstall
    #>

    Write-Host "Installing selected applications..." -ForegroundColor Green
    Write-Host ""

    try {
        # Install Google Chrome
        Write-Host "Installing Google Chrome..." -ForegroundColor Yellow
        winget install --id Google.Chrome --accept-package-agreements --accept-source-agreements

        # Install Android Studio
        Write-Host "Installing Android Studio..." -ForegroundColor Yellow
        winget install --id Google.AndroidStudio --accept-package-agreements --accept-source-agreements

        # Install Git
        Write-Host "Installing Git..." -ForegroundColor Yellow
        winget install --id Git.Git --accept-package-agreements --accept-source-agreements

        # Install gh
        Write-Host "Installing gh..." -ForegroundColor Yellow

        winget install -e --accept-package-agreements --accept-source-agreements  --id GitHub.cli
        # Install gpg
        Write-Host "Installing Gpg..." -ForegroundColor Yellow
        winget install -e --accept-package-agreements --accept-source-agreements --id GnuPG.GnuPG

        # Install GitHub Desktop
        Write-Host "Installing GitHub Desktop..." -ForegroundColor Yellow
        winget install --id GitHub.GitHubDesktop --accept-package-agreements --accept-source-agreements


        # Install PeaZip
        Write-Host "Installing PeaZip..." -ForegroundColor Yellow
        winget install --id Giorgiotani.Peazip --accept-package-agreements --accept-source-agreements


        # Install Node.js
        Write-Host "Installing Node.js..." -ForegroundColor Yellow
        winget install --id OpenJS.NodeJS --accept-package-agreements --accept-source-agreements

        # Install Brave Browser
        # Write-Host "Installing Brave Browser..." -ForegroundColor Yellow
        # winget install --id Brave.Brave --accept-package-agreements --accept-source-agreements

        # Install Visual Studio Code
        Write-Host "Installing Visual Studio Code..." -ForegroundColor Yellow
        winget install --id Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements

        Write-Host ""
        Write-Host "Installation complete!" -ForegroundColor Green

        # Check if npm is available and run basic operations
        Write-Host "Checking npm availability..." -ForegroundColor Yellow
        Start-Sleep -Seconds 3  # Brief pause to allow PATH update

        $npmCheck = Get-Command npm -ErrorAction SilentlyContinue
        if ($npmCheck) {
            Write-Host "npm is available. Current version:" -ForegroundColor Green
            npm --version

            Write-Host "Running npm doctor to check npm installation..." -ForegroundColor Yellow
            npm doctor

            Write-Host "npm is ready to use!" -ForegroundColor Green
        } else {
            Write-Warning "npm may not be in PATH yet. You might need to restart your terminal or run 'refreshenv'."
            Write-Host "To refresh environment variables without restarting, you can run:" -ForegroundColor Yellow
            Write-Host "  refreshenv" -ForegroundColor White
            Write-Host "  # (requires administrator privileges or the 'Chocolatey' package)"
        }
    }
    catch {
        Write-Error "An error occurred during installation: $($_.Exception.Message)"
    }
}

# Function to run the SDK configuration
function Set-AndroidSDKConfig {
    <#
    .SYNOPSIS
        Configures Android SDK and Java environment variables.

    .DESCRIPTION
        This function detects Android SDK and Java installations, sets environment
        variables (ANDROID_HOME, JAVA_HOME), and updates the PATH variable.
        If directories don't exist, it will still set the environment variables
        to the expected paths.

    .EXAMPLE
        PS> Set-AndroidSDKConfig
    #>

    Write-Output "=================================="
    Write-Output "Android SDK + Java Auto Config"
    Write-Output "=================================="
    Write-Output ""

    # Check execution policy and provide guidance if needed
    try {
        $currentPolicy = Get-ExecutionPolicy
        Write-Output "Current PowerShell execution policy: $currentPolicy"
        Write-Output ""

        if ($currentPolicy -eq "Restricted") {
            Write-Warning "PowerShell execution policy is set to Restricted."
            Write-Output ""
            Write-Output "To run this script, you need to allow script execution:"
            Write-Output "Option 1 - Run in current session only:"
            Write-Output "  PowerShell -ExecutionPolicy Bypass -File `"$PSCommandPath`""
            Write-Output ""
            Write-Output "Option 2 - Allow remote signed scripts (recommended):"
            Write-Output "  Run PowerShell as Administrator and execute:"
            Write-Output "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine"
            Write-Output ""
            Write-Error "Execution policy prevents running scripts. Please follow the instructions above."
            return
        }
    }
    catch {
        Write-Warning "Could not determine PowerShell execution policy. This might indicate a module loading issue."
        Write-Output "If you encounter script execution errors, try running with: PowerShell -ExecutionPolicy Bypass"
        Write-Output ""
        Write-Output "For this script, run it using: PowerShell -ExecutionPolicy Bypass -File `"sdk.ps1`""
        Write-Output ""
    }

    Write-Output "Checking for Android SDK installation..."

    # ---------- Set Android SDK path (whether it exists or not) ----------
    $defaultSdkPath = "$env:LOCALAPPDATA\Android\Sdk"
    $sdkPath = $defaultSdkPath  # Set to default path regardless of existence

    if (Test-Path $sdkPath) {
        Write-Output "Found Android SDK at: $sdkPath"
    } else {
        Write-Warning "Android SDK directory does not exist at: $sdkPath"
        Write-Output "Setting ANDROID_HOME to expected location: $sdkPath"
        Write-Output ""
        Write-Output "To install Android SDK:"
        Write-Output "  1. Download Android Studio from https://developer.android.com/studio"
        Write-Output "     (includes Android SDK, Android Virtual Device, and other tools)"
        Write-Output ""
        Write-Output "  2. Or install Command Line Tools only from https://developer.android.com/tools"
        Write-Output "     (minimal installation, you'll need to install additional packages using sdkmanager)"
        Write-Output ""
    }

    # ---------- Set Android environment variables ----------
    try {
        [Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkPath, "User")
        [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $sdkPath, "User")
    }
    catch {
        Write-Warning "Could not set user environment variables."
        Write-Output ""
        Write-Output "To set environment variables manually:"
        Write-Output "  1. Open System Properties -> Advanced -> Environment Variables"
        Write-Output "  2. Under 'User Variables', click 'New' and add:"
        Write-Output "     Variable: ANDROID_HOME"
        Write-Output "     Value: $sdkPath"
        Write-Output "  3. Find the 'Path' variable under User Variables and add these entries:"
        $pathsToAdd | ForEach-Object { Write-Output "     - $_" }
        Write-Output ""
    }

    # ---------- Collect Android PATH entries ----------
    $pathsToAdd = @(
        "$sdkPath\platform-tools",
        "$sdkPath\cmdline-tools\latest\bin"
    )

    # Add latest build-tools dynamically
    $buildToolsRoot = "$sdkPath\build-tools"
    if (Test-Path $buildToolsRoot) {
        $latestBuildTools = Get-ChildItem $buildToolsRoot |
            Sort-Object Name -Descending |
            Select-Object -First 1

        if ($latestBuildTools) {
            $pathsToAdd += $latestBuildTools.FullName
        }
    }

    # ---------- Set Java path (whether it exists or not) ----------
    $defaultJavaPath = "C:\Program Files\Android\Android Studio\jbr"
    $javaHome = $defaultJavaPath  # Set to default path regardless of existence

    if (Test-Path $javaHome) {
        Write-Output "Found Java at: $javaHome"
    } else {
        Write-Warning "Java directory does not exist at: $javaHome"
        Write-Output "Setting JAVA_HOME to expected location: $javaHome"
        Write-Output ""
        Write-Output "To install Java:"
        Write-Output "  1. Install Android Studio (includes bundled JDK)"
        Write-Output "     Download from: https://developer.android.com/studio"
        Write-Output ""
        Write-Output "  2. Or install a standalone JDK 17+ from OpenJDK or Oracle"
        Write-Output ""
    }

    # ---------- Set Java environment variables ----------
    try {
        [Environment]::SetEnvironmentVariable("JAVA_HOME", $javaHome, "User")
        $pathsToAdd += "$javaHome\bin"
    }
    catch {
        Write-Warning "Could not set JAVA_HOME environment variable."
        Write-Output ""
        Write-Output "To set JAVA_HOME manually:"
        Write-Output "  1. Open System Properties -> Advanced -> Environment Variables"
        Write-Output "  2. Under 'User Variables', click 'New' and add:"
        Write-Output "     Variable: JAVA_HOME"
        Write-Output "     Value: $javaHome"
        Write-Output "  3. Find the 'Path' variable under User Variables and add this entry:"
        Write-Output "     - $javaHome\bin"
        Write-Output ""
        $pathsToAdd += "$javaHome\bin"  # Still add to local array for PATH instructions
    }

    # ---------- Update User PATH safely ----------
    try {
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

        foreach ($p in $pathsToAdd) {
            if ($currentPath -notlike "*$p*") {
                $currentPath += ";$p"
            }
        }

        [Environment]::SetEnvironmentVariable("Path", $currentPath, "User")

        # ---------- Done ----------
        Write-Output "Android SDK and Java environment configured successfully."
        Write-Output "Environment variables have been set. Restart all terminals to apply changes."
        Write-Output ""
        Write-Output "Note: Directories were not verified to exist. Install the required software"
        Write-Output "to the configured paths for the environment variables to work properly."
    }
    catch {
        Write-Warning "Could not update user PATH."
        Write-Output ""
        Write-Output "To update PATH manually:"
        Write-Output "  1. Open System Properties -> Advanced -> Environment Variables"
        Write-Output "  2. Find the 'Path' variable under User Variables and click 'Edit'"
        Write-Output "  3. Click 'New' and add each of these entries:"
        $pathsToAdd | ForEach-Object { Write-Output "     - $_" }
        Write-Output ""
        Write-Output "Environment variables need to be set manually for the tools to work properly."
    }
}

# Function to run both configurations
function Start-CompleteSetup {
    <#
    .SYNOPSIS
        Runs both winget installation and SDK configuration.

    .DESCRIPTION
        This function runs both the winget installer to install applications
        and the SDK configuration to set up Android and Java environment.

    .EXAMPLE
        PS> Start-CompleteSetup
    #>

    Write-Host "Starting complete setup: winget installation and SDK configuration..." -ForegroundColor Green
    Write-Host ""

    Write-Host "Step 1: Running winget installation..." -ForegroundColor Yellow
    Start-WingetInstall

    Write-Host ""
    Write-Host "Step 2: Running SDK configuration..." -ForegroundColor Yellow
    Set-AndroidSDKConfig

    Write-Host ""
    Write-Host "Complete setup finished!" -ForegroundColor Green
    Write-Host "Note: Restart all terminals to apply environment variable changes." -ForegroundColor Cyan


    # Reload environment variables from the registry
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

   ## install qwen
   npm install -g @qwen-code/qwen-code@latest

}

function iqwen() {

  Write-Host "Checking for qwen-code installation..."

# Use npm list to check for global installation, suppress error output
npm list -g qwen-code | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "qwen-code not found. Installing now..."

   npm install -g @qwen-code/qwen-code@latest

    } else {
    Write-Host "qwen-code is already installed."
}


   $qpath = "$env:USERPROFILE/.qwen"
   if (!(Test-Path -PathType Container $qpath)) {
          New-Item -ItemType Directory -Path $qpath
     }

    # Download and decrypt the gpg files from GitHub

    $oauthCredsUrl = "https://github.com/melsiir/powerwin/raw/main/qwen/oauth_creds.json.gpg"
    $settingsUrl = "https://github.com/melsiir/powerwin/raw/main/qwen/settings.json.gpg"
    $oauthCredsDest = "$qpath/oauth_creds.json.gpg"
    $settingsDest = "$qpath/settings.json.gpg"

    # Download the encrypted files from GitHub to the .qwen directory
    try {
        Write-Host "Downloading oauth_creds.json.gpg from GitHub..." -ForegroundColor Green

        Invoke-RestMethod $oauthCredsUrl -OutFile $oauthCredsDest

        # Decrypt the file
        Invoke-Decrypt -FilePath $oauthCredsDest
    } catch {
        Write-Host "Warning: Could not download oauth_creds.json.gpg from GitHub. Error: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    try {
        Write-Host "Downloading settings.json.gpg from GitHub..." -ForegroundColor Green
        Invoke-WebRequest -Uri $settingsUrl -OutFile $settingsDest
        # Decrypt the file
        Invoke-Decrypt -FilePath $settingsDest
    } catch {
        Write-Host "Warning: Could not download settings.json.gpg from GitHub. Error: $($_.Exception.Message)" -ForegroundColor Yellow
    }

}

function cloneRepos {
    cd $HOME\Desktop
    git clone https://github.com/melsiir/cboard.git
  }

# Function to encrypt files with gpg
function Invoke-Encrypt {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [SecureString]$Passphrase
    )

    if (-not (Test-Path $FilePath)) {
        throw "Input file does not exist"
    }

    if (-not (Get-Command gpg -ErrorAction SilentlyContinue)) {
        throw "gpg not found in PATH"
    }

    if (-not $Passphrase) {
        $Passphrase = Read-Host -Prompt "Enter passphrase for encryption" -AsSecureString
    }

    $outputPath = "$FilePath.gpg"

    $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Passphrase)
    )

    try {
        $plain | gpg `
            --batch `
            --yes `
            --pinentry-mode loopback `
            --passphrase-fd 0 `
            --output $outputPath `
            --symmetric `
            $FilePath
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR(
            [Runtime.InteropServices.Marshal]::StringToBSTR($plain)
        )
    }

    if ($LASTEXITCODE -ne 0) {
        throw "GPG encryption failed"
    }
}

function Invoke-Decrypt {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [SecureString]$Passphrase
    )

    if (-not (Test-Path $FilePath)) {
        throw "Input file does not exist"
    }

    if ($FilePath -notmatch '\.gpg$') {
        throw "Input file does not have .gpg extension"
    }

    if (-not (Get-Command gpg -ErrorAction SilentlyContinue)) {
        throw "gpg not found in PATH"
    }

    if (-not $Passphrase) {
        $Passphrase = Read-Host -Prompt "Enter passphrase for decryption" -AsSecureString
    }

    $outputPath = $FilePath -replace '\.gpg$', ''

    $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Passphrase)
    )

    try {
        $plain | gpg `
            --batch `
            --yes `
            --pinentry-mode loopback `
            --passphrase-fd 0 `
            --output $outputPath `
            --decrypt `
            $FilePath
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR(
            [Runtime.InteropServices.Marshal]::StringToBSTR($plain)
        )
    }

    if ($LASTEXITCODE -ne 0) {
        throw "GPG decryption failed"
    }
}


# Quick File Creation
function nf { param($name) New-Item -ItemType "file" -Path . -Name $name }

# Directory Management
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }


# Enhanced Listing
function la { Get-ChildItem | Format-Table -AutoSize }
function ll { Get-ChildItem -Force | Format-Table -AutoSize }

# Git Shortcuts
function gs { git status }

function ga { git add . }

function gc { param($m) git commit -m "$m" }

function gpush { git push }

function gpull { git pull }


function gcl { git clone "$args" }

function gcom {
    git add .
    git commit -m "$args"
}
function lazyg {
    git add .
    git commit -m "$args"
    git push
}

function unzip ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}
# Navigation Shortcuts
function docs {
    $docs = if(([Environment]::GetFolderPath("MyDocuments"))) {([Environment]::GetFolderPath("MyDocuments"))} else {$HOME + "\Documents"}
    Set-Location -Path $docs
}

function dtop {
    $dtop = if ([Environment]::GetFolderPath("Desktop")) {[Environment]::GetFolderPath("Desktop")} else {$HOME + "\Documents"}
    Set-Location -Path $dtop
}

function u {
    explorer.exe $env:USERPROFILE
  }

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init --cmd z powershell | Out-String) })
} else {
    Write-Host "zoxide command not found. Attempting to install via winget..."
    try {
        winget install -e --id ajeetdsouza.zoxide
        Write-Host "zoxide installed successfully. Initializing..."
        Invoke-Expression (& { (zoxide init --cmd z powershell | Out-String) })
    } catch {
        Write-Error "Failed to install zoxide. Error: $_"
    }
}


# Aliases for convenience
Set-Alias winget-install Start-WingetInstall
Set-Alias sdk-config Set-AndroidSDKConfig
Set-Alias complete-setup Start-CompleteSetup
Set-Alias fresh Start-CompleteSetup
Set-Alias encrypt Invoke-Encrypt
Set-Alias decrypt Invoke-Decrypt

Write-Host "PowerShell profile loaded successfully!" -ForegroundColor Green
Write-Host "Available functions:" -ForegroundColor Cyan
Write-Host "  - Start-CompleteSetup (alias: complete-setup, fresh)" -ForegroundColor White
Write-Host "  - Invoke-Encrypt (alias: encrypt)" -ForegroundColor White
Write-Host "  - Invoke-Decrypt (alias: decrypt)" -ForegroundColor White
Write-Host ""
