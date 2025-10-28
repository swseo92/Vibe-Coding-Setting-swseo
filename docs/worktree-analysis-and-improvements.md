# Worktree Commands: 종합 분석 및 개선 제안

## 목차
1. [현재 구현 분석](#현재-구현-분석)
2. [아키텍처 비교: Native Git Worktree vs Copy-based](#아키텍처-비교)
3. [명령어별 개선 제안](#명령어별-개선-제안)
4. [새로운 명령어 제안](#새로운-명령어-제안)
5. [완전한 워크플로우 예시](#완전한-워크플로우-예시)
6. [구현 로드맵](#구현-로드맵)

---

## 현재 구현 분석

### 전체 아키텍처 개요

**핵심 개념**: Python `shutil.copytree()`를 사용한 디렉토리 복제 방식
- 전체 프로젝트 디렉토리를 `clone/<branch-name>/`으로 복사
- 각 클론은 독립적인 git repository + 가상환경
- 원본과 클론은 git origin을 통해 동기화

**디렉토리 구조**:
```
project-root/
├── .git/
├── src/
├── tests/
├── pyproject.toml
└── clone/
    ├── feature-a/         # Clone 1
    │   ├── .git/
    │   ├── .venv/         # 독립적 가상환경
    │   ├── src/
    │   └── ...
    └── feature-b/         # Clone 2
        ├── .git/
        ├── .venv/
        └── ...
```

---

## 아키텍처 비교

### Option 1: Native Git Worktree (현재 미사용)

**장점**:
- Git 내장 기능, 별도 도구 불필요
- 디스크 공간 효율적 (.git 공유)
- Git이 직접 관리 (안전성 보장)
- 빠른 생성 속도
- `git worktree list` 내장 명령어

**단점**:
- 가상환경(.venv) 자동 생성 안 됨
- 의존성 설치 수동 작업 필요
- Python 프로젝트 특화 기능 부족
- 복잡한 설정 필요 (pre-create hooks)

**예시**:
```bash
git worktree add ../feature-a feature-a
cd ../feature-a
uv venv
uv sync
```

### Option 2: Copy-based Approach (현재 구현) ⭐

**장점**:
- 완전한 격리 (가상환경 포함)
- Python 프로젝트 최적화
- 유연한 복사 패턴 (.venv, node_modules 제외)
- 플랫폼 독립적
- 자동화된 초기 설정 (uv venv, uv sync)
- 언커밋 변경사항 포함 가능

**단점**:
- 디스크 공간 많이 사용
- Python 의존성 필요
- 느린 생성 속도 (대용량 프로젝트)
- Git worktree 표준 도구 사용 불가

**현재 무시 패턴**:
```python
ignore_patterns(
    'node_modules', '__pycache__', '.venv', 'venv',
    'dist', 'build', '.pytest_cache', '.mypy_cache',
    'clone', '.idea', '*.pyc', '*.pyo', '*.pyd', '.DS_Store'
)
```

### 결론: Copy-based가 Python 프로젝트에 더 적합

**이유**:
1. 가상환경 자동 생성 + 의존성 설치 자동화
2. 언커밋 변경사항 포함 (실험적 작업 보존)
3. 완전한 격리로 인한 안전성
4. Python 프로젝트에 특화된 워크플로우

**권장**: 현재 아키텍처 유지하되, 성능 및 안전성 개선에 집중

---

## 명령어별 개선 제안

### 1. /worktree-create

#### 현재 구현 분석

**강점**:
- ✅ 철저한 안전성 체크 (remote, branch, commits)
- ✅ 가상환경 자동 생성 (uv venv)
- ✅ 의존성 자동 설치 (uv sync)
- ✅ Editable install 시도 (uv pip install -e .)
- ✅ 유연한 무시 패턴

**약점**:
- ❌ 대용량 프로젝트에서 느림
- ❌ 중복 생성 체크 없음 (기존 clone 덮어쓰기 가능)
- ❌ 진행 상황 표시 없음
- ❌ 생성 실패 시 부분 정리 없음
- ❌ Windows 경로 길이 제한 문제 가능

#### 개선 제안

**1) 중복 생성 방지**:
```markdown
## SAFETY CHECKS (Run these first and STOP if any fail)

0. Check if clone already exists:
!test -d clone/$1 && echo "ERROR: Clone already exists" || echo "OK: No existing clone"

**If clone exists, STOP and warn:**
- "⚠️ Clone 'clone/$1' already exists. Delete it first with `/worktree-delete $1` or choose a different name."
```

**2) 진행 상황 표시**:
```markdown
## WORKTREE CREATION (With progress tracking)

!echo "📦 Step 1/5: Creating clone directory..."
!mkdir -p clone

!echo "📋 Step 2/5: Copying project files (excluding .venv, node_modules, etc.)..."
!python -c "import shutil; import os; print('Copying...'); shutil.copytree('.', 'clone/$1', ignore=shutil.ignore_patterns(...)); print('✓ Copy complete')"

!echo "🌿 Step 3/5: Creating new branch '$1'..."
!cd clone/$1 && git checkout -b $1

!echo "🐍 Step 4/5: Setting up Python virtual environment..."
!cd clone/$1 && uv venv

!echo "📚 Step 5/5: Installing dependencies..."
!cd clone/$1 && (uv sync 2>/dev/null || echo "No pyproject.toml found, skipping sync")
```

**3) 실패 시 정리 (Rollback)**:
```markdown
## ERROR HANDLING

If any step fails after directory creation, clean up:
!test -d clone/$1 && rm -rf clone/$1 && echo "⚠️ Creation failed. Cleaned up partial clone."
```

**4) Windows 경로 길이 문제 해결**:
```python
# Windows에서 긴 경로 지원
import sys
if sys.platform == 'win32':
    import ctypes
    kernel32 = ctypes.windll.kernel32
    kernel32.SetFileAttributesW('clone/$1', 0x80)  # FILE_ATTRIBUTE_NORMAL
```

**5) 성능 개선 - 병렬 복사 (선택적)**:
```python
# 큰 파일 병렬 복사 (고급 기능)
from concurrent.futures import ThreadPoolExecutor
# 구현 생략 (필요 시 추가)
```

#### 개선된 전체 명령어

```markdown
---
description: Create a new cloned directory with full working environment
argument-hint: [branch-name]
allowed-tools: Bash(git:*), Bash(mkdir:*), Bash(uv:*), Bash(python:*), Bash(test:*), Bash(echo:*)
---

Create a new cloned directory with complete working environment.

Branch name to create: $1

## SAFETY CHECKS (Run these first and STOP if any fail)

0. Check if clone already exists:
!test -d clone/$1 && echo "ERROR: Clone 'clone/$1' already exists" && exit 1 || echo "✓ No existing clone"

1. Check remote GitHub configuration:
!git remote -v

2. Check current branch is main or master:
!git branch --show-current

3. Check commit history exists (to prevent orphan branches):
!git log --oneline -1

**IMPORTANT**: Before proceeding, verify:
- ✅ No existing clone with same name
- ✅ Remote origin exists and points to github.com
- ✅ Current branch is "main" or "master"
- ✅ At least one commit exists

**If ANY check fails, STOP and warn the user with appropriate message:**
- Clone exists: "⚠️ Clone 'clone/$1' already exists. Delete it first with `/worktree-delete $1` or choose a different name."
- No remote: "⚠️ No GitHub remote configured. Please set up remote origin first: `git remote add origin <url>`"
- Wrong branch: "⚠️ Not on main/master branch. Please switch to main/master before creating worktree: `git checkout main`"
- No commits: "⚠️ No commits found. Please create initial commit first: `git add . && git commit -m 'Initial commit'`"

## WORKTREE CREATION (With progress tracking and error handling)

Execute the following commands with progress indicators:

!echo "📦 Step 1/5: Creating clone directory structure..."
!mkdir -p clone || (echo "❌ Failed to create clone directory" && exit 1)

!echo "📋 Step 2/5: Copying project files (this may take a while for large projects)..."
!python -c "
import shutil
import os
import sys

try:
    print('  Analyzing files to copy...')
    shutil.copytree(
        '.',
        'clone/$1',
        ignore=shutil.ignore_patterns(
            'node_modules', '__pycache__', '.venv', 'venv',
            'dist', 'build', '.pytest_cache', '.mypy_cache',
            'clone', '.idea', '*.pyc', '*.pyo', '*.pyd', '.DS_Store'
        ),
        dirs_exist_ok=False
    )
    print('  ✓ Files copied successfully')
except Exception as e:
    print(f'  ❌ Copy failed: {e}', file=sys.stderr)
    sys.exit(1)
" || (echo "❌ Copy failed. Cleaning up..." && rm -rf clone/$1 && exit 1)

!echo "🌿 Step 3/5: Creating new branch '$1'..."
!cd clone/$1 && git checkout -b $1 || (echo "❌ Branch creation failed" && cd ../.. && rm -rf clone/$1 && exit 1)

!echo "🐍 Step 4/5: Setting up Python virtual environment..."
!cd clone/$1 && uv venv || echo "⚠️ Virtual environment creation skipped"

!echo "📚 Step 5/5: Installing dependencies..."
!cd clone/$1 && (uv sync 2>/dev/null || echo "ℹ️ No pyproject.toml found, skipping sync")
!cd clone/$1 && (uv pip install -e . 2>/dev/null || echo "ℹ️ No editable install available")

!echo "✅ Clone creation complete!"
!echo ""
!echo "📊 Status:"
!cd clone/$1 && git status --short && git branch -vv

Provide a comprehensive summary including:
- ✅ Branch name and clone directory path
- ✅ What was copied (including uncommitted changes and untracked files)
- ✅ Virtual environment status
- ✅ Dependencies installation status (uv sync)
- ✅ Editable install status (uv pip install -e .)
- ✅ Current git status
- ✅ Disk space used (estimate)
- ✅ Next steps: "Now you can work in `clone/$1/` independently. Use `/worktree-status $1` to check status."
```

---

### 2. /worktree-sync

#### 현재 구현 분석

**강점**:
- ✅ 간단하고 명확한 동기화 흐름
- ✅ Conflict 감지

**약점**:
- ❌ Clone 존재 여부 체크 없음
- ❌ Uncommitted changes 체크 없음 (덮어쓰기 위험)
- ❌ Conflict 발생 시 자동 해결 없음
- ❌ Sync 방향 혼란 (origin = GitHub, not local main)
- ❌ Dry-run 모드 없음

#### 개선 제안

**1) 안전성 체크 추가**:
```markdown
## SAFETY CHECKS

1. Check if clone exists:
!test -d clone/$1 || (echo "ERROR: Clone not found" && exit 1)

2. Check for uncommitted changes in clone:
!cd clone/$1 && git diff-index --quiet HEAD || echo "WARNING: Uncommitted changes detected"

3. Show what will be synced:
!cd clone/$1 && git fetch origin && git log HEAD..origin/$(git -C ../.. branch --show-current) --oneline
```

**2) Dry-run 모드**:
```markdown
## DRY-RUN MODE (Optional)

If user wants to preview changes:
!cd clone/$1 && git fetch origin && git diff HEAD origin/$(git -C ../.. branch --show-current) --stat
```

**3) Conflict 자동 해결 옵션**:
```markdown
## SYNC WITH CONFLICT RESOLUTION

!cd clone/$1 && git merge origin/$(git -C ../.. branch --show-current) || {
    echo "⚠️ Merge conflict detected. Attempting auto-resolution..."
    git merge --strategy-option=theirs origin/$(git -C ../.. branch --show-current) || {
        echo "❌ Auto-resolution failed. Manual intervention required."
        git merge --abort
        exit 1
    }
}
```

**4) 진행 상황 표시**:
```markdown
!echo "🔄 Step 1/3: Fetching latest changes from GitHub..."
!cd clone/$1 && git fetch origin

!echo "🔀 Step 2/3: Merging changes into clone..."
!cd clone/$1 && git merge origin/$(git -C ../.. branch --show-current)

!echo "📊 Step 3/3: Checking final status..."
!cd clone/$1 && git status
```

#### 개선된 전체 명령어

```markdown
---
description: Sync a cloned directory with the original repository
argument-hint: [branch-name]
allowed-tools: Bash(git:*), Bash(test:*), Bash(echo:*)
---

Synchronize the specified cloned directory with the latest changes from GitHub.

Clone to sync: $1

## SAFETY CHECKS

1. Check if clone exists:
!test -d clone/$1 || (echo "❌ ERROR: Clone 'clone/$1' not found. Create it first with /worktree-create" && exit 1)

2. Check for uncommitted changes in clone:
!cd clone/$1 && {
    if ! git diff-index --quiet HEAD; then
        echo "⚠️ WARNING: Clone has uncommitted changes:"
        git status --short
        echo ""
        echo "Continuing will attempt to merge on top of these changes."
        echo "Consider committing or stashing them first."
    else
        echo "✓ No uncommitted changes detected"
    fi
}

3. Get base branch name:
!BASE_BRANCH=$(git branch --show-current) && echo "📌 Base branch: $BASE_BRANCH"

## DRY-RUN PREVIEW (Optional - show what will be synced)

!echo "🔍 Preview: Changes that will be synced:"
!cd clone/$1 && git fetch origin && git log HEAD..origin/$(git -C ../.. branch --show-current) --oneline --max-count=10 || echo "ℹ️ No new commits to sync"

## SYNC OPERATION

!echo ""
!echo "🔄 Step 1/3: Fetching latest changes from origin (GitHub)..."
!cd clone/$1 && git fetch origin

!echo "🔀 Step 2/3: Merging base branch into clone..."
!cd clone/$1 && {
    BASE_BRANCH=$(git -C ../.. branch --show-current)
    if git merge origin/$BASE_BRANCH; then
        echo "✅ Merge successful"
    else
        echo "⚠️ Merge conflict detected. Attempting auto-resolution with 'theirs' strategy..."
        if git merge --strategy-option=theirs origin/$BASE_BRANCH; then
            echo "✅ Auto-resolution successful (accepted incoming changes)"
        else
            echo "❌ Auto-resolution failed. Manual conflict resolution required."
            echo ""
            echo "To resolve manually:"
            echo "  1. cd clone/$1"
            echo "  2. Resolve conflicts in affected files"
            echo "  3. git add <resolved-files>"
            echo "  4. git merge --continue"
            echo ""
            echo "To abort merge:"
            echo "  git merge --abort"
            git merge --abort
            exit 1
        fi
    fi
}

!echo "📊 Step 3/3: Checking final status..."
!cd clone/$1 && git status

!echo ""
!echo "✅ Sync complete!"

Provide a comprehensive summary including:
- ✅ Base branch name
- ✅ Number of commits merged (use: `git log --oneline @{1}..HEAD | wc -l`)
- ✅ Any merge conflicts detected and resolution status
- ✅ Current status of the clone
- ✅ Files changed summary (use: `git diff --stat @{1}..HEAD`)
- ✅ Next steps: "Clone is now up-to-date with origin. You can continue working or create a PR with /worktree-pr"

Note: This command syncs from **origin (GitHub)**, not from the local main branch.
If you want to sync from local main, push local changes to GitHub first.
```

---

### 3. /worktree-status

#### 현재 구현 분석

**강점**:
- ✅ 기본적인 상태 정보 제공
- ✅ 간결하고 명확

**약점**:
- ❌ Clone 존재 여부 체크 없음
- ❌ 디스크 사용량 표시 없음
- ❌ 의존성 상태 체크 없음
- ❌ 가상환경 활성화 상태 확인 없음
- ❌ 비교 정보 부족 (vs main branch)

#### 개선 제안

**1) 존재 여부 체크**:
```markdown
!test -d clone/$1 || (echo "ERROR: Clone not found" && exit 1)
```

**2) 추가 상태 정보**:
```markdown
# 디스크 사용량
!du -sh clone/$1 2>/dev/null || echo "Size: Unknown"

# 가상환경 존재 확인
!test -d clone/$1/.venv && echo "✓ Virtual environment exists" || echo "⚠️ No virtual environment"

# 의존성 상태
!cd clone/$1 && (test -f uv.lock && echo "✓ Dependencies locked (uv.lock)" || echo "⚠️ No uv.lock found")

# Base branch와의 비교
!cd clone/$1 && git rev-list --left-right --count origin/$(git -C ../.. branch --show-current)...$1
```

**3) Health check**:
```markdown
## HEALTH CHECK

Issues detected:
- [ ] Uncommitted changes: X files
- [ ] Unpushed commits: Y commits
- [ ] Behind origin: Z commits
- [ ] Merge conflicts: None/Present
- [ ] Virtual environment: Present/Missing
- [ ] Dependencies synced: Yes/No
```

#### 개선된 전체 명령어

```markdown
---
description: Show detailed status of a specific cloned directory
argument-hint: [branch-name]
allowed-tools: Bash(git:*), Bash(test:*), Bash(du:*), Bash(echo:*)
---

Display comprehensive status information for the specified cloned directory.

Clone to check: $1

## SAFETY CHECK

!test -d clone/$1 || (echo "❌ ERROR: Clone 'clone/$1' not found. Available clones:" && ls -1 clone/ 2>/dev/null && exit 1)

## STATUS INFORMATION

### 1. Basic Information
!echo "📁 Clone: clone/$1"
!echo "💾 Disk usage:"
!du -sh clone/$1 2>/dev/null || echo "  Unknown"
!echo ""

### 2. Git Status
!echo "📊 Git status:"
!cd clone/$1 && git status --short --branch

### 3. Commit History
!echo ""
!echo "📜 Recent commits (last 10):"
!cd clone/$1 && git log --oneline --graph --decorate -10

### 4. Changes Summary
!echo ""
!echo "📝 Changes summary:"
!cd clone/$1 && git diff --stat

### 5. Branch Tracking
!echo ""
!echo "🌿 Branch tracking:"
!cd clone/$1 && git branch -vv

### 6. Comparison with Base Branch
!echo ""
!echo "🔀 Comparison with base branch:"
!cd clone/$1 && {
    BASE_BRANCH=$(git -C ../.. branch --show-current)
    AHEAD_BEHIND=$(git rev-list --left-right --count origin/$BASE_BRANCH...$1 2>/dev/null || echo "0 0")
    BEHIND=$(echo $AHEAD_BEHIND | cut -d' ' -f1)
    AHEAD=$(echo $AHEAD_BEHIND | cut -d' ' -f2)
    echo "  Behind origin/$BASE_BRANCH: $BEHIND commits"
    echo "  Ahead of origin/$BASE_BRANCH: $AHEAD commits"
}

### 7. Python Environment Status
!echo ""
!echo "🐍 Python environment:"
!cd clone/$1 && {
    if test -d .venv; then
        echo "  ✓ Virtual environment exists"
        if test -f uv.lock; then
            echo "  ✓ Dependencies locked (uv.lock)"
        else
            echo "  ⚠️ No uv.lock found"
        fi
    else
        echo "  ⚠️ No virtual environment (.venv not found)"
    fi
}

## HEALTH CHECK SUMMARY

!cd clone/$1 && {
    echo ""
    echo "🏥 Health Check:"

    # Uncommitted changes
    if ! git diff-index --quiet HEAD 2>/dev/null; then
        CHANGES=$(git status --short | wc -l)
        echo "  ⚠️ Uncommitted changes: $CHANGES files"
    else
        echo "  ✓ No uncommitted changes"
    fi

    # Unpushed commits
    UNPUSHED=$(git log @{u}.. --oneline 2>/dev/null | wc -l || echo "0")
    if [ "$UNPUSHED" -gt 0 ]; then
        echo "  ⚠️ Unpushed commits: $UNPUSHED"
    else
        echo "  ✓ All commits pushed"
    fi

    # Merge conflicts
    if git ls-files -u | grep -q .; then
        echo "  ❌ Merge conflicts present"
    else
        echo "  ✓ No merge conflicts"
    fi

    # Virtual environment
    if test -d .venv; then
        echo "  ✓ Virtual environment present"
    else
        echo "  ⚠️ Virtual environment missing"
    fi
}

!echo ""
!echo "✅ Status check complete!"

Provide a comprehensive summary including:
- ✅ Current branch and tracking information
- ✅ Number of commits ahead/behind origin branch
- ✅ Modified, staged, and untracked files count
- ✅ Disk space used
- ✅ Virtual environment status
- ✅ Dependencies status (uv.lock presence)
- ✅ Overall clone health (Green/Yellow/Red)
- ✅ Recommended actions if any issues detected
- ✅ Next steps based on status
```

---

### 4. /worktree-pr

#### 현재 구현 분석

**강점**:
- ✅ 간단한 PR 생성 흐름
- ✅ `gh pr create --fill` 사용 (자동 채우기)

**약점**:
- ❌ Clone 존재 여부 체크 없음
- ❌ Uncommitted changes 체크 없음
- ❌ PR 생성 전 status 확인 부족
- ❌ Draft PR 옵션 없음
- ❌ Reviewer 자동 지정 없음
- ❌ PR 생성 실패 시 롤백 없음

#### 개선 제안

**1) 안전성 체크**:
```markdown
## SAFETY CHECKS

1. Clone exists:
!test -d clone/$1 || (echo "ERROR: Clone not found" && exit 1)

2. No uncommitted changes:
!cd clone/$1 && git diff-index --quiet HEAD || (echo "ERROR: Uncommitted changes detected" && exit 1)

3. Commits to push:
!cd clone/$1 && test $(git log @{u}.. --oneline | wc -l) -gt 0 || (echo "ERROR: No new commits to push" && exit 1)
```

**2) PR 옵션 추가**:
```markdown
## PR CREATION OPTIONS

# Ask user for PR type
Choose PR type:
1. Standard PR (ready for review)
2. Draft PR (work in progress)
3. Auto-merge PR (after CI passes)

Based on selection:
- Standard: gh pr create --fill
- Draft: gh pr create --fill --draft
- Auto-merge: gh pr create --fill && gh pr merge --auto --squash
```

**3) Reviewer 자동 지정**:
```markdown
# Auto-assign reviewers from .github/CODEOWNERS or team config
!gh pr create --fill --reviewer @team/reviewers
```

**4) PR Template 적용**:
```markdown
# If .github/pull_request_template.md exists, use it
!cd clone/$1 && gh pr create --body-file .github/pull_request_template.md --title "feat: $1"
```

#### 개선된 전체 명령어

```markdown
---
description: Create a pull request from a cloned directory branch
argument-hint: [branch-name]
allowed-tools: Bash(git:*), Bash(gh:*), Bash(test:*), Bash(echo:*)
---

Create a pull request for the specified cloned directory branch.

Branch to create PR for: $1

## SAFETY CHECKS

1. Check if clone exists:
!test -d clone/$1 || (echo "❌ ERROR: Clone 'clone/$1' not found. Create it first with /worktree-create" && exit 1)

2. Check for uncommitted changes:
!cd clone/$1 && {
    if ! git diff-index --quiet HEAD; then
        echo "❌ ERROR: Clone has uncommitted changes. Commit or stash them first:"
        git status --short
        exit 1
    else
        echo "✓ No uncommitted changes"
    fi
}

3. Check if there are commits to push:
!cd clone/$1 && {
    UNPUSHED=$(git log @{u}.. --oneline 2>/dev/null | wc -l || echo "0")
    if [ "$UNPUSHED" -eq 0 ]; then
        echo "❌ ERROR: No new commits to push. Make some commits first."
        exit 1
    else
        echo "✓ Found $UNPUSHED unpushed commit(s)"
    fi
}

4. Check if gh CLI is authenticated:
!gh auth status || (echo "❌ ERROR: gh CLI not authenticated. Run 'gh auth login' first." && exit 1)

## PR PREVIEW

!echo "📊 PR Preview:"
!cd clone/$1 && {
    echo ""
    echo "Commits to include:"
    git log @{u}..HEAD --oneline
    echo ""
    echo "Files changed:"
    git diff @{u}..HEAD --stat
}

## PR CREATION

!echo ""
!echo "🚀 Step 1/3: Pushing branch to origin..."
!cd clone/$1 && git push -u origin $1 || (echo "❌ Push failed" && exit 1)

!echo "📝 Step 2/3: Creating pull request..."
!cd clone/$1 && {
    # Check if PR template exists
    if test -f .github/pull_request_template.md; then
        echo "  ℹ️ Using PR template from .github/pull_request_template.md"
        gh pr create --fill --template .github/pull_request_template.md
    else
        echo "  ℹ️ Using auto-generated PR content"
        gh pr create --fill
    fi
}

!echo "✅ Step 3/3: PR created successfully!"

## PR OPTIONS (Optional post-creation steps)

!cd clone/$1 && {
    PR_URL=$(gh pr view --json url -q .url)
    echo ""
    echo "📎 PR URL: $PR_URL"
    echo ""
    echo "Additional options:"
    echo "  - Mark as draft: gh pr ready --undo"
    echo "  - Request reviewers: gh pr edit --add-reviewer @username"
    echo "  - Enable auto-merge: gh pr merge --auto --squash"
    echo "  - Add labels: gh pr edit --add-label bug,enhancement"
}

Provide a comprehensive summary including:
- ✅ PR title and description (first 3 lines)
- ✅ Number of commits included
- ✅ Files changed summary
- ✅ PR URL (clickable)
- ✅ PR number
- ✅ Base branch (target)
- ✅ Any CI checks status (if available)
- ✅ Suggested next steps:
  - "Review the PR at <URL>"
  - "Request reviews from team members"
  - "Monitor CI/CD pipeline status"
  - "After merge, clean up with /worktree-delete $1"

Note: This pushes to **origin (GitHub)** and creates a PR against the base branch.
Make sure your changes are ready for review before running this command.
```

---

### 5. /worktree-delete

#### 현재 구현 분석

**강점**:
- ✅ 간단한 삭제 흐름
- ✅ 삭제 전후 상태 표시

**약점**:
- ❌ 확인 없이 즉시 삭제 (위험!)
- ❌ Uncommitted changes 경고 없음
- ❌ Unpushed commits 경고 없음
- ❌ 백업 옵션 없음
- ❌ 삭제 실패 시 오류 처리 없음

#### 개선 제안

**1) 안전성 체크 + 확인 프롬프트**:
```markdown
## SAFETY CHECKS

1. Clone exists:
!test -d clone/$1 || (echo "ERROR: Clone not found" && exit 1)

2. Check for uncommitted changes:
!cd clone/$1 && git diff-index --quiet HEAD || echo "WARNING: Uncommitted changes will be lost!"

3. Check for unpushed commits:
!cd clone/$1 && {
    UNPUSHED=$(git log @{u}.. --oneline 2>/dev/null | wc -l || echo "0")
    [ "$UNPUSHED" -gt 0 ] && echo "WARNING: $UNPUSHED unpushed commits will be lost!"
}

## USER CONFIRMATION

**STOP**: Ask user to confirm deletion with warnings about data loss.
```

**2) 백업 옵션**:
```markdown
## BACKUP OPTION (Optional)

Before deleting, offer to create a backup:
!tar -czf clone-$1-backup-$(date +%Y%m%d-%H%M%S).tar.gz clone/$1
!echo "Backup saved to: clone-$1-backup-*.tar.gz"
```

**3) 강제 삭제 플래그**:
```markdown
# Add --force flag to skip confirmation
argument-hint: [branch-name] [--force]

If --force flag not provided, require user confirmation.
```

**4) 삭제 후 정리**:
```markdown
## POST-DELETE CLEANUP

# Also delete remote branch (optional)
!git push origin --delete $1 2>/dev/null || echo "Remote branch already deleted or doesn't exist"

# Clean up local tracking branches
!git fetch --prune
```

#### 개선된 전체 명령어

```markdown
---
description: Delete a cloned directory (with safety checks)
argument-hint: [branch-name] [--force]
allowed-tools: Bash(rm:*), Bash(ls:*), Bash(git:*), Bash(test:*), Bash(du:*), Bash(tar:*)
---

Delete the specified cloned directory with safety checks and optional backup.

Clone directory to delete: $1
Force deletion (skip confirmation): $2 (optional: --force)

## SAFETY CHECKS

1. Check if clone exists:
!test -d clone/$1 || (echo "❌ ERROR: Clone 'clone/$1' not found. Available clones:" && ls -1 clone/ 2>/dev/null && exit 1)

2. Get clone size:
!CLONE_SIZE=$(du -sh clone/$1 2>/dev/null | cut -f1)
!echo "📁 Clone size: $CLONE_SIZE"

3. Check for uncommitted changes:
!cd clone/$1 && {
    if ! git diff-index --quiet HEAD 2>/dev/null; then
        CHANGES=$(git status --short | wc -l)
        echo "⚠️ WARNING: Clone has $CHANGES uncommitted changes that will be lost!"
        git status --short
    else
        echo "✓ No uncommitted changes"
    fi
}

4. Check for unpushed commits:
!cd clone/$1 && {
    UNPUSHED=$(git log @{u}..HEAD --oneline 2>/dev/null | wc -l || echo "0")
    if [ "$UNPUSHED" -gt 0 ]; then
        echo "⚠️ WARNING: Clone has $UNPUSHED unpushed commits that will be lost!"
        git log @{u}..HEAD --oneline
    else
        echo "✓ All commits pushed"
    fi
}

## BACKUP OPTION

!echo ""
!echo "💾 Backup option:"
!echo "Create backup before deleting? (Recommended if there are uncommitted changes)"
!echo "  Backup command: tar -czf clone-$1-backup-\$(date +%Y%m%d-%H%M%S).tar.gz clone/$1"

**STOP HERE if --force flag not provided**:

Ask user to confirm deletion:
- "⚠️ Are you sure you want to delete 'clone/$1'?"
- "This will permanently remove:"
  - All uncommitted changes (X files)
  - All unpushed commits (Y commits)
  - The entire clone directory ($CLONE_SIZE)
- Options:
  1. Yes, delete (no backup)
  2. Yes, delete (create backup first)
  3. No, cancel

## DELETION (Only if confirmed)

Based on user choice:

### Option 1: Delete without backup
!rm -rf clone/$1
!echo "✅ Clone 'clone/$1' deleted (no backup created)"

### Option 2: Delete with backup
!echo "Creating backup..."
!tar -czf clone-$1-backup-$(date +%Y%m%d-%H%M%S).tar.gz clone/$1
!echo "✓ Backup created: clone-$1-backup-*.tar.gz"
!rm -rf clone/$1
!echo "✅ Clone 'clone/$1' deleted (backup saved)"

### Option 3: Cancel
!echo "❌ Deletion cancelled"

## POST-DELETE CLEANUP (Optional)

!echo ""
!echo "🧹 Additional cleanup options:"
!echo "  - Delete remote branch: git push origin --delete $1"
!echo "  - Prune tracking branches: git fetch --prune"

## FINAL STATUS

!echo ""
!echo "📊 Remaining clones:"
!ls -1 clone/ 2>/dev/null || echo "  No clones remaining (clone/ directory empty)"

Provide a comprehensive summary including:
- ✅ Whether deletion was successful
- ✅ Disk space freed ($CLONE_SIZE)
- ✅ Backup file location (if created)
- ✅ List of remaining clones
- ✅ Warnings if data was lost (uncommitted changes, unpushed commits)
- ✅ Suggested cleanup steps:
  - "Delete remote branch with: git push origin --delete $1"
  - "Prune stale tracking branches with: git fetch --prune"

**IMPORTANT**: This is a destructive operation. Deleted data cannot be recovered unless a backup was created.
```

---

## 새로운 명령어 제안

### 1. /worktree-list

**목적**: 모든 클론 디렉토리의 목록 및 상태를 한눈에 확인

```markdown
---
description: List all cloned directories with status overview
allowed-tools: Bash(ls:*), Bash(git:*), Bash(du:*), Bash(test:*)
---

List all cloned directories with comprehensive status information.

## LIST ALL CLONES

!echo "📋 Cloned Directories:"
!echo ""

!for clone in clone/*/; do
    if [ -d "$clone" ]; then
        CLONE_NAME=$(basename "$clone")
        echo "─────────────────────────────────────"
        echo "📁 Clone: $CLONE_NAME"

        # Size
        SIZE=$(du -sh "$clone" 2>/dev/null | cut -f1)
        echo "  💾 Size: $SIZE"

        # Branch
        BRANCH=$(cd "$clone" && git branch --show-current 2>/dev/null)
        echo "  🌿 Branch: $BRANCH"

        # Uncommitted changes
        CHANGES=$(cd "$clone" && git status --short 2>/dev/null | wc -l)
        if [ "$CHANGES" -gt 0 ]; then
            echo "  ⚠️ Uncommitted: $CHANGES files"
        else
            echo "  ✓ Clean working tree"
        fi

        # Unpushed commits
        UNPUSHED=$(cd "$clone" && git log @{u}..HEAD --oneline 2>/dev/null | wc -l || echo "0")
        if [ "$UNPUSHED" -gt 0 ]; then
            echo "  ⚠️ Unpushed: $UNPUSHED commits"
        else
            echo "  ✓ All commits pushed"
        fi

        # Last modified
        LAST_MOD=$(ls -ld "$clone" | awk '{print $6, $7, $8}')
        echo "  🕐 Last modified: $LAST_MOD"

        # Virtual environment
        if [ -d "$clone/.venv" ]; then
            echo "  ✓ Virtual environment present"
        else
            echo "  ⚠️ No virtual environment"
        fi
    fi
done

!echo "─────────────────────────────────────"
!echo ""

## SUMMARY

!TOTAL_CLONES=$(ls -1 clone/ 2>/dev/null | wc -l)
!TOTAL_SIZE=$(du -sh clone/ 2>/dev/null | cut -f1)
!echo "📊 Summary:"
!echo "  Total clones: $TOTAL_CLONES"
!echo "  Total disk usage: $TOTAL_SIZE"

Provide a summary table in markdown format:

| Clone Name | Branch | Size | Status | Uncommitted | Unpushed | Virtual Env |
|------------|--------|------|--------|-------------|----------|-------------|
| feature-a  | feature-a | 120MB | ⚠️ | 5 files | 2 commits | ✓ |
| bugfix-123 | bugfix-123 | 85MB | ✓ | - | - | ✓ |

Include recommendations:
- ✅ Clones ready for PR: [list]
- ⚠️ Clones with uncommitted changes: [list]
- ⚠️ Clones with unpushed commits: [list]
- 🧹 Stale clones (>30 days old): [list]
```

---

### 2. /worktree-cleanup

**목적**: 오래된 또는 병합된 클론 자동 정리

```markdown
---
description: Clean up old or merged cloned directories
argument-hint: [--dry-run] [--age=30] [--merged-only]
allowed-tools: Bash(ls:*), Bash(git:*), Bash(rm:*), Bash(date:*), Bash(find:*)
---

Automatically clean up old or merged cloned directories.

Options:
- --dry-run: Show what would be deleted without actually deleting
- --age=N: Delete clones older than N days (default: 30)
- --merged-only: Only delete clones whose branches are merged into main

## FIND CANDIDATES FOR CLEANUP

!echo "🔍 Finding clones to clean up..."
!echo ""

### 1. Old clones (not modified in last 30 days)
!find clone/ -maxdepth 1 -type d -mtime +30 2>/dev/null

### 2. Merged branches
!for clone in clone/*/; do
    if [ -d "$clone" ]; then
        CLONE_NAME=$(basename "$clone")
        BRANCH=$(cd "$clone" && git branch --show-current 2>/dev/null)

        # Check if branch is merged into main
        IS_MERGED=$(git branch --merged main | grep -c "^\s*$BRANCH\s*$" || echo "0")

        if [ "$IS_MERGED" -gt 0 ]; then
            echo "✓ $CLONE_NAME (branch '$BRANCH' is merged)"
        fi
    fi
done

## CONFIRMATION

**If not --dry-run**: Ask user to confirm cleanup of each clone

## CLEANUP EXECUTION

!echo ""
!echo "🧹 Cleaning up..."

!for clone in <candidates>; do
    echo "Deleting: $clone"
    rm -rf "$clone"
done

!echo ""
!echo "✅ Cleanup complete!"

## SUMMARY

Provide summary:
- Number of clones deleted
- Disk space freed
- Remaining clones
```

---

### 3. /worktree-repair

**목적**: 손상된 클론 복구 또는 재생성

```markdown
---
description: Repair or recreate a corrupted cloned directory
argument-hint: [branch-name]
allowed-tools: Bash(git:*), Bash(rm:*), Bash(mkdir:*), Bash(uv:*)
---

Repair or recreate a corrupted cloned directory.

Clone to repair: $1

## DIAGNOSIS

!echo "🔍 Diagnosing clone '$1'..."

1. Check if clone exists:
!test -d clone/$1 || (echo "ERROR: Clone not found" && exit 1)

2. Check git repository integrity:
!cd clone/$1 && git fsck || echo "⚠️ Git repository corrupted"

3. Check virtual environment:
!test -d clone/$1/.venv || echo "⚠️ Virtual environment missing"

4. Check remote tracking:
!cd clone/$1 && git remote -v || echo "⚠️ Remote not configured"

## REPAIR OPTIONS

Based on diagnosis, offer repair options:

1. **Light repair**: Fix virtual environment and dependencies
   - Recreate .venv
   - Run uv sync

2. **Medium repair**: Reset git state
   - git reset --hard origin/$1
   - Recreate .venv
   - Run uv sync

3. **Full repair**: Delete and recreate from scratch
   - Backup current clone
   - Delete clone
   - Run /worktree-create $1

## EXECUTION

Execute selected repair option

## VERIFICATION

!echo "✅ Repair complete. Verifying..."
!cd clone/$1 && git status
!cd clone/$1 && test -d .venv && echo "✓ Virtual environment OK"
```

---

### 4. /worktree-switch

**목적**: 클론 간 빠른 전환 (VS Code workspace 연동)

```markdown
---
description: Switch to a cloned directory (opens in new VS Code window)
argument-hint: [branch-name]
allowed-tools: Bash(code:*), Bash(test:*)
---

Switch to the specified cloned directory and open in VS Code.

Clone to switch to: $1

## VALIDATION

!test -d clone/$1 || (echo "ERROR: Clone not found" && exit 1)

## SWITCH

!echo "🔀 Switching to clone '$1'..."

# Open in VS Code (or current editor)
!code clone/$1

# Print useful commands
!echo ""
!echo "📂 Clone opened in VS Code"
!echo ""
!echo "Useful commands for this clone:"
!echo "  - Check status: /worktree-status $1"
!echo "  - Sync with main: /worktree-sync $1"
!echo "  - Create PR: /worktree-pr $1"
!echo "  - Delete clone: /worktree-delete $1"
```

---

### 5. /worktree-diff

**목적**: 클론 간 또는 클론-메인 간 차이점 비교

```markdown
---
description: Compare differences between clones or clone and main
argument-hint: [branch-name-1] [branch-name-2|main]
allowed-tools: Bash(git:*)
---

Compare differences between two clones or a clone and main branch.

Branches to compare: $1 and $2

## COMPARISON

!echo "🔍 Comparing '$1' vs '$2'..."

### 1. Commit differences
!if [ "$2" = "main" ] || [ "$2" = "master" ]; then
    # Compare clone with main
    cd clone/$1 && git log --oneline --left-right --graph main...$1
else
    # Compare two clones
    cd clone/$1 && git log --oneline --left-right --graph ../clone/$2/$2...$1
fi

### 2. File differences
!if [ "$2" = "main" ] || [ "$2" = "master" ]; then
    cd clone/$1 && git diff main...$1 --stat
else
    cd clone/$1 && git diff ../clone/$2/$2...$1 --stat
fi

### 3. Show detailed diff (optional)
!echo "Show detailed diff? (y/n)"
# If yes:
!cd clone/$1 && git diff main...$1

## SUMMARY

Provide summary:
- Commits unique to $1: X
- Commits unique to $2: Y
- Files changed: Z
- Lines added: +A
- Lines removed: -B
```

---

## 완전한 워크플로우 예시

### Workflow 1: 기본 기능 개발 (Feature Development)

```bash
# 1. 새 기능 브랜치 클론 생성
/worktree-create feature-user-auth

# 출력:
# ✅ Clone creation complete!
# 📁 Clone: clone/feature-user-auth/
# 🌿 Branch: feature-user-auth
# 🐍 Virtual environment: ✓ Created
# 📚 Dependencies: ✓ Installed (uv sync)
# 💾 Disk usage: 120 MB

# 2. 작업 중 상태 확인
/worktree-status feature-user-auth

# 출력:
# 📊 Git status: 5 files modified
# 🏥 Health Check:
#   ⚠️ Uncommitted changes: 5 files
#   ✓ No merge conflicts
#   ✓ Virtual environment present

# 3. Main 브랜치 최신 변경사항 가져오기
/worktree-sync feature-user-auth

# 출력:
# ✅ Merge successful
# 📈 3 commits merged
# 📝 Files changed: 12 files, +245 insertions, -87 deletions

# 4. 모든 클론 상태 확인
/worktree-list

# 출력:
# 📋 Cloned Directories:
# ─────────────────────────────────────
# 📁 Clone: feature-user-auth
#   💾 Size: 125MB
#   🌿 Branch: feature-user-auth
#   ⚠️ Uncommitted: 5 files
#   ✓ All commits pushed
# ─────────────────────────────────────
# 📊 Summary: 1 clone, 125MB total

# 5. 변경사항 커밋 및 PR 생성
cd clone/feature-user-auth
git add .
git commit -m "feat: Add user authentication"
cd ../..

/worktree-pr feature-user-auth

# 출력:
# ✅ PR created successfully!
# 📎 PR URL: https://github.com/user/repo/pull/42
# 📊 Summary: 2 commits, 15 files changed

# 6. PR 병합 후 정리
/worktree-delete feature-user-auth

# 출력:
# ⚠️ Are you sure? This will delete 125MB
# ✅ Clone deleted
# 💾 Disk space freed: 125MB
```

---

### Workflow 2: 긴급 버그 수정 (Hotfix)

```bash
# 1. 빠르게 hotfix 클론 생성
/worktree-create hotfix-critical-bug

# 2. 수정 작업
cd clone/hotfix-critical-bug
# ... 버그 수정 ...
git add .
git commit -m "fix: Critical security vulnerability"
cd ../..

# 3. 즉시 PR 생성 및 병합
/worktree-pr hotfix-critical-bug

# 4. PR 병합 후 즉시 정리
/worktree-delete hotfix-critical-bug --force
```

---

### Workflow 3: 여러 기능 동시 개발 (Parallel Development)

```bash
# 1. 여러 기능 동시 시작
/worktree-create feature-payment
/worktree-create feature-notifications
/worktree-create feature-dashboard

# 2. 모든 클론 상태 확인
/worktree-list

# 출력:
# 📋 Cloned Directories:
# ─────────────────────────────────────
# 📁 Clone: feature-payment
#   💾 Size: 130MB
#   ⚠️ Uncommitted: 8 files, Unpushed: 3 commits
# ─────────────────────────────────────
# 📁 Clone: feature-notifications
#   💾 Size: 115MB
#   ✓ Clean, All pushed
# ─────────────────────────────────────
# 📁 Clone: feature-dashboard
#   💾 Size: 140MB
#   ⚠️ Uncommitted: 2 files
# ─────────────────────────────────────
# 📊 Summary: 3 clones, 385MB total
#
# 🧹 Recommendations:
#   - Ready for PR: feature-notifications
#   - Need commits: feature-payment, feature-dashboard

# 3. 완료된 기능부터 PR 생성
/worktree-pr feature-notifications

# 4. 나머지 작업 계속
cd clone/feature-payment
# ... 작업 ...

# 5. 주기적으로 메인 동기화
/worktree-sync feature-payment
/worktree-sync feature-dashboard

# 6. 모두 완료 후 정리
/worktree-cleanup --merged-only

# 출력:
# 🔍 Finding merged branches...
# ✓ feature-notifications (merged 3 days ago)
#
# Delete merged clones? (y/n): y
# ✅ Cleaned up 1 clone, freed 115MB
```

---

### Workflow 4: 실험적 기능 개발 (Experimental Features)

```bash
# 1. 실험용 클론 생성
/worktree-create experiment-new-architecture

# 2. 대대적인 리팩토링 작업
cd clone/experiment-new-architecture
# ... 실험적 변경 ...

# 3. 원본과 비교
/worktree-diff experiment-new-architecture main

# 출력:
# 🔍 Comparing 'experiment-new-architecture' vs 'main'...
# Commits unique to experiment: 15
# Files changed: 42
# Lines added: +2,345
# Lines removed: -1,876

# 4. 실험 실패 시 바로 삭제
/worktree-delete experiment-new-architecture --force

# 또는 성공 시 PR 생성
/worktree-pr experiment-new-architecture
```

---

### Workflow 5: 오래된 클론 관리 (Maintenance)

```bash
# 1. 모든 클론 리스트 확인
/worktree-list

# 출력:
# 📋 Cloned Directories:
# 📁 feature-old (Last modified: 45 days ago)
# 📁 feature-stale (Last modified: 60 days ago)
# 📁 feature-current (Last modified: 2 days ago)
#
# 🧹 Stale clones (>30 days old): 2

# 2. Dry-run으로 삭제 대상 확인
/worktree-cleanup --dry-run --age=30

# 출력:
# 🔍 Would delete:
#   - feature-old (45 days old, 130MB)
#   - feature-stale (60 days old, 95MB)
# Total space to free: 225MB

# 3. 실제 정리 실행
/worktree-cleanup --age=30

# 출력:
# ✅ Deleted 2 clones, freed 225MB
```

---

### Workflow 6: 클론 손상 복구 (Recovery)

```bash
# 1. 클론 상태 확인 시 문제 발견
/worktree-status feature-broken

# 출력:
# ❌ Git repository corrupted
# ⚠️ Virtual environment missing

# 2. 복구 시도
/worktree-repair feature-broken

# 출력:
# 🔍 Diagnosing clone 'feature-broken'...
# ⚠️ Git repository corrupted
# ⚠️ Virtual environment missing
#
# Repair options:
# 1. Light repair (recreate .venv)
# 2. Medium repair (reset git state)
# 3. Full repair (recreate from scratch)
#
# Choose option: 3
#
# 🔧 Creating backup...
# ✓ Backup saved: clone-feature-broken-backup-20250129.tar.gz
# 🔧 Recreating clone...
# ✅ Repair complete!

# 3. 검증
/worktree-status feature-broken

# 출력:
# ✓ All systems healthy
```

---

## 구현 로드맵

### Phase 1: 안전성 개선 (Priority: High)
**타임라인**: 1-2 weeks

**Task 1.1**: /worktree-create 개선
- [ ] 중복 생성 방지 체크
- [ ] 진행 상황 표시
- [ ] 실패 시 자동 롤백
- [ ] 테스트: 다양한 실패 시나리오

**Task 1.2**: /worktree-delete 개선
- [ ] 안전성 체크 (uncommitted, unpushed)
- [ ] 사용자 확인 프롬프트
- [ ] 백업 옵션
- [ ] --force 플래그 추가
- [ ] 테스트: 데이터 손실 방지 확인

**Task 1.3**: /worktree-sync 개선
- [ ] Clone 존재 여부 체크
- [ ] Uncommitted changes 체크
- [ ] Dry-run 모드
- [ ] Conflict 자동 해결 옵션
- [ ] 테스트: 다양한 충돌 시나리오

---

### Phase 2: 기능 강화 (Priority: Medium)
**타임라인**: 2-3 weeks

**Task 2.1**: /worktree-status 개선
- [ ] 디스크 사용량 표시
- [ ] 가상환경 상태 체크
- [ ] 의존성 상태 (uv.lock)
- [ ] Base branch 비교 정보
- [ ] Health check 요약
- [ ] 테스트: 다양한 상태 시나리오

**Task 2.2**: /worktree-pr 개선
- [ ] 안전성 체크 강화
- [ ] Draft PR 옵션
- [ ] PR template 적용
- [ ] Reviewer 자동 지정
- [ ] PR 생성 후 옵션 (auto-merge 등)
- [ ] 테스트: PR 생성 실패 시나리오

---

### Phase 3: 새 명령어 추가 (Priority: Medium-Low)
**타임라인**: 3-4 weeks

**Task 3.1**: /worktree-list 구현
- [ ] 모든 클론 나열
- [ ] 각 클론 상태 요약
- [ ] 테이블 형식 출력
- [ ] 추천 액션 제공
- [ ] 테스트: 다양한 클론 상태

**Task 3.2**: /worktree-cleanup 구현
- [ ] 오래된 클론 찾기
- [ ] 병합된 브랜치 감지
- [ ] Dry-run 모드
- [ ] 배치 삭제
- [ ] 테스트: 안전한 정리 확인

**Task 3.3**: /worktree-repair 구현
- [ ] Git 손상 감지
- [ ] 가상환경 복구
- [ ] 경량/중량/전체 복구 옵션
- [ ] 백업 생성
- [ ] 테스트: 다양한 손상 시나리오

---

### Phase 4: 고급 기능 (Priority: Low)
**타임라인**: 4-6 weeks

**Task 4.1**: /worktree-switch 구현
- [ ] VS Code/Editor 통합
- [ ] 빠른 전환
- [ ] 유용한 명령어 표시

**Task 4.2**: /worktree-diff 구현
- [ ] 클론 간 비교
- [ ] 클론-메인 비교
- [ ] 상세 diff 옵션

**Task 4.3**: 성능 최적화
- [ ] 대용량 프로젝트 복사 속도 개선
- [ ] 병렬 복사 (선택적)
- [ ] 증분 동기화

**Task 4.4**: 크로스 플랫폼 개선
- [ ] Windows 긴 경로 지원
- [ ] macOS 특화 최적화
- [ ] Linux 특화 최적화

---

### Phase 5: 문서화 및 통합 (Priority: Medium)
**타임라인**: Ongoing

**Task 5.1**: 문서 작성
- [ ] 전체 사용 가이드
- [ ] 워크플로우 예시
- [ ] 문제 해결 가이드
- [ ] FAQ

**Task 5.2**: CI/CD 통합
- [ ] GitHub Actions 워크플로우
- [ ] 자동 정리 스크립트
- [ ] PR 생성 자동화

**Task 5.3**: 모니터링 및 분석
- [ ] 클론 사용 통계
- [ ] 디스크 사용량 추적
- [ ] 자동 알림 (오래된 클론 등)

---

## 결론 및 추천사항

### 핵심 강점 유지
1. ✅ **Copy-based 아키텍처**: Python 프로젝트에 최적화됨
2. ✅ **자동화된 환경 설정**: uv venv + uv sync 자동 실행
3. ✅ **완전한 격리**: 각 클론이 독립적인 가상환경 보유

### 주요 개선 영역
1. ⚠️ **안전성**: 데이터 손실 방지, 확인 프롬프트, 백업 옵션
2. ⚠️ **사용성**: 진행 상황 표시, 명확한 오류 메시지, 추천 액션
3. ⚠️ **관리**: list, cleanup, repair 명령어로 전체 생애주기 관리

### 우선순위 권장사항
**즉시 구현 (Week 1-2)**:
- /worktree-delete 안전성 체크 (데이터 손실 방지)
- /worktree-create 중복 생성 방지
- /worktree-list 기본 구현

**단기 목표 (Week 3-4)**:
- /worktree-status 개선 (health check)
- /worktree-sync 충돌 해결 개선
- /worktree-pr 안전성 체크

**중기 목표 (Week 5-8)**:
- /worktree-cleanup 구현
- /worktree-repair 구현
- 성능 최적화

### 최종 비전
현재 worktree 시스템을 "단순 복사 도구"에서 **"완전한 병렬 개발 환경 관리 시스템"**으로 진화시키는 것이 목표입니다. 이를 통해:

- 🚀 여러 기능을 동시에 개발
- 🔒 안전한 실험 및 롤백
- 🧹 자동화된 정리 및 관리
- 📊 전체 개발 상태 한눈에 파악

이 시스템은 Python 프로젝트에서 **Git worktree의 강력한 대안**이 될 것입니다.
