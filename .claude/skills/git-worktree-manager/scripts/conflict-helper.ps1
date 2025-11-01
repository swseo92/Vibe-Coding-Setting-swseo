# conflict-helper.ps1 - Conservative conflict assistance
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Conflict Helper (Conservative Mode)" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan

# Validate file exists
if (-not (Test-Path $FilePath)) {
    Write-Error "File not found: $FilePath"
    exit 1
}

# Check if file has conflict markers
$content = Get-Content $FilePath -Raw
if ($content -notmatch '<<<<<<< HEAD') {
    Write-Warning "No conflict markers found in: $FilePath"
    Write-Host "File may already be resolved or does not have conflicts."
    exit 0
}

Write-Host "`nConflict detected in: $FilePath" -ForegroundColor Yellow
Write-Host ""

# Display conflict preview
Write-Host "Conflict preview (first 10 lines):" -ForegroundColor Gray
Get-Content $FilePath | Select-Object -First 10 | ForEach-Object {
    if ($_ -match '<<<<<<< HEAD') {
        Write-Host $_ -ForegroundColor Red
    } elseif ($_ -match '=======') {
        Write-Host $_ -ForegroundColor Yellow
    } elseif ($_ -match '>>>>>>> ') {
        Write-Host $_ -ForegroundColor Green
    } else {
        Write-Host $_
    }
}

Write-Host "`n..." -ForegroundColor Gray
Write-Host ""

# Resolution options
Write-Host "Resolution options:" -ForegroundColor Cyan
Write-Host "  1. Open in PyCharm (RECOMMENDED)" -ForegroundColor White
Write-Host "     - Use PyCharm's 3-way merge tool" -ForegroundColor Gray
Write-Host "     - Visual diff comparison" -ForegroundColor Gray
Write-Host "     - Safest option" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Get AI suggestion (Manual apply ONLY)" -ForegroundColor White
Write-Host "     - Uses Codex CLI to analyze conflict" -ForegroundColor Gray
Write-Host "     - Provides suggestion for review" -ForegroundColor Gray
Write-Host "     - YOU must manually apply changes" -ForegroundColor Gray
Write-Host "     - ⚠️  NEVER auto-applied" -ForegroundColor Red
Write-Host ""
Write-Host "  3. Manual resolution" -ForegroundColor White
Write-Host "     - Edit file directly" -ForegroundColor Gray
Write-Host "     - git add . && git rebase --continue" -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "Choose option (1/2/3)"

switch ($choice) {
    '1' {
        # Open in PyCharm
        Write-Host "`nOpening in PyCharm..." -ForegroundColor Cyan

        # Try to find PyCharm executable
        $pycharmPaths = @(
            "${env:ProgramFiles}\JetBrains\PyCharm*\bin\pycharm64.exe",
            "${env:LOCALAPPDATA}\Programs\PyCharm*\bin\pycharm64.exe"
        )

        $pycharmExe = $null
        foreach ($pattern in $pycharmPaths) {
            $found = Get-Item $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) {
                $pycharmExe = $found.FullName
                break
            }
        }

        if ($pycharmExe) {
            & $pycharmExe (Resolve-Path $FilePath).Path
            Write-Host "✓ PyCharm opened with: $FilePath" -ForegroundColor Green
            Write-Host "`nAfter resolving in PyCharm:" -ForegroundColor Yellow
            Write-Host "  git add $FilePath"
            Write-Host "  git rebase --continue"
        } else {
            Write-Warning "PyCharm not found. Opening with default editor..."
            Invoke-Item $FilePath
        }
    }

    '2' {
        # AI suggestion (if Codex CLI available)
        Write-Host "`n⚠️  AI SUGGESTION MODE (MANUAL APPLY ONLY)" -ForegroundColor Red
        Write-Host ""

        if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
            Write-Error "Codex CLI not found. Install from: https://github.com/openai/openai-codex"
            Write-Host "`nFallback to manual resolution:"
            Write-Host "  1. Edit: $FilePath"
            Write-Host "  2. git add $FilePath"
            Write-Host "  3. git rebase --continue"
            exit 1
        }

        Write-Host "Analyzing conflict with AI..." -ForegroundColor Cyan

        $prompt = @"
This file has a git merge conflict. Analyze the conflict and suggest a resolution.

File: $FilePath

Conflict content:
$content

Please provide:
1. Analysis of what changed in both branches
2. Suggested resolution (preserve intent of both changes if possible)
3. Confidence level (Low/Medium/High)

IMPORTANT: This is a suggestion ONLY. The user will manually review and apply.
"@

        Write-Host "`nQuerying AI..." -ForegroundColor Gray
        $suggestion = $prompt | codex exec

        Write-Host "`n╔════════════════════════════════════════════════╗" -ForegroundColor Yellow
        Write-Host "║  AI SUGGESTION (REVIEW CAREFULLY!)            ║" -ForegroundColor Yellow
        Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Yellow
        Write-Host ""
        Write-Host $suggestion
        Write-Host ""
        Write-Host "⚠️  DO NOT BLINDLY APPLY THIS SUGGESTION!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "  1. Review the AI suggestion above"
        Write-Host "  2. Manually edit: $FilePath"
        Write-Host "  3. Apply only if you understand and agree"
        Write-Host "  4. git add $FilePath"
        Write-Host "  5. git rebase --continue"
    }

    '3' {
        # Manual resolution
        Write-Host "`nManual resolution steps:" -ForegroundColor Cyan
        Write-Host "  1. Edit the file: $FilePath" -ForegroundColor White
        Write-Host "  2. Remove conflict markers (<<<<<<, =======, >>>>>>>)"
        Write-Host "  3. Combine changes as needed"
        Write-Host "  4. Save the file"
        Write-Host "  5. Stage changes: git add $FilePath"
        Write-Host "  6. Continue rebase: git rebase --continue"
        Write-Host ""
        Write-Host "Opening file in default editor..."
        Invoke-Item $FilePath
    }

    default {
        Write-Warning "Invalid choice. Exiting."
        exit 1
    }
}

Write-Host "`n✓ Conflict helper completed" -ForegroundColor Green
Write-Host ""
Write-Host "Remember:" -ForegroundColor Yellow
Write-Host "  • Test after resolving conflicts"
Write-Host "  • Review changes carefully"
Write-Host "  • git rerere will remember this resolution for future conflicts"
