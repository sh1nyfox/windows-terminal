# ==============================================================================
#                 Windows Terminal Environment Setup Script
# ==============================================================================
#
# This script automates the setup of a complete terminal environment on Windows.
# It installs PowerShell, necessary fonts, and modern tools like Starship and
# Fastfetch. It also sets up WSL with Fedora.
#
# Prerequisites:
# - Windows 10 version 2004 or higher, or Windows 11.
# - The script must be run with Administrator privileges.
#
# ==============================================================================

# --- Stop on any error ---
$ErrorActionPreference = 'Stop'

# --- Administrator Check ---
# Verifies that the script is running in an elevated PowerShell session.
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script must be run with Administrator privileges."
    Write-Warning "Please re-open PowerShell as an Administrator and run the script again."
    # The 'exit' keyword is used to terminate the script immediately.
    exit 1
}

# --- Helper Function for Executing Commands ---
# This function runs an external command (like winget or wsl) and checks its
# exit code. If the command fails (exit code is not 0), it writes an error
# and stops the script.
function Invoke-CommandAndCheck {
    param(
        [string]$Executable,
        [string]$Arguments
    )
    
    Write-Host "Running command: $Executable $Arguments" -ForegroundColor Cyan
    & $Executable $Arguments
    
    # $LASTEXITCODE holds the exit code of the last native application that was run.
    # A value of 0 typically means success.
    if ($LASTEXITCODE -ne 0) {
        Write-Error "$Executable command failed with exit code $LASTEXITCODE."
        # Stop the script. The error message above will be the last thing displayed.
        exit 1
    }
    Write-Host "$Executable command completed successfully." -ForegroundColor Green
}


# --- Script Variables ---
# These variables define the URLs and paths for the configuration files.
# We use raw.githubusercontent.com to get the actual file content.
$GitHubUser = "sh1nyfox"
$GitHubRepo = "windows-terminal"
$GitHubBranch = "main" # Or whichever branch your files are on
$GitHubRawContentUrlBase = "https://raw.githubusercontent.com/$GitHubUser/$GitHubRepo/$GitHubBranch"

# Configuration file URLs
$WindowsTerminalSettingsFileUrl = "$GitHubRawContentUrlBase/settings.json"
$PowerShellProfileFileUrl = "$GitHubRawContentUrlBase/Microsoft.PowerShell_profile.ps1"
$StarshipConfigFileUrl = "$GitHubRawContentUrlBase/starship.toml"
$FastfetchConfigFileUrl = "$GitHubRawContentUrlBase/config.jsonc"

# --- 1. Install Tools using winget ---
# We use Windows Package Manager (winget) to install command-line tools.
# The `-e` flag ensures the exact package ID is matched.
# The `--accept-source-agreements` and `--accept-package-agreements` flags
# automate the installation by accepting any prompts.

Write-Host "--- Starting Tool Installation using winget ---" -ForegroundColor Yellow

# Check if winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "Windows Package Manager (winget) not found. Please install it from the Microsoft Store."
    exit 1
}

# Install PowerShell
winget install --id Microsoft.PowerShell -e 

# Install FiraCode Nerd Font for icons and glyphs in the terminal
winget install --id FiraCode.FiraCodeNerdFont -e

# Install Fastfetch for system information display
winget install --id fastfetch-cli.fastfetch -e

# Install Starship for a custom shell prompt
winget install --id Starship.Starship -e


# --- 2. Apply Configuration Files ---
# This section downloads your custom configuration files from GitHub and places
# them in the correct directories.

Write-Host "--- Applying Configuration Files ---" -ForegroundColor Yellow

try {
    # --- Apply PowerShell Profile ---
    Write-Host "Applying PowerShell profile..."
    # The $PROFILE variable automatically points to the correct path.
    $ProfileDirectory = Split-Path -Path $PROFILE -Parent
    if (-not (Test-Path -Path $ProfileDirectory)) {
        Write-Host "Creating profile directory: $ProfileDirectory"
        New-Item -Path $ProfileDirectory -ItemType Directory -Force | Out-Null
    }
    Invoke-WebRequest -Uri $PowerShellProfileFileUrl -OutFile $PROFILE
    Write-Host "PowerShell profile applied." -ForegroundColor Green

    # --- Apply Starship Configuration ---
    Write-Host "Applying Starship configuration..."
    $StarshipConfigPath = Join-Path $HOME ".config"
    if (-not (Test-Path -Path $StarshipConfigPath)) {
        Write-Host "Creating Starship config directory: $StarshipConfigPath"
        New-Item -Path $StarshipConfigPath -ItemType Directory -Force | Out-Null
    }
    Invoke-WebRequest -Uri $StarshipConfigFileUrl -OutFile (Join-Path $StarshipConfigPath "starship.toml")
    Write-Host "Starship configuration applied." -ForegroundColor Green

    # --- Apply Fastfetch Configuration ---
    Write-Host "Applying Fastfetch configuration..."
    $FastfetchParentPath = Join-Path $HOME ".config"
    $FastfetchConfigPath = Join-Path $FastfetchParentPath "fastfetch"
    
    # Use -Force to ensure the full path is created even if .config doesn't exist
    if (-not (Test-Path -Path $FastfetchConfigPath)) {
        Write-Host "Creating Fastfetch config directory: $FastfetchConfigPath"
        New-Item -Path $FastfetchConfigPath -ItemType Directory -Force | Out-Null
    }
    
    # The config file must be named 'config.jsonc' to support comments.
    Invoke-WebRequest -Uri $FastfetchConfigFileUrl -OutFile (Join-Path $FastfetchConfigPath "config.jsonc")
    Write-Host "Fastfetch configuration applied." -ForegroundColor Green

} catch {
    # If any of the Invoke-WebRequest or New-Item commands fail, this block will run.
    Write-Error "Failed to download or apply a configuration file."
    Write-Error $_.Exception.Message
    exit 1
}


# --- 3. Install and Configure WSL ---
# This section installs the Windows Subsystem for Linux and the Fedora distribution.

Write-Host "--- Setting up WSL and Fedora ---" -ForegroundColor Yellow

# Install WSL and Fedora. The name 'Fedora' is the correct one from the Microsoft Store.
# The install command handles enabling the required Windows features.
Invoke-CommandAndCheck "wsl" "--install -d Fedora"

# Sets the default WSL version to 2 for any future installations.
# This is often the default already, but it's good to be explicit.
Invoke-CommandAndCheck "wsl" "--set-default-version 2"


# --- Final Message ---
Write-Host "======================================================" -ForegroundColor Green
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host "A system restart may be required for all changes, especially WSL, to take effect."
Write-Host "After restarting, open Windows Terminal to see your new setup."
Write-Host "======================================================" -ForegroundColor Green