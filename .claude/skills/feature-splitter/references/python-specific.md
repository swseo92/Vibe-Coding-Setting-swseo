# Feature Splitter: Python-Specific Reference

> **NOTE**: This is an **optional reference** for Python projects.
> The core feature-splitter skill is language-agnostic and works without this.
> Use this only if you want Python/Django/FastAPI-specific guidance.
> Similar guides can be created for other languages (JavaScript, Java, Go, etc.).

---

## Purpose

This document provides Python-specific:
- Framework detection heuristics (Django, FastAPI)
- Code patterns that indicate split points
- Language-specific decomposition tips
- References to Python templates

**The Agent can figure this out automatically** - this just documents the patterns for reference.

---

## Framework Detection

### Django Detection

**Primary Signals:**

1. **File existence: `manage.py`**
   ```python
   if os.path.exists("manage.py"):
       framework = "django"
   ```

2. **Import patterns**
   ```python
   # Check any .py file for Django imports
   patterns = [
       r"from django\.",
       r"import django",
       r"from django import"
   ]
   ```

3. **Directory structure**
   ```
   ├── manage.py ✅
   ├── apps/
   │   └── myapp/
   │       ├── models.py ✅
   │       ├── views.py ✅
   │       └── migrations/ ✅
   ├── settings.py or settings/ ✅
   └── wsgi.py
   ```

**Confirmation Score:**
- `manage.py` exists: +50 points
- Django imports found: +30 points
- `apps/*/migrations/` exists: +20 points
- **Threshold**: 50+ points → Django confirmed

### FastAPI Detection

**Primary Signals:**

1. **Import patterns**
   ```python
   patterns = [
       r"from fastapi import",
       r"import fastapi"
   ]
   ```

2. **File existence: `main.py`** (common convention)
   ```python
   if os.path.exists("main.py"):
       score += 20
   ```

3. **Directory structure**
   ```
   ├── main.py ✅
   ├── routers/
   │   ├── auth.py ✅
   │   └── users.py ✅
   ├── schemas/
   │   └── user.py ✅
   ├── dependencies.py ✅
   ├── database.py ✅
   └── alembic/ ✅
   ```

**Confirmation Score:**
- FastAPI imports found: +50 points
- `routers/` directory exists: +20 points
- `schemas/` or `dependencies.py`: +20 points
- `alembic/` (Alembic migrations): +10 points
- **Threshold**: 50+ points → FastAPI confirmed

### Flask Detection (Future)

**Signals:**
- Import: `from flask import`
- File: `app.py` or `wsgi.py`
- Blueprints: `blueprints/` directory

---

## Django Split Signals

### App Boundaries

**Natural Split:** Each Django app is a potential subtask boundary

**Detection:**
```python
apps = glob.glob("apps/*/")
# or
apps = glob.glob("*/apps.py")
```

**Example:**
```
apps/
├── auth/       → oauth-auth subtask
├── users/      → user-profile subtask
├── products/   → product-crud subtask
```

### Model Layer

**Files:** `models.py`, `apps/*/models.py`

**Indicators:**
- New model class → Separate subtask
- Model modification → May require migration subtask

**Example:**
```python
# apps/oauth/models.py

class OAuthToken(models.Model):  # New model → oauth-schema subtask
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    provider = models.CharField(max_length=50)
    access_token = models.TextField()
    ...
```

**Split Rule:**
- Each new model or significant model change → Dedicated subtask
- Group related models (e.g., `OAuthToken` + `OAuthState` → same subtask)

### Admin Layer

**Files:** `admin.py`, `apps/*/admin.py`

**Indicators:**
- Admin registration for new models

**Example:**
```python
# apps/oauth/admin.py

@admin.register(OAuthToken)  # Admin for oauth models → oauth-admin subtask
class OAuthTokenAdmin(admin.ModelAdmin):
    ...
```

**Split Rule:**
- Pair with model subtask OR separate if substantial customization

### Serializer Layer (DRF)

**Files:** `serializers.py`, `apps/*/serializers.py`

**Indicators:**
- DRF serializers for API endpoints

**Example:**
```python
# apps/oauth/serializers.py

class OAuthTokenSerializer(serializers.ModelSerializer):  # API serialization → oauth-api subtask
    ...
```

**Split Rule:**
- Pair with views OR separate if complex serialization logic

### View Layer

**Files:** `views.py`, `viewsets.py`, `apps/*/views.py`

**Indicators:**
- New views/viewsets for endpoints

**Example:**
```python
# apps/oauth/views.py

class OAuthLoginView(APIView):  # API endpoint → oauth-endpoints subtask
    def get(self, request):
        ...
```

**Split Rule:**
- Group related endpoints (login + callback → same subtask)
- Separate if >3-4 complex endpoints

### URL Configuration

**Files:** `urls.py`, `apps/*/urls.py`

**Indicators:**
- New URL patterns

**Example:**
```python
# apps/oauth/urls.py

urlpatterns = [
    path('oauth/login/', OAuthLoginView.as_view()),  # Routing → oauth-endpoints subtask
    path('oauth/callback/', OAuthCallbackView.as_view()),
]
```

**Split Rule:**
- Always pair with corresponding views

### Migration Layer

**Files:** `apps/*/migrations/*.py`

**Indicators:**
- New migration files

**Example:**
```
apps/oauth/migrations/
├── 0001_initial.py  # New migration → oauth-schema subtask
└── 0002_oauth_provider.py
```

**Split Rule:**
- Schema migrations → Always separate subtask
- Data migrations → May pair with schema OR separate if complex

### Signals & Middleware

**Files:** `signals.py`, `middleware.py`

**Indicators:**
- Django signals (post_save, pre_delete)
- Custom middleware

**Example:**
```python
# apps/oauth/signals.py

@receiver(post_save, sender=User)  # Side effects → oauth-integration subtask
def create_oauth_profile(sender, instance, created, **kwargs):
    ...
```

**Split Rule:**
- Pair with related feature OR separate if complex orchestration

### Templates & Static

**Files:** `templates/`, `static/`

**Indicators:**
- Frontend assets

**Split Rule:**
- Usually pair with views
- Separate if substantial frontend work (React, Vue embedded)

---

## FastAPI Split Signals

### Router Layer

**Files:** `routers/*.py`

**Natural Split:** Each router file is a potential subtask

**Example:**
```
routers/
├── auth.py      → oauth-endpoints subtask
├── users.py     → user-crud subtask
├── products.py  → product-api subtask
```

**Detection:**
```python
routers = glob.glob("routers/*.py")
```

### Schema Layer (Pydantic)

**Files:** `schemas/*.py`, `models/*.py` (Pydantic models)

**Indicators:**
- Pydantic model definitions

**Example:**
```python
# schemas/oauth.py

class OAuthTokenResponse(BaseModel):  # API schema → oauth-schemas subtask
    access_token: str
    token_type: str
    expires_in: int
```

**Split Rule:**
- Pair with routers OR separate if complex validation logic

### Dependency Injection

**Files:** `dependencies.py`, `deps.py`

**Indicators:**
- FastAPI dependency functions

**Example:**
```python
# dependencies.py

def get_current_user(token: str = Depends(oauth2_scheme)):  # Auth dependency → oauth-middleware subtask
    ...
```

**Split Rule:**
- Separate if substantial auth/validation logic
- Pair with routers if simple

### Service Layer

**Files:** `services/*.py`, `business_logic/*.py`

**Indicators:**
- Business logic separation

**Example:**
```python
# services/oauth_provider.py

class OAuthProviderService:  # External integration → oauth-provider subtask
    async def exchange_code_for_token(self, code: str):
        ...
```

**Split Rule:**
- Each complex service → Separate subtask
- Simple utilities → Pair with router

### Database Layer

**Files:** `database.py`, `models/*.py` (SQLAlchemy)

**Indicators:**
- SQLAlchemy model definitions

**Example:**
```python
# models/oauth.py

class OAuthToken(Base):  # DB model → oauth-schema subtask
    __tablename__ = "oauth_tokens"
    ...
```

**Split Rule:**
- Schema definitions → Separate subtask
- Database connection config → Pair with schema

### Background Tasks

**Files:** `tasks.py`, `workers/*.py`, `celery_app.py`

**Indicators:**
- Celery tasks, BackgroundTasks

**Example:**
```python
# tasks.py

@celery_app.task
def refresh_oauth_tokens():  # Background job → oauth-refresh subtask
    ...
```

**Split Rule:**
- Complex background processing → Separate subtask
- Simple async tasks → Pair with related feature

### Alembic Migrations

**Files:** `alembic/versions/*.py`

**Indicators:**
- Migration files

**Example:**
```
alembic/versions/
├── 2025_01_27_add_oauth_tokens.py  # Migration → oauth-schema subtask
```

**Split Rule:**
- Same as Django migrations

---

## Shared Python Signals

### Test Structure

**Files:** `tests/`, `test_*.py`

**Indicators:**
- Test organization

**Django:**
```
tests/
├── unit/
│   ├── test_oauth_models.py  # Unit tests → oauth-schema subtask
│   └── test_oauth_views.py   # API tests → oauth-endpoints subtask
└── integration/
    └── test_oauth_flow.py     # E2E tests → oauth-tests subtask
```

**FastAPI:**
```
tests/
├── test_auth_router.py        # Router tests → oauth-endpoints subtask
├── test_oauth_service.py      # Service tests → oauth-provider subtask
└── test_integration.py        # E2E tests → oauth-tests subtask
```

**Split Rule:**
- Unit tests pair with implementation
- Integration/E2E tests → Separate subtask after API stabilizes

### Pytest Fixtures

**Files:** `conftest.py`, `tests/conftest.py`

**Indicators:**
- Shared test fixtures

**Example:**
```python
# conftest.py

@pytest.fixture
def oauth_client():  # Test fixture → oauth-tests subtask (or pair)
    ...
```

**Split Rule:**
- Simple fixtures → Pair with tests
- Complex test infrastructure → Separate subtask

### Configuration

**Files:** `config.py`, `settings.py`, `.env`, `.env.example`

**Indicators:**
- Environment configuration

**Example:**
```python
# config.py

class Settings(BaseSettings):
    OAUTH_CLIENT_ID: str  # Config vars → oauth-config subtask
    OAUTH_CLIENT_SECRET: str
```

**Split Rule:**
- Configuration changes → Often pair with feature implementation
- Separate if substantial env restructuring

### Dependencies

**Files:** `pyproject.toml`, `requirements.txt`

**Indicators:**
- Package additions

**Example:**
```toml
# pyproject.toml

[tool.poetry.dependencies]
authlib = "^1.2.0"  # New dependency → oauth-provider subtask (pair)
```

**Split Rule:**
- Always pair with subtask requiring the dependency
- Don't create dedicated subtask for dependency management

---

## Detection Algorithm

### Step 1: Framework Detection

```python
def detect_framework():
    frameworks = {
        "django": 0,
        "fastapi": 0,
        "flask": 0
    }

    # Django signals
    if os.path.exists("manage.py"):
        frameworks["django"] += 50

    # FastAPI signals
    if has_import_pattern(r"from fastapi import"):
        frameworks["fastapi"] += 50

    # Additional signals...

    detected = max(frameworks, key=frameworks.get)
    confidence = frameworks[detected]

    if confidence >= 50:
        return detected
    else:
        return "unknown"
```

### Step 2: Component Inventory

```python
def inventory_components(framework):
    if framework == "django":
        return {
            "apps": find_django_apps(),
            "models": glob.glob("**/models.py"),
            "views": glob.glob("**/views.py"),
            "serializers": glob.glob("**/serializers.py"),
            "urls": glob.glob("**/urls.py"),
            "migrations": glob.glob("**/migrations/*.py"),
            "admin": glob.glob("**/admin.py"),
            "tests": glob.glob("tests/**/*.py")
        }

    elif framework == "fastapi":
        return {
            "routers": glob.glob("routers/*.py"),
            "schemas": glob.glob("schemas/*.py"),
            "dependencies": glob.glob("dependencies.py"),
            "services": glob.glob("services/*.py"),
            "models": glob.glob("models/*.py"),
            "migrations": glob.glob("alembic/versions/*.py"),
            "tests": glob.glob("tests/**/*.py")
        }
```

### Step 3: Split Point Identification

```python
def identify_split_points(components, goal):
    split_points = []

    if "authentication" in goal.lower():
        if framework == "django":
            split_points.extend([
                {"layer": "models", "files": ["apps/oauth/models.py"]},
                {"layer": "serializers", "files": ["apps/oauth/serializers.py"]},
                {"layer": "views", "files": ["apps/oauth/views.py"]},
                {"layer": "urls", "files": ["apps/oauth/urls.py"]},
            ])
        elif framework == "fastapi":
            split_points.extend([
                {"layer": "models", "files": ["models/oauth.py"]},
                {"layer": "schemas", "files": ["schemas/oauth.py"]},
                {"layer": "routers", "files": ["routers/auth.py"]},
                {"layer": "services", "files": ["services/oauth_provider.py"]},
            ])

    return split_points
```

### Step 4: Subtask Generation

```python
def generate_subtasks(split_points):
    subtasks = []

    for point in split_points:
        subtask = {
            "name": f"oauth-{point['layer']}",
            "files": point["files"],
            "description": f"Implement OAuth {point['layer']} layer"
        }
        subtasks.append(subtask)

    return subtasks
```

---

## Common Patterns

### Pattern 1: CRUD Resource (Django)

**Goal:** "Add product management"

**Split Points:**
```
1. product-models     (models.py)
2. product-admin      (admin.py)
3. product-serializers (serializers.py)
4. product-views      (views.py, viewsets.py)
5. product-urls       (urls.py)
6. product-tests      (tests/)
```

**Dependency:**
```
models → admin, serializers
serializers → views
views → urls
all → tests
```

### Pattern 2: Background Jobs (FastAPI)

**Goal:** "Add email sending background job"

**Split Points:**
```
1. email-config       (config.py - SMTP settings)
2. email-service      (services/email.py)
3. email-tasks        (tasks.py - Celery)
4. email-endpoints    (routers/email.py - trigger)
5. email-tests        (tests/test_email.py)
```

**Dependency:**
```
config → service
service → tasks
tasks → endpoints
all → tests
```

### Pattern 3: Third-Party Integration

**Goal:** "Integrate Stripe payments"

**Split Points:**
```
1. stripe-config      (API keys, .env)
2. stripe-models      (Payment, Invoice models)
3. stripe-service     (Stripe API wrapper)
4. stripe-webhooks    (Webhook endpoints)
5. stripe-checkout    (Checkout flow)
6. stripe-tests       (Mock Stripe calls)
```

**Dependency:**
```
config → models, service
models → service
service → webhooks, checkout
all → tests
```

---

## Best Practices

### Do's ✅

1. **Leverage Framework Conventions**: Follow Django apps or FastAPI routers
2. **Detect Automatically**: Use file patterns and imports for detection
3. **Respect Boundaries**: Don't cross architectural layers in single subtask
4. **Test Separately**: E2E tests after API stabilizes
5. **Config First**: Configuration changes before implementation

### Don'ts ❌

1. **Don't Ignore Framework**: Respect Django/FastAPI idioms
2. **Don't Mix Layers**: Keep models separate from views
3. **Don't Skip Migrations**: Always isolate schema changes
4. **Don't Bundle Tests**: Unit tests with code, E2E tests separate
5. **Don't Assume**: Confirm framework detection with user

---

## Python Feature Templates

Pre-made decomposition templates for common Python feature patterns are available in `assets/templates/python/`:

1. **`auth-feature.md`** - OAuth, JWT, Sessions authentication
2. **`crud-resource.md`** - CRUD operations for resources
3. **`background-jobs.md`** - Celery, arq task processing
4. **`api-integration.md`** - Stripe, Twilio, third-party APIs
5. **`db-migration.md`** - Schema and data migrations
6. **`search-feature.md`** - ElasticSearch, PostgreSQL FTS

**These are examples, not requirements.** The Agent can propose custom splits based on your actual codebase.

---

**Document Version**: 2.0.0 (Optional Reference)
**Last Updated**: 2025-11-01
**Status**: Optional Reference for Python Projects
