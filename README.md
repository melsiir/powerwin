# PowerShell Profile for Windows Setup

This repository contains a PowerShell profile (`Microsoft.PowerShell_profile.ps1`) that automates the setup of development tools and environment configuration on Windows systems.

## installation

`irm "https://github.com/melsiir/winpower/raw/main/setup.ps1" | iex`

## Features

- **Automated Application Installation**: Uses `winget` to install commonly used applications including:
  - Google Chrome
  - Android Studio
  - Git
  - GitHub Desktop
  - PeaZip
  - Node.js
  - Visual Studio Code

- **Android SDK & Java Environment Configuration**: Automatically detects and configures:
  - ANDROID_HOME and ANDROID_SDK_ROOT environment variables
  - JAVA_HOME environment variable
  - Adds necessary paths to the system PATH

- **Qwen Integration**: Includes installation of the Qwen Code CLI tool

## Usage

Once installed, the profile provides several functions:

- `Start-CompleteSetup` (aliases: `complete-setup`, `fresh`): Runs both winget installation and SDK configuration
- `Start-WingetInstall` (alias: `winget-install`): Installs applications using winget
- `Set-AndroidSDKConfig` (alias: `sdk-config`): Configures Android SDK and Java environment
- `iqwen`: Installs the Qwen Code CLI tool

## Prerequisites

- Windows 10/11
- PowerShell 5.1 or later
- Winget package manager (comes with Windows Package Manager)
- Internet connection for downloading packages

## Security Note

This profile includes scripts that install software and modify environment variables. Review the code before running it on your system.

## > [!IMPORTANT]

> the install script borrowed from chrisTitus
