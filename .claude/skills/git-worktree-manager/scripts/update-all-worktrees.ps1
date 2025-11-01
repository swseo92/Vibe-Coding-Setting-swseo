# update-all-worktrees.ps1 - Sync all worktrees after main changes
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "Updating all worktrees..." -ForegroundColor Cyan

$worktrees = git worktree list --porcelain | Select-String "^worktree (.+)$" | ForEach-Object {
    $_.Matches.Groups[1].Value
}

foreach ($wt in $worktrees) {
    Write-Host "`n▶ Worktree: $wt" -ForegroundColor Yellow
    Push-Location $wt

    try {
        git fetch origin

        # Main worktree: fast-forward pull
        if ($wt -match "\\main$") {
            Write-Host "  Pulling main..." -ForegroundColor Gray
            git pull --ff-only origin main
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Main updated" -ForegroundColor Green
            } else {
                Write-Warning "  Cannot fast-forward. Manual merge needed."
            }
        }
        # Feature worktrees: offer rebase
        else {
            $currentBranch = git branch --show-current
            Write-Host "  Current branch: $currentBranch" -ForegroundColor Gray
            Write-Host "  Rebase onto origin/main? (Y/N/Skip)" -ForegroundColor Cyan
            $choice = Read-Host

            if ($choice -eq 'Y') {
                git rebase origin/main
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✓ Rebased successfully" -ForegroundColor Green
                } else {
                    Write-Warning "  Rebase conflicts. Resolve manually:"
                    Write-Host "    cd $wt"
                    Write-Host "    git rebase --continue (after fixing)"
                    Write-Host "    git rebase --abort (to cancel)"
                }
            } elseif ($choice -eq 'Skip') {
                Write-Host "  Skipped" -ForegroundColor Gray
            }
        }
    } finally {
        Pop-Location
    }
}

Write-Host "`n✓ Worktree update completed!" -ForegroundColor Green
