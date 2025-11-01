# cleanup-worktree.ps1 - Hardened version
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

param(
    [Parameter(Mandatory=$true)]
    [string]$BranchName,

    [switch]$KeepDB,
    [switch]$Force,
    [string]$WorkspaceRoot = "C:\ws"
)

try {
    $projectName = (Get-Item .).Name
    $worktreePath = "$WorkspaceRoot\$projectName\$BranchName"

    # Validate worktree exists
    if (-not (Test-Path $worktreePath)) {
        Write-Warning "Worktree not found: $worktreePath"

        # Check if git knows about it
        $gitWorktrees = git worktree list --porcelain
        if ($gitWorktrees -match $BranchName) {
            Write-Host "Git worktree entry found. Attempting prune..."
            git worktree prune
        }
        return
    }

    # Confirm deletion
    if (-not $Force) {
        Write-Host "About to remove worktree: $worktreePath" -ForegroundColor Yellow
        $confirm = Read-Host "Continue? (Y/N)"
        if ($confirm -ne 'Y') {
            Write-Host "Aborted by user."
            return
        }
    }

    # ═══════════════════════════════════════════
    # Phase 1: DB Archiving
    # ═══════════════════════════════════════════
    $dbPath = "$worktreePath\db-$BranchName.sqlite3"
    if ((Test-Path $dbPath) -and -not $KeepDB) {
        Write-Host "Archiving database..." -ForegroundColor Cyan

        $archiveDir = ".\db-archives"
        New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null

        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $archivePath = "$archiveDir\db-$BranchName-$timestamp.sqlite3"

        Copy-Item $dbPath $archivePath -ErrorAction Stop
        Write-Host "✓ Database archived: $archivePath" -ForegroundColor Green
    }

    # ═══════════════════════════════════════════
    # Phase 2: Close File Handles (Windows)
    # ═══════════════════════════════════════════
    Write-Host "Checking for open file handles..." -ForegroundColor Cyan

    # Wait for PyCharm/Git to release handles
    $maxRetries = 3
    $retryCount = 0

    while ($retryCount -lt $maxRetries) {
        try {
            # Try to remove .venv (most likely locked)
            if (Test-Path "$worktreePath\.venv") {
                Remove-Item "$worktreePath\.venv" -Recurse -Force -ErrorAction Stop
            }
            # Break after successful removal or if .venv doesn't exist
            break
        } catch {
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Write-Warning "Files are locked. Retrying in 5 seconds... ($retryCount/$maxRetries)"
                Start-Sleep -Seconds 5
            } else {
                Write-Warning "Files still locked after $maxRetries attempts."
                Write-Warning "Close PyCharm and retry, or use --Force to ignore."
                if (-not $Force) {
                    throw "Cannot remove locked files"
                }
            }
        }
    }

    # ═══════════════════════════════════════════
    # Phase 3: Git Worktree Removal
    # ═══════════════════════════════════════════
    Write-Host "Removing git worktree..." -ForegroundColor Cyan

    git worktree remove $worktreePath --force
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "git worktree remove failed. Trying prune..."
        git worktree prune
    }

    # ═══════════════════════════════════════════
    # Phase 4: Filesystem Cleanup
    # ═══════════════════════════════════════════
    if (Test-Path $worktreePath) {
        Write-Host "Cleaning up filesystem..." -ForegroundColor Cyan
        Remove-Item -Path $worktreePath -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "`n✓ Worktree '$BranchName' cleaned up successfully!" -ForegroundColor Green

} catch {
    Write-Host "`n❌ Cleanup failed: $_" -ForegroundColor Red
    Write-Host "`nManual cleanup may be required:" -ForegroundColor Yellow
    Write-Host "  1. Close PyCharm windows for this worktree"
    Write-Host "  2. Run: git worktree prune"
    Write-Host "  3. Manually delete: $worktreePath"
    throw
}
