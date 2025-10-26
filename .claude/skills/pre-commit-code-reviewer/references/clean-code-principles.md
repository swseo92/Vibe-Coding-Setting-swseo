# Clean Code Principles

Based on "Clean Code" by Robert C. Martin (Uncle Bob) with Python-specific examples.

## Core Principles

### 1. Meaningful Names

Names should reveal intent and avoid disinformation.

**❌ Bad:**
```python
d = 86400  # seconds in a day
lst = []
tmp = get_user()
```

**✅ Good:**
```python
SECONDS_PER_DAY = 86400
active_users = []
current_user = get_user()
```

#### Naming Guidelines

- **Use pronounceable names**: `timestamp` not `ts`
- **Use searchable names**: `MAX_RETRY_COUNT` not `7`
- **Avoid mental mapping**: `user` not `u`
- **Class names**: Nouns (`User`, `AccountManager`)
- **Function names**: Verbs (`get_user`, `calculate_total`)
- **Boolean variables**: `is_active`, `has_permission`, `can_edit`

**Examples:**
```python
# ✅ Good boolean names
is_valid = validate_input(data)
has_admin_rights = check_permissions(user)
can_proceed = is_valid and has_admin_rights

# ❌ Bad boolean names
flag = validate_input(data)  # What does flag mean?
status = check_permissions(user)  # Boolean or string?
```

### 2. Functions Should Do One Thing

**Single Responsibility Principle applied to functions.**

**❌ Bad:**
```python
def process_user_and_send_email(user_id):
    # Fetch user
    user = database.get_user(user_id)

    # Validate user
    if not user.email:
        raise ValueError("No email")

    # Update user
    user.last_login = datetime.now()
    database.save(user)

    # Send email
    subject = "Welcome back!"
    body = f"Hello {user.name}"
    email.send(user.email, subject, body)

    # Log activity
    logger.info(f"Processed user {user_id}")

    return user
```

**✅ Good:**
```python
def process_user_login(user_id: int) -> User:
    """Handle user login process."""
    user = fetch_user(user_id)
    validate_user_email(user)
    update_last_login(user)
    send_welcome_email(user)
    log_user_activity(user_id, "login")
    return user

def fetch_user(user_id: int) -> User:
    """Retrieve user from database."""
    return database.get_user(user_id)

def validate_user_email(user: User) -> None:
    """Ensure user has valid email."""
    if not user.email:
        raise ValueError(f"User {user.id} has no email")

def update_last_login(user: User) -> None:
    """Update user's last login timestamp."""
    user.last_login = datetime.now()
    database.save(user)

def send_welcome_email(user: User) -> None:
    """Send welcome back email to user."""
    email.send(
        to=user.email,
        subject="Welcome back!",
        body=f"Hello {user.name}"
    )

def log_user_activity(user_id: int, action: str) -> None:
    """Log user activity."""
    logger.info(f"User {user_id}: {action}")
```

**Benefits:**
- Each function is testable independently
- Easy to understand at a glance
- Can reuse individual functions
- Changes localized to single function

### 3. Function Size

**Keep functions small - ideally <20 lines, max 50 lines.**

**Signs a function is too long:**
- Need to scroll to see entire function
- Multiple levels of abstraction mixed
- Hard to name the function
- Many local variables
- Difficult to unit test

**Refactoring strategy:**
```python
# ❌ Too long
def generate_report(data):
    # 100 lines of code...
    pass

# ✅ Extract smaller functions
def generate_report(data):
    validated_data = validate_report_data(data)
    formatted_data = format_report_data(validated_data)
    summary = calculate_summary_statistics(formatted_data)
    return create_report_document(formatted_data, summary)
```

### 4. Function Arguments

**Ideal: 0-2 arguments. Max: 3 arguments.**

**❌ Too many arguments:**
```python
def create_user(name, email, age, address, phone, role, department, manager):
    pass
```

**✅ Use dataclass or config object:**
```python
from dataclasses import dataclass

@dataclass
class UserData:
    name: str
    email: str
    age: int
    address: str
    phone: str
    role: str
    department: str
    manager_id: int

def create_user(user_data: UserData) -> User:
    """Create user from UserData object."""
    pass
```

**Avoid flag arguments:**
```python
# ❌ Bad
def render(include_header: bool):
    if include_header:
        render_with_header()
    else:
        render_without_header()

# ✅ Good
def render_with_header():
    pass

def render_without_header():
    pass
```

### 5. DRY - Don't Repeat Yourself

**Extract common patterns into reusable functions.**

**❌ Duplication:**
```python
# User validation
if not user.name or len(user.name) < 3:
    raise ValueError("Name too short")
if not user.email or '@' not in user.email:
    raise ValueError("Invalid email")

# Product validation
if not product.name or len(product.name) < 3:
    raise ValueError("Name too short")
if not product.sku or len(product.sku) != 10:
    raise ValueError("Invalid SKU")
```

**✅ Extracted:**
```python
def validate_name(name: str, min_length: int = 3) -> None:
    """Validate name meets minimum length."""
    if not name or len(name) < min_length:
        raise ValueError(f"Name must be at least {min_length} characters")

def validate_email(email: str) -> None:
    """Validate email format."""
    if not email or '@' not in email:
        raise ValueError("Invalid email format")

def validate_sku(sku: str, expected_length: int = 10) -> None:
    """Validate SKU format."""
    if not sku or len(sku) != expected_length:
        raise ValueError(f"SKU must be {expected_length} characters")

# Usage
validate_name(user.name)
validate_email(user.email)

validate_name(product.name)
validate_sku(product.sku)
```

### 6. KISS - Keep It Simple, Stupid

**Simplest solution is often the best.**

**❌ Over-engineered:**
```python
class AbstractUserFactoryBuilderInterface(ABC):
    @abstractmethod
    def create_builder(self):
        pass

class ConcreteUserFactoryBuilder(AbstractUserFactoryBuilderInterface):
    def create_builder(self):
        return UserBuilder()

class UserBuilder:
    def build(self):
        return User()

# Just to create a user!
factory = ConcreteUserFactoryBuilder()
builder = factory.create_builder()
user = builder.build()
```

**✅ Simple:**
```python
def create_user(name: str, email: str) -> User:
    """Create a new user."""
    return User(name=name, email=email)

user = create_user("Alice", "alice@example.com")
```

### 7. YAGNI - You Aren't Gonna Need It

**Don't implement features until they're actually needed.**

**❌ Premature abstraction:**
```python
class DatabaseAdapter(ABC):
    """Support future databases..."""
    @abstractmethod
    def connect(self): pass
    @abstractmethod
    def execute(self, query): pass

class MySQLAdapter(DatabaseAdapter):
    def connect(self): pass
    def execute(self, query): pass

# Only using MySQL, may never need other databases
```

**✅ Implement when needed:**
```python
# Start simple
class Database:
    def connect(self):
        return mysql.connect(...)

    def execute(self, query):
        return self.conn.execute(query)

# Add abstraction layer when second database is actually needed
```

### 8. Comments Explain "Why", Not "What"

**Code should be self-explanatory. Comments explain reasoning.**

**❌ Bad comments:**
```python
# Loop through users
for user in users:
    # Check if user is active
    if user.is_active:
        # Send email
        send_email(user)
```

**✅ Good - self-documenting code:**
```python
active_users = [u for u in users if u.is_active]
for user in active_users:
    send_email(user)
```

**✅ Good comments - explain "why":**
```python
# Retry up to 3 times to handle transient network errors
for attempt in range(3):
    try:
        response = api.call()
        break
    except NetworkError:
        if attempt == 2:
            raise
        time.sleep(2 ** attempt)  # Exponential backoff
```

### 9. Error Handling is One Thing

**Functions that handle errors should only handle errors.**

**❌ Mixed concerns:**
```python
def process_data(data):
    try:
        result = validate(data)
        transformed = transform(result)
        saved = save(transformed)
        return saved
    except ValidationError:
        logger.error("Validation failed")
        return None
    except TransformError:
        logger.error("Transform failed")
        return None
```

**✅ Separated:**
```python
def process_data(data):
    """Main processing logic."""
    result = validate(data)
    transformed = transform(result)
    return save(transformed)

def safe_process_data(data):
    """Process data with error handling."""
    try:
        return process_data(data)
    except ValidationError as e:
        logger.error(f"Validation failed: {e}")
        raise
    except TransformError as e:
        logger.error(f"Transform failed: {e}")
        raise
```

### 10. Avoid Magic Numbers

**Use named constants.**

**❌ Bad:**
```python
if age < 18:
    return "minor"
if age > 65:
    return "senior"
return "adult"
```

**✅ Good:**
```python
ADULT_AGE = 18
SENIOR_AGE = 65

def get_age_category(age: int) -> str:
    """Categorize age group."""
    if age < ADULT_AGE:
        return "minor"
    if age > SENIOR_AGE:
        return "senior"
    return "adult"
```

## Code Organization

### Vertical Formatting

**Related concepts should be close together.**

```python
# ✅ Good - related functions grouped
def fetch_user(user_id: int) -> User:
    return database.get(user_id)

def fetch_users(user_ids: List[int]) -> List[User]:
    return [fetch_user(uid) for uid in user_ids]

def save_user(user: User) -> None:
    database.save(user)


# Separate group of functions
def send_email(user: User) -> None:
    pass

def send_bulk_email(users: List[User]) -> None:
    for user in users:
        send_email(user)
```

### Horizontal Formatting

**Keep lines short - max 79-100 characters.**

```python
# ❌ Too long
def calculate_total_price_including_tax_and_shipping(base_price, tax_rate, shipping_cost, discount_percentage):
    return base_price * (1 + tax_rate) + shipping_cost - (base_price * discount_percentage)

# ✅ Good
def calculate_total_price(
    base_price: float,
    tax_rate: float,
    shipping_cost: float,
    discount_percentage: float
) -> float:
    """Calculate total price with tax, shipping, and discount."""
    price_with_tax = base_price * (1 + tax_rate)
    discount_amount = base_price * discount_percentage
    return price_with_tax + shipping_cost - discount_amount
```

## Code Smells to Flag

### 1. Long Parameter Lists
More than 3 parameters - use dataclass or config object.

### 2. Long Functions
More than 50 lines - extract smaller functions.

### 3. Deeply Nested Code
More than 3 levels of nesting - extract functions or use early returns.

```python
# ❌ Deeply nested
def process(data):
    if data:
        if data.is_valid:
            if data.user:
                if data.user.is_active:
                    return process_active_user(data.user)

# ✅ Guard clauses
def process(data):
    if not data:
        return None
    if not data.is_valid:
        return None
    if not data.user:
        return None
    if not data.user.is_active:
        return None

    return process_active_user(data.user)
```

### 4. Duplicate Code
Same logic repeated - extract to function.

### 5. Dead Code
Unused functions/variables - remove them.

### 6. Speculative Generality
Code for "future needs" that aren't real - remove it.

### 7. Temporary Fields
Class attributes used only in some cases - refactor.

## Clean Code Checklist

- [ ] Names reveal intent
- [ ] Functions do one thing
- [ ] Functions are small (<50 lines)
- [ ] 0-3 function arguments
- [ ] No code duplication (DRY)
- [ ] Simple solutions (KISS)
- [ ] Implement only what's needed (YAGNI)
- [ ] Comments explain "why" not "what"
- [ ] Error handling separated
- [ ] No magic numbers
- [ ] Related code grouped together
- [ ] Max 79-100 character line length
- [ ] Guard clauses instead of deep nesting
- [ ] No dead code
