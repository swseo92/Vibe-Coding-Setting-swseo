# Mid-Debate User Input Prompt Templates

**Purpose:** Ready-to-use templates for requesting user input during Claude-Codex debates.

---

## Template 1: Information Deficit

**Use when:** Missing critical information that affects solution choice.

```markdown
## 🤔 Mid-Debate User Input Required

**Round:** {round_number} / 5
**Type:** Information Needed

### Current Discussion

{brief_summary_1_2_sentences}

### Why We're Asking

We've identified {number} viable approaches, but choosing the best one requires information about {missing_aspect}.

### Your Input Needed

**Question:** {specific_question}

### Options

1. **{option_1_name}**
   - Description: {brief_description}
   - Best for: {use_case}
   - Trade-off: {consideration}

2. **{option_2_name}**
   - Description: {brief_description}
   - Best for: {use_case}
   - Trade-off: {consideration}

3. **Skip** - We'll proceed with our best judgment based on assumptions.

---
*Your answer helps us provide a solution that better fits your needs.*
```

**Example Usage:**
```markdown
## 🤔 Mid-Debate User Input Required

**Round:** 2 / 5
**Type:** Information Needed

### Current Discussion

We're evaluating caching strategies for your Django API. Both Redis and Memcached are technically sound options.

### Why We're Asking

The best choice depends on whether you need cached data to persist across server restarts.

### Your Input Needed

**Question:** Do you need cached data to survive server restarts?

### Options

1. **Yes, persistence required**
   - Description: Use Redis (in-memory + optional disk persistence)
   - Best for: Session data, frequently accessed objects that shouldn't be lost
   - Trade-off: Slightly more complex setup, marginally slower

2. **No, ephemeral cache is fine**
   - Description: Use Memcached (pure in-memory, faster)
   - Best for: Temporary computed results, read-heavy queries
   - Trade-off: Data lost on restart, but simpler and faster

3. **Skip** - We'll recommend Redis for flexibility.

---
*Your answer helps us provide a solution that better fits your needs.*
```

---

## Template 2: Preference Fork

**Use when:** Trade-off requires user priority judgment.

```markdown
## 🤔 Mid-Debate User Input Required

**Round:** {round_number} / 5
**Type:** Preference Needed

### Current Discussion

{brief_summary_1_2_sentences}

### Why We're Asking

Both approaches are technically valid but optimize for different goals. We need to know your priority.

### Trade-Off Analysis

| Aspect | Option A: {name} | Option B: {name} |
|--------|------------------|------------------|
| {dimension_1} | {value_a} | {value_b} |
| {dimension_2} | {value_a} | {value_b} |
| {dimension_3} | {value_a} | {value_b} |

### Your Input Needed

**Question:** Which aspect is most important for your use case?

### Options

1. **Prioritize {aspect_1}** → Choose Option A
2. **Prioritize {aspect_2}** → Choose Option B
3. **Balanced approach** → Hybrid solution (some compromise)
4. **Skip** - We'll aim for balance.

---
*Your priority helps us make the right trade-off for your situation.*
```

**Example Usage:**
```markdown
## 🤔 Mid-Debate User Input Required

**Round:** 3 / 5
**Type:** Preference Needed

### Current Discussion

We're debating between eager loading (select_related) and lazy loading with caching for your Django ORM queries.

### Why We're Asking

Both approaches work, but they optimize for different goals. We need to know your priority.

### Trade-Off Analysis

| Aspect | Option A: Eager Loading | Option B: Lazy + Caching |
|--------|-------------------------|--------------------------|
| Performance | Faster (1 query) | Moderate (N+1 cached) |
| Code Complexity | Simple, explicit | More complex setup |
| Memory Usage | Higher per request | Lower, distributed |
| Flexibility | Less flexible | Very flexible |
| Setup Time | Quick (1 day) | Longer (3 days) |

### Your Input Needed

**Question:** What's your highest priority?

### Options

1. **Prioritize Performance** → Eager loading (faster, simpler)
2. **Prioritize Flexibility** → Lazy + caching (more work upfront)
3. **Balanced approach** → Eager for common cases, lazy for others
4. **Skip** - We'll recommend eager loading for simplicity.

---
*Your priority helps us make the right trade-off for your situation.*
```

---

## Template 3: New Constraint Discovery

**Use when:** Debate reveals constraint not mentioned in pre-clarification.

```markdown
## 🤔 Mid-Debate User Input Required

**Round:** {round_number} / 5
**Type:** Constraint Validation

### Current Discussion

{brief_summary_1_2_sentences}

### Why We're Asking

We discovered a constraint that affects our approach: {discovered_constraint}

### Impact on Solution

{explain_how_this_changes_things}

### Your Input Needed

**Question:** {ask_about_constraint_acceptability}

### Options

1. **Accept constraint** - Adjust approach accordingly
   - Implications: {what_changes}

2. **Find workaround** - Alternative with trade-offs
   - Workaround: {describe_workaround}
   - Trade-offs: {list_cons}

3. **Re-evaluate requirements** - This might change the goal
   - What we'd need to revisit: {aspects}

4. **Skip** - We'll assume constraint is acceptable.

---
*Your clarification prevents us from proposing an unworkable solution.*
```

**Example Usage:**
```markdown
## 🤔 Mid-Debate User Input Required

**Round:** 2 / 5
**Type:** Constraint Validation

### Current Discussion

We're designing a real-time notification system for your app.

### Why We're Asking

We discovered this approach requires WebSocket support, which means:
- Your hosting needs WebSocket-capable infrastructure
- This may conflict with your current "shared hosting" constraint

### Impact on Solution

If WebSockets aren't available:
- Real-time becomes "near real-time" (polling every 5-30s)
- OR we need to upgrade hosting
- OR use a third-party service (Pusher, Ably)

### Your Input Needed

**Question:** Can you upgrade to WebSocket-capable hosting, or should we design for polling?

### Options

1. **Accept constraint (use polling)**
   - Implications: 5-30s delay, higher server load

2. **Upgrade hosting**
   - Workaround: Move to VPS/cloud with WebSocket support
   - Trade-offs: Higher cost (~$20/month), migration work

3. **Use third-party service**
   - Workaround: Pusher or Ably for WebSockets
   - Trade-offs: External dependency, ~$50/month

4. **Skip** - We'll design for polling (safest assumption).

---
*Your clarification prevents us from proposing an unworkable solution.*
```

---

## Template 4: Deadlock Resolution

**Use when:** 3+ rounds without convergence, need user as tie-breaker.

```markdown
## 🤔 Mid-Debate User Input Required

**Round:** {round_number} / 5
**Type:** Tie-Breaker Needed

### Current Discussion

After {N} rounds, Claude and Codex have not reached consensus on {topic}.

### Why We're Asking

Both perspectives have merit, and the best choice depends on your specific context.

### Competing Perspectives

**Claude's Position:**
- Main argument: {claude_key_point}
- Rationale: {claude_reasoning}
- Best for: {claude_use_case}

**Codex's Position:**
- Main argument: {codex_key_point}
- Rationale: {codex_reasoning}
- Best for: {codex_use_case}

### Your Input Needed

**Question:** Which perspective aligns better with your priorities?

### Options

1. **Go with Claude's approach**
   - Summary: {brief_summary}
   - Why: {when_this_makes_sense}

2. **Go with Codex's approach**
   - Summary: {brief_summary}
   - Why: {when_this_makes_sense}

3. **Provide additional context** (tell us more about {aspect})

4. **Skip** - We'll synthesize a hybrid approach.

---
*Your input helps us break the tie and converge on a solution.*
```

**Example Usage:**
```markdown
## 🤔 Mid-Debate User Input Required

**Round:** 4 / 5
**Type:** Tie-Breaker Needed

### Current Discussion

After 3 rounds, Claude and Codex have not reached consensus on whether to refactor or rewrite your legacy module.

### Why We're Asking

Both approaches have merit, and the best choice depends on your risk tolerance and timeline.

### Competing Perspectives

**Claude's Position:**
- Main argument: Refactor incrementally (safer, gradual improvement)
- Rationale: Preserves existing tests, lower risk, can deploy sooner
- Best for: Risk-averse teams, tight timelines, production stability critical

**Codex's Position:**
- Main argument: Rewrite from scratch (cleaner, modern architecture)
- Rationale: Legacy code too tangled, rewrite faster long-term, better maintainability
- Best for: Teams with time, willingness to rebuild tests, long-term investment

### Your Input Needed

**Question:** Which perspective aligns better with your priorities?

### Options

1. **Go with Claude's approach (Refactor)**
   - Summary: Incremental improvement, lower risk
   - Why: If you need production stability and can't afford downtime

2. **Go with Codex's approach (Rewrite)**
   - Summary: Fresh start, modern patterns
   - Why: If you have 2-3 months and want long-term maintainability

3. **Provide additional context**
   - Tell us more about: Timeline flexibility, team size, risk tolerance

4. **Skip** - We'll recommend hybrid: rewrite critical parts, refactor the rest.

---
*Your input helps us break the tie and converge on a solution.*
```

---

## Template 5: Quick Yes/No Validation

**Use when:** Simple validation needed, binary choice.

```markdown
## 🤔 Quick Validation Needed

**Question:** {simple_yes_no_question}

**Context:** {one_sentence_why}

**Options:**
- **Yes** → {what_happens_if_yes}
- **No** → {what_happens_if_no}
- **Skip** → {default_assumption}

---
*Quick answer helps us stay on track.*
```

**Example Usage:**
```markdown
## 🤔 Quick Validation Needed

**Question:** Can you add new Python dependencies to your project?

**Context:** The optimal solution uses `celery` for async tasks, but we need to confirm you can install it.

**Options:**
- **Yes** → We'll design with Celery (recommended)
- **No** → We'll use Django's built-in async or simpler alternatives
- **Skip** → We'll assume yes (most projects can)

---
*Quick answer helps us stay on track.*
```

---

## Usage Guidelines

### Formatting Rules

1. **Always include Round number** - Shows progress
2. **Keep summary brief** - 1-2 sentences max
3. **Explain WHY asking** - Builds trust
4. **Provide context, not just options** - Help user make informed choice
5. **Always include Skip option** - No user should feel forced
6. **Add reassuring note** - Reduce pressure

### Tone Guidelines

- ✅ Collaborative: "We need your help to..."
- ✅ Specific: "Which is more important: X or Y?"
- ✅ Reassuring: "If you skip, we'll proceed with..."

- ❌ Vague: "What do you think?"
- ❌ Demanding: "You must choose..."
- ❌ Apologetic: "Sorry to bother but..."

### Length Guidelines

- **Minimum:** Question + 2 options + skip
- **Target:** Full template with context
- **Maximum:** Don't exceed 15 lines (user attention span)

### Response Handling

**User answers Option 1/2/3:**
```markdown
Thank you! Based on your input ({user_answer}), we'll proceed with {approach}.

Continuing debate with this context...
```

**User skips:**
```markdown
No problem. We'll proceed with our best judgment: {default_choice}.

Reasoning: {why_this_default}

Continuing debate...
```

**User provides additional context:**
```markdown
Excellent, this helps! Key points noted:
- {point_1}
- {point_2}

Incorporating this into our analysis...
```

---

## Integration Points

### With Heuristic Module

```
Heuristic detects condition
    ↓
Select appropriate template
    ↓
Fill in {placeholders} with context
    ↓
Display to user
    ↓
Capture response
    ↓
Log to reasoning log
    ↓
Continue debate with input
```

### With Quality Gate

After debate, verify:
- Was correct template used for condition?
- Were placeholders filled appropriately?
- Was user's response integrated correctly?

---

## Customization

**Project-specific templates:**

Create `.claude/skills/codex-collaborative-solver/facilitator/prompts/custom-mid-debate.md` for project-specific formats.

**Global settings override:**

```json
{
  "codex_debate": {
    "mid_debate_prompts": {
      "template_style": "concise",  // "concise" | "detailed" | "custom"
      "always_show_skip": true,
      "max_options": 3
    }
  }
}
```

---

**Version:** 1.0
**Last Updated:** 2025-10-31
**Templates:** 5 core + 1 quick validation
