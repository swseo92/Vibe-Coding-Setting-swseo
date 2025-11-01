# Conflict Resolution: Git Rerere vs AI

**Based on:** Claude vs Codex Debate Round 4 (2025-11-01)
**Decision:** Git rerere as primary, PyCharm as fallback, AI as learning tool only
**Confidence:** High (90%)

---

## Decision Summary

**Tier 1: Git Rerere (Automatic)** ⭐ Recommended
- Automatically resolves repeated conflicts
- One-time setup, lifetime benefit
- 100% safe, deterministic

**Tier 2: PyCharm Merge Tool (Visual)**
- 3-way merge view with syntax highlighting
- Manual review required
- 2-5 minutes per file

**Tier 3: AI Suggestion (Educational)**
- Manual application only
- Use for learning conflict patterns
- **Never auto-apply**

---

## Git Rerere: The 80/20 Solution

### What is Rerere?

**REuse REcorded REsolution** - Git automatically remembers how you resolved conflicts.

**Setup (one-time):**
```bash
git config --global rerere.enabled true
git config --global rerere.autoupdate true
```

### How It Works

**First conflict:**
```python
<<<<<<< HEAD
def calculate_total(items):
    return sum(item.price for item in items)
=======
def calculate_total(items):
    return sum(item.price * item.quantity for item in items)
>>>>>>> feature

# You manually resolve to:
def calculate_total(items):
    return sum(item.price * item.quantity for item in items)
```

Git records:
```
.git/rr-cache/abc123/
├── preimage  (conflict markers)
└── postimage (your resolution)
```

**Next time same conflict:**
```python
# Git automatically resolves to:
def calculate_total(items):
    return sum(item.price * item.quantity for item in items)

# No manual intervention needed!
```

### When Rerere Helps Most

**Common scenarios:**
1. **Rebasing frequently** - Same conflicts appear repeatedly
2. **Feature branch conflicts** - Resolve once, rebase multiple times
3. **Cherry-picking** - Same fix applied to multiple branches
4. **Merge conflicts** - Recurring patterns

**Example workflow:**
```
Day 1: Rebase feature-auth, resolve conflict in auth.py
Day 2: Main updated, rebase again → Conflict auto-resolved by rerere
Day 3: Another rebase → Conflict auto-resolved again
```

**Time saved:** 5 minutes per rebase * 10 rebases = 50 minutes

---

## Why Not AI Auto-Resolve?

### ROI Analysis for Solo Developers

**Costs:**
1. **Implementation complexity** - 100-200 lines of integration code
2. **API costs** - $0.01-0.10 per conflict resolution
3. **Confidence threshold tuning** - Trial and error, ongoing maintenance
4. **Test coverage assumptions** - Assumes comprehensive test suite
5. **User intervention prompts** - Fatigue from "Are you sure?" prompts

**Benefits:**
1. **Time saved** - Maybe 2-3 minutes per conflict (if correct)
2. **Success rate** - 60-80% for simple conflicts (unreliable)

**Calculation:**
```
Conflicts per month (solo dev): ~5-10
Time saved per conflict: 3 min (optimistic)
Total saved: 15-30 min/month

vs.

Git rerere:
Setup time: 2 min (one-time)
Time saved per conflict: 5 min (100% success for repeated conflicts)
Total saved: 25-50 min/month (ongoing)
```

**Verdict:** Git rerere provides better ROI with zero ongoing cost

### When AI Suggestions ARE Useful

**Educational scenarios:**
1. **Learning conflict patterns** - See how AI would resolve
2. **Complex refactoring** - Get ideas for resolution approach
3. **Unfamiliar codebase** - Understand context around conflict

**Script:** `conflict-helper.ps1`

```powershell
.\conflict-helper.ps1 auth.py
```

**Options:**
```
1. Open in PyCharm (recommended)
2. Get AI suggestion (manual apply only)
3. Manual resolution
```

**If option 2 selected:**
- Shows suggested resolution
- User reviews and manually applies
- **Never auto-applies**

---

## PyCharm Merge Tool

### Visual 3-Way Merge

**Layout:**
```
+------------------+------------------+------------------+
| Yours (HEAD)     | Base (common)    | Theirs (feature) |
+------------------+------------------+------------------+
|                  Result (to be saved)                  |
+--------------------------------------------------------+
```

**Features:**
- ✅ Syntax highlighting
- ✅ Side-by-side comparison
- ✅ Accept left/right/both buttons
- ✅ Inline editing

**Typical resolution time:** 2-5 minutes per file

### Opening Conflict in PyCharm

**Method 1: From PyCharm**
```
VCS > Git > Resolve Conflicts
Select file → Click "Merge"
```

**Method 2: From conflict-helper.ps1**
```powershell
.\conflict-helper.ps1 conflicted-file.py
# Choose option 1
```

**Method 3: Direct command**
```powershell
pycharm merge conflicted-file.py  # If PyCharm CLI configured
```

---

## Conflict Resolution Workflow

### Step-by-Step Process

**1. Identify conflicts**
```bash
git status
# Shows files with conflicts
```

**2. Check rerere**
```bash
git rerere status
# Shows if rerere resolved any conflicts
```

**3. For remaining conflicts:**

**Option A: PyCharm (recommended)**
```
Open PyCharm → VCS → Resolve Conflicts
```

**Option B: conflict-helper.ps1**
```powershell
.\conflict-helper.ps1 conflicted-file.py
```

**Option C: Manual**
```bash
# Edit file, remove markers
<<<<<<< HEAD
...
=======
...
>>>>>>> feature
```

**4. Mark as resolved**
```bash
git add conflicted-file.py
```

**5. Continue operation**
```bash
git rebase --continue
# or
git merge --continue
```

**6. Verify**
```bash
# Run tests
pytest

# Check changes
git diff HEAD~1
```

---

## Common Conflict Patterns

### Pattern 1: Both Modified Same Function

**Conflict:**
```python
<<<<<<< HEAD
def process_payment(amount, currency="USD"):
    return stripe.charge(amount, currency)
=======
def process_payment(amount, currency="USD"):
    return paypal.charge(amount, currency)
>>>>>>> feature
```

**Resolution strategies:**
1. **Keep yours** - HEAD version is correct
2. **Keep theirs** - Feature version is correct
3. **Merge both** - Support both stripe and paypal
4. **Rewrite** - Better solution combining both

**Example merge:**
```python
def process_payment(amount, currency="USD", provider="stripe"):
    if provider == "stripe":
        return stripe.charge(amount, currency)
    elif provider == "paypal":
        return paypal.charge(amount, currency)
    else:
        raise ValueError(f"Unknown provider: {provider}")
```

### Pattern 2: Import Conflicts

**Conflict:**
```python
<<<<<<< HEAD
from services.auth import authenticate, authorize
=======
from services.authentication import verify_user, check_permissions
>>>>>>> feature
```

**Cause:** File or function renamed

**Resolution:**
```python
# Check if functions are same (just renamed)
from services.authentication import verify_user as authenticate
from services.authentication import check_permissions as authorize
```

### Pattern 3: Deleted vs Modified

**Conflict:**
```
main: Deleted user_model.py (renamed to user.py)
feature: Modified user_model.py (added fields)
```

**Resolution:**
1. Accept deletion
2. Apply modifications to new file (user.py)
3. Update imports in feature branch

---

## Rerere Maintenance

### Clearing Rerere Cache

**When to clear:**
- Incorrect resolution was recorded
- Want to re-resolve from scratch

**Commands:**
```bash
# Clear all rerere resolutions
git rerere clear

# Forget specific resolution
git rerere forget path/to/file.py
```

### Viewing Rerere Status

```bash
# Show files rerere resolved
git rerere status

# Show diff of what rerere did
git rerere diff
```

---

## Advanced: Conflict Prevention

### Rebase Frequently

**Daily rebase:**
```bash
cd feature-auth
git fetch origin
git rebase origin/main
```

**Benefits:**
- ✅ Smaller conflicts (recent changes only)
- ✅ Easier to resolve (fresh in memory)
- ✅ Rerere builds resolution history

### Communication

**For solo developers:**
- Plan feature order to minimize overlap
- Finish one feature before starting another

**For teams:**
- Communicate about file ownership
- Avoid simultaneous edits to same files

### Modular Code

**Design for minimal conflicts:**
```python
# Good: Separate files
auth_service.py
payment_service.py
user_service.py

# Bad: Everything in one file
services.py  # High conflict probability
```

---

## Confidence Scores: Why Unreliable for Auto-Resolution

### AI Confidence Analysis

**Example AI output:**
```json
{
  "resolution": "def calculate_total(items): return sum(item.price * item.quantity for item in items)",
  "confidence": 0.85,
  "reasoning": "Added quantity to match feature branch pattern"
}
```

**Problems:**
1. **Threshold tuning** - Is 0.85 high enough? Depends on context
2. **Context limitations** - AI doesn't know business requirements
3. **Test coverage assumptions** - Assumes tests will catch mistakes
4. **Silent failures** - High confidence can still be wrong

**Example failure:**
```python
# AI suggests (confidence: 0.90):
def calculate_discount(price, user):
    return price * 0.1  # 10% for all users

# Correct resolution:
def calculate_discount(price, user):
    if user.is_premium:
        return price * 0.2  # 20% for premium
    return price * 0.1  # 10% for regular
```

AI missed business logic because it's not in code context!

---

## See Also

- **`merge-strategy.md`** - Rebase-first workflow
- **`pycharm-integration.md`** - IDE conflict resolution setup
- **`best-practices.md`** - Conflict prevention strategies

---

**Last Updated:** 2025-11-01
**Status:** Production validated
