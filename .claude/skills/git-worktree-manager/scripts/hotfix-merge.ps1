# hotfix-merge.ps1 - Fast-track with fallback
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

param(
    [Parameter(Mandatory=$true)]
    [string]$HotfixBranch,

    [string]$WorkspaceRoot = "C:\ws"
)

$projectName = (Get-Item .).Name
$mainPath = "$WorkspaceRoot\$projectName\main"

Push-Location $mainPath

try {
    Write-Host "🚨 HOTFIX MERGE: $HotfixBranch" -ForegroundColor Red

    # Update main
    git fetch origin
    git pull --rebase origin main

    # Attempt FF merge
    Write-Host "Attempting fast-forward merge..." -ForegroundColor Yellow
    git merge --ff-only $HotfixBranch

    if ($LASTEXITCODE -ne 0) {
        # Fallback: Regular merge
        Write-Warning "Fast-forward failed. Creating merge commit..."

        git merge $HotfixBranch -m "Merge hotfix: $HotfixBranch

HOTFIX - Emergency deployment
FF merge failed due to divergence

Commits:
$(git log --oneline main..$HotfixBranch)
"
        if ($LASTEXITCODE -ne 0) {
            throw "Merge failed. Resolve conflicts manually."
        }
    }

    # Quick smoke test
    .\.venv\Scripts\Activate.ps1
    pytest -k smoke --tb=line

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Smoke tests failed. Abort deployment!"
        git reset --hard HEAD~1
        exit 1
    }

    # Tag for rollback
    $tagName = "hotfix-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    git tag $tagName
    Write-Host "✓ Tagged: $tagName" -ForegroundColor Green

    # Push
    git push origin main
    git push origin $tagName

    Write-Host "✓ Hotfix deployed!" -ForegroundColor Green
    Write-Host "`nRollback command:" -ForegroundColor Yellow
    Write-Host "  git reset --hard $tagName~1" -ForegroundColor Gray
    Write-Host "  git push origin main --force" -ForegroundColor Gray

} catch {
    Write-Error "Hotfix failed: $_"
    Write-Host "`nManual steps:" -ForegroundColor Yellow
    Write-Host "  1. Resolve conflicts"
    Write-Host "  2. git add ."
    Write-Host "  3. git commit"
    Write-Host "  4. pytest -k smoke"
    Write-Host "  5. git push origin main"
} finally {
    Pop-Location
}
