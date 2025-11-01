# PyCharm Integration Guide

Complete guide for setting up and using PyCharm with git worktrees on Windows.

---

## Initial Setup (Per Worktree)

### Step 1: Open Worktree as Project

```
File > Open > C:\ws\my-project\feature-auth
```

**Important:** Open as **separate project**, not "Attach to Current Project"

### Step 2: Configure Python Interpreter

```
Settings > Project > Python Interpreter
> Add Interpreter > Add Local Interpreter
> Existing environment
> Select: C:\ws\my-project\feature-auth\.venv\Scripts\python.exe
```

**Verify:**
- ✅ Interpreter shows correct path
- ✅ Packages list shows installed dependencies
- ✅ "Inherit global site-packages" is OFF

### Step 3: Configure Project Structure

```
Settings > Project > Project Structure
> Mark src/ as "Sources Root" (blue folder)
> Mark tests/ as "Tests" (green folder)
```

### Step 4: Install EnvFile Plugin (for .env.local)

```
Settings > Plugins
> Search "EnvFile"
> Install > Restart PyCharm
```

**Configure:**
```
Run > Edit Configurations
> Select configuration
> EnvFile tab > Enable
> Add .env.local file
```

### Step 5: Verify VCS Root

```
Settings > Version Control
> Should show only: C:\ws\my-project\feature-auth
```

**If multiple roots shown:**
- Remove other worktree roots
- Keep only current worktree

---

## Daily Workflow

### Running Tests

**Option 1: Run Configuration**
```
Run > Run 'pytest' (created automatically)
```

**Option 2: Right-click**
```
Right-click test file or directory
> Run 'pytest in ...'
```

**Option 3: Terminal**
```
# PyCharm automatically activates .venv in terminal
pytest
```

### Debugging

**Set breakpoints:**
- Click gutter next to line number

**Run debugger:**
```
Right-click test
> Debug 'test_name'
```

**Features:**
- ✅ Step through code
- ✅ Inspect variables
- ✅ Evaluate expressions
- ✅ Set conditional breakpoints

### Git Operations

**Commit:**
```
Ctrl+K (Windows)
> Select files
> Write commit message
> Commit
```

**Push:**
```
Ctrl+Shift+K (Windows)
> Select branch
> Push
```

**Merge Tool:**
```
VCS > Git > Resolve Conflicts
> Select file
> Click "Merge"
```

---

## Troubleshooting

### Issue 1: Wrong Python Interpreter

**Symptoms:**
- Import errors despite packages installed
- Tests fail with ModuleNotFoundError
- Packages don't appear in Project view

**Solution:**
```
Settings > Python Interpreter
> Remove incorrect interpreter
> Add Local Interpreter
> Select correct .venv\Scripts\python.exe
```

**Verify:**
```python
# In Python Console
import sys
print(sys.executable)
# Should show: C:\ws\my-project\feature-auth\.venv\Scripts\python.exe
```

### Issue 2: Multiple VCS Roots

**Symptoms:**
- Commit dialog shows files from other worktrees
- Version Control tool window confusing
- Git operations target wrong worktree

**Solution:**
```
Settings > Version Control
> Unregister all roots
> Add only current worktree root
```

**Verify:**
```
VCS > Git > Show History
# Should show only current worktree's branch
```

### Issue 3: Tests Not Discovered

**Symptoms:**
- pytest doesn't find tests
- Green play button missing from test functions

**Solutions:**

**A. Wrong working directory:**
```
Run > Edit Configurations > pytest
> Working directory: C:\ws\my-project\feature-auth
```

**B. Wrong test framework:**
```
Settings > Tools > Python Integrated Tools
> Default test runner: pytest
```

**C. Tests directory not marked:**
```
Settings > Project Structure
> Mark tests/ as "Tests" (green folder)
```

### Issue 4: Environment Variables Not Loaded

**Symptoms:**
- KeyError on env vars
- Tests pass in terminal, fail in PyCharm

**Solution:**
```
Settings > Plugins > Install "EnvFile"

Run > Edit Configurations
> EnvFile tab > Enable
> Add: .env.local
```

**Alternative (without plugin):**
```
Run > Edit Configurations
> Environment variables: [Click folder icon]
> Add variables manually
```

### Issue 5: Import Errors Despite Package Installed

**Symptoms:**
```python
from mypackage import something
# ModuleNotFoundError despite pip install mypackage
```

**Causes:**
1. **Wrong interpreter selected**
2. **Sources root not marked**
3. **Editable install not done**

**Solutions:**

**A. Check interpreter:**
```powershell
# In terminal
pip list | grep mypackage
# If not shown, wrong venv active
```

**B. Mark sources root:**
```
Settings > Project Structure
> Mark src/ as "Sources Root"
```

**C. Editable install:**
```powershell
pip install -e .
# If project has setup.py or pyproject.toml
```

### Issue 6: PyCharm Indexing Slow

**Symptoms:**
- PyCharm freezes during indexing
- "Indexing..." notification stuck

**Causes:**
- Multiple worktrees in same window
- Large directories (node_modules, .venv) not excluded

**Solutions:**

**A. Exclude directories:**
```
Right-click .venv/ > Mark Directory as > Excluded
Right-click __pycache__/ > Mark Directory as > Excluded
```

**B. Increase memory:**
```
Help > Edit Custom VM Options
> Add: -Xmx4096m
> Restart PyCharm
```

### Issue 7: Terminal Not Activating venv

**Symptoms:**
```powershell
# Expected:
(.venv) PS C:\ws\my-project\feature-auth>

# Actual:
PS C:\ws\my-project\feature-auth>
```

**Solution:**
```
Settings > Tools > Terminal
> Activate virtualenv: ✓ (enabled)
```

**Manual activation:**
```powershell
.venv\Scripts\Activate.ps1
```

---

## Multiple Worktree Windows

### Workflow

**Open main + 2 features:**
```
Window 1: C:\ws\my-project\main
Window 2: C:\ws\my-project\feature-auth
Window 3: C:\ws\my-project\feature-payment
```

**Benefits:**
- ✅ Work on feature while running tests in main
- ✅ Compare implementations side-by-side
- ✅ Quick context switching

**Tips:**
1. **Distinct window titles** - Rename projects in Project view
2. **Different color schemes** - Easier to identify
3. **Separate run configurations** - No conflicts

### Renaming Project Display

```
Project view > Right-click root
> Rename Module
> Enter: "Main Branch" or "Feature: Auth"
```

**Result:**
- Easier to identify in taskbar
- Clearer window management

---

## Performance Optimization

### Exclude Unnecessary Directories

**Always exclude:**
```
.venv/
__pycache__/
.pytest_cache/
.mypy_cache/
*.egg-info/
```

**How:**
```
Right-click directory
> Mark Directory as > Excluded
```

### Disable Unused Plugins

```
Settings > Plugins
> Disable unused plugins
> Restart PyCharm
```

**Recommended to keep:**
- Python
- Git
- EnvFile
- pytest

**Can disable (if unused):**
- Docker
- Database Tools
- JavaScript/TypeScript

### Limit Inspections

```
Settings > Editor > Inspections
> Uncheck inspections you don't need
```

**Keep essential:**
- PEP 8 coding style
- Unreachable code
- Unused imports

**Can disable:**
- Spelling
- Documentation (if not writing docs)

---

## Keyboard Shortcuts (Windows)

### Essential

| Action | Shortcut |
|--------|----------|
| Commit | Ctrl+K |
| Push | Ctrl+Shift+K |
| Run tests | Ctrl+Shift+F10 |
| Debug tests | Ctrl+Shift+D |
| Terminal | Alt+F12 |
| Project view | Alt+1 |
| Version Control | Alt+9 |
| Find in files | Ctrl+Shift+F |
| Go to file | Ctrl+Shift+N |

### Git

| Action | Shortcut |
|--------|----------|
| Show history | Alt+Grave (`) |
| Compare with branch | N/A (menu only) |
| Annotate | N/A (menu only) |

---

## See Also

- **`architecture-decision.md`** - Why separate projects per worktree
- **`merge-strategy.md`** - Using PyCharm merge tool
- **`best-practices.md`** - Daily workflow optimization

---

**Last Updated:** 2025-11-01
**Status:** Production validated
