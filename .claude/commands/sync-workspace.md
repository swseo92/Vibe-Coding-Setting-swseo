---
name: sync-workspace
description: Sync latest Vibe-Coding-Setting changes to current project
tags: [project, gitignored]
---

# Sync Workspace Settings

Vibe-Coding-Setting-swseo GitHub 저장소의 최신 변경사항을 현재 프로젝트에 적용합니다.

**중요:**
- 현재 프로젝트의 `.git`은 그대로 유지되며, 설정 파일들만 업데이트됩니다.
- Vibe-Coding-Setting-swseo 저장소 자체에서 실행 시, 자동으로 전역 설정(`~/.claude/`, `~/.specify/`)도 업데이트됩니다.

## Usage

```bash
# 기본 실행 (전체 동기화)
/sync-workspace

# 특정 항목만 동기화
/sync-workspace --only claude-config
/sync-workspace --only specify

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

동기화할 파일들의 차이를 분석합니다.

#### Windows (PowerShell)
```powershell
function Compare-Settings {
    param($SourceDir, $TargetDir)

    $changes = @{
        "New" = @()
        "Modified" = @()
        "Unchanged" = @()
    }

    # .claude 디렉토리 비교
    if (Test-Path "$SourceDir/.claude") {
        Get-ChildItem -Recurse -File "$SourceDir/.claude" | ForEach-Object {
            $relativePath = $_.FullName.Substring("$SourceDir/.claude".Length + 1)
            $targetFile = Join-Path "$TargetDir/.claude" $relativePath

            if (-not (Test-Path $targetFile)) {
                $changes["New"] += ".claude/$relativePath"
            } elseif ((Get-FileHash $_.FullName).Hash -ne (Get-FileHash $targetFile).Hash) {
                $changes["Modified"] += ".claude/$relativePath"
            } else {
                $changes["Unchanged"] += ".claude/$relativePath"
            }
        }
    }

    # .specify 디렉토리 비교
    if (Test-Path "$SourceDir/.specify") {
        Get-ChildItem -Recurse -File "$SourceDir/.specify" | ForEach-Object {
            $relativePath = $_.FullName.Substring("$SourceDir/.specify".Length + 1)
            $targetFile = Join-Path "$TargetDir/.specify" $relativePath

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

$changes = Compare-Settings -SourceDir $tempDir -TargetDir "."

# 결과 출력
Write-Host "`n=== Sync Preview ===" -ForegroundColor Cyan

if ($changes["New"].Count -gt 0) {
    Write-Host "`nNew files ($($changes["New"].Count)):" -ForegroundColor Green
    $changes["New"] | ForEach-Object { Write-Host "  + $_" -ForegroundColor Green }
}

if ($changes["Modified"].Count -gt 0) {
    Write-Host "`nModified files ($($changes["Modified"].Count)):" -ForegroundColor Yellow
    $changes["Modified"] | ForEach-Object { Write-Host "  ~ $_" -ForegroundColor Yellow }
}

if ($changes["New"].Count -eq 0 -and $changes["Modified"].Count -eq 0) {
    Write-Host "`nNo changes - already up to date!" -ForegroundColor Green
    Remove-Item -Recurse -Force $tempDir
    exit 0
}

Write-Host "`nUnchanged: $($changes["Unchanged"].Count) files" -ForegroundColor Gray
```

#### Unix/Linux/Mac (Bash)
```bash
compare_settings() {
    local source_dir="$1"
    local target_dir="$2"

    NEW_FILES=()
    MODIFIED_FILES=()
    UNCHANGED_COUNT=0

    # .claude 디렉토리 비교
    if [ -d "$source_dir/.claude" ]; then
        while IFS= read -r -d '' file; do
            relative_path="${file#$source_dir/.claude/}"
            target_file="$target_dir/.claude/$relative_path"

            if [ ! -f "$target_file" ]; then
                NEW_FILES+=(".claude/$relative_path")
            elif ! cmp -s "$file" "$target_file"; then
                MODIFIED_FILES+=(".claude/$relative_path")
            else
                ((UNCHANGED_COUNT++))
            fi
        done < <(find "$source_dir/.claude" -type f -print0)
    fi

    # .specify 디렉토리 비교
    if [ -d "$source_dir/.specify" ]; then
        while IFS= read -r -d '' file; do
            relative_path="${file#$source_dir/.specify/}"
            target_file="$target_dir/.specify/$relative_path"

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
    echo "=== Sync Preview ==="

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

    if [ ${#NEW_FILES[@]} -eq 0 ] && [ ${#MODIFIED_FILES[@]} -eq 0 ]; then
        echo ""
        echo "No changes - already up to date!"
        rm -rf "$TEMP_DIR"
        exit 0
    fi

    echo ""
    echo "Unchanged: $UNCHANGED_COUNT files"
}

compare_settings "$TEMP_DIR" "."
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

### 5. 동기화 실행

변경사항 적용:

#### Windows (PowerShell)
```powershell
function Sync-Settings {
    param($SourceDir, $TargetDir, $OnlyItem = $null)

    $syncItems = @{
        "claude-config" = ".claude"
        "specify" = ".specify"
    }

    # Filter if --only specified
    if ($OnlyItem) {
        $syncItems = @{$OnlyItem = $syncItems[$OnlyItem]}
    }

    $totalSynced = 0

    foreach ($item in $syncItems.GetEnumerator()) {
        $name = $item.Key
        $dir = $item.Value
        $sourcePath = Join-Path $SourceDir $dir
        $targetPath = Join-Path $TargetDir $dir

        if (Test-Path $sourcePath) {
            Write-Host "Syncing $name..." -ForegroundColor Yellow

            # 타겟 디렉토리 백업 (선택사항)
            # if (Test-Path $targetPath) {
            #     $backupPath = "$targetPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            #     Copy-Item -Recurse $targetPath $backupPath
            # }

            # 기존 디렉토리 제거
            if (Test-Path $targetPath) {
                Remove-Item -Recurse -Force $targetPath
            }

            # 새 버전 복사
            Copy-Item -Recurse -Force $sourcePath $targetPath

            $fileCount = (Get-ChildItem -Recurse -File $targetPath).Count
            $totalSynced += $fileCount

            Write-Host "  ✓ Synced $name ($fileCount files)" -ForegroundColor Green
        } else {
            Write-Host "  ⊘ $name not found in source, skipping" -ForegroundColor Gray
        }
    }

    return $totalSynced
}

$syncedCount = Sync-Settings -SourceDir $tempDir -TargetDir "." -OnlyItem $OnlyItem
```

#### Unix/Linux/Mac (Bash)
```bash
sync_settings() {
    local source_dir="$1"
    local target_dir="$2"
    local only_item="$3"

    declare -A sync_items=(
        ["claude-config"]=".claude"
        ["specify"]=".specify"
    )

    local total_synced=0

    for name in "${!sync_items[@]}"; do
        # Filter if --only specified
        if [ -n "$only_item" ] && [ "$name" != "$only_item" ]; then
            continue
        fi

        local dir="${sync_items[$name]}"
        local source_path="$source_dir/$dir"
        local target_path="$target_dir/$dir"

        if [ -d "$source_path" ]; then
            echo "Syncing $name..."

            # 기존 디렉토리 제거
            if [ -d "$target_path" ]; then
                rm -rf "$target_path"
            fi

            # 새 버전 복사
            cp -r "$source_path" "$target_path"

            local file_count=$(find "$target_path" -type f | wc -l)
            total_synced=$((total_synced + file_count))

            echo "  ✓ Synced $name ($file_count files)"
        else
            echo "  ⊘ $name not found in source, skipping"
        fi
    done

    echo "$total_synced"
}

SYNCED_COUNT=$(sync_settings "$TEMP_DIR" "." "$ONLY_ITEM")
```

### 6. Apply Settings to Global Config

프로젝트 설정을 전역 설정에 자동으로 적용합니다 (`/apply-settings` 기능).

**중요:** 이 단계는 현재 프로젝트가 **Vibe-Coding-Setting-swseo 저장소 자체**인 경우에만 실행됩니다.

#### Windows (PowerShell)
```powershell
# 현재 프로젝트가 Vibe-Coding-Setting 저장소인지 확인
$gitRemote = git remote get-url origin 2>$null
if ($gitRemote -match "Vibe-Coding-Setting-swseo") {
    Write-Host "`nApplying settings to global config (~/.claude/)..." -ForegroundColor Cyan

    # .claude 전체 복사
    if (Test-Path ".claude") {
        $globalClaudeDir = Join-Path $env:USERPROFILE ".claude"

        # 백업 생성 (선택사항)
        # $backupDir = "$globalClaudeDir.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        # Copy-Item -Recurse $globalClaudeDir $backupDir -ErrorAction SilentlyContinue

        # 기존 디렉토리 제거 후 복사
        if (Test-Path $globalClaudeDir) {
            Remove-Item -Recurse -Force $globalClaudeDir -ErrorAction SilentlyContinue
        }
        Copy-Item -Recurse -Force ".claude" $globalClaudeDir
        Write-Host "  ✓ Synced .claude/ to ~/.claude/" -ForegroundColor Green
    }

    # settings.local.json → settings.json
    if (Test-Path ".claude/settings.local.json") {
        Copy-Item -Force ".claude/settings.local.json" "$globalClaudeDir/settings.json"
        Write-Host "  ✓ Synced settings.local.json to settings.json" -ForegroundColor Green
    }

    # .specify 전체 복사
    if (Test-Path ".specify") {
        $globalSpecifyDir = Join-Path $env:USERPROFILE ".specify"
        if (Test-Path $globalSpecifyDir) {
            Remove-Item -Recurse -Force $globalSpecifyDir -ErrorAction SilentlyContinue
        }
        Copy-Item -Recurse -Force ".specify" $globalSpecifyDir
        Write-Host "  ✓ Synced .specify/ to ~/.specify/" -ForegroundColor Green
    }

    Write-Host "`n✓ Global settings updated!" -ForegroundColor Green
} else {
    Write-Host "`nSkipping global settings sync (not in Vibe-Coding-Setting repo)" -ForegroundColor Gray
}
```

#### Unix/Linux/Mac (Bash)
```bash
# 현재 프로젝트가 Vibe-Coding-Setting 저장소인지 확인
GIT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
if [[ "$GIT_REMOTE" == *"Vibe-Coding-Setting-swseo"* ]]; then
    echo ""
    echo "Applying settings to global config (~/.claude/)..."

    # .claude 전체 복사
    if [ -d ".claude" ]; then
        GLOBAL_CLAUDE_DIR="$HOME/.claude"

        # 기존 디렉토리 제거 후 복사
        rm -rf "$GLOBAL_CLAUDE_DIR" 2>/dev/null
        cp -r ".claude" "$GLOBAL_CLAUDE_DIR"
        echo "  ✓ Synced .claude/ to ~/.claude/"
    fi

    # settings.local.json → settings.json
    if [ -f ".claude/settings.local.json" ]; then
        cp -f ".claude/settings.local.json" "$GLOBAL_CLAUDE_DIR/settings.json"
        echo "  ✓ Synced settings.local.json to settings.json"
    fi

    # .specify 전체 복사
    if [ -d ".specify" ]; then
        GLOBAL_SPECIFY_DIR="$HOME/.specify"
        rm -rf "$GLOBAL_SPECIFY_DIR" 2>/dev/null
        cp -r ".specify" "$GLOBAL_SPECIFY_DIR"
        echo "  ✓ Synced .specify/ to ~/.specify/"
    fi

    echo ""
    echo "✓ Global settings updated!"
else
    echo ""
    echo "Skipping global settings sync (not in Vibe-Coding-Setting repo)"
fi
```

### 7. 정리 및 완료

임시 디렉토리 정리:

```powershell
# Windows
Remove-Item -Recurse -Force $tempDir
```

```bash
# Unix
rm -rf "$TEMP_DIR"
```

### 8. 완료 메시지

```markdown
## ✅ Workspace Sync Complete

**Source:** Vibe-Coding-Setting-swseo (latest from GitHub)
**Target:** Current project

### Changes Applied:
- ✓ .claude/ - 13 commands, 2 agents, 12 skills, 2 personas, 4 scripts
- ✓ .specify/ - Templates and scripts updated

**Summary:**
- Total files synced: 145
- New files added: 3
- Files updated: 5
- Time taken: 3.2s

### Global Settings:
- ✓ Applied to ~/.claude/ (if in Vibe-Coding-Setting repo)
- ✓ Applied to ~/.specify/ (if in Vibe-Coding-Setting repo)

### Next Steps:

1. **Review changes:**
   ```bash
   git status
   git diff .claude/
   git diff .specify/
   ```

2. **Test the changes:**
   - Try new commands: `/help`
   - Verify settings work

3. **Commit if satisfied:**
   ```bash
   git add .claude/ .specify/
   git commit -m "chore: Sync Vibe-Coding-Setting updates"
   ```

4. **Or rollback:**
   ```bash
   git restore .claude/ .specify/
   ```

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

### --only <item>
Sync only specific item

**Available items:**
- `claude-config` - Only .claude/ directory
- `specify` - Only .specify/ directory

**Example:**
```bash
/sync-workspace --only claude-config
```

### --dry-run
Show what would be synced without actually syncing

**Example:**
```bash
/sync-workspace --dry-run
```

## Implementation Notes

**IMPORTANT:**
1. Use Bash tool to execute git clone
2. Detect platform (Windows/Unix) and use appropriate scripts
3. Always show diff before syncing
4. Get user confirmation via AskUserQuestion
5. Clean up temporary directory in all cases (success/failure)
6. Preserve current project's .git completely
7. Only sync .claude/ and .specify/ directories
8. **Automatically apply settings to global config if in Vibe-Coding-Setting repo**
9. Show clear summary of what was changed

**Repository URL:**
```
https://github.com/swseo92/Vibe-Coding-Setting-swseo.git
```

**Sync Targets:**
- `.claude/` - All Claude Code configurations
  - commands/
  - agents/
  - skills/
  - personas/
  - scripts/
  - settings.local.json
- `.specify/` - Speckit templates and scripts

**Exclude from sync:**
- `.git/` - Current project's git (NEVER touch)
- `src/`, `tests/`, etc. - Project source code
- `templates/` - Template files (not needed in projects)
- `speckit/` - Only in Vibe-Coding-Setting repo
- `docs/` - Documentation (project-specific)

## Use Cases

### Use Case 1: Update Commands on Existing Project
```bash
cd ~/my-existing-project
/sync-workspace --only claude-config
# → Get latest commands, agents, skills
```

### Use Case 2: Sync After Vibe-Coding-Setting Update
```bash
# Vibe-Coding-Setting repo got new updates
cd ~/my-api-project
/sync-workspace
# → Apply all latest changes
```

### Use Case 3: Preview Changes
```bash
cd ~/critical-project
/sync-workspace --dry-run
# → See what would change before applying
```

## Related Commands

- `/init-workspace` - Initialize NEW project from template
- `/update-claude-skills` - Update only Anthropic skills from GitHub
- `/apply-settings` - Apply local settings to global ~/.claude/
