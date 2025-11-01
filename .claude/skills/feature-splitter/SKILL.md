---
name: feature-splitter
description: Strategic task decomposition for parallel worktree development. Analyzes high-level features and breaks them into independent subtasks with dependency mapping. Use when planning multi-part features, setting up parallel development, or determining worktree strategy. Language and framework agnostic - adapts to any codebase architecture.
---

# Feature Splitter

Strategic task decomposition and worktree planning for parallel development. Transforms high-level goals into actionable subtasks with clear dependencies and merge strategies.

## When to Use This Skill

Activate this skill when you need to:

- **"Split this feature for parallel development"** - Decompose complex features
- **"How should I use worktrees for this?"** - Strategic worktree planning
- **"Break down this task into independent pieces"** - Identify natural boundaries
- **"What's the best order to implement this?"** - Dependency analysis
- **"Can I parallelize this work?"** - Concurrent development strategy

**Appropriate scenarios:**
- Multi-part features requiring parallel development
- Complex changes touching multiple architectural layers
- Features with unclear implementation order
- Work that needs isolation to avoid conflicts
- Large tasks that should be merged incrementally

## Core Principle

**Let the Agent analyze the codebase context.**

This skill provides the decomposition framework and guardrails, but relies on Claude's contextual understanding to:
- Detect the language, framework, and architecture
- Identify natural split points based on actual code structure
- Recognize project-specific patterns and conventions
- Propose subtasks appropriate for the specific codebase

You provide the high-level goal. The Agent figures out how to split it based on your project's reality.

## Core Workflow

### Phase 1: Clarify Goal & Constraints

**Questions to ask:**

1. **Goal Summary**: What's the high-level feature?
2. **Existing Infrastructure**: Does similar functionality exist?
3. **Breaking Changes**: Will this require schema/API changes?
4. **Risk Level**: Security-critical? Performance-sensitive?
5. **Preferred Sequencing**: Sequential (safer) or parallel (faster)?

**Keep it simple - just enough to understand scope and constraints.**

---

### Phase 2: Inventory & Analysis

**Analyze the codebase to identify:**

1. **Existing Patterns**: How are similar features structured?
2. **Architectural Layers**: What layers exist? (e.g., data, logic, presentation, config)
3. **File Organization**: How is code organized? (modules, packages, directories)
4. **Shared Resources**: What files/modules are touched by multiple features?
5. **Testing Strategy**: Where do tests live? How are they organized?

**Use built-in context awareness - no hardcoded file patterns.**

---

### Phase 3: Identify Architectural Seams

**Natural split points based on system boundaries:**

#### Common Architectural Layers

1. **Persistence Layer**
   - Data models, schemas
   - Database migrations
   - Data access logic

2. **Business Logic Layer**
   - Core feature logic
   - Domain services
   - Algorithms and processing

3. **API/Interface Layer**
   - HTTP endpoints, routes
   - Request/response handling
   - Input validation

4. **Configuration Layer**
   - Settings, environment variables
   - Feature flags
   - External service credentials

5. **Testing Layer**
   - Unit tests
   - Integration tests
   - End-to-end tests

**Adapt to actual project architecture - these are guidelines, not rules.**

---

### Phase 4: Derive Subtasks

**Subtask Creation Principles:**

1. **Single Purpose**: Each subtask has one clear deliverable
2. **Reviewable Size**: Fits in 1-2 focused PRs (~1 engineer-day)
3. **Minimal Coupling**: Touches disjoint file sets where possible
4. **Risk Isolation**: Separate high-risk changes (security, schema) for focused review
5. **Testable**: Can be independently validated

**Example Subtask Template:**
```markdown
## Subtask: {descriptive-name}

**Goal**: {one-sentence deliverable}

**Files** (estimated):
- {module/file patterns based on codebase analysis}

**Effort**: {0.5d | 1d | 2d | 3d}

**Risk**: {Low | Medium | High}

**Dependency**: {none | subtask-1, subtask-2}

**Notes**: {gotchas, special considerations}
```

---

### Phase 5: Build Dependency Graph

**Dependency Types:**

1. **Data Flow**: B reads data written by A → B depends on A
2. **Shared State**: Both modify same resources → Coordinate or sequence
3. **Configuration**: B needs settings added by A → B depends on A
4. **Logical**: A validates assumptions needed by B → B depends on A

**Represent as:**
```
Subtask 1 (foundation)
  ├─→ Subtask 2 (builds on 1)
  │   └─→ Subtask 4 (builds on 2)
  └─→ Subtask 3 (builds on 1, parallel with 2)
      └─→ Subtask 5 (builds on 3)
```

**Parallel Clusters**: If no dependency path exists between A and B, they can run in parallel.

---

### Phase 6: Apply Guardrails

**Validation Rules:**

#### 1. Worktree Count Limit
- **Max**: 4-5 concurrent worktrees for solo developers
- **Warn** at 4, **require confirmation** at 5+
- **Rationale**: More = higher cognitive load, more merge conflicts

#### 2. Subtask Size
- **Min**: ~1 engineer-day (smaller tasks don't justify worktree overhead)
- **Max**: ~3 engineer-days (larger tasks increase merge risk)
- **Sweet spot**: 1-2 days per subtask

#### 3. Shared File Conflicts
- **Detect**: Multiple subtasks modifying the same files
- **Warn**: High-risk files (core configs, shared models)
- **Action**: Suggest sequential merge or coordination

#### 4. High-Risk Changes
- **Flag**: Security, schema, third-party integrations
- **Require**: Extra validation, security review
- **Isolate**: Separate subtask for focused review

---

## Output Format

### Decomposition Plan Template

```markdown
## Feature Decomposition: {Feature Name}

### Summary
- Total subtasks: {N}
- Parallel clusters: {M}
- Sequential dependencies: {K}
- Estimated timeline: {X-Y days}
- Risk level: {Low | Medium | High}

### Subtask Breakdown

| # | Subtask | Description | Dependency | Worktree | Effort | Risk |
|---|---------|-------------|------------|----------|--------|------|
| 1 | {name} | {description} | – | feature/{name} | Xd | Low |
| 2 | {name} | {description} | 1 | feature/{name} | Xd | Medium |
| 3 | {name} | {description} | 1 | feature/{name} | Xd | Low |
| 4 | {name} | {description} | 2,3 | feature/{name} | Xd | High |

### Dependency Graph

```
                    1 (foundation)
                   ↙ ↘
          2 (layer A)  3 (layer B)
                   ↘ ↙
                    4 (integration)
```

### Merge Order

**Sequential:**
1. Merge `feature/{subtask-1}` first (foundation)
2. Merge `feature/{subtask-2}` second

**Parallel (after step 1):**
3. Merge `feature/{subtask-3}` and `feature/{subtask-4}` (independent)

### Worktree Creation Commands

```bash
# Foundation (sequential)
/worktree-create feature/{subtask-1}
# → Work, test, merge

/worktree-create feature/{subtask-2}
# → Work, test, merge

# Parallel development
/worktree-create feature/{subtask-3}
/worktree-create feature/{subtask-4}
# → Work on both simultaneously
```

### Risk Mitigation

**High-Risk Items:**
- Subtask {N}: {reason}
- Action: {required validation}

**Shared File Warnings:**
- {file}: touched by subtasks {A, B}
- Recommendation: {merge order or coordination strategy}

**Guardrail Checks:**
✅ Worktree count: {N} (within limit)
✅ Subtask sizing: All 0.5-3 days
⚠️  {Warning if any}
```

---

## Decomposition Strategies

### Strategy 1: Layer-Based (Common)

**Split by architectural layer:**
```
1. Data layer (models, schema)
2. Business logic (core algorithms)
3. API layer (endpoints, routes)
4. Integration layer (glue code)
5. Testing layer (validation)
```

**Best for**: Well-layered architectures, clear separation of concerns

---

### Strategy 2: Feature-Based

**Split by user-facing capability:**
```
1. Feature A (login)
2. Feature B (logout)
3. Feature C (password reset)
4. Integration tests
```

**Best for**: Independent features, microservices

---

### Strategy 3: Risk-Driven

**Isolate high-risk changes:**
```
1. Schema migration (high-risk, do first)
2. Low-risk features (parallel)
3. Integration (after low-risk features)
4. Validation (after all)
```

**Best for**: Features with security/data concerns

---

### Strategy 4: Dependency-Driven

**Follow natural dependency order:**
```
1. Foundation (no dependencies)
2. Tier-2 (depends on foundation)
3. Tier-3 (depends on tier-2)
```

**Best for**: Tightly coupled changes

---

## Integration with git-worktree-manager

**Hand-off Workflow:**

1. **feature-splitter** (this skill): Produces decomposition plan
2. **User Review**: Approves or adjusts plan
3. **Execute**: Copy `/worktree-create` commands
4. **git-worktree-manager**: Creates worktrees, sets up environment
5. **Work**: Implement in each worktree
6. **Merge**: Use merge workflows, cleanup

**The plan is the bridge between strategy and execution.**

---

## Best Practices

### Do's ✅

1. **Understand Context First**: Analyze codebase before suggesting splits
2. **Follow Existing Patterns**: Respect how the project organizes code
3. **Keep It Simple**: Default to sequential if unsure about parallelism
4. **Size Appropriately**: 1-2 day subtasks are the sweet spot
5. **Isolate Risk**: Separate security/schema changes for focused review
6. **Document Dependencies**: Make blocking relationships explicit

### Don'ts ❌

1. **Don't Over-Split**: Avoid creating worktrees for trivial changes (<1 day)
2. **Don't Ignore Shared Files**: Concurrent modifications = conflicts
3. **Don't Assume Parallelism**: Just because subtasks are independent doesn't mean they should be parallel
4. **Don't Skip Guardrails**: Warnings exist for a reason
5. **Don't Use Template Blindly**: Adapt to actual project structure

---

## Language/Framework Adaptation

**This skill adapts automatically by:**

1. **Analyzing Project Structure**: File organization reveals architecture
2. **Detecting Patterns**: Import statements, directory naming, config files
3. **Following Conventions**: Respect language/framework idioms
4. **Asking When Uncertain**: Clarify ambiguous architecture

**No hardcoded assumptions** - the Agent figures out:
- How models/data are organized
- Where business logic lives
- How APIs/endpoints are structured
- Where tests belong
- Configuration management patterns

**Examples of Adaptation:**

- **Python Django**: Detects apps, models, views, migrations
- **Node.js Express**: Detects routes, controllers, middleware
- **Java Spring**: Detects controllers, services, repositories
- **Ruby Rails**: Detects models, controllers, views, migrations
- **Go**: Detects packages, handlers, repositories
- **Rust**: Detects modules, services, handlers

**Agent uses context clues, not templates.**

---

## Example: OAuth Authentication (Language-Agnostic)

**User Goal**: "Add OAuth authentication"

**Agent Analysis** (adapts to codebase):
1. Detects existing auth mechanism
2. Identifies where auth logic lives
3. Finds data persistence layer
4. Locates API endpoint definitions
5. Discovers test organization

**Proposed Split** (generic):
```
1. auth-schema (0.5d, Medium)
   - Add data models for OAuth tokens
   - Create migration/schema update

2. auth-config (0.5d, Low)
   - Add OAuth provider credentials
   - Update configuration

3. auth-provider (1d, High)
   - Implement OAuth handshake logic
   - Token exchange and validation

4. auth-endpoints (1d, Medium)
   - Add login, callback, logout routes
   - Request/response handling

5. auth-integration (0.5d, Medium)
   - Integrate with existing auth system
   - Update protected routes

6. auth-tests (1d, Low)
   - End-to-end OAuth flow tests
```

**Dependencies**:
```
schema → config → provider → endpoints → integration → tests
```

**No Python-specific assumptions** - adapts to Java, JavaScript, Go, etc.

---

## References

For detailed technical background:

- **`references/algorithm-details.md`** - Deep dive into 6-step decomposition
- **`references/guardrails.md`** - Complete validation rules
- **`references/python-specific.md`** - Python/Django/FastAPI adaptations (optional)

---

## Quick Start

**First Time:**
```
User: "I want to add {feature} to my project"

feature-splitter:
1. Asks clarifying questions (5-6 questions)
2. Analyzes codebase structure (automatic)
3. Proposes subtask breakdown
4. Outputs dependency graph + worktree commands

User: Reviews plan, executes commands
```

**The Agent handles the context - you provide the goal.**

---

## Design Philosophy

1. **Language Agnostic**: No hardcoded assumptions about tech stack
2. **Context Aware**: Use built-in Agent intelligence to understand codebase
3. **Principle-Based**: Teach decomposition framework, not specific patterns
4. **Pragmatic Defaults**: Sensible guardrails, but allow overrides
5. **Safety First**: Flag high-risk changes, require approvals

**Trust the Agent to understand your codebase.**

---

**Version:** 2.0.0 (Language-Agnostic)
**Dependencies:** git-worktree-manager skill
**Status:** Production ready
