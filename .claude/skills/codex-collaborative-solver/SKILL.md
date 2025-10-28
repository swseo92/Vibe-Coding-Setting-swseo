---
name: codex-collaborative-solver
description: Solve complex problems through collaborative debate between Claude and OpenAI Codex. Use when users request "codex와 토론", "claude랑 codex 협업", or need multi-perspective analysis for architecture decisions, bug investigation, algorithm optimization, or design patterns. Conducts 3-5 rounds of structured debate to reach consensus solutions.
---

# Codex Collaborative Solver

## Overview

Enable Claude and OpenAI Codex to engage in structured, multi-round debates to solve complex technical problems. By leveraging two different AI perspectives (Anthropic's Claude and OpenAI's Codex), reach more robust solutions through collaborative discussion, challenge assumptions, and cross-validate approaches.

## When to Use This Skill

Activate when users request:
- "codex와 토론해서 해결해줘" / "debate with codex to solve this"
- "claude랑 codex 협업으로 답 찾아줘" / "claude and codex collaborate"
- "두 AI의 의견을 들어보고 싶어" / "want opinions from both AIs"
- Complex problems requiring multi-perspective analysis

**Appropriate problem types:**

1. **Architecture Decisions**
   - "Should we use microservices or monolith?"
   - "Which database fits this use case?"
   - "REST vs GraphQL for our API?"

2. **Bug Investigation**
   - "What's causing this memory leak?"
   - "Where's the performance bottleneck?"
   - "Why does this race condition occur?"

3. **Algorithm Optimization**
   - "Can we improve from O(n²) to O(n log n)?"
   - "What's a better data structure here?"
   - "How to parallelize this computation?"

4. **Design Pattern Selection**
   - "Which design pattern fits this scenario?"
   - "How should we refactor this code?"
   - "What's the best error handling strategy?"

## Prerequisites

**Required:**
- OpenAI Codex CLI installed: `npm i -g @openai/codex`
- ChatGPT Plus/Pro subscription
- Codex authenticated: Run `codex` once

**Verify installation:**
```bash
codex --version
```

## Token Efficiency

**NEW: Stateful Session Management**

This skill now uses **stateful Codex sessions** to dramatically reduce token usage:

**Token Savings:**
- Traditional (stateless): ~6,500 tokens over 5 rounds
- Stateful approach: ~2,100 tokens over 5 rounds
- **67% reduction in token costs!** 🎉

**How it works:**
- Round 1: Full context sent (~3,300 tokens)
- Round 2+: Only new messages (~400-800 tokens each)
- Codex automatically maintains conversation history

**Scripts location:** `.claude/scripts/codex-debate/`

See [Scripts](#scripts) section for details.

## Debate Workflow

### Phase 1: Problem Definition

1. **Collect Context**
   - Understand user's problem thoroughly
   - Ask clarifying questions if needed
   - Gather relevant code/files/context

2. **Frame the Question**
   - Distill into clear, debatable question
   - Identify key constraints and requirements
   - Set success criteria

**Example:**
```
User: "우리 앱이 느려. 어떻게 개선할까?"

Claude frames:
"Question: What's the most effective approach to improve application performance?
Constraints:
- Current stack: Django + PostgreSQL
- 10k daily active users
- Response time currently 2-3 seconds
- Target: <500ms response time
Context: [attaches relevant code]"
```

### Phase 2: Initial Analysis (Claude)

**Claude's role:**
1. Analyze the problem from multiple angles
2. Propose initial approach with reasoning
3. Identify potential weaknesses in own approach
4. Frame questions for Codex

**Template:**
```
My Initial Analysis:
[Problem understanding]

Proposed Approach:
[Detailed solution with reasoning]

Potential Concerns:
[What could go wrong]

Questions for Codex:
[Specific areas where Codex input valuable]
```

### Phase 3: Codex Consultation (Round 1)

**Start a stateful Codex session** using the debate-start.sh script:

```bash
bash .claude/scripts/codex-debate/debate-start.sh "You are participating in a technical debate with Claude (Anthropic).

Problem: [problem statement]

Claude's Analysis:
[Claude's full analysis]

Please provide your perspective:
1. Do you agree with Claude's approach? Why or why not?
2. What alternatives or improvements do you suggest?
3. What are the tradeoffs?
4. What concerns should we address?

Be critical and thorough. Challenge assumptions."
```

**What happens:**
- Codex responds with analysis
- Thread ID saved to `./debate-session/thread_id.txt`
- Ready for subsequent rounds

### Phase 4: Analysis & Response (Claude)

**After receiving Codex response:**

1. **Identify Agreement Points**
   - Where both perspectives align
   - Shared concerns or validations
   - Consensus on approach

2. **Identify Disagreements**
   - Where perspectives diverge
   - Different priorities or assumptions
   - Alternative approaches suggested

3. **Evaluate Arguments**
   - Which arguments are stronger?
   - What evidence supports each view?
   - What's missing from either analysis?

4. **Formulate Response**
   - Acknowledge valid points
   - Defend or revise own position
   - Raise new questions
   - Propose synthesis if possible

### Phase 5: Iterative Debate (Rounds 2-5)

**Continue debate rounds until:**
- Both perspectives converge on solution
- Tradeoffs clearly understood
- No new insights emerging
- 5 rounds completed (maximum)

**Each round (using debate-continue.sh):**
```bash
bash .claude/scripts/codex-debate/debate-continue.sh "Continuing debate on: [problem]

Claude's latest position:
[Claude's updated analysis - NEW THOUGHTS ONLY]

Your response:
1. Address Claude's new points
2. Refine your position
3. Suggest compromises or synthesis
4. Identify remaining gaps

Round X of 5"
```

**Token efficiency in action:**
- ✅ NO need to re-send previous rounds
- ✅ Codex remembers full conversation
- ✅ Only send new analysis/questions
- ✅ Saves ~70% tokens per round

### Phase 6: Consensus & Final Solution

**Synthesize final solution:**

1. **Agreed Approach**
   - What both perspectives support
   - Consensus on implementation
   - Validated by both AIs

2. **Acknowledged Tradeoffs**
   - Limitations of chosen approach
   - Alternative paths not taken
   - When to reconsider

3. **Implementation Guidance**
   - Step-by-step plan
   - Risk mitigation strategies
   - Success metrics

4. **Dissenting Views**
   - Where disagreement remains
   - Why each AI holds their position
   - Let user decide

### Phase 7: Generate Debate Report

Use template from `assets/debate-report-template.md` to create comprehensive report:

```bash
# Save report
.debate-reports/YYYY-MM-DD-HH-MM-[problem-slug].md
```

Report includes:
- Problem statement
- Full debate transcript (all rounds)
- Consensus solution
- Tradeoff analysis
- Implementation plan
- Dissenting opinions (if any)

### Phase 8: Cleanup Session

**Clean up Codex session** after debate completes:

```bash
bash .claude/scripts/codex-debate/debate-end.sh
```

**What happens:**
- Removes `./debate-session/` directory
- Cleans up thread_id and session files
- Frees up storage

**Important:** Always run cleanup after finishing a debate to avoid stale sessions.

## Debate Protocol Guidelines

For detailed debate rules and best practices, see `references/debate-protocol.md`.

**Key principles:**

1. **Intellectual Honesty**
   - Admit when uncertain
   - Change position when evidence warrants
   - Acknowledge valid counterarguments

2. **Constructive Challenge**
   - Question assumptions respectfully
   - Seek understanding before disagreeing
   - Focus on ideas, not winning

3. **Evidence-Based**
   - Support claims with reasoning
   - Reference documentation when possible
   - Distinguish opinion from fact

4. **User-Centric**
   - Keep user's constraints in mind
   - Prioritize practical solutions
   - Consider user's skill level

## Example Debate Session

**User Request:**
"codex와 토론해서 이 성능 문제 해결법 찾아줘. 데이터베이스 쿼리가 너무 느려."

**Debate Flow (with Stateful Scripts):**

```
=== Phase 1: Problem Definition ===
Claude: "Analyzing slow query issue...
[Examines code, identifies N+1 query pattern]

Question: How should we optimize database queries in this Django API?
Context: 100+ queries per request, causing 3s response time"

=== Phase 2: Claude Initial Analysis ===
Claude: "My analysis suggests eager loading with select_related()
and prefetch_related() to eliminate N+1 queries.

Proposed: Refactor views to use optimized querysets.

Concerns: May increase memory usage for large datasets."

=== Phase 3: Codex Round 1 (START SESSION) ===
bash .claude/scripts/codex-debate/debate-start.sh "Problem: Django query optimization...
Claude's analysis: [eager loading approach]
Your perspective?"

✓ Thread ID: 019a2d18-c64a-7ef3-aae3-71e536186462
✓ Tokens used: 3,320

Codex: "Eager loading is good for predictable relations, but
I see you're dealing with dynamic filtering. Consider:

1. Database indexing first (missing indexes on foreign keys)
2. Query result caching (Redis)
3. Database connection pooling
4. Then eager loading where applicable

Eager loading alone won't solve if queries aren't indexed."

=== Phase 4: Claude Response ===
Claude: "Excellent point about indexes. I assumed they existed.
Let me verify... [checks schema]

You're right - foreign keys aren't indexed! This explains
the slowness. Revised approach:

1. Add indexes (immediate win)
2. Implement eager loading (eliminates N+1)
3. Add Redis caching (for frequently accessed data)

Let me ask Codex about implementation priority..."

=== Phase 5: Codex Round 2 (CONTINUE SESSION) ===
bash .claude/scripts/codex-debate/debate-continue.sh "Claude's updated position:
Indexes first, then eager loading, then Redis.
Do you agree with this priority?"

✓ Resuming: 019a2d18-c64a-7ef3-aae3-71e536186462
✓ Tokens used: 768 (only new message!)
✓ Token savings: 77% vs re-sending full context

Codex: "Yes, that's the right priority order. One addition:
before Redis caching, use Django's query cache
(simpler, no new infrastructure).

For Redis later: cache invalidation strategy is critical.
Consider using cache-aside pattern with TTL."

=== Phase 6: Consensus ===
Both agree on:
1. Add database indexes (highest impact)
2. Implement eager loading (eliminate N+1)
3. Start with Django query cache
4. Upgrade to Redis when needed

Report generated: .debate-reports/2025-10-29-15-30-db-query-optimization.md

=== Phase 8: Cleanup ===
bash .claude/scripts/codex-debate/debate-end.sh
✓ Session cleaned up

**Total tokens: ~5,000 (vs ~8,000 without stateful sessions)**
```

## Advanced Usage

### Focused Debates

For specific aspects, direct the debate:

```
"codex랑 security 관점에서만 토론해줘"
"focus debate on performance only"
"debate different architectures, not implementation details"
```

### Pre-existing Solutions

When comparing existing solutions:

```
"Option A: [approach 1]
Option B: [approach 2]

codex랑 토론해서 어느게 나은지 결정해줘"
```

### Team Decision Support

For team discussions, get AI perspectives first:

```
"팀에서 이 문제로 의견이 갈려.
codex와 토론해서 각 접근법의 장단점 분석해줘"
```

## Output Structure

Each debate session produces:

1. **Console Summary** (Real-time)
   - Round-by-round highlights
   - Key agreements/disagreements
   - Emerging consensus

2. **Debate Report** (`.debate-reports/`)
   - Full transcript
   - Analysis and synthesis
   - Implementation recommendations
   - Timestamp and context

3. **Implementation Plan** (If requested)
   - Step-by-step execution
   - Code changes needed
   - Testing strategy

## Best Practices

### Do's ✅

1. **Provide Rich Context**
   - Share relevant code files
   - Explain constraints clearly
   - Include error messages/logs

2. **Let Debate Evolve**
   - Allow multiple rounds
   - Don't rush to consensus
   - Embrace disagreement initially

3. **Guide, Don't Dictate**
   - Frame good questions
   - Let AIs explore freely
   - Intervene only if stuck

4. **Save Debate Reports**
   - Keep `.debate-reports/` in git
   - Learn from past debates
   - Share with team

5. **Critically Evaluate**
   - Both AIs can be wrong
   - Use your judgment
   - Test solutions thoroughly

### Don'ts ❌

1. **Don't Skip Context**
   - Vague problems → vague solutions
   - Missing constraints → impractical advice

2. **Don't Expect Perfect Agreement**
   - Some problems have no "right" answer
   - Tradeoffs are real
   - Disagreement can be valuable

3. **Don't Automate Blindly**
   - Review all suggestions
   - Understand the reasoning
   - Validate against requirements

4. **Don't Overuse**
   - Simple problems don't need debate
   - Save for complex decisions
   - Consider time investment

5. **Don't Ignore Implementation**
   - Great ideas need execution
   - Test the consensus solution
   - Iterate based on results

## Troubleshooting

### "Codex CLI not found"

Install and authenticate:
```bash
npm i -g @openai/codex
codex  # Run once to authenticate
```

### "Debate isn't converging"

After 5 rounds without consensus:
- Identify core disagreement
- Research the disputed point
- Get human expert opinion
- Let user decide based on tradeoffs

### "Responses are too generic"

Provide more specific context:
- Share actual code, not descriptions
- Include exact error messages
- Specify concrete constraints
- Ask targeted questions

### "Codex keeps agreeing with Claude"

Prompt Codex to be more critical:
```bash
codex exec "...

IMPORTANT: Your role is to challenge Claude's thinking.
Even if the approach seems reasonable, identify potential
issues, edge cases, or alternatives. Be the devil's advocate."
```

## Comparison to Other Approaches

| Approach | Pros | Cons |
|----------|------|------|
| **Claude Only** | Fast, integrated | Single perspective |
| **Codex Only** | Autonomous, can execute | Limited by one model |
| **Claude-Codex Debate** | Multi-perspective, validated | Slower, requires both subscriptions |
| **Human Team Debate** | Real experience, domain knowledge | Time-intensive, scheduling challenges |

**Best for:** Complex, high-stakes decisions where multiple perspectives add value.

## Resources

### Scripts

**Stateful Session Management (NEW!):**

Located in `.claude/scripts/codex-debate/`:

1. **debate-start.sh** - Start new Codex debate session
   - Captures thread ID
   - Saves session state
   - Returns Codex's first response

2. **debate-continue.sh** - Continue existing session
   - Loads thread ID automatically
   - Sends only new messages (token efficient!)
   - Maintains conversation context

3. **debate-end.sh** - Clean up session
   - Removes session files
   - Frees up storage

**Full documentation:** `.claude/scripts/codex-debate/README.md`

**Quick example:**
```bash
# Round 1
bash .claude/scripts/codex-debate/debate-start.sh "Your question"

# Round 2
bash .claude/scripts/codex-debate/debate-continue.sh "Follow-up"

# Cleanup
bash .claude/scripts/codex-debate/debate-end.sh
```

### References

- `references/debate-protocol.md` - Detailed rules and guidelines for conducting effective debates

### Assets

- `assets/debate-report-template.md` - Markdown template for generating final debate reports

## Limitations

This skill cannot:
- Replace human judgment and domain expertise
- Execute code or run tests (use separately)
- Access external APIs or databases
- Guarantee "correct" answer (provides perspectives)
- Work without Codex CLI installed
- Work offline (requires OpenAI API access)

**Remember:** AI debate is a tool for exploration and validation, not a replacement for human decision-making.

---

**Version:** 2.0 (Stateful)
**Last Updated:** 2025-10-29
**Models:** Claude 3.5 Sonnet (Anthropic) + GPT-5 Codex via Codex CLI (OpenAI)

**Changelog:**
- v2.0 (2025-10-29): Added stateful session management with 67% token savings
- v1.0 (2025-01-27): Initial release with stateless approach
