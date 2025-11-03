# Claude.md Quality Validation Checklist

## Scoring Rubric

**Overall Score Calculation:**
- Project Overview: 15%
- Directory Structure: 25%
- Development Rules: 20%
- Dependencies & Configuration: 15%
- Workflows & Commands: 15%
- Consistency & Formatting: 10%

**Score Ranges:**
- 90-100: Excellent - Ready to commit
- 75-89: Good - Minor improvements recommended
- 60-74: Fair - Important issues to address
- Below 60: Poor - Critical updates required

---

## Category 1: Project Overview Completeness (15%)

**Checklist:**

- [ ] **Project name clearly stated** (3 points)
  - Project name appears in title or first section
  - Name matches repository/directory name

- [ ] **Purpose and scope defined** (5 points)
  - Clear 1-3 sentence project description
  - Primary use case or problem it solves
  - Target audience (if applicable)

- [ ] **Key features or capabilities listed** (4 points)
  - Main features enumerated
  - Technology stack mentioned
  - Distinguishing characteristics noted

- [ ] **Project status indicated** (3 points)
  - Development stage (prototype, production, etc.)
  - Version number or release status
  - Maintenance status (active, deprecated, etc.)

**Scoring:**
- 13-15 points: Excellent
- 10-12 points: Good
- 7-9 points: Fair
- Below 7: Poor

---

## Category 2: Directory Structure Accuracy (25%)

**Checklist:**

- [ ] **Directory tree documented** (8 points)
  - Complete tree structure shown
  - Uses proper formatting (├──, └──, etc.)
  - Includes all major directories

- [ ] **Directory tree matches reality** (10 points)
  - Every documented directory exists
  - No major directories missing from documentation
  - Path separators correct for platform

- [ ] **Directory purposes explained** (5 points)
  - Comments describe what each major directory contains
  - Special directories (`.claude/`, `.specify/`, etc.) explained
  - Module organization rationale provided

- [ ] **File examples included** (2 points)
  - Key files shown in structure
  - Configuration files highlighted
  - Entry points identified

**Validation Commands:**
```bash
# Generate actual structure
ls -R > actual_structure.txt

# Compare with documented structure
# Look for discrepancies
```

**Scoring:**
- 22-25 points: Excellent
- 17-21 points: Good
- 13-16 points: Fair
- Below 13: Poor

**Common Issues:**
- ❌ Documented directories don't exist
- ❌ New directories not documented
- ❌ Outdated structure from old project version
- ❌ Missing explanation for non-obvious directories

---

## Category 3: Development Rules Clarity (20%)

**Checklist:**

- [ ] **Coding conventions specified** (5 points)
  - Style guide referenced (PEP 8, Airbnb, etc.)
  - Language-specific conventions noted
  - Code formatting tools mentioned (Black, Prettier, etc.)

- [ ] **Prohibited practices listed** (5 points)
  - Security anti-patterns documented
  - Common mistakes to avoid
  - "DO NOT" or "NEVER" rules clearly stated

- [ ] **File/folder creation rules** (5 points)
  - Where temporary files should go (`tmp/`)
  - Naming conventions for new files
  - Git tracking policies

- [ ] **Critical rules highlighted** (5 points)
  - Most important rules at the top
  - Warning symbols (⚠️, ❌, 🚨) used appropriately
  - Context/reasoning provided for critical rules

**Example:**
```markdown
## ⚠️ CRITICAL: Mandatory Rules

### 1. Temporary File Creation (MANDATORY)

**🚨 All temporary/test/experimental files MUST be created in `tmp/` only.**

- ✅ DO: `tmp/test-feature.py`
- ❌ NEVER: `test-feature.py` (root creation forbidden)

**Reason:** Prevents security risks, Git pollution, and management issues
```

**Scoring:**
- 18-20 points: Excellent
- 14-17 points: Good
- 10-13 points: Fair
- Below 10: Poor

---

## Category 4: Dependencies & Configuration (15%)

**Checklist:**

- [ ] **All dependencies listed** (5 points)
  - Production dependencies documented
  - Development dependencies noted
  - Version constraints specified (if critical)

- [ ] **Configuration files documented** (5 points)
  - Key config files identified
  - Purpose of each config explained
  - Location and format noted

- [ ] **Environment setup instructions** (3 points)
  - How to install dependencies
  - Environment variables required
  - Platform-specific notes (Windows/Mac/Linux)

- [ ] **Dependency verification** (2 points)
  - Documented dependencies match actual files
  - No undocumented major dependencies
  - Deprecated dependencies removed

**Validation Commands:**
```bash
# Python
cat pyproject.toml requirements.txt

# JavaScript
cat package.json

# Rust
cat Cargo.toml

# Check for discrepancies with documented dependencies
```

**Scoring:**
- 13-15 points: Excellent
- 10-12 points: Good
- 7-9 points: Fair
- Below 7: Poor

**Common Issues:**
- ❌ New dependencies not documented
- ❌ Removed dependencies still listed
- ❌ Missing version constraints for critical deps
- ❌ No explanation for unusual dependencies

---

## Category 5: Workflows & Commands (15%)

**Checklist:**

- [ ] **Development workflow documented** (4 points)
  - How to start development server
  - How to run the application
  - Hot reload or watch mode (if applicable)

- [ ] **Testing workflow documented** (4 points)
  - How to run tests
  - Test types (unit, integration, e2e)
  - Coverage requirements or commands

- [ ] **Build and deployment workflow** (4 points)
  - How to build for production
  - Deployment steps or commands
  - CI/CD integration notes

- [ ] **Custom commands documented** (3 points)
  - Slash commands in `.claude/commands/` listed
  - Usage examples provided
  - When to use each command

**Example:**
```markdown
## Workflows

### Testing
```bash
# Run all tests
pytest

# Run specific test file
pytest tests/test_auth.py

# Run with coverage
pytest --cov=src tests/
```

### Build
```bash
# Development build
npm run build:dev

# Production build
npm run build:prod
```
```

**Scoring:**
- 13-15 points: Excellent
- 10-12 points: Good
- 7-9 points: Fair
- Below 7: Poor

---

## Category 6: Consistency & Formatting (10%)

**Checklist:**

- [ ] **Markdown formatting correct** (3 points)
  - Headers properly nested (H1 → H2 → H3)
  - Code blocks have language identifiers
  - Lists formatted consistently

- [ ] **Cross-references valid** (2 points)
  - Links to files/sections work
  - Relative paths correct
  - No broken references

- [ ] **Examples provided** (3 points)
  - Command examples shown
  - Expected output included (where helpful)
  - Real use cases demonstrated

- [ ] **No contradictions** (2 points)
  - Instructions don't conflict with each other
  - No outdated information contradicting current state
  - Consistent terminology throughout

**Scoring:**
- 9-10 points: Excellent
- 7-8 points: Good
- 5-6 points: Fair
- Below 5: Poor

---

## Critical Issues (Auto-Fail)

**These issues should block commits:**

1. **Major structural discrepancies**
   - Documented directory structure >50% inaccurate
   - Missing critical directories

2. **Dangerous instructions**
   - Commands that could delete data
   - Insecure practices recommended
   - Missing security warnings

3. **Completely outdated**
   - Documentation doesn't match current project at all
   - References removed features extensively

---

## Validation Report Template

```markdown
# Claude.md Quality Report

**Overall Score: {score}/100** {emoji}

## Category Scores
- Project Overview: {score}/15 {emoji}
- Directory Structure: {score}/25 {emoji}
- Development Rules: {score}/20 {emoji}
- Dependencies & Configuration: {score}/15 {emoji}
- Workflows & Commands: {score}/15 {emoji}
- Consistency & Formatting: {score}/10 {emoji}

## Critical Issues ({count})
{list of critical issues with line numbers}

## Important Issues ({count})
{list of important issues with line numbers}

## Minor Issues ({count})
{list of minor issues with line numbers}

## Recommendations
{actionable suggestions with diff examples}

## Verification Commands Run
```bash
{commands used for validation}
```

## Next Steps
- [ ] Fix critical issues before commit
- [ ] Address important issues
- [ ] Review minor issues (optional)
```

**Emoji Guide:**
- 90-100: ✅ (Green check)
- 75-89: ⚠️ (Yellow warning)
- Below 75: ❌ (Red X)
