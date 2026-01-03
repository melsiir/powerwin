# Ensure the script can run with elevated privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    break
}

# Set-ExecutionPolicy Bypass -Scope Process -Force

# Helper function for cross-editio compatibility
function Get-ProfileDir {
    if ($PSVersionTable.PSEdition -eq "Core") {
        return "$env:userprofile\Documents\PowerShell"
    } elseif ($PSVersionTable.PSEdition -eq "Desktop") {
        return "$env:userprofile\Documents\WindowsPowerShell"
    } else {
        Write-Error "Unsupported PowerShell edition: $($PSVersionTable.PSEdition)"
        break
    }
}
# Profile creation or update
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        $profilePath = Get-ProfileDir
        if (!(Test-Path -Path $profilePath)) {
            New-Item -Path $profilePath -ItemType "directory" -Force
        }
        Invoke-RestMethod https://github.com/melsiir/powerwin/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created."
        Write-Host "If you want to make any personal changes or customizations, please do so at [$profilePath\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes"
    }
    catch {
        Write-Error "Failed to create or update the profile. Error: $_"
    }
}
else {
    try {
        $backupPath = Join-Path (Split-Path $PROFILE) "oldprofile.ps1"
        Move-Item -Path $PROFILE -Destination $backupPath -Force
        Invoke-RestMethod https://github.com/melsiir/powerwin/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        Write-Host "✅ PowerShell profile at [$PROFILE] has been updated."
        Write-Host "📦 Your old profile has been backed up to [$backupPath]"
        Write-Host "⚠️ NOTE: Please back up any persistent components of your old profile to [$HOME\Documents\PowerShell\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes"
    }
    catch {
        Write-Error "❌ Failed to backup and update the profile. Error: $_"
    }
}

# Final check and message to the user
if (Test-Path -Path $PROFILE)  {
    Write-Host "Setup completed successfully. Please restart your PowerShell session to apply changes."
} else {
    Write-Warning "Setup completed with errors. Please check the error messages above."
}
