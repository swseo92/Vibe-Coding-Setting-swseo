# SOLID Principles for Python

SOLID principles for object-oriented design, adapted for Python.

## S - Single Responsibility Principle (SRP)

**A class should have only one reason to change.**

**❌ Violation:**
```python
class User:
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email

    def save_to_database(self):
        """Save user to database."""
        database.execute(
            "INSERT INTO users VALUES (?, ?)",
            (self.name, self.email)
        )

    def send_welcome_email(self):
        """Send welcome email."""
        email_service.send(
            to=self.email,
            subject="Welcome!",
            body=f"Hello {self.name}"
        )

    def generate_report(self):
        """Generate user activity report."""
        return f"Report for {self.name}..."
```

**Why it's wrong:**
- User class has 4 reasons to change:
  1. User data structure changes
  2. Database schema changes
  3. Email format changes
  4. Report format changes

**✅ Fixed:**
```python
class User:
    """Represents a user - data only."""
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email


class UserRepository:
    """Handles user persistence."""
    def save(self, user: User) -> None:
        database.execute(
            "INSERT INTO users VALUES (?, ?)",
            (user.name, user.email)
        )

    def find_by_email(self, email: str) -> Optional[User]:
        row = database.query("SELECT * FROM users WHERE email = ?", (email,))
        return User(name=row[0], email=row[1]) if row else None


class EmailService:
    """Handles email sending."""
    def send_welcome_email(self, user: User) -> None:
        self.send(
            to=user.email,
            subject="Welcome!",
            body=f"Hello {user.name}"
        )


class UserReportGenerator:
    """Generates user reports."""
    def generate(self, user: User) -> str:
        return f"Report for {user.name}..."
```

**Benefits:**
- Each class has one clear responsibility
- Changes to database don't affect email logic
- Easy to test each class independently
- Can swap implementations (e.g., different databases)

## O - Open/Closed Principle (OCP)

**Software entities should be open for extension, but closed for modification.**

**❌ Violation:**
```python
class PaymentProcessor:
    def process(self, payment_type: str, amount: float):
        if payment_type == "credit_card":
            # Credit card processing logic
            fee = amount * 0.03
            print(f"Processing ${amount} via credit card, fee: ${fee}")
        elif payment_type == "paypal":
            # PayPal processing logic
            fee = amount * 0.04
            print(f"Processing ${amount} via PayPal, fee: ${fee}")
        elif payment_type == "bitcoin":
            # Bitcoin processing logic
            fee = amount * 0.01
            print(f"Processing ${amount} via Bitcoin, fee: ${fee}")
        else:
            raise ValueError("Unknown payment type")
```

**Why it's wrong:**
- Adding new payment method requires modifying existing class
- Violates open/closed principle
- Risk of breaking existing payment methods

**✅ Fixed:**
```python
from abc import ABC, abstractmethod

class PaymentMethod(ABC):
    """Abstract payment method."""

    @abstractmethod
    def calculate_fee(self, amount: float) -> float:
        pass

    def process(self, amount: float) -> None:
        fee = self.calculate_fee(amount)
        print(f"Processing ${amount} via {self.__class__.__name__}, fee: ${fee}")


class CreditCardPayment(PaymentMethod):
    def calculate_fee(self, amount: float) -> float:
        return amount * 0.03


class PayPalPayment(PaymentMethod):
    def calculate_fee(self, amount: float) -> float:
        return amount * 0.04


class BitcoinPayment(PaymentMethod):
    def calculate_fee(self, amount: float) -> float:
        return amount * 0.01


class PaymentProcessor:
    def process(self, payment_method: PaymentMethod, amount: float):
        payment_method.process(amount)


# Usage
processor = PaymentProcessor()
processor.process(CreditCardPayment(), 100.0)
processor.process(PayPalPayment(), 100.0)

# Adding new payment method - no changes to existing code
class ApplePayPayment(PaymentMethod):
    def calculate_fee(self, amount: float) -> float:
        return amount * 0.025

processor.process(ApplePayPayment(), 100.0)
```

**Benefits:**
- Add new payment methods without modifying existing code
- Reduced risk of breaking existing functionality
- Easy to test new payment methods independently

## L - Liskov Substitution Principle (LSP)

**Subtypes must be substitutable for their base types.**

**❌ Violation:**
```python
class Rectangle:
    def __init__(self, width: int, height: int):
        self.width = width
        self.height = height

    def area(self) -> int:
        return self.width * self.height


class Square(Rectangle):
    def __init__(self, side: int):
        super().__init__(side, side)

    def set_width(self, width: int):
        # Square must keep width == height
        self.width = width
        self.height = width  # ❌ Violates LSP

    def set_height(self, height: int):
        self.width = height
        self.height = height


# Breaks substitutability
def test_rectangle(rect: Rectangle):
    rect.width = 5
    rect.height = 4
    assert rect.area() == 20  # ❌ Fails for Square!
```

**Why it's wrong:**
- Square can't be substituted for Rectangle
- Behavior changes unexpectedly
- Violates caller expectations

**✅ Fixed:**
```python
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self) -> int:
        pass


class Rectangle(Shape):
    def __init__(self, width: int, height: int):
        self.width = width
        self.height = height

    def area(self) -> int:
        return self.width * self.height


class Square(Shape):
    def __init__(self, side: int):
        self.side = side

    def area(self) -> int:
        return self.side ** 2


# Both are shapes, but not in a parent-child relationship
def test_shape(shape: Shape):
    area = shape.area()
    assert area > 0  # ✅ Works for any Shape
```

**Benefits:**
- Each shape has appropriate representation
- No unexpected behavior
- Code using `Shape` works for all implementations

## I - Interface Segregation Principle (ISP)

**Clients shouldn't be forced to depend on interfaces they don't use.**

**❌ Violation:**
```python
class Worker(ABC):
    @abstractmethod
    def work(self):
        pass

    @abstractmethod
    def eat(self):
        pass

    @abstractmethod
    def sleep(self):
        pass


class Human(Worker):
    def work(self):
        print("Human working")

    def eat(self):
        print("Human eating")

    def sleep(self):
        print("Human sleeping")


class Robot(Worker):
    def work(self):
        print("Robot working")

    def eat(self):
        # ❌ Robots don't eat!
        raise NotImplementedError("Robots don't eat")

    def sleep(self):
        # ❌ Robots don't sleep!
        raise NotImplementedError("Robots don't sleep")
```

**Why it's wrong:**
- Robot forced to implement methods it doesn't use
- Violates ISP
- Confusing interface

**✅ Fixed:**
```python
class Workable(ABC):
    @abstractmethod
    def work(self):
        pass


class Eatable(ABC):
    @abstractmethod
    def eat(self):
        pass


class Sleepable(ABC):
    @abstractmethod
    def sleep(self):
        pass


class Human(Workable, Eatable, Sleepable):
    def work(self):
        print("Human working")

    def eat(self):
        print("Human eating")

    def sleep(self):
        print("Human sleeping")


class Robot(Workable):
    def work(self):
        print("Robot working")


# Clients depend only on interfaces they use
def manage_worker(worker: Workable):
    worker.work()

def manage_biological_worker(worker: Workable & Eatable & Sleepable):
    worker.work()
    worker.eat()
    worker.sleep()
```

**Benefits:**
- Smaller, focused interfaces
- No unnecessary dependencies
- Clear contracts

## D - Dependency Inversion Principle (DIP)

**Depend on abstractions, not concretions.**

**❌ Violation:**
```python
class MySQLDatabase:
    def connect(self):
        print("Connecting to MySQL")

    def query(self, sql: str):
        print(f"Executing: {sql}")


class UserService:
    def __init__(self):
        # ❌ Depends on concrete MySQL implementation
        self.db = MySQLDatabase()

    def get_user(self, user_id: int):
        self.db.connect()
        self.db.query(f"SELECT * FROM users WHERE id = {user_id}")
```

**Why it's wrong:**
- UserService tightly coupled to MySQL
- Can't swap to PostgreSQL without modifying UserService
- Hard to test (can't mock database)

**✅ Fixed:**
```python
from abc import ABC, abstractmethod

class Database(ABC):
    """Abstract database interface."""

    @abstractmethod
    def connect(self):
        pass

    @abstractmethod
    def query(self, sql: str):
        pass


class MySQLDatabase(Database):
    def connect(self):
        print("Connecting to MySQL")

    def query(self, sql: str):
        print(f"MySQL query: {sql}")


class PostgreSQLDatabase(Database):
    def connect(self):
        print("Connecting to PostgreSQL")

    def query(self, sql: str):
        print(f"PostgreSQL query: {sql}")


class UserService:
    def __init__(self, database: Database):
        # ✅ Depends on abstraction
        self.db = database

    def get_user(self, user_id: int):
        self.db.connect()
        self.db.query(f"SELECT * FROM users WHERE id = {user_id}")


# Usage - inject dependency
mysql_db = MySQLDatabase()
user_service = UserService(mysql_db)

# Easy to swap implementation
postgres_db = PostgreSQLDatabase()
user_service = UserService(postgres_db)

# Easy to test with mock
class MockDatabase(Database):
    def connect(self):
        pass

    def query(self, sql: str):
        return {"id": 1, "name": "Test User"}

test_service = UserService(MockDatabase())
```

**Benefits:**
- Loose coupling
- Easy to swap implementations
- Testable with mocks
- Flexible architecture

## Python-Specific SOLID Considerations

### Duck Typing vs Explicit Interfaces

Python's duck typing can make SOLID principles less formal:

```python
# ✅ Duck typing - no explicit interface
class EmailSender:
    def send(self, to: str, subject: str, body: str):
        pass


class SMSSender:
    def send(self, to: str, subject: str, body: str):
        pass


def notify(sender, to: str, subject: str, body: str):
    # Works with any object having send() method
    sender.send(to, subject, body)
```

### Protocols (Python 3.8+)

Use typing.Protocol for structural subtyping:

```python
from typing import Protocol

class Sender(Protocol):
    def send(self, to: str, subject: str, body: str) -> None:
        ...


def notify(sender: Sender, to: str, subject: str, body: str):
    sender.send(to, subject, body)
```

## Review Checklist

When reviewing for SOLID principles:

### Single Responsibility
- [ ] Each class has one clear purpose
- [ ] Each class has one reason to change
- [ ] No "God classes" doing too much

### Open/Closed
- [ ] Can add new functionality without modifying existing code
- [ ] Use inheritance/composition for extension
- [ ] Avoid if/elif chains for type checking

### Liskov Substitution
- [ ] Subclasses can replace parent classes
- [ ] No unexpected behavior changes in subclasses
- [ ] Preconditions not strengthened in subclasses
- [ ] Postconditions not weakened in subclasses

### Interface Segregation
- [ ] Interfaces are small and focused
- [ ] No classes forced to implement unused methods
- [ ] Use multiple small interfaces over one large interface

### Dependency Inversion
- [ ] High-level modules don't depend on low-level modules
- [ ] Both depend on abstractions
- [ ] Dependencies injected, not created internally
- [ ] Easy to swap implementations
- [ ] Easy to test with mocks

## Common Violations to Flag

1. **Large classes** (>300 lines) - likely violating SRP
2. **if/elif chains for types** - violating OCP
3. **Inheritance for code reuse** - consider composition
4. **Concrete classes in type hints** - use abstractions
5. **Direct instantiation of dependencies** - use dependency injection
6. **Classes with many dependencies** - likely violating SRP
