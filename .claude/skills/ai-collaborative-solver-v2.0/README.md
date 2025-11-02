# AI Collaborative Solver V2.0

**Simplified Redesign - Focus on Agent-Driven Clarity**

## Philosophy

V2.0 is a complete redesign based on lessons learned from V1.0:

### What Went Wrong in V1.0

1. **Over-engineering:** Complex script-based pre-clarification (pre-clarify.sh)
2. **Environment Issues:** stdin/TTY checks broke in Claude Code
3. **Synchronization:** Multiple file locations caused confusion
4. **Debugging:** Hard to trace issues across subprocess chains

### V2.0 Approach

**Start simple, add incrementally:**

1. ✅ **Phase 1 (Current):** Agent-driven pre-clarification only
   - Claude Code asks questions directly (skill.md instructions)
   - No pre-clarify.sh subprocess
   - ai-debate.sh is placeholder (validates workflow)

2. 🔄 **Phase 2 (Next):** Add actual model integration
   - Codex adapter (GPT-5-Codex via CLI)
   - Simple debate execution
   - Basic report generation

3. 📅 **Phase 3 (Future):** Advanced features
   - Hybrid multi-model debates
   - Mid-debate user input
   - Coverage monitoring
   - Quality gates

## Current Status (Phase 1)

### ✅ Implemented

- `skill.md` - Clear pre-clarification instructions for Claude Code
- `scripts/ai-debate.sh` - Placeholder script (validates input/output)
- Simple model auto-selection (keyword-based)

### ❌ Not Yet Implemented

- Actual Codex/Claude/Gemini adapters (placeholders only)
- Multi-round debate logic
- Coverage monitoring
- Quality gates
- Hybrid mode

## How It Works (Phase 1)

```
User: "Django vs FastAPI 선택"
  ↓
Claude Code: (reads skill.md)
  ↓
Claude Code: "몇 가지 확인하고 싶습니다:
1. 프로젝트 규모는?
2. 팀 경험은?
3. 주요 요구사항은?"
  ↓
User: [답변]
  ↓
Claude Code: Builds enriched problem
  ↓
Bash ai-debate.sh "<enriched problem>" --auto --mode balanced
  ↓
Script: Creates placeholder report
  ↓
Claude Code: "현재 Phase 1이라 실제 토론은 구현 중입니다.
하지만 명확화 워크플로우가 잘 작동하는지 확인했습니다!"
```

## Testing Phase 1

**Goal:** Validate pre-clarification workflow works correctly.

**Test command:**
```
"Django 4.2 + PostgreSQL 14 성능 개선 ai 토론"
```

**Expected behavior:**
1. Claude Code shows clarification questions OR understanding summary
2. User provides input
3. Claude Code runs ai-debate.sh with enriched problem
4. Script creates report (placeholder content)
5. Claude Code summarizes that Phase 1 validation succeeded

**Success criteria:**
- [ ] Claude Code consistently asks clarifying questions
- [ ] User interaction is smooth (no stdin/TTY issues)
- [ ] Enriched problem statement includes clarification context
- [ ] Script executes without errors
- [ ] Report is generated

## Next Steps (Phase 2)

Once Phase 1 is validated:

1. **Implement Codex adapter:**
   - Call Codex CLI with structured prompt
   - Parse multi-round debate output
   - Generate proper report

2. **Add mode configurations:**
   - Simple: 3 rounds
   - Balanced: 4 rounds
   - Deep: 6 rounds

3. **Test end-to-end:**
   - Real debate execution
   - Quality assessment
   - User feedback

## File Structure

```
ai-collaborative-solver-v2.0/
├── skill.md              # Agent instructions (pre-clarification focus)
├── README.md             # This file
├── scripts/
│   └── ai-debate.sh      # Placeholder script
└── references/           # (Future: Documentation)
```

## Lessons from V1.0

### ❌ Don't

1. **Don't over-engineer early** - V1.0 had pre-clarify.sh, facilitator.sh, coverage checks before validating basic flow
2. **Don't fight the platform** - Checking `[[ -t 0 ]]` broke in Claude Code; better to use platform strengths
3. **Don't duplicate files** - 6 locations with ai-debate.sh caused sync issues
4. **Don't add features speculatively** - Registry, quality gates, playbooks before basic workflow worked

### ✅ Do

1. **Start with one feature** - V2.0 focuses on pre-clarification only
2. **Leverage agent capabilities** - Claude Code is already interactive and smart
3. **Validate incrementally** - Test Phase 1 before building Phase 2
4. **Keep it simple** - One skill location, minimal scripts

## Contributing to V2.0

**Phase 1 (Current focus):**
- Test pre-clarification workflow
- Report issues with clarification questions
- Suggest improvements to skill.md instructions

**Phase 2 (After Phase 1 validated):**
- Implement model adapters
- Add debate logic
- Test actual debates

**Phase 3 (After Phase 2 works):**
- Add advanced features
- Optimize performance
- Enhance quality

---

**Version:** 2.0.0-alpha
**Status:** Phase 1 (Pre-clarification validation)
**Created:** 2025-11-02
**Philosophy:** Simplicity first, features later
