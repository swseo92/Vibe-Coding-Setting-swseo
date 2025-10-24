---
name: init-workspace
description: Initialize workspace from language template
tags: [project, gitignored]
---

# Initialize Development Workspace

현재 디렉토리에 언어별 프로젝트 템플릿을 적용하여 작업환경을 초기화합니다.

## Usage

```bash
/init-workspace [language] [additional requirements]
```

**Examples:**
- `/init-workspace python`
- `/init-workspace python add fastapi and sqlalchemy dependencies`
- `/init-workspace javascript`

## Workflow

### 1. 사용자 요청 파싱
- 언어 추출 (python, javascript, rust, go 등)
- 추가 요구사항 추출 (있는 경우)

### 2. 안전성 검사
현재 디렉토리 상태 확인:

```bash
# 현재 디렉토리 내용 확인
ls -la
```

**만약 디렉토리가 비어있지 않으면:**
- 사용자에게 경고
- 계속 진행할지 확인 (AskUserQuestion 도구 사용)
- 중요 파일 덮어쓰기 위험 안내

### 3. 템플릿 복사

#### Windows (PowerShell)
```powershell
# 임시 디렉토리에 설정 repo clone
$tempDir = New-Item -ItemType Directory -Path "$env:TEMP\vibe-coding-$(Get-Random)"
git clone https://github.com/swseo92/Vibe-Coding-Setting-swseo.git $tempDir

# 템플릿 파일 복사
$language = "python"  # 사용자 입력에서 추출
$templatePath = Join-Path $tempDir "templates\$language"

if (-not (Test-Path $templatePath)) {
    Write-Host "Error: Template for '$language' not found" -ForegroundColor Red
    Write-Host "Available templates:" -ForegroundColor Yellow
    Get-ChildItem (Join-Path $tempDir "templates") -Directory | ForEach-Object { Write-Host "  - $($_.Name)" }
    Remove-Item -Recurse -Force $tempDir
    exit 1
}

# 모든 파일 복사 (hidden 파일 포함)
Get-ChildItem -Path $templatePath -Force -Recurse | ForEach-Object {
    $relativePath = $_.FullName.Substring($templatePath.Length + 1)
    $targetPath = Join-Path (Get-Location) $relativePath

    if ($_.PSIsContainer) {
        New-Item -ItemType Directory -Force -Path $targetPath | Out-Null
    } else {
        $targetDir = Split-Path -Parent $targetPath
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
        }
        Copy-Item -Force $_.FullName $targetPath
    }
}

# 임시 디렉토리 정리
Remove-Item -Recurse -Force $tempDir

Write-Host "✓ Template files copied successfully" -ForegroundColor Green
```

#### Unix/Linux/Mac (Bash)
```bash
# 임시 디렉토리에 설정 repo clone
TEMP_DIR=$(mktemp -d)
git clone https://github.com/swseo92/Vibe-Coding-Setting-swseo.git "$TEMP_DIR"

# 템플릿 파일 복사
LANGUAGE="python"  # 사용자 입력에서 추출
TEMPLATE_PATH="$TEMP_DIR/templates/$LANGUAGE"

if [ ! -d "$TEMPLATE_PATH" ]; then
    echo "Error: Template for '$LANGUAGE' not found"
    echo "Available templates:"
    ls "$TEMP_DIR/templates"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 모든 파일 복사 (hidden 파일 포함)
cp -r "$TEMPLATE_PATH/." .

# 임시 디렉토리 정리
rm -rf "$TEMP_DIR"

echo "✓ Template files copied successfully"
```

### 4. 프로젝트 이름 업데이트

복사 후 템플릿의 기본 이름(`myproject`)을 실제 프로젝트 이름으로 변경:

**Python의 경우:**
```bash
# 현재 디렉토리 이름을 프로젝트 이름으로 사용
PROJECT_NAME=$(basename $(pwd))

# src/myproject → src/{PROJECT_NAME}
mv src/myproject "src/$PROJECT_NAME"

# pyproject.toml 업데이트
# name = "myproject" → name = "{PROJECT_NAME}"
# 관련 경로들도 모두 업데이트
```

사용자에게 확인:
- AskUserQuestion 도구로 프로젝트 이름 확인
- 기본값: 현재 디렉토리 이름

### 5. 추가 요구사항 처리

사용자가 추가 요청한 내용이 있으면 처리:

**예시:**
- "add fastapi and sqlalchemy dependencies" → pyproject.toml에 의존성 추가
- "setup docker" → Dockerfile 생성
- "add github actions" → .github/workflows/ 생성

### 6. 초기화 완료 안내

```markdown
## ✅ Workspace Initialized

**Language:** Python
**Template:** templates/python
**Project Name:** {project_name}

### Files Created:
- claude.md (workspace marker)
- pyproject.toml (uv configuration)
- src/{project_name}/__init__.py
- tests/ (unit, integration, e2e)
- docs/testing_guidelines.md
- .gitignore
- README.md

### Next Steps:

1. **Install dependencies:**
   ```bash
   uv sync
   ```

2. **Review and customize:**
   - Update pyproject.toml with project details
   - Review README.md
   - Check docs/testing_guidelines.md

3. **Initialize git (if needed):**
   ```bash
   git init
   git add .
   git commit -m "Initial commit from template"
   ```

4. **Start developing:**
   ```bash
   # Run tests
   uv run pytest

   # Add your code to src/{project_name}/
   ```

### Template Documentation:
See README.md for complete usage guide.
```

## Error Handling

### 템플릿이 존재하지 않는 경우
```
Error: Template for '{language}' not found

Available templates:
  - python
  - javascript (coming soon)
  - rust (coming soon)

Please use one of the available templates or contribute a new one:
https://github.com/swseo92/Vibe-Coding-Setting-swseo
```

### 디렉토리가 비어있지 않은 경우
AskUserQuestion으로 확인:
- "현재 디렉토리에 파일이 있습니다. 계속하면 일부 파일이 덮어쓰여질 수 있습니다. 계속하시겠습니까?"
- 옵션: "예, 계속", "아니오, 취소"

### Git이 설치되지 않은 경우
```
Error: git is not installed or not in PATH

Please install git first:
- Windows: https://git-scm.com/download/win
- Mac: brew install git
- Linux: sudo apt-get install git (Ubuntu/Debian)
```

## Implementation Notes

**IMPORTANT:**
1. NEVER read or clone the template repository yourself
2. Use the Bash tool to execute the clone and copy commands
3. Let the scripts handle all file operations
4. Use AskUserQuestion for user confirmations
5. Parse user input to extract language and additional requirements
6. Handle both Windows (PowerShell) and Unix (Bash) environments

**Platform Detection:**
```python
import platform
is_windows = platform.system() == "Windows"
```

**User Input Parsing Example:**
```
Input: "/init-workspace python add fastapi"
→ language = "python"
→ additional_requirements = "add fastapi"

Input: "/init-workspace javascript"
→ language = "javascript"
→ additional_requirements = None
```

## Available Templates

Currently supported:
- ✅ **python** - uv + pyproject.toml + pytest + ruff

Coming soon:
- 🔄 **javascript** - npm/pnpm + TypeScript + Jest
- 🔄 **rust** - Cargo + clippy + rustfmt
- 🔄 **go** - go modules + testing

## Template Structure Reference

Each template should include:
- `claude.md` - Workspace marker
- Language-specific config files
- `src/` directory
- `tests/` directory
- `docs/` directory
- `.gitignore`
- `README.md`

See `templates/python/` for reference implementation.
