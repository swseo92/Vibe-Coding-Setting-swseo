# Install Git hooks from .githooks/ to .git/hooks/
# This script should be run from project root
# Usage: .\.claude\scripts\install-hooks.ps1

$ErrorActionPreference = "Stop"

Write-Host "Installing Git hooks..." -ForegroundColor Cyan

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Host "Error: Not a git repository" -ForegroundColor Red
    Write-Host "Please run this script from project root" -ForegroundColor Yellow
    exit 1
}

# Check if .githooks directory exists
if (-not (Test-Path ".githooks")) {
    Write-Host "Error: .githooks directory not found" -ForegroundColor Red
    Write-Host "Expected location: .\.githooks\" -ForegroundColor Yellow
    exit 1
}

# Create .git/hooks if it doesn't exist
$hooksDir = ".git\hooks"
if (-not (Test-Path $hooksDir)) {
    New-Item -ItemType Directory -Path $hooksDir | Out-Null
}

# Install each hook
$installed = 0
$skipped = 0

Get-ChildItem ".githooks" -File | ForEach-Object {
    $hookName = $_.Name

    # Skip README or documentation files
    if ($hookName -like "README*" -or $hookName -like "*.md") {
        return
    }

    $target = Join-Path $hooksDir $hookName

    # Check if hook already exists
    if (Test-Path $target) {
        Write-Host "Warning: $hookName already exists" -ForegroundColor Yellow
        $response = Read-Host "Overwrite? (y/n)"
        if ($response -ne "y" -and $response -ne "Y") {
            Write-Host "Skipped $hookName" -ForegroundColor Gray
            $script:skipped++
            return
        }
    }

    # Copy hook
    Copy-Item $_.FullName $target -Force
    Write-Host "Installed: $hookName" -ForegroundColor Green
    $script:installed++
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "- Installed: $installed hooks"
Write-Host "- Skipped: $skipped hooks"
Write-Host ""
Write-Host "Git hooks installation complete" -ForegroundColor Green
Write-Host ""
Write-Host "Note: On Windows, Git Bash will execute these hooks."
Write-Host "To bypass a hook temporarily, use: git commit --no-verify"
