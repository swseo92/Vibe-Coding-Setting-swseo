# .readme-config.json Specification

**Version:** 1.0
**Purpose:** Control which folders get automatic README generation/updates

---

## File Location

```
project-root/
├── .readme-config.json    # ✅ Root level
├── src/
└── tests/
```

Place at project root alongside `.gitignore`, `package.json`, etc.

---

## Schema

```json
{
  "version": "1.0",
  "strategy": "hybrid" | "all" | "manual",
  "targets": ["folder1/", "folder2/"],
  "exclude": ["folder3/", "folder4/"],
  "rules": {
    "min_files": 5,
    "min_subfolders": 2,
    "max_depth": 3,
    "require_code_files": true
  },
  "validation": {
    "rounds": 1 | 2 | 3,
    "adaptive_rounds": true,
    "critical_folders": ["src/models/", "src/services/"]
  },
  "metadata": {
    "include_generation_info": true,
    "include_confidence_score": true,
    "last_human_review": "YYYY-MM-DD"
  }
}
```

---

## Fields

### `version` (required)
- **Type:** String
- **Default:** `"1.0"`
- **Description:** Config file version for future compatibility

### `strategy` (required)
- **Type:** Enum
- **Values:**
  - `"hybrid"` - Only targets + rules (recommended)
  - `"all"` - All folders except exclude
  - `"manual"` - Only explicit targets
- **Default:** `"hybrid"`

### `targets` (required if strategy = hybrid/manual)
- **Type:** Array of strings
- **Description:** Explicit folders to include
- **Example:**
  ```json
  [
    "src/",
    "src/models/",
    "src/services/",
    "src/api/"
  ]
  ```
- **Notes:**
  - Trailing slash recommended
  - Paths relative to project root

### `exclude` (optional)
- **Type:** Array of strings
- **Description:** Folders to always skip
- **Example:**
  ```json
  [
    "node_modules/",
    ".git/",
    "tmp/",
    "__pycache__/",
    "tests/",
    "src/utils/",
    "src/helpers/"
  ]
  ```
- **Notes:**
  - Takes precedence over targets
  - Useful for excluding generated/vendor code

### `rules` (optional)
- **Type:** Object
- **Description:** Automatic inclusion rules

#### `rules.min_files`
- **Type:** Integer
- **Default:** 5
- **Description:** Minimum files in folder to qualify

#### `rules.min_subfolders`
- **Type:** Integer
- **Default:** 2
- **Description:** Minimum subfolders to qualify

#### `rules.max_depth`
- **Type:** Integer
- **Default:** 3
- **Description:** Maximum folder depth from root
- **Example:** `src/services/auth/` = depth 3

#### `rules.require_code_files`
- **Type:** Boolean
- **Default:** true
- **Description:** Folder must contain code files (.py, .js, .ts, etc.)

### `validation` (optional)
- **Type:** Object
- **Description:** LLM validation settings

#### `validation.rounds`
- **Type:** Integer (1-3)
- **Default:** 2
- **Description:** Number of LLM validation rounds
  - `1` = Claude only (fast, cheap)
  - `2` = Claude → Codex (recommended)
  - `3` = Claude → Codex → Claude (thorough, expensive)

#### `validation.adaptive_rounds`
- **Type:** Boolean
- **Default:** true
- **Description:** Adjust rounds based on folder importance
- **Logic:**
  ```
  if folder in critical_folders:
      rounds = 3
  elif file_changes < 10:
      rounds = 2
  else:
      rounds = validation.rounds
  ```

#### `validation.critical_folders`
- **Type:** Array of strings
- **Default:** `[]`
- **Description:** Always use max rounds for these folders

### `metadata` (optional)
- **Type:** Object
- **Description:** README metadata settings

#### `metadata.include_generation_info`
- **Type:** Boolean
- **Default:** true
- **Description:** Add generation timestamp/version to README

#### `metadata.include_confidence_score`
- **Type:** Boolean
- **Default:** true
- **Description:** Show LLM confidence score (0-100%)

#### `metadata.last_human_review`
- **Type:** String (YYYY-MM-DD)
- **Default:** null
- **Description:** Last human review date

---

## Example Configs

### Minimal (Hybrid)

```json
{
  "version": "1.0",
  "strategy": "hybrid",
  "targets": [
    "src/",
    "src/models/",
    "src/services/",
    "src/api/"
  ],
  "exclude": [
    "tmp/",
    "tests/",
    "src/utils/"
  ]
}
```

### Complete (Hybrid with Rules)

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
    "last_human_review": "2025-11-04"
  }
}
```

### All Folders (Not Recommended)

```json
{
  "version": "1.0",
  "strategy": "all",
  "exclude": [
    "node_modules/",
    ".git/",
    "tmp/",
    "__pycache__/"
  ],
  "validation": {
    "rounds": 2,
    "adaptive_rounds": true
  }
}
```

---

## Validation Logic

**Folder inclusion decision tree:**

```
1. Check exclude list
   ├─ In exclude? → SKIP
   └─ Not in exclude? → Continue

2. Check strategy
   ├─ "manual" → Check targets
   │  ├─ In targets? → INCLUDE
   │  └─ Not in targets? → SKIP
   │
   ├─ "hybrid" → Check targets OR rules
   │  ├─ In targets? → INCLUDE
   │  └─ Check rules:
   │     ├─ Files >= min_files? → INCLUDE
   │     ├─ Subfolders >= min_subfolders? → INCLUDE
   │     ├─ Depth <= max_depth? → Continue
   │     └─ Has code files? → INCLUDE
   │
   └─ "all" → INCLUDE (unless excluded)
```

---

## Usage in Documentation Manager

**Workflow:**

```bash
# 1. Parse config
config = read_json(".readme-config.json")

# 2. Get changed folders (from git diff)
changed_folders = git_diff_folders()

# 3. Filter by config
for folder in changed_folders:
    if should_generate_readme(folder, config):
        readme = generate_readme(folder, config.validation.rounds)
        save_readme(folder, readme)
```

**Example:**

```bash
# User commits changes to src/services/auth/
# Config has targets = ["src/services/"]
# → README generated/updated for src/services/

# User commits changes to src/utils/helpers/
# Config has exclude = ["src/utils/"]
# → README NOT generated
```

---

## Best Practices

**Do's ✅**

1. **Start small**
   - Begin with 5-10 critical folders
   - Expand gradually

2. **Use exclude liberally**
   - Exclude vendor/generated code
   - Exclude test folders
   - Exclude utility folders

3. **Set adaptive_rounds = true**
   - Save cost on minor changes
   - Use max rounds for critical folders

4. **Track human reviews**
   - Update `last_human_review` monthly
   - Ensures quality feedback loop

**Don'ts ❌**

1. **Don't use strategy = "all"**
   - Unless project is < 20 folders
   - Cost/complexity explodes

2. **Don't set min_files too low**
   - 2-3 files = too granular
   - 5+ files = reasonable threshold

3. **Don't set rounds = 3 globally**
   - Use adaptive_rounds instead
   - Reserve for critical_folders

4. **Don't skip exclude list**
   - Always exclude node_modules, .git, tmp
   - Prevents wasted API calls

---

## Migration Guide

**From manual to hybrid:**

```json
// Before: No config (manual)

// After: Add config
{
  "version": "1.0",
  "strategy": "hybrid",
  "targets": ["src/", "src/models/", "src/services/"],
  "exclude": ["tmp/", "tests/"]
}
```

**From hybrid to all (not recommended):**

```json
// Before: Hybrid
{
  "strategy": "hybrid",
  "targets": ["src/models/", "src/services/"]
}

// After: All (⚠️ check cost first!)
{
  "strategy": "all",
  "exclude": ["node_modules/", ".git/", "tmp/", "tests/", "src/utils/"]
}
```

---

## Troubleshooting

**"Too many READMEs generated"**
- Check strategy (should be `"hybrid"`, not `"all"`)
- Review exclude list
- Increase `min_files` threshold

**"Critical folder skipped"**
- Ensure folder in `targets`
- Check not in `exclude`
- Verify `max_depth` setting

**"API costs too high"**
- Set `adaptive_rounds = true`
- Reduce `rounds` to 1-2
- Expand exclude list

**"README quality poor"**
- Increase `rounds` for critical_folders
- Add to `validation.critical_folders`
- Schedule human review

---

**Version:** 1.0
**Last Updated:** 2025-11-04
