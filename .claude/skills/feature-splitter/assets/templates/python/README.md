# Python Feature Templates

> **NOTE**: These are **example templates** for common Python patterns.
> They are **not requirements** - the Agent can propose custom decompositions based on your actual codebase.

---

## Purpose

These templates provide starting points for common feature types in Python projects (Django, FastAPI):

1. **auth-feature.md** - OAuth, JWT, Sessions authentication
2. **crud-resource.md** - CRUD operations for resources
3. **background-jobs.md** - Celery, arq, RQ task processing
4. **api-integration.md** - Stripe, Twilio, SendGrid integrations
5. **db-migration.md** - Schema and data migrations
6. **search-feature.md** - ElasticSearch, PostgreSQL FTS

---

## How to Use

**The Agent decides when to use templates:**
- If user's goal matches a template pattern → Suggest template as starting point
- If custom decomposition needed → Analyze codebase and propose custom split
- Templates are **accelerators**, not constraints

**You can:**
- Use templates as-is for standard features
- Adapt templates to your project structure
- Ignore templates completely if they don't fit

---

## Creating Templates for Other Languages

**Similar templates can be created for:**
- JavaScript/TypeScript (Express, NestJS, Next.js)
- Java (Spring Boot)
- Go (Gin, Echo)
- Ruby (Rails)
- Rust (Actix, Rocket)

**Template Structure:**
```markdown
# Template: {Feature Type}

## Canonical Subtasks
1. {subtask-1} - {description}
2. {subtask-2} - {description}
...

## Dependency Graph
...

## Common Pitfalls
...
```

**Keep templates language-agnostic where possible**, adapting only framework-specific details.

---

**Version**: 1.0.0
**Status**: Example Templates for Python
