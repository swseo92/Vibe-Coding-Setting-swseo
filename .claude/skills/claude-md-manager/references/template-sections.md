# Claude.md Template Sections

This document provides standard section templates and examples for effective `claude.md` documentation.

---

## Standard Section Order

**Recommended structure for most projects:**

1. **Project Title & Description** (Required)
2. **Critical Rules** (If applicable)
3. **Project Scope/Boundaries** (If applicable)
4. **Purpose & Goals** (Required)
5. **Directory Structure** (Required)
6. **Setup Instructions** (Required)
7. **Development Rules** (Required)
8. **Dependencies & Configuration** (Required)
9. **Workflows & Commands** (Required)
10. **Testing** (Required for most projects)
11. **Build & Deployment** (If applicable)
12. **Special Features** (If applicable)
13. **Troubleshooting** (Optional)
14. **References** (Optional)

---

## Template Section: Project Title & Description

**Purpose:** Immediately orient Claude to the project's identity and purpose.

**Template:**
```markdown
# {Project Name}

**{One-sentence project description}**

{2-3 sentence explanation of what this project does, who it's for, and what problem it solves}

---
```

**Example:**
```markdown
# FastAPI User Authentication Service

**Production-ready authentication microservice built with FastAPI and PostgreSQL.**

This service provides JWT-based authentication, user registration, password reset, and role-based access control (RBAC) for our microservices architecture. It integrates with our existing user database and provides RESTful endpoints for all major platforms (web, mobile, desktop).

---
```

---

## Template Section: Critical Rules

**Purpose:** Highlight non-negotiable rules that must be followed.

**Template:**
```markdown
## ⚠️ CRITICAL: Mandatory Rules

**Read these rules before any work:**

### 1. {Rule Category} (MANDATORY)

**🚨 {Clear statement of the rule}**

- ✅ **DO**: {Correct examples}
- ❌ **NEVER**: {Prohibited examples}

**Reason:** {Brief explanation of why this rule exists}

**Details:** [Link to detailed section if needed]

### 2. {Next Critical Rule}

{...}

---
```

**Example:**
```markdown
## ⚠️ CRITICAL: Mandatory Rules

**Read these rules before any work:**

### 1. Database Migration Rules (MANDATORY)

**🚨 All database schema changes MUST go through migrations. Never modify the database directly.**

- ✅ **DO**: `alembic revision --autogenerate -m "Add user email column"`
- ❌ **NEVER**: Direct SQL `ALTER TABLE` in production

**Reason:** Direct changes bypass version control, break deployments, and cause data inconsistencies.

**Details:** See [Database Migrations](#database-migrations) section.

### 2. Secret Management (MANDATORY)

**🚨 Never commit secrets to Git. Always use environment variables.**

- ✅ **DO**: `DATABASE_URL=os.getenv("DATABASE_URL")`
- ❌ **NEVER**: `DATABASE_URL = "postgresql://user:password@localhost/db"`

**Reason:** Prevents credential leaks and security breaches.

---
```

---

## Template Section: Project Scope/Boundaries

**Purpose:** Define what's in and out of scope, especially for shared repositories.

**Template:**
```markdown
## ⚠️ Project Scope & Boundaries

**This `CLAUDE.md` file defines the root directory for this project.**

### Working Directory
- ✅ All work is performed **within this root folder**
- ✅ File paths use **this root as the base**
- ❌ **Never reference parent directories** (`../`)
- ❌ Never modify files outside this repository

### Scope Limitations
```
{Project Root}/              ← This CLAUDE.md location (repository root)
├── {folders}                ← ✅ Access allowed
└── ...                      ← ✅ All subdirectories accessible

../                          ← ❌ Parent directory access forbidden
../../                       ← ❌ Grandparent access forbidden
```

**Important:** Claude Code must strictly follow these boundaries.

---
```

**Example:**
```markdown
## ⚠️ Project Scope & Boundaries

**This `CLAUDE.md` file defines the root directory for this project.**

### Working Directory
- ✅ All work is performed **within this root folder**
- ✅ File paths use **this root as the base**
- ❌ **Never reference parent directories** (`../`)
- ❌ Never modify files outside this repository

### Scope Limitations
```
my-auth-service/             ← This CLAUDE.md location (repository root)
├── src/                     ← ✅ Access allowed
├── tests/                   ← ✅ Access allowed
├── .claude/                 ← ✅ Access allowed
└── ...                      ← ✅ All subdirectories accessible

../                          ← ❌ Parent directory access forbidden
../../other-service/         ← ❌ Other services forbidden
```

**Important:** This is a microservice in a monorepo, but Claude Code works only within this service's boundaries.

---
```

---

## Template Section: Purpose & Goals

**Purpose:** Explain the "why" behind the project.

**Template:**
```markdown
## Purpose

{1-2 paragraph explanation of the project's purpose and goals}

**Key Objectives:**
- {Objective 1}
- {Objective 2}
- {Objective 3}

**Technology Stack:**
- **Language:** {Primary language}
- **Framework:** {Main framework}
- **Database:** {Database system}
- **Key Libraries:** {Important dependencies}

---
```

**Example:**
```markdown
## Purpose

This project provides a centralized authentication service for our microservices ecosystem. It handles user registration, login, JWT token generation, and role-based access control, allowing other services to delegate authentication concerns.

**Key Objectives:**
- Provide secure, scalable authentication for 10+ microservices
- Support multiple authentication methods (password, OAuth, SSO)
- Maintain 99.9% uptime with horizontal scalability
- Ensure GDPR compliance for user data

**Technology Stack:**
- **Language:** Python 3.12
- **Framework:** FastAPI 0.110
- **Database:** PostgreSQL 16 with SQLAlchemy
- **Key Libraries:** PyJWT, Passlib, Alembic, Pydantic

---
```

---

## Template Section: Directory Structure

**Purpose:** Map the project's file organization.

**Template:**
```markdown
## Directory Structure

```
{project-root}/
├── {folder}/               # {Description}
│   ├── {subfolder}/        # {Description}
│   └── {file}              # {Description}
├── {folder}/               # {Description}
├── {config-file}           # {Description}
└── claude.md               # This file
```

**Key Directories:**
- **`{folder}/`** - {Detailed purpose}
- **`{folder}/`** - {Detailed purpose}

**Configuration Files:**
- **`{config-file}`** - {Purpose and what it configures}

---
```

**Example:**
```markdown
## Directory Structure

```
auth-service/
├── src/                    # Source code
│   ├── api/                # FastAPI routes and endpoints
│   ├── models/             # SQLAlchemy database models
│   ├── schemas/            # Pydantic request/response schemas
│   ├── services/           # Business logic layer
│   ├── auth/               # Authentication utilities (JWT, password hashing)
│   └── main.py             # FastAPI application entry point
├── tests/                  # Test suite
│   ├── unit/               # Unit tests
│   ├── integration/        # Integration tests
│   └── conftest.py         # Pytest fixtures
├── alembic/                # Database migrations
│   └── versions/           # Migration scripts
├── .claude/                # Claude Code configuration
│   ├── commands/           # Slash commands
│   └── settings.json       # Local settings
├── pyproject.toml          # Dependencies and project config
├── pytest.ini              # Pytest configuration
├── .env.example            # Environment variable template
└── claude.md               # This file
```

**Key Directories:**
- **`src/api/`** - FastAPI route definitions organized by resource (users, auth, roles)
- **`src/services/`** - Business logic separated from HTTP layer for testability
- **`src/auth/`** - JWT generation, password hashing, token validation utilities

**Configuration Files:**
- **`pyproject.toml`** - Python dependencies managed with `uv`
- **`.env.example`** - Template for required environment variables (copy to `.env`)

---
```

---

## Template Section: Setup Instructions

**Purpose:** Enable someone to get the project running from scratch.

**Template:**
```markdown
## Setup Instructions

### Prerequisites
- {Software/tool} version {X.Y} or higher
- {Another requirement}
- {Optional requirement} (optional, for {purpose})

### Installation

**1. Clone the repository:**
```bash
{clone command if applicable}
```

**2. Install dependencies:**
```bash
{dependency installation commands}
```

**3. Configure environment:**
```bash
# Copy environment template
{copy command}

# Edit .env and set:
# - {VARIABLE_1}: {Description}
# - {VARIABLE_2}: {Description}
```

**4. Initialize database** (if applicable):
```bash
{database setup commands}
```

**5. Run the application:**
```bash
{run command}
```

**Verify installation:**
```bash
{verification command or URL to check}
```

### Platform-Specific Notes

**Windows:**
- {Windows-specific instruction}

**macOS:**
- {macOS-specific instruction}

**Linux:**
- {Linux-specific instruction}

---
```

**Example:**
```markdown
## Setup Instructions

### Prerequisites
- Python 3.12 or higher
- PostgreSQL 16 or higher
- `uv` package manager (`pip install uv`)
- Docker (optional, for local PostgreSQL)

### Installation

**1. Install dependencies:**
```bash
# Using uv (recommended)
uv sync

# Or using pip
pip install -e .
```

**2. Configure environment:**
```bash
# Copy environment template
cp .env.example .env

# Edit .env and set:
# - DATABASE_URL: PostgreSQL connection string
# - JWT_SECRET_KEY: Secret for signing JWT tokens (generate with `openssl rand -hex 32`)
# - JWT_ALGORITHM: HS256 (default)
```

**3. Initialize database:**
```bash
# Run migrations
alembic upgrade head

# Seed initial data (optional)
python scripts/seed_db.py
```

**4. Run the application:**
```bash
# Development server with auto-reload
uvicorn src.main:app --reload

# Production server
uvicorn src.main:app --host 0.0.0.0 --port 8000
```

**Verify installation:**
```bash
# Check API health endpoint
curl http://localhost:8000/health

# Or visit in browser:
# http://localhost:8000/docs (Swagger UI)
```

### Platform-Specific Notes

**Windows:**
- Use `set` instead of `export` for environment variables
- Git Bash recommended for shell commands

**macOS:**
- Install PostgreSQL with Homebrew: `brew install postgresql@16`

**Linux:**
- Ensure PostgreSQL service is running: `sudo systemctl start postgresql`

---
```

---

## Template Section: Development Rules

**Purpose:** Define conventions and best practices for contributors.

**Template:**
```markdown
## Development Rules

### Code Style
- **Style Guide:** {Standard or custom guide}
- **Formatter:** {Tool name and config}
- **Linter:** {Tool name and config}

**Run formatters:**
```bash
{format command}
```

### File Organization
- {Rule about where files go}
- {Rule about naming conventions}
- {Rule about imports/exports}

### Commit Guidelines
- {Commit message format}
- {When to commit}
- {Branch naming}

### Testing Requirements
- {Coverage requirements}
- {Test types required}
- {Test naming conventions}

### Prohibited Practices
- ❌ {Anti-pattern 1} - {Why}
- ❌ {Anti-pattern 2} - {Why}
- ❌ {Anti-pattern 3} - {Why}

---
```

**Example:**
```markdown
## Development Rules

### Code Style
- **Style Guide:** PEP 8 with line length 100
- **Formatter:** Black (configured in `pyproject.toml`)
- **Linter:** Ruff (replaces Flake8 + isort)

**Run formatters:**
```bash
# Format code
black src/ tests/

# Lint and auto-fix
ruff check --fix src/ tests/

# Type checking
mypy src/
```

### File Organization
- **One model per file** in `src/models/`, named after the model class (snake_case)
- **Group related routes** in `src/api/`, one resource per file (e.g., `users.py`, `auth.py`)
- **Business logic in services**, never directly in route handlers

### Commit Guidelines
- **Format:** `type(scope): description`
- **Types:** `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
- **Examples:**
  - `feat(auth): add OAuth2 Google integration`
  - `fix(users): handle duplicate email registration`

### Testing Requirements
- **Minimum 80% coverage** for new code
- **All API endpoints** must have integration tests
- **Critical paths** (auth, payments) require 95%+ coverage
- **Test file naming:** `test_{module_name}.py`

### Prohibited Practices
- ❌ **Direct database queries in routes** - Use service layer
- ❌ **Committing `.env` files** - Use `.env.example` template
- ❌ **Hardcoded secrets** - Always use environment variables
- ❌ **Skipping migrations** - Never modify DB schema directly

---
```

---

## Template Section: Workflows & Commands

**Purpose:** Document how to perform common development tasks.

**Template:**
```markdown
## Workflows & Commands

### Development Workflow
```bash
# {Description of task}
{command}

# {Description of another task}
{command}
```

### Testing
```bash
# {Run all tests}
{command}

# {Run specific test}
{command}

# {Run with coverage}
{command}
```

### Database Management
```bash
# {Create migration}
{command}

# {Apply migrations}
{command}

# {Rollback}
{command}
```

### Custom Commands
{Document any slash commands or custom scripts}

---
```

**Example:**
```markdown
## Workflows & Commands

### Development Workflow
```bash
# Start development server with auto-reload
uvicorn src.main:app --reload

# Run in debug mode
uvicorn src.main:app --reload --log-level debug

# Access interactive API docs
# http://localhost:8000/docs
```

### Testing
```bash
# Run all tests
pytest

# Run specific test file
pytest tests/unit/test_auth.py

# Run with coverage report
pytest --cov=src --cov-report=html tests/

# Open coverage report
# Open htmlcov/index.html in browser
```

### Database Management
```bash
# Create new migration
alembic revision --autogenerate -m "Add user email verification"

# Apply migrations
alembic upgrade head

# Rollback one migration
alembic downgrade -1

# View migration history
alembic history
```

### Custom Commands

**`/commit`** - Run pre-commit checks and create commit
```bash
/commit "feat(auth): add email verification"
```

**`/test-endpoint`** - Test specific API endpoint
```bash
/test-endpoint POST /api/auth/login
```

---
```

---

## Template Section: Testing

**Purpose:** Explain testing strategy and how to run tests.

**Template:**
```markdown
## Testing

### Test Structure
- **Unit Tests:** {What they cover}
- **Integration Tests:** {What they cover}
- **E2E Tests:** {What they cover} (if applicable)

### Running Tests
```bash
{test commands with explanations}
```

### Writing Tests
{Guidelines for writing tests}

### Test Fixtures
{Explanation of available fixtures}

### Mocking
{When and how to mock dependencies}

---
```

---

## Template Section: Environment Variables Management

**Purpose:** Document how to securely manage environment variables and secrets.

**Template:**
```markdown
## ⚠️ 환경변수 관리 (MANDATORY)

**🚨 모든 환경변수는 반드시 {적절한 라이브러리}를 통해 로드해야 합니다.**

### 기본 원칙

1. **절대 하드코딩 금지**
   - ❌ `API_KEY = "sk-abc123..."` (코드에 직접 작성)
   - ✅ `API_KEY = {환경변수 로드 방법}` (환경변수에서 로드)

2. **`.env` 파일은 Git에 커밋하지 않음**
   - ❌ `.env` 파일 커밋 (보안 위험!)
   - ✅ `.env.example` 템플릿만 커밋

3. **환경변수 로드 라이브러리 사용**
   - {언어별 권장 라이브러리 및 사용법}

### 사용 방법

**1. 의존성 추가:**
```{language}
{dependency installation command}
```

**2. 코드에서 환경변수 로드:**
```{language}
{code example for loading env vars}
```

**3. `.env` 파일 예시:**
```bash
# .env (Git에 커밋하지 않음!)
DATABASE_URL=your_database_url
API_KEY=your_api_key
DEBUG=true
```

**4. `.env.example` 템플릿:**
```bash
# .env.example (Git에 커밋함)
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
API_KEY=your_api_key_here
DEBUG=false
```

### 환경변수 체크리스트

| 환경변수 | 필수 | 기본값 | 설명 |
|----------|------|--------|------|
| `DATABASE_URL` | ✅ | - | 데이터베이스 연결 문자열 |
| `API_KEY` | ✅ | - | API 인증 키 |
| `DEBUG` | ❌ | `false` | 디버그 모드 |

### 보안 주의사항

- ⚠️ **절대 `.env` 파일을 Git에 커밋하지 마세요**
- ⚠️ **민감 정보는 로그에 출력하지 마세요**
- ✅ **`.gitignore`에 `.env`가 포함되어 있는지 확인**

---
```

**Python Example:**
```markdown
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

**1. 의존성 추가:**
```bash
# uv 사용
uv add python-dotenv

# pip 사용
pip install python-dotenv
```

**2. 코드에서 환경변수 로드:**
```python
import os
from dotenv import load_dotenv

# .env 파일에서 환경변수 로드
load_dotenv()

# 환경변수 사용
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
```

**4. `.env.example` 템플릿:**
```bash
# .env.example (Git에 커밋함)
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
API_KEY=your_api_key_here
DEBUG=False
```

### 환경변수 체크리스트

| 환경변수 | 필수 | 기본값 | 설명 |
|----------|------|--------|------|
| `DATABASE_URL` | ✅ | - | PostgreSQL 연결 문자열 |
| `API_KEY` | ✅ | - | 외부 API 인증 키 |
| `DEBUG` | ❌ | `False` | 디버그 모드 활성화 |
| `SECRET_KEY` | ✅ | - | 세션/JWT 서명 키 |

### 보안 주의사항

- ⚠️ **절대 `.env` 파일을 Git에 커밋하지 마세요**
- ⚠️ **민감 정보는 로그에 출력하지 마세요**
- ⚠️ **환경변수 값을 코드 리뷰에 포함하지 마세요**
- ✅ **`.gitignore`에 `.env`가 포함되어 있는지 확인**

---
```

**JavaScript/Node.js Example:**
```markdown
## ⚠️ 환경변수 관리 (MANDATORY)

**🚨 모든 환경변수는 반드시 `dotenv` 라이브러리를 통해 로드해야 합니다.**

### 기본 원칙

1. **절대 하드코딩 금지**
   - ❌ `const API_KEY = "sk-abc123..."` (코드에 직접 작성)
   - ✅ `const API_KEY = process.env.API_KEY` (환경변수에서 로드)

2. **`.env` 파일은 Git에 커밋하지 않음**
   - ❌ `.env` 파일 커밋 (보안 위험!)
   - ✅ `.env.example` 템플릿만 커밋

3. **`dotenv.config()` 사용 필수**
   - Entry point에서 가장 먼저 호출

### 사용 방법

**1. 의존성 추가:**
```bash
npm install dotenv
# or
yarn add dotenv
# or
pnpm add dotenv
```

**2. 코드에서 환경변수 로드:**
```javascript
// index.js or app.js (entry point)
require('dotenv').config();

// 환경변수 사용
const DATABASE_URL = process.env.DATABASE_URL;
const API_KEY = process.env.API_KEY;
const DEBUG = process.env.DEBUG === 'true';

// 필수 환경변수 검증
if (!DATABASE_URL) {
  throw new Error('DATABASE_URL environment variable is not set');
}
```

**3. TypeScript 사용 시:**
```typescript
import dotenv from 'dotenv';
dotenv.config();

const DATABASE_URL: string = process.env.DATABASE_URL!;
const API_KEY: string = process.env.API_KEY!;
const DEBUG: boolean = process.env.DEBUG === 'true';
```

**4. `.env` 파일 예시:**
```bash
# .env (Git에 커밋하지 않음!)
DATABASE_URL=mongodb://localhost:27017/mydb
API_KEY=sk-abc123xyz789
DEBUG=true
PORT=3000
```

**5. `.env.example` 템플릿:**
```bash
# .env.example (Git에 커밋함)
DATABASE_URL=mongodb://localhost:27017/dbname
API_KEY=your_api_key_here
DEBUG=false
PORT=3000
```

### 환경변수 체크리스트

| 환경변수 | 필수 | 기본값 | 설명 |
|----------|------|--------|------|
| `DATABASE_URL` | ✅ | - | MongoDB 연결 문자열 |
| `API_KEY` | ✅ | - | 외부 API 인증 키 |
| `DEBUG` | ❌ | `false` | 디버그 모드 활성화 |
| `PORT` | ❌ | `3000` | 서버 포트 |

### 보안 주의사항

- ⚠️ **절대 `.env` 파일을 Git에 커밋하지 마세요**
- ⚠️ **민감 정보는 로그에 출력하지 마세요**
- ✅ **`.gitignore`에 `.env`가 포함되어 있는지 확인**

---
```

---

## Language-Specific Templates

### Python Project Template
- Include `uv` or `poetry` usage
- Document virtual environment setup
- Show `pytest` configuration
- Mention type checking with `mypy`

### JavaScript/TypeScript Template
- Include `npm`/`yarn`/`pnpm` usage
- Document build scripts
- Show test runner (`jest`, `vitest`, etc.)
- Mention linting (`eslint`, `biome`)

### Rust Template
- Include `cargo` commands
- Document feature flags
- Show build profiles (debug/release)
- Mention clippy and formatting

---

## Minimal Template (New Projects)

**For quickly bootstrapping claude.md:**

```markdown
# {Project Name}

**{One-sentence description}**

## Directory Structure

```
{basic structure}
```

## Setup

```bash
{installation commands}
```

## Development

```bash
{how to run}
```

## Testing

```bash
{how to test}
```

---
```

**Expand this as the project grows.**
