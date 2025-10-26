# Testing Checklist

Best practices for writing and reviewing tests in Python.

## Test Coverage Guidelines

### Minimum Coverage Standards

- **Overall**: 80%+ code coverage
- **Critical paths**: 100% coverage (authentication, payment, data loss prevention)
- **New code**: 90%+ coverage
- **Bug fixes**: Include regression test

### Coverage Tools

```bash
# Install
pip install pytest pytest-cov

# Run with coverage
pytest --cov=src --cov-report=html

# View uncovered lines
pytest --cov=src --cov-report=term-missing
```

## Test Structure: AAA Pattern

**Arrange → Act → Assert**

```python
def test_user_creation():
    # Arrange - Set up test data
    name = "Alice"
    email = "alice@example.com"

    # Act - Execute the code being tested
    user = create_user(name, email)

    # Assert - Verify the results
    assert user.name == name
    assert user.email == email
    assert user.id is not None
```

## Test Naming Conventions

**Format**: `test_<function_name>_<scenario>_<expected_outcome>`

```python
# ✅ Good names - clear intent
def test_calculate_total_with_discount_returns_reduced_price():
    pass

def test_validate_email_with_invalid_format_raises_value_error():
    pass

def test_get_user_when_not_found_returns_none():
    pass

# ❌ Bad names - unclear
def test_user():
    pass

def test_calculation():
    pass

def test_1():
    pass
```

## Types of Tests

### 1. Unit Tests

**Test individual functions/methods in isolation.**

```python
def test_calculate_discount():
    # Test pure logic
    price = 100.0
    discount_percent = 20

    result = calculate_discount(price, discount_percent)

    assert result == 80.0
```

### 2. Integration Tests

**Test multiple components working together.**

```python
def test_user_registration_flow():
    # Tests UserService + Database + EmailService
    user_data = {"name": "Alice", "email": "alice@example.com"}

    user = user_service.register(user_data)

    # Verify user saved to database
    saved_user = database.get_user(user.id)
    assert saved_user.email == user_data["email"]

    # Verify welcome email sent
    assert len(email_service.sent_emails) == 1
    assert email_service.sent_emails[0]["to"] == user_data["email"]
```

### 3. Edge Case Tests

**Test boundaries and corner cases.**

```python
def test_divide_by_zero_raises_exception():
    with pytest.raises(ZeroDivisionError):
        divide(10, 0)

def test_empty_list_returns_none():
    result = find_max([])
    assert result is None

def test_very_large_number_handling():
    result = calculate(10**100)
    assert isinstance(result, int)
```

## Mocking and Stubbing

### When to Mock

- External APIs
- Database calls
- File I/O
- Time-dependent code
- Randomness

### Using unittest.mock

```python
from unittest.mock import Mock, patch, MagicMock

# Mock function calls
def test_send_email_calls_smtp():
    with patch('myapp.smtp.send') as mock_send:
        send_email("user@example.com", "Subject", "Body")

        mock_send.assert_called_once_with(
            to="user@example.com",
            subject="Subject",
            body="Body"
        )

# Mock return values
def test_get_user_from_api():
    with patch('myapp.api.fetch_user') as mock_fetch:
        mock_fetch.return_value = {"id": 1, "name": "Alice"}

        user = get_user_from_api(1)

        assert user["name"] == "Alice"

# Mock side effects
def test_retry_on_network_error():
    with patch('myapp.api.call') as mock_call:
        mock_call.side_effect = [NetworkError(), NetworkError(), {"status": "ok"}]

        result = retry_api_call()

        assert result == {"status": "ok"}
        assert mock_call.call_count == 3
```

### Mocking Best Practices

```python
# ✅ Good - mock at the right level
@patch('myapp.services.database.get_user')
def test_user_service(mock_get_user):
    mock_get_user.return_value = User(id=1, name="Alice")
    # ...

# ❌ Bad - mocking too much
@patch('myapp.services.UserService')
@patch('myapp.database.Database')
@patch('myapp.email.EmailService')
def test_something(mock_email, mock_db, mock_service):
    # Test becomes meaningless
    pass
```

## Fixtures (pytest)

### Reusable Test Data

```python
import pytest

@pytest.fixture
def sample_user():
    """Create a sample user for testing."""
    return User(id=1, name="Alice", email="alice@example.com")

@pytest.fixture
def database_session():
    """Provide database session for testing."""
    db = Database()
    db.connect()
    yield db
    db.rollback()  # Clean up
    db.close()

def test_save_user(sample_user, database_session):
    database_session.save(sample_user)
    saved = database_session.get_user(sample_user.id)
    assert saved.name == sample_user.name
```

### Fixture Scopes

```python
@pytest.fixture(scope="function")  # Default - runs for each test
def temp_file():
    file = create_temp_file()
    yield file
    delete_temp_file(file)

@pytest.fixture(scope="module")  # Runs once per module
def database():
    db = setup_database()
    yield db
    teardown_database(db)

@pytest.fixture(scope="session")  # Runs once per test session
def app_config():
    return load_config()
```

## Parameterized Tests

```python
import pytest

@pytest.mark.parametrize("input,expected", [
    (0, "zero"),
    (1, "positive"),
    (-1, "negative"),
    (100, "positive"),
])
def test_number_classification(input, expected):
    result = classify_number(input)
    assert result == expected
```

## Test Organization

### Directory Structure

```
project/
├── src/
│   └── myapp/
│       ├── __init__.py
│       ├── user.py
│       └── payment.py
└── tests/
    ├── __init__.py
    ├── test_user.py
    └── test_payment.py
```

### File Naming

- Test files: `test_<module>.py`
- Test classes: `Test<ClassName>`
- Test functions: `test_<function_name>_<scenario>`

```python
# tests/test_user.py
class TestUserValidation:
    def test_validate_email_with_valid_format_returns_true(self):
        pass

    def test_validate_email_with_invalid_format_returns_false(self):
        pass

def test_create_user_with_valid_data_returns_user_object():
    pass
```

## Common Testing Mistakes

### 1. Testing Implementation Instead of Behavior

```python
# ❌ Bad - tests implementation detail
def test_user_service_uses_database_query():
    service = UserService()
    with patch.object(service.database, 'query') as mock_query:
        service.get_user(1)
        assert mock_query.called

# ✅ Good - tests behavior
def test_get_user_returns_correct_user():
    user = user_service.get_user(1)
    assert user.id == 1
```

### 2. Test Dependencies

```python
# ❌ Bad - tests depend on each other
def test_create_user():
    global created_user
    created_user = create_user("Alice", "alice@example.com")

def test_update_user():
    # Depends on test_create_user running first
    updated = update_user(created_user, name="Bob")
    assert updated.name == "Bob"

# ✅ Good - independent tests
@pytest.fixture
def sample_user():
    return create_user("Alice", "alice@example.com")

def test_update_user(sample_user):
    updated = update_user(sample_user, name="Bob")
    assert updated.name == "Bob"
```

### 3. Too Many Assertions

```python
# ❌ Bad - too many things in one test
def test_user_creation():
    user = create_user("Alice", "alice@example.com")
    assert user.name == "Alice"
    assert user.email == "alice@example.com"
    assert user.is_active == True
    assert user.created_at is not None
    assert len(user.id) == 36
    # ... 10 more assertions

# ✅ Good - focused tests
def test_create_user_sets_name():
    user = create_user("Alice", "alice@example.com")
    assert user.name == "Alice"

def test_create_user_sets_email():
    user = create_user("Alice", "alice@example.com")
    assert user.email == "alice@example.com"

def test_create_user_activates_user_by_default():
    user = create_user("Alice", "alice@example.com")
    assert user.is_active == True
```

## Test Quality Indicators

### Good Tests Are:

1. **Fast** - Run in milliseconds
2. **Independent** - Can run in any order
3. **Repeatable** - Same result every time
4. **Self-validating** - Pass or fail, no manual checking
5. **Timely** - Written with or before production code

### Code Review Checklist

- [ ] **Coverage**: New code has 90%+ test coverage
- [ ] **Edge cases**: Boundary conditions tested
- [ ] **Error paths**: Exceptions and errors tested
- [ ] **Happy path**: Normal usage tested
- [ ] **Naming**: Test names clearly describe scenario
- [ ] **AAA pattern**: Tests follow Arrange-Act-Assert
- [ ] **Independence**: Tests don't depend on each other
- [ ] **Mocking**: External dependencies properly mocked
- [ ] **Assertions**: Each test has clear assertions
- [ ] **Fixtures**: Reusable test data in fixtures
- [ ] **Parameterization**: Similar tests parameterized
- [ ] **Speed**: Tests run quickly (<5 seconds total)

## When to Require Tests

### Always Require Tests For:

- New functions/methods
- Bug fixes (regression tests)
- Critical paths (authentication, payment)
- Public APIs
- Complex logic (loops, conditionals, algorithms)

### Tests May Be Optional For:

- Simple getters/setters
- Straightforward constructors
- Configuration files
- Scripts (if documented well)

## Example: Comprehensive Test Suite

```python
import pytest
from unittest.mock import Mock, patch
from myapp.user import User, UserService, InvalidEmailError

class TestUser:
    """Tests for User model."""

    def test_create_user_with_valid_data_succeeds(self):
        user = User(name="Alice", email="alice@example.com")
        assert user.name == "Alice"
        assert user.email == "alice@example.com"

    def test_user_email_is_lowercase(self):
        user = User(name="Alice", email="ALICE@EXAMPLE.COM")
        assert user.email == "alice@example.com"


class TestUserService:
    """Tests for UserService."""

    @pytest.fixture
    def mock_database(self):
        return Mock()

    @pytest.fixture
    def user_service(self, mock_database):
        return UserService(database=mock_database)

    def test_get_user_returns_user_from_database(self, user_service, mock_database):
        # Arrange
        mock_database.query.return_value = {"id": 1, "name": "Alice"}

        # Act
        user = user_service.get_user(1)

        # Assert
        assert user.name == "Alice"
        mock_database.query.assert_called_once_with("SELECT * FROM users WHERE id = ?", (1,))

    def test_get_user_when_not_found_returns_none(self, user_service, mock_database):
        mock_database.query.return_value = None
        user = user_service.get_user(999)
        assert user is None

    @pytest.mark.parametrize("email", [
        "invalid",
        "@example.com",
        "user@",
        "user @example.com",
    ])
    def test_validate_email_with_invalid_format_raises_error(self, user_service, email):
        with pytest.raises(InvalidEmailError):
            user_service.validate_email(email)

    def test_create_user_sends_welcome_email(self, user_service):
        with patch('myapp.email.send') as mock_send:
            user = user_service.create_user("Alice", "alice@example.com")

            mock_send.assert_called_once()
            assert mock_send.call_args[1]['to'] == "alice@example.com"
```

This comprehensive test suite demonstrates:
- Fixture usage
- Mocking external dependencies
- Parameterized tests
- Clear test naming
- AAA pattern
- Edge case coverage
