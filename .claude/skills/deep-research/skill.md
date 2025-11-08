---
name: deep-research
description: Conduct comprehensive research with clarification phase, parallel task execution, and Codex integration. Use when users request "딥리서치", "deep research", "조사해줘", or thorough analysis of technical topics requiring multiple sources.
---

# Deep Research Skill

Comprehensive research assistant with pre-clarification, parallel task execution, and AI-powered quality validation.

## When to Use

Trigger when users request:
- "딥리서치" / "deep research"
- "조사해줘" / "research this"
- "분석해줘" / "analyze thoroughly"
- Technical comparisons requiring multiple sources
- Market research or technology evaluation
- Documentation gathering from multiple sources

## Phase 1: Clarification

Always start with clarification to define research scope and objectives.

### Step 1: Analyze Request Ambiguity

Examine the user's request and identify:
- **Missing Information**: Topic scope, depth, output format
- **Ambiguity Level**:
  - High (0-40%): 4-5 questions needed
  - Medium (40-70%): 3 questions needed
  - Low (70-100%): 1-2 questions needed

### Step 2: Ask Clarifying Questions

Use AskUserQuestion tool with 3-5 targeted questions:

**Question Categories:**

1. **Research Scope**:
   - Specific aspect or comprehensive overview?
   - Time period (latest info or historical analysis)?
   - Geographic/market focus?

2. **Depth & Detail**:
   - Surface-level summary or deep technical analysis?
   - Target audience (technical/non-technical)?
   - Level of evidence required (citations, benchmarks, case studies)?

3. **Output Requirements**:
   - Preferred format (Markdown report, JSON data, conversational summary)?
   - Length (concise brief or comprehensive document)?
   - Sections needed (pros/cons, alternatives, implementation guide)?

4. **Sources & Methods**:
   - Preferred sources (web search, official docs, academic papers)?
   - Include code examples or diagrams?
   - Compare alternatives (vs approach)?

5. **Success Criteria**:
   - What decision will this research inform?
   - What makes this research "complete"?

**Example Implementation:**

```javascript
AskUserQuestion({
  "questions": [
    {
      "question": "How deep should the research go?",
      "header": "Research Depth",
      "multiSelect": false,
      "options": [
        {"label": "Quick overview", "description": "High-level summary, 5-10 sources"},
        {"label": "Standard analysis", "description": "Balanced coverage, 15-20 sources"},
        {"label": "Comprehensive", "description": "Deep dive, 30+ sources, benchmarks"}
      ]
    },
    {
      "question": "What sources should be prioritized?",
      "header": "Source Priority",
      "multiSelect": true,
      "options": [
        {"label": "Official docs", "description": "Documentation, API references"},
        {"label": "Web articles", "description": "Blog posts, tutorials, guides"},
        {"label": "Academic papers", "description": "Research papers, whitepapers"},
        {"label": "Community", "description": "Forums, GitHub issues, discussions"}
      ]
    },
    {
      "question": "Should alternatives be compared?",
      "header": "Comparison",
      "multiSelect": false,
      "options": [
        {"label": "Yes, compare alternatives", "description": "Side-by-side analysis"},
        {"label": "Focus on main topic only", "description": "No comparison needed"}
      ]
    }
  ]
})
```

### Step 3: Confirm Understanding

After receiving answers, summarize:

```
Research Plan Confirmed:
- Topic: [Clarified topic]
- Scope: [Specific/Comprehensive]
- Depth: [Level]
- Sources: [Primary sources]
- Output: Markdown report with [sections]
- Comparison: [Yes/No alternatives]

Proceed with research?
```

Wait for user confirmation before continuing.

## Phase 2: Parallel Research Execution

Execute research tasks in parallel using Task tool with general-purpose agents.

### Step 1: Generate Research Task Plan

Based on Phase 1 clarification, identify independent research tasks:

**Task Categories:**

1. **Web Search Tasks** (WebSearch tool):
   - Latest trends and news
   - Community discussions and best practices
   - Real-world use cases and examples

2. **Documentation Tasks** (WebFetch tool):
   - Official documentation
   - API references
   - Technical specifications

3. **Comparative Analysis** (if requested):
   - Alternative solutions research
   - Feature comparison
   - Performance benchmarks

4. **Code Examples** (if applicable):
   - GitHub repository analysis
   - Implementation patterns
   - Sample code gathering

**Example Task List:**

```
Independent Tasks (can run in parallel):
1. Web Search: Latest trends and 2024-2025 developments
2. Documentation: Official docs and API reference
3. Community: Forums, GitHub issues, Stack Overflow discussions
4. Alternatives: Competing solutions and comparisons
5. Benchmarks: Performance data and case studies
```

### Step 2: Create TodoWrite Task List

```javascript
TodoWrite({
  "todos": [
    {"content": "Web search for latest trends", "status": "pending", "activeForm": "Searching web for trends"},
    {"content": "Fetch official documentation", "status": "pending", "activeForm": "Fetching official docs"},
    {"content": "Analyze community discussions", "status": "pending", "activeForm": "Analyzing community"},
    {"content": "Research alternatives and comparisons", "status": "pending", "activeForm": "Researching alternatives"},
    {"content": "Collect benchmarks and performance data", "status": "pending", "activeForm": "Collecting benchmarks"}
  ]
})
```

### Step 3: Execute Parallel Tasks

Launch multiple Task agents in parallel (single message, multiple Task calls):

```
Launching 4 parallel research agents:
- Agent 1: Web trends search
- Agent 2: Documentation analysis
- Agent 3: Community research
- Agent 4: Alternatives comparison
```

**Task Agent Prompts:**

```
Task 1 (Web Search):
"Research latest trends and developments for [topic] in 2024-2025.
Use WebSearch tool to find:
- Recent articles and blog posts
- Industry news and updates
- Best practices and recommendations
Summarize findings with source URLs."

Task 2 (Documentation):
"Analyze official documentation for [topic].
Use WebFetch tool to gather:
- Getting started guides
- API reference
- Configuration options
- Common patterns
Summarize key information with URLs."

Task 3 (Community):
"Research community discussions about [topic].
Use WebSearch to find:
- Stack Overflow questions and solutions
- GitHub issues and discussions
- Reddit/forum threads
- Common pain points and solutions
Summarize insights with URLs."

Task 4 (Alternatives):
"Compare [topic] with alternatives [A, B, C].
Research:
- Feature comparison
- Performance differences
- Use case recommendations
- Migration considerations
Summarize with source URLs."
```

### Step 4: Mark Tasks as Completed

As each parallel agent returns results, mark corresponding todo as completed:

```javascript
TodoWrite({
  "todos": [
    {"content": "Web search for latest trends", "status": "completed", ...},
    {"content": "Fetch official documentation", "status": "in_progress", ...},
    ...
  ]
})
```

## Phase 3: Codex Quality Validation

Use Codex for quality assurance and insight enhancement.

### Step 1: Aggregate Raw Research Results

Combine all parallel task results into structured data:

```
Raw Research Data:
- Web Search Results: [Summary with URLs]
- Documentation Findings: [Summary with URLs]
- Community Insights: [Summary with URLs]
- Alternative Comparisons: [Summary with URLs]
- Benchmarks: [Summary with URLs]
```

### Step 2: Codex Quality Validation

Execute Codex with quality validation prompt:

```bash
SCRIPTS_DIR="$HOME/.claude/skills/ai-collaborative-solver/scripts"

CODEX_VALIDATION_PROMPT="You are a research quality validator and insight enhancer.

## Task
Analyze the following raw research data and provide:

1. Quality Assessment (0-100 score):
   - Completeness: Are key aspects covered?
   - Accuracy: Any contradictions or outdated info?
   - Source credibility: How reliable are sources?
   - Depth: Is analysis sufficient or superficial?

2. Missing Gaps:
   - What critical information is missing?
   - Which aspects need deeper investigation?
   - Are there overlooked perspectives?

3. Alternative Viewpoints:
   - What opposing arguments exist?
   - Are there alternative approaches not mentioned?
   - What are the trade-offs?

4. Enhanced Insights:
   - What patterns emerge from the data?
   - What non-obvious conclusions can be drawn?
   - What are the practical implications?

## Raw Research Data
[Paste aggregated research results here]

## Output Format
Provide structured analysis:
- Overall Quality Score: X/100
- Completeness: [Assessment]
- Accuracy Issues: [List if any]
- Missing Gaps: [List]
- Alternative Viewpoints: [List]
- Enhanced Insights: [List]
- Recommendations: [Next steps if gaps found]
"

CODEX_VALIDATION=$(bash "$SCRIPTS_DIR/codex-session.sh" new "$CODEX_VALIDATION_PROMPT" --stdout-only --quiet 2>&1)
```

### Step 3: Codex Comparative Analysis (if alternatives exist)

If researching alternatives, use Codex for deeper comparison:

```bash
CODEX_COMPARISON_PROMPT="You are an expert technical analyst comparing alternatives.

## Context
Research topic: [Topic]
Alternatives: [A, B, C]

## Raw Comparison Data
[Paste alternative comparison data]

## Task
Provide in-depth comparative analysis:

1. Decision Framework:
   - When to choose A vs B vs C?
   - Key decision factors (ranked)
   - Use case mapping

2. Trade-off Analysis:
   - Performance vs Ease of use
   - Features vs Stability
   - Ecosystem vs Innovation
   - Cost implications

3. Real-world Recommendations:
   - For startups: [Recommendation with reasoning]
   - For enterprises: [Recommendation with reasoning]
   - For specific constraints: [List scenarios]

4. Migration Considerations:
   - Switching costs between alternatives
   - Learning curve comparison
   - Long-term sustainability

## Output Format
Structured comparison with specific recommendations.
"

CODEX_COMPARISON=$(bash "$SCRIPTS_DIR/codex-session.sh" new "$CODEX_COMPARISON_PROMPT" --stdout-only --quiet 2>&1)
```

### Step 4: Review Codex Feedback

Analyze Codex output:
- Quality score < 70: Consider additional research
- Missing gaps identified: Launch targeted follow-up tasks
- Enhanced insights: Integrate into final report

## Phase 4: Final Report Generation

Synthesize all research into comprehensive Markdown report.

### Report Structure

```markdown
# [Research Topic] - Deep Research Report

**Research Date:** [Date]
**Scope:** [Defined in Phase 1]
**Sources:** [N web, M docs, K community]

---

## Executive Summary

[3-5 paragraph high-level overview]
- Key findings
- Main conclusions
- Critical recommendations

---

## Research Methodology

**Clarification Phase:**
- Research depth: [Level]
- Primary sources: [List]
- Comparison scope: [Yes/No]

**Execution Phase:**
- Parallel research tasks: [N tasks]
- Total sources analyzed: [N]
- Quality validation: Codex AI review

---

## Findings

### 1. [Topic Overview]

[Comprehensive explanation based on documentation research]

**Key Points:**
- [Point 1]
- [Point 2]
- [Point 3]

**Sources:**
- [Title 1](URL1)
- [Title 2](URL2)

### 2. [Latest Trends & Developments]

[Based on web search results]

**2024-2025 Trends:**
- [Trend 1]: [Description]
- [Trend 2]: [Description]

**Sources:**
- [Article 1](URL)
- [Article 2](URL)

### 3. [Community Insights]

[Based on forums, GitHub, Stack Overflow]

**Common Use Cases:**
- [Use case 1]: [Description]
- [Use case 2]: [Description]

**Known Issues & Solutions:**
- [Issue 1]: [Solution]
- [Issue 2]: [Solution]

**Sources:**
- [Discussion 1](URL)
- [GitHub issue](URL)

### 4. [Comparative Analysis] (if applicable)

[Based on alternatives research + Codex comparison]

**Feature Comparison:**

| Feature | [Topic] | Alternative A | Alternative B |
|---------|---------|---------------|---------------|
| [Feature 1] | [Value] | [Value] | [Value] |
| [Feature 2] | [Value] | [Value] | [Value] |

**When to Choose What:**
- **[Topic]**: [Scenario and reasoning]
- **Alternative A**: [Scenario and reasoning]
- **Alternative B**: [Scenario and reasoning]

**Sources:**
- [Comparison article](URL)
- [Benchmark](URL)

### 5. [Performance & Benchmarks] (if applicable)

[Based on benchmark research]

**Performance Metrics:**
- [Metric 1]: [Value] (Source: [URL])
- [Metric 2]: [Value] (Source: [URL])

**Real-world Case Studies:**
- [Company/Project 1]: [Results] (Source: [URL])
- [Company/Project 2]: [Results] (Source: [URL])

---

## Codex AI Insights

**Quality Assessment:**
- Overall Score: [X/100]
- Completeness: [Assessment]
- Accuracy: [Assessment]

**Enhanced Insights:**
- [Insight 1]: [Explanation]
- [Insight 2]: [Explanation]

**Alternative Perspectives:**
- [Viewpoint 1]: [Explanation]
- [Viewpoint 2]: [Explanation]

---

## Conclusions

### Key Takeaways
1. [Takeaway 1]
2. [Takeaway 2]
3. [Takeaway 3]

### Recommendations
1. [Recommendation 1]: [Reasoning]
2. [Recommendation 2]: [Reasoning]
3. [Recommendation 3]: [Reasoning]

### Next Steps (if gaps identified)
- [ ] [Follow-up task 1]
- [ ] [Follow-up task 2]

---

## Source Summary

**Total Sources:** [N]

**By Category:**
- Official Documentation: [N sources]
- Web Articles: [N sources]
- Community Discussions: [N sources]
- Benchmarks/Case Studies: [N sources]

**All Sources:**
1. [Title](URL) - [Category]
2. [Title](URL) - [Category]
...
[Complete list]

---

**Research Confidence:** [High/Medium/Low]
**Quality Score (Codex):** [X/100]
**Completeness:** [Complete / Needs follow-up on: [topics]]
```

### Report Generation Process

1. **Aggregate all research results** from parallel tasks
2. **Integrate Codex insights** into relevant sections
3. **Format with proper Markdown structure** (headings, tables, lists)
4. **Include all source URLs** with descriptive titles
5. **Highlight key findings** with bold/emphasis
6. **Add executive summary** at top for quick scanning

## Best Practices

### Clarification Phase
- Ask 3-5 questions maximum (not overwhelming)
- Use specific options, not open-ended questions
- Confirm understanding before proceeding
- Wait for user approval

### Parallel Execution
- Launch all independent tasks in single message
- Use TodoWrite for progress tracking
- Clearly separate task agents by focus area
- Mark tasks completed as results arrive

### Codex Integration
- Always validate research quality with Codex
- Use Codex for comparative analysis (alternatives)
- Integrate Codex insights into final report
- Include Codex quality score in report

### Report Quality
- Include all source URLs with descriptions
- Structure with clear headings and sections
- Use tables for comparisons
- Provide executive summary for quick overview
- Add quality score and completeness assessment

## Performance Expectations

- **Phase 1 (Clarification)**: 10-20s
- **Phase 2 (Parallel Research)**: 40-80s (depending on task count)
- **Phase 3 (Codex Validation)**: 15-25s
- **Phase 4 (Report Generation)**: 10-20s

**Total Time:** 75-145s (1.5-2.5 minutes)

## Bundled Resources

### References
- `references/research-templates.md` - Reusable research patterns for different scenarios

### Scripts
- Uses `~/.claude/skills/ai-collaborative-solver/scripts/codex-session.sh` for Codex integration

---

**Version:** 1.0.0
**Created:** 2025-11-09
**Features:**
- Phase 1: Pre-clarification with AskUserQuestion
- Phase 2: Parallel task execution (automatic)
- Phase 3: Codex quality validation and insights
- Phase 4: Comprehensive Markdown report with sources
**Performance:** 75-145s (comprehensive research)
