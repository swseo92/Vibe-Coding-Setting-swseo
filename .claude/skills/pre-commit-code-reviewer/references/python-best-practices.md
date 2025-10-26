# Python Best Practices & Antipatterns

Reference for identifying common Python bugs, antipatterns, and performance issues during code review.

## Common Python Antipatterns

### 1. Mutable Default Arguments

**❌ Bad:**
```python
def append_to_list(item, list=[]):
    list.append(item)
    return list
```

**✅ Good:**
```python
def append_to_list(item, list=None):
    if list is None:
        list = []
    list.append(item)
    return list
```

**Why**: Default arguments are evaluated once at function definition time, not at call time.

### 2. Using `is` for Value Comparison

**❌ Bad:**
```python
if count is 0:
    return None
```

**✅ Good:**
```python
if count == 0:
    return None
```

**Why**: `is` checks identity, not equality. Use `==` for value comparison.

### 3. Catching `Exception` Too Broadly

**❌ Bad:**
```python
try:
    dangerous_operation()
except:
    pass
```

**✅ Good:**
```python
try:
    dangerous_operation()
except (ValueError, KeyError) as e:
    logger.error(f"Operation failed: {e}")
    raise
```

**Why**: Broad exception handling masks bugs. Catch specific exceptions.

### 4. Using `+` for String Concatenation in Loops

**❌ Bad:**
```python
result = ""
for item in items:
    result += str(item) + ","
```

**✅ Good:**
```python
result = ",".join(str(item) for item in items)
```

**Why**: String concatenation with `+` creates new string objects each iteration (O(n²)).

### 5. Not Using Context Managers for Resources

**❌ Bad:**
```python
f = open("file.txt")
data = f.read()
f.close()
```

**✅ Good:**
```python
with open("file.txt") as f:
    data = f.read()
```

**Why**: Context managers ensure resources are properly cleaned up, even if exceptions occur.

### 6. Using `list()` When List Comprehension is Better

**❌ Bad:**
```python
squares = list(map(lambda x: x**2, range(10)))
```

**✅ Good:**
```python
squares = [x**2 for x in range(10)]
```

**Why**: List comprehensions are more readable and often faster.

### 7. Not Using `enumerate()` for Index Access

**❌ Bad:**
```python
for i in range(len(items)):
    print(i, items[i])
```

**✅ Good:**
```python
for i, item in enumerate(items):
    print(i, item)
```

**Why**: `enumerate()` is more Pythonic and less error-prone.

### 8. Checking for Empty Sequences with `len()`

**❌ Bad:**
```python
if len(my_list) == 0:
    return
```

**✅ Good:**
```python
if not my_list:
    return
```

**Why**: Sequences are falsy when empty. More concise and Pythonic.

### 9. Using `del` Instead of `pop()` for Lists

**❌ Bad:**
```python
item = my_list[-1]
del my_list[-1]
```

**✅ Good:**
```python
item = my_list.pop()
```

**Why**: `pop()` removes and returns in one operation.

### 10. Importing `*`

**❌ Bad:**
```python
from module import *
```

**✅ Good:**
```python
from module import specific_function, another_function
```

**Why**: Pollutes namespace and makes code unclear.

## Potential Bug Patterns

### None/AttributeError Issues

**Check for:**
```python
# Accessing attributes without checking None
result = function_that_might_return_none()
value = result.attribute  # ❌ AttributeError if None

# ✅ Better
result = function_that_might_return_none()
value = result.attribute if result else default_value
```

### Dictionary KeyError

**Check for:**
```python
# Accessing dict keys without checking
value = my_dict[key]  # ❌ KeyError if key doesn't exist

# ✅ Better
value = my_dict.get(key, default_value)
```

### Off-by-One Errors

**Common in:**
```python
# Range endpoint confusion
for i in range(len(items) - 1):  # ❌ Misses last item?
    process(items[i])

# ✅ Verify intent
for i in range(len(items)):  # All items
    process(items[i])
```

### Race Conditions in Concurrent Code

**Check for:**
```python
# Time-of-check to time-of-use
if not os.path.exists(filename):  # ❌ File might be created here
    with open(filename, 'w') as f:
        f.write(data)

# ✅ Better
try:
    with open(filename, 'x') as f:  # Exclusive creation
        f.write(data)
except FileExistsError:
    pass
```

### Resource Leaks

**Check for unclosed:**
- Files
- Database connections
- Network sockets
- Thread pools
- Subprocesses

**Always use context managers:**
```python
with resource_manager() as resource:
    use(resource)
```

## PEP 8 Style Guide Essentials

### Naming Conventions

- **Modules**: `lowercase_with_underscores.py`
- **Classes**: `CapitalizedWords`
- **Functions/Methods**: `lowercase_with_underscores()`
- **Constants**: `UPPERCASE_WITH_UNDERSCORES`
- **Private**: `_leading_underscore`

### Line Length

- Maximum 79 characters for code
- Maximum 72 characters for docstrings/comments
- Break long lines using parentheses, not backslash

### Imports

```python
# ✅ Good order
import os
import sys

from third_party import module

from mypackage import mymodule
```

### Whitespace

```python
# ✅ Good
spam(ham[1], {eggs: 2})
x = 1

# ❌ Bad
spam( ham[ 1 ], { eggs: 2 } )
x=1
```

## Performance Optimization Tips

### 1. Use Built-in Functions

```python
# ❌ Slower
max_value = None
for item in items:
    if max_value is None or item > max_value:
        max_value = item

# ✅ Faster
max_value = max(items)
```

### 2. List Comprehensions Over `map()`/`filter()`

```python
# ✅ Faster for simple operations
[x*2 for x in range(100)]

# vs
list(map(lambda x: x*2, range(100)))
```

### 3. Use `set` for Membership Testing

```python
# ❌ O(n) lookup
if item in my_list:  # Slow for large lists
    pass

# ✅ O(1) lookup
if item in my_set:  # Fast
    pass
```

### 4. Avoid Repeated Attribute Lookups

```python
# ❌ Bad
for i in range(len(items)):
    items.append(process(items[i]))

# ✅ Good
items_append = items.append
for i in range(len(items)):
    items_append(process(items[i]))
```

### 5. Use Generators for Large Datasets

```python
# ❌ Memory intensive
return [expensive_operation(x) for x in huge_list]

# ✅ Memory efficient
return (expensive_operation(x) for x in huge_list)
```

### 6. Leverage `__slots__` for Memory Savings

```python
class Point:
    __slots__ = ('x', 'y')

    def __init__(self, x, y):
        self.x = x
        self.y = y
```

**Use when**: Creating millions of instances.

## Security Considerations

### SQL Injection Prevention

```python
# ❌ Vulnerable
query = f"SELECT * FROM users WHERE name = '{user_input}'"

# ✅ Safe
query = "SELECT * FROM users WHERE name = %s"
cursor.execute(query, (user_input,))
```

### Path Traversal Prevention

```python
# ❌ Vulnerable
filepath = os.path.join(base_dir, user_input)

# ✅ Safe
filepath = os.path.join(base_dir, os.path.basename(user_input))
if not filepath.startswith(base_dir):
    raise ValueError("Invalid path")
```

### Command Injection Prevention

```python
# ❌ Vulnerable
os.system(f"ls {user_input}")

# ✅ Safe
subprocess.run(["ls", user_input], check=True)
```

## Type Hints Best Practices

```python
from typing import List, Dict, Optional, Union, Callable

def process_data(
    items: List[str],
    config: Dict[str, int],
    callback: Optional[Callable[[str], None]] = None
) -> Union[int, None]:
    """Process items with config."""
    if not items:
        return None

    count = 0
    for item in items:
        if callback:
            callback(item)
        count += config.get(item, 0)

    return count
```

## Common Code Smells to Flag

1. **Long functions** (>50 lines) - likely violating Single Responsibility
2. **Deep nesting** (>3 levels) - hard to read and test
3. **Many parameters** (>5) - consider using dataclass or config object
4. **Duplicated code** - violation of DRY principle
5. **Magic numbers** - use named constants
6. **God classes** - classes doing too much
7. **Shotgun surgery** - changes require modifications across many files
8. **Comments explaining code** - code should be self-explanatory

## Review Checklist

When reviewing Python code, check:

- [ ] No mutable default arguments
- [ ] Proper exception handling (specific exceptions)
- [ ] Resources cleaned up with context managers
- [ ] Type hints present and accurate
- [ ] No hardcoded secrets or credentials
- [ ] Input validation for user data
- [ ] Efficient algorithms (no unnecessary O(n²))
- [ ] PEP 8 compliance (naming, spacing, imports)
- [ ] No common antipatterns listed above
- [ ] Security vulnerabilities addressed
