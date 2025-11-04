# Python 프로젝트

**이 디렉토리는 Python 기반 Claude Code 작업환경입니다.**

**상태**: 활성 개발 중
**언어**: Python 3.12+
**환경 구성일**: [날짜]

---

## ⚠️ 프로젝트 루트 폴더 규칙

**이 `claude.md` 파일이 위치한 폴더가 프로젝트의 루트(root) 디렉토리입니다.**

### 작업 범위 제한
- ✅ 모든 작업은 **이 루트 폴더를 기준**으로 수행됩니다
- ✅ 파일 경로는 **이 루트 폴더 기준 상대 경로** 또는 절대 경로를 사용합니다
- ❌ **상위 폴더(`../`)는 절대 참조하지 않습니다**
- ❌ 프로젝트 외부 파일은 수정하거나 참조하지 않습니다

### Claude Code 작업 가이드라인
```
프로젝트 루트/               ← 이 claude.md가 위치한 폴더
├── claude.md               ← 현재 파일 (프로젝트 루트 마커)
├── src/                    ← ✅ 접근 가능
├── tests/                  ← ✅ 접근 가능
├── pyproject.toml          ← ✅ 접근 가능
└── ...                     ← ✅ 루트 하위 모든 파일 접근 가능

../                         ← ❌ 상위 폴더 접근 금지
../../                      ← ❌ 상위의 상위 폴더 접근 금지
```

**중요**: Claude Code는 이 규칙을 엄격히 준수해야 합니다. 프로젝트 범위를 벗어난 작업은 수행하지 않습니다.

---

## 중요: Commit 시 주의사항

**이 파일은 프로젝트별로 커스터마이징이 필요합니다.**

Commit하기 전에 다음 항목들을 확인하고 수정하세요:

- [ ] **환경 구성일**: 실제 프로젝트 시작일 또는 오늘 날짜로 변경
- [ ] **프로젝트 설명**: 아래 섹션에 프로젝트 목적과 주요 기능 추가
- [ ] **환경변수**: 필요한 환경변수를 `.env.example`에 추가하고 문서화
- [ ] **의존성**: `pyproject.toml`에 실제 의존성 반영
- [ ] **테스트**: 테스트 전략 및 실행 방법 문서화

---

## 프로젝트 설명
<!-- 프로젝트의 목적, 주요 기능, 아키텍처 등을 설명하세요 -->

[여기에 프로젝트 설명을 작성하세요]

**주요 기능:**
- [기능 1]
- [기능 2]
- [기능 3]

---

## 개발 환경

### 필수 도구
- **Python**: 3.12 이상
- **패키지 매니저**: `uv` (권장) 또는 `pip`
- **가상환경**: 자동 생성 (`.venv/`)
- **기타 도구**: [예: Docker, PostgreSQL, Redis 등]

### 설치 및 실행

**1. 의존성 설치:**
```bash
# uv 사용 (권장)
uv sync

# 또는 pip 사용
pip install -e .
```

**2. 환경변수 설정:**
```bash
# .env.example을 복사하여 .env 생성
cp .env.example .env

# .env 파일을 편집하여 실제 값 입력
# 필요한 환경변수는 아래 "환경변수 관리" 섹션 참조
```

**3. 개발 서버 실행:**
```bash
# 애플리케이션 실행 (예시)
python src/main.py

# 또는 uvicorn (FastAPI 프로젝트인 경우)
uvicorn src.main:app --reload
```

**4. 테스트 실행:**
```bash
# 전체 테스트
pytest

# 커버리지 포함
pytest --cov=src tests/

# 특정 테스트 파일만
pytest tests/test_example.py
```

---

## ⚠️ 환경변수 관리 (MANDATORY)

**🚨 모든 환경변수는 반드시 `python-dotenv` 라이브러리를 통해 로드해야 합니다.**

### 기본 원칙

1. **절대 하드코딩 금지**
   - ❌ `API_KEY = "sk-abc123..."` (코드에 직접 작성)
   - ✅ `API_KEY = os.getenv("API_KEY")` (환경변수에서 로드)

2. **`.env` 파일은 Git에 커밋하지 않음**
   - ❌ `.env` 파일 커밋 (보안 위험!)
   - ✅ `.env.example` 템플릿만 커밋

3. **`load_dotenv()` 사용 필수**
   - 모든 Python 스크립트는 환경변수 사용 전에 `load_dotenv()` 호출

### 사용 방법

**1. 의존성 추가 (이미 포함되어 있음):**
```toml
# pyproject.toml
[project]
dependencies = [
    "python-dotenv>=1.0.0",
    # ... 기타 의존성
]
```

**2. 코드에서 환경변수 로드:**

```python
# src/main.py 또는 모든 entry point 파일의 최상단
import os
from dotenv import load_dotenv

# .env 파일에서 환경변수 로드 (프로젝트 루트의 .env)
load_dotenv()

# 이제 환경변수 사용 가능
DATABASE_URL = os.getenv("DATABASE_URL")
API_KEY = os.getenv("API_KEY")
DEBUG = os.getenv("DEBUG", "False").lower() == "true"

# 필수 환경변수 검증
if not DATABASE_URL:
    raise ValueError("DATABASE_URL 환경변수가 설정되지 않았습니다.")
```

**3. `.env` 파일 예시:**
```bash
# .env (Git에 커밋하지 않음!)
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
API_KEY=sk-abc123xyz789
DEBUG=True
LOG_LEVEL=INFO
```

**4. `.env.example` 템플릿 작성:**
```bash
# .env.example (Git에 커밋함)
# 이 파일을 복사하여 .env를 생성하고 실제 값을 입력하세요

# 데이터베이스 연결 정보
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# API 키
API_KEY=your_api_key_here

# 디버그 모드 (True/False)
DEBUG=False

# 로그 레벨 (DEBUG/INFO/WARNING/ERROR)
LOG_LEVEL=INFO
```

### 환경변수 체크리스트

프로젝트에서 사용하는 모든 환경변수를 여기에 문서화하세요:

| 환경변수 | 필수 | 기본값 | 설명 |
|----------|------|--------|------|
| `DATABASE_URL` | ✅ | - | PostgreSQL 연결 문자열 |
| `API_KEY` | ✅ | - | 외부 API 인증 키 |
| `DEBUG` | ❌ | `False` | 디버그 모드 활성화 |
| `LOG_LEVEL` | ❌ | `INFO` | 로그 레벨 (DEBUG/INFO/WARNING/ERROR) |
| `SECRET_KEY` | ✅ | - | 세션/JWT 서명 키 |

### 배포 환경별 설정

**개발 환경 (`.env`):**
```bash
DEBUG=True
LOG_LEVEL=DEBUG
DATABASE_URL=postgresql://localhost:5432/mydb_dev
```

**프로덕션 환경:**
```bash
# 환경변수는 시스템 레벨에서 설정 (Docker, K8s secrets, etc.)
# .env 파일 사용 안 함!
export DEBUG=False
export LOG_LEVEL=WARNING
export DATABASE_URL=postgresql://prod-db:5432/mydb_prod
```

### 보안 주의사항

- ⚠️ **절대 `.env` 파일을 Git에 커밋하지 마세요**
- ⚠️ **민감 정보는 로그에 출력하지 마세요**
- ⚠️ **환경변수 값을 코드 리뷰에 포함하지 마세요**
- ✅ **`.gitignore`에 `.env`가 포함되어 있는지 확인**

---

## 개발 규칙

### 코드 스타일
- **PEP 8** 준수
- **타입 힌트** 사용 권장 (Python 3.10+ 타입 문법)
- **Formatter**: `black` (line length 100)
- **Linter**: `ruff` (Flake8 + isort 대체)

**포매팅 실행:**
```bash
# 코드 포매팅
black src/ tests/

# Lint 검사 및 자동 수정
ruff check --fix src/ tests/

# 타입 체킹
mypy src/
```

### 임시 파일 관리
**🚨 모든 임시/테스트/실험 파일은 반드시 `tmp/` 폴더에만 생성합니다.**

- ✅ **DO**: `tmp/test-feature.py`, `tmp/experiment/`
- ❌ **NEVER**: `test-feature.py`, `experiment/` (루트에 직접 생성 금지)

**이유:** 보안 리스크, Git 오염, 관리 불가 방지

### 테스트 작성
- **최소 80% 커버리지** 유지
- **모든 공개 함수**에 대한 단위 테스트 작성
- **통합 테스트**로 주요 워크플로우 검증
- **테스트 파일 명명**: `test_{module_name}.py`

### Commit 규칙
```
type(scope): description

Types:
- feat: 새 기능
- fix: 버그 수정
- docs: 문서 업데이트
- refactor: 리팩토링
- test: 테스트 추가/수정
- chore: 빌드/설정 변경

Examples:
- feat(auth): add OAuth2 login
- fix(api): handle null values in response
- docs(readme): update installation guide
```

---

## 디렉토리 구조

```
프로젝트 루트/
├── src/                    # 소스 코드
│   ├── __init__.py
│   ├── main.py             # Entry point
│   ├── config.py           # 환경변수 로드 및 설정
│   └── ...                 # 모듈들
├── tests/                  # 테스트 코드
│   ├── __init__.py
│   ├── conftest.py         # Pytest fixtures
│   ├── test_main.py
│   └── ...
├── docs/                   # 문서
├── notebooks/              # Jupyter 노트북 (선택)
├── .claude/                # Claude Code 설정
│   ├── scripts/            # Hook 스크립트
│   └── settings.json       # 로컬 설정
├── .env                    # 환경변수 (Git 무시)
├── .env.example            # 환경변수 템플릿
├── .gitignore
├── pyproject.toml          # 프로젝트 설정 및 의존성
├── pytest.ini              # Pytest 설정
├── README.md               # 프로젝트 개요
└── claude.md               # 이 파일
```

---

## 의존성 관리

### 주요 라이브러리
- **python-dotenv**: 환경변수 로드 (필수)
- **pytest**: 테스트 프레임워크
- **pytest-cov**: 커버리지 측정
- **black**: 코드 포매터
- **ruff**: Fast linter
- **mypy**: 정적 타입 검사

### 의존성 추가
```bash
# 런타임 의존성 추가
uv add <package-name>

# 개발 의존성 추가
uv add --dev <package-name>

# 의존성 동기화
uv sync
```

---

## 문제 해결

### 환경변수가 로드되지 않을 때
```python
# 1. .env 파일 위치 확인
import os
from pathlib import Path

print("현재 작업 디렉토리:", os.getcwd())
print(".env 파일 존재:", Path(".env").exists())

# 2. 명시적 경로 지정
from dotenv import load_dotenv
load_dotenv(dotenv_path=Path(__file__).parent.parent / ".env")

# 3. 환경변수 확인
print("DATABASE_URL:", os.getenv("DATABASE_URL"))
```

### 가상환경 문제
```bash
# 가상환경 재생성
rm -rf .venv
uv sync
```

### 테스트 실패
```bash
# 상세 로그 출력
pytest -v -s

# 특정 테스트만 실행
pytest tests/test_main.py::test_function_name
```

---

## 메모
<!-- 프로젝트 관련 중요 메모를 여기에 추가하세요 -->

-
-
-

---

## 참고 자료

- [Python Docs](https://docs.python.org/3/)
- [uv Documentation](https://docs.astral.sh/uv/)
- [python-dotenv Documentation](https://github.com/theskumar/python-dotenv)
- [Pytest Documentation](https://docs.pytest.org/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/) (FastAPI 프로젝트인 경우)

---

## Exception Handling & Traceback 보존

**🚨 예외 처리 시 원본 traceback을 반드시 보존해야 합니다.**

디버깅의 핵심은 에러 발생 지점과 호출 스택을 정확히 파악하는 것입니다. `try-except`를 잘못 사용하면 중요한 traceback 정보가 손실되어 디버깅이 매우 어려워집니다.

### ✅ 올바른 패턴

**1. logging.exception() 사용** (가장 권장):
```python
import logging

try:
    risky_operation()
except Exception:
    # 자동으로 전체 traceback 포함하여 로깅
    logging.exception("Operation failed")
    # 또는 특정 로그 레벨 사용
    # logging.error("Operation failed", exc_info=True)
```

**2. traceback.print_exc() 사용**:
```python
import traceback
import sys

try:
    risky_operation()
except Exception:
    # 전체 traceback을 stderr로 출력
    traceback.print_exc()
    # 또는
    # traceback.print_exc(file=sys.stderr)
```

**3. raise from으로 예외 체이닝** (컨텍스트 보존):
```python
try:
    database_operation()
except KeyError as e:
    # 원본 예외(KeyError)를 보존하면서 새 예외(ValueError) 발생
    raise ValueError("Invalid configuration key") from e
    # Traceback에 "During handling of the above exception..." 표시됨
```

**4. 예외 재발생** (처리 후 전파):
```python
try:
    critical_operation()
except Exception:
    logging.exception("Critical operation failed, cleaning up...")
    cleanup_resources()
    raise  # 원본 예외를 그대로 재발생 (traceback 보존)
```

### ❌ Anti-patterns (피해야 할 패턴)

**1. Bare except** (절대 금지):
```python
try:
    something()
except:  # ❌ NEVER! BaseException, KeyboardInterrupt까지 잡음
    print("Error occurred")
```

**이유:**
- `KeyboardInterrupt`, `SystemExit` 같은 시스템 예외까지 잡아버림
- 프로그램 종료 불가 (Ctrl+C 무시)
- 항상 `except Exception:`을 사용하세요

**2. 정보 손실** (traceback 버림):
```python
try:
    risky_operation()
except Exception as e:
    print(f"Error: {e}")  # ❌ Traceback 손실! 메시지만 출력
    # 어디서 에러가 났는지 알 수 없음
```

**올바른 방법:**
```python
except Exception:
    logging.exception("Error occurred")  # ✅ Traceback 보존
```

**3. raise from 누락** (컨텍스트 손실):
```python
try:
    parse_config()
except KeyError as e:
    raise ValueError("Invalid config")  # ❌ 원본 KeyError 정보 손실
```

**올바른 방법:**
```python
except KeyError as e:
    raise ValueError("Invalid config") from e  # ✅ 체이닝
```

**4. 과도한 try-except** (너무 넓은 범위):
```python
try:
    step1()
    step2()
    step3()
except Exception:
    logging.exception("Something failed")  # ❌ 어느 단계에서 실패했는지 모호
```

**올바른 방법:**
```python
try:
    step1()
except Exception:
    logging.exception("Step 1 failed")

try:
    step2()
except Exception:
    logging.exception("Step 2 failed")
```

### 실전 예제

**데이터베이스 작업**:
```python
import logging
from contextlib import suppress

def fetch_user(user_id):
    try:
        user = db.query(User).filter_by(id=user_id).first()
        if not user:
            raise ValueError(f"User {user_id} not found")
        return user
    except SQLAlchemyError:
        logging.exception(f"Database error fetching user {user_id}")
        raise  # 상위 호출자에게 전파

# 선택적: 무시해도 되는 예외
with suppress(FileNotFoundError):
    os.remove("temp_file.txt")  # 파일 없어도 OK
```

**API 호출**:
```python
import requests
import logging

def call_external_api(url):
    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        return response.json()
    except requests.Timeout:
        logging.exception(f"API timeout: {url}")
        raise  # 타임아웃은 재시도 가능하므로 전파
    except requests.HTTPError as e:
        # 원본 HTTP 에러를 보존하면서 커스텀 예외 발생
        raise APIError(f"API call failed: {url}") from e
    except Exception:
        logging.exception(f"Unexpected error calling API: {url}")
        raise
```

### 핵심 원칙

1. **절대 bare except 사용 금지**: 항상 `except Exception:` 사용
2. **Traceback 보존 필수**: `logging.exception()` 또는 `traceback.print_exc()`
3. **예외 체이닝**: `raise ... from e`로 원본 컨텍스트 보존
4. **구체적 예외 처리**: 가능한 한 구체적 예외 타입 catch
5. **적절한 범위**: 최소한의 코드만 try 블록에 포함

---

**마지막 업데이트**: [날짜]
