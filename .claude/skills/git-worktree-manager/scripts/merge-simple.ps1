# merge-simple.ps1 - Production-ready merge script
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

param(
    [Parameter(Mandatory=$true)]
    [string]$FeatureBranch,

    [switch]$DryRun,
    [switch]$SkipTests,
    [string]$WorkspaceRoot = "C:\ws"
)

function Write-Step {
    param([string]$Message)
    Write-Host "`n▶ $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

$projectName = (Get-Item .).Name
$featurePath = "$WorkspaceRoot\$projectName\$FeatureBranch"
$mainPath = "$WorkspaceRoot\$projectName\main"

try {
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Simple Merge: $FeatureBranch" -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "  (DRY RUN - No changes will be made)" -ForegroundColor Yellow
    }
    Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan

    # Step 1: Validate feature branch
    Write-Step "Validating feature branch"

    if (-not (Test-Path $featurePath)) {
        throw "Feature worktree not found: $featurePath"
    }

    Push-Location $featurePath

    $status = git status --porcelain
    if ($status) {
        Write-Error "Uncommitted changes in feature branch:"
        git status
        throw "Commit or stash changes first"
    }
    Write-Success "Feature branch is clean"

    # Run tests
    if (-not $SkipTests) {
        Write-Step "Running tests in feature branch"
        .\.venv\Scripts\Activate.ps1

        if (-not $DryRun) {
            pytest --tb=short
            if ($LASTEXITCODE -ne 0) {
                throw "Tests failed in feature branch"
            }
        } else {
            Write-Host "  [DRY RUN] Would run: pytest" -ForegroundColor Gray
        }
        Write-Success "Tests passed"
    }

    Pop-Location

    # Step 2: Rebase onto main
    Write-Step "Rebasing feature onto main"

    Push-Location $featurePath

    if (-not $DryRun) {
        git fetch origin
        git rebase origin/main

        if ($LASTEXITCODE -ne 0) {
            Write-Error "Rebase failed. Resolve conflicts:"
            Write-Host "  1. Fix conflicts"
            Write-Host "  2. git add ."
            Write-Host "  3. git rebase --continue"
            Write-Host "  Or: git rebase --abort"
            throw "Rebase conflicts detected"
        }
    } else {
        Write-Host "  [DRY RUN] Would run: git rebase origin/main" -ForegroundColor Gray
    }
    Write-Success "Feature rebased onto main"

    Pop-Location

    # Step 3: Update main worktree
    Write-Step "Updating main worktree"

    Push-Location $mainPath

    $mainStatus = git status --porcelain
    if ($mainStatus) {
        throw "Main worktree has uncommitted changes. Clean up first."
    }

    if (-not $DryRun) {
        git fetch origin
        git pull --ff-only origin main
        if ($LASTEXITCODE -ne 0) {
            throw "Cannot fast-forward main. Resolve manually."
        }
    } else {
        Write-Host "  [DRY RUN] Would run: git pull --ff-only origin/main" -ForegroundColor Gray
    }
    Write-Success "Main updated"

    # Step 4: Fast-forward merge
    Write-Step "Merging feature (fast-forward)"

    if (-not $DryRun) {
        git merge --ff-only $FeatureBranch
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Cannot fast-forward merge. Main has diverged."
            Write-Host "`nFallback options:"
            Write-Host "  1. git merge $FeatureBranch (create merge commit)"
            Write-Host "  2. Rebase feature again and retry"
            throw "Fast-forward merge failed"
        }
    } else {
        Write-Host "  [DRY RUN] Would run: git merge --ff-only $FeatureBranch" -ForegroundColor Gray
    }
    Write-Success "Feature merged"

    if (-not $DryRun) {
        git log --oneline -5
    }

    # Step 5: Post-merge validation
    if (-not $SkipTests) {
        Write-Step "Running tests in main context"

        .\.venv\Scripts\Activate.ps1

        if (-not $DryRun) {
            pytest --tb=short
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Tests failed after merge!"
                Write-Host "`nRollback:"
                Write-Host "  git reset --hard origin/main"
                throw "Post-merge tests failed"
            }
        } else {
            Write-Host "  [DRY RUN] Would run: pytest" -ForegroundColor Gray
        }
        Write-Success "Tests passed in main"
    }

    # Step 6: Push to remote
    Write-Step "Pushing to origin"

    if ($DryRun) {
        Write-Host "  [DRY RUN] Would run: git push origin main" -ForegroundColor Gray
        Write-Success "Dry run completed"
    } else {
        Write-Host "  Push to origin/main? (Y/N)" -ForegroundColor Yellow
        $confirm = Read-Host
        if ($confirm -eq 'Y') {
            git push origin main
            if ($LASTEXITCODE -ne 0) {
                throw "Push failed"
            }
            Write-Success "Pushed to origin/main"
        } else {
            Write-Warning "Push skipped. Remember to push later."
        }
    }

    Pop-Location

    # Success
    if (-not $DryRun) {
        Write-Host "`n╔════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║  ✓ Feature Merged Successfully!            ║" -ForegroundColor Green
        Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green

        Write-Host "`nNext steps:" -ForegroundColor Cyan
        Write-Host "  1. Delete feature worktree:"
        Write-Host "     .\cleanup-worktree.ps1 -BranchName $FeatureBranch"
        Write-Host "  2. Update other worktrees (if any):"
        Write-Host "     cd {worktree} && git pull --ff-only origin/main"
    } else {
        Write-Host "`n✓ Dry run completed. No changes made." -ForegroundColor Green
    }

} catch {
    Write-Host "`n❌ Merge failed: $_" -ForegroundColor Red
    Pop-Location -ErrorAction SilentlyContinue

    Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
    Write-Host "  • Rebase conflicts: Resolve manually in feature worktree"
    Write-Host "  • Tests failed: Fix issues in feature branch and retry"
    Write-Host "  • FF merge failed: Main has diverged, use regular merge"

    throw
}
