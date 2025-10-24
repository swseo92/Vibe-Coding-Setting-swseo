---
name: sync-workspace
description: Sync workspace settings between local and global configurations
tags: [project, gitignored]
---

# Sync Workspace Settings

로컬 프로젝트 설정과 전역 설정(`~/.claude/`, `~/.specify/`) 간 양방향 동기화를 수행합니다.

## Usage

```bash
# 전역 → 로컬 (pull)
/sync-workspace --from-global
/sync-workspace pull

# 로컬 → 전역 (push)
/sync-workspace --to-global
/sync-workspace push

# 대화형 모드 (기본)
/sync-workspace

# 특정 항목만 동기화
/sync-workspace --from-global --only commands
/sync-workspace push --only skills
```

## Workflow

### 1. 방향 결정

사용자가 방향을 지정하지 않으면 AskUserQuestion으로 확인:

**질문:**
"어떤 방향으로 동기화하시겠습니까?"

**옵션:**
1. **From Global (Pull)** - 전역 설정을 로컬로 가져오기
   - 설명: `~/.claude/` → 현재 프로젝트
   - 용도: 다른 머신이나 업데이트된 전역 설정 가져오기

2. **To Global (Push)** - 로컬 설정을 전역으로 보내기
   - 설명: 현재 프로젝트 → `~/.claude/`
   - 용도: 이 프로젝트의 설정을 모든 프로젝트에 적용

3. **Both (Interactive)** - 대화형으로 파일별 선택
   - 설명: 파일마다 어느 버전을 유지할지 선택
   - 용도: 세밀한 제어가 필요할 때

### 2. 동기화 전 검사

#### Windows (PowerShell)
```powershell
$globalClaude = Join-Path $env:USERPROFILE ".claude"
$globalSpecify = Join-Path $env:USERPROFILE ".specify"
$localClaude = ".claude"
$localSpecify = ".specify"

# 디렉토리 존재 확인
if (-not (Test-Path $globalClaude)) {
    Write-Host "Warning: Global .claude directory not found at $globalClaude" -ForegroundColor Yellow
    Write-Host "Run /apply-settings first to initialize global settings" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $localClaude)) {
    Write-Host "Error: Local .claude directory not found" -ForegroundColor Red
    Write-Host "This command must be run from a repository with .claude/ directory" -ForegroundColor Yellow
    exit 1
}
```

#### Unix/Linux/Mac (Bash)
```bash
GLOBAL_CLAUDE="$HOME/.claude"
GLOBAL_SPECIFY="$HOME/.specify"
LOCAL_CLAUDE=".claude"
LOCAL_SPECIFY=".specify"

# 디렉토리 존재 확인
if [ ! -d "$GLOBAL_CLAUDE" ]; then
    echo "Warning: Global .claude directory not found at $GLOBAL_CLAUDE"
    echo "Run /apply-settings first to initialize global settings"
    exit 1
fi

if [ ! -d "$LOCAL_CLAUDE" ]; then
    echo "Error: Local .claude directory not found"
    echo "This command must be run from a repository with .claude/ directory"
    exit 1
fi
```

### 3. 차이점 분석

동기화 전에 변경사항을 사용자에게 보여줍니다.

#### Windows (PowerShell)
```powershell
function Compare-Directories {
    param($Source, $Target, $Label)

    Write-Host "`n=== $Label ===" -ForegroundColor Cyan

    $changes = @{
        "New" = @()
        "Modified" = @()
        "Deleted" = @()
    }

    # Source에만 있는 파일 (New)
    Get-ChildItem -Recurse -File $Source | ForEach-Object {
        $relativePath = $_.FullName.Substring($Source.Length + 1)
        $targetFile = Join-Path $Target $relativePath

        if (-not (Test-Path $targetFile)) {
            $changes["New"] += $relativePath
        } elseif ((Get-FileHash $_.FullName).Hash -ne (Get-FileHash $targetFile).Hash) {
            $changes["Modified"] += $relativePath
        }
    }

    # Target에만 있는 파일 (Deleted)
    Get-ChildItem -Recurse -File $Target | ForEach-Object {
        $relativePath = $_.FullName.Substring($Target.Length + 1)
        $sourceFile = Join-Path $Source $relativePath

        if (-not (Test-Path $sourceFile)) {
            $changes["Deleted"] += $relativePath
        }
    }

    # 결과 출력
    if ($changes["New"].Count -gt 0) {
        Write-Host "`nNew files ($($changes["New"].Count)):" -ForegroundColor Green
        $changes["New"] | ForEach-Object { Write-Host "  + $_" -ForegroundColor Green }
    }

    if ($changes["Modified"].Count -gt 0) {
        Write-Host "`nModified files ($($changes["Modified"].Count)):" -ForegroundColor Yellow
        $changes["Modified"] | ForEach-Object { Write-Host "  ~ $_" -ForegroundColor Yellow }
    }

    if ($changes["Deleted"].Count -gt 0) {
        Write-Host "`nDeleted files ($($changes["Deleted"].Count)):" -ForegroundColor Red
        $changes["Deleted"] | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    }

    if ($changes["New"].Count -eq 0 -and $changes["Modified"].Count -eq 0 -and $changes["Deleted"].Count -eq 0) {
        Write-Host "  No changes" -ForegroundColor Gray
    }

    return $changes
}

# From Global 방향
if ($Direction -eq "from-global") {
    $changes = Compare-Directories -Source $globalClaude -Target $localClaude -Label "Changes from Global → Local"
}
# To Global 방향
elseif ($Direction -eq "to-global") {
    $changes = Compare-Directories -Source $localClaude -Target $globalClaude -Label "Changes from Local → Global"
}
```

### 4. 확인 프롬프트

변경사항이 있으면 사용자 확인:

**AskUserQuestion:**
```
다음 변경사항을 적용하시겠습니까?

- 새 파일: 5개
- 수정된 파일: 3개
- 삭제될 파일: 1개
```

**옵션:**
- "Yes, proceed" - 계속 진행
- "No, cancel" - 취소
- "Show details" - 파일 목록 자세히 보기

### 5. 동기화 실행

#### From Global (Pull)

**Windows (PowerShell):**
```powershell
function Sync-FromGlobal {
    param($OnlyItem = $null)

    $itemsToCopy = @{
        "commands" = @{
            Source = Join-Path $globalClaude "commands"
            Target = Join-Path $localClaude "commands"
        }
        "agents" = @{
            Source = Join-Path $globalClaude "agents"
            Target = Join-Path $localClaude "agents"
        }
        "skills" = @{
            Source = Join-Path $globalClaude "skills"
            Target = Join-Path $localClaude "skills"
        }
        "personas" = @{
            Source = Join-Path $globalClaude "personas"
            Target = Join-Path $localClaude "personas"
        }
        "scripts" = @{
            Source = Join-Path $globalClaude "scripts"
            Target = Join-Path $localClaude "scripts"
        }
        "settings" = @{
            Source = Join-Path $globalClaude "settings.json"
            Target = Join-Path $localClaude "settings.local.json"
        }
        "specify" = @{
            Source = $globalSpecify
            Target = $localSpecify
        }
    }

    # Filter if --only specified
    if ($OnlyItem) {
        $itemsToCopy = @{$OnlyItem = $itemsToCopy[$OnlyItem]}
    }

    foreach ($item in $itemsToCopy.GetEnumerator()) {
        $name = $item.Key
        $source = $item.Value.Source
        $target = $item.Value.Target

        if (Test-Path $source) {
            Write-Host "Syncing $name..." -ForegroundColor Yellow

            # 디렉토리면 전체 복사
            if (Test-Path $source -PathType Container) {
                if (Test-Path $target) {
                    Remove-Item -Recurse -Force $target
                }
                Copy-Item -Recurse -Force $source $target
            }
            # 파일이면 개별 복사
            else {
                $targetDir = Split-Path -Parent $target
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
                }
                Copy-Item -Force $source $target
            }

            Write-Host "  ✓ Synced $name" -ForegroundColor Green
        } else {
            Write-Host "  ⊘ $name not found in global, skipping" -ForegroundColor Gray
        }
    }
}

Sync-FromGlobal -OnlyItem $OnlyItem
```

**Unix/Linux/Mac (Bash):**
```bash
sync_from_global() {
    local only_item="$1"

    declare -A items_to_copy=(
        ["commands"]="$GLOBAL_CLAUDE/commands:$LOCAL_CLAUDE/commands"
        ["agents"]="$GLOBAL_CLAUDE/agents:$LOCAL_CLAUDE/agents"
        ["skills"]="$GLOBAL_CLAUDE/skills:$LOCAL_CLAUDE/skills"
        ["personas"]="$GLOBAL_CLAUDE/personas:$LOCAL_CLAUDE/personas"
        ["scripts"]="$GLOBAL_CLAUDE/scripts:$LOCAL_CLAUDE/scripts"
        ["settings"]="$GLOBAL_CLAUDE/settings.json:$LOCAL_CLAUDE/settings.local.json"
        ["specify"]="$GLOBAL_SPECIFY:$LOCAL_SPECIFY"
    )

    for name in "${!items_to_copy[@]}"; do
        # Filter if --only specified
        if [ -n "$only_item" ] && [ "$name" != "$only_item" ]; then
            continue
        fi

        IFS=':' read -r source target <<< "${items_to_copy[$name]}"

        if [ -e "$source" ]; then
            echo "Syncing $name..."

            # 디렉토리면 전체 복사
            if [ -d "$source" ]; then
                rm -rf "$target"
                cp -r "$source" "$target"
            # 파일이면 개별 복사
            else
                mkdir -p "$(dirname "$target")"
                cp "$source" "$target"
            fi

            echo "  ✓ Synced $name"
        else
            echo "  ⊘ $name not found in global, skipping"
        fi
    done
}

sync_from_global "$ONLY_ITEM"
```

#### To Global (Push)

**Windows (PowerShell):**
```powershell
function Sync-ToGlobal {
    param($OnlyItem = $null)

    $itemsToCopy = @{
        "commands" = @{
            Source = Join-Path $localClaude "commands"
            Target = Join-Path $globalClaude "commands"
        }
        "agents" = @{
            Source = Join-Path $localClaude "agents"
            Target = Join-Path $globalClaude "agents"
        }
        "skills" = @{
            Source = Join-Path $localClaude "skills"
            Target = Join-Path $globalClaude "skills"
        }
        "personas" = @{
            Source = Join-Path $localClaude "personas"
            Target = Join-Path $globalClaude "personas"
        }
        "scripts" = @{
            Source = Join-Path $localClaude "scripts"
            Target = Join-Path $globalClaude "scripts"
        }
        "settings" = @{
            Source = Join-Path $localClaude "settings.local.json"
            Target = Join-Path $globalClaude "settings.json"
        }
        "specify" = @{
            Source = $localSpecify
            Target = $globalSpecify
        }
    }

    # Filter if --only specified
    if ($OnlyItem) {
        $itemsToCopy = @{$OnlyItem = $itemsToCopy[$OnlyItem]}
    }

    foreach ($item in $itemsToCopy.GetEnumerator()) {
        $name = $item.Key
        $source = $item.Value.Source
        $target = $item.Value.Target

        if (Test-Path $source) {
            Write-Host "Syncing $name..." -ForegroundColor Yellow

            # 디렉토리면 전체 복사
            if (Test-Path $source -PathType Container) {
                if (Test-Path $target) {
                    Remove-Item -Recurse -Force $target
                }
                Copy-Item -Recurse -Force $source $target
            }
            # 파일이면 개별 복사
            else {
                $targetDir = Split-Path -Parent $target
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
                }
                Copy-Item -Force $source $target
            }

            Write-Host "  ✓ Synced $name" -ForegroundColor Green
        } else {
            Write-Host "  ⊘ $name not found in local, skipping" -ForegroundColor Gray
        }
    }
}

Sync-ToGlobal -OnlyItem $OnlyItem
```

### 6. 완료 메시지

```markdown
## ✅ Workspace Sync Complete

**Direction:** Global → Local (Pull)
**Synced Items:**
- ✓ commands (13 files)
- ✓ agents (2 files)
- ✓ skills (12 directories)
- ✓ personas (2 files)
- ✓ scripts (4 files)
- ✓ settings (settings.json → settings.local.json)
- ⊘ specify (not found in global)

**Summary:**
- Total files synced: 145
- Time taken: 2.3s

### Next Steps:

**If synced FROM global:**
- Review changes: `git diff .claude/`
- Commit if satisfied: `git add .claude/ && git commit`

**If synced TO global:**
- Global settings updated at: `~/.claude/`
- All projects will now use these settings

### Rollback:
To undo this sync, run:
```bash
git restore .claude/  # If synced from global
# or
/sync-workspace --from-global  # If synced to global
```
```

## Error Handling

### Global directory not found
```
Error: Global .claude directory not found

Initialize global settings first:
1. Run /apply-settings from Vibe-Coding-Setting-swseo repository
2. Or manually create ~/.claude/

Current location: ~/.claude/ (not found)
```

### Sync conflict detection
```
Warning: Conflicting changes detected

The following files have been modified in both locations:
- .claude/commands/custom-command.md
- .claude/settings.local.json

Options:
1. Keep local version
2. Keep global version
3. Cancel and resolve manually
```

### Permission errors
```
Error: Permission denied writing to ~/.claude/

Possible solutions:
- Check file permissions: ls -la ~/.claude/
- Run with appropriate permissions
- Check if files are in use by another process
```

## Implementation Notes

**IMPORTANT:**
1. Use Bash tool for all file operations
2. Detect platform (Windows/Unix) automatically
3. Always show diff before syncing
4. Provide rollback instructions
5. Handle settings.json vs settings.local.json correctly
6. Support --only filter for partial sync
7. Create backup before major operations (optional)

**Sync Items:**
- `commands/` - Slash commands
- `agents/` - Custom agents
- `skills/` - Skills
- `personas/` - Personas
- `scripts/` - Scripts
- `settings.json` ↔ `settings.local.json`
- `.specify/` - Speckit templates (optional)

**Exclude from sync:**
- `.claude/shell-snapshots/`
- `.claude/history/`
- `.claude/debug/`
- `.claude/.credentials`

## Options

### --from-global / pull
Pull settings from global to local

### --to-global / push
Push settings from local to global

### --only <item>
Sync only specific item (commands, agents, skills, personas, scripts, settings, specify)

### --dry-run
Show what would be synced without actually syncing

### --backup
Create backup before syncing

## Related Commands

- `/apply-settings` - One-way sync: local → global (legacy)
- `/update-claude-skills` - Update Anthropic skills from GitHub
- `/init-workspace` - Initialize new project from template
