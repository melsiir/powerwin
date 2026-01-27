# PowerShell Profile for Windows
# Contains functions for winget installation and SDK configuration



$ConfigPath = "$HOME\Documents\PowerShell\profiles"

# Import all .ps1 files in that folder
Get-ChildItem $ConfigPath -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

if (Test-Path $ConfigPath) {
    # Import all .ps1 files in that folder
    Get-ChildItem $ConfigPath -Filter *.ps1 | ForEach-Object {
        . $_.FullName
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
    Write-Host ""
    Write-Host "gh auth"
    ghAuth

   ## install qwen
   npm install -g @qwen-code/qwen-code@latest
   ## install qr code module
   iqr

}


# github secret
function ghAuth {

   $githubPath = "$env:USERPROFILE/github"
   if (!(Test-Path -PathType Container $githubPath)) {
          New-Item -ItemType Directory -Path $githubPath
     }

    $passphrase = Read-Host `
        -Prompt "Enter passphrase for all files: " `
        -AsSecureString

   $ghSecretPathEnc = "$env:USERPROFILE/github/ghs.gpg"
   $ghSecretPath = "$env:USERPROFILE/github/ghs"
   $ghSecretUrl = "https://github.com/melsiir/powerwin/raw/main/github/ghs.gpg"
   Invoke-RestMethod $ghSecretUrl -OutFile $ghSecretPathEnc
   Invoke-Decrypt -FilePath $ghSecretPathEnc -Passphrase $passphrase
   Get-Content $ghSecretPath | gh auth login --with-token
   Remove-Item $ghSecretPath

   # username and email
   $identityPathEnc =  "$env:USERPROFILE/github/identity.gpg"
   $identityPath =  "$env:USERPROFILE/github/identity"
   $identityUrl = "https://github.com/melsiir/powerwin/raw/main/github/identity.gpg"
   Invoke-RestMethod $identityUrl -OutFile $identityPathEnc
   Invoke-Decrypt -FilePath $identityPathEnc -Passphrase $passphrase

   $lines = Get-Content $identityPath

   $email = $lines[0]
   $name  = $lines[1]
   git config --global user.email "$email"
   git config --global user.name "$name"
  }

function ccc {
    cd $HOME\Desktop
    git clone https://github.com/melsiir/goboard.git
     cd $HOME\Desktop\goboard
  }

function cc {
     cd $HOME\Desktop\goboard

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

    Write-Host "Decrypting $FilePath"

    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Passphrase)
    try {
        $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)

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
        if ($bstr -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }

    if ($LASTEXITCODE -ne 0) {
        throw "GPG decryption failed"
    }

    Write-Host "Decryption complete: $outputPath"
}

function transfer {
    param(
        [string]$file
    )

    # Check if file argument is provided
    if (-not $file) {
        Write-Error "No arguments specified. Usage: transfer <file|directory>"
        return
    }

    # Check if the file exists
    $fileName = [System.IO.Path]::GetFileName($file)
    if (-not (Test-Path $file)) {
        Write-Error "${file}: No such file or directory"
        return
    }

    # If it's a directory, zip it first
    if (Test-Path $file -PathType Container) {

        # Directory
        # $dirName  = [System.IO.Path]::GetFileName($file.TrimEnd([System.IO.Path]::DirectorySeparatorChar))
        #
        # $zipName  = "$dirName.zip"
        # $tempFile = Join-Path $env:TEMP $zipName

#-------------
        $fileName = "$fileName.zip"
        $tempFile = [System.IO.Path]::Combine($env:TEMP, $fileName)
#-------------
        # Compress the directory to a temporary zip file
        try {
            Compress-Archive -Path $file -DestinationPath $tempFile -Force
        }
        catch {
            Write-Error "Failed to compress the directory."
            return
        }

        # Upload the compressed file
        $uploadUrl = "https://transfer.whalebone.io/$fileName"
        $uploadedUrl = curl.exe --progress-bar --upload-file $tempFile $uploadUrl


    }
    else {
        # If it's a file, upload it directly
        $uploadUrl = "https://transfer.whalebone.io/$fileName"
        $uploadedUrl = curl.exe --progress-bar --upload-file $file $uploadUrl
    }

    $commandName = "ConvertTo-QrCode"
    if (Get-Command $commandName -ErrorAction SilentlyContinue) {
       echo $uploadedUrl
       echo ""
        ConvertTo-QrCode $uploadedUrl | Format-QRCode
    } else {
       echo $uploadedUrl
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

function gb {

    .\gradlew.bat assembledebug
  }

function  gbl {
    .\gradlew.bat assembledebug > build_log.txt 2>&1
    }


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
        winget install -e --id ajeetdsouza.zoxide  --accept-package-agreements --accept-source-agreements
        Write-Host "zoxide installed successfully. Initializing..."

        $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        Invoke-Expression (& { (zoxide init --cmd z powershell | Out-String) })

    } catch {
        Write-Error "Failed to install zoxide. Error: $_"
    }
}

if (-not (Get-Command -Name 'gpg' -ErrorAction SilentlyContinue)) {
## for now run complete setup with zoxide but may remove it later
  Start-CompleteSetup
  } else {
      Write-Host "gpg is installed and ready to use."
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
