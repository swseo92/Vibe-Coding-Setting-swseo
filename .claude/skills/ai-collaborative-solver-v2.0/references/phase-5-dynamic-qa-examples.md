# Phase 5: Dynamic Q&A - Detailed Examples

This reference provides comprehensive examples of content-driven user participation during AI debates (Phase 5.1) and user intervention patterns (Phase 5.2).

**When to use this**: Reference these examples when implementing Dynamic Q&A or User Intervention patterns.

---

## Part 1: Dynamic Q&A Examples (Phase 5.1)

### Example 1: Phase 2 - Team Experience Uncertainty

**Context**: While generating Phase 2 opinion, you encounter uncertainty about team capabilities.

```markdown
### Your Analysis (Phase 2.1)

While generating opinion:
"FastAPI is great for async workloads, but **I don't know if the team has async/await experience**..."

[Pause and Ask]
❓ AskUserQuestion({
  "question": "Does your team have Python async/await experience?",
  "header": "Async exp",
  "options": [
    {"label": "Yes (1+ year)", "description": "Production experience with async code"},
    {"label": "Some (tutorials)", "description": "Basic understanding, no production use"},
    {"label": "None", "description": "Never used async/await"}
  ]
})

[User answers: "None"]

✅ "Thank you! Since team has NO async experience, I'll adjust my recommendation:
- FastAPI's async benefits are offset by learning curve
- Django's synchronous model is safer for your team"

[Continue with enriched context]
```

---

### Example 2: Phase 3 - Challenge Based on Missing Info

**Context**: During Phase 3 challenge review, Codex makes an assumption you need to validate.

```markdown
### Phase 3.1 Challenge

Codex mentioned:
"Team should be able to handle Django Channels complexity"

[You detect assumption]
"Codex is **assuming WebSocket experience**, but I'm not sure..."

[Pause and Ask]
❓ AskUserQuestion({
  "question": "Does your team have real-time communication (WebSocket, SSE) experience?",
  "header": "Realtime exp",
  "options": [
    {"label": "Yes (production)", "description": "Built production WebSocket/SSE apps"},
    {"label": "Yes (prototypes)", "description": "Experimented but not in production"},
    {"label": "No", "description": "No real-time experience"}
  ]
})

[User answers: "No"]

✅ "Thank you! This is important for the challenge:

**Challenge to Codex**:
❌ Weak Spot: You assumed WebSocket experience, but team has NONE.
- Django Channels learning curve: 2-3 weeks
- This significantly impacts the recommendation"

[Continue Phase 3 with real context]
```

---

### Example 3: Phase 4 - Evidence Validation

**Context**: During evidence gathering, you find data that requires user-specific interpretation.

```markdown
### Phase 4.1 Evidence Gathering

🔍 WebSearch: "Django Channels learning curve"
📊 Found: "Average learning time: 2-3 weeks for experienced Django developers"

[You need context to interpret this]
"Is 2-3 weeks acceptable for this project's timeline?"

[Pause and Ask]
❓ AskUserQuestion({
  "question": "Your project timeline is 3 months. Is 2-3 weeks for Channels learning acceptable?",
  "header": "Timeline fit",
  "options": [
    {"label": "Yes, fine", "description": "We have buffer time"},
    {"label": "Tight", "description": "Doable but risky"},
    {"label": "Too risky", "description": "Can't afford this delay"}
  ]
})

[User answers: "Too risky"]

✅ "Thank you! This changes the recommendation:

**Evidence Conclusion**:
❌ 2-3 weeks learning is TOO RISKY for your 3-month timeline
→ FastAPI WebSocket (1 week learning) is safer choice
→ Confidence adjustment: Django 90% → 60%, FastAPI 10% → 40%"

[Continue with adjusted view]
```

---

### Example 4: Priority Clarification

**Context**: During Phase 2 synthesis, you identify a trade-off that requires user priority input.

```markdown
### Phase 2 Synthesis

"There's a trade-off: FastAPI is faster (5x) but Django is more productive (2x faster dev)"

[Need user priority]
"Which is more important depends on user's priorities..."

[Pause and Ask]
❓ AskUserQuestion({
  "question": "For this project, which is more critical?",
  "header": "Priority",
  "options": [
    {"label": "Performance", "description": "Response speed is top priority"},
    {"label": "Speed to market", "description": "Fast development & launch"},
    {"label": "Balance", "description": "Both are important"}
  ]
})

[User answers: "Speed to market"]

✅ "Thank you! With speed-to-market as priority:
- Django's productivity advantage is MORE valuable
- FastAPI's performance edge is LESS critical
→ Stronger Django recommendation (90% → 95%)"

[Adjust synthesis accordingly]
```

---

## Part 2: User Intervention Examples (Phase 5.2)

### Step 1: Summarize Current State (After Phase 4)

```markdown
## 📊 Phase 4 Complete - Debate Summary

**Original Question**: Should we use Django or FastAPI for our 10,000 DAU REST API project?

**Round 1 (Phase 2)**:
- Your initial view: Django (85%)
  - Reasoning: Admin panel, ORM, ecosystem, beginner-friendly
- Codex initial view: Django (90%)
  - Reasoning: Team experience, timeline, built-in features
- Agreement level: 95%

**Round 2 (Phase 3-4)**:
- Key challenges raised:
  - FastAPI performance advantage (5x faster)
  - Django Channels complexity for WebSocket
  - Learning curve differences
- Evidence gathered:
  - Django Channels learning: 2-3 weeks
  - FastAPI WebSocket learning: 1 week
  - Team has NO async/WebSocket experience
- Confidence changes:
  - Your view: 85% → 90% (Django)
  - Codex view: 90% → 85% (Django)

**Current Recommendation**: Django (87.5% average confidence)

**Key Insights Discovered**:
1. Team's lack of async experience is critical constraint
2. 3-month timeline can't afford 2-3 week Channels learning
3. Performance difference (5x) less critical than productivity for 10K DAU
```

---

### Step 2: Ask User What to Do Next

```markdown
AskUserQuestion({
  "questions": [{
    "question": "How would you like to proceed?",
    "header": "Next step",
    "multiSelect": false,
    "options": [
      {
        "label": "Conclude debate",
        "description": "Current analysis is sufficient. Generate final recommendation (Phase 6)"
      },
      {
        "label": "Dig deeper",
        "description": "Focus on specific aspect with another evidence-gathering round"
      },
      {
        "label": "Add constraint",
        "description": "I have new requirements. Let's restart with updated context"
      }
    ]
  }]
})
```

---

### Step 3: Handle User Choice - Option A (Conclude)

```markdown
✅ User chose to conclude.

"Great! I'll now synthesize all insights from our debate into a comprehensive final recommendation..."

Proceeding to Phase 6: Final Synthesis...
```

→ Go to Phase 6

---

### Step 3: Handle User Choice - Option B (Dig Deeper)

```markdown
✅ User wants to dig deeper.

"I'd like to investigate one aspect more thoroughly. Which area should we focus on?"

AskUserQuestion({
  "questions": [{
    "question": "Which aspect should we investigate more deeply?",
    "header": "Focus area",
    "options": [
      {
        "label": "Performance impact",
        "description": "Is 5x speed difference significant for our scale?"
      },
      {
        "label": "WebSocket options",
        "description": "Alternative real-time solutions beyond Channels"
      },
      {
        "label": "Team ramp-up",
        "description": "Detailed learning timeline for both options"
      }
    ]
  }]
})

[User selects: "WebSocket options"]

✅ "Thank you! Let's do a focused analysis on WebSocket alternatives..."

**Focused Analysis Round 2**:
1. Reformulate challenges focusing on WebSocket alternatives
2. Gather MORE evidence on alternative real-time solutions
3. Return to Phase 3 with narrowed focus

[Execute Phase 3-4 again with focused scope]
→ After completion, return to Phase 5.2 (this step) for next decision
```

---

### Step 3: Handle User Choice - Option C (Add Constraint)

```markdown
✅ User has new constraints.

"What changed that we should incorporate into our analysis?"

AskUserQuestion({
  "questions": [{
    "question": "What new constraint or requirement should we consider?",
    "header": "New info",
    "options": [
      {"label": "Timeline changed", "description": "Deadline moved"},
      {"label": "Budget constraint", "description": "Cost became factor"},
      {"label": "Team changed", "description": "Team size/experience shifted"},
      {"label": "New requirement", "description": "Feature/requirement added"}
    ]
  }]
})

[User selects: "Team changed" and explains: "We hired 2 senior engineers with FastAPI experience"]

✅ "Thank you! This is a game-changer. Let's restart analysis with this new constraint..."

**Restart from Phase 1**:
1. Incorporate new constraint: "Team now has 2 FastAPI experts"
2. Re-run Phase 2-4 with updated context
3. Compare new results with previous round (Django 87.5% vs ???)

→ Execute Phase 1 again with [original context + new constraint]
→ Track this as "Round 2" in Phase 6 history
```

---

## Uncertainty Markers - Quick Reference

Watch for these phrases that should trigger Dynamic Q&A:

**Direct uncertainty**:
- "I don't know..."
- "I'm not sure..."
- "Unclear whether..."
- "It's uncertain..."

**Conditional assumptions**:
- "It depends on..."
- "Assuming that..."
- "If the team has..."
- "Provided that..."

**Missing critical info**:
- "We need to know..."
- "This hinges on..."
- "The answer varies based on..."
- "Critical factor is..."

**When in doubt**: Ask! User clarification always improves debate quality.
