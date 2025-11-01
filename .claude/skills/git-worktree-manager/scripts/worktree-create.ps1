# worktree-create.ps1 - Hardened version with Codex feedback
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

param(
    [Parameter(Mandatory=$true)]
    [string]$BranchName,

    [switch]$ShareDB,
    [switch]$SkipDeps,
    [string]$WorkspaceRoot = "C:\ws"
)

# State tracking for rollback
$state = @{
    WorktreeCreated = $false
    VenvCreated = $false
    DepsInstalled = $false
    HooksConfigured = $false
    OriginalHooksPath = $null
}

try {
    # ═══════════════════════════════════════════
    # Phase 1: Environment Validation
    # ═══════════════════════════════════════════
    Write-Host "Phase 1: Validating environment..." -ForegroundColor Cyan

    # Check long paths
    $longPathEnabled = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -ErrorAction SilentlyContinue).LongPathsEnabled
    if (-not $longPathEnabled) {
        Write-Warning "긴 경로가 비활성화되어 있습니다."
        Write-Host "활성화 방법 (관리자 권한):"
        Write-Host "  Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1"
        Write-Host ""
        $continue = Read-Host "계속하시겠습니까? (Y/N)"
        if ($continue -ne 'Y') { throw "사용자가 중단했습니다." }
    }

    # Check Python
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        throw "Python이 설치되어 있지 않습니다."
    }

    # Check Git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "Git이 설치되어 있지 않습니다."
    }

    # Validate workspace root
    if (-not (Test-Path $WorkspaceRoot)) {
        New-Item -ItemType Directory -Path $WorkspaceRoot -Force | Out-Null
        Write-Host "✓ Workspace root created: $WorkspaceRoot"
    }

    # ═══════════════════════════════════════════
    # Phase 2: Git Worktree Creation
    # ═══════════════════════════════════════════
    Write-Host "`nPhase 2: Creating git worktree..." -ForegroundColor Cyan

    $projectName = (Get-Item .).Name
    $worktreePath = "$WorkspaceRoot\$projectName\$BranchName"

    # Check if worktree already exists
    if (Test-Path $worktreePath) {
        Write-Warning "Worktree already exists at: $worktreePath"
        $recreate = Read-Host "Recreate? (Y/N)"
        if ($recreate -eq 'Y') {
            Remove-Item -Path $worktreePath -Recurse -Force
        } else {
            throw "Worktree already exists. Aborting."
        }
    }

    # Create worktree
    git worktree add $worktreePath $BranchName
    if ($LASTEXITCODE -ne 0) {
        throw "git worktree add failed with exit code $LASTEXITCODE"
    }
    $state.WorktreeCreated = $true
    Write-Host "✓ Worktree created: $worktreePath"

    # ═══════════════════════════════════════════
    # Phase 3: Python Virtual Environment
    # ═══════════════════════════════════════════
    Write-Host "`nPhase 3: Setting up Python environment..." -ForegroundColor Cyan

    Push-Location $worktreePath

    python -m venv .venv
    if ($LASTEXITCODE -ne 0) {
        throw "venv creation failed with exit code $LASTEXITCODE"
    }
    $state.VenvCreated = $true
    Write-Host "✓ Virtual environment created"

    # ═══════════════════════════════════════════
    # Phase 4: Dependency Installation
    # ═══════════════════════════════════════════
    if (-not $SkipDeps) {
        Write-Host "`nPhase 4: Installing dependencies..." -ForegroundColor Cyan

        .\.venv\Scripts\Activate.ps1

        if (Test-Path "requirements.txt") {
            pip install -r requirements.txt
            if ($LASTEXITCODE -ne 0) {
                throw "pip install failed with exit code $LASTEXITCODE"
            }
        } elseif (Test-Path "pyproject.toml") {
            pip install -e .
            if ($LASTEXITCODE -ne 0) {
                throw "pip install failed with exit code $LASTEXITCODE"
            }
        }
        $state.DepsInstalled = $true
        Write-Host "✓ Dependencies installed"
    }

    # ═══════════════════════════════════════════
    # Phase 5: Environment Variables
    # ═══════════════════════════════════════════
    Write-Host "`nPhase 5: Configuring environment variables..." -ForegroundColor Cyan

    $mainEnvPath = "$WorkspaceRoot\$projectName\main\.env"
    if (Test-Path $mainEnvPath) {
        $envContent = Get-Content $mainEnvPath

        # Mask sensitive values
        $envLocal = $envContent | ForEach-Object {
            if ($_ -match "^(SECRET|PASSWORD|API_KEY|TOKEN|PRIVATE_KEY)") {
                $key = ($_ -split '=')[0]
                "# MASKED - SET MANUALLY: $key=***"
            } else {
                $_
            }
        }

        $envLocal | Out-File -FilePath ".env.local" -Encoding UTF8
        Write-Host "✓ Environment variables copied to .env.local"
        Write-Warning "⚠️  민감정보가 마스킹되었습니다. .env.local을 확인하세요."
    }

    # ═══════════════════════════════════════════
    # Phase 6: Database Strategy
    # ═══════════════════════════════════════════
    Write-Host "`nPhase 6: Setting up database..." -ForegroundColor Cyan

    $mainDBPath = "$WorkspaceRoot\$projectName\main\db.sqlite3"
    $targetDBPath = "db-$BranchName.sqlite3"

    if (Test-Path $mainDBPath) {
        if ($ShareDB) {
            # Create symlink (requires admin or Developer Mode)
            Write-Host "Creating database symlink..." -ForegroundColor Yellow
            try {
                New-Item -ItemType SymbolicLink -Path $targetDBPath -Target $mainDBPath -ErrorAction Stop
                Write-Host "✓ Database shared via symlink: $targetDBPath -> $mainDBPath" -ForegroundColor Green
                Write-Warning "⚠️  Shared database mode enabled. Concurrent access may cause locking issues."
            } catch {
                Write-Warning "Failed to create symlink. Falling back to copy..."
                Write-Warning "Enable Developer Mode or run as Administrator to use --ShareDB"
                Copy-Item $mainDBPath $targetDBPath -ErrorAction Stop
                Write-Host "✓ Database copied (symlink failed): $targetDBPath"
            }
        } else {
            # Copy DB (default, safe mode)
            try {
                $fileStream = [System.IO.File]::Open($mainDBPath, 'Open', 'Read', 'None')
                $fileStream.Close()

                Copy-Item $mainDBPath $targetDBPath -ErrorAction Stop
                Write-Host "✓ Database copied: $targetDBPath"
            } catch {
                Write-Warning "Database is locked. Retrying in 3 seconds..."
                Start-Sleep -Seconds 3

                try {
                    Copy-Item $mainDBPath $targetDBPath -ErrorAction Stop -Force
                    Write-Host "✓ Database copied (retry succeeded)"
                } catch {
                    Write-Error "Failed to copy database: $_"
                    throw
                }
            }
        }
    } else {
        Write-Warning "Main database not found. Skipping DB setup."
    }

    # ═══════════════════════════════════════════
    # Phase 7: Git Hooks Configuration
    # ═══════════════════════════════════════════
    Write-Host "`nPhase 7: Configuring git hooks..." -ForegroundColor Cyan

    $hooksSharedPath = "..\.git\hooks-shared"
    if (Test-Path $hooksSharedPath) {
        # Save original hooksPath
        $state.OriginalHooksPath = git config core.hooksPath 2>$null

        # Set new hooksPath
        git config core.hooksPath $hooksSharedPath
        if ($LASTEXITCODE -ne 0) {
            throw "git config core.hooksPath failed"
        }
        $state.HooksConfigured = $true
        Write-Host "✓ Git hooks configured: $hooksSharedPath"

        # Re-install pre-commit if exists
        if (Get-Command pre-commit -ErrorAction SilentlyContinue) {
            .\.venv\Scripts\Activate.ps1
            pre-commit install 2>&1 | Out-Null
            Write-Host "✓ pre-commit hooks installed"
        }
    } else {
        Write-Warning "Shared hooks directory not found. Skipping hooks setup."
    }

    # ═══════════════════════════════════════════
    # Phase 8: README Generation
    # ═══════════════════════════════════════════
    Write-Host "`nPhase 8: Generating documentation..." -ForegroundColor Cyan

    $interpreterPath = (Resolve-Path ".venv\Scripts\python.exe").Path

    @"
# Worktree: $BranchName

**Created:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## 환경 정보

- **Python Interpreter:** ``.venv\Scripts\python.exe``
- **Full Path:** ``$interpreterPath``
- **환경변수:** ``.env.local``
- **Database:** ``db-$BranchName.sqlite3``
- **Git Hooks:** ``$hooksSharedPath``

## PyCharm 설정

### 1. 프로젝트 열기
``````
File > Open > $worktreePath
``````

### 2. Python Interpreter 설정
``````
Settings > Project > Python Interpreter
> Add Interpreter > Existing environment
> Select: $interpreterPath
> ✓ "Inherit global site-packages" OFF
``````

### 3. Environment Variables 설정
``````
Run > Edit Configurations
> Environment variables > Load from .env.local
``````

**또는 EnvFile Plugin 사용:**
``````
Settings > Plugins > Install "EnvFile"
Run Configuration > EnvFile tab > Enable > Add .env.local
``````

### 4. VCS Root 확인
``````
Settings > Version Control
> Ensure only this worktree root is enabled
> Remove other worktree roots if listed
``````

## 테스트 실행

``````powershell
# Activate venv
.\.venv\Scripts\Activate.ps1

# Run smoke tests
pytest -k smoke

# Run all tests
pytest
``````

## 데이터베이스 마이그레이션

``````powershell
# Activate venv
.\.venv\Scripts\Activate.ps1

# Run migrations (Django example)
python manage.py migrate

# Or Alembic
alembic upgrade head
``````

## 정리

``````powershell
# 메인 프로젝트로 돌아가서
cd ..\..\main
.\cleanup-worktree.ps1 $BranchName
``````

## Troubleshooting

### PyCharm이 잘못된 인터프리터를 사용할 때
1. Settings > Project > Python Interpreter
2. Show All > Remove invalid interpreters
3. Add correct interpreter: ``.venv\Scripts\python.exe``

### 테스트 실행 시 ImportError
1. venv가 활성화되었는지 확인
2. 의존성이 설치되었는지 확인: ``pip list``
3. 재설치: ``pip install -r requirements.txt``

### Git hooks이 실행 안 될 때
``````powershell
git config core.hooksPath
# Should show: ..\.git\hooks-shared

# Re-configure if needed
git config core.hooksPath ..\.git\hooks-shared
pre-commit install
``````
"@ | Out-File -FilePath "README-worktree.md" -Encoding UTF8

    Write-Host "✓ README-worktree.md created"

    # ═══════════════════════════════════════════
    # Phase 9: Smoke Tests
    # ═══════════════════════════════════════════
    Write-Host "`nPhase 9: Running smoke tests..." -ForegroundColor Cyan

    if (Test-Path "tests") {
        .\.venv\Scripts\Activate.ps1

        $smokeResult = pytest -k smoke --tb=short 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Smoke tests passed!" -ForegroundColor Green
        } else {
            Write-Warning "⚠️  Smoke tests failed. Review output:"
            Write-Host $smokeResult
        }
    } else {
        Write-Warning "No tests directory found. Skipping smoke tests."
    }

    Pop-Location

    # ═══════════════════════════════════════════
    # Phase 10: Success Summary
    # ═══════════════════════════════════════════
    Write-Host "`n╔════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✓ Worktree '$BranchName' Created Successfully!" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Green

    Write-Host "`n📌 Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Open PyCharm:" -ForegroundColor White
    Write-Host "     File > Open > $worktreePath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. Set Python Interpreter:" -ForegroundColor White
    Write-Host "     $interpreterPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. Configure Environment:" -ForegroundColor White
    Write-Host "     Review .env.local for masked secrets" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  4. Read Documentation:" -ForegroundColor White
    Write-Host "     $worktreePath\README-worktree.md" -ForegroundColor Gray
    Write-Host ""

    # Return summary object
    return [PSCustomObject]@{
        BranchName = $BranchName
        WorktreePath = $worktreePath
        Interpreter = $interpreterPath
        Database = "$worktreePath\db-$BranchName.sqlite3"
        HooksPath = $hooksSharedPath
        EnvFile = "$worktreePath\.env.local"
        SmokeTestPassed = ($LASTEXITCODE -eq 0)
    }

} catch {
    # ═══════════════════════════════════════════
    # Rollback on Failure
    # ═══════════════════════════════════════════
    Write-Host "`n❌ Error occurred: $_" -ForegroundColor Red
    Write-Host "`n🔄 Rolling back changes..." -ForegroundColor Yellow

    try {
        Pop-Location -ErrorAction SilentlyContinue

        # Rollback hooks config
        if ($state.HooksConfigured) {
            if ($state.OriginalHooksPath) {
                Push-Location $worktreePath -ErrorAction SilentlyContinue
                git config core.hooksPath $state.OriginalHooksPath
                Pop-Location -ErrorAction SilentlyContinue
            } else {
                Push-Location $worktreePath -ErrorAction SilentlyContinue
                git config --unset core.hooksPath
                Pop-Location -ErrorAction SilentlyContinue
            }
            Write-Host "  ✓ Git hooks config restored"
        }

        # Remove worktree
        if ($state.WorktreeCreated) {
            git worktree remove $worktreePath --force 2>$null
            if (Test-Path $worktreePath) {
                Remove-Item -Path $worktreePath -Recurse -Force -ErrorAction SilentlyContinue
            }
            Write-Host "  ✓ Worktree removed"
        }

        Write-Host "`n✓ Rollback completed" -ForegroundColor Green
    } catch {
        Write-Warning "Rollback failed: $_"
        Write-Warning "Manual cleanup may be required for: $worktreePath"
    }

    throw
}
