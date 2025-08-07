# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script must be run with Administrator privileges. Please re-open PowerShell as an administrator and try again." -ForegroundColor Red
    exit
}

# --- Script Variables ---

# Replace 'YourGitHubUsername' and 'YourRepoName' with your actual GitHub details
$GitHubRepoUrl = "https://www.github.com/sh1nyfox/windows-terminal"
$WindowsTerminalSettingsFile = "$GitHubRepoUrl/settings.json"
$PowerShellProfileFile = "$GitHubRepoUrl/Microsoft.PowerShell_profile.ps1"
$StarshipConfigFile = "$GitHubRepoUrl/starship.toml"
$FastfetchConfigFile = "$GitHubRepoUrl/config.jsonc"

# --- Install Tools using winget ---

# Check if winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Windows Package Manager (winget) not found. Please install it first." -ForegroundColor Red
    exit
}

Write-Host "Installing PowerShell"
winget install --id Microsoft.PowerShell -e

Write-Host "Installing FiraCode Nerd Font..."
winget install --id dnf.FiraCodeNerdFont -e

Write-Host "Installing Fastfetch..."
winget install --id fastfetch.fastfetch -e

Write-Host "Installing Starship..."
winget install --id starship.starship -e

# --- Apply Configuration Files ---

Write-Host "Applying Windows Terminal settings..."
# The settings.json file is located in the Windows Terminal user settings directory
$TerminalSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Invoke-WebRequest -Uri $WindowsTerminalSettingsFile -OutFile $TerminalSettingsPath

Write-Host "Applying PowerShell profile..."
# The PowerShell profile file is located in the user's Documents directory
$PowerShellProfilePath = "$HOME\Documents\PowerShell"
# Check if the directory exists, create it if not
if (-not (Test-Path $PowerShellProfilePath)) {
    New-Item -Path $PowerShellProfilePath -ItemType Directory -Force
}
Invoke-WebRequest -Uri $PowerShellProfileFile -OutFile "$PowerShellProfilePath\Microsoft.PowerShell_profile.ps1"

Write-Host "Applying Starship configuration..."
# The Starship config file is located in the user's home directory
$StarshipConfigPath = "$HOME\.config"
if (-not (Test-Path $StarshipConfigPath)) {
    New-Item -Path $StarshipConfigPath -ItemType Directory -Force
}
Invoke-WebRequest -Uri $StarshipConfigFile -OutFile "$StarshipConfigPath\starship.toml"

Write-Host "Applying Fastfetch configuration..."
# The Fastfetch config is located in a similar .config directory
$FastfetchConfigPath = "$HOME\.config\fastfetch"
if (-not (Test-Path $FastfetchConfigPath)) {
    New-Item -Path $FastfetchConfigPath -ItemType Directory -Force
}
Invoke-WebRequest -Uri $FastfetchConfigFile -OutFile "$FastfetchConfigPath\config.json"

# --- Install and Configure WSL ---

Write-Host "Installing Fedora Linux 42 via WSL..."
# This command installs the core WSL components and Fedora 42 as the default distribution
wsl --install -d FedoraLinux-42

Write-Host "Setting WSL 2 as the default version..."
# Sets the default WSL version to 2
wsl --set-default-version 2

Write-Host "Setup complete. A system restart may be required for some changes to take effect."