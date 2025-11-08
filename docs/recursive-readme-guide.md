# Recursive README Implementation Guide

**Complete guide to setting up and using automatic README generation.**

---

## Quick Start (5 minutes)

### Step 1: Create Config File

```bash
# In your project root
cat > .readme-config.json << 'EOF'
{
  "version": "1.0",
  "strategy": "hybrid",
  "targets": [
    "src/",
    "src/models/",
    "src/services/"
  ],
  "exclude": [
    "tmp/",
    "tests/"
  ],
  "validation": {
    "rounds": 2,
    "adaptive_rounds": true
  }
}
EOF
```

### Step 2: Test Run

```bash
# Dry run (shows what would be generated)
/documentation-manager --check-recursive

# Actually generate
/documentation-manager --recursive-readme
```

### Step 3: Review Output

```bash
# Check generated READMEs
find src/ -name "README.md" -exec head -20 {} \;

# Review confidence scores
grep "Confidence:" src/**/README.md
```

**Done!** You now have AI-generated READMEs for your critical folders.

---

## Detailed Setup

### 1. Configuration File

**Location:** `project-root/.readme-config.json`

**Minimal config (start here):**
```json
{
  "version": "1.0",
  "strategy": "hybrid",
  "targets": ["src/", "src/models/", "src/services/"],
  "exclude": ["tmp/", "tests/"]
}
```

**Production config (recommended):**
```json
{
  "version": "1.0",
  "strategy": "hybrid",
  "targets": [
    "src/",
    "src/models/",
    "src/services/",
    "src/api/",
    "src/core/"
  ],
  "exclude": [
    "node_modules/",
    ".git/",
    "tmp/",
    "__pycache__/",
    ".pytest_cache/",
    "tests/",
    "src/utils/",
    "src/helpers/",
    "src/generated/"
  ],
  "rules": {
    "min_files": 5,
    "min_subfolders": 2,
    "max_depth": 3,
    "require_code_files": true
  },
  "validation": {
    "rounds": 2,
    "adaptive_rounds": true,
    "critical_folders": [
      "src/models/",
      "src/services/"
    ]
  },
  "metadata": {
    "include_generation_info": true,
    "include_confidence_score": true,
    "last_human_review": null
  }
}
```

**Full spec:** See `docs/readme-config-spec.md`

---

### 2. Usage Commands

**Initialize config (interactive):**
```bash
/documentation-manager --init-config
```
- Asks questions
- Generates .readme-config.json
- Suggests targets based on project structure

**Check what would be generated:**
```bash
/documentation-manager --check-recursive
```
- Dry run mode
- Shows which folders match rules
- Estimates API costs
- No actual generation

**Generate/Update READMEs:**
```bash
/documentation-manager --recursive-readme
```
- Parses config
- Detects changed folders (git diff)
- Generates READMEs with cross-validation
- Saves with metadata

**Update specific folder:**
```bash
/documentation-manager --recursive-readme --folder src/models/
```
- Only updates specified folder
- Useful for testing

---

### 3. Validation Workflow

**How cross-validation works:**

```
┌─────────────────────────────────────────┐
│ Round 1: Claude (Writer)                │
│ - Analyzes folder structure             │
│ - Reads code files                      │
│ - Generates README draft                │
└──────────────┬──────────────────────────┘
               │
               v
┌─────────────────────────────────────────┐
│ Round 2: Codex (Reviewer)               │
│ - Reviews Claude's draft                │
│ - Checks technical accuracy             │
│ - Suggests improvements                 │
│ - Provides confidence score             │
└──────────────┬──────────────────────────┘
               │
               v (if rounds = 3)
┌─────────────────────────────────────────┐
│ Round 3: Claude (Refiner)               │
│ - Applies Codex feedback                │
│ - Polishes formatting                   │
│ - Final quality check                   │
└──────────────┬──────────────────────────┘
               │
               v
     ┌─────────────────┐
     │ Final README.md │
     └─────────────────┘
```

**Adaptive rounds:**
- Critical folders (`critical_folders` list): Always 3 rounds
- Small changes (< 10 files modified): 2 rounds
- Standard folders: `validation.rounds` (default: 2)

---

### 4. Output Format

**Generated README structure:**

```markdown
<!-- Auto-generated README -->
<!-- Generated: 2025-11-04 12:00:00 -->
<!-- Verified by: Codex (Round 2) -->
<!-- Confidence: 85% -->
<!-- Last human review: null -->

# Models Layer

## Purpose
Data models for the application using SQLAlchemy ORM.

## Structure
```
models/
├── __init__.py
├── user.py          # User model
├── product.py       # Product model
└── order.py         # Order model
```

## Components

### user.py
User authentication and profile data model.
- Fields: id, email, password_hash, created_at
- Relations: has_many orders

### product.py
Product catalog data model.
- Fields: id, name, price, stock
- Relations: has_many order_items

### order.py
Order and transaction data model.
- Fields: id, user_id, total, status
- Relations: belongs_to user, has_many order_items

## Usage

```python
from models import User, Product, Order

# Create user
user = User(email="alice@example.com")
db.session.add(user)
db.session.commit()

# Query products
products = Product.query.filter_by(stock__gt=0).all()
```

## Dependencies
- SQLAlchemy >= 2.0
- python-dotenv (for DATABASE_URL)

## Notes
- All models inherit from Base (declarative_base)
- Timestamps are UTC
- Soft deletes implemented (deleted_at field)
```

**Metadata fields:**
- `Generated`: Timestamp of last generation
- `Verified by`: Which AI reviewed it (Codex/Claude)
- `Confidence`: LLM confidence score (0-100%)
- `Last human review`: Manual review date (null if never)

---

### 5. Cost Management

**Estimate before running:**
```bash
/documentation-manager --check-recursive --show-cost
```

**Example output:**
```
📊 Cost Estimation:

Folders to process: 15
Average rounds: 2.3 (adaptive)

Per folder: $0.05
Total estimated: $0.75

Breakdown:
- Claude (Round 1): $0.30
- Codex (Round 2): $0.45
- Claude (Round 3): $0 (adaptive, skipped for 12 folders)
```

**Cost-saving strategies:**

1. **Use adaptive_rounds = true**
   ```json
   {
     "validation": {
       "adaptive_rounds": true  // ← Saves 30-50% cost
     }
   }
   ```

2. **Exclude aggressively**
   ```json
   {
     "exclude": [
       "tests/",
       "src/utils/",
       "src/helpers/",
       "src/generated/"
     ]
   }
   ```

3. **Batch updates (CI)**
   - Don't run on every commit
   - Schedule: daily or on main branch push only

4. **Use manual strategy for large projects**
   ```json
   {
     "strategy": "manual",  // Explicit control
     "targets": ["src/models/", "src/services/"]
   }
   ```

---

### 6. Quality Assurance

**Monitor confidence scores:**
```bash
# Find low-confidence READMEs
grep -r "Confidence:" src/**/README.md | awk -F: '{if ($3 < 70) print $0}'
```

**Monthly review checklist:**

- [ ] Sample 10% of READMEs
- [ ] Verify technical accuracy
- [ ] Check for outdated information
- [ ] Update `last_human_review` in config
- [ ] Adjust targets/exclude based on findings
- [ ] Review API costs

**Update human review date:**
```json
{
  "metadata": {
    "last_human_review": "2025-11-04"  // ← Update after review
  }
}
```

---

### 7. CI Integration

**GitHub Actions example:**

```yaml
# .github/workflows/update-readmes.yml
name: Update Auto-generated READMEs

on:
  push:
    branches: [main]
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday

jobs:
  update-readmes:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v3
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Install Claude Code
        run: |
          npm install -g @anthropic-ai/claude-code

      - name: Check costs first
        run: |
          claude /documentation-manager --check-recursive --show-cost

      - name: Generate READMEs
        run: |
          claude /documentation-manager --recursive-readme
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}

      - name: Commit changes
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add **/README.md
          git diff --staged --quiet || git commit -m "docs: update auto-generated READMEs [skip ci]"
          git push
```

**Why CI (not pre-commit):**
- ✅ Doesn't block developer workflow
- ✅ Async processing
- ✅ Centralized cost tracking
- ✅ Easier debugging
- ✅ Scheduled updates (weekly/monthly)

---

### 8. Troubleshooting

**Problem: "Too many READMEs generated"**

**Solution:**
```bash
# 1. Check your strategy
cat .readme-config.json | grep strategy
# Should be "hybrid", not "all"

# 2. Review targets list
cat .readme-config.json | jq '.targets'
# Too many? Remove some

# 3. Expand exclude list
# Edit .readme-config.json, add more to exclude

# 4. Increase min_files threshold
{
  "rules": {
    "min_files": 10  // ← Increase from 5
  }
}
```

---

**Problem: "Critical folder skipped"**

**Solution:**
```bash
# 1. Check it's in targets
cat .readme-config.json | jq '.targets' | grep "your-folder"

# 2. Check not in exclude
cat .readme-config.json | jq '.exclude' | grep "your-folder"

# 3. Verify depth
# If folder is deep (src/a/b/c/d), increase max_depth
{
  "rules": {
    "max_depth": 5  // ← Increase
  }
}

# 4. Check require_code_files
# If folder has only .md files, set to false
{
  "rules": {
    "require_code_files": false
  }
}
```

---

**Problem: "API costs too high"**

**Solution:**
```bash
# 1. Enable adaptive rounds
{
  "validation": {
    "adaptive_rounds": true  // ← Add this
  }
}

# 2. Reduce rounds globally
{
  "validation": {
    "rounds": 1  // ← Claude only, no Codex
  }
}

# 3. Expand exclude list
{
  "exclude": [
    "tests/",
    "docs/",
    "scripts/",
    "src/utils/",
    "src/helpers/"
  ]
}

# 4. Use manual strategy
{
  "strategy": "manual",
  "targets": ["src/models/", "src/services/"]  // Only critical
}
```

---

**Problem: "README quality poor"**

**Solution:**
```bash
# 1. Increase rounds for critical folders
{
  "validation": {
    "rounds": 3,
    "critical_folders": ["src/models/", "src/services/"]
  }
}

# 2. Check Codex feedback
# Look in logs or .ai-debate-output/ for Codex suggestions

# 3. Schedule human review
# Mark in calendar: monthly README review

# 4. Provide examples
# Create manual README.md in one folder
# AI will learn from existing style
```

---

## Best Practices Summary

### ✅ Do's

1. **Start small** (5-10 folders)
2. **Use hybrid strategy** (not "all")
3. **Enable adaptive_rounds**
4. **Review monthly** (sample 10%)
5. **Track costs** (monitor API usage)
6. **Use CI** (not pre-commit)
7. **Exclude aggressively** (tests, utils, generated)
8. **Trust but verify** (check low-confidence READMEs)

### ❌ Don'ts

1. **Don't use strategy = "all"** (unless < 20 folders)
2. **Don't skip exclude list** (always exclude vendor code)
3. **Don't set rounds = 3 globally** (too expensive)
4. **Don't trust blindly** (LLMs make mistakes)
5. **Don't ignore confidence scores** (< 70% needs review)
6. **Don't run on every commit** (use CI schedule)
7. **Don't forget human review** (monthly minimum)
8. **Don't expand without testing** (measure costs first)

---

## Migration Path

### Phase 1: Pilot (Week 1-2)
- 5 critical folders only
- Measure costs and quality
- Adjust config based on learnings

### Phase 2: Expand (Week 3-4)
- Add 5-10 more folders
- Refine exclude list
- Set up CI integration

### Phase 3: Production (Month 2+)
- Full hybrid strategy
- Monthly review schedule
- Cost optimization

---

## FAQ

**Q: Can I edit AI-generated READMEs manually?**
A: Yes! They're just markdown files. Manual edits will be preserved if folder doesn't change. But if code changes, AI will regenerate and your edits may be lost. Consider moving manual notes to separate docs.

**Q: How do I exclude a specific folder?**
A: Add to `exclude` list in `.readme-config.json`:
```json
{
  "exclude": ["src/specific-folder/"]
}
```

**Q: What if I want MORE folders, not less?**
A: Use strategy = "all" BUT test costs first with `--check-recursive --show-cost`. For 50+ folders, expect $5-10/month.

**Q: Can I use different templates per folder?**
A: Not yet (v1.1). All READMEs use same structure. Custom templates planned for v2.0.

**Q: How accurate are confidence scores?**
A: Rough estimate. 90%+ = likely good, 70-89% = review recommended, < 70% = definitely review. Based on LLM self-assessment.

**Q: Can I run this locally (not CI)?**
A: Yes! Just run `/documentation-manager --recursive-readme` manually whenever you want.

---

**Version:** 1.0
**Last Updated:** 2025-11-04
