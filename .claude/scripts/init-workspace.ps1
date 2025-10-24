# init-workspace.ps1 - Initialize workspace from language template
# Usage: init-workspace.ps1 <temp-dir> <language> [additional-requirements]
# Or: init-workspace.ps1 <language> [additional-requirements] (will clone)

param(
    [Parameter(Mandatory=$true)]
    [string]$FirstArg,

    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"

# Check if first argument is a directory (TEMP_DIR passed from command)
if (Test-Path $FirstArg -PathType Container) {
    $TemplatesPath = Join-Path $FirstArg "templates"
    if (Test-Path $TemplatesPath) {
        $TempDir = $FirstArg
        $Language = $RemainingArgs[0]
        $AdditionalRequirements = $RemainingArgs[1..($RemainingArgs.Length-1)]
        $Cleanup = $false
        Write-Host "Using provided repository: $TempDir" -ForegroundColor Cyan
    } else {
        # Not a valid repo directory, treat as language
        $Language = $FirstArg
        $AdditionalRequirements = $RemainingArgs
        $Cleanup = $true
    }
} else {
    # First arg is not a directory, treat as language
    $Language = $FirstArg
    $AdditionalRequirements = $RemainingArgs
    $Cleanup = $true
}

if ($Cleanup) {
    Write-Host "Initializing workspace for language: $Language" -ForegroundColor Cyan

    # Create temporary directory
    $TempDir = New-Item -ItemType Directory -Path "$env:TEMP\vibe-coding-$(Get-Random)"
    Write-Host "Created temporary directory: $TempDir" -ForegroundColor Gray

    # Clone the settings repository
    Write-Host "Cloning Vibe-Coding-Setting-swseo repository..." -ForegroundColor Gray
    try {
        git clone https://github.com/swseo92/Vibe-Coding-Setting-swseo.git $TempDir 2>&1 | Out-Null
    } catch {
        Write-Host "Error: Failed to clone repository" -ForegroundColor Red
        Remove-Item -Recurse -Force $TempDir
        exit 1
    }
}

# Check if language template exists
$TemplatePath = Join-Path $TempDir "templates\$Language"
if (-not (Test-Path $TemplatePath)) {
    Write-Host "Error: Template for '$Language' not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available templates:" -ForegroundColor Yellow
    Get-ChildItem (Join-Path $TempDir "templates") -Directory |
        Where-Object { $_.Name -ne "common" } |
        ForEach-Object { Write-Host "  - $($_.Name)" }
    Remove-Item -Recurse -Force $TempDir
    exit 1
}

# Copy common files first (hidden files included)
$CommonPath = Join-Path $TempDir "templates\common"
if (Test-Path $CommonPath) {
    Write-Host "Copying common files..." -ForegroundColor Gray
    Get-ChildItem -Path $CommonPath -Force -Recurse | ForEach-Object {
        $RelativePath = $_.FullName.Substring($CommonPath.Length + 1)
        $TargetPath = Join-Path (Get-Location) $RelativePath

        if ($_.PSIsContainer) {
            New-Item -ItemType Directory -Force -Path $TargetPath | Out-Null
        } else {
            $TargetDir = Split-Path -Parent $TargetPath
            if (-not (Test-Path $TargetDir)) {
                New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
            }
            Copy-Item -Force $_.FullName $TargetPath
        }
    }
    Write-Host "✓ Common files copied (.specify/, .mcp.json)" -ForegroundColor Green
}

# Copy language-specific template files (hidden files included)
Write-Host "Copying $Language template files..." -ForegroundColor Gray
Get-ChildItem -Path $TemplatePath -Force -Recurse | ForEach-Object {
    $RelativePath = $_.FullName.Substring($TemplatePath.Length + 1)
    $TargetPath = Join-Path (Get-Location) $RelativePath

    if ($_.PSIsContainer) {
        New-Item -ItemType Directory -Force -Path $TargetPath | Out-Null
    } else {
        $TargetDir = Split-Path -Parent $TargetPath
        if (-not (Test-Path $TargetDir)) {
            New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
        }
        Copy-Item -Force $_.FullName $TargetPath
    }
}
Write-Host "✓ Template files copied successfully" -ForegroundColor Green

# Clean up temporary directory (only if we created it)
if ($Cleanup) {
    Remove-Item -Recurse -Force $TempDir
    Write-Host "✓ Cleanup completed" -ForegroundColor Green
}

# Get project name from current directory
$ProjectName = Split-Path -Leaf (Get-Location)
Write-Host ""
Write-Host "Project name detected: $ProjectName" -ForegroundColor Cyan

# Language-specific post-processing
switch ($Language) {
    "python" {
        # Update project name in Python files
        $OldSrcPath = "src\myproject"
        $NewSrcPath = "src\$ProjectName"
        if (Test-Path $OldSrcPath) {
            Move-Item $OldSrcPath $NewSrcPath -Force
            Write-Host "✓ Renamed src\myproject → src\$ProjectName" -ForegroundColor Green
        }

        # Update pyproject.toml
        $PyProjectPath = "pyproject.toml"
        if (Test-Path $PyProjectPath) {
            $Content = Get-Content $PyProjectPath -Raw
            $Content = $Content -replace 'name = "myproject"', "name = `"$ProjectName`""
            $Content = $Content -replace 'packages = \[{include = "myproject"', "packages = [{include = `"$ProjectName`""
            Set-Content -Path $PyProjectPath -Value $Content
            Write-Host "✓ Updated pyproject.toml with project name" -ForegroundColor Green
        }
    }
    "javascript" {
        # Future: Update package.json
        Write-Host "✓ JavaScript template applied" -ForegroundColor Green
    }
}

# Display success message
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║          ✅ Workspace Initialized Successfully             ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Language:      $Language" -ForegroundColor Cyan
Write-Host "Project Name:  $ProjectName" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files Created:" -ForegroundColor Yellow

# List key files
if (Test-Path ".specify") {
    Write-Host "  ✓ .specify/          (Speckit templates & scripts)"
}
if (Test-Path ".mcp.json") {
    Write-Host "  ✓ .mcp.json          (MCP server configuration)"
}

switch ($Language) {
    "python" {
        Write-Host "  ✓ pyproject.toml     (uv package configuration)"
        Write-Host "  ✓ pytest.ini         (pytest configuration)"
        Write-Host "  ✓ src\$ProjectName\ (main package)"
        Write-Host "  ✓ tests\             (unit/integration/e2e)"
        Write-Host "  ✓ docs\              (documentation)"
        Write-Host "  ✓ .github\workflows\ (CI/CD)"
        Write-Host "  ✓ .pre-commit-config.yaml"
    }
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host ""

switch ($Language) {
    "python" {
        Write-Host "1. Install dependencies:"
        Write-Host "   PS> uv sync" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. Install pre-commit hooks:"
        Write-Host "   PS> uv run pre-commit install" -ForegroundColor Gray
        Write-Host ""
        Write-Host "3. Run tests:"
        Write-Host "   PS> uv run pytest" -ForegroundColor Gray
        Write-Host ""
    }
}

Write-Host "4. Initialize git (if needed):"
Write-Host "   PS> git init" -ForegroundColor Gray
Write-Host "   PS> git add ." -ForegroundColor Gray
Write-Host "   PS> git commit -m `"Initial commit from template`"" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Review and customize:"
Write-Host "   - Update README.md with project details"
Write-Host "   - Configure .env (see .env.example)"
Write-Host "   - Review docs\testing_guidelines.md"
Write-Host ""

if ($AdditionalRequirements) {
    $Requirements = $AdditionalRequirements -join " "
    Write-Host "Additional requirements noted: $Requirements" -ForegroundColor Yellow
    Write-Host "Please handle these manually or ask Claude Code for help."
    Write-Host ""
}

Write-Host "Happy coding! 🚀" -ForegroundColor Cyan
