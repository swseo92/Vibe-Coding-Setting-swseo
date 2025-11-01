# Skill Functionality Review Prompt Template

Template for generating Codex prompts to review skill script functionality.

---

## Template

```markdown
# {SKILL_NAME} Skill - Functionality Review

**Date:** {DATE}
**Reviewer:** OpenAI Codex (GPT-5-Codex)
**Review Type:** Functionality & Correctness

---

## Context

Review the bundled scripts in {SKILL_NAME} skill for:
- Functional correctness
- Error handling
- Edge cases
- Security issues
- Best practices

---

## Scripts to Review

{SCRIPT_LIST}

---

## Review Focus

1. **Critical Bugs:** Logic errors, incorrect assumptions, broken flows
2. **High Bugs:** Missing error handling, security issues, data loss risks
3. **Medium Bugs:** Poor UX, missing validations, inconsistent behavior
4. **Low Bugs:** Style issues, minor inefficiencies

---

## Expected Output

### Overall Assessment
- Status: Accept / Conditional Accept / Reject
- Confidence: Low / Medium / High
- Summary: 2-3 sentence verdict

### Bug Analysis
For each bug:
- Bug #N: [Critical/High/Medium/Low]
  - Location: file:line
  - Description: What's wrong
  - Impact: Why it matters
  - Recommendation: How to fix

### Remaining Issues
List any issues not addressed

### Recommended Next Steps
Actionable next steps

---

**Please conduct functionality review and provide detailed feedback.**
```

---

## Usage

```bash
python scripts/review-skill.py <skill-path> --type functionality
```
