# Template: Database Migration

Pattern for schema changes and data migrations.

---

## Canonical Subtasks

### 1. migration-plan (0.5d)
**Goal**: Document migration strategy

**Files**:
- `docs/migration-plan.md` - Migration steps
- Identify affected tables, indexes, constraints

**Checklist**:
- [ ] Backward compatible? (can old code run with new schema?)
- [ ] Data migration needed? (transform existing data)
- [ ] Downtime required? (or zero-downtime strategy)
- [ ] Rollback plan documented

**Dependency**: None

---

### 2. schema-migration (0.5d)
**Goal**: Create schema change migration

**Files (Django)**: `apps/{app}/migrations/XXXX_description.py`
**Files (FastAPI)**: `alembic/versions/XXXX_description.py`

**Example (Add Column)**:
```python
# Django migration
operations = [
    migrations.AddField(
        model_name='user',
        name='verified',
        field=models.BooleanField(default=False),
    ),
]
```

**Naming Convention**: `YYYYMMDDHHMM_add_user_verified`

**Dependency**: migration-plan

**Risk**: MEDIUM-HIGH (schema change)

---

### 3. data-migration (0.5-1d)
**Goal**: Transform existing data (if needed)

**Files**:
- Separate migration file OR
- Python script: `scripts/migrate_data.py`

**Example (Backfill Data)**:
```python
# Django data migration
def backfill_verified_status(apps, schema_editor):
    User = apps.get_model('auth', 'User')
    User.objects.filter(email_confirmed_at__isnull=False).update(verified=True)

class Migration(migrations.Migration):
    operations = [
        migrations.RunPython(backfill_verified_status),
    ]
```

**Dependency**: schema-migration

**Risk**: HIGH (data transformation)

---

### 4. migration-validation (0.5d)
**Goal**: Test migration forward + rollback

**Files**:
- `tests/migrations/test_XXXX.py` - Migration tests

**Test Cases**:
- [ ] Migration applies successfully
- [ ] Rollback works
- [ ] Data preserved (no loss)
- [ ] Indexes created
- [ ] Performance acceptable (large tables)

**Dependency**: data-migration

---

## Dependency Graph

```
1. plan → 2. schema-migration → 3. data-migration → 4. validation
```

**Sequential**: All steps must be sequential

---

## Migration Types

### Type 1: Additive (Safe)
**Examples**:
- Add new table
- Add new column (with default)
- Add index

**Backward Compatible**: ✅ Yes

**Strategy**: Deploy code + migration simultaneously

---

### Type 2: Modification (Risky)
**Examples**:
- Rename column
- Change column type
- Remove column

**Backward Compatible**: ❌ No

**Strategy**: Multi-phase deployment
1. Add new column, deploy code using old column
2. Backfill data to new column
3. Deploy code using new column
4. Remove old column

---

### Type 3: Data Transformation (Very Risky)
**Examples**:
- Split column (name → first_name + last_name)
- Merge tables
- Change data format

**Backward Compatible**: ❌ No

**Strategy**: Offline migration OR feature flag + dual-write

---

## Common Pitfalls

1. **No Rollback Plan**: Migration breaks, can't undo → Always test rollback
2. **Missing Default Values**: Adding NOT NULL column → Provide default or backfill first
3. **Locking Tables**: Migration locks large table → Use lock-free DDL (PostgreSQL `CONCURRENTLY`)
4. **Slow Data Migration**: Backfilling 1M rows → Batch updates (1000 at a time)
5. **Not Testing on Staging**: Works locally, fails in prod → Always test on staging data
6. **Forgetting Indexes**: Query performance degrades → Add indexes in same migration

---

## Zero-Downtime Migration Example

**Scenario**: Rename `User.name` → `User.full_name`

**Phase 1: Add New Column**
```python
# Migration 001
operations = [
    migrations.AddField('user', 'full_name', TextField(null=True)),
]
# Deploy code that writes to BOTH name and full_name
```

**Phase 2: Backfill Data**
```python
# Migration 002 (data migration)
User.objects.update(full_name=F('name'))
```

**Phase 3: Switch to New Column**
```python
# Deploy code that uses full_name only
```

**Phase 4: Remove Old Column**
```python
# Migration 003
operations = [
    migrations.RemoveField('user', 'name'),
]
```

---

## Performance Considerations

### Large Table Migrations

**Problem**: Migration locks table for minutes/hours

**Solutions**:

**PostgreSQL**:
```sql
-- Add index concurrently (no lock)
CREATE INDEX CONCURRENTLY idx_user_email ON users(email);
```

**Django**:
```python
from django.contrib.postgres.operations import AddIndexConcurrently

class Migration(migrations.Migration):
    operations = [
        AddIndexConcurrently(
            model_name='user',
            index=models.Index(fields=['email'], name='idx_user_email'),
        ),
    ]
```

**Batch Updates**:
```python
# Don't do this (locks table)
User.objects.all().update(verified=True)

# Do this (batches)
batch_size = 1000
for batch in queryset_iterator(User.objects.all(), batch_size):
    User.objects.filter(id__in=[u.id for u in batch]).update(verified=True)
    time.sleep(0.1)  # Give DB a break
```

---

## Rollback Checklist

Before deploying migration:

- [ ] Tested rollback locally
- [ ] Rollback script documented
- [ ] Database backup created
- [ ] Migration tested on staging with prod-like data
- [ ] Downtime window communicated (if needed)
- [ ] Monitoring/alerts set up
- [ ] Team on standby during deployment

---

**Typical Duration**: 1-2 days (simple), 3-5 days (complex)
**Risk Level**: HIGH (data loss risk)
**Recommended Approach**: Always sequential, never parallel
