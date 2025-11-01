# Template: Background Jobs

Pattern for adding asynchronous task processing (Celery, arq, RQ).

---

## Canonical Subtasks

### 1. worker-setup (0.5-1d)
**Goal**: Configure task queue infrastructure

**Files**:
- `celery_app.py` or `worker.py` - Worker configuration
- `config.py` - Broker settings (Redis, RabbitMQ)
- `.env` - Broker URL

**Example (Celery)**:
```python
from celery import Celery

celery_app = Celery(
    "myapp",
    broker="redis://localhost:6379/0",
    backend="redis://localhost:6379/0"
)
```

**Dependencies**: `celery`, `redis`, or `arq`

**Dependency**: None

---

### 2. task-definitions (1d)
**Goal**: Implement background tasks

**Files**:
- `tasks.py` or `workers/tasks.py` - Task functions
- `services/{task_name}.py` - Business logic

**Example**:
```python
@celery_app.task
def send_email(user_id: int, subject: str, body: str):
    user = get_user(user_id)
    email_service.send(user.email, subject, body)
```

**Common Tasks**:
- Email sending
- Report generation
- Data import/export
- Image processing
- Webhook delivery

**Dependency**: worker-setup

---

### 3. task-scheduling (0.5d)
**Goal**: Trigger tasks (on-demand, periodic)

**Files (Django)**:
- `views.py` - Trigger from API
- `signals.py` - Trigger from model events

**Files (FastAPI)**:
- `routers/*.py` - Trigger from endpoints
- `dependencies.py` - Trigger from events

**Example (Periodic)**:
```python
from celery.schedules import crontab

celery_app.conf.beat_schedule = {
    'daily-report': {
        'task': 'tasks.generate_daily_report',
        'schedule': crontab(hour=8, minute=0),  # 8am daily
    },
}
```

**Dependency**: task-definitions

---

### 4. monitoring (0.5d)
**Goal**: Task monitoring and error handling

**Files**:
- `tasks.py` - Add logging, retries
- `monitoring.py` - Health checks (optional)

**Example**:
```python
@celery_app.task(bind=True, max_retries=3)
def unreliable_task(self, data):
    try:
        process(data)
    except Exception as exc:
        self.retry(exc=exc, countdown=60)  # Retry after 1 min
```

**Monitoring Tools**:
- Flower (Celery UI)
- Redis CLI (queue inspection)
- Logs (`logger.info` in tasks)

**Dependency**: task-scheduling

---

## Dependency Graph

```
1. worker-setup → 2. task-definitions → 3. task-scheduling → 4. monitoring
```

**Sequential**: All steps depend on previous

---

## Common Pitfalls

1. **Synchronous Calls**: Blocking task queue → Use async libraries
2. **No Retries**: Failed tasks lost → Add `max_retries`
3. **Large Payloads**: Passing huge objects → Pass IDs, fetch in task
4. **No Timeouts**: Tasks run forever → Set `time_limit`
5. **Missing Idempotency**: Re-running causes duplicates → Make tasks idempotent
6. **Broker Downtime**: Tasks lost → Use persistent broker (Redis with AOF)

---

## Example Task (Idempotent)

```python
@celery_app.task(bind=True, max_retries=3)
def send_invoice_email(self, invoice_id: int):
    invoice = get_invoice(invoice_id)

    # Idempotent check
    if invoice.email_sent:
        return "Already sent"

    try:
        email_service.send(invoice.user.email, "Invoice", body)
        invoice.email_sent = True
        invoice.save()
    except Exception as exc:
        self.retry(exc=exc, countdown=300)  # 5 min retry
```

---

**Typical Duration**: 2-3 days
**Risk Level**: MEDIUM (infrastructure dependency)
**Recommended Approach**: Sequential
