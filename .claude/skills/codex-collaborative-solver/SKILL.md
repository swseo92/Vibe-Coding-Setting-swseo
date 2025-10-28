---
name: codex-collaborative-solver
description: Solve complex problems through collaboration between Claude and OpenAI Codex. Use when users request "codex와 토론", "claude랑 codex 협업", or need multi-perspective analysis for architecture decisions, bug investigation, algorithm optimization, or design patterns. Conducts 3-5 rounds of structured discussion to reach comprehensive solutions.
---

# Codex Collaborative Solver

## Overview

Enable Claude and OpenAI Codex to engage in structured, multi-round discussions to solve complex technical problems. By leveraging two different AI perspectives (Anthropic's Claude and OpenAI's Codex), reach more robust solutions through collaborative problem-solving, complementary insights, and multi-angle analysis.

## When to Use This Skill

Activate when users request:
- "codex와 토론해서 해결해줘" / "collaborate with codex to solve this"
- "claude랑 codex 협업으로 답 찾아줘" / "claude and codex work together"
- "두 AI의 의견을 들어보고 싶어" / "want perspectives from both AIs"
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

## Discussion Workflow

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

### Phase 2: Claude's Opening Analysis

**CRITICAL: Claude must OUTPUT to user first, BEFORE calling Codex.**

**Claude's role:**
1. Analyze the problem thoroughly
2. **OUTPUT to user:** Present your analysis and proposed approach
3. Share your reasoning clearly
4. THEN call Codex to get additional perspective

**Output to User (clear and thoughtful):**
```
=== Round 1: My Analysis ===

My understanding of [problem]:
[Deep analysis of the problem]

My proposed approach:
[Specific solution with reasoning]

Why I think this approach works:
- [Reason 1 with explanation]
- [Reason 2 with explanation]
- [Reason 3 with explanation]

Now let me get Codex's perspective to see if there are additional insights...
[Call Codex via Bash]
```

**Guidelines:**
- ✅ Share your analysis clearly and thoroughly
- ✅ Explain your reasoning
- ✅ Be open to additional insights and improvements
- ✅ Focus on problem-solving, not being "right"

### Phase 3: Codex Response (Round 1)

Call Codex with **Claude's analysis** as the starting point:

```bash
codex exec "You are Codex (OpenAI) collaborating with Claude (Anthropic) to solve a technical problem.

Problem: [problem statement with context]

Claude's Analysis:
[Claude's full analysis and proposed approach]

Your role: Provide your own perspective to help find the best solution.

1. Analyze the problem from your perspective
2. Share YOUR approach (you may agree, have a different view, or suggest complementary ideas)
3. If you have a different perspective, explain your reasoning
4. If you agree with Claude, add any additional insights or considerations
5. Identify any potential issues or improvements

This is collaborative problem-solving. Build on good ideas and share alternative perspectives where valuable."
```

### Phase 4: Claude's Response

**CRITICAL: After receiving Codex response, OUTPUT to user again.**

**Claude's role:**
1. Read Codex's perspective carefully
2. **OUTPUT to user:** Share your thoughts and synthesis
3. Identify valuable insights from Codex
4. Integrate good ideas into the solution
5. Clarify any remaining considerations

**Output to User:**
```
=== Round 1: After Hearing Codex ===

Codex's key insights:
- [Key insight 1]
- [Key insight 2]

Thoughts on Codex's perspective:
[What resonates, what adds value, any different considerations]

Integrated solution:
[Combined approach incorporating the best ideas from both perspectives]

Additional considerations:
[Any trade-offs, open questions, or refinements needed]

[If more discussion would be valuable, continue to Phase 5]
```

**Guidelines:**
- ✅ Genuinely consider Codex's insights
- ✅ Build on good ideas from both perspectives
- ✅ Explain your reasoning when you have different views
- ✅ Focus on finding the best solution, not "winning"
- ✅ Synthesize ideas to create something better than either alone

### Phase 5: Iterative Discussion (Rounds 2-5)

**Each round follows same pattern:**

1. **Claude OUTPUT to user first:**
```
=== Round X: Further Thoughts ===

Based on our discussion so far:
[Brief summary of what we've learned]

My current thinking:
[Refined approach with reasoning]

[Then call Codex for additional input]
```

2. **Call Codex:**
```bash
codex exec "Collaboration Round X of 5

Problem: [problem]

Discussion so far:
- Round 1: [Key insights from both perspectives]
- Round 2: [Key insights from both perspectives]
...

Claude's latest thinking:
[Claude's refined approach with reasoning]

Your response:
1. Share your thoughts on Claude's refinements
2. Add any new insights or considerations
3. Identify what we've converged on
4. Suggest any remaining aspects to explore

Continue the collaborative problem-solving."
```

3. **Claude OUTPUT synthesis to user:**
```
=== Round X: After Codex Input ===

[Integration of Codex's latest insights]
[Current state of the solution]
[Progress toward final approach]
```

**Continue until:**
- Strong solution emerges (perspectives converge or complement)
- Key trade-offs clearly understood
- No significant new insights (discussion naturally concludes)
- 5 rounds completed (practical limit)

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

### Phase 7: Generate Discussion Report

Use template from `assets/debate-report-template.md` to create comprehensive report:

```bash
# Save report to .debate-reports/ (legacy path name)
.debate-reports/YYYY-MM-DD-HH-MM-[problem-slug].md
```

Report includes:
- Problem statement
- Full discussion transcript (all rounds)
- Consensus solution
- Tradeoff analysis
- Implementation plan
- Alternative perspectives (if any)

## Collaboration Guidelines

For detailed collaboration practices, see `references/debate-protocol.md`.

**Key principles:**

1. **Intellectual Honesty**
   - Admit when uncertain
   - Update views when evidence warrants
   - Acknowledge valuable insights from others

2. **Constructive Contribution**
   - Share different perspectives thoughtfully
   - Seek to understand before responding
   - Focus on finding the best solution

3. **Evidence-Based**
   - Support suggestions with reasoning
   - Reference documentation when possible
   - Distinguish opinion from fact

4. **User-Centric**
   - Keep user's constraints in mind
   - Prioritize practical solutions
   - Consider user's skill level

## Example Collaboration Session

**User Request:**
"codex와 토론해서 이 성능 문제 해결법 찾아줘. 데이터베이스 쿼리가 너무 느려."

**Collaboration Flow:**

```
=== Phase 1: Problem Definition ===
Claude analyzes code and frames the problem:
"I've identified N+1 query pattern in your Django API.
100+ queries per request, causing 3s response time.

Let me analyze this and propose a solution..."

=== Phase 2: Claude's Opening Analysis (OUTPUT TO USER) ===
Claude: "=== Round 1: My Analysis ===

My understanding: The core issue is N+1 queries where we're fetching
related objects in a loop instead of eager loading.

My proposed approach:
Use Django's select_related() for ForeignKey relationships and
prefetch_related() for ManyToMany relationships. This should
reduce 100+ queries to 2-3 optimized queries.

Why I think this approach works:
- Should dramatically reduce query count (100+ → ~3)
- No infrastructure changes needed
- Django ORM handles optimization automatically
- Well-established pattern for N+1 problems

Implementation:
queryset = Model.objects.select_related('user', 'category')
                        .prefetch_related('tags')

Let me get Codex's perspective to see if there are other considerations...
[Calls Codex via Bash]"

=== Phase 3: Codex Response ===
Codex (via codex exec): "Good thinking on eager loading! That will definitely help.
I'd like to add another important consideration:

My analysis: I noticed in your schema that several foreign keys and
filter fields don't have indexes:
- Foreign keys WITHOUT indexes
- Filter fields (created_at, status) WITHOUT indexes

My suggested approach:
1. Add database indexes first (can give immediate 10-20x speedup)
2. Enable Django's query logging to measure impact
3. Then apply eager loading as you suggested
4. Consider query result caching (Django cache framework)

Why I suggest indexes first:
- Quick win with no code changes
- Benefits all existing queries immediately
- Complements your eager loading approach
- Without indexes, even optimized queries can be slow

Your eager loading approach is solid - I'm just suggesting we add
indexes as a first step to maximize the improvement."

=== Phase 4: Claude's Response (OUTPUT TO USER) ===
Claude: "=== Round 1: After Hearing Codex ===

Codex's key insights:
- Foreign keys are missing indexes
- Indexes should be added first for quick wins
- Query logging to measure improvements
- Approach should combine indexes + eager loading

Thoughts on Codex's perspective:
This is a really good catch! I should have checked the schema for
indexes first. Let me verify... [checks schema]

You're right - several foreign keys don't have indexes. That's
definitely limiting performance even before we consider the N+1 issue.

Integrated solution:
Let's combine both approaches in the right order:
1. Add indexes on foreign keys (Codex's insight - quick win)
2. Implement eager loading (my original suggestion - fixes N+1)
3. Add query logging to validate improvements
4. Consider caching for frequently accessed data

This gives us the best of both: indexes speed up individual queries,
and eager loading eliminates redundant queries. Together they should
give us much better results than either alone.

Let me continue the discussion to refine the implementation...
[Calls Codex for Round 2]"

=== Phase 5: Round 2 - Claude's Further Thoughts (OUTPUT TO USER) ===
Claude: "=== Round 2: Further Thoughts ===

Based on our discussion so far:
- Indexes + eager loading is the core approach
- Both complement each other well

My current thinking:
Let's implement in this order:
1. Indexes (immediate win, no code changes)
2. Eager loading (eliminates N+1 pattern)
3. Django's built-in query cache (before considering Redis)

I'm wondering about the caching layer - do you think Django's
cache framework is sufficient initially, or should we plan
for Redis from the start?

[Calls Codex for Round 2]"

=== Phase 5: Round 2 - Codex Response ===
Codex (via codex exec): "I think your approach is solid!

On the caching question:
I'd definitely start with Django's cache framework:
- No new infrastructure to set up
- Simpler cache invalidation
- Good enough for most cases
- Easy to upgrade to Redis later if needed

Only move to Redis if:
- Django cache can't handle the load
- You need cross-server cache sharing
- You need advanced features (pub/sub, etc.)

So the complete approach looks good:
1. Add indexes (immediate 10-20x improvement)
2. Apply eager loading (eliminate N+1)
3. Django query cache (simple and effective)
4. Monitor performance metrics
5. Consider Redis later only if needed

This gives you a clear path forward with minimal risk."

=== Phase 5: Round 2 - Claude's Synthesis (OUTPUT TO USER) ===
Claude: "=== Round 2: After Codex Input ===

Great - we're aligned on the full approach!

Final integrated solution:
1. ✅ Add database indexes on all foreign keys
2. ✅ Implement select_related() and prefetch_related()
3. ✅ Use Django's cache framework (not Redis yet)
4. ✅ Monitor with query logging
5. ✅ Upgrade to Redis only if Django cache proves insufficient

Why this solution works:
- Indexes: Immediate performance boost (Codex's key insight)
- Eager loading: Eliminates redundant queries (my initial suggestion)
- Django cache: Simple, effective, no infrastructure overhead (both agreed)
- Monitoring: Validates improvements and guides next steps (both agreed)

Discussion complete. Generating implementation plan...

Report saved: .debate-reports/2025-01-27-15-30-db-query-optimization.md"

=== Phase 6: Solution Summary ===
Claude and Codex converged on a comprehensive solution:
1. Add database indexes (immediate impact - Codex's contribution)
2. Implement eager loading (eliminates N+1 - Claude's contribution)
3. Start with Django query cache (both agreed on simplicity-first)
4. Monitor and iterate based on real metrics

Estimated improvement: 3s → <300ms response time
```

## Advanced Usage

### Focused Discussions

For specific aspects, direct the discussion:

```
"codex랑 security 관점에서만 토론해줘"
"focus discussion on performance only"
"discuss different architectures, not implementation details"
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

Each discussion session produces:

1. **Console Summary** (Real-time)
   - Round-by-round highlights
   - Key convergences and complementary insights
   - Emerging solution

2. **Discussion Report** (`.debate-reports/` - legacy folder name)
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

2. **Let Discussion Develop**
   - Allow multiple rounds
   - Let insights emerge naturally
   - Value different perspectives

3. **Guide, Don't Dictate**
   - Frame good questions
   - Let AIs explore freely
   - Intervene only if stuck

4. **Save Discussion Reports**
   - Keep `.debate-reports/` in git
   - Learn from past collaborations
   - Share with team

5. **Thoughtfully Evaluate**
   - Both AIs can be wrong
   - Use your judgment
   - Test solutions thoroughly

### Don'ts ❌

1. **Don't Skip Context**
   - Vague problems → vague solutions
   - Missing constraints → impractical advice

2. **Don't Expect Identical Views**
   - Some problems have multiple valid approaches
   - Tradeoffs are real
   - Different perspectives add value

3. **Don't Automate Blindly**
   - Review all suggestions
   - Understand the reasoning
   - Validate against requirements

4. **Don't Overuse**
   - Simple problems don't need multi-AI collaboration
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

### "Discussion isn't making progress"

After 5 rounds without clear solution:
- Identify what's still unclear
- Research any disputed technical points
- Get human expert opinion
- Let user decide based on tradeoffs presented

### "Responses are too generic"

Provide more specific context:
- Share actual code, not descriptions
- Include exact error messages
- Specify concrete constraints
- Ask targeted questions

### "Responses are too similar"

If both AIs are converging too quickly, prompt for deeper exploration:
```bash
codex exec "...

Please provide a thorough analysis from your perspective.
Consider potential issues, edge cases, and alternative approaches
that might not be immediately obvious."
```

## Comparison to Other Approaches

| Approach | Pros | Cons |
|----------|------|------|
| **Claude Only** | Fast, integrated | Single perspective |
| **Codex Only** | Autonomous, can execute | Limited by one model |
| **Claude-Codex Collaboration** | Multi-perspective, complementary insights | Slower, requires both subscriptions |
| **Human Team Discussion** | Real experience, domain knowledge | Time-intensive, scheduling challenges |

**Best for:** Complex, high-stakes decisions where multiple perspectives add value.

## Resources

### Scripts

- None required (uses Codex CLI directly via bash)

### References

- `references/debate-protocol.md` - Detailed guidelines for effective AI collaboration

### Assets

- `assets/debate-report-template.md` - Markdown template for generating final discussion reports (legacy filename)

## Limitations

This skill cannot:
- Replace human judgment and domain expertise
- Execute code or run tests (use separately)
- Access external APIs or databases
- Guarantee "correct" answer (provides perspectives)
- Work without Codex CLI installed
- Work offline (requires OpenAI API access)

**Remember:** AI collaboration is a tool for exploration and validation, not a replacement for human decision-making.

---

**Version:** 1.0
**Last Updated:** 2025-01-27
**Models:** Claude 3.5 Sonnet (Anthropic) + GPT-4/o3 via Codex CLI (OpenAI)
