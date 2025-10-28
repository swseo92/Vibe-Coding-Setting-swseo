# Worktree Commands: 구현 예시

이 문서는 개선된 worktree 명령어의 실제 구현 예시를 제공합니다.

---

## 1. 개선된 /worktree-create 구현

### 파일: `.claude/commands/worktree-create-v2.md`

```markdown
---
description: Create a new cloned directory with full working environment (Enhanced v2)
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

## WORKTREE CREATION (With progress tracking)

Execute the following commands with progress indicators:

!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
!echo "📦 Starting clone creation for branch: $1"
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

!echo ""
!echo "[1/5] 📁 Creating clone directory structure..."
!mkdir -p clone || (echo "❌ Failed to create clone directory" && exit 1)
!echo "      ✓ Directory structure created"

!echo ""
!echo "[2/5] 📋 Copying project files (excluding .venv, node_modules, etc.)..."
!python3 -c "
import shutil
import os
import sys

try:
    print('      Analyzing files to copy...')
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
    print('      ✓ Files copied successfully')
except FileExistsError:
    print('      ❌ Error: Clone directory already exists', file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f'      ❌ Copy failed: {e}', file=sys.stderr)
    sys.exit(1)
" || (echo "" && echo "❌ Copy failed. Cleaning up..." && rm -rf clone/$1 && exit 1)

!echo ""
!echo "[3/5] 🌿 Creating new branch '$1'..."
!cd clone/$1 && git checkout -b $1 || (echo "      ❌ Branch creation failed" && cd ../.. && rm -rf clone/$1 && exit 1)
!echo "      ✓ Branch created and checked out"

!echo ""
!echo "[4/5] 🐍 Setting up Python virtual environment..."
!cd clone/$1 && uv venv && echo "      ✓ Virtual environment created" || echo "      ⚠️ Virtual environment creation skipped (uv not available)"

!echo ""
!echo "[5/5] 📚 Installing project dependencies..."
!cd clone/$1 && {
    if uv sync 2>/dev/null; then
        echo "      ✓ Dependencies installed via uv sync"
    else
        echo "      ℹ️ No pyproject.toml found, skipping uv sync"
    fi

    if uv pip install -e . 2>/dev/null; then
        echo "      ✓ Project installed in editable mode"
    else
        echo "      ℹ️ No editable install available"
    fi
}

!echo ""
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
!echo "✅ Clone creation complete!"
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

!echo ""
!echo "📊 Clone Status:"
!cd clone/$1 && git status --short && git branch -vv

!echo ""
!echo "💾 Disk Usage:"
!du -sh clone/$1 2>/dev/null || echo "   Size calculation not available"

!echo ""
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
!echo "📍 Next Steps:"
!echo "   1. Start working: cd clone/$1"
!echo "   2. Check status:  /worktree-status $1"
!echo "   3. Sync changes:  /worktree-sync $1"
!echo "   4. Create PR:     /worktree-pr $1"
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

Provide a comprehensive summary including:
- ✅ Branch name: $1
- ✅ Clone directory: clone/$1/
- ✅ What was copied: All project files except build artifacts
- ✅ Uncommitted changes: Included in clone
- ✅ Untracked files: Included in clone
- ✅ Virtual environment: Created/Skipped (with reason)
- ✅ Dependencies: Installed/Skipped (with reason)
- ✅ Editable install: Success/Skipped (with reason)
- ✅ Disk usage: Approximate size
- ✅ Git status: Branch created, tracking origin/$1
- ✅ Next steps: Clear action items listed above
```

---

## 2. 신규 /worktree-list 구현

### 파일: `.claude/commands/worktree-list.md`

```markdown
---
description: List all cloned directories with comprehensive status overview
allowed-tools: Bash(ls:*), Bash(git:*), Bash(du:*), Bash(test:*), Bash(find:*), Bash(date:*)
---

List all cloned directories with detailed status information.

## CHECK IF CLONES EXIST

!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
!echo "📋 Cloned Directories Status"
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

!if [ ! -d clone ] || [ -z "$(ls -A clone 2>/dev/null)" ]; then
    echo ""
    echo "ℹ️  No clones found"
    echo ""
    echo "Create a clone with: /worktree-create <branch-name>"
    exit 0
fi

## LIST ALL CLONES

!echo ""
!for clone_dir in clone/*/; do
    if [ -d "$clone_dir" ]; then
        CLONE_NAME=$(basename "$clone_dir")

        echo "─────────────────────────────────────"
        echo "📁 Clone: $CLONE_NAME"
        echo ""

        # Size
        SIZE=$(du -sh "$clone_dir" 2>/dev/null | cut -f1)
        echo "   💾 Size: $SIZE"

        # Current branch
        BRANCH=$(cd "$clone_dir" && git branch --show-current 2>/dev/null)
        echo "   🌿 Branch: $BRANCH"

        # Git status
        cd "$clone_dir"

        # Uncommitted changes
        if ! git diff-index --quiet HEAD 2>/dev/null; then
            CHANGES=$(git status --short 2>/dev/null | wc -l)
            echo "   ⚠️  Uncommitted changes: $CHANGES files"
        else
            echo "   ✓  Clean working tree"
        fi

        # Unpushed commits
        UNPUSHED=$(git log @{u}..HEAD --oneline 2>/dev/null | wc -l || echo "0")
        if [ "$UNPUSHED" -gt 0 ]; then
            echo "   ⚠️  Unpushed commits: $UNPUSHED"
        else
            echo "   ✓  All commits pushed"
        fi

        # Behind origin
        BEHIND=$(git rev-list HEAD..@{u} --count 2>/dev/null || echo "0")
        if [ "$BEHIND" -gt 0 ]; then
            echo "   ⚠️  Behind origin: $BEHIND commits"
        fi

        # Virtual environment
        if [ -d ".venv" ]; then
            echo "   ✓  Virtual environment present"
        else
            echo "   ⚠️  No virtual environment"
        fi

        # Dependencies
        if [ -f "uv.lock" ]; then
            echo "   ✓  Dependencies locked (uv.lock)"
        elif [ -f "requirements.txt" ]; then
            echo "   ℹ️  Requirements file present"
        else
            echo "   ⚠️  No dependency lock file"
        fi

        # Last modified (days ago)
        if command -v stat >/dev/null 2>&1; then
            # Get last modification time
            LAST_MOD_EPOCH=$(stat -c %Y "$clone_dir" 2>/dev/null || stat -f %m "$clone_dir" 2>/dev/null || echo "0")
            NOW_EPOCH=$(date +%s)
            DAYS_AGO=$(( ($NOW_EPOCH - $LAST_MOD_EPOCH) / 86400 ))

            if [ "$DAYS_AGO" -gt 30 ]; then
                echo "   ⚠️  Last modified: $DAYS_AGO days ago (stale)"
            elif [ "$DAYS_AGO" -gt 7 ]; then
                echo "   ℹ️  Last modified: $DAYS_AGO days ago"
            else
                echo "   ✓  Recently active ($DAYS_AGO days ago)"
            fi
        fi

        # Overall health
        HEALTH="✅ Healthy"
        if [ "$CHANGES" -gt 0 ] || [ "$UNPUSHED" -gt 0 ]; then
            HEALTH="⚠️  Needs attention"
        fi
        if [ "$DAYS_AGO" -gt 30 ]; then
            HEALTH="🧹 Stale (consider cleanup)"
        fi
        echo ""
        echo "   Status: $HEALTH"

        cd - >/dev/null
    fi
done

!echo "─────────────────────────────────────"

## SUMMARY STATISTICS

!echo ""
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
!echo "📊 Summary Statistics"
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

!TOTAL_CLONES=$(find clone/ -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l)
!TOTAL_SIZE=$(du -sh clone/ 2>/dev/null | cut -f1)
!echo ""
!echo "   Total clones: $TOTAL_CLONES"
!echo "   Total disk usage: $TOTAL_SIZE"

## RECOMMENDATIONS

!echo ""
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
!echo "💡 Recommendations"
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
!echo ""

# Clones with uncommitted changes
!UNCOMMITTED_CLONES=""
!for clone_dir in clone/*/; do
    if [ -d "$clone_dir" ]; then
        cd "$clone_dir"
        if ! git diff-index --quiet HEAD 2>/dev/null; then
            CLONE_NAME=$(basename "$clone_dir")
            UNCOMMITTED_CLONES="$UNCOMMITTED_CLONES $CLONE_NAME"
        fi
        cd - >/dev/null
    fi
done

!if [ -n "$UNCOMMITTED_CLONES" ]; then
    echo "⚠️  Clones with uncommitted changes:"
    for clone in $UNCOMMITTED_CLONES; do
        echo "   - $clone (commit your changes)"
    done
    echo ""
fi

# Clones with unpushed commits
!UNPUSHED_CLONES=""
!for clone_dir in clone/*/; do
    if [ -d "$clone_dir" ]; then
        cd "$clone_dir"
        UNPUSHED=$(git log @{u}..HEAD --oneline 2>/dev/null | wc -l || echo "0")
        if [ "$UNPUSHED" -gt 0 ]; then
            CLONE_NAME=$(basename "$clone_dir")
            UNPUSHED_CLONES="$UNPUSHED_CLONES $CLONE_NAME"
        fi
        cd - >/dev/null
    fi
done

!if [ -n "$UNPUSHED_CLONES" ]; then
    echo "⚠️  Clones with unpushed commits:"
    for clone in $UNPUSHED_CLONES; do
        echo "   - $clone (push or create PR: /worktree-pr $clone)"
    done
    echo ""
fi

# Clean clones (ready for PR or cleanup)
!CLEAN_CLONES=""
!for clone_dir in clone/*/; do
    if [ -d "$clone_dir" ]; then
        cd "$clone_dir"
        UNCOMMITTED=$(git diff-index --quiet HEAD 2>/dev/null && echo "0" || echo "1")
        UNPUSHED=$(git log @{u}..HEAD --oneline 2>/dev/null | wc -l || echo "0")
        if [ "$UNCOMMITTED" -eq 0 ] && [ "$UNPUSHED" -eq 0 ]; then
            CLONE_NAME=$(basename "$clone_dir")
            CLEAN_CLONES="$CLEAN_CLONES $CLONE_NAME"
        fi
        cd - >/dev/null
    fi
done

!if [ -n "$CLEAN_CLONES" ]; then
    echo "✅ Clean clones (all changes pushed):"
    for clone in $CLEAN_CLONES; do
        echo "   - $clone (consider cleanup if PR merged)"
    done
    echo ""
fi

# Stale clones
!STALE_CLONES=$(find clone/ -maxdepth 1 -type d -mtime +30 2>/dev/null | xargs -n 1 basename)
!if [ -n "$STALE_CLONES" ]; then
    echo "🧹 Stale clones (>30 days old):"
    for clone in $STALE_CLONES; do
        if [ "$clone" != "clone" ]; then
            echo "   - $clone (cleanup with: /worktree-delete $clone)"
        fi
    done
    echo ""
fi

!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

Provide a markdown summary table:

| Clone Name | Branch | Size | Uncommitted | Unpushed | Status |
|------------|--------|------|-------------|----------|--------|
| feature-a  | feature-a | 120MB | 5 files | 2 commits | ⚠️ Needs attention |
| bugfix-123 | bugfix-123 | 85MB | - | - | ✅ Healthy |

Include:
- ✅ Total number of clones
- ✅ Total disk usage
- ✅ Clones that need attention
- ✅ Clones ready for PR
- ✅ Stale clones for cleanup
- ✅ Specific action recommendations for each category
```

---

## 3. 신규 /worktree-cleanup 구현

### 파일: `.claude/commands/worktree-cleanup.md`

```markdown
---
description: Clean up old or merged cloned directories
argument-hint: [--dry-run] [--age=30] [--merged-only]
allowed-tools: Bash(ls:*), Bash(git:*), Bash(rm:*), Bash(find:*), Bash(date:*)
---

Automatically clean up old or merged cloned directories.

Options:
- $1: --dry-run (show what would be deleted without deleting)
- $2: --age=N (delete clones older than N days, default: 30)
- $3: --merged-only (only delete clones whose branches are merged)

## PARSE OPTIONS

!DRY_RUN=false
!MAX_AGE=30
!MERGED_ONLY=false

!for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
        --age=*)
            MAX_AGE="${arg#*=}"
            ;;
        --merged-only)
            MERGED_ONLY=true
            ;;
    esac
done

!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
!echo "🧹 Clone Cleanup Utility"
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
!echo ""
!echo "Options:"
!echo "  Dry run: $DRY_RUN"
!echo "  Max age: $MAX_AGE days"
!echo "  Merged only: $MERGED_ONLY"
!echo ""

## FIND CLEANUP CANDIDATES

!echo "🔍 Finding cleanup candidates..."
!echo ""

!CANDIDATES=""
!TOTAL_SIZE=0

!for clone_dir in clone/*/; do
    if [ ! -d "$clone_dir" ]; then
        continue
    fi

    CLONE_NAME=$(basename "$clone_dir")
    SHOULD_DELETE=false
    REASON=""

    cd "$clone_dir"

    # Check age
    if [ "$MAX_AGE" -gt 0 ]; then
        LAST_MOD_EPOCH=$(stat -c %Y . 2>/dev/null || stat -f %m . 2>/dev/null || echo "0")
        NOW_EPOCH=$(date +%s)
        DAYS_AGO=$(( ($NOW_EPOCH - $LAST_MOD_EPOCH) / 86400 ))

        if [ "$DAYS_AGO" -gt "$MAX_AGE" ]; then
            SHOULD_DELETE=true
            REASON="Not modified for $DAYS_AGO days (threshold: $MAX_AGE days)"
        fi
    fi

    # Check if merged (if --merged-only flag)
    if [ "$MERGED_ONLY" = true ]; then
        BRANCH=$(git branch --show-current 2>/dev/null)
        BASE_BRANCH=$(git -C ../.. branch --show-current 2>/dev/null)

        # Check if branch is merged into base branch
        IS_MERGED=$(cd ../.. && git branch --merged $BASE_BRANCH | grep -c "^\s*$BRANCH\s*$" || echo "0")

        if [ "$IS_MERGED" -gt 0 ]; then
            SHOULD_DELETE=true
            REASON="Branch '$BRANCH' is merged into $BASE_BRANCH"
        else
            SHOULD_DELETE=false
        fi
    fi

    # Check for uncommitted changes (safety check)
    if [ "$SHOULD_DELETE" = true ]; then
        if ! git diff-index --quiet HEAD 2>/dev/null; then
            CHANGES=$(git status --short 2>/dev/null | wc -l)
            echo "⚠️  $CLONE_NAME: Has $CHANGES uncommitted changes - SKIPPING"
            SHOULD_DELETE=false
        fi

        # Check for unpushed commits (safety check)
        UNPUSHED=$(git log @{u}..HEAD --oneline 2>/dev/null | wc -l || echo "0")
        if [ "$UNPUSHED" -gt 0 ]; then
            echo "⚠️  $CLONE_NAME: Has $UNPUSHED unpushed commits - SKIPPING"
            SHOULD_DELETE=false
        fi
    fi

    if [ "$SHOULD_DELETE" = true ]; then
        SIZE=$(du -sh . 2>/dev/null | cut -f1)
        echo "✓  $CLONE_NAME ($SIZE) - $REASON"
        CANDIDATES="$CANDIDATES $CLONE_NAME"
        # Note: SIZE is human-readable, can't easily sum
    fi

    cd - >/dev/null
done

!if [ -z "$CANDIDATES" ]; then
    echo ""
    echo "ℹ️  No clones found matching cleanup criteria"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
fi

!echo ""
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

## DRY RUN OR EXECUTE

!if [ "$DRY_RUN" = true ]; then
    echo ""
    echo "🔍 DRY RUN MODE - No files will be deleted"
    echo ""
    echo "Clones that would be deleted:"
    for clone in $CANDIDATES; do
        SIZE=$(du -sh clone/$clone 2>/dev/null | cut -f1)
        echo "   - $clone ($SIZE)"
    done
    echo ""
    echo "To actually delete these clones, run without --dry-run flag"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
fi

## CONFIRMATION

!echo ""
!echo "⚠️  WARNING: This will permanently delete the following clones:"
!for clone in $CANDIDATES; do
    SIZE=$(du -sh clone/$clone 2>/dev/null | cut -f1)
    echo "   - $clone ($SIZE)"
done

**STOP HERE**: Ask user for confirmation:
- "Are you sure you want to delete these clones? (yes/no)"
- If user says anything other than "yes", abort with message: "Cleanup cancelled"

## CLEANUP EXECUTION

!echo ""
!echo "🧹 Deleting clones..."
!echo ""

!DELETED_COUNT=0
!for clone in $CANDIDATES; do
    echo "   Deleting $clone..."
    rm -rf "clone/$clone"
    if [ $? -eq 0 ]; then
        echo "   ✓ Deleted $clone"
        DELETED_COUNT=$((DELETED_COUNT + 1))
    else
        echo "   ❌ Failed to delete $clone"
    fi
done

!echo ""
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
!echo "✅ Cleanup Complete"
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
!echo ""
!echo "   Clones deleted: $DELETED_COUNT"
!echo ""

## REMAINING CLONES

!REMAINING=$(find clone/ -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l)
!if [ "$REMAINING" -gt 0 ]; then
    echo "📋 Remaining clones:"
    ls -1 clone/
else
    echo "ℹ️  No clones remaining"
fi

!echo ""
!echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

Provide summary:
- ✅ Number of clones analyzed
- ✅ Number of candidates found
- ✅ Number deleted (if not dry-run)
- ✅ Clones skipped (with reasons: uncommitted changes, unpushed commits)
- ✅ Total disk space freed (estimate)
- ✅ Remaining clones count
- ✅ Suggestions for remaining clones if any need attention
```

---

## 4. 사용 예시 스크립트

### 예시 1: 안전한 클론 생성 테스트

```bash
#!/bin/bash
# test-worktree-create.sh

echo "Testing /worktree-create improvements..."

# Test 1: 중복 생성 방지
echo "Test 1: Duplicate prevention"
/worktree-create test-branch
sleep 2
/worktree-create test-branch  # Should fail with error

# Test 2: 진행 상황 표시
echo "Test 2: Progress indicators"
/worktree-create test-branch-2  # Should show [1/5], [2/5], etc.

# Test 3: 실패 시 롤백
echo "Test 3: Rollback on failure"
# Simulate failure by corrupting git state
# (manual test required)

echo "All tests completed"
```

### 예시 2: 클론 관리 워크플로우

```bash
#!/bin/bash
# worktree-workflow.sh

echo "=== Worktree Management Workflow ==="

# 1. List all clones
echo "1. Checking all clones..."
/worktree-list

# 2. Sync all clones with main
echo "2. Syncing clones..."
for clone in clone/*/; do
    if [ -d "$clone" ]; then
        clone_name=$(basename "$clone")
        echo "Syncing $clone_name..."
        /worktree-sync "$clone_name"
    fi
done

# 3. Find stale clones
echo "3. Finding stale clones..."
/worktree-cleanup --dry-run --age=30

# 4. Clean up merged branches
echo "4. Cleaning up merged branches..."
/worktree-cleanup --merged-only --dry-run

echo "=== Workflow Complete ==="
```

### 예시 3: Python 스크립트로 클론 통계

```python
#!/usr/bin/env python3
# worktree-stats.py

import os
import subprocess
from pathlib import Path
from datetime import datetime, timedelta

def get_clone_stats():
    """Get statistics for all worktree clones."""
    clone_dir = Path("clone")

    if not clone_dir.exists():
        print("No clone directory found")
        return

    clones = [d for d in clone_dir.iterdir() if d.is_dir()]

    stats = {
        "total": len(clones),
        "with_uncommitted": 0,
        "with_unpushed": 0,
        "stale": 0,
        "healthy": 0
    }

    for clone in clones:
        os.chdir(clone)

        # Check uncommitted changes
        result = subprocess.run(
            ["git", "diff-index", "--quiet", "HEAD"],
            capture_output=True
        )
        if result.returncode != 0:
            stats["with_uncommitted"] += 1

        # Check unpushed commits
        result = subprocess.run(
            ["git", "log", "@{u}..HEAD", "--oneline"],
            capture_output=True,
            text=True
        )
        if result.stdout.strip():
            stats["with_unpushed"] += 1

        # Check if stale (>30 days)
        mod_time = datetime.fromtimestamp(clone.stat().st_mtime)
        if datetime.now() - mod_time > timedelta(days=30):
            stats["stale"] += 1

        # Healthy = no uncommitted, no unpushed, not stale
        if (result.returncode == 0 and
            not result.stdout.strip() and
            datetime.now() - mod_time <= timedelta(days=30)):
            stats["healthy"] += 1

        os.chdir("../..")

    print("=== Worktree Clone Statistics ===")
    print(f"Total clones: {stats['total']}")
    print(f"Healthy: {stats['healthy']}")
    print(f"With uncommitted changes: {stats['with_uncommitted']}")
    print(f"With unpushed commits: {stats['with_unpushed']}")
    print(f"Stale (>30 days): {stats['stale']}")

    # Recommendations
    if stats['with_uncommitted'] > 0:
        print("\n⚠️ Commit changes in affected clones")
    if stats['with_unpushed'] > 0:
        print("⚠️ Push commits or create PRs")
    if stats['stale'] > 0:
        print("🧹 Consider cleaning up stale clones")

if __name__ == "__main__":
    get_clone_stats()
```

---

## 5. 테스트 체크리스트

### /worktree-create 테스트

- [ ] 중복 생성 시도 → 오류 메시지 확인
- [ ] Remote 없는 상태 → 오류 메시지 확인
- [ ] 잘못된 브랜치에서 생성 → 오류 메시지 확인
- [ ] 커밋 없는 상태 → 오류 메시지 확인
- [ ] 정상 생성 → 진행 상황 표시 확인
- [ ] 가상환경 생성 확인
- [ ] 의존성 설치 확인
- [ ] 디스크 사용량 표시 확인

### /worktree-delete 테스트

- [ ] Uncommitted changes 경고 표시
- [ ] Unpushed commits 경고 표시
- [ ] 사용자 확인 프롬프트
- [ ] 백업 옵션 제공
- [ ] --force 플래그 테스트
- [ ] 삭제 후 확인

### /worktree-list 테스트

- [ ] 클론 없을 때 메시지
- [ ] 단일 클론 표시
- [ ] 다중 클론 표시
- [ ] 상태 정보 정확성 (uncommitted, unpushed)
- [ ] 추천 액션 표시
- [ ] 통계 요약

### /worktree-cleanup 테스트

- [ ] --dry-run 모드 (삭제 안 됨)
- [ ] --age 옵션
- [ ] --merged-only 옵션
- [ ] 안전성 체크 (uncommitted, unpushed 스킵)
- [ ] 사용자 확인 프롬프트
- [ ] 실제 삭제 확인

---

## 6. 배포 계획

### Phase 1: 안전성 개선 (즉시)
1. /worktree-create-v2.md 작성
2. /worktree-delete-v2.md 작성
3. 기존 명령어 백업
4. 새 명령어로 교체
5. 테스트

### Phase 2: 신규 명령어 (1-2주)
1. /worktree-list.md 작성
2. 테스트 및 피드백
3. /worktree-cleanup.md 작성
4. 테스트 및 피드백

### Phase 3: 문서화 (진행 중)
1. Quick reference 업데이트
2. 워크플로우 예시 추가
3. 문제 해결 가이드 작성
4. CLAUDE.md 업데이트

---

## 7. 피드백 및 개선

### 수집할 피드백
- 사용자가 가장 많이 사용하는 명령어
- 불편한 점
- 추가 요청 기능
- 성능 이슈

### 개선 우선순위
1. 데이터 손실 방지 (최우선)
2. 사용자 경험 개선
3. 성능 최적화
4. 고급 기능 추가

---

이 문서는 실제 구현을 위한 구체적인 가이드를 제공합니다. 각 명령어는 점진적으로 개선하고 테스트할 수 있습니다.
