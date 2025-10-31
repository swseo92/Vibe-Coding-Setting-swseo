# Pre-Debate Clarification Stage Design

**Date:** 2025-10-31
**Session ID:** 019a3994-01a3-7591-ac0d-630f1d6a6049
**Status:** Designed, Implementation Pending

---

## Summary

Add agent-driven clarification stage to V3.0 Codex Collaborative Solver to reduce assumptions and improve debate quality by gathering essential context before starting debates.

---

## Design Consensus (Claude + Codex)

### Codex Proposal (Round 1)

**Strategy:**
- 기본 1-3개 질문 + 복잡도에 따라 0-2개 추가
- `--skip-clarify` 플래그로 사용자 제어
- skill.md에 Clarify Stage 추가
- Agent 동적 생성

**Claude 반박:**
- ❌ 휴리스틱 기반 복잡도 판단은 키워드 매칭과 동일한 문제
- 💡 대안: Agent가 질문을 읽고 직접 판단

**최종 합의:**
- Agent-driven complexity judgment
- No heuristics, no keyword matching
- Dynamic question generation
- User control preserved

---

## Implementation Spec

### 1. Workflow Integration

```
User request
    ↓
Claude analyzes complexity (agent judgment)
    ↓
Generate 1-3 questions IF needed
    ↓
User answers (or --skip-clarify)
    ↓
Debate starts with full context
```

### 2. Complexity Judgment Criteria

**Agent asks itself:**
- Are constraints mentioned? (tech stack, budget, timeline)
- Is goal clear? (what defines "solved"?)
- Is context sufficient? (current system, problem background)
- Single or multi-dimensional problem?

**Decision:**
- 0 questions: All information present
- 1-2 questions: Minor gaps
- 3 questions: Major gaps

### 3. Question Categories

**Essential** (always ask if missing):
- Constraints (tech stack, budget, timeline, team capability)
- Goals & Success Criteria (what defines "solved"?)
- Context (current system, why this problem matters)

**Conditional** (based on problem type):
- Performance: Target metrics, current profiling data
- Architecture: Existing system, integration concerns
- Security: Compliance requirements, threat model
- Bug: Reproduction steps, error logs

### 4. Example Flow

```
User: "Django API 응답이 너무 느려"

Claude (internal judgment):
- No constraints mentioned → Ask
- No target metrics → Ask
- Context unclear → Ask
→ Generate 3 questions

Claude: "명확화 질문:
1. 현재 응답 시간과 목표 응답 시간은?
2. 사용 중인 Django 버전, DB, 캐시 스택은?
3. 예산/시간 제약사항은?"

User: "현재 2초, 목표 500ms. Django 4.2, PostgreSQL, Redis 없음. 1주일 내 개선."

→ Now debate with full context
```

### 5. Skip Options

**Auto-skip** (sufficient info):
```
User: "Django 4.2 API 성능 개선 (2초→500ms, PostgreSQL 14, 1주일)"
→ Claude: (모든 정보 있음) → Skip clarify, start debate
```

**Explicit skip**:
```
User: "--skip-clarify Django API 성능 개선"
→ Claude: Debate immediately
```

---

## Quality Gate Integration

### New Section 0: Clarification Completeness

```markdown
## 0. Clarification Completeness

**Question:** Was sufficient context gathered before the debate?

**Check:**
- [ ] Clarification stage conducted (or explicitly skipped)
- [ ] Key constraints identified
- [ ] Goals and success criteria defined
- [ ] Problem context understood
- [ ] User responses integrated

**Clarification Answers Used:**
- Technical constraints: _______________
- Goals: _______________
- Success criteria: _______________
- Timeline/budget: _______________

**Quality Impact:**
- Good clarification → Fewer assumptions (lower Tier 3 evidence)
- Poor clarification → More guessing (higher assumption:fact ratio)
```

---

## Documentation Updates Needed

### skill.md Changes

**Section: V3.0 Workflow > Pre-Debate**

Add new Step 1: Clarification Stage (before Mode Selection)
- Purpose, process, complexity judgment
- Question categories
- Example flow
- Skip options
- Philosophy alignment

**Section: Usage Examples**

Update basic example to include clarification stage
Add skip clarify example

**Section: Best Practices**

Add Do's:
1. Answer Clarification Questions
2. Provide Complete Context Upfront

Add Don'ts:
1. Don't Rush Past Clarification
2. Don't Say "I Don't Know" Without Details

Add Pro Tips:
- Good initial requests (auto-skip)
- Vague requests (trigger clarify)
- Effective clarification responses

---

## Benefits

1. **Fewer Assumptions**
   - Lower Tier 3 evidence usage
   - Higher confidence in recommendations

2. **Better Constraint Adherence**
   - Solutions respect actual limitations
   - No impossible recommendations

3. **More Realistic Solutions**
   - Based on actual tech stack
   - Aligned with timeline/budget

4. **Faster Convergence**
   - Clear context from start
   - Less back-and-forth during debate

---

## Philosophy Alignment

✅ **"Scripts Assist, Agents Judge"**
- Agent decides if/what to ask
- No rigid heuristics

✅ **No Keyword Matching**
- Natural language understanding
- Context-aware judgment

✅ **Fully Flexible**
- Dynamic question generation
- Adapts to problem type

✅ **User Control Preserved**
- `--skip-clarify` flag
- Auto-skip when sufficient info

---

## Implementation Status

- [x] Design complete
- [x] Codex validation (Session 019a3994-01a3-7591-ac0d-630f1d6a6049)
- [x] Documentation drafted
- [ ] skill.md updates
- [ ] quality-gate.md updates
- [ ] Testing
- [ ] Commit to repository

---

## Next Steps

When ready to implement:

1. Update `.claude/skills/codex-collaborative-solver-v3/skill.md`
   - Add Clarification Stage to Pre-Debate workflow
   - Update usage examples
   - Add best practices

2. Update `.claude/skills/codex-collaborative-solver-v3/facilitator/quality-gate.md`
   - Add Section 0: Clarification Completeness

3. Test with real debates

4. Commit changes

5. Apply settings: `/apply-settings`

---

## File Locations

**Skill Definition:**
```
.claude/skills/codex-collaborative-solver-v3/skill.md
~/.claude/skills/codex-collaborative-solver-v3/skill.md
```

**Quality Gate:**
```
.claude/skills/codex-collaborative-solver-v3/facilitator/quality-gate.md
~/.claude/skills/codex-collaborative-solver-v3/facilitator/quality-gate.md
```

**This Design Doc:**
```
.debate-reports/2025-10-31-clarification-stage-design.md
```

---

**Design By:** Claude + Codex
**Validated:** 2025-10-31
**Ready for Implementation:** Yes
