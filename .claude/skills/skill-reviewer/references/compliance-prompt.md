# Skill Compliance Review Prompt Template

Use this template to generate Codex prompts for skill-creator guideline compliance reviews.

---

## Template Variables

- `{SKILL_NAME}`: Name of the skill being reviewed
- `{SKILL_PATH}`: Path to skill directory
- `{DATE}`: Review date
- `{DESCRIPTION}`: Skill description from YAML frontmatter
- `{WORD_COUNT}`: Approximate word count of SKILL.md body

---

## Prompt Template

```markdown
# {SKILL_NAME} Skill - skill-creator Compliance Review

**Date:** {DATE}
**Reviewer:** OpenAI Codex (GPT-5-Codex)
**Review Type:** skill-creator Guidelines Compliance

---

## Context

The {SKILL_NAME} skill has been implemented and needs validation against skill-creator best practices.

Please review the skill structure for compliance with official skill-creator guidelines.

---

## skill-creator Guidelines Summary

### Key Requirements

1. **File Naming:** SKILL.md (uppercase, not skill.md)
2. **YAML Frontmatter:**
   - `name:` (required)
   - `description:` (required, third-person form)
3. **Progressive Disclosure:**
   - Description: <100 words
   - SKILL.md body: <5k words
   - Bundled resources: scripts/, references/, assets/
4. **Writing Style:** Imperative/infinitive form in SKILL.md body
5. **Avoid Duplication:** Details in references/, core in SKILL.md
6. **Structure:** SKILL.md + optional bundled resources

### Progressive Disclosure Principle

Three-level loading system:
1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words)
3. **Bundled resources** - As needed by Claude (unlimited)

---

## Current Implementation

### Directory Structure

[Auto-generated from skill directory]

### SKILL.md YAML Frontmatter

```yaml
[Auto-inserted from skill]
```

**Word Count:** {WORD_COUNT} words
**Form:** [Auto-detected: third-person / first-person]
**Triggers:** [Auto-extracted trigger keywords]

### SKILL.md Body Structure

[Auto-generated table of contents]

**Total:** ~{WORD_COUNT} words
**Style:** [Auto-detected: imperative / declarative / mixed]

---

## Review Focus Areas

### 1. File Naming Compliance

- [ ] `SKILL.md` (uppercase)
- [ ] Not `skill.md`

### 2. YAML Frontmatter Quality

**Check:**
- Is `description` in third-person form? ("This skill should be used..." vs "Manage...")
- Is trigger specification clear? ("Trigger when user says...")
- Is description concise? (<100 words)
- Does description adequately describe when to use the skill?

### 3. Progressive Disclosure

**Check:**
- SKILL.md body length within limits? (target: <5k words)
- Are detailed docs moved to references/?
- Does SKILL.md reference bundled resources appropriately?
- Is there duplication between SKILL.md and references/?

### 4. Writing Style

**Check:**
- Is SKILL.md body in imperative/infinitive form?
- Are there sections that should be more directive?
- Is the tone objective and instructional?

### 5. Content Organization

**Check:**
- Does SKILL.md answer:
  1. What is the purpose?
  2. When should it be used?
  3. How to use bundled resources?
- Are scripts/ and references/ properly referenced?
- Is the skill discoverable without loading references?

### 6. Duplication Analysis

**Check:**
- Is information duplicated between SKILL.md and references/?
- Should any SKILL.md content move to references/?
- Are references/ summaries in SKILL.md too detailed?

---

## Expected Output Format

### 1. Overall Compliance Assessment

- **Status:** Compliant / Minor Issues / Major Issues
- **Confidence:** Low / Medium / High
- **Summary:** 2-3 sentence verdict on skill-creator compliance

### 2. Compliance Checklist

Rate each area:
- ✅ **Fully Compliant** - Meets all requirements
- ⚠️ **Minor Issue** - Works but could improve
- ❌ **Non-Compliant** - Violates guideline

**Format:**
1. File Naming: [✅/⚠️/❌] + Comment
2. YAML Frontmatter: [✅/⚠️/❌] + Comment
3. Progressive Disclosure: [✅/⚠️/❌] + Comment
4. Writing Style: [✅/⚠️/❌] + Comment
5. Content Organization: [✅/⚠️/❌] + Comment
6. Duplication Avoidance: [✅/⚠️/❌] + Comment

### 3. Specific Issues (If Any)

If any issues found:
1. **[Critical/High/Medium/Low]** Issue description
   - Location: file:line or section
   - Recommendation: Specific fix
2. ...

### 4. Improvement Suggestions

Optional suggestions for:
- Better progressive disclosure
- Clearer skill activation triggers
- More effective resource organization
- Enhanced discoverability

### 5. Recommended Next Steps

- If **Compliant:** Ready for packaging/distribution
- If **Minor Issues:** Address X, Y, Z (optional)
- If **Major Issues:** Must fix A, B, C before use

---

## Success Criteria

Review is successful if:
1. ✅ File naming follows convention (SKILL.md uppercase)
2. ✅ YAML frontmatter is third-person with clear triggers
3. ✅ Progressive disclosure is properly implemented
4. ✅ SKILL.md is lean (<5k words) with references to bundled resources
5. ✅ Writing style is imperative/objective
6. ✅ No significant duplication between SKILL.md and references/

---

## Notes

- This is a **structure/compliance review**, not a functionality review
- Focus on: skill-creator guidelines adherence, discoverability, context efficiency
- "Could improve" items are acceptable (not blocking)

---

**Please conduct a skill-creator compliance review and provide actionable feedback.**
```

---

## Usage Example

```bash
# Generate prompt for skill review
cat references/compliance-prompt.md | \
  sed "s/{SKILL_NAME}/my-skill/g" | \
  sed "s/{DATE}/$(date +%Y-%m-%d)/g" | \
  codex exec
```

Or use the Python script:

```python
from pathlib import Path
import subprocess

# Load template
template = Path("references/compliance-prompt.md").read_text()

# Substitute variables
prompt = template.format(
    SKILL_NAME="my-skill",
    SKILL_PATH="~/.claude/skills/my-skill",
    DATE="2025-11-01",
    DESCRIPTION="...",
    WORD_COUNT=1500
)

# Execute with Codex
subprocess.run(["codex", "exec"], input=prompt, text=True)
```
