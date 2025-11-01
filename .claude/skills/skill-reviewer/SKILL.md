---
name: skill-reviewer
description: This skill should be used to automate skill quality reviews using OpenAI Codex. Trigger when user says "review this skill with codex", "codex로 스킬 검토", "skill quality check", "validate skill structure", or "check skill compliance". Performs comprehensive analysis of skill-creator guideline compliance, structural quality, and functional correctness.
---

# Skill Reviewer

Automate skill quality reviews using OpenAI Codex for comprehensive compliance and correctness validation.

---

## When to Use This Skill

Use this skill when users request:

**English triggers:**
- "Review this skill with Codex"
- "Check if my skill follows skill-creator guidelines"
- "Validate skill structure"
- "Perform quality check on this skill"
- "Analyze skill compliance"

**Korean triggers:**
- "codex로 스킬 검토"
- "skill 품질 체크"
- "스킬 가이드라인 준수 확인"
- "스킬 구조 검증"

**Appropriate scenarios:**
1. After creating a new skill
2. Before packaging/distributing a skill
3. After major refactoring of existing skill
4. Periodic quality audits

---

## Review Types

### 1. Compliance Review

Validates adherence to skill-creator guidelines:
- File naming conventions (SKILL.md uppercase)
- YAML frontmatter quality (third-person, clear triggers)
- Progressive disclosure implementation
- Writing style (imperative/infinitive form)
- Content organization
- Duplication avoidance

Execute via `scripts/review-compliance.sh`:

```bash
bash scripts/review-compliance.sh <skill-path>
```

See `references/compliance-prompt.md` for detailed review criteria.

### 2. Functionality Review

Validates functional correctness of bundled scripts:
- Script logic and error handling
- Parameter validation
- Rollback mechanisms
- Edge case handling
- Security considerations

Execute via `scripts/review-functionality.sh`:

```bash
bash scripts/review-functionality.sh <skill-path>
```

See `references/functionality-prompt.md` for detailed review criteria.

### 3. Full Review

Combines both compliance and functionality reviews:

```bash
# Run both reviews
bash scripts/review-compliance.sh <skill-path>
bash scripts/review-functionality.sh <skill-path>
```

Generates comprehensive reports with actionable recommendations.

---

## Workflow

### Step 1: Prepare Skill for Review

Ensure the skill directory contains:
- `SKILL.md` (required)
- `scripts/` (if applicable)
- `references/` (if applicable)

```bash
ls <skill-path>
# Should show: SKILL.md, scripts/, references/, etc.
```

### Step 2: Run Review

```bash
# Navigate to skill-reviewer scripts directory
cd ~/.claude/skills/skill-reviewer/scripts

# Run compliance review
bash review-compliance.sh ~/.claude/skills/<skill-name>

# Run functionality review (if skill has scripts/)
bash review-functionality.sh ~/.claude/skills/<skill-name>
```

### Step 3: Analyze Results

Review output displayed in terminal:
- Overall assessment (Compliant/Minor Issues/Major Issues)
- Detailed checklist with ✅/⚠️/❌ ratings
- Specific issues with locations and recommendations
- Improvement suggestions
- Recommended next steps

### Step 4: Address Issues

Iterate on skill based on review feedback:
1. Fix critical/high issues first
2. Address medium/low issues if time permits
3. Re-run review to confirm fixes
4. Proceed with packaging when Compliant

---

## Output Format

### Compliance Review Report

```markdown
# Skill Review: <skill-name>

**Date:** <timestamp>
**Reviewer:** OpenAI Codex (GPT-5-Codex)
**Review Type:** Compliance

## Overall Assessment
- Status: Compliant / Minor Issues / Major Issues
- Confidence: Low / Medium / High
- Summary: <verdict>

## Compliance Checklist
1. File Naming: [✅/⚠️/❌] + Comment
2. YAML Frontmatter: [✅/⚠️/❌] + Comment
3. Progressive Disclosure: [✅/⚠️/❌] + Comment
4. Writing Style: [✅/⚠️/❌] + Comment
5. Content Organization: [✅/⚠️/❌] + Comment
6. Duplication Avoidance: [✅/⚠️/❌] + Comment

## Specific Issues
<list of issues with recommendations>

## Improvement Suggestions
<optional improvements>

## Recommended Next Steps
<actionable next steps>
```

### Functionality Review Report

```markdown
# Skill Review: <skill-name>

**Date:** <timestamp>
**Reviewer:** OpenAI Codex (GPT-5-Codex)
**Review Type:** Functionality

## Overall Assessment
- Status: Accept / Conditional Accept / Reject
- Confidence: Low / Medium / High
- Summary: <verdict>

## Bug Analysis
For each critical/high bug found:
- Bug #N: [Critical/High/Medium/Low]
  - Location: file:line
  - Description: <what's wrong>
  - Impact: <why it matters>
  - Recommendation: <how to fix>

## Remaining Issues
<issues not fixed or newly found>

## Recommended Next Steps
<actionable next steps>
```

---

## Best Practices

Follow these guidelines when using skill-reviewer:

**Before Review:**
- Ensure Codex CLI is installed (`codex --version`)
- Set API keys if needed (`.credentials.json`)
- Clean up test files/temporary artifacts

**During Review:**
- Run compliance review first (faster, structural)
- Fix compliance issues before functionality review
- Use `--verbose` flag for detailed output

**After Review:**
- Save review reports for documentation
- Address critical/high issues immediately
- Consider improvement suggestions for next iteration
- Re-review after major changes

---

## Configuration

### Codex Settings

Default configuration:
- Model: `gpt-5-codex`
- Provider: `openai`
- Reasoning effort: `high`
- Approval: `never`

Customize via `~/.codex/config.yaml` (see Codex documentation).

### Review Output

Review results are printed to terminal in real-time.

To save results:

```bash
# Save to file
bash review-compliance.sh ~/.claude/skills/my-skill > compliance-report.md

# Or copy from terminal
```

---

## Troubleshooting

### Issue: "Codex command not found"

**Solution:** Install Codex CLI:
```bash
npm install -g @openai/codex-cli
# or
pip install openai-codex
```

### Issue: "API rate limit exceeded"

**Solution:** Wait or upgrade OpenAI API tier:
- Free tier: 3 requests/minute
- Paid tier: Higher limits

### Issue: "Review incomplete or truncated"

**Solution:**
- Increase timeout: `--timeout 600`
- Use `--type compliance` first (lighter)
- Split large skills into smaller reviews

### Issue: "False positive/negative detections"

**Solution:**
- Review Codex's reasoning summaries
- Adjust prompts in `references/`
- Provide context via `--context` flag

---

## References

Detailed review templates and checklists:

- **`references/skill-creator-checklist.md`** - Comprehensive guideline checklist
- **`references/compliance-prompt.md`** - Template for compliance reviews
- **`references/functionality-prompt.md`** - Template for functionality reviews

---

## Limitations

**Works best for:**
- ✅ Skills following skill-creator guidelines
- ✅ Skills with clear documentation
- ✅ Python/Bash/PowerShell scripts
- ✅ Structured YAML frontmatter

**May require adaptation for:**
- ⚠️ Skills with complex assets/
- ⚠️ Skills in other languages (Rust, Go, etc.)
- ⚠️ Skills with external dependencies
- ⚠️ Skills without bundled resources

---

**Version:** 1.0.0
**Dependencies:** OpenAI Codex CLI, Bash
**Status:** Production ready
