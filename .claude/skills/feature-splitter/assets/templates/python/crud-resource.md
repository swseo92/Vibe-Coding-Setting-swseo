# Template: CRUD Resource

Pattern for adding a new resource with Create, Read, Update, Delete operations.

---

## Canonical Subtasks

### 1. {resource}-schema (0.5d)
**Goal**: Database model for the resource

**Files (Django)**: `apps/{resource}/models.py`, migration
**Files (FastAPI)**: `models/{resource}.py`, Alembic migration

**Example**:
```python
class Product(Base):
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    price = Column(Float)
    stock = Column(Integer, default=0)
```

**Dependency**: None

---

### 2. {resource}-serializers (0.5d)
**Goal**: Request/response schemas

**Files (Django)**: `serializers.py`
**Files (FastAPI)**: `schemas/{resource}.py`

**Example (FastAPI)**:
```python
class ProductCreate(BaseModel):
    name: str
    price: float
    stock: int = 0

class ProductResponse(BaseModel):
    id: int
    name: str
    price: float
    stock: int
```

**Dependency**: {resource}-schema

---

### 3. {resource}-crud (1d)
**Goal**: CRUD operations (Create, Read, Update, Delete)

**Files (Django)**: `viewsets.py`, `urls.py`
**Files (FastAPI)**: `routers/{resource}.py`

**Endpoints**:
- `POST /{resource}` - Create
- `GET /{resource}` - List all
- `GET /{resource}/{id}` - Get one
- `PUT /{resource}/{id}` - Update
- `DELETE /{resource}/{id}` - Delete

**Dependency**: {resource}-serializers

---

### 4. {resource}-tests (0.5-1d)
**Goal**: API tests for all CRUD operations

**Files**: `tests/test_{resource}.py`

**Coverage**:
- Create valid resource
- Create invalid (validation errors)
- Read existing resource
- Read non-existent (404)
- Update resource
- Delete resource

**Dependency**: {resource}-crud

---

## Dependency Graph

```
1. schema → 2. serializers → 3. crud → 4. tests
```

**Sequential**: All steps depend on previous

---

## Common Pitfalls

1. **No Pagination**: List endpoint returns all records → Use pagination
2. **Missing Validation**: Accept invalid data → Add Pydantic validators
3. **No Soft Deletes**: Hard delete loses data → Consider `is_deleted` flag
4. **Concurrent Updates**: Race conditions → Use optimistic locking (version field)
5. **N+1 Queries**: Loading relations in loop → Use `select_related`/`prefetch_related` (Django) or `joinedload` (SQLAlchemy)

---

**Typical Duration**: 2-3 days
**Risk Level**: LOW-MEDIUM
**Recommended Approach**: Sequential
