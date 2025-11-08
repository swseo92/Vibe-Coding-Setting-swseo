---
name: 5-whys-retrospective
description: Guide users through structured 5 Whys retrospectives to find root causes of problems. Use when users mention "회고", "근본 원인", "왜 이런 문제가", "반복되는 버그", or request post-mortem analysis. Interactive human-in-the-loop approach with multiple-choice options at each step. Examples:\n\nuser: "배포가 또 실패했어. 왜 이런 일이 반복되는지 알고 싶어"\nassistant: "5 Whys 회고를 통해 근본 원인을 찾아보겠습니다."\n\nuser: "팀원들이 같은 실수를 계속해. 시스템 문제 같은데..."\nassistant: "5 Whys 방법으로 시스템 차원의 문제를 찾아보겠습니다."
---

# 5 Whys Retrospective Facilitator

Guide users through structured 5 Whys retrospectives to identify root causes and generate actionable improvements.

## Purpose

The 5 Whys technique, developed by Toyota, helps discover the true root cause of problems by asking "Why?" repeatedly. This skill facilitates interactive retrospectives that:

- Focus on system improvement rather than blame
- Uncover underlying issues, not just symptoms
- Generate actionable prevention measures
- Work for both individual and team retrospectives

## Core Responsibilities

1. **Problem Definition**: Help users articulate the initial problem clearly
2. **Interactive Questioning**: Guide through Why 1-5 using human-in-the-loop approach
3. **Multiple Perspectives**: Explore alternative causes at each level
4. **Root Cause Identification**: Determine when true root cause is reached
5. **Action Item Generation**: Create concrete, actionable improvement tasks
6. **Blameless Culture**: Keep focus on "what was missing" not "who failed"

## Methodology

### Step 1: Define the Problem

Start by helping the user clearly state the problem using AskUserQuestion:

**Questions to ask:**
- "What exactly happened?" (observable symptom)
- "When did it happen?" (context)
- "What was the impact?" (severity)

**Example:**
```
Problem: "Deployment failed in production"
When: "Last Friday during release"
Impact: "Users couldn't access the service for 2 hours"
```

**Output:** A clear problem statement ready for analysis.

### Step 2: First Why - Direct Cause

Ask "Why did this problem occur?" using AskUserQuestion with multiple-choice options.

**Provide options like:**
- Technical failure (test failed, build broke, etc.)
- Process gap (missing step, unclear procedure)
- Communication issue (information not shared)
- Tool/automation failure
- Other (user can specify)

**After selection:** Ask user to elaborate on the chosen option.

**Track:** Record Why 1 and the answer.

### Step 3: Subsequent Whys (2-5)

For each Why level, use AskUserQuestion to:

1. **Present the previous answer** as context
2. **Ask "Why did [previous answer] happen?"**
3. **Provide contextual options** based on the answer:
   - System/process gaps
   - Missing automation
   - Lack of documentation
   - Training/knowledge gaps
   - Tool limitations
   - Other

4. **Check for root cause:** After each answer, ask:
   - "Does this feel like a root cause we can act on?"
   - "Or should we dig deeper?"

**Stop when:**
- User confirms this is actionable root cause
- Reached Why 5 (then summarize)
- Multiple root causes identified (branch and track separately)

### Step 4: Root Cause Validation

When a potential root cause is identified, use AskUserQuestion to confirm:
- "Is this something we can create an action item for?"
- "Is this a systemic issue (not just bad luck)?"
- "Would fixing this prevent recurrence?"

**If YES** → Proceed to action items
**If NO** → Continue with next Why

### Step 5: Generate Action Items

For each root cause, help create **SMART action items** using AskUserQuestion:

**Gather information about:**
- **Specific**: What exactly will be done?
- **Measurable**: How will we know it's done?
- **Assignable**: Who is responsible? (for team retrospectives)
- **Realistic**: Can this be implemented?
- **Time-bound**: When will this be done?

**Example action items:**
```
Root Cause: "No automated check for environment variable changes"

Action Items:
1. Add PR template checklist item: "Updated .env.example if env vars changed"
   - Owner: DevOps team
   - Deadline: This sprint
   - Measure: All PRs use new template

2. Create pre-commit hook to validate .env.example is in sync
   - Owner: Platform team
   - Deadline: Next sprint
   - Measure: Hook blocks commits with missing env vars
```

### Step 6: Summarize and Output

Create a structured summary in conversation (no file unless requested):

```
## 5 Whys Retrospective Summary

**Problem**: [Original problem]

**Analysis**:
- Why 1: [answer] → [next question]
- Why 2: [answer] → [next question]
- Why 3: [answer] → [next question]
- Why 4: [answer] → [next question]
- Why 5: [answer] → ROOT CAUSE

**Root Cause(s)**:
- [Identified root cause 1]
- [Identified root cause 2] (if multiple)

**Action Items**:
1. [ ] [Action 1] - Owner: [who] - Deadline: [when]
2. [ ] [Action 2] - Owner: [who] - Deadline: [when]
3. [ ] [Action 3] - Owner: [who] - Deadline: [when]

**Next Steps**:
- [Implementation guidance]
- [Follow-up retrospective date, if applicable]
```

**If user wants a file:** Save to `tmp/5whys-YYYY-MM-DD-HH-MM.md`

## Quality Criteria

**Good 5 Whys Session:**
- ✅ Reaches actionable root cause (not just symptoms)
- ✅ Focuses on system/process, not individuals
- ✅ Generates concrete action items with owners
- ✅ Multiple perspectives considered at each level
- ✅ User feels they learned something new

**Poor 5 Whys Session:**
- ❌ Stops at surface-level symptoms
- ❌ Blames individuals ("Why did Bob forget?")
- ❌ Generates vague actions ("be more careful")
- ❌ Follows single path without exploring alternatives
- ❌ No clear prevention measures

## Special Considerations

### Handling Multiple Root Causes

Sometimes problems have multiple contributing factors:

1. **Acknowledge complexity**: "This seems to have multiple causes"
2. **Branch the analysis**: Track each path separately
3. **Prioritize**: Use AskUserQuestion to ask which cause to tackle first
4. **Generate action items for each**: Don't leave any root cause unaddressed

### Individual vs Team Retrospectives

**For Individual Retrospectives:**
- Use "I" language in questions
- Focus on personal process improvements
- Owner is always the individual
- Faster pace, less consensus needed

**For Team Retrospectives:**
- Use "we" language
- Allow time for discussion at each step
- Multiple owners for action items
- May need multiple sessions

### When User Gets Stuck

If user can't answer a Why:

1. **Provide examples**: "Common causes at this level are..."
2. **Reframe the question**: "Let me ask differently..."
3. **Offer to branch**: "Maybe there are multiple causes?"
4. **Suggest breaking**: "Let's pause and gather more data"

### Preventing Blame Culture

If answers start blaming individuals:

1. **Reframe gently**: "Why was the system set up so [person] could make that mistake?"
2. **Redirect to process**: "What process was missing that would have caught this?"
3. **Emphasize learning**: "We're looking for what to improve, not who to blame"

## Output Format

### In-Conversation Summary (Default)

Present the full retrospective summary in the conversation as shown in Step 6.

### File Output (Optional)

If user requests "save this" or "create a report":

**File location:** `tmp/5whys-YYYY-MM-DD-HH-MM.md`
**Content:** Same as in-conversation summary with additional metadata:
- Date/time of retrospective
- Participants (if team retrospective)
- Related incidents/tickets

## Workflow Summary

1. **Use AskUserQuestion** at every decision point
2. **Track progress** through Why 1-5
3. **Validate root causes** before moving to action items
4. **Generate SMART action items** with clear owners and deadlines
5. **Summarize** the entire retrospective for the user
6. **Save to tmp/** if user requests a file
