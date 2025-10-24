---
name: init-workspace
description: Initialize workspace from language template
tags: [project, gitignored]
---

# Initialize Development Workspace

현재 디렉토리에 언어별 프로젝트 템플릿을 적용하여 작업환경을 초기화합니다.

## Usage

```bash
/init-workspace <language> [additional requirements]
```

**Examples:**
- `/init-workspace python`
- `/init-workspace python add fastapi and sqlalchemy dependencies`
- `/init-workspace javascript`

## How It Works

이 커맨드는 `.claude/scripts/init-workspace.sh` (Unix/Mac) 또는 `.claude/scripts/init-workspace.ps1` (Windows) 스크립트를 실행합니다.

스크립트는 다음 작업을 수행합니다:
1. GitHub에서 Vibe-Coding-Setting-swseo 저장소 clone
2. `templates/common/` 파일 복사 (.specify, .mcp.json)
3. `templates/{language}/` 파일 복사
4. 프로젝트 이름 자동 업데이트
5. 다음 단계 안내

## Workflow

### 1. 입력 파싱 및 검증

사용자 입력에서 언어와 추가 요구사항을 추출합니다:

```
입력: "/init-workspace python add fastapi"
→ language = "python"
→ additional_requirements = "add fastapi"
```

### 2. 안전성 검사

**현재 디렉토리 내용 확인:**

```bash
ls -la
```

**디렉토리가 비어있지 않으면:**
- 사용자에게 경고 메시지 표시
- AskUserQuestion으로 계속 진행 여부 확인
  - 옵션 1: "Yes, continue (may overwrite files)"
  - 옵션 2: "No, cancel"

### 3. 플랫폼 감지 및 스크립트 실행

스크립트를 로컬 또는 전역 위치에서 찾아 실행합니다.

**스크립트 검색 순서:**
1. 로컬 프로젝트: `.claude/scripts/init-workspace.*`
2. 전역 설정: `~/.claude/scripts/init-workspace.*`

```bash
# 플랫폼 감지
PLATFORM=$(uname -s 2>/dev/null || echo "Windows")

# 스크립트 위치 찾기
if [ -f ".claude/scripts/init-workspace.sh" ]; then
    SCRIPT_PATH=".claude/scripts/init-workspace.sh"
elif [ -f "$HOME/.claude/scripts/init-workspace.sh" ]; then
    SCRIPT_PATH="$HOME/.claude/scripts/init-workspace.sh"
elif [ -f ".claude/scripts/init-workspace.ps1" ]; then
    SCRIPT_PATH=".claude/scripts/init-workspace.ps1"
elif [ -f "$HOME/.claude/scripts/init-workspace.ps1" ]; then
    SCRIPT_PATH="$HOME/.claude/scripts/init-workspace.ps1"
else
    echo "Error: init-workspace script not found"
    echo "Please run /apply-settings to install scripts globally"
    exit 1
fi

# Windows인 경우
if [[ "$PLATFORM" == "Windows" ]] || [[ "$PLATFORM" == *"MINGW"* ]] || [[ "$PLATFORM" == *"MSYS"* ]]; then
    # PowerShell 스크립트 실행
    if [[ "$SCRIPT_PATH" == *.ps1 ]]; then
        powershell -ExecutionPolicy Bypass -File "$SCRIPT_PATH" "$LANGUAGE" $ADDITIONAL_REQUIREMENTS
    else
        # .ps1이 없으면 bash 스크립트 실행
        bash "$SCRIPT_PATH" "$LANGUAGE" $ADDITIONAL_REQUIREMENTS
    fi
else
    # Bash 스크립트 실행
    bash "$SCRIPT_PATH" "$LANGUAGE" $ADDITIONAL_REQUIREMENTS
fi
```

**IMPORTANT:**
- 스크립트를 직접 실행해야 합니다
- 파일을 직접 생성하거나 repo를 clone하지 마세요
- 스크립트가 없으면 `/apply-settings` 실행 필요

### 4. 추가 요구사항 처리 (선택)

스크립트 실행 후 추가 요구사항이 있으면 처리:

**예시:**
- "add fastapi and sqlalchemy" → pyproject.toml에 의존성 추가
- "setup docker" → Dockerfile과 docker-compose.yml 생성
- "add github actions for testing" → .github/workflows/test.yml 수정

### 5. 결과 확인 및 요약

스크립트 실행 결과를 확인하고 요약 제공:

```markdown
## ✅ Workspace Initialized

**Language:** Python
**Project Name:** {project_name}

### Files Created:
✓ .specify/ (Speckit templates & scripts)
✓ .mcp.json (MCP server configuration)
✓ pyproject.toml (uv configuration)
✓ src/{project_name}/ (main package)
✓ tests/ (unit/integration/e2e)
✓ docs/ (documentation)
✓ .github/workflows/ (CI/CD)

### Next Steps:
1. Install dependencies: `uv sync`
2. Install pre-commit hooks: `uv run pre-commit install`
3. Run tests: `uv run pytest`
4. Review and customize files

Ready to code! 🚀
```

## Error Handling

### Git이 설치되지 않음
```
Error: git is not installed or not in PATH

Please install git:
- Windows: https://git-scm.com/download/win
- Mac: brew install git
- Linux: sudo apt-get install git
```

### 템플릿이 존재하지 않음
```
Error: Template for '{language}' not found

Available templates:
  - python
  - javascript (coming soon)

Please choose an available template.
```

### 네트워크 오류
```
Error: Failed to clone repository

Please check your internet connection and try again.
If the problem persists, you can manually clone:
git clone https://github.com/swseo92/Vibe-Coding-Setting-swseo.git
```

## Implementation Notes

**CRITICAL RULES:**
1. ✅ **MUST execute the platform-specific script directly**
2. ❌ **NEVER clone the repository yourself**
3. ❌ **NEVER create files directly**
4. ❌ **NEVER read template files**
5. ✅ **Let the script handle ALL file operations**

**Correct Implementation:**
```bash
# Good - Execute script
powershell -File .claude/scripts/init-workspace.ps1 python

# Bad - Try to do it yourself
git clone ...
cp ...
```

**Why Scripts?**
- Ensures consistent behavior every time
- Properly handles edge cases
- Tested and verified implementation
- Platform-specific optimizations

**Script Responsibilities:**
- Clone repository to temp directory
- Copy common files (.specify, .mcp.json)
- Copy language-specific files
- Update project names
- Clean up temp directory
- Display success message

**Command Responsibilities:**
- Parse user input (language + requirements)
- Check directory safety
- Execute appropriate script
- Handle additional requirements (post-script)
- Provide final summary

## Available Templates

Currently supported:
- ✅ **python** - uv + pyproject.toml + pytest + ruff + pre-commit
- ✅ **common** - Shared files (.specify, .mcp.json)

Coming soon:
- 🔄 **javascript** - npm/pnpm + TypeScript + Jest
- 🔄 **rust** - Cargo + clippy + rustfmt
- 🔄 **go** - go modules + testing

## Template Structure

### Common Template (`templates/common/`)
Always copied to every project:
- `.specify/` - Speckit templates and scripts
  - `memory/constitution.md`
  - `scripts/bash/` - Automation scripts
  - `templates/` - Spec/plan/task templates
- `.mcp.json` - MCP server configurations
  - Playwright MCP (with Windows cmd wrapper)

### Python Template (`templates/python/`)
- `pyproject.toml` - uv configuration with dev dependencies
- `pytest.ini` - pytest configuration
- `src/myproject/` - main package (renamed to project name)
- `tests/` - unit/integration/e2e test structure
- `docs/testing_guidelines.md` - testing documentation
- `.gitignore` - Python-specific ignores
- `.env.example` - environment variables template
- `.pre-commit-config.yaml` - pre-commit hooks
- `.github/workflows/` - CI/CD pipelines
- `README.md` - project documentation

## Platform Support

- ✅ Windows (PowerShell 5.1+)
- ✅ macOS (bash/zsh)
- ✅ Linux (bash)
- ✅ WSL (bash)
- ✅ Git Bash on Windows

## Examples

### Example 1: Simple Python Project
```
User: /init-workspace python
Assistant:
1. Checking current directory... (3 files found)
2. Warning: Directory not empty. Continue? [User: Yes]
3. Executing init-workspace.ps1...
4. ✓ Repository cloned
5. ✓ Common files copied
6. ✓ Python template applied
7. ✓ Project name updated to 'my-project'
8. ✓ Cleanup completed

Ready! Run 'uv sync' to install dependencies.
```

### Example 2: Python with Additional Requirements
```
User: /init-workspace python add fastapi uvicorn
Assistant:
1. Executing init-workspace.sh...
2. ✓ Template initialized
3. Adding FastAPI dependencies to pyproject.toml...
4. ✓ Added: fastapi, uvicorn

Next: Run 'uv sync' to install new dependencies.
```

### Example 3: Empty Directory
```
User: /init-workspace python
Assistant:
1. Checking directory... (empty, good!)
2. Executing script...
3. ✓ All files copied successfully
4. ✓ Project 'awesome-project' ready

Start coding with 'uv sync' and 'uv run pytest'!
```

## Testing

To test this command:
```bash
# Create test directory
mkdir /tmp/test-init-workspace
cd /tmp/test-init-workspace

# Run command
/init-workspace python

# Verify files
ls -la .specify/
ls -la .mcp.json
ls -la src/
```

Expected result: All template files present, no errors.

## Related Commands

- `/apply-settings` - Apply .claude settings globally
- `/speckit.specify` - Create feature specifications
- `/worktree-create` - Create git worktree for features
