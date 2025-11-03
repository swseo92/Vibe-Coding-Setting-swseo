---
name: claude-md-manager
description: Review and maintain claude.md project documentation quality. Trigger when user says "커밋 리뷰", "commit review", "claude.md 검토", "review claude.md", "update claude.md", or before committing changes. Validates completeness, consistency, and accuracy of project instructions.
---

# Claude.md Manager

## Purpose

Maintain high-quality `claude.md` project documentation by validating completeness, consistency, and accuracy before commits. Ensure that `claude.md` accurately reflects current project state including structure, workflows, rules, and dependencies.

## When to Use

Trigger this skill when:
- User explicitly requests: "커밋 리뷰", "commit review", "claude.md 검토", "review claude.md", "update claude.md"
- Before committing significant changes (proactively suggest review)
- After adding new features, dependencies, or changing project structure
- When user asks to validate project documentation

## Core Workflow

### 1. Read Current State

**Load claude.md:**
```bash
cat claude.md
```

**Analyze project structure:**
```bash
# Check directory structure
ls -la

# Check dependencies
cat pyproject.toml    # Python
cat package.json      # JavaScript
cat Cargo.toml        # Rust

# Check configuration files
ls -la .claude/
ls -la .specify/
```

### 2. Quality Validation

**Use the validation checklist in `references/checklist.md`.**

Load the checklist into context:
```bash
cat .claude/skills/claude-md-manager/references/checklist.md
```

**Validate against checklist categories:**
- Project Overview Completeness
- Directory Structure Accuracy
- Development Rules Clarity
- Dependencies and Configuration
- Workflows and Commands
- Consistency and Formatting

**Generate scored report (0-100):**
- Each category weighted based on importance
- Provide specific line references for issues
- Suggest concrete improvements

### 3. Structure Verification

**Use standard sections template in `references/template-sections.md`.**

Load template for reference:
```bash
cat .claude/skills/claude-md-manager/references/template-sections.md
```

**Verify presence and order of standard sections:**
- Project description and purpose
- Directory structure
- Setup instructions
- Development rules and conventions
- Testing and build workflows
- Deployment instructions (if applicable)

**Check for consistency:**
- Section headers follow standard format
- Cross-references are valid
- Code blocks have proper syntax highlighting
- File paths are accurate

### 4. Content Accuracy Check

**Validate against actual project state:**

- **Directory structure**: Compare documented structure with actual `ls -R` output
- **Dependencies**: Cross-check documented packages with `pyproject.toml`, `package.json`, etc.
- **Commands**: Verify documented commands exist in `.claude/commands/`
- **Configuration files**: Confirm documented configs match actual files
- **Workflows**: Validate documented workflows match scripts and tooling

**Flag discrepancies:**
```
❌ Directory `src/api/` documented but not found
❌ Dependency `fastapi` in pyproject.toml but not documented
✅ All documented commands verified in .claude/commands/
```

### 5. Update Recommendations

**Generate actionable recommendations:**

1. **Critical (must fix before commit):**
   - Missing required sections
   - Inaccurate directory structure
   - Outdated dependency information

2. **Important (should fix soon):**
   - Missing workflow documentation
   - Incomplete setup instructions
   - Unclear development rules

3. **Nice-to-have (optional improvements):**
   - Better formatting
   - More detailed examples
   - Additional context

**Provide diff suggestions:**
```diff
## Directory Structure

- Old structure here
+ Updated structure reflecting current state
```

### 6. Interactive Updates

**Offer to make updates automatically:**
- "Should I update the directory structure section?"
- "Would you like me to add the new dependencies to claude.md?"
- "Shall I document the new workflow you just added?"

**Apply changes with user approval:**
- Use Edit tool to make specific updates
- Show diffs before applying
- Commit only reviewed changes

## Special Cases

### New Project Without claude.md

**Detect missing claude.md:**
```bash
if [ ! -f claude.md ]; then
  echo "No claude.md found. Would you like to create one?"
fi
```

**Generate from template:**
- Use `references/template-sections.md` as base
- Auto-populate from project analysis
- Language-specific sections (Python, JS, Rust, etc.)
- Include detected dependencies and structure

### Language-Specific Conventions

**Python projects:**
- Document `uv`, `pip`, or `poetry` usage
- Include `pytest` configuration
- Virtual environment setup

**JavaScript/TypeScript projects:**
- Document `npm`, `yarn`, or `pnpm` usage
- Include build scripts
- Node version requirements

**Rust projects:**
- Document `cargo` commands
- Include feature flags
- Build profiles

### Integration with Vibe-Coding-Setting

**Recognize template-based projects:**
- Check if project was initialized with `/init-workspace`
- Preserve template structure and conventions
- Note any deviations from template

**Hook integration notes:**
- Document TTS notification hooks if present
- Note Playwright MCP configuration
- Include Speckit integration details

## Output Format

### Summary Report

```
# Claude.md Quality Report

**Overall Score: 85/100** ✅

## Category Scores
- Project Overview: 90/100 ✅
- Directory Structure: 75/100 ⚠️
- Development Rules: 90/100 ✅
- Dependencies: 80/100 ✅
- Workflows: 85/100 ✅
- Consistency: 90/100 ✅

## Critical Issues (2)
1. ❌ Line 45: Directory `src/utils/` documented but not found
2. ❌ Line 67: Missing pytest configuration documentation

## Important Issues (3)
1. ⚠️ Line 23: Dependency `pydantic` not documented
2. ⚠️ Line 89: Workflow for running tests not detailed
3. ⚠️ Line 102: No deployment instructions

## Recommendations
[Specific suggestions with diffs...]
```

### Validation Checklist

```
✅ Project overview present and clear
✅ Directory structure documented
⚠️ Directory structure has 2 discrepancies
✅ Development rules section exists
✅ Testing workflow documented
❌ Deployment section missing
✅ All dependencies listed
✅ Configuration files documented
```

## Best Practices

**Review frequency:**
- Before every commit with structural changes
- After adding new major features
- When onboarding new team members
- Quarterly full audit

**Scope:**
- Focus on accuracy and completeness
- Keep documentation concise but thorough
- Prioritize developer onboarding clarity
- Include examples for complex workflows

**Avoid:**
- Over-documentation (don't duplicate README.md)
- Stale information (verify before committing)
- Generic boilerplate (customize for project)
- Missing critical setup steps

## References

**Load these references as needed:**

- `references/checklist.md` - Comprehensive validation checklist with scoring rubric
- `references/template-sections.md` - Standard section structure and examples

**Search patterns for large reference files:**
- "checklist category:" for specific validation areas
- "template section:" for structure guidance
- "scoring rubric" for quality metrics
