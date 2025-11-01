# Template: Authentication Feature

Pattern for adding authentication (OAuth, JWT, Sessions) to Python APIs.

---

## Canonical Subtasks

### 1. auth-schema (0.5-1d)
**Goal**: Database schema for auth tokens/sessions

**Files (Django)**:
- `apps/auth/models.py` - User, Token, Session models
- `apps/auth/migrations/XXX_auth.py` - Initial migration

**Files (FastAPI)**:
- `models/auth.py` - SQLAlchemy User, Token models
- `alembic/versions/XXX_auth.py` - Migration

**Tests**:
- `tests/models/test_auth.py` - Model validation

**Dependency**: None (foundation)

---

### 2. auth-config (0.5d)
**Goal**: Configure auth provider (OAuth credentials, JWT secrets)

**Files**:
- `config.py` or `settings.py` - Add auth settings
- `.env.example` - Document required env vars
- `.env` (local) - Add credentials

**Example Env Vars**:
```
JWT_SECRET_KEY=xxx
JWT_ALGORITHM=HS256
OAUTH_CLIENT_ID=xxx
OAUTH_CLIENT_SECRET=xxx
OAUTH_REDIRECT_URI=http://localhost:8000/auth/callback
```

**Dependency**: auth-schema (needs models)

---

### 3. auth-provider (1-2d)
**Goal**: Implement auth handshake logic (OAuth flow, JWT generation)

**Files (Django)**:
- `apps/auth/services.py` - OAuthProvider class
- `apps/auth/utils.py` - Token generation/validation

**Files (FastAPI)**:
- `services/oauth_provider.py` - OAuth handshake
- `services/jwt_handler.py` - JWT encode/decode

**Third-Party Libraries**:
- OAuth: `authlib`, `python-jose`
- JWT: `pyjwt`, `python-jose`

**Dependency**: auth-config

**Risk**: HIGH (third-party integration, security-critical)

---

### 4. auth-endpoints (1d)
**Goal**: API endpoints for login, callback, logout, refresh

**Files (Django)**:
- `apps/auth/views.py` - Login, callback, logout views
- `apps/auth/serializers.py` - Login request/response
- `apps/auth/urls.py` - URL patterns

**Files (FastAPI)**:
- `routers/auth.py` - Login, callback, logout routes
- `schemas/auth.py` - Pydantic request/response models

**Endpoints**:
- `POST /auth/login` - Initiate OAuth or JWT login
- `GET /auth/callback` - OAuth callback
- `POST /auth/refresh` - Refresh access token
- `POST /auth/logout` - Invalidate session

**Dependency**: auth-provider

---

### 5. auth-middleware (0.5-1d)
**Goal**: Protect routes with authentication

**Files (Django)**:
- `apps/auth/middleware.py` - Authentication middleware
- `apps/auth/decorators.py` - `@login_required`

**Files (FastAPI)**:
- `dependencies.py` - `get_current_user` dependency
- Update routers with `Depends(get_current_user)`

**Example (FastAPI)**:
```python
@router.get("/protected")
async def protected_route(user: User = Depends(get_current_user)):
    return {"message": f"Hello {user.username}"}
```

**Dependency**: auth-endpoints

---

### 6. auth-tests (1d)
**Goal**: E2E tests for complete auth flow

**Files**:
- `tests/integration/test_oauth_flow.py` - OAuth login → callback → protected endpoint
- `tests/integration/test_jwt_flow.py` - JWT login → refresh → logout

**Test Coverage**:
- Happy path (successful login)
- Invalid credentials
- Expired tokens
- Token refresh
- Logout invalidation

**Dependency**: auth-endpoints, auth-middleware

---

## Dependency Graph

```
1. auth-schema (DB models)
   ↓
2. auth-config (settings, env vars)
   ↓
3. auth-provider (OAuth/JWT logic)
   ↓
4. auth-endpoints (API routes)
   ↓
5. auth-middleware (protect routes)
   ↓
6. auth-tests (E2E validation)
```

**Parallel Opportunities**:
- After `auth-provider`: Can parallelize `auth-endpoints` and `auth-middleware`
- But sequential is safer for auth (high-risk)

---

## Merge Order

**Sequential (Recommended)**:
1. Merge `auth-schema` first (foundation)
2. Merge `auth-config` (configuration)
3. Merge `auth-provider` (core logic) → Security review here
4. Merge `auth-endpoints` (API)
5. Merge `auth-middleware` (protection)
6. Merge `auth-tests` (validation)

**Parallel (Advanced)**:
- Steps 1-3 sequential (critical path)
- Steps 4-5 parallel (if confident)
- Step 6 after 4-5 complete

---

## Common Pitfalls

### 1. Storing Passwords in Plaintext
**Problem**: Never store raw passwords

**Solution**:
- Django: Use `User.set_password()` (PBKDF2)
- FastAPI: Use `passlib` with bcrypt

### 2. Weak JWT Secrets
**Problem**: Short or predictable secrets

**Solution**:
```python
# Generate strong secret
import secrets
JWT_SECRET = secrets.token_urlsafe(64)
```

### 3. No Token Expiration
**Problem**: Tokens valid forever

**Solution**:
```python
# Set expiration
token_data = {
    "sub": user.id,
    "exp": datetime.utcnow() + timedelta(hours=1)  # 1 hour expiry
}
```

### 4. CORS Issues with OAuth
**Problem**: Callback blocked by CORS

**Solution** (FastAPI):
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Frontend URL
    allow_credentials=True,
)
```

### 5. Missing HTTPS in Production
**Problem**: Auth over HTTP

**Solution**:
- Enforce HTTPS in production
- Set `secure=True` for cookies
- Use HSTS headers

### 6. OAuth State Parameter Missing
**Problem**: CSRF vulnerability

**Solution**:
```python
# Generate random state
state = secrets.token_urlsafe(32)
# Store in session
# Validate on callback
```

---

## Security Checklist

Before merging auth changes:

- [ ] Passwords hashed (bcrypt, PBKDF2)
- [ ] JWT secret is strong (64+ chars)
- [ ] Tokens have expiration
- [ ] HTTPS enforced in production
- [ ] CORS configured correctly
- [ ] OAuth state parameter validated
- [ ] Rate limiting on login endpoint
- [ ] Account lockout after failed attempts
- [ ] Sensitive data not logged
- [ ] Security headers set (HSTS, CSP)

---

## Example Worktree Commands

```bash
# Foundation
/worktree-create feature/auth-schema
# Work on models, migration
# Merge when tests pass

# Configuration
/worktree-create feature/auth-config
# Add env vars, settings
# Merge

# Core logic (HIGH RISK - security review)
/worktree-create feature/auth-provider
# Implement OAuth/JWT logic
# Security review before merge
# Merge

# API endpoints
/worktree-create feature/auth-endpoints
# Add login, callback routes
# Merge

# Protection
/worktree-create feature/auth-middleware
# Add auth dependencies
# Merge

# Validation
/worktree-create feature/auth-tests
# E2E tests
# Merge
```

---

**Template Version**: 1.0.0
**Risk Level**: HIGH (security-critical)
**Typical Duration**: 4-6 days
**Recommended Approach**: Sequential merging for safety
