# Documentation Checklist

Guidelines for reviewing documentation updates in code changes.

## When to Update Documentation

### README.md

Update when:
- ✅ Public API changed (new functions, changed signatures)
- ✅ Installation steps changed
- ✅ Configuration options added/changed
- ✅ Usage examples need update
- ✅ Dependencies added/removed
- ✅ New features added

Don't need to update for:
- ❌ Internal refactoring (no API changes)
- ❌ Bug fixes (unless behavior changes)
- ❌ Performance improvements (unless significant)

### CHANGELOG.md

Update for:
- ✅ All user-facing changes
- ✅ Bug fixes
- ✅ New features
- ✅ Breaking changes
- ✅ Deprecations
- ✅ Security fixes

Format:
```markdown
# Changelog

## [Unreleased]

### Added
- New feature X that does Y

### Changed
- Improved performance of Z by 50%

### Fixed
- Bug where A caused B (#123)

### Deprecated
- Function X will be removed in v2.0

### Security
- Fixed XSS vulnerability in input validation
```

### API Documentation

Update when:
- ✅ New endpoints added
- ✅ Request/response format changed
- ✅ Authentication requirements changed
- ✅ Rate limits changed
- ✅ Error codes added

## Docstring Standards

### Docstring Formats

Python supports three main formats:

1. **Google Style** (Recommended)
2. **NumPy Style**
3. **reStructuredText (reST)**

### Google Style Docstrings

```python
def calculate_total(items: List[float], tax_rate: float = 0.1, discount: float = 0) -> float:
    """Calculate total price with tax and discount.

    Calculates the sum of all items, applies discount, then adds tax.
    Discount is applied before tax calculation.

    Args:
        items: List of item prices
        tax_rate: Tax rate as decimal (default: 0.1 for 10%)
        discount: Discount amount in currency units (default: 0)

    Returns:
        Total price after discount and tax

    Raises:
        ValueError: If tax_rate is negative
        ValueError: If any item price is negative

    Examples:
        >>> calculate_total([10.0, 20.0, 30.0], tax_rate=0.1)
        66.0
        >>> calculate_total([10.0, 20.0], tax_rate=0.1, discount=5.0)
        27.5

    Note:
        Discount is subtracted from subtotal before tax calculation.
    """
    if tax_rate < 0:
        raise ValueError("Tax rate cannot be negative")
    if any(price < 0 for price in items):
        raise ValueError("Item prices cannot be negative")

    subtotal = sum(items)
    after_discount = subtotal - discount
    total = after_discount * (1 + tax_rate)
    return total
```

### Module Docstrings

```python
"""User management module.

This module provides functionality for user creation, validation,
and persistence. It includes the User model and UserService for
business logic.

Typical usage example:

    user_service = UserService(database)
    user = user_service.create_user("Alice", "alice@example.com")
    user_service.send_welcome_email(user)
"""

from typing import List
# ... rest of module
```

### Class Docstrings

```python
class UserService:
    """Service for managing user operations.

    Handles user creation, validation, and persistence. Integrates
    with database and email services.

    Attributes:
        database: Database connection for user persistence
        email_service: Service for sending user emails

    Example:
        >>> service = UserService(database, email_service)
        >>> user = service.create_user("Alice", "alice@example.com")
    """

    def __init__(self, database: Database, email_service: EmailService):
        """Initialize UserService.

        Args:
            database: Database connection
            email_service: Email service for notifications
        """
        self.database = database
        self.email_service = email_service
```

## Documentation Quality Checklist

### Completeness

- [ ] All public functions have docstrings
- [ ] All public classes have docstrings
- [ ] All public modules have docstrings
- [ ] Complex private functions have docstrings
- [ ] Type hints present and documented

### Accuracy

- [ ] Docstrings match actual function behavior
- [ ] Parameter descriptions match actual parameters
- [ ] Return value description matches actual return
- [ ] Examples actually work (can be executed)
- [ ] Edge cases documented

### Clarity

- [ ] Written in clear, simple language
- [ ] No jargon without explanation
- [ ] Examples provided for complex functions
- [ ] Common pitfalls mentioned
- [ ] Related functions cross-referenced

## Type Hints Documentation

### Basic Type Hints

```python
def greet(name: str) -> str:
    """Greet a person by name.

    Args:
        name: Person's name

    Returns:
        Greeting message
    """
    return f"Hello, {name}!"
```

### Complex Type Hints

```python
from typing import List, Dict, Optional, Union, Callable

def process_users(
    users: List[Dict[str, Union[str, int]]],
    filter_fn: Optional[Callable[[Dict], bool]] = None
) -> List[Dict[str, Union[str, int]]]:
    """Process and optionally filter users.

    Args:
        users: List of user dictionaries with string and int values
        filter_fn: Optional function to filter users. Should take
            a user dict and return True to include, False to exclude.

    Returns:
        Processed (and optionally filtered) list of users

    Example:
        >>> users = [{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}]
        >>> process_users(users, lambda u: u["age"] > 26)
        [{"name": "Alice", "age": 30}]
    """
    result = users.copy()
    if filter_fn:
        result = [u for u in result if filter_fn(u)]
    return result
```

## README.md Structure

### Essential Sections

```markdown
# Project Name

Brief one-line description

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

```bash
pip install package-name
```

## Quick Start

```python
from package import function

result = function("example")
print(result)
```

## Usage

### Basic Usage

Detailed explanation with examples

### Advanced Usage

More complex examples

## Configuration

Environment variables and config options

## API Reference

Link to full API documentation

## Contributing

Guidelines for contributors

## License

MIT License
```

### Good README Example

```markdown
# User Management API

RESTful API for user registration, authentication, and profile management.

## Features

- User registration with email verification
- JWT-based authentication
- Profile management (CRUD operations)
- Password reset functionality
- Role-based access control (RBAC)

## Installation

```bash
# Clone repository
git clone https://github.com/example/user-api.git
cd user-api

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Start server
python manage.py runserver
```

## Quick Start

```python
import requests

# Register new user
response = requests.post(
    "http://localhost:8000/api/users/register",
    json={"email": "user@example.com", "password": "secret123"}
)

# Login
auth_response = requests.post(
    "http://localhost:8000/api/users/login",
    json={"email": "user@example.com", "password": "secret123"}
)
token = auth_response.json()["token"]

# Get profile (authenticated)
profile = requests.get(
    "http://localhost:8000/api/users/me",
    headers={"Authorization": f"Bearer {token}"}
)
```

## Configuration

Create `.env` file:

```env
DATABASE_URL=postgresql://user:pass@localhost/dbname
SECRET_KEY=your-secret-key-here
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
```

## API Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/users/register` | Register new user | No |
| POST | `/api/users/login` | Login user | No |
| GET | `/api/users/me` | Get current user profile | Yes |
| PATCH | `/api/users/me` | Update profile | Yes |
| DELETE | `/api/users/me` | Delete account | Yes |

Full API documentation: [API Docs](docs/api.md)

## Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# View coverage report
open htmlcov/index.html
```

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

MIT License - see [LICENSE](LICENSE) file
```

## Code Comments Best Practices

### When to Write Comments

**Write comments for:**
- Complex algorithms
- Business logic that isn't obvious
- Workarounds for bugs in dependencies
- Performance optimizations
- Security considerations
- Regex patterns

**Don't write comments for:**
- Obvious code
- Redundant information
- Outdated information

### Good vs Bad Comments

```python
# ❌ Bad - states the obvious
# Increment counter by 1
counter += 1

# ✅ Good - explains why
# Increment retry counter to trigger exponential backoff
counter += 1

# ❌ Bad - redundant
# Check if user is active
if user.is_active:
    pass

# ✅ Good - self-explanatory code, no comment needed
if user.is_active:
    pass

# ✅ Good - explains non-obvious business rule
# Users must wait 24 hours between password changes
# to prevent rapid password cycling attacks
if user.last_password_change > datetime.now() - timedelta(hours=24):
    raise PasswordChangeTooSoonError()

# ✅ Good - documents workaround
# Workaround for bug in library v1.2.3 where connection
# isn't properly closed. Fixed in v1.3.0.
# TODO: Remove after upgrading to v1.3.0
connection.close()
connection = None
```

### TODO Comments

```python
# ✅ Good TODOs - actionable and tracked
# TODO(alice): Optimize query performance (JIRA-123)
# TODO: Add validation for negative numbers before v2.0 release
# TODO(bob): Handle timezone conversion (see issue #456)

# ❌ Bad TODOs - vague and untracked
# TODO: fix this
# TODO: make better
# TODO: refactor
```

## Documentation Review Checklist

When reviewing documentation in code changes:

### README.md
- [ ] Installation steps current
- [ ] Usage examples work
- [ ] New features documented
- [ ] Breaking changes highlighted
- [ ] Dependencies list updated

### CHANGELOG.md
- [ ] User-facing changes listed
- [ ] Breaking changes marked
- [ ] Version number correct
- [ ] Links to issues/PRs included

### Docstrings
- [ ] All public functions documented
- [ ] Parameters described
- [ ] Return values described
- [ ] Exceptions documented
- [ ] Examples provided for complex functions
- [ ] Type hints present

### Comments
- [ ] Comments explain "why" not "what"
- [ ] No outdated comments
- [ ] Complex logic explained
- [ ] TODOs are actionable and tracked

### API Documentation
- [ ] New endpoints documented
- [ ] Request/response formats shown
- [ ] Authentication requirements clear
- [ ] Error responses documented

## Anti-patterns to Flag

1. **Missing docstrings** for public API
2. **Outdated comments** that don't match code
3. **README not updated** when API changes
4. **No CHANGELOG entry** for user-facing changes
5. **Type hints missing** from function signatures
6. **Examples don't work** or are outdated
7. **Vague TODOs** without assignee or issue link
8. **Comments stating the obvious**
9. **Undocumented exceptions**
10. **Missing installation instructions** for new dependencies
