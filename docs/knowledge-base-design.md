# Centralized Knowledge Base Design

**Status**: Design Document
**Last Updated**: 2025-01-28
**Reviewers**: Claude (Anthropic) + Codex (OpenAI)

## Executive Summary

This document outlines the design for a centralized knowledge base system for Claude Code agents and skills. The system provides consistent coding guidelines, domain knowledge, and architectural decisions that all agents/skills can reference, ensuring code quality and knowledge sharing across the project.

## Problem Statement

**Current Situation:**
- Multiple agents and skills perform coding tasks (langgraph-node-implementer, pytest-test-writer, etc.)
- No systematic mechanism for sharing coding guidelines
- Knowledge duplication across agent/skill `references/` folders
- Inconsistent coding patterns
- No central source of truth for domain knowledge

**Desired Outcome:**
- Centralized, version-controlled knowledge base
- Agents/skills reference shared guidelines via explicit paths
- DRY principle for knowledge management
- Git-tracked evolution of guidelines and decisions

## Proposed Solution

### Directory Structure

```
docs/
├── coding-guidelines/          # Coding standards and patterns
│   ├── shared/                 # Language-agnostic principles
│   │   ├── principles.md       # SOLID, DRY, security
│   │   ├── testing.md          # General testing philosophy
│   │   └── tooling.md          # Common tools and practices
│   ├── python/
│   │   ├── general.md          # Python style guide
│   │   ├── langgraph-nodes.md  # LangGraph patterns
│   │   ├── pytest.md           # pytest best practices
│   │   └── pydantic.md         # Pydantic model patterns
│   └── typescript/
│       ├── general.md
│       └── testing.md
│
├── architecture/               # Architecture Decision Records (ADR)
│   ├── decisions/
│   │   ├── 001-use-langgraph.md
│   │   └── 002-pydantic-state.md
│   └── diagrams/
│
├── domain-knowledge/           # Business/project domain knowledge
│   ├── workflows.md
│   ├── business-rules.md
│   └── glossary.md
│
├── apis/                       # API documentation
│   ├── internal-apis.md
│   └── third-party-apis.md
│
├── index.yaml                  # Role-to-guideline mapping
└── scripts/                    # Helper scripts (future)
    └── load-guidelines.sh
```

### Knowledge Base Categories

**1. Coding Guidelines** (`coding-guidelines/`)
- Language-specific patterns and anti-patterns
- Framework-specific best practices (LangGraph, pytest, etc.)
- Shared principles (SOLID, security, etc.)

**2. Architecture** (`architecture/`)
- Architecture Decision Records (ADR)
- System diagrams
- Technology choices and rationale

**3. Domain Knowledge** (`domain-knowledge/`)
- Business rules and workflows
- Domain terminology (glossary)
- User workflows and use cases

**4. APIs** (`apis/`)
- Internal API documentation
- Third-party API integration guides

## Reference Mechanism

### Option 1: Manual References (Minimal Viable - Recommended)

Agents/skills explicitly list required documents in their system prompts:

```markdown
# .claude/agents/langgraph-node-implementer.md

## Knowledge Base
Before implementing nodes, read these documents:
- `docs/coding-guidelines/shared/principles.md`
- `docs/coding-guidelines/python/langgraph-nodes.md`
- `docs/coding-guidelines/python/pytest.md`

Use the Read tool to check these files before starting implementation.

## Instructions
[Rest of agent instructions...]
```

**Pros:**
- Simple, no infrastructure needed
- Works immediately
- Easy to understand and debug

**Cons:**
- Manual maintenance per agent
- No automatic updates

### Option 2: Index-Based (Full Featured - Future)

Central `index.yaml` maps agent roles to required documents:

```yaml
# docs/index.yaml

roles:
  langgraph-node-implementer:
    required:
      - coding-guidelines/shared/principles.md
      - coding-guidelines/python/langgraph-nodes.md
      - coding-guidelines/python/pytest.md
    optional:
      - architecture/decisions/001-use-langgraph.md

  system-designer:
    required:
      - architecture/decisions/
      - domain-knowledge/workflows.md
    optional:
      - coding-guidelines/shared/principles.md
```

Agent markdown references role:

```markdown
# .claude/agents/langgraph-node-implementer.md

Role: langgraph-node-implementer

## Knowledge Base
This agent follows guidelines defined in `docs/index.yaml` for role: `langgraph-node-implementer`.

## Instructions
[Agent instructions...]
```

**Pros:**
- Central management
- Easy to update mappings
- Scalable

**Cons:**
- Requires index.yaml maintenance
- More complex initially

## Guideline Document Format

### YAML Front Matter (Optional - Full Featured)

Each guideline can include metadata:

```markdown
---
title: Pytest Guidelines
version: 1.1.0
summary: >
  Prefer explicit fixtures, keep test modules stateless, and centralize
  reusable helpers under shared/testutils.py to minimize duplication.
last_reviewed: 2025-01-28
required_for:
  - langgraph-node-implementer
  - pytest-test-writer
---

# Pytest Guidelines

[Full content...]
```

### Summary Field

**Purpose**: Provide 200-300 token summary for quick reference without reading full document.

**Usage**: Agents can read summary first, then decide if full document is needed.

## Implementation Phases

### Phase 0: Preparation (Week 0)

**Tasks:**
- Decide on directory structure
- Identify existing documents to migrate
- Create initial folder structure

**Deliverables:**
- Empty folder structure in `docs/`
- Migration plan for existing docs

### Phase 1: Minimal Viable (Weeks 1-2)

**Tasks:**
- Create initial `docs/coding-guidelines/` structure
- Move existing `docs/python/testing_guidelines.md` → `docs/coding-guidelines/python/pytest.md`
- Create `docs/coding-guidelines/shared/principles.md` (basic SOLID principles)
- Update 2-3 agents to reference new paths

**Implementation:**

```markdown
# .claude/agents/langgraph-node-implementer.md

## Knowledge Base
Before coding, read:
- docs/coding-guidelines/shared/principles.md
- docs/coding-guidelines/python/langgraph-nodes.md
- docs/coding-guidelines/python/pytest.md

## Instructions
[Rest of instructions...]
```

**Success Criteria:**
- At least 3 agents use centralized guidelines
- No duplicated guideline content
- Guidelines are readable and actionable

### Phase 2: Expansion (Weeks 3-4)

**Tasks:**
- Add domain knowledge documents
- Add architecture decisions (ADR)
- Create summaries for existing guidelines
- Update all agents/skills to use knowledge base

**Deliverables:**
- `docs/domain-knowledge/` populated
- `docs/architecture/decisions/` with ADRs
- All agents reference docs

### Phase 3: Automation (Weeks 5-6+) - Optional

**Tasks:**
- Create `docs/index.yaml` with role mappings
- Add YAML front matter to guidelines
- Create `docs/scripts/load-guidelines.sh` helper script
- Add summary fields to all documents

**Deliverables:**
- `index.yaml` with all role mappings
- Helper script for loading guidelines
- YAML front matter in all docs

## Guidelines Update Workflow

### Small Teams (1-3 developers)

**Process:**
1. Edit guideline file directly
2. Self-review or buddy review
3. Commit with descriptive message
4. Optional: Git tag for major changes

**No Formal RFC Required**

### Larger Teams (4+ developers)

**Process:**
1. Create PR with guideline changes
2. Assign reviewer(s)
3. Discuss in PR comments
4. Update `last_reviewed` date
5. Merge after approval

## Conflict Resolution

**Priority Order** (later overrides earlier):

1. `shared/principles.md` (foundational)
2. `shared/*.md` (general shared knowledge)
3. `{language}/general.md` (language defaults)
4. `{language}/{specific}.md` (specific patterns)
5. Project-specific overrides (if any)

**Explicit Override Rule:**

If a guideline contradicts a higher-priority document, it MUST include an `overrides` note:

```markdown
---
title: LangGraph Pytest Patterns
overrides: shared/principles.md
override_reason: LangGraph state testing requires fixtures for consistency
---

# LangGraph Pytest Patterns

**Override Note**: While `shared/principles.md` recommends avoiding implicit
dependencies, LangGraph state testing benefits from fixtures that provide
consistent state schemas. This is an intentional exception.

[Rest of content...]
```

## Integration with Agent/Skill Creation

### Agent Creator Template

When creating new agents, include knowledge base section:

```markdown
# {Agent Name}

Role: {agent-role-name}

## Knowledge Base
Review these documents before performing tasks:
- docs/coding-guidelines/shared/principles.md
- docs/coding-guidelines/{language}/general.md
- docs/coding-guidelines/{language}/testing.md

(Adjust based on agent's specific needs)

## Instructions
...
```

### Skill Creator Template

Similar pattern for skills:

```markdown
# {Skill Name}

## Knowledge Base
This skill generates code following centralized guidelines.

**Before generating code, read:**
- docs/coding-guidelines/{language}/{framework}.md
- docs/coding-guidelines/{language}/testing.md

## Skill-Specific References
For {skill}-specific patterns:
- references/{pattern}.md (skill-local patterns)

## Instructions
...
```

## Benefits

**For Agents/Skills:**
- Consistent coding patterns
- Reduced duplication
- Clear source of truth
- Easy updates (update guideline → all agents benefit)

**For Development Team:**
- Centralized knowledge management
- Git-tracked changes
- Easy onboarding (new agents/skills reference same docs)
- Scalable as project grows

**For Knowledge Evolution:**
- Version controlled
- Review process ensures quality
- Can track when/why guidelines change
- Searchable and discoverable

## Limitations and Considerations

**Not Automatic:**
- Agents must explicitly Read referenced documents
- No automatic injection into context (yet)
- Requires developer discipline

**Token Limits:**
- Long documents may exceed agent context
- Summaries help mitigate this
- Prioritize concise, actionable guidelines

**Maintenance Burden:**
- Guidelines need periodic review
- Outdated guidelines worse than none
- Use `last_reviewed` field to track

## Future Enhancements

**Possible Improvements:**
- Auto-load mechanism (when Claude Code supports it)
- Guideline linting (check for conflicts, outdated info)
- Template generation (auto-generate agent knowledge sections)
- CI checks (ensure agents reference valid paths)
- Search/discovery tool (find relevant guidelines)

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-01-28 | Start with manual references (Phase 1) | Simplest, works immediately, no infrastructure |
| 2025-01-28 | Add `/shared` folder for language-agnostic knowledge | Codex recommendation, supports DRY |
| 2025-01-28 | YAML front matter optional (Phase 3+) | Useful but not required initially |
| 2025-01-28 | Expand beyond coding guidelines to full knowledge base | User insight, supports broader use cases |

## Related Documents

- [Testing Guidelines](coding-guidelines/python/pytest.md) (when created)
- [Architecture Decisions](architecture/decisions/) (when created)

---

**Contributors:**
- Claude (Anthropic) - Initial design and structure
- Codex (OpenAI) - Implementation details and practical guidance
- User - Requirements and use case validation
