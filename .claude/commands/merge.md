---
name: merge
description: Merge a branch with automatic conflict resolution
tags: [project]
---

# Git Branch Merge with Conflict Resolution

사용자가 지정한 브랜치를 대상 브랜치에 merge하고, conflict 발생 시 자동으로 해결합니다.

## Usage

```bash
/merge <source-branch> [--into <target-branch>]
/merge <source-branch>  # 현재 브랜치에 merge
```

**Examples:**
- `/merge feature-auth --into main` - feature-auth를 main에 merge
- `/merge develop` - develop을 현재 브랜치에 merge
- `/merge hotfix/bug-123 --into master` - hotfix를 master에 merge

## Workflow

### 1. 입력 파싱 및 검증

사용자 입력에서 소스 브랜치와 타겟 브랜치를 추출합니다.

```bash
# 입력 예시: "/merge feature-auth --into main"
SOURCE_BRANCH="feature-auth"
TARGET_BRANCH="main"

# --into가 없으면 현재 브랜치가 타겟
# 입력 예시: "/merge develop"
SOURCE_BRANCH="develop"
TARGET_BRANCH=$(git branch --show-current)
```

### 2. Safety Checks

Merge 전에 안전성 검사를 수행합니다:

```bash
# 1. Working tree가 clean한지 확인
git status --porcelain

# 만약 uncommitted changes가 있으면:
# - 사용자에게 경고
# - AskUserQuestion: "변경사항을 stash하고 계속하시겠습니까?"
#   옵션: "Stash and continue", "Commit first", "Cancel"

# 2. 소스 브랜치 존재 확인
git rev-parse --verify $SOURCE_BRANCH

# 3. 타겟 브랜치 존재 확인
git rev-parse --verify $TARGET_BRANCH

# 4. 리모트와 동기화 상태 확인 (선택사항)
# AskUserQuestion: "리모트에서 최신 상태를 가져오시겠습니까?"
#   옵션: "Yes, fetch first", "No, use local only"
```

### 3. Merge 준비

```bash
# 타겟 브랜치로 체크아웃
git checkout $TARGET_BRANCH

# (선택) 리모트에서 fetch
git fetch origin $SOURCE_BRANCH
git fetch origin $TARGET_BRANCH

# Merge 전 상태 확인
echo "Merging: $SOURCE_BRANCH → $TARGET_BRANCH"
echo ""
echo "Target branch commits:"
git log --oneline -5 $TARGET_BRANCH

echo ""
echo "Source branch commits (not in target):"
git log --oneline $TARGET_BRANCH..$SOURCE_BRANCH
```

### 4. Merge 시도

```bash
# Merge 실행 (--no-commit으로 일단 시도)
git merge --no-commit --no-ff $SOURCE_BRANCH

# 결과 확인
if [ $? -eq 0 ]; then
    # Conflict 없음
    echo "✓ Merge successful, no conflicts"
    # → Step 6으로 이동
else
    # Conflict 발생
    echo "⚠ Merge conflicts detected"
    # → Step 5로 이동
fi
```

### 5. Conflict 해결

Conflict가 발생한 경우:

```bash
# Conflict 파일 목록 확인
git diff --name-only --diff-filter=U

# 각 conflict 파일 처리
for file in $(git diff --name-only --diff-filter=U); do
    echo "Resolving conflict in: $file"

    # Read 도구로 파일 읽기
    # Conflict 마커 분석:
    # <<<<<<< HEAD
    # (current branch changes)
    # =======
    # (incoming branch changes)
    # >>>>>>> source-branch
done
```

**Conflict 해결 전략:**

1. **자동 해결 가능한 경우:**
   - 한쪽이 삭제, 다른 쪽이 수정 → 수정 버전 선택
   - 단순 텍스트 추가 (비중복) → 둘 다 유지
   - Import 문 충돌 → 알파벳 순으로 정렬
   - 버전 번호 충돌 → 더 높은 버전 선택

2. **사용자 확인 필요한 경우:**
   - 같은 함수의 다른 로직 변경
   - 비즈니스 로직 충돌
   - 설정값 충돌

```bash
# 자동 해결 후 staging
git add $file

# 사용자 확인 필요한 경우
# AskUserQuestion으로 선택지 제공:
# - "Keep current (HEAD) version"
# - "Keep incoming (source-branch) version"
# - "Keep both (manual merge)"
# - "Show me the diff first"
```

**Conflict 해결 후:**

```bash
# 모든 conflict 해결 확인
git diff --check

# Staging 상태 확인
git status
```

### 6. Merge 완료

```bash
# Merge commit 생성
git commit -m "$(cat <<'EOF'
Merge branch '$SOURCE_BRANCH' into $TARGET_BRANCH

Merged changes from $SOURCE_BRANCH:
$(git log --oneline $TARGET_BRANCH..$SOURCE_BRANCH | head -5)

$(if conflicts_resolved; then
echo "Conflicts resolved in:"
git diff --name-only --diff-filter=U | while read file; do
  echo "  - $file"
done
fi)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

echo "✓ Merge completed successfully"
```

### 7. Post-Merge 검증 (선택)

```bash
# AskUserQuestion: "다음 작업을 수행하시겠습니까?"
# multiSelect: true
# 옵션:
# - "Run tests" (pytest, npm test 등)
# - "Run linter" (ruff, eslint 등)
# - "Build project"
# - "Push to remote"

# 선택된 작업 수행
if [[ "$RUN_TESTS" == "true" ]]; then
    # 프로젝트 타입 감지하여 테스트 실행
    if [ -f "pyproject.toml" ]; then
        uv run pytest
    elif [ -f "package.json" ]; then
        npm test
    fi
fi

if [[ "$PUSH_REMOTE" == "true" ]]; then
    git push origin $TARGET_BRANCH
fi
```

### 8. 결과 요약

```markdown
## ✅ Merge Completed

**Source Branch:** $SOURCE_BRANCH
**Target Branch:** $TARGET_BRANCH

### Changes Merged:
- X commits from $SOURCE_BRANCH
- Y files changed
- Z conflicts resolved (if any)

### Modified Files:
$(git diff --name-only HEAD~1 HEAD)

### Next Steps:
1. Review the merged changes: `git log -p -1`
2. Test the application
3. Push to remote: `git push origin $TARGET_BRANCH`
```

## Error Handling

### 브랜치가 존재하지 않음
```
Error: Branch '$SOURCE_BRANCH' does not exist

Available branches:
$(git branch -a)

Please check the branch name and try again.
```

### Working tree가 clean하지 않음
```
Error: You have uncommitted changes

Modified files:
$(git status --short)

Please commit or stash your changes before merging:
- Commit: git add . && git commit -m "message"
- Stash: git stash
- Or use AskUserQuestion to let me handle it
```

### Merge 충돌 해결 실패
```
Error: Unable to automatically resolve conflicts

The following files have complex conflicts:
$(git diff --name-only --diff-filter=U)

I've analyzed the conflicts but need your input to resolve them properly.
Would you like to:
1. Abort the merge (git merge --abort)
2. Review conflicts manually
3. Let me show you each conflict for guidance
```

## Implementation Notes

**IMPORTANT:**
1. ALWAYS use TodoWrite to track merge progress
2. ALWAYS check git status before and after operations
3. NEVER force operations without user confirmation
4. ALWAYS provide clear conflict analysis with context
5. Use AskUserQuestion for critical decisions
6. Keep detailed logs of what was changed

**Todo List Structure:**
```
1. Parse and validate input
2. Check working tree status
3. Checkout target branch
4. Attempt merge
5. Resolve conflicts (if any)
6. Complete merge commit
7. Run post-merge checks (if requested)
8. Display summary
```

**Conflict Resolution Priority:**
1. Try automatic resolution based on patterns
2. If uncertain, explain both sides to user
3. Use AskUserQuestion for user decision
4. Document resolution reasoning in commit message

## Platform Support

- ✅ Windows (Git Bash, PowerShell)
- ✅ macOS (zsh, bash)
- ✅ Linux (bash)
- ✅ WSL

## Related Commands

- `/resolve-conflicts` - Conflict만 해결 (merge는 이미 진행 중)
- `/rebase` - Rebase 작업 (향후 구현)
- `/cherry-pick` - 특정 커밋만 가져오기 (향후 구현)

## Examples

### Example 1: Clean Merge
```
User: /merge feature-login --into develop
Assistant:
1. Checking out develop...
2. Merging feature-login...
3. ✓ Merge successful, no conflicts
4. Creating merge commit...
5. ✓ Complete!

5 commits merged, 12 files changed
```

### Example 2: Merge with Conflicts
```
User: /merge feature-payment --into main
Assistant:
1. Checking out main...
2. Merging feature-payment...
3. ⚠ Conflicts detected in:
   - src/payment.py
   - tests/test_payment.py
4. Analyzing conflicts...
5. Auto-resolved: tests/test_payment.py (import order)
6. Need input for: src/payment.py

   Conflict in calculate_fee():
   - Current: flat 5% fee
   - Incoming: tiered fee (3% < $100, 5% >= $100)

   Which approach should we use?
   [User selects tiered approach]

7. Applying resolution...
8. ✓ All conflicts resolved
9. Creating merge commit...
10. ✓ Complete!
```

### Example 3: Dirty Working Tree
```
User: /merge hotfix --into main
Assistant:
⚠ You have uncommitted changes:
  - modified: src/config.py
  - new file: temp.txt

What would you like to do?
[User selects "Stash and continue"]

1. Stashing changes...
2. Checking out main...
3. Merging hotfix...
4. ✓ Complete!
5. Restoring stashed changes...
```
