# Recursive README Generation

**Automatically generate and maintain README files for folder structure.**

---

## Overview

Based on `.readme-config.json` settings, automatically generate README files for selected folders using Claude + Codex cross-validation.

**Workflow:**
```
1. Parse .readme-config.json
2. Detect changed folders (git diff)
3. Filter by config rules
4. For each folder:
   Round 1: Claude writes README
   Round 2: Codex reviews and suggests improvements
   Round 3: Claude applies feedback (if enabled)
5. Save README with metadata
```

---

## Configuration

**Create `.readme-config.json` in project root:**

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
  ],
  "validation": {
    "rounds": 2,
    "adaptive_rounds": true,
    "critical_folders": ["src/models/", "src/services/"]
  }
}
```

**Strategies:**
- `"hybrid"` - Only targets + rule-based (recommended)
- `"all"` - All folders except exclude (⚠️ expensive)
- `"manual"` - Only explicit targets

**Full spec:** See `docs/readme-config-spec.md`

---

## Usage

**Generate/Update READMEs:**
```bash
/documentation-manager --recursive-readme
```

**Check existing READMEs:**
```bash
/documentation-manager --check-recursive
```

**Initialize config:**
```bash
/documentation-manager --init-config
```

---

## Validation Rounds

**Round 1: Claude (Writer)**
- Analyzes folder structure
- Reads code files
- Generates README draft
- Focuses on: purpose, structure, usage

**Round 2: Codex (Reviewer)**
- Reviews Claude's draft
- Checks technical accuracy
- Suggests improvements
- Flags missing information

**Round 3: Claude (Refiner)** (optional)
- Applies Codex feedback
- Polishes formatting
- Final quality check

**Adaptive Rounds:**
- Critical folders: 3 rounds
- Small changes (<10 files): 2 rounds
- Standard folders: config.validation.rounds

---

## README Template

**Auto-generated READMEs include:**

```markdown
<!-- Auto-generated README -->
<!-- Generated: 2025-11-04 12:00:00 -->
<!-- Verified by: Codex (Round 2) -->
<!-- Confidence: 85% -->
<!-- Last human review: null -->

# Folder Name

## Purpose
Brief description of what this folder contains.

## Structure
```
folder/
├── file1.py
├── file2.py
└── subfolder/
```

## Components
- **file1.py** - Description
- **file2.py** - Description

## Usage
```python
from folder import Component
component = Component()
```

## Dependencies
- Dependency 1
- Dependency 2

## Notes
Additional context or warnings
```

---

## Cost Estimation

**Per folder (2-round validation):**
- Claude (Round 1): ~$0.02
- Codex (Round 2): ~$0.03
- **Total**: ~$0.05/folder

**Example project (15 folders):**
- Initial generation: $0.75
- Updates (5 folders/week): $0.25/week = $1/month
- **Estimated monthly cost**: $1-5

**Large project (50 folders):**
- Initial: $2.50
- Updates: $5-10/month
- **⚠️ Monitor costs carefully**

---

## Best Practices

**Do's ✅**

1. **Start with 5-10 critical folders**
   - Test workflow first
   - Measure costs
   - Expand gradually

2. **Use adaptive_rounds = true**
   - Save costs on minor changes
   - Reserve 3-rounds for critical code

3. **Review monthly**
   - Sample 10% READMEs
   - Update config based on feedback
   - Adjust targets/exclude lists

4. **Track metadata**
   - Check confidence scores
   - Note low-confidence READMEs
   - Schedule human review

**Don'ts ❌**

1. **Don't use strategy = "all"**
   - Unless project < 20 folders
   - Cost explodes quickly

2. **Don't skip exclude list**
   - Always exclude: node_modules, .git, tmp, tests
   - Prevents wasted API calls

3. **Don't trust blindly**
   - LLMs make mistakes
   - Critical folders need human verification
   - Sample regularly

4. **Don't set rounds = 3 globally**
   - Use adaptive_rounds instead
   - Too expensive for all folders

---

## Troubleshooting

**"Too many READMEs generated"**
```
1. Check strategy (should be "hybrid", not "all")
2. Review targets list (too broad?)
3. Expand exclude list
4. Increase min_files threshold
```

**"Critical folder skipped"**
```
1. Ensure folder in targets
2. Check not in exclude
3. Verify max_depth setting
4. Check require_code_files rule
```

**"API costs too high"**
```
1. Set adaptive_rounds = true
2. Reduce rounds to 1-2
3. Expand exclude list
4. Use manual strategy for critical folders only
```

**"README quality poor"**
```
1. Increase rounds for critical_folders
2. Add to validation.critical_folders
3. Check Codex feedback in logs
4. Schedule human review
```

---

## Integration with CI

**Recommended: CI stage (not pre-commit)**

```yaml
# .github/workflows/docs.yml
name: Update READMEs

on:
  push:
    branches: [main, develop]

jobs:
  update-readmes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Generate READMEs
        run: |
          claude /documentation-manager --recursive-readme
      - name: Commit changes
        run: |
          git add **/README.md
          git commit -m "docs: update auto-generated READMEs" || echo "No changes"
          git push
```

**Why CI, not pre-commit:**
- ✅ Doesn't block developer workflow
- ✅ Async processing
- ✅ Centralized cost tracking
- ✅ Easier debugging

---

**Last Updated:** 2025-11-04
