---
name: documentation-manager
description: Reviews existing documentation quality (docstrings, comments, CHANGELOG) using Codex. Trigger ONLY for "문서 리뷰", "docstring 체크", "review documentation". DO NOT trigger for generating new documentation - that requires explicit user instruction.
---

# Documentation Manager

Review and improve code documentation quality using OpenAI Codex.

---

## When to Use

Trigger when user requests:

**Korean:**
- "문서 리뷰 해줘"
- "docstring 체크해줘"
- "문서화 품질 확인"
- "주석 검토"
- **"전체 문서 검증"** (Comprehensive Validation)

**English:**
- "review documentation"
- "check docstring quality"
- "review code comments"
- "check documentation completeness"
- **"comprehensive documentation validation"** (Full Validation)

**Auto-triggered by:**
- `/pre-commit-full` command (comprehensive validation mode)

---

## Prerequisites

**Required:**
- OpenAI Codex CLI: `npm i -g @openai/codex`
- ChatGPT Plus/Pro subscription
- Codex session script: `~/.claude/scripts/codex-session.sh`

**Verify installation:**
```bash
codex --version
ls ~/.claude/scripts/codex-session.sh
```

---

## Core Review Workflow

### Step 1: Detect Scope

Ask user which documentation to review:
- **All** - Complete documentation audit
- **Docstrings** - Function/class/module docstrings only
- **Comments** - Inline code comments
- **Project Docs** - README, CHANGELOG, API docs
- **Specific Files** - User-specified files

### Step 2: Call Codex for Review

**Full Documentation Audit:**
```bash
~/.claude/scripts/codex-session.sh new "Perform comprehensive documentation review.

Check all aspects:

## Docstrings (Critical)
- [ ] All public functions have docstrings (Google Style)
- [ ] All public classes have docstrings
- [ ] All public modules have module docstring
- [ ] Docstrings include Args, Returns, Raises, Examples
- [ ] Type hints present and documented
- [ ] Examples actually work (can be executed)

## Code Comments (Warning)
- [ ] Comments explain 'why' not 'what'
- [ ] No outdated or incorrect comments
- [ ] Complex logic has explanatory comments
- [ ] Workarounds are documented with reason
- [ ] Security considerations documented
- [ ] Performance optimizations explained

## README.md (Critical)
- [ ] Installation instructions current
- [ ] Usage examples work
- [ ] New features documented
- [ ] Configuration options documented
- [ ] Dependencies list updated
- [ ] Quick Start section exists

## CHANGELOG.md (Warning)
- [ ] User-facing changes listed
- [ ] Breaking changes marked
- [ ] Bug fixes documented
- [ ] Security fixes highlighted
- [ ] Links to issues/PRs included

## TODO Comments (Suggestion)
- [ ] TODOs are actionable (not vague)
- [ ] TODOs have assignee or issue link
- [ ] No TODOs older than 6 months

## API Documentation (if applicable)
- [ ] New endpoints documented
- [ ] Request/response formats shown
- [ ] Authentication requirements clear
- [ ] Error responses documented

Provide:
- Overall score (0-100)
- Critical issues (must fix)
- Warnings (should fix)
- Suggestions (nice to have)
- Top 5 most important improvements
- File-specific findings (file:line)

**IMPORTANT: Write all findings in Korean (한국어로 모든 결과를 작성해주세요)**"
```

**Docstrings Only:**
```bash
~/.claude/scripts/codex-session.sh new "Review docstring quality for all public functions and classes.

Focus on:
- Google Style format compliance
- Completeness (Args, Returns, Raises, Examples)
- Type hints present and accurate
- Examples that actually work
- Edge cases documented

For each missing or poor docstring, provide:
- file:line location
- Current state (missing, incomplete, incorrect)
- Suggested improvement

Score: 0-100 based on coverage and quality

**IMPORTANT: Write all findings in Korean (한국어로 작성)**"
```

**Comments Only:**
```bash
~/.claude/scripts/codex-session.sh new "Review inline code comments quality.

Check for:
- Comments explaining 'why' (not 'what')
- Outdated comments that don't match code
- Complex logic without explanation
- Workarounds documented
- TODO quality (actionable, tracked)

Flag anti-patterns:
- Obvious comments (counter += 1 # increment counter)
- Commented-out code
- Vague TODOs (# TODO: fix this)

Provide file:line for each issue

**IMPORTANT: Write all findings in Korean (한국어로 작성)**"
```

**Project Docs Only:**
```bash
~/.claude/scripts/codex-session.sh new "Review project documentation (README, CHANGELOG, API docs).

README.md:
- [ ] Installation steps work
- [ ] Usage examples are current
- [ ] Configuration documented
- [ ] API reference linked
- [ ] Contributing guidelines exist

CHANGELOG.md:
- [ ] Recent changes documented
- [ ] Breaking changes marked
- [ ] Version format correct

API Documentation (if exists):
- [ ] All endpoints documented
- [ ] Request/response formats clear
- [ ] Authentication requirements shown

List missing or outdated sections

**IMPORTANT: Write all findings in Korean (한국어로 작성)**"
```

### Step 3: Save Review Report

```bash
mkdir -p .doc-reviews
# Save to: .doc-reviews/YYYY-MM-DD-HH-MM-docs-review.md
```

### Step 4: Present Findings

```
📚 Documentation Review Complete!

📊 Overall Score: X/100

🚨 Critical Issues: X
⚠️  Warnings: X
💡 Suggestions: X

Top 5 Improvements:
1. [File] Issue description (file:line)
2. [File] Issue description (file:line)
3. [File] Issue description (file:line)
4. [File] Issue description (file:line)
5. [File] Issue description (file:line)

📄 Full report: .doc-reviews/YYYY-MM-DD-HH-MM-docs-review.md
```

---

## Comprehensive Validation for Pre-Commit (AUTO)

**Automatically triggered by `/pre-commit-full` command.**

This mode runs **ALL available documentation checks** automatically without requiring specific user input. It's designed to be extensible - new validation features added to this skill are automatically included.

### What Gets Checked

**All checks run automatically in this mode:**

1. ✅ **Core Review Workflow**
   - Docstring coverage and quality (Codex)
   - Code comment quality and clarity
   - README.md completeness and accuracy
   - CHANGELOG.md entries (if applicable)

2. ✅ **README Completeness Check**
   - Parse `.readme-config.json` for target folders
   - Check if all target folders have README.md
   - Report missing READMEs

3. ✅ **README Freshness Check**
   - Detect if code files changed but README not updated
   - Compare file modification times
   - Suggest README updates if stale

4. ✅ **Central Index Up-to-date Check**
   - Check if `docs/index.md` exists
   - Verify it includes all current READMEs
   - Suggest regeneration if outdated

5. ✅ **Future Checks**
   - Any new validation added to this skill will automatically run
   - No need to update `/pre-commit-full` command

### Execution Flow

```python
def comprehensive_validation():
    """Run all documentation validations automatically."""

    results = {
        "core_review": None,
        "readme_completeness": None,
        "readme_freshness": None,
        "central_index": None,
    }

    # 1. Core Review (Codex)
    results["core_review"] = run_core_review_workflow(scope="all")

    # 2. README Completeness
    if Path(".readme-config.json").exists():
        config = parse_readme_config()
        missing_readmes = check_readme_completeness(config["targets"])
        results["readme_completeness"] = {
            "missing_count": len(missing_readmes),
            "missing_folders": missing_readmes,
            "status": "PASS" if len(missing_readmes) == 0 else "FAIL"
        }
    else:
        results["readme_completeness"] = {"status": "SKIP", "reason": "No .readme-config.json"}

    # 3. README Freshness
    stale_readmes = check_readme_freshness()
    results["readme_freshness"] = {
        "stale_count": len(stale_readmes),
        "stale_folders": stale_readmes,
        "status": "PASS" if len(stale_readmes) == 0 else "WARNING"
    }

    # 4. Central Index Check
    if Path("docs/index.md").exists():
        index_status = check_central_index_freshness()
        results["central_index"] = index_status
    else:
        results["central_index"] = {"status": "SKIP", "reason": "No docs/index.md"}

    # Future checks automatically added here

    return generate_comprehensive_report(results)
```

### Output Format

**Returned to `/pre-commit-full`:**

```markdown
## Documentation Validation Results

### ✅ Core Review (Codex)
- Overall Score: 85/100
- Docstring Coverage: 78%
- Critical Issues: 2
- Warnings: 5

### ⚠️  README Completeness
- Missing READMEs: 3 folders
  - src/utils/
  - src/helpers/
  - tests/integration/
- **Action**: Generate missing READMEs

### ✅ README Freshness
- All READMEs up-to-date
- Last check: 2025-11-09 10:30

### ⚠️  Central Index
- Status: OUTDATED
- Missing entries: 5 READMEs
- **Action**: Run /docs-generate-index

### Summary
- **Overall Status**: PASS WITH WARNINGS
- **Critical Issues**: 0
- **Warnings**: 3 (missing READMEs, outdated index)
- **Recommendations**:
  1. Generate missing READMEs for 3 folders
  2. Update central index (run /docs-generate-index)
  3. Review 2 critical docstring issues
```

### Auto-Fix Capabilities

**When comprehensive validation finds issues:**

1. **Missing READMEs**: Automatically offer to generate them
   ```
   발견: 3개 폴더에 README 누락
   자동 생성하시겠습니까? (Quality Mode, Codex 검증 포함)
   ```

2. **Outdated Index**: Automatically offer to regenerate
   ```
   docs/index.md가 오래되었습니다
   자동 재생성하시겠습니까?
   ```

3. **Critical Docstring Issues**: Show specific files and lines
   ```
   Critical: src/auth.py:45 - Public function missing docstring
   ```

### Extensibility

**Adding new checks:**

Simply add a new check to this section, and it will automatically run when `/pre-commit-full` invokes comprehensive validation.

**Example - Adding API Documentation Check:**

```python
# 5. API Documentation Check (NEW)
if Path("docs/api/").exists():
    api_status = check_api_documentation_completeness()
    results["api_docs"] = api_status
```

**No changes needed to `/pre-commit-full`** - it just calls this skill and receives the updated report.

### Quality Standards

**Validation thresholds:**

| Check | Pass | Warning | Fail |
|-------|------|---------|------|
| Docstring Coverage | ≥70% | 50-69% | <50% |
| README Completeness | 100% | - | <100% |
| README Freshness | 0 stale | 1-3 stale | 4+ stale |
| Central Index | Up-to-date | 1-5 missing | 6+ missing |

---

## Documentation Standards

### Google Style Docstrings (Recommended)

**Function:**
```python
def calculate_total(items: List[float], tax_rate: float = 0.1) -> float:
    """Calculate total price with tax.

    Calculates the sum of all items and applies tax.

    Args:
        items: List of item prices
        tax_rate: Tax rate as decimal (default: 0.1 for 10%)

    Returns:
        Total price after tax

    Raises:
        ValueError: If tax_rate is negative

    Examples:
        >>> calculate_total([10.0, 20.0], tax_rate=0.1)
        33.0

    Note:
        Tax is applied to the subtotal.
    """
```

**Class:**
```python
class UserService:
    """Service for managing user operations.

    Handles user creation, validation, and persistence.

    Attributes:
        database: Database connection
        email_service: Email service for notifications

    Example:
        >>> service = UserService(database, email_service)
        >>> user = service.create_user("Alice", "alice@example.com")
    """
```

**Module:**
```python
"""User management module.

This module provides functionality for user creation, validation,
and persistence.

Typical usage example:

    user_service = UserService(database)
    user = user_service.create_user("Alice", "alice@example.com")
"""
```

### Good Comments vs Bad Comments

```python
# ❌ Bad - states the obvious
# Increment counter by 1
counter += 1

# ✅ Good - explains why
# Increment retry counter to trigger exponential backoff
counter += 1

# ✅ Good - business rule
# Users must wait 24 hours between password changes
# to prevent rapid password cycling attacks
if user.last_password_change > datetime.now() - timedelta(hours=24):
    raise PasswordChangeTooSoonError()

# ✅ Good - workaround
# Workaround for bug in library v1.2.3 where connection
# isn't properly closed. Fixed in v1.3.0.
# TODO: Remove after upgrading to v1.3.0
connection.close()
```

### TODO Comment Standards

```python
# ✅ Good - actionable and tracked
# TODO(alice): Optimize query performance (JIRA-123)
# TODO: Add validation for negative numbers before v2.0 release
# TODO(bob): Handle timezone conversion (see issue #456)

# ❌ Bad - vague and untracked
# TODO: fix this
# TODO: make better
# TODO: refactor
```

---

## Scoring System

| Score | Grade | Meaning | Action |
|-------|-------|---------|--------|
| 90-100 | A | Excellent documentation | ✅ Well documented |
| 80-89 | B | Good documentation | ✅ Minor improvements |
| 70-79 | C | Acceptable | ⚠️ Improve key areas |
| 60-69 | D | Poor documentation | 🔴 Significant work needed |
| 0-59 | F | Severely lacking | 🔴 Major documentation effort |

**Pass Criteria:**
- Score ≥ 70/100
- All public API documented
- README installation/usage current
- No critical documentation gaps

---

## Common Issues to Flag

### Critical (Must Fix)
1. **Missing docstrings** for public functions/classes
2. **README outdated** - installation steps don't work
3. **Undocumented breaking changes**
4. **Missing type hints** on public API
5. **Non-working examples** in documentation

### Warnings (Should Fix)
6. **Incomplete docstrings** - missing Args, Returns, Raises
7. **Outdated comments** that don't match code
8. **No CHANGELOG entry** for user-facing changes
9. **Vague TODOs** without assignee/issue
10. **Complex logic** without explanation

### Suggestions (Nice to Have)
11. **Missing examples** for complex functions
12. **No module docstrings**
13. **Comments stating obvious**
14. **No API documentation** for web services
15. **Missing edge case documentation**

---

## Advanced Usage

### Review Specific Module
```bash
~/.claude/scripts/codex-session.sh new "Review documentation in src/services/user_service.py

Check docstrings, comments, and type hints for this module only.

**Write findings in Korean (한국어로 작성)**"
```

### Generate Documentation
```bash
~/.claude/scripts/codex-session.sh new "Generate missing docstrings for all public functions in src/models/

Use Google Style format with Args, Returns, Examples.

**Write in Korean (한국어로 작성)**"
```

### Update CHANGELOG
```bash
~/.claude/scripts/codex-session.sh new "Review recent commits and update CHANGELOG.md

Categorize changes into Added, Changed, Fixed, Deprecated, Security.

**Write in Korean (한국어로 작성)**"
```

---

## Best Practices

**Do's ✅**

1. **Document public API first**
   - All public functions, classes, modules
   - Type hints on all parameters and returns

2. **Write examples that work**
   - Test examples in docstrings
   - Use doctests when possible

3. **Explain "why" not "what"**
   - Comments should add value
   - Code should be self-explanatory

4. **Keep docs in sync**
   - Update docs when code changes
   - Review documentation in code reviews

**Don'ts ❌**

1. **Don't write obvious comments**
   - `counter += 1  # increment counter` ❌

2. **Don't leave outdated docs**
   - Update or remove if no longer valid

3. **Don't write vague TODOs**
   - Add assignee and issue link

4. **Don't forget CHANGELOG**
   - User-facing changes need changelog entry

---

## Troubleshooting

### "No docstrings found"
- Verify files have Python docstrings
- Check if functions are public (not starting with _)

### "Examples don't work"
- Test docstring examples manually
- Use pytest --doctest-modules to verify

### "Outdated documentation"
- Compare code changes with docs
- Update README/CHANGELOG for each release

---

## Integration with Pre-Commit Review

Use both skills together:

1. **Pre-commit review** - Code quality, structure, security
2. **Documentation manager** - Documentation completeness, quality

```bash
# First: code review
/pre-commit-code-reviewer

# Then: documentation review
/documentation-manager
```

Or use documentation review for major features:
- Before release
- After significant refactoring
- For new public APIs

---

## Recursive README Generation (NEW)

**Automatically generate and maintain README files for folder structure.**

### Quick Start

Generate READMEs for your project folders using Claude + Codex cross-validation:

```bash
# Initialize configuration
/documentation-manager --init-config

# Generate/update READMEs
/documentation-manager --recursive-readme

# Check existing READMEs
/documentation-manager --check-recursive

# Generate central index (NEW)
/documentation-manager --generate-index
```

### Key Features

- **Configuration-driven** - Control which folders via `.readme-config.json`
- **Cross-validation** - Claude writes, Codex reviews, Claude refines
- **Adaptive rounds** - Critical folders get 3 rounds, standard get 2
- **Parallel execution** - Process up to 10 folders simultaneously using Task agents (NEW)
- **Cost-efficient** - ~$0.05/folder with caching and smart detection
- **CI-friendly** - Integrates with GitHub Actions, GitLab CI, etc.
- **Central Index** - Auto-generate `docs/index.md` with categorized links (NEW)

### Example Cost

- **15 folders**: $1-5/month
- **50 folders**: $5-10/month (⚠️ monitor carefully)

### When to Use

- Project has 5-50 folders needing documentation
- README maintenance burden is high
- Team wants consistent documentation format
- Willing to review 10% monthly for quality

**For detailed guides, configuration reference, troubleshooting, and CI integration:**

📖 **See `references/recursive-readme.md`**

---

## Quality Verification Workflow (NEW in v1.5)

**MANDATORY: All documentation must pass quality verification before being accepted.**

### Step 1: Pre-Generation Checklist

**ALWAYS create checklist BEFORE starting documentation generation:**

```markdown
## Documentation Quality Checklist

### Pre-Generation
- [ ] Identify target folders from .readme-config.json
- [ ] Create TodoWrite checklist for each folder
- [ ] Assign each folder to parallel Task agent

### Generation (Per Folder)
- [ ] [folder_name]: Structure complete (all sections present)
- [ ] [folder_name]: Code examples verified for syntax correctness
- [ ] [folder_name]: Security review completed (if applicable)
- [ ] [folder_name]: Metadata added (auto-generated marker, date, maintainer)
- [ ] [folder_name]: Word count ≥ 400 (quality threshold)

### Post-Generation Verification
- [ ] All folders generated successfully
- [ ] Codex automatic verification completed
- [ ] All quality checks passed
- [ ] User approval obtained (if required)
```

### Step 2: Parallel Generation with Checklist Updates

**Each subagent MUST update their assigned checklist items:**

```python
# Main agent creates master checklist
TodoWrite(todos=[
    {"content": f"{folder}: Generate and verify README",
     "activeForm": f"Generating {folder} README",
     "status": "pending"}
    for folder in targets
])

# Launch parallel tasks
for folder in targets:
    Task(
        subagent_type="general-purpose",
        prompt=f"""...Quality Mode prompt...

        **CRITICAL: After saving README:**
        1. Mark your checklist item as completed
        2. Report: SUCCESS + file path + word count
        """,
        description=f"Generate {folder}README.md (Quality Mode)"
    )
```

### Step 3: Codex Automatic Verification

**After all READMEs generated, run automatic quality check:**

```bash
~/.claude/scripts/codex-session.sh new "Verify documentation quality for generated READMEs.

## Folders to Verify
${GENERATED_FOLDERS}

## Quality Checklist (Score each 0-100)

### Structure Compliance (Critical)
- [ ] All mandatory sections present (Purpose, Contents, Key Components, etc.)
- [ ] Proper Markdown formatting
- [ ] Metadata present (auto-generated marker, date, maintainer)

### Content Quality (Critical)
- [ ] Technical accuracy (code examples, explanations)
- [ ] Sufficient detail (≥ 400 words per README)
- [ ] Code examples use proper syntax highlighting

### Best Practices (Warning)
- [ ] Security considerations included (if applicable)
- [ ] Best practices and common pitfalls documented
- [ ] Links to related documentation

## Output Format
For each folder, provide:
- Folder name
- Overall score (0-100)
- Issues found (if any)
- Recommendations

**Fail threshold: < 90/100**" --stdout-only
```

### Step 4: Validation and User Approval

**Review Codex output:**

```markdown
## Quality Verification Results

### Passed (≥ 90/100)
- ✅ src/models/ (Score: 95/100)
- ✅ src/services/ (Score: 92/100)

### Failed (< 90/100)
- ❌ src/api/ (Score: 85/100)
  - Missing: Security considerations
  - Issue: Code examples lack syntax highlighting
  - Recommendation: Regenerate with explicit security section

**Action Required:** Regenerate failed folders before proceeding.
```

**User approval checklist:**

```markdown
## Ready for Commit?

- [ ] All Codex scores ≥ 90/100
- [ ] No critical issues found
- [ ] User has reviewed sample READMEs (at least 2)
- [ ] User confirms quality is acceptable

**User:** Please review generated documentation and confirm approval.
```

### Step 5: Regeneration (If Failed)

**For any folder with score < 90/100:**

```python
# Regenerate with explicit fixes
Task(
    subagent_type="general-purpose",
    prompt=f"""Regenerate README for {failed_folder}.

    **Address these specific issues:**
    {codex_recommendations}

    **Extra emphasis on:**
    - Security considerations (MUST include if applicable)
    - Code example syntax highlighting (MUST use ```language)
    - Comprehensive detail (target ≥ 500 words)

    ...rest of Quality Mode prompt...
    """,
    description=f"Regenerate {failed_folder}README.md (Quality Mode)"
)
```

### Quality Metrics

**Target benchmarks:**

| Metric | Minimum | Target | Excellent |
|--------|---------|--------|-----------|
| Codex Score | 90/100 | 95/100 | 98/100 |
| Word Count | 400 | 500 | 600+ |
| Code Examples | 1 | 2-3 | 4+ |
| Security Notes | If applicable | Always consider | Comprehensive |
| Structure Compliance | 100% | 100% | 100% |

**Failure triggers:**
- ❌ Codex score < 90/100
- ❌ Missing mandatory sections
- ❌ Code examples without syntax highlighting
- ❌ Word count < 400

---

## Central Index Generation (NEW in v1.2)

**Automatically create `docs/index.md` with categorized links to all READMEs.**

### Why You Need This

**Problem**: Agents must read many READMEs to find relevant context
- Token waste reading 50+ READMEs
- Slow response times
- No overview of documentation structure

**Solution**: Central index provides:
- Single entry point (`docs/index.md`)
- Categorized TOC (Architecture, API, Guides)
- Quick reference by task type
- Documentation statistics

### Quick Start

```bash
# Generate central index from existing READMEs
/documentation-manager --generate-index
```

### What It Creates

File: `docs/index.md`

```markdown
<!-- AUTO-GENERATED: Do not edit manually! -->
<!-- Generated: 2025-11-08 23:00:00 -->
<!-- Command: /documentation-manager --generate-index -->

# Project Documentation Index

## 📚 Overview
[Project description from claude.md]

## 🗂️ Documentation Categories

### Architecture
- [System Design](../src/architecture/README.md) - System architecture
- [Data Flow](../src/architecture/data-flow/README.md) - Data flow diagrams

### API Documentation
- [Endpoints](../src/api/README.md) - API endpoints reference

### Guides
- [Getting Started](../docs/guides/README.md) - Quick start guide
- [Best Practices](../docs/guides/best-practices/README.md) - Coding standards

### Source Code
- [Models](../src/models/README.md) - Data models
- [Services](../src/services/README.md) - Business logic

## 🔍 Quick Reference

**Task-based documentation paths:**
- **Authentication** → `src/auth/README.md`, `docs/architecture/security.md`
- **API Endpoints** → `src/api/README.md`, `docs/api/endpoints.md`
- **Data Models** → `src/models/README.md`, `docs/architecture/data-flow.md`
- **Testing** → `tests/README.md`, `docs/guides/testing.md`

## 📊 Documentation Statistics
- Total folders: 15
- Documented folders: 12 (80%)
- Last updated: 2025-11-08
```

### How It Works

1. **Scan READMEs**: Read `.readme-config.json` targets
2. **Categorize**: Group by folder name patterns (architecture/, api/, guides/)
3. **Extract Titles**: Parse first `#` heading from each README
4. **Generate TOC**: Create categorized table of contents
5. **Add Metadata**: Include generation timestamp and statistics

### Categorization Logic

**Auto-categorization by folder path:**

| Folder Pattern | Category | Examples |
|---------------|----------|----------|
| `docs/architecture/`, `src/architecture/` | Architecture | system-design, data-flow |
| `docs/api/`, `src/api/` | API Documentation | endpoints, schemas |
| `docs/guides/`, `docs/tutorials/` | Guides | getting-started, best-practices |
| `src/models/`, `src/*/models/` | Source Code > Models | user, product |
| `src/services/`, `src/*/services/` | Source Code > Services | auth, payment |
| `src/utils/`, `src/helpers/` | Source Code > Utilities | validators, formatters |
| `tests/` | Testing | unit, integration |

**Custom categories** can be defined in `.readme-config.json`:

```json
{
  "index": {
    "categories": {
      "Security": ["src/auth/", "src/security/"],
      "Database": ["src/models/", "src/migrations/"]
    }
  }
}
```

### Merge Conflict Handling

**Strategy**: Treat `docs/index.md` as a generated artifact

**In `.gitignore` (Optional)**:
```
docs/index.md
```

**Or commit it** and handle conflicts:
```bash
# On merge conflict, regenerate
git checkout --theirs docs/index.md  # Or --ours
/documentation-manager --generate-index
git add docs/index.md
```

**Recommended**: Commit `docs/index.md` to track documentation coverage over time

### Agent Usage Guide

**Add to `claude.md`:**

```markdown
## Documentation Navigation

**New to this project? Start here:**

1. **Read** `docs/index.md` - Central documentation index
2. **Identify** relevant category (Architecture, API, Guides)
3. **Navigate** to specific README for your task
4. **Deep dive** into related docs as needed

**Example workflow for adding authentication:**
1. Check `docs/index.md` → "Quick Reference" section
2. Follow link to `src/auth/README.md`
3. Review `docs/architecture/security.md` for context
4. Implement feature

**Optimization**: Only read READMEs relevant to your task (use index categories)
```

### CI Integration

**GitHub Actions:**

```yaml
name: Update Documentation Index

on:
  push:
    paths:
      - '**/README.md'
      - '.readme-config.json'

jobs:
  update-index:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Generate Index
        run: |
          # Assuming documentation-manager CLI exists
          documentation-manager --generate-index

      - name: Commit if changed
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add docs/index.md
          git diff --staged --quiet || git commit -m "docs: update documentation index [skip ci]"
          git push
```

### Cost & Performance

- **Generation time**: ~5-15 seconds (depending on folder count)
- **Cost**: ~$0.01 per run (Codex for README scanning)
- **Frequency**: Run on README changes (automated via CI)

### Limitations

- **Manual categorization**: Complex projects may need custom category config
- **Not semantic**: Groups by folder names, not content analysis
- **README-only**: Only indexes existing READMEs (won't discover undocumented folders)

### Advanced: Task-Based Priority Mapping

**For token optimization**, add task-to-doc mapping:

```json
{
  "index": {
    "task_mapping": {
      "auth": ["src/auth/README.md", "docs/architecture/security.md"],
      "api": ["src/api/README.md", "docs/api/endpoints.md"],
      "database": ["src/models/README.md", "docs/architecture/data-flow.md"]
    }
  }
}
```

**Agent can then**:
1. Identify task type (e.g., "add authentication")
2. Look up in `task_mapping`
3. Read only 2-3 READMEs instead of 50+

**Token savings**: 80-90% (example: 100K tokens → 10-20K tokens)

---

## Parallel Execution (NEW in v1.3)

**Generate multiple READMEs simultaneously using Task agents.**

### How It Works

When processing `--recursive-readme`, use **Task tool multiple times** to launch parallel agents:

```python
# Automatic parallelization (RECOMMENDED)
# Just launch multiple Task agents - Claude Code handles scheduling

targets = parse_readme_config()  # ["src/models/", "src/services/", ...]

# Launch Task agent for each folder (in single response)
for folder in targets:
    Task(
        subagent_type="general-purpose",
        prompt=f"""Generate README for {folder}.

        Follow .readme-config.json rules.
        Use adaptive validation (2-3 rounds).
        Save to {folder}README.md

        Output only: SUCCESS or ERROR with details.""",
        description=f"Generate {folder}README.md"
    )

# Claude Code automatically:
# - Runs up to 10 tasks in parallel
# - Queues remaining tasks
# - Executes queued tasks as slots become available
```

### Concurrency Limits

**Key specifications** (based on Claude Code internals):

- **Maximum concurrent tasks**: 10
- **Queue size**: Unlimited (auto-managed)
- **Scheduling**: Dynamic (don't specify parallelism level)
- **Scalability**: 100+ folders supported (10 at a time)

**Example:**
- 15 folders → First 10 run in parallel, next 5 queued
- Total time: ~20-30 seconds (vs 5 minutes sequential)

### Quality-First Execution (Default)

**All documentation generation uses Quality Mode by default.**

**Philosophy:** Quality is never compromised for speed. Comprehensive, accurate documentation is the foundation of maintainable codebases.

#### Quality Mode (Default & Only Mode)

**Mandatory Quality Standards:**
- ✅ 100% guideline compliance
- ✅ Comprehensive code examples with proper syntax highlighting
- ✅ Security notes and best practices
- ✅ Complete metadata (auto-generated marker, date, maintainer)
- ✅ Technical accuracy verification
- ✅ 10x more detailed than basic structure (avg 546 words/file)

**Implementation Pattern:**

```python
# IMPORTANT: Always create checklist BEFORE generating documentation
# Each subagent must update their assigned checklist items

for folder in targets:
    Task(
        subagent_type="general-purpose",
        prompt=f"""Generate high-quality README for {folder}.

        **CRITICAL: Follow documentation-manager skill guidelines (Quality Mode):**

        1. **Structure (MANDATORY):**
           - # [Folder Name]
           - **Purpose**: 1-2 sentences explaining folder's role
           - **Contents**: Bullet list of files with brief descriptions
           - **Key Components**: Classes/functions with signatures and descriptions
           - **Usage Examples**: Code snippets if applicable
           - **Dependencies**: Related folders or external libraries

        2. **Quality Standards (MANDATORY):**
           - Clear, concise language
           - Technical accuracy (verify all code examples)
           - Code examples use triple backticks with language specifier
           - Links to related documentation (when applicable)
           - Security considerations (if relevant)
           - Best practices and common pitfalls

        3. **Metadata (MANDATORY):**
           - Add: <!-- Auto-generated by Claude Code -->
           - Add: **Last Updated**: [current date]
           - Add: **Maintainer**: Claude Code

        4. **Quality Verification (MANDATORY):**
           - All sections present and complete
           - Code examples tested for syntax correctness
           - Security review completed (if applicable)
           - Checklist item marked as completed

        Save to {folder}README.md

        **Update your assigned checklist item when complete.**
        Output: SUCCESS with file path or ERROR with details""",
        description=f"Generate {folder}README.md (Quality Mode)",
        model="haiku"
    )
```

**Performance:** ~212s for 3 folders (quality over speed)
**Quality:** 100/100 (full guideline compliance guaranteed)

### Best Practices

**✅ DO:**
- **ALWAYS create TodoWrite checklist BEFORE starting** (mandatory)
- Use Quality Mode for all documentation (only mode available)
- Launch all Task agents in single response (parallel execution)
- Let Claude Code manage scheduling (automatic queuing)
- Run Codex verification after generation (mandatory)
- Obtain user approval before committing (recommended)

**❌ DON'T:**
- Skip checklist creation (violates quality-first principle)
- Generate documentation without quality verification
- Commit documentation with Codex score < 90/100
- Specify explicit parallelism level (inefficient batching)
- Mix parallel and sequential logic (confusing)

### Performance

| Folders | Sequential | Parallel (10 max) | Speedup |
|---------|-----------|-------------------|---------|
| 5       | 1.5 min   | 20 sec            | 4.5x    |
| 10      | 3 min     | 20 sec            | 9x      |
| 15      | 5 min     | 30 sec            | 10x     |
| 50      | 15 min    | 2 min             | 7.5x    |
| 100     | 30 min    | 4 min             | 7.5x    |

**Cost**: Identical to sequential (same API calls)

### Example Prompts (For Users)

**Standard Workflow (Only Available Mode):**
```
Generate high-quality READMEs for folders in .readme-config.json.

**Requirements:**
1. Create TodoWrite checklist BEFORE starting (mandatory)
2. Use parallel Task agents with full documentation-manager guidelines
3. Include code examples, security notes, and best practices
4. Each subagent updates their checklist item when complete
5. Run Codex verification after all generation completes
6. Only accept documentation with Codex score ≥ 90/100

Target folders: src/models/, src/services/, src/api/

Launch all simultaneously and report quality verification results.
```

**With Explicit Quality Assurance:**
```
Generate comprehensive READMEs with quality-first approach.

**Workflow:**
1. Create master checklist (TodoWrite) for all target folders
2. Launch parallel Task agents (Quality Mode - mandatory)
3. Each agent generates README and marks checklist complete
4. Run Codex automatic verification
5. Show verification results (pass/fail with scores)
6. Regenerate any folder with score < 90/100
7. Request user approval before committing

Target: All folders in .readme-config.json
Quality threshold: 90/100 minimum (Codex score)
```

**For Large Projects (10+ folders):**
```
Generate quality documentation for large project (15+ folders).

**Note:** Quality Mode is the only available mode. For large projects:
- Use parallel execution (up to 10 concurrent tasks)
- Remaining tasks automatically queued
- Total time: ~2-4 minutes for 15 folders (vs 15 minutes sequential)
- Quality guaranteed: 100% guideline compliance

Proceed with quality-first workflow and Codex verification.
```

### Troubleshooting

**"Some tasks failed":**
- Check individual task error messages
- Retry failed folders individually
- Verify .readme-config.json is valid

**"Takes same time as sequential":**
- Verify multiple Task calls in single response
- Check that folders are independent (no shared files)
- Ensure not throttling with explicit parallelism level

### Source

Parallelization based on [Claude Code Subagent Deep Dive](https://cuong.io/blog/2025/06/24-claude-code-subagent-deep-dive) (Cuong Tham, June 2025)

---

## Limitations

**This skill cannot:**
- Auto-generate perfect docstrings (review only)
- Run doctests (use pytest separately)
- Replace human review for complex docs
- Detect all documentation issues
- Guarantee 100% accurate READMEs (LLM limitations)
- Scale to 100+ folders economically (use throttling for 50+)

**Best practice:** Use as a checklist, verify critical findings manually.

---

**Version:** 1.6 (Comprehensive Auto-Validation for Pre-Commit)
**Last Updated:** 2025-11-09

**Changelog:**
- v1.6: **Comprehensive Validation** - Added auto-triggered validation mode for `/pre-commit-full`, extensible architecture
- v1.5: **Quality-first redesign** - Removed Fast Mode, added mandatory Codex verification, checklist-driven workflow
- v1.4: Added Quality Mode (embedded guidelines) & Fast Mode (speed priority)
- v1.3: Added Parallel Execution (up to 10 concurrent tasks)
- v1.2: Added Central Index Generation
- v1.1: Added Recursive README Generation
- v1.0: Initial documentation review functionality
