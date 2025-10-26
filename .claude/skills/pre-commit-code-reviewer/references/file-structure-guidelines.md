# Python File & Folder Structure Guidelines

Best practices for organizing Python projects.

## Standard Python Project Structure

### Small to Medium Projects

```
my-project/
├── README.md
├── LICENSE
├── .gitignore
├── pyproject.toml          # Project metadata and dependencies (PEP 518)
├── setup.py                # (Optional) for backward compatibility
├── requirements.txt        # Or use pyproject.toml
├── src/
│   └── myproject/          # Package name
│       ├── __init__.py
│       ├── main.py         # Entry point
│       ├── config.py       # Configuration
│       ├── models/
│       │   ├── __init__.py
│       │   └── user.py
│       ├── services/
│       │   ├── __init__.py
│       │   └── user_service.py
│       └── utils/
│           ├── __init__.py
│           └── helpers.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py         # pytest fixtures
│   ├── test_models/
│   │   └── test_user.py
│   └── test_services/
│       └── test_user_service.py
├── docs/
│   └── api.md
└── scripts/
    └── deploy.sh
```

### Large Projects (Application Structure)

```
my-app/
├── README.md
├── pyproject.toml
├── src/
│   └── myapp/
│       ├── __init__.py
│       ├── main.py
│       ├── api/                # API layer
│       │   ├── __init__.py
│       │   ├── routes/
│       │   │   ├── __init__.py
│       │   │   ├── users.py
│       │   │   └── products.py
│       │   └── middleware.py
│       ├── core/               # Core business logic
│       │   ├── __init__.py
│       │   ├── models/
│       │   ├── services/
│       │   └── repositories/
│       ├── db/                 # Database layer
│       │   ├── __init__.py
│       │   ├── migrations/
│       │   └── session.py
│       ├── config/             # Configuration
│       │   ├── __init__.py
│       │   ├── settings.py
│       │   └── logging.py
│       └── utils/              # Utilities
│           ├── __init__.py
│           └── validators.py
├── tests/
├── docs/
└── scripts/
```

## Module Naming Conventions

### Files and Directories

```python
# ✅ Good - lowercase with underscores
user_service.py
data_processor.py
api_client.py

# ❌ Bad - mixed case or hyphens
UserService.py
dataProcessor.py
api-client.py  # Hyphens don't work in imports
```

### Package Names

```python
# ✅ Good - short, lowercase, no underscores if possible
myapp/
utils/
models/

# ⚠️ Acceptable - underscores for clarity
user_management/
data_processing/

# ❌ Bad - mixed case
MyApp/
UserManagement/
```

## Import Organization

### Import Order (PEP 8)

```python
# 1. Standard library imports
import os
import sys
from datetime import datetime

# 2. Third-party imports
import numpy as np
import requests
from flask import Flask, request

# 3. Local imports
from myapp.models import User
from myapp.services import UserService
from . import utils
```

### Import Styles

```python
# ✅ Good - explicit imports
from myapp.models import User, Product
from myapp.services import UserService

# ✅ Good - module import for many items
from myapp import models
user = models.User()

# ❌ Bad - wildcard imports
from myapp.models import *  # Pollutes namespace

# ❌ Bad - importing modules you don't use
import numpy as np  # But never using np
```

### Relative vs Absolute Imports

```python
# Within src/myapp/services/user_service.py

# ✅ Good - absolute import (preferred)
from myapp.models.user import User
from myapp.repositories.user_repository import UserRepository

# ✅ Acceptable - relative import (for related modules)
from ..models.user import User
from ..repositories.user_repository import UserRepository

# ❌ Bad - mixing both unnecessarily
from myapp.models.user import User
from ..repositories.user_repository import UserRepository
```

## __init__.py Usage

### Empty __init__.py

```python
# src/myapp/__init__.py
# Can be empty - just marks directory as package
```

### Importing for Convenience

```python
# src/myapp/models/__init__.py
"""Models package."""

from .user import User
from .product import Product
from .order import Order

__all__ = ["User", "Product", "Order"]
```

```python
# Now users can import like this:
from myapp.models import User, Product

# Instead of:
from myapp.models.user import User
from myapp.models.product import Product
```

### Package Initialization

```python
# src/myapp/__init__.py
"""My application package."""

from .config import load_config

# Initialize package-level state
config = load_config()

__version__ = "1.0.0"
```

## Circular Dependency Prevention

### Problem: Circular Imports

```python
# ❌ Bad - circular dependency

# models/user.py
from myapp.services.user_service import UserService

class User:
    def save(self):
        UserService().save(self)

# services/user_service.py
from myapp.models.user import User

class UserService:
    def save(self, user: User):
        database.save(user)

# Causes ImportError!
```

### Solution 1: Dependency Injection

```python
# ✅ Good - dependency injection

# models/user.py
class User:
    def save(self, service):  # Inject service
        service.save(self)

# services/user_service.py
from myapp.models.user import User

class UserService:
    def save(self, user: User):
        database.save(user)

# Usage
service = UserService()
user = User()
user.save(service)
```

### Solution 2: Import at Function Level

```python
# ✅ Good - local import

# models/user.py
class User:
    def save(self):
        # Import only when needed
        from myapp.services.user_service import UserService
        UserService().save(self)
```

### Solution 3: Refactor to Remove Circular Dependency

```python
# ✅ Best - proper separation of concerns

# models/user.py
class User:
    """User model - data only."""
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email

# services/user_service.py
from myapp.models.user import User
from myapp.repositories.user_repository import UserRepository

class UserService:
    def __init__(self, repository: UserRepository):
        self.repository = repository

    def save(self, user: User):
        self.repository.save(user)

# No circular dependency!
```

## Layered Architecture

### Clean Separation of Concerns

```
api/          # HTTP layer - routes, request/response handling
  └── routes/
core/         # Business logic - services, domain models
  ├── models/
  ├── services/
  └── repositories/  # Data access interface
db/           # Database layer - actual DB operations
  └── implementations/
```

### Dependency Direction

```
API Layer → Service Layer → Repository Layer → Database Layer
  ↓             ↓                 ↓                ↓
 Routes    Business Logic    Data Access      Actual DB
```

**Rule**: Higher layers can depend on lower layers, never reverse.

## File Size Guidelines

### Keep Files Focused

```python
# ✅ Good - focused file
# user_service.py - ~200 lines
class UserService:
    # All user-related business logic

# ❌ Bad - God file
# services.py - 2000+ lines
class UserService:
    pass
class ProductService:
    pass
class OrderService:
    pass
# ... 20 more classes
```

### When to Split Files

Split when file exceeds:
- **300 lines** - Consider splitting
- **500 lines** - Should definitely split
- **1000+ lines** - Urgent refactoring needed

Split strategies:
```
# Before: large services.py
services.py

# After: split by domain
services/
├── __init__.py
├── user_service.py
├── product_service.py
└── order_service.py
```

## Configuration Files

### Environment-Specific Config

```
config/
├── __init__.py
├── base.py          # Shared config
├── development.py   # Dev-specific
├── production.py    # Prod-specific
└── test.py          # Test-specific
```

```python
# config/base.py
class BaseConfig:
    DEBUG = False
    TESTING = False
    DATABASE_URI = "sqlite:///app.db"

# config/development.py
from .base import BaseConfig

class DevelopmentConfig(BaseConfig):
    DEBUG = True
    DATABASE_URI = "sqlite:///dev.db"

# config/production.py
from .base import BaseConfig

class ProductionConfig(BaseConfig):
    DATABASE_URI = os.getenv("DATABASE_URL")
```

## Tests Mirror Source Structure

```
src/myapp/
├── models/
│   ├── user.py
│   └── product.py
└── services/
    ├── user_service.py
    └── product_service.py

tests/
├── test_models/
│   ├── test_user.py          # Mirrors src/myapp/models/user.py
│   └── test_product.py
└── test_services/
    ├── test_user_service.py
    └── test_product_service.py
```

## File Structure Review Checklist

### Project Root
- [ ] README.md exists and is current
- [ ] pyproject.toml or requirements.txt present
- [ ] .gitignore includes Python artifacts (__pycache__, *.pyc, .env)
- [ ] LICENSE file present
- [ ] Tests directory mirrors source structure

### Source Code Organization
- [ ] Code in src/ directory (not root)
- [ ] Package name matches project name
- [ ] All packages have __init__.py
- [ ] Modules named with lowercase_underscores
- [ ] No single file >500 lines
- [ ] Related functionality grouped together

### Import Structure
- [ ] Imports organized (stdlib → third-party → local)
- [ ] No wildcard imports (from x import *)
- [ ] No unused imports
- [ ] No circular dependencies
- [ ] Consistent use of absolute/relative imports

### Layer Separation
- [ ] Clear separation: API → Service → Repository → DB
- [ ] Dependencies flow in one direction (top to bottom)
- [ ] No business logic in API layer
- [ ] No database code in service layer

### File Placement
- [ ] Configuration in config/ or separate file
- [ ] Utilities in utils/ for general-purpose functions
- [ ] Tests in tests/ directory
- [ ] Documentation in docs/ directory
- [ ] Scripts in scripts/ directory

## Common Anti-patterns to Flag

### 1. Flat Structure for Large Projects

```
# ❌ Bad - everything in one directory
myapp/
├── __init__.py
├── user.py
├── product.py
├── order.py
├── user_service.py
├── product_service.py
├── order_service.py
├── user_repository.py
├── ... (50 more files)
```

### 2. Circular Imports

```python
# ❌ Bad - A imports B, B imports A
# file_a.py
from file_b import B

# file_b.py
from file_a import A
```

### 3. Mixed Concerns in Single File

```python
# ❌ Bad - API routes + business logic + database code in one file
# app.py - 1000 lines
@app.route('/users')
def get_users():
    # Database code
    conn = sqlite3.connect("db.sqlite")
    users = conn.execute("SELECT * FROM users").fetchall()

    # Business logic
    for user in users:
        user['active'] = check_active_status(user)

    return jsonify(users)
```

### 4. Overly Deep Nesting

```
# ❌ Bad - too many levels
myapp/layer1/layer2/layer3/layer4/layer5/user.py
```

### 5. Inconsistent Naming

```
# ❌ Bad - mixed naming conventions
MyApp/
├── UserService.py
├── product-model.py
├── Order_Repository.py
```

## Refactoring Tips

### Extract Related Classes to Module

```python
# Before: models.py (500 lines)
class User: pass
class Product: pass
class Order: pass

# After: models/
models/
├── __init__.py
├── user.py
├── product.py
└── order.py
```

### Split by Feature vs Layer

```python
# Layer-based (traditional)
myapp/
├── models/
│   ├── user.py
│   ├── product.py
│   └── order.py
├── services/
│   ├── user_service.py
│   ├── product_service.py
│   └── order_service.py

# Feature-based (alternative for large apps)
myapp/
├── users/
│   ├── models.py
│   ├── services.py
│   └── routes.py
├── products/
│   ├── models.py
│   ├── services.py
│   └── routes.py
```

Choose based on:
- **Layer-based**: Small to medium projects, clear separation
- **Feature-based**: Large projects with distinct features
