# AI Debate v4.0: Implementation Plan

**Executive Summary Document**

**Version**: 4.0.0-implementation-plan
**Date**: 2025-11-04
**Status**: ✅ Ready for Implementation
**Based on**: Design doc + Codex debate results

---

## 1. Final Decisions (미해결 질문 해결됨)

### Q1: Devil's Advocate Mode → v4.1로 연기

**Decision**: ⏳ **NOT in v4.0**, defer to v4.1+

**Reasoning (from debate)**:
- Codex: 신뢰도 신호 기반 자동 활성화 제안
- Main Claude: 사용자 명시적 플래그 제안
- **합의**: 하이브리드 (자동 감지 + 수동 플래그)
- **But**: 신뢰도 신호 시스템이 아직 없음 → v4.1에서 구현

**v4.0 Action**: Skip (구현 안 함)
**v4.1 Plan**:
```python
if confidence_variance > 0.3 or user_flag == "--devil-advocate":
    activate_devils_advocate()
```

---

### Q2: Unanimous Agreement → Codex 방식 채택 ✅

**Decision**: ✅ **Implement Codex's Self-Review Approach**

**What to implement**:
```python
if unanimous_agreement(threshold=90%):
    # Step 1: Lightweight safety check (2-3s overhead)
    review = {
        "claude_failure_mode": "Most likely failure: [20 words max]",
        "codex_failure_mode": "Most likely failure: [20 words max]"
    }

    # Step 2: Auto-decision
    if high_risk_flagged(review):
        run_full_debate()  # Phase 3-4
    else:
        skip_to_synthesis()  # Phase 6
        # Show: "[✅ Both agents agree. View reasoning?]"
```

**Why Codex wins**:
- 사용자 인터랙션 0초 (vs My: 10-30s 대기)
- Failure mode 체크로 안전장치 확보
- 투명성: "View reasoning" 링크로 유지

**Implementation time**: 2-3 hours

---

### Q3: Maximum Rounds → Main Claude 방식 채택 ✅

**Decision**: ✅ **User-Triggered Extension (My Approach)**

**What to implement**:
```python
DEFAULT_MAX_ROUNDS = 3  # Fixed
ABSOLUTE_CAP = 5        # Hard limit

# Phase 5: User intervention point
options = [
    "Deep dive on [topic]",      # +1 round for specific topic
    "Add new constraint",          # Restart with new info
    "Conclude"                     # Skip to Phase 6
]

if user_selects("Deep dive"):
    max_rounds = 4
    show_eta("+30s for focused analysis")
```

**Why My approach wins**:
- Codex 신호 기반 자동 확장은 신호 품질 검증 필요 (v4.2+)
- User-triggered는 즉시 구현 가능하고 안전
- Phase 5 이미 개입점이므로 자연스러움

**Implementation time**: 1-2 hours (Phase 5 구현 일부)

---

## 2. v4.0 Final Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Phase 1: Pre-Clarification (기존 유지)                  │
└─────────────────┬───────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 2: Round 1 - Independent Analysis                 │
│ ├─ 2.1: Main Claude opinion (0.7s)                      │
│ ├─ 2.2: Codex opinion (19s)                            │
│ └─ 2.3: Unanimous check (NEW)                          │
│        if unanimous → Self-review (2s)                  │
│           if safe → SKIP to Phase 6                    │
│           if risky → Continue to Phase 3               │
└─────────────────┬───────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 3: Round 2 - Constructive Challenge               │
│ ├─ 3.1: Main Claude → Codex challenge (15s)            │
│ │      ✅ Strengths ⚠️ Questions ❌ Weak spots 📊 Evidence │
│ ├─ 3.2: Codex → Main Claude challenge (15s) [parallel] │
│ └─ Total: 30s (parallel execution)                     │
└─────────────────┬───────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 4: Round 3 - Evidence & Refinement                │
│ ├─ 4.1: Main Claude responds + WebSearch (20s)         │
│ ├─ 4.2: Codex responds + WebSearch (20s) [parallel]    │
│ └─ Total: 20-50s (depends on evidence complexity)      │
└─────────────────┬───────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 5: User Intervention Point (NEW)                  │
│ ├─ Show debate summary                                  │
│ ├─ Options:                                             │
│ │   1. Deep dive on [topic] → Loop to Phase 3 (+1 round)│
│ │   2. Add constraint → Restart Phase 2                │
│ │   3. Conclude → Phase 6                              │
│ └─ [10-30s user think time]                            │
└─────────────────┬───────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 6: Final Synthesis                                 │
│ ├─ Integrate all rounds                                 │
│ ├─ Re-evaluate confidence                               │
│ └─ Present refined recommendation (2s)                  │
└─────────────────────────────────────────────────────────┘
```

**Performance Budget**:
| Path | Time | Scenario |
|------|------|----------|
| **Fast path** (unanimous) | 28s | 명확한 케이스 (Phase 6 직행) |
| **Normal path** | 56-86s | 일반 토론 (Phase 2→6) |
| **Deep dive** | 86-120s | 사용자 심화 요청 (+1 round) |

---

## 3. Implementation Roadmap

### Week 1: Core Implementation (6-8 hours)

#### Day 1-2: Phase 3 (Constructive Challenge)

**Tasks**:
1. ✅ skill.md에 Phase 3 섹션 추가
2. ✅ Challenge 템플릿 작성 (✅⚠️❌📊 구조)
3. ✅ Main Claude → Codex challenge 로직
4. ✅ Codex → Main Claude challenge (codex-session.sh)
5. ✅ 병렬 실행 구현

**Deliverables**:
```markdown
# In skill.md

### Phase 3: Constructive Challenge

#### 3.1 Main Claude Challenges Codex
[Template with guidelines]

#### 3.2 Codex Challenges Main Claude
[codex-session.sh command]
```

**Test**:
```bash
# tmp/test-phase3.sh
bash test-constructive-challenge.sh "Django vs FastAPI"
# Expected: Two challenge outputs in ✅⚠️❌📊 format
```

**Time**: 3-4 hours

---

#### Day 2-3: Phase 4 (Evidence & Refinement)

**Tasks**:
1. ✅ skill.md에 Phase 4 섹션 추가
2. ✅ 응답 템플릿 작성
3. ✅ WebSearch 통합 감지 로직
4. ✅ Evidence 포맷팅 템플릿
5. ✅ "No evidence found" 폴백

**Deliverables**:
```markdown
# In skill.md

### Phase 4: Evidence-Based Refinement

#### 4.1 Main Claude Responds
[Response template with evidence integration]

#### 4.2 Codex Responds
[codex-session.sh continue command]
```

**WebSearch Integration**:
```python
# Pseudo-code in skill.md instructions
if "📊 Evidence Requested:" in challenge:
    query = extract_query(challenge)
    results = WebSearch(query)
    evidence = format_results(results)
```

**Test**:
```bash
# tmp/test-phase4.sh
bash test-evidence-refinement.sh "FastAPI performance benchmark"
# Expected: Response with WebSearch results cited
```

**Time**: 3-4 hours

---

### Week 2: User Features & Polish (6-8 hours)

#### Day 4-5: Phase 5 (User Intervention)

**Tasks**:
1. ✅ Debate summary 템플릿 작성
2. ✅ AskUserQuestion 통합 (3 options)
3. ✅ Loop-back 로직 (deep dive → Phase 3)
4. ✅ Constraint injection (add info → Phase 2)
5. ✅ "Conclude" path (→ Phase 6)

**Deliverables**:
```markdown
# In skill.md

### Phase 5: User Intervention Point

#### 5.1 Present Debate Summary
[Summary template]

#### 5.2 Handle User Input
[AskUserQuestion implementation]
[Loop-back logic]
```

**AskUserQuestion Example**:
```json
{
  "questions": [{
    "question": "What would you like to do next?",
    "header": "Next Step",
    "multiSelect": false,
    "options": [
      {"label": "Deep dive: [topic]", "description": "+30s for focused analysis"},
      {"label": "Add constraint", "description": "Introduce new information"},
      {"label": "Conclude", "description": "Proceed to final synthesis"}
    ]
  }]
}
```

**Test**:
```bash
# tmp/test-phase5.sh
bash test-user-intervention.sh
# Interactive: user selects option, flow continues correctly
```

**Time**: 3-4 hours

---

#### Day 5-6: Phase 2.3 (Unanimous Check) + Phase 6 Update

**Tasks**:
1. ✅ Phase 2.3 추가: Unanimous agreement detection
2. ✅ Self-review prompt (20 words max)
3. ✅ Risk detection logic
4. ✅ Phase 6 업데이트: Multi-round synthesis
5. ✅ Confidence re-evaluation logic

**Deliverables**:
```markdown
# In skill.md

### Phase 2.3: Unanimous Agreement Check (NEW)
[Detection logic]
[Self-review template]
[Decision tree: skip vs continue]

### Phase 6: Final Synthesis (UPDATED)
[Multi-round synthesis template]
[Confidence evolution tracking]
```

**Self-Review Template**:
```
Task: Identify the most likely failure mode of your recommendation in ≤20 words.

Example:
"Most likely failure: Team lacks async expertise, FastAPI learning curve exceeds 3-month timeline."
```

**Test**:
```bash
# tmp/test-unanimous.sh
bash test-unanimous-handling.sh "Python 3.12 vs 3.11?"
# Expected: Self-review → auto-skip to Phase 6 (if safe)
```

**Time**: 2-3 hours

---

#### Day 6-7: Testing & Refinement

**Tasks**:
1. ✅ End-to-end test (3 scenarios)
2. ✅ Performance measurement
3. ✅ Edge case handling
4. ✅ Documentation polish
5. ✅ Examples update

**Test Scenarios**:

**Scenario 1: Fast path (unanimous)**
```
Input: "Should I use Python 3.12 over 3.11?"
Expected: 28s total (Phase 2 → self-review → Phase 6)
```

**Scenario 2: Normal debate**
```
Input: "Django vs FastAPI (5 devs, 10k users, 3 months)"
Expected: 56-86s (Phase 2 → 3 → 4 → 5 [conclude] → 6)
```

**Scenario 3: Deep dive**
```
Input: Same as Scenario 2
User action: "Deep dive on team skillset"
Expected: 86-120s (Phase 2 → 3 → 4 → 5 [deep dive] → 3 → 4 → 6)
```

**Performance Validation**:
```bash
# tmp/test-performance.sh
for i in {1..5}; do
  time bash test-ai-debate-v4.sh "Test question $i"
done
# Target: avg <90s for normal path
```

**Time**: 2-3 hours

---

### Week 2 End: Deployment (1 hour)

**Tasks**:
1. ✅ Git commit all changes
2. ✅ Update version to 4.0.0-complete
3. ✅ `/apply-settings` to global
4. ✅ Verify in test project
5. ✅ Update CHANGELOG.md

**Commit Message**:
```bash
git commit -m "feat(ai-debate): Implement v4.0 Progressive Constructive Debate

Major features:
- Phase 3: Constructive Challenge (✅⚠️❌📊 format)
- Phase 4: Evidence-Based Refinement (WebSearch integration)
- Phase 5: User Intervention Point (deep dive, add constraint, conclude)
- Phase 2.3: Unanimous Agreement Check (self-review + smart skip)
- Phase 6: Multi-round synthesis with confidence evolution

Performance:
- Fast path: 28s (unanimous cases)
- Normal path: 56-86s (full debate)
- Deep dive: 86-120s (user-requested extension)

Breaking changes: None (v3.1 still works, v4.0 is opt-in via trigger)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Verification**:
```bash
cd ~/other-project
claude
> AI 토론: Redis vs Memcached?
# Expected: v4.0 workflow executes successfully
```

**Time**: 1 hour

---

## 4. What NOT to Do (v4.0 Scope Control)

### ❌ Out of Scope for v4.0

**1. Devil's Advocate Mode**
- Reason: 신뢰도 신호 시스템 필요 (v4.1+)
- Action: Skip implementation, document in roadmap

**2. Streaming Output**
- Reason: UX improvement, not core functionality
- Action: Defer to v4.1

**3. Caching System**
- Reason: Optimization, not essential for MVP
- Action: Defer to v4.2

**4. 4+ Agent Support**
- Reason: Complexity explosion
- Action: Stick with Main Claude + Codex

**5. Signal-Based Auto-Extension (Q3)**
- Reason: Signal system not validated yet
- Action: Use user-triggered extension for v4.0, defer auto to v4.2

---

## 5. Risk Mitigation

### R1: Time Budget Overflow (>90s avg)

**Risk**: Normal path takes >90s consistently

**Mitigation**:
- ✅ Unanimous check (fast path): saves 30-50s
- ✅ Parallel execution (Phase 3, 4): saves 15-25s
- ✅ User can skip Phase 5: saves 10-30s
- ⚠️ Monitor: If avg >90s, add "quick mode" flag

**Threshold**: If 5 test runs avg >95s, implement quick mode immediately

---

### R2: Unproductive Back-and-Forth

**Risk**: Agents engage in meaningless rebuttal

**Mitigation**:
- ✅ Enforce "✅ Acknowledge strengths" first
- ✅ Cap at 3 rounds (4 with user deep dive)
- ✅ Require evidence for continued disagreement
- ✅ User can terminate early (Phase 5 "Conclude")

**Detection**: If challenges lack substance (too generic), refine templates

---

### R3: WebSearch Quality

**Risk**: WebSearch returns irrelevant data

**Mitigation**:
- ✅ Use top 3 results (not just 1)
- ✅ Agents must cite sources (transparency)
- ✅ Fallback: "Evidence not found, proceeding with analysis"
- ✅ User can challenge evidence in Phase 5

**Improvement path**: v4.1 adds source whitelisting

---

## 6. Success Criteria

### Must-Have (v4.0 Release Blockers)

- [ ] **P0**: All 6 phases implemented and tested
- [ ] **P0**: Unanimous check works (self-review + auto-skip)
- [ ] **P0**: User intervention point functional (3 options)
- [ ] **P0**: WebSearch integration works
- [ ] **P0**: Performance: Normal path <90s (avg of 5 runs)
- [ ] **P0**: No breaking changes to v3.1 (backward compatible)

### Nice-to-Have (Can defer)

- [ ] **P1**: Quick mode flag (`--quick`)
- [ ] **P1**: Progress indicators ("Round 2/3...")
- [ ] **P2**: Streaming output
- [ ] **P2**: Caching system

---

## 7. Post-Launch Plan (v4.1-4.2)

### v4.1 (2-3 weeks after v4.0)

**Features**:
1. ✅ Devil's Advocate Mode (hybrid: auto + manual)
2. ✅ Quick Mode flag (`AI 토론 --quick`)
3. ✅ WebSearch source whitelisting
4. ✅ Progress indicators

**Time**: 8-10 hours

---

### v4.2 (1-2 months after v4.0)

**Features**:
1. ✅ Caching system (Codex response + WebSearch)
2. ✅ Signal-based auto-extension (Q3 Codex approach)
3. ✅ Confidence/uncertainty signal system
4. ✅ Performance optimization (target: <60s avg)

**Time**: 10-15 hours

---

## 8. Implementation Checklist

### Pre-Implementation
- [x] Design document approved
- [x] Codex debate completed (미해결 질문 해결)
- [x] Implementation plan finalized
- [ ] User confirms: "Start implementation"

### Week 1
- [ ] Day 1-2: Phase 3 implemented
- [ ] Day 2-3: Phase 4 implemented
- [ ] Phase 3-4 tests passing

### Week 2
- [ ] Day 4-5: Phase 5 implemented
- [ ] Day 5-6: Phase 2.3 + Phase 6 updated
- [ ] Day 6-7: E2E tests + edge cases
- [ ] Performance validated (<90s avg)

### Deployment
- [ ] Git commit
- [ ] `/apply-settings`
- [ ] Test in separate project
- [ ] CHANGELOG.md updated
- [ ] User acceptance test

---

## 9. Quick Reference

### Key Files to Modify

```
.claude/skills/ai-collaborative-solver-v2.0/
├── skill.md                    # MAIN FILE (add Phase 3-5, update 2, 6)
└── scripts/
    └── codex-session.sh        # Already exists, use as-is
```

### Estimated Lines of Code

| File | Current | Added | Final |
|------|---------|-------|-------|
| skill.md | ~600 lines | +400 lines | ~1000 lines |
| (No new scripts needed) | - | - | - |

### Key Templates to Create

1. Phase 3 Challenge Template (✅⚠️❌📊)
2. Phase 4 Response Template (with evidence)
3. Phase 5 Summary Template (debate progress)
4. Phase 2.3 Self-Review Prompt (20 words)
5. Phase 6 Multi-Round Synthesis Template

---

## 10. Communication Plan

### User Updates

**After Week 1**:
- ✅ "Phase 3-4 implemented, testing in progress"
- 📊 Performance preview: "[X]s avg for normal path"

**After Week 2**:
- ✅ "v4.0 complete, ready for deployment"
- 📊 Final performance: "[X]s fast path, [Y]s normal, [Z]s deep dive"
- 📋 "Test in your project before global deployment?"

**Post-Deployment**:
- ✅ "v4.0 deployed globally"
- 📖 "User guide: [link]"
- 🐛 "Report issues: [how]"

---

## 11. Rollback Plan

**If v4.0 has critical issues**:

```bash
# Revert to v3.1
git revert [v4.0-commit-hash]
/apply-settings

# Or: Keep both versions
# v3.1: Trigger with "AI 토론 v3"
# v4.0: Trigger with "AI 토론 v4" or "AI 토론 --progressive"
```

**Rollback criteria**:
- Performance >120s consistently
- >50% user complaints
- Breaking existing functionality

---

## 12. Summary: What to Do Next

### Immediate Next Step

**Option 1: Start Implementation Now**
```bash
# Begin Week 1, Day 1 tasks
cd .claude/skills/ai-collaborative-solver-v2.0
# Edit skill.md: Add Phase 3 section
```

**Option 2: Create Issue Tracker**
```bash
# If using Linear/GitHub issues
# Create 10 issues for Week 1-2 tasks
# Assign priorities and estimates
```

**Option 3: Prototype First**
```bash
# Quick proof-of-concept
# Test Phase 3 with mock data (no API calls)
cd tmp/
bash prototype-phase3.sh
```

**Recommendation**: **Option 1** - Direct implementation (설계 완료됨)

---

## Document Metadata

**Based on**:
- Design doc: `docs/roadmap/ai-debate-v4-progressive-design.md`
- Codex debate: Completed 2025-11-04
- User requirements: From `/clarify` session

**Approval Status**: ⏳ Pending user confirmation

**Ready to Start**: ✅ Yes (모든 결정 완료)

---

**Next Action**: 사용자 확인 후 Week 1 Day 1 작업 시작

**Question for User**:
```
지금 바로 구현 시작할까요?
1. 예 → Week 1 Day 1 (Phase 3) 시작
2. 아니오 → 추가 검토할 부분이 있나요?
3. 프로토타입 먼저 → tmp/에 간단한 POC 작성
```
