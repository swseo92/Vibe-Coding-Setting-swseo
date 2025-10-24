---
name: update-claude-skills
description: Update Anthropic official skills from GitHub
tags: [project, gitignored]
---

# Update Claude Skills

Anthropic 공식 skills를 최신 버전으로 업데이트합니다.

## Usage

```bash
/update-claude-skills
```

## Workflow

### 1. 현재 skills 확인

```bash
# 현재 설치된 skills 목록 확인
ls -la .claude/skills
```

사용자에게 현재 설치된 skills와 업데이트할 것임을 알림.

### 2. 최신 버전 Clone

#### Windows (PowerShell)
```powershell
# 임시 디렉토리에 최신 skills clone
$tempDir = New-Item -ItemType Directory -Path "$env:TEMP\anthropic-skills-$(Get-Random)"
Write-Host "Cloning latest skills from GitHub..." -ForegroundColor Cyan

git clone https://github.com/anthropics/skills.git $tempDir

if (-not (Test-Path $tempDir)) {
    Write-Host "Error: Failed to clone skills repository" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Successfully cloned latest skills" -ForegroundColor Green
```

#### Unix/Linux/Mac (Bash)
```bash
# 임시 디렉토리에 최신 skills clone
TEMP_DIR=$(mktemp -d)
echo "Cloning latest skills from GitHub..."

git clone https://github.com/anthropics/skills.git "$TEMP_DIR"

if [ ! -d "$TEMP_DIR" ]; then
    echo "Error: Failed to clone skills repository"
    exit 1
fi

echo "✓ Successfully cloned latest skills"
```

### 3. Skills 업데이트

#### Windows (PowerShell)
```powershell
# .claude/skills 디렉토리 확인
$skillsDir = ".claude/skills"
if (-not (Test-Path $skillsDir)) {
    Write-Host "Error: .claude/skills directory not found" -ForegroundColor Red
    Write-Host "Run this command from the Vibe-Coding-Setting-swseo repository root" -ForegroundColor Yellow
    Remove-Item -Recurse -Force $tempDir
    exit 1
}

# 각 skill 디렉토리 업데이트
$skillFolders = @(
    "algorithmic-art",
    "artifacts-builder",
    "brand-guidelines",
    "canvas-design",
    "document-skills",
    "internal-comms",
    "mcp-builder",
    "skill-creator",
    "slack-gif-creator",
    "template-skill",
    "theme-factory",
    "webapp-testing"
)

$updatedSkills = @()
$failedSkills = @()

foreach ($skill in $skillFolders) {
    $sourcePath = Join-Path $tempDir $skill
    $targetPath = Join-Path $skillsDir $skill

    if (Test-Path $sourcePath) {
        Write-Host "Updating $skill..." -ForegroundColor Yellow

        # 기존 디렉토리 삭제
        if (Test-Path $targetPath) {
            Remove-Item -Recurse -Force $targetPath
        }

        # 새 버전 복사
        Copy-Item -Recurse -Force $sourcePath $targetPath
        $updatedSkills += $skill
        Write-Host "  ✓ Updated $skill" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Skill '$skill' not found in repository" -ForegroundColor Red
        $failedSkills += $skill
    }
}

# 임시 디렉토리 정리
Remove-Item -Recurse -Force $tempDir
Write-Host ""
Write-Host "Update Summary:" -ForegroundColor Cyan
Write-Host "  Updated: $($updatedSkills.Count) skills" -ForegroundColor Green
if ($failedSkills.Count -gt 0) {
    Write-Host "  Failed: $($failedSkills.Count) skills" -ForegroundColor Red
    Write-Host "  Failed skills: $($failedSkills -join ', ')" -ForegroundColor Yellow
}
```

#### Unix/Linux/Mac (Bash)
```bash
# .claude/skills 디렉토리 확인
SKILLS_DIR=".claude/skills"
if [ ! -d "$SKILLS_DIR" ]; then
    echo "Error: .claude/skills directory not found"
    echo "Run this command from the Vibe-Coding-Setting-swseo repository root"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 각 skill 디렉토리 업데이트
SKILL_FOLDERS=(
    "algorithmic-art"
    "artifacts-builder"
    "brand-guidelines"
    "canvas-design"
    "document-skills"
    "internal-comms"
    "mcp-builder"
    "skill-creator"
    "slack-gif-creator"
    "template-skill"
    "theme-factory"
    "webapp-testing"
)

UPDATED_COUNT=0
FAILED_COUNT=0
FAILED_SKILLS=""

for skill in "${SKILL_FOLDERS[@]}"; do
    SOURCE_PATH="$TEMP_DIR/$skill"
    TARGET_PATH="$SKILLS_DIR/$skill"

    if [ -d "$SOURCE_PATH" ]; then
        echo "Updating $skill..."

        # 기존 디렉토리 삭제
        if [ -d "$TARGET_PATH" ]; then
            rm -rf "$TARGET_PATH"
        fi

        # 새 버전 복사
        cp -r "$SOURCE_PATH" "$TARGET_PATH"
        UPDATED_COUNT=$((UPDATED_COUNT + 1))
        echo "  ✓ Updated $skill"
    else
        echo "  ✗ Skill '$skill' not found in repository"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_SKILLS="$FAILED_SKILLS $skill"
    fi
done

# 임시 디렉토리 정리
rm -rf "$TEMP_DIR"

echo ""
echo "Update Summary:"
echo "  Updated: $UPDATED_COUNT skills"
if [ $FAILED_COUNT -gt 0 ]; then
    echo "  Failed: $FAILED_COUNT skills"
    echo "  Failed skills:$FAILED_SKILLS"
fi
```

### 4. Git 상태 확인

업데이트 후 변경사항 확인:

```bash
git status .claude/skills
```

변경된 파일이 있으면 사용자에게 알림:
```
Updated skills have been modified in .claude/skills/

To commit the changes:
  git add .claude/skills
  git commit -m "chore: Update Anthropic skills to latest version"
  git push

To discard the changes:
  git restore .claude/skills
```

### 5. 완료 메시지

```markdown
## ✅ Skills Update Complete

**Updated:** {count} skills
**Repository:** https://github.com/anthropics/skills

### Updated Skills:
- algorithmic-art
- artifacts-builder
- brand-guidelines
- canvas-design
- document-skills
- internal-comms
- mcp-builder
- skill-creator
- slack-gif-creator
- template-skill
- theme-factory
- webapp-testing

### Next Steps:

1. **Review changes:**
   ```bash
   git diff .claude/skills
   ```

2. **Commit if satisfied:**
   ```bash
   git add .claude/skills
   git commit -m "chore: Update Anthropic skills to latest version"
   git push
   ```

3. **Apply to global settings** (optional):
   ```bash
   /apply-settings
   ```
```

## Error Handling

### Git not installed
```
Error: git is not installed or not in PATH

Please install git first:
- Windows: https://git-scm.com/download/win
- Mac: brew install git
- Linux: sudo apt-get install git
```

### .claude/skills not found
```
Error: .claude/skills directory not found

Please run this command from the Vibe-Coding-Setting-swseo repository root.
Current directory: {pwd}
```

### Network errors
```
Error: Failed to clone skills repository

Possible causes:
- No internet connection
- GitHub is down
- Repository URL has changed

Please try again later or check:
https://github.com/anthropics/skills
```

## Implementation Notes

**IMPORTANT:**
1. Use Bash tool to execute all git and file operations
2. Detect platform (Windows/Unix) and use appropriate scripts
3. Show progress for each skill being updated
4. Handle missing skills gracefully
5. Clean up temporary directory in all cases (success/failure)
6. Do NOT automatically commit - let user review changes first

**Platform Detection:**
```python
import platform
is_windows = platform.system() == "Windows"
```

## Customization

사용자가 일부 skills만 유지하고 싶은 경우:
- .claude/skills/에서 원하지 않는 skill 디렉토리 삭제
- update 실행 시 해당 skills는 건너뜀
- 새로 받고 싶으면 수동으로 복사하거나 전체 재설치

## Related Commands

- `/apply-settings` - 업데이트된 skills를 전역 설정에 적용
- `/init-workspace` - 새 프로젝트에 템플릿 적용 (skills와는 무관)
