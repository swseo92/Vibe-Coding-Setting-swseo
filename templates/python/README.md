# Python 프로젝트 템플릿

uv와 pyproject.toml을 사용하는 Python 프로젝트 템플릿입니다.

## 빠른 시작

### 1. uv 설치

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### 2. 프로젝트 초기화

```bash
# 의존성 설치
uv sync

# 개발 의존성 포함 설치
uv sync --all-extras
```

### 3. 가상환경 활성화

```bash
# uv는 자동으로 가상환경을 관리합니다
# 명령어 앞에 'uv run'을 붙여 실행

uv run python your_script.py
uv run pytest
```

## 프로젝트 구조

```
.
├── pyproject.toml          # 프로젝트 설정 및 의존성
├── .gitignore             # Git 제외 파일 목록
├── pytest.ini             # pytest 설정 (선택적)
├── README.md              # 이 문서
├── src/
│   └── myproject/         # 메인 소스 코드
└── tests/                 # 테스트 코드
    ├── conftest.py        # 전역 테스트 설정
    ├── unit/              # 단위 테스트
    │   └── conftest.py
    ├── integration/       # 통합 테스트
    │   └── conftest.py
    └── e2e/              # E2E 테스트
        └── conftest.py
```

## 개발 워크플로우

### 의존성 관리

```bash
# 패키지 추가
uv add requests

# 개발 의존성 추가
uv add --dev pytest

# 패키지 제거
uv remove requests

# 의존성 업데이트
uv sync --upgrade
```

### 테스트 실행

```bash
# 전체 테스트
uv run pytest

# 단위 테스트만
uv run pytest tests/unit/

# 통합 테스트만
uv run pytest tests/integration/

# 커버리지 포함
uv run pytest --cov=myproject

# 느린 테스트 제외
uv run pytest -m "not slow"
```

### 코드 품질 검사

```bash
# Ruff로 린팅
uv run ruff check .

# 자동 수정
uv run ruff check --fix .

# 포맷팅
uv run ruff format .
```

## pyproject.toml 주요 설정

### 프로젝트 정보 수정
```toml
[project]
name = "myproject"              # 프로젝트 이름 변경
version = "0.1.0"
description = "..."             # 설명 추가
requires-python = ">=3.10"      # Python 버전 요구사항
```

### 의존성 추가
```toml
[project.dependencies]
requests = ">=2.31.0"
pandas = ">=2.0.0"
```

### pytest 설정
```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
# --cov=myproject 부분을 프로젝트 이름에 맞게 수정
```

### 코드 커버리지 설정
```toml
[tool.coverage.run]
source = ["myproject"]          # 프로젝트 이름에 맞게 수정
```

## 테스트 작성 가이드

### AAA 패턴 (Arrange-Act-Assert)
```python
def test_example():
    # Arrange: 테스트 데이터 준비
    data = {"key": "value"}

    # Act: 테스트할 기능 실행
    result = process_data(data)

    # Assert: 결과 검증
    assert result == expected_value
```

### 픽스처 활용
```python
# conftest.py에 정의된 픽스처 사용
def test_with_fixture(sample_data):
    assert sample_data["id"] == 1
```

### 매개변수화 테스트
```python
@pytest.mark.parametrize("input,expected", [
    (1, 2),
    (2, 4),
    (3, 6),
])
def test_double(input, expected):
    assert double(input) == expected
```

## 환경 변수

테스트 실행 시 자동으로 `TEST_MODE=true`가 설정됩니다.

### 환경 변수 설정

1. `.env.example`을 `.env`로 복사:
```bash
cp .env.example .env
```

2. `.env` 파일 수정하여 실제 값 입력

3. python-dotenv 사용:
```bash
uv add python-dotenv
```

```python
from dotenv import load_dotenv
load_dotenv()
```

## CI/CD 파이프라인

이 템플릿에는 완전한 CI/CD 워크플로우가 포함되어 있습니다.

### GitHub Actions 워크플로우

#### 1. CI (`.github/workflows/ci.yml`)
**트리거:** Push 및 Pull Request (main, master, develop 브랜치)

**작업:**
- **Test Job**: Python 3.10, 3.11, 3.12에서 테스트 실행
- **Lint Job**: Ruff 린팅 및 포맷팅 검사
- **Security Job**: Bandit 보안 스캔 및 Safety 의존성 검사

```bash
# 로컬에서 CI와 동일한 검사 실행
uv run ruff check .
uv run ruff format --check .
uv run mypy src/
uv run pytest --cov=myproject
uv run bandit -r src/
```

#### 2. Release (`.github/workflows/release.yml`)
**트리거:** 태그 푸시 (v*.*.*)

**작업:**
- 테스트 실행
- 패키지 빌드
- GitHub Release 생성
- PyPI 배포 (옵션)

```bash
# 릴리즈 만들기
git tag v0.1.0
git push origin v0.1.0
```

#### 3. Dependency Update (`.github/workflows/dependency-update.yml`)
**트리거:** 매주 월요일 또는 수동 실행

**작업:**
- 의존성 자동 업데이트
- 테스트 실행
- Pull Request 자동 생성

### Dependabot

`.github/dependabot.yml`이 설정되어 있어 자동으로 의존성을 업데이트합니다:
- GitHub Actions 주간 업데이트
- Python 패키지 주간 업데이트
- 관련 패키지 그룹화 (testing, linting, production)

### Pre-commit Hooks

로컬 개발 환경에서 커밋 전 자동 검사:

```bash
# Pre-commit 설치
uv run pre-commit install

# 모든 파일에 수동 실행
uv run pre-commit run --all-files
```

**포함된 훅:**
- Ruff 린팅 및 포맷팅
- Mypy 타입 체킹
- Trailing whitespace 제거
- 큰 파일 체크
- Private key 감지
- Bandit 보안 스캔

### CI/CD 워크플로우 활성화

1. **Codecov 설정** (선택):
   - https://codecov.io 에서 계정 생성
   - Repository secrets에 `CODECOV_TOKEN` 추가

2. **PyPI 배포** (선택):
   - PyPI 계정 생성 및 API 토큰 발급
   - Repository secrets에 `PYPI_TOKEN` 추가

3. **의존성 자동 업데이트**:
   - Dependabot이 자동으로 활성화됨
   - PR 검토 및 병합만 하면 됨

## 추가 도구

템플릿에는 이미 포함되어 있습니다:

### 타입 체킹 (mypy)
```bash
uv run mypy src/
```

### 보안 검사 (bandit)
```bash
uv run bandit -r src/
```

### 문서 생성 (Sphinx)
```bash
uv add --dev sphinx sphinx-rtd-theme
uv run sphinx-quickstart docs/
```

## 참고 자료

- [uv 공식 문서](https://docs.astral.sh/uv/)
- [pytest 문서](https://docs.pytest.org/)
- [Ruff 문서](https://docs.astral.sh/ruff/)
- 프로젝트 테스트 가이드라인: `docs/python/testing_guidelines.md`

## 문제 해결

### uv가 인식되지 않을 때
```bash
# 쉘 재시작 또는 PATH 확인
echo $PATH  # Linux/macOS
echo %PATH%  # Windows
```

### 의존성 충돌
```bash
# 캐시 정리 후 재설치
uv cache clean
uv sync --reinstall
```

### 테스트 실패 디버깅
```bash
# 상세 출력으로 실행
uv run pytest -vv --tb=long

# 특정 테스트만 실행
uv run pytest tests/unit/test_specific.py::test_function
```
