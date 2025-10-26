---
name: sync-workspace
description: Sync latest Vibe-Coding-Setting changes to current project
tags: [project, gitignored]
---

# Sync Workspace Settings

Vibe-Coding-Setting-swseo GitHub 저장소의 최신 변경사항을 현재 프로젝트와 전역 설정에 적용합니다.

**중요:**
- 현재 프로젝트의 `.git`은 그대로 유지되며, 설정 파일들만 업데이트됩니다.
- **프로젝트 로컬**: 경로 의존적 파일만 동기화 (.claude/settings.json, .claude/scripts/, .specify/)
- **전역 설정**: 항상 자동으로 업데이트 (~/.claude/, ~/.specify/)
  - commands, agents, skills, personas 등
  - 모든 프로젝트에서 최신 명령어 사용 가능

## Usage

```bash
# 기본 실행 (프로젝트 로컬 + 전역 설정 모두 동기화)
/sync-workspace

# 프로젝트 로컬만 동기화 (전역은 건너뛰기)
/sync-workspace --local-only

# 전역 설정만 동기화 (프로젝트는 건너뛰기)
/sync-workspace --global-only

# 변경사항만 미리보기
/sync-workspace --dry-run
```

## Workflow

### 1. Vibe-Coding-Setting 저장소 Clone

임시 디렉토리에 최신 버전을 clone합니다.

#### Windows (PowerShell)
```powershell
# 임시 디렉토리 생성
$tempDir = New-Item -ItemType Directory -Path "$env:TEMP\vibe-coding-sync-$(Get-Random)"

Write-Host "Fetching latest Vibe-Coding-Setting from GitHub..." -ForegroundColor Cyan

# Clone 저장소
git clone https://github.com/swseo92/Vibe-Coding-Setting-swseo.git $tempDir

if (-not (Test-Path $tempDir)) {
    Write-Host "Error: Failed to clone Vibe-Coding-Setting repository" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Successfully fetched latest version" -ForegroundColor Green
```

#### Unix/Linux/Mac (Bash)
```bash
# 임시 디렉토리 생성
TEMP_DIR=$(mktemp -d)

echo "Fetching latest Vibe-Coding-Setting from GitHub..."

# Clone 저장소
git clone https://github.com/swseo92/Vibe-Coding-Setting-swseo.git "$TEMP_DIR"

if [ ! -d "$TEMP_DIR" ]; then
    echo "Error: Failed to clone Vibe-Coding-Setting repository"
    exit 1
fi

echo "✓ Successfully fetched latest version"
```

### 2. 현재 프로젝트 확인

현재 디렉토리가 올바른 프로젝트인지 확인:

```bash
# 현재 프로젝트의 git remote 확인
git remote -v

# 사용자에게 확인
# 출력 예시:
# origin  https://github.com/user/my-project.git (fetch)
# origin  https://github.com/user/my-project.git (push)
```

**확인 메시지:**
```
Current project git remote:
  origin: https://github.com/user/my-project.git

This will sync Vibe-Coding-Setting changes to this project.
Your project's .git and code will NOT be affected.

Continue? (y/N)
```

### 3. 변경사항 분석

프로젝트 로컬 파일과 전역 설정의 차이를 각각 분석합니다.

**프로젝트 로컬 파일:**
- `.claude/settings.json` - Hook 설정
- `.claude/scripts/` - Hook 스크립트 (notify.py 등)
- `.specify/` - Speckit 템플릿

**전역 설정:**
- `~/.claude/commands/` - Slash commands
- `~/.claude/agents/` - Agents
- `~/.claude/skills/` - Skills
- `~/.claude/personas/` - Personas
- `~/.specify/` - Speckit 템플릿 (전역)

#### Windows (PowerShell)
```powershell
function Compare-LocalSettings {
    param($SourceDir, $TargetDir)

    $changes = @{
        "New" = @()
        "Modified" = @()
        "Unchanged" = @()
    }

    # .claude/settings.json 비교
    $settingsFile = "templates/common/.claude/settings.json"
    if (Test-Path "$SourceDir/$settingsFile") {
        $targetFile = ".claude/settings.json"

        if (-not (Test-Path $targetFile)) {
            $changes["New"] += $targetFile
        } elseif ((Get-FileHash "$SourceDir/$settingsFile").Hash -ne (Get-FileHash $targetFile).Hash) {
            $changes["Modified"] += $targetFile
        } else {
            $changes["Unchanged"] += $targetFile
        }
    }

    # .claude/scripts 디렉토리 비교
    if (Test-Path "$SourceDir/templates/common/.claude/scripts") {
        Get-ChildItem -Recurse -File "$SourceDir/templates/common/.claude/scripts" | ForEach-Object {
            $relativePath = $_.FullName.Substring("$SourceDir/templates/common/.claude/scripts".Length + 1)
            $targetFile = Join-Path ".claude/scripts" $relativePath

            if (-not (Test-Path $targetFile)) {
                $changes["New"] += ".claude/scripts/$relativePath"
            } elseif ((Get-FileHash $_.FullName).Hash -ne (Get-FileHash $targetFile).Hash) {
                $changes["Modified"] += ".claude/scripts/$relativePath"
            } else {
                $changes["Unchanged"] += ".claude/scripts/$relativePath"
            }
        }
    }

    # .specify 디렉토리 비교
    if (Test-Path "$SourceDir/.specify") {
        Get-ChildItem -Recurse -File "$SourceDir/.specify" | ForEach-Object {
            $relativePath = $_.FullName.Substring("$SourceDir/.specify".Length + 1)
            $targetFile = Join-Path ".specify" $relativePath

            if (-not (Test-Path $targetFile)) {
                $changes["New"] += ".specify/$relativePath"
            } elseif ((Get-FileHash $_.FullName).Hash -ne (Get-FileHash $targetFile).Hash) {
                $changes["Modified"] += ".specify/$relativePath"
            } else {
                $changes["Unchanged"] += ".specify/$relativePath"
            }
        }
    }

    return $changes
}

$localChanges = Compare-LocalSettings -SourceDir $tempDir -TargetDir "."

# 결과 출력
Write-Host "`n=== Project Local Sync Preview ===" -ForegroundColor Cyan

if ($localChanges["New"].Count -gt 0) {
    Write-Host "`nNew files ($($localChanges["New"].Count)):" -ForegroundColor Green
    $localChanges["New"] | ForEach-Object { Write-Host "  + $_" -ForegroundColor Green }
}

if ($localChanges["Modified"].Count -gt 0) {
    Write-Host "`nModified files ($($localChanges["Modified"].Count)):" -ForegroundColor Yellow
    $localChanges["Modified"] | ForEach-Object { Write-Host "  ~ $_" -ForegroundColor Yellow }
}

Write-Host "`nUnchanged: $($localChanges["Unchanged"].Count) files" -ForegroundColor Gray

# 전역 설정은 항상 업데이트 (프리뷰 없이)
Write-Host "`n=== Global Settings ===" -ForegroundColor Cyan
Write-Host "  Will update: ~/.claude/ (commands, agents, skills, personas)" -ForegroundColor Yellow
Write-Host "  Will update: ~/.specify/" -ForegroundColor Yellow
```

#### Unix/Linux/Mac (Bash)
```bash
compare_local_settings() {
    local source_dir="$1"

    NEW_FILES=()
    MODIFIED_FILES=()
    UNCHANGED_COUNT=0

    # .claude/settings.json 비교
    local settings_file="$source_dir/templates/common/.claude/settings.json"
    if [ -f "$settings_file" ]; then
        local target_file=".claude/settings.json"

        if [ ! -f "$target_file" ]; then
            NEW_FILES+=("$target_file")
        elif ! cmp -s "$settings_file" "$target_file"; then
            MODIFIED_FILES+=("$target_file")
        else
            ((UNCHANGED_COUNT++))
        fi
    fi

    # .claude/scripts 디렉토리 비교
    if [ -d "$source_dir/templates/common/.claude/scripts" ]; then
        while IFS= read -r -d '' file; do
            relative_path="${file#$source_dir/templates/common/.claude/scripts/}"
            target_file=".claude/scripts/$relative_path"

            if [ ! -f "$target_file" ]; then
                NEW_FILES+=(".claude/scripts/$relative_path")
            elif ! cmp -s "$file" "$target_file"; then
                MODIFIED_FILES+=(".claude/scripts/$relative_path")
            else
                ((UNCHANGED_COUNT++))
            fi
        done < <(find "$source_dir/templates/common/.claude/scripts" -type f -print0)
    fi

    # .specify 디렉토리 비교
    if [ -d "$source_dir/.specify" ]; then
        while IFS= read -r -d '' file; do
            relative_path="${file#$source_dir/.specify/}"
            target_file=".specify/$relative_path"

            if [ ! -f "$target_file" ]; then
                NEW_FILES+=(".specify/$relative_path")
            elif ! cmp -s "$file" "$target_file"; then
                MODIFIED_FILES+=(".specify/$relative_path")
            else
                ((UNCHANGED_COUNT++))
            fi
        done < <(find "$source_dir/.specify" -type f -print0)
    fi

    # 결과 출력
    echo ""
    echo "=== Project Local Sync Preview ==="

    if [ ${#NEW_FILES[@]} -gt 0 ]; then
        echo ""
        echo "New files (${#NEW_FILES[@]}):"
        for file in "${NEW_FILES[@]}"; do
            echo "  + $file"
        done
    fi

    if [ ${#MODIFIED_FILES[@]} -gt 0 ]; then
        echo ""
        echo "Modified files (${#MODIFIED_FILES[@]}):"
        for file in "${MODIFIED_FILES[@]}"; do
            echo "  ~ $file"
        done
    fi

    echo ""
    echo "Unchanged: $UNCHANGED_COUNT files"

    # 전역 설정은 항상 업데이트 (프리뷰 없이)
    echo ""
    echo "=== Global Settings ==="
    echo "  Will update: ~/.claude/ (commands, agents, skills, personas)"
    echo "  Will update: ~/.specify/"
}

compare_local_settings "$TEMP_DIR"
```

### 4. 사용자 확인

변경사항을 적용할지 확인:

**AskUserQuestion:**
```
다음 변경사항을 적용하시겠습니까?

- 새 파일: 3개
- 수정된 파일: 5개
- 변경 없음: 142개

적용하면 현재 프로젝트의 .claude/ 및 .specify/ 내용이 업데이트됩니다.
```

**옵션:**
- "Yes, apply changes" - 변경사항 적용
- "No, cancel" - 취소
- "Show file details" - 변경된 파일 목록 자세히 보기

### 5. 백업 생성 (선택사항)

변경 전 기존 설정을 백업합니다 (사용자 확인 시).

#### Windows (PowerShell)
```powershell
function Backup-Settings {
    param([switch]$CreateBackup)

    if (-not $CreateBackup) {
        return
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupDir = ".claude-backup-$timestamp"

    Write-Host "`nCreating backup..." -ForegroundColor Cyan

    # 프로젝트 로컬 백업
    if (Test-Path ".claude") {
        Copy-Item -Recurse ".claude" "$backupDir/.claude" -ErrorAction SilentlyContinue
        Write-Host "  ✓ Backed up .claude/ to $backupDir/.claude/" -ForegroundColor Green
    }
    if (Test-Path ".specify") {
        Copy-Item -Recurse ".specify" "$backupDir/.specify" -ErrorAction SilentlyContinue
        Write-Host "  ✓ Backed up .specify/ to $backupDir/.specify/" -ForegroundColor Green
    }

    # 전역 설정 백업
    $globalClaudeDir = Join-Path $env:USERPROFILE ".claude"
    $globalSpecifyDir = Join-Path $env:USERPROFILE ".specify"

    if (Test-Path $globalClaudeDir) {
        $globalBackupDir = Join-Path $env:USERPROFILE ".claude-backup-$timestamp"
        Copy-Item -Recurse $globalClaudeDir $globalBackupDir -ErrorAction SilentlyContinue
        Write-Host "  ✓ Backed up ~/.claude/ to ~/.claude-backup-$timestamp/" -ForegroundColor Green
    }
    if (Test-Path $globalSpecifyDir) {
        $globalBackupDir = Join-Path $env:USERPROFILE ".specify-backup-$timestamp"
        Copy-Item -Recurse $globalSpecifyDir $globalBackupDir -ErrorAction SilentlyContinue
        Write-Host "  ✓ Backed up ~/.specify/ to ~/.specify-backup-$timestamp/" -ForegroundColor Green
    }

    Write-Host ""
}
```

#### Unix/Linux/Mac (Bash)
```bash
backup_settings() {
    local create_backup="$1"

    if [ "$create_backup" != "true" ]; then
        return
    fi

    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_dir=".claude-backup-$timestamp"

    echo ""
    echo "Creating backup..."

    # 프로젝트 로컬 백업
    if [ -d ".claude" ]; then
        mkdir -p "$backup_dir"
        cp -r ".claude" "$backup_dir/.claude" 2>/dev/null
        echo "  ✓ Backed up .claude/ to $backup_dir/.claude/"
    fi
    if [ -d ".specify" ]; then
        mkdir -p "$backup_dir"
        cp -r ".specify" "$backup_dir/.specify" 2>/dev/null
        echo "  ✓ Backed up .specify/ to $backup_dir/.specify/"
    fi

    # 전역 설정 백업
    if [ -d "$HOME/.claude" ]; then
        cp -r "$HOME/.claude" "$HOME/.claude-backup-$timestamp" 2>/dev/null
        echo "  ✓ Backed up ~/.claude/ to ~/.claude-backup-$timestamp/"
    fi
    if [ -d "$HOME/.specify" ]; then
        cp -r "$HOME/.specify" "$HOME/.specify-backup-$timestamp" 2>/dev/null
        echo "  ✓ Backed up ~/.specify/ to ~/.specify-backup-$timestamp/"
    fi

    echo ""
}
```

### 6. 사용자 확인 (전역 설정 변경 경고)

전역 설정을 변경하면 **모든 프로젝트**에 영향을 미치므로 명확한 경고를 표시합니다.

**AskUserQuestion:**
```
⚠️  전역 설정을 업데이트합니다

다음 디렉토리가 최신 버전으로 업데이트됩니다:
- ~/.claude/ (commands, agents, skills, personas)
- ~/.specify/ (Speckit templates)

이 변경은 **모든 프로젝트**에 영향을 미칩니다.

백업을 생성하시겠습니까?
```

**옵션:**
- "Yes, create backup and continue" - 백업 생성 후 진행
- "No, skip backup and continue" - 백업 없이 진행
- "Cancel" - 취소

### 7. 동기화 실행

변경사항 적용 (프로젝트 로컬 + 전역):

**중요:** 기존 파일을 삭제하지 않고 덮어쓰기만 합니다. 프로젝트별 커스터마이징은 보존됩니다.

#### Windows (PowerShell)
```powershell
function Sync-LocalSettings {
    param($SourceDir)

    $totalSynced = 0

    # 1. .claude/settings.json 동기화 (덮어쓰기)
    $settingsSource = Join-Path $SourceDir "templates\common\.claude\settings.json"
    if (Test-Path $settingsSource) {
        Write-Host "Syncing .claude/settings.json..." -ForegroundColor Yellow
        Copy-Item -Force $settingsSource ".claude\settings.json"
        $totalSynced++
        Write-Host "  ✓ Synced settings.json" -ForegroundColor Green
    }

    # 2. .claude/scripts/ 동기화 (덮어쓰기, 기존 파일 보존)
    $scriptsSource = Join-Path $SourceDir "templates\common\.claude\scripts"
    if (Test-Path $scriptsSource) {
        Write-Host "Syncing .claude/scripts/..." -ForegroundColor Yellow

        # 디렉토리가 없으면 생성
        if (-not (Test-Path ".claude\scripts")) {
            New-Item -ItemType Directory -Path ".claude\scripts" -Force | Out-Null
        }

        # 파일별로 복사 (덮어쓰기, 삭제 안 함)
        Get-ChildItem -Recurse -File $scriptsSource | ForEach-Object {
            $relativePath = $_.FullName.Substring($scriptsSource.Length + 1)
            $targetPath = Join-Path ".claude\scripts" $relativePath
            $targetDir = Split-Path $targetPath -Parent

            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }

            Copy-Item -Force $_.FullName $targetPath
            $totalSynced++
        }

        $fileCount = (Get-ChildItem -Recurse -File ".claude\scripts").Count
        Write-Host "  ✓ Synced scripts ($fileCount files total)" -ForegroundColor Green
    }

    # 3. .specify/ 동기화 (덮어쓰기, 기존 파일 보존)
    $specifySource = Join-Path $SourceDir ".specify"
    if (Test-Path $specifySource) {
        Write-Host "Syncing .specify/..." -ForegroundColor Yellow

        # 디렉토리가 없으면 생성
        if (-not (Test-Path ".specify")) {
            New-Item -ItemType Directory -Path ".specify" -Force | Out-Null
        }

        # 파일별로 복사 (덮어쓰기, 삭제 안 함)
        Get-ChildItem -Recurse -File $specifySource | ForEach-Object {
            $relativePath = $_.FullName.Substring($specifySource.Length + 1)
            $targetPath = Join-Path ".specify" $relativePath
            $targetDir = Split-Path $targetPath -Parent

            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }

            Copy-Item -Force $_.FullName $targetPath
            $totalSynced++
        }

        $fileCount = (Get-ChildItem -Recurse -File ".specify").Count
        Write-Host "  ✓ Synced .specify ($fileCount files total)" -ForegroundColor Green
    }

    return $totalSynced
}

function Sync-GlobalSettings {
    param($SourceDir)

    $globalClaudeDir = Join-Path $env:USERPROFILE ".claude"
    $globalSpecifyDir = Join-Path $env:USERPROFILE ".specify"

    # 1. ~/.claude/ 전체 동기화 (덮어쓰기, 기존 파일 보존)
    Write-Host "`nSyncing global ~/.claude/..." -ForegroundColor Yellow
    $claudeSource = Join-Path $SourceDir ".claude"
    if (Test-Path $claudeSource) {
        # 디렉토리가 없으면 생성
        if (-not (Test-Path $globalClaudeDir)) {
            New-Item -ItemType Directory -Path $globalClaudeDir -Force | Out-Null
        }

        # 파일별로 복사 (덮어쓰기, 삭제 안 함)
        Get-ChildItem -Recurse -File $claudeSource | ForEach-Object {
            $relativePath = $_.FullName.Substring($claudeSource.Length + 1)
            $targetPath = Join-Path $globalClaudeDir $relativePath
            $targetDir = Split-Path $targetPath -Parent

            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }

            Copy-Item -Force $_.FullName $targetPath
        }

        Write-Host "  ✓ Synced ~/.claude/" -ForegroundColor Green
    }

    # 2. settings.local.json → settings.json
    $settingsLocal = Join-Path $SourceDir ".claude\settings.local.json"
    if (Test-Path $settingsLocal) {
        Copy-Item -Force $settingsLocal "$globalClaudeDir\settings.json"
        Write-Host "  ✓ Synced settings.local.json → settings.json" -ForegroundColor Green
    }

    # 3. ~/.specify/ 동기화 (덮어쓰기, 기존 파일 보존)
    Write-Host "Syncing global ~/.specify/..." -ForegroundColor Yellow
    $specifySource = Join-Path $SourceDir ".specify"
    if (Test-Path $specifySource) {
        # 디렉토리가 없으면 생성
        if (-not (Test-Path $globalSpecifyDir)) {
            New-Item -ItemType Directory -Path $globalSpecifyDir -Force | Out-Null
        }

        # 파일별로 복사 (덮어쓰기, 삭제 안 함)
        Get-ChildItem -Recurse -File $specifySource | ForEach-Object {
            $relativePath = $_.FullName.Substring($specifySource.Length + 1)
            $targetPath = Join-Path $globalSpecifyDir $relativePath
            $targetDir = Split-Path $targetPath -Parent

            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }

            Copy-Item -Force $_.FullName $targetPath
        }

        Write-Host "  ✓ Synced ~/.specify/" -ForegroundColor Green
    }
}

# 백업 생성 (사용자 선택에 따라)
Backup-Settings -CreateBackup:$CreateBackup

# 프로젝트 로컬 동기화
Write-Host "`n=== Syncing Project Local ===" -ForegroundColor Cyan
$localSynced = Sync-LocalSettings -SourceDir $tempDir

# 전역 설정 동기화 (unless --local-only)
if (-not $LocalOnly) {
    Write-Host "`n=== Syncing Global Settings ===" -ForegroundColor Cyan
    Sync-GlobalSettings -SourceDir $tempDir
}
```

#### Unix/Linux/Mac (Bash)
```bash
sync_local_settings() {
    local source_dir="$1"
    local total_synced=0

    # 1. .claude/settings.json 동기화 (덮어쓰기)
    local settings_source="$source_dir/templates/common/.claude/settings.json"
    if [ -f "$settings_source" ]; then
        echo "Syncing .claude/settings.json..."
        cp -f "$settings_source" ".claude/settings.json"
        total_synced=$((total_synced + 1))
        echo "  ✓ Synced settings.json"
    fi

    # 2. .claude/scripts/ 동기화 (덮어쓰기, 기존 파일 보존)
    local scripts_source="$source_dir/templates/common/.claude/scripts"
    if [ -d "$scripts_source" ]; then
        echo "Syncing .claude/scripts/..."

        # 디렉토리가 없으면 생성
        mkdir -p ".claude/scripts"

        # 파일별로 복사 (덮어쓰기, 삭제 안 함)
        find "$scripts_source" -type f | while IFS= read -r file; do
            local relative_path="${file#$scripts_source/}"
            local target_path=".claude/scripts/$relative_path"
            local target_dir=$(dirname "$target_path")

            mkdir -p "$target_dir"
            cp -f "$file" "$target_path"
            total_synced=$((total_synced + 1))
        done

        local file_count=$(find ".claude/scripts" -type f | wc -l)
        echo "  ✓ Synced scripts ($file_count files total)"
    fi

    # 3. .specify/ 동기화 (덮어쓰기, 기존 파일 보존)
    local specify_source="$source_dir/.specify"
    if [ -d "$specify_source" ]; then
        echo "Syncing .specify/..."

        # 디렉토리가 없으면 생성
        mkdir -p ".specify"

        # 파일별로 복사 (덮어쓰기, 삭제 안 함)
        find "$specify_source" -type f | while IFS= read -r file; do
            local relative_path="${file#$specify_source/}"
            local target_path=".specify/$relative_path"
            local target_dir=$(dirname "$target_path")

            mkdir -p "$target_dir"
            cp -f "$file" "$target_path"
            total_synced=$((total_synced + 1))
        done

        local file_count=$(find ".specify" -type f | wc -l)
        echo "  ✓ Synced .specify ($file_count files total)"
    fi

    echo "$total_synced"
}

sync_global_settings() {
    local source_dir="$1"
    local global_claude_dir="$HOME/.claude"
    local global_specify_dir="$HOME/.specify"

    # 1. ~/.claude/ 전체 동기화 (덮어쓰기, 기존 파일 보존)
    echo ""
    echo "Syncing global ~/.claude/..."
    local claude_source="$source_dir/.claude"
    if [ -d "$claude_source" ]; then
        # 디렉토리가 없으면 생성
        mkdir -p "$global_claude_dir"

        # 파일별로 복사 (덮어쓰기, 삭제 안 함)
        find "$claude_source" -type f | while IFS= read -r file; do
            local relative_path="${file#$claude_source/}"
            local target_path="$global_claude_dir/$relative_path"
            local target_dir=$(dirname "$target_path")

            mkdir -p "$target_dir"
            cp -f "$file" "$target_path"
        done

        echo "  ✓ Synced ~/.claude/"
    fi

    # 2. settings.local.json → settings.json
    local settings_local="$source_dir/.claude/settings.local.json"
    if [ -f "$settings_local" ]; then
        cp -f "$settings_local" "$global_claude_dir/settings.json"
        echo "  ✓ Synced settings.local.json → settings.json"
    fi

    # 3. ~/.specify/ 동기화 (덮어쓰기, 기존 파일 보존)
    echo "Syncing global ~/.specify/..."
    local specify_source="$source_dir/.specify"
    if [ -d "$specify_source" ]; then
        # 디렉토리가 없으면 생성
        mkdir -p "$global_specify_dir"

        # 파일별로 복사 (덮어쓰기, 삭제 안 함)
        find "$specify_source" -type f | while IFS= read -r file; do
            local relative_path="${file#$specify_source/}"
            local target_path="$global_specify_dir/$relative_path"
            local target_dir=$(dirname "$target_path")

            mkdir -p "$target_dir"
            cp -f "$file" "$target_path"
        done

        echo "  ✓ Synced ~/.specify/"
    fi
}

# 백업 생성 (사용자 선택에 따라)
backup_settings "$CREATE_BACKUP"

# 프로젝트 로컬 동기화
echo ""
echo "=== Syncing Project Local ==="
LOCAL_SYNCED=$(sync_local_settings "$TEMP_DIR")

# 전역 설정 동기화 (unless --local-only)
if [ "$LOCAL_ONLY" != "true" ]; then
    echo ""
    echo "=== Syncing Global Settings ==="
    sync_global_settings "$TEMP_DIR"
fi
```

### 8. 정리 및 완료

임시 디렉토리 정리:

```powershell
# Windows
Remove-Item -Recurse -Force $tempDir
```

```bash
# Unix
rm -rf "$TEMP_DIR"
```

### 9. 완료 메시지

```markdown
## ✅ Workspace Sync Complete

**Source:** Vibe-Coding-Setting-swseo (latest from GitHub)

### Project Local Files Updated:
- ✓ .claude/settings.json (hook configuration)
- ✓ .claude/scripts/ (notification scripts)
- ✓ .specify/ (Speckit templates and scripts)

**Summary:**
- Local files synced: 3-5 files
- New files added: X
- Files updated: X

### Global Settings Updated:
- ✓ ~/.claude/commands/ (13 slash commands)
- ✓ ~/.claude/agents/ (2 agents)
- ✓ ~/.claude/skills/ (13 skills)
- ✓ ~/.claude/personas/ (2 personas)
- ✓ ~/.specify/ (Speckit templates)

**Note:** Global settings are now shared across ALL projects!

### Next Steps:

1. **Review local changes:**
   ```bash
   git status
   git diff .claude/settings.json
   git diff .specify/
   ```

2. **Test the changes:**
   - Try slash commands: `/help`, `/init-workspace`, `/speckit.specify`
   - Verify hooks work (TTS notifications)

3. **Commit local changes if satisfied:**
   ```bash
   git add .claude/settings.json .claude/scripts/ .specify/
   git commit -m "chore: Sync Vibe-Coding-Setting updates (local files)"
   ```

4. **Or rollback local changes:**
   ```bash
   git restore .claude/ .specify/
   ```

5. **Global settings rollback (if needed):**
   - Manually restore `~/.claude/` from backup
   - Or re-run `/sync-workspace` with older repo version

### What was NOT changed:
- ✓ Your project's .git directory
- ✓ Your source code
- ✓ Your project-specific files
- ✓ Your git history and branches
```

## Error Handling

### Repository clone failed
```
Error: Failed to clone Vibe-Coding-Setting-swseo repository

Possible causes:
- No internet connection
- GitHub is down
- Repository URL has changed
- Authentication required

Please try again later or check:
https://github.com/swseo92/Vibe-Coding-Setting-swseo
```

### Not in a git repository
```
Warning: Current directory is not a git repository

This command is designed to sync settings to an existing project.

Options:
1. Initialize git: git init
2. Use /init-workspace to create new project from template
3. Cancel and run from correct directory
```

### Permission errors
```
Error: Permission denied writing to .claude/

Possible solutions:
- Check file permissions
- Close any programs using these files
- Run from correct directory
```

## Options

### --local-only
Sync only project local files (skip global settings update)

**Example:**
```bash
/sync-workspace --local-only
# → Updates only .claude/settings.json, .claude/scripts/, .specify/ locally
# → Skips ~/.claude/ and ~/.specify/ global updates
```

### --global-only
Sync only global settings (skip project local files)

**Example:**
```bash
/sync-workspace --global-only
# → Updates only ~/.claude/ and ~/.specify/
# → Skips project local .claude/ and .specify/
```

### --dry-run
Show what would be synced without actually syncing

**Example:**
```bash
/sync-workspace --dry-run
# → Preview changes only, no actual file operations
```

## Implementation Notes

**IMPORTANT:**
1. Use Bash tool to execute git clone
2. Detect platform (Windows/Unix) and use appropriate scripts
3. Always show diff before syncing (project local files only)
4. Get user confirmation via AskUserQuestion
5. Clean up temporary directory in all cases (success/failure)
6. Preserve current project's .git completely
7. **ALWAYS sync global settings (~/.claude/, ~/.specify/) automatically**
8. Show clear summary of what was changed (both local and global)

**Repository URL:**
```
https://github.com/swseo92/Vibe-Coding-Setting-swseo.git
```

**Project Local Sync Targets:**
- `.claude/settings.json` - Hook configuration (경로 의존적)
- `.claude/scripts/` - Hook scripts (notify.py 등, 경로 의존적)
- `.specify/` - Speckit templates and scripts

**Global Sync Targets (Always synced):**
- `~/.claude/commands/` - Slash commands (경로 독립적)
- `~/.claude/agents/` - Agents (경로 독립적)
- `~/.claude/skills/` - Skills (경로 독립적)
- `~/.claude/personas/` - Personas (경로 독립적)
- `~/.claude/scripts/` - Utility scripts (경로 독립적)
- `~/.specify/` - Speckit templates (전역 공유)

**Exclude from sync:**
- `.git/` - Current project's git (NEVER touch)
- `src/`, `tests/`, etc. - Project source code
- `templates/` - Template files (not needed in live projects)
- `speckit/` - Only in Vibe-Coding-Setting repo
- `docs/` - Documentation (project-specific)

## Use Cases

### Use Case 1: Full Sync (Recommended)
```bash
cd ~/my-existing-project
/sync-workspace
# → Updates project local files (.claude/settings.json, .claude/scripts/, .specify/)
# → Updates global settings (~/.claude/, ~/.specify/)
# → All projects now have latest commands/agents/skills!
```

### Use Case 2: Update Only Global Settings
```bash
# Just want latest commands/skills across all projects
cd ~/any-project
/sync-workspace --global-only
# → Updates only ~/.claude/ and ~/.specify/
# → Project local files unchanged
```

### Use Case 3: Update Only Project Local Files
```bash
# Update project hooks/scripts but keep current global commands
cd ~/specific-project
/sync-workspace --local-only
# → Updates only .claude/settings.json, .claude/scripts/, .specify/
# → Global ~/.claude/ unchanged
```

### Use Case 4: Preview Changes
```bash
cd ~/critical-project
/sync-workspace --dry-run
# → See what would change before applying
```

## Related Commands

- `/init-workspace` - Initialize NEW project from template
- `/update-claude-skills` - Update only Anthropic skills from GitHub
- `/apply-settings` - Apply local settings to global ~/.claude/
