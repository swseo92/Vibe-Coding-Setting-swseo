# AI-Collaborative-Solver Architecture Design

**Codex Debate Session**
- **Date:** 2025-10-31
- **Session ID:** 019a39f2-1812-7d42-9442-14c7c85c45f2
- **Topic:** Generalizing Codex V3.0 to Multi-Model Architecture

---

## Executive Summary

AI-Collaborative-Solver should be a **generalized version of Codex V3.0**, where:
- **Framework (Facilitator, quality gates, playbooks) = Model-agnostic**
- **Model = Swappable component** (Codex, Gemini, Claude, etc.)
- **All V3.0 quality features apply to ANY model**

---

## Key Design Decisions

### 1. ModelAdapter Protocol

**Interface Contract:**

```python
from __future__ import annotations
from dataclasses import dataclass
from typing import Protocol, AsyncIterator, Mapping, Any

@dataclass(frozen=True)
class ModelRequest:
    task_id: str
    messages: list[dict[str, Any]]           # OpenAI-style role/content
    tools: list[ToolSpec] = ()
    system_hint: str | None = None
    temperature: float | None = None
    max_output_tokens: int | None = None
    response_format: str | None = None       # "text" | "json" | "tool_calls"
    metadata: Mapping[str, Any] = frozenset()

@dataclass(frozen=True)
class ModelResponse:
    messages: list[dict[str, Any]]           # assistant/tool messages normalized
    usage: Usage                              # tokens + cost
    finish_reason: str                        # "stop", "length", "tool_call"
    raw: Any                                  # provider-native payload

class ModelAdapter(Protocol):
    name: str
    provider: str
    default_model: str
    supported_capabilities: set[str]          # {"chat", "json", "tool", "debate"}

    async def invoke(self, request: ModelRequest, *, session: SessionContext) -> ModelResponse
    def stream(self, request: ModelRequest, *, session: SessionContext) -> AsyncIterator[StreamEvent]
    def supports(self, capability: str) -> bool
    def cost_estimate(self, request: ModelRequest) -> Usage
    async def healthcheck(self) -> None
```

**Key principles:**
- Unified request/response format
- Provider-agnostic telemetry
- Side-effect free (retries at facilitator layer)

---

### 2. Facilitator Pipeline (7 Stages)

**Stage 0: Session Bootstrap**
- Input: Raw user task + context
- Output: SessionState (user profile, constraints)
- Decision: Abort if policy violation

**Stage 1: Pre-Clarification**
- Input: SessionState
- Output: Clarification questions + updated context
- Decision: If unanswered after 2 attempts → abort

**Stage 2: Capability Planning**
- Input: Clarified problem statement
- Output: ExecutionPlan (model, playbook, tooling)
- Decision: If no candidate satisfies → escalate

**Stage 3: Draft Generation**
- Input: ExecutionPlan
- Output: Primary model response + telemetry
- Decision: Adapter errors > budget → fallback model

**Stage 4: Quality Gate**
- Input: Primary response
- Output: Pass/fail + remediation instructions
- Decision: Fail with remediation → Stage 5, else escalate

**Stage 5: Layer-2 Escalation (Debate/Self-Critique)**
- Input: Failed draft + remediation plan
- Output: Revised response or escalation packet
- Decision: Success → Stage 6, repeated failure → escalate

**Stage 6: Post-Processing & Delivery**
- Input: Final content
- Output: User-facing artifact + logs
- Decision: Run compliance filters → deliver or escalate

---

### 3. Capability Registry

**Structure:**

```yaml
models:
  - id: openai.gpt-4o
    adapter: openai
    modalities: [text]
    max_output_tokens: 4096
    cost:
      prompt: 0.000005
      completion: 0.000015
    capabilities: [chat, json, tool, debate]
    default_playbook_roles:
      clarification: true
      escalation: true

  - id: google.gemini-1.5-pro
    adapter: google
    modalities: [text, image]
    max_output_tokens: 2048
    cost:
      prompt: 0.000002
      completion: 0.000006
    capabilities: [chat, clarification, grounding]
```

**Purpose:**
- Facilitator queries by capability, cost, latency
- Loaded at startup (YAML/JSON)
- Drives model selection

---

### 4. Playbook Override Mechanism

**Structure:**

```yaml
playbook: baseline-agent
stages:
  clarification:
    model: google.gemini-1.5-pro
    adapter_options:
      temperature: 0.1
      max_output_tokens: 512

  draft_generation:
    model: openai.gpt-4o
    adapter_options:
      temperature: 0.2
      response_format: text

  quality_gate:
    model: openai.gpt-4o
    adapter_options:
      temperature: 0.0
      tool_choice: auto

  escalation:
    enabled: true
    primary_model: anthropic.claude-3.5
    fallback_model: openai.gpt-4o
    max_cycles: 2

defaults:
  safety_review_model: OpenAI-moderation
  retry_policy:
    max_attempts: 2
    backoff_seconds: 3
```

**Benefits:**
- Per-stage model selection
- Cost optimization (cheap for clarification, powerful for generation)
- Flexible fallback chains

---

### 5. Facilitator Refactoring Strategy

**Current Problem:**
- V3.0 Facilitator tightly coupled to Codex
- Pattern detection specific to Codex responses
- Escalation hardcoded to Codex

**Solution:**

**Extract into pluggable components:**

1. **ModelAdapter** - Per-model implementations
   ```
   - CodEXAdapter (existing logic)
   - GeminiAdapter (new)
   - ClaudeAdapter (future)
   ```

2. **ResponseInterpreter** - Pattern detection abstraction
   ```python
   class ResponseInterpreter(Protocol):
       def extract_confidence(self, response: ModelResponse) -> float
       def detect_escalation_markers(self, response: ModelResponse) -> bool
       def parse_evidence_tier(self, response: ModelResponse) -> EvidenceTier
   ```
   - Codex: Current regex patterns
   - Gemini: Structured metadata
   - Generic: Fallback heuristics

3. **EscalationStrategy** - Model selection for Layer 2
   ```python
   class EscalationStrategy:
       def select_escalation_model(
           self,
           failed_model: str,
           problem_type: str,
           registry: CapabilityRegistry
       ) -> str
   ```

**Backward Compatibility:**
- Codex adapter = default for all stages (unless overridden)
- Identical behavior when using `--model codex`
- No changes to existing playbooks

---

### 6. Pre-Clarification Model Selection

**Codex Recommendation: Option C (Lightweight Model)**

**Rationale:**
- Cost efficiency (Gemini or GPT-4o-mini)
- Fast turnaround
- Sufficient for clarification questions

**Configuration:**
```yaml
clarification:
  default_model: google.gemini-1.5-pro  # Cheap, fast
  high_risk_override: openai.gpt-4o     # For critical domains
  parity_mode: selected_primary          # Match debate model
```

**Benefits:**
- Default: Low cost
- Override for high-stakes
- Backward compatible (can force Codex)

---

### 7. Implementation Roadmap

**MVP (v1.0) - Must-Have:**

✅ **Core Infrastructure:**
1. Define `ModelAdapter` protocol + dataclasses
2. Implement Codex adapter (migrate existing logic)
3. Implement Gemini adapter
4. Create capability registry (YAML format)
5. Build registry loader + query logic

✅ **Facilitator Refactor:**
6. Extract ResponseInterpreter interface
7. Port Codex pattern detection to ResponseInterpreter
8. Update facilitator to consume ModelAdapter
9. Implement playbook override system
10. Add telemetry (adapter_name, model_id)

✅ **Testing:**
11. Regression test Codex behavior (must be identical)
12. Test Gemini adapter with simple debates
13. Validate playbook overrides work

**Defer to v1.1+:**

🔮 **Advanced Features:**
- Additional adapters (Claude, DeepSeek)
- Cost-aware auto-selection
- Streaming UX enhancements
- Multi-modal support
- Human-in-the-loop dashboards
- Fine-grained telemetry visualization

---

## Critical Design Principles

### 1. **Model-Agnostic Core**
- Facilitator logic independent of model choice
- All quality checks (coverage, anti-patterns, gates) universal
- Playbooks work with any model

### 2. **Pluggable Architecture**
- New models = implement ModelAdapter interface
- No changes to facilitator or playbooks
- Hot-swappable via configuration

### 3. **Backward Compatible**
- `--model codex` = identical to V3.0
- Existing playbooks work unchanged
- No regression for current users

### 4. **Cost-Conscious**
- Use cheap models where appropriate (clarification)
- Expensive models only when needed (generation, escalation)
- Registry tracks costs, facilitator optimizes

### 5. **Extensible**
- Easy to add new models (implement interface)
- Easy to add new stages (extend pipeline)
- Easy to add new capabilities (registry flags)

---

## Example Workflow

### Scenario: User requests architecture debate

**Step 1: Session Bootstrap**
```
User: "AI 토론해서 microservices vs monolith 결정"
→ SessionState created
```

**Step 2: Pre-Clarification (Gemini)**
```
Model: google.gemini-1.5-pro (cheap, fast)
Questions:
- Team size?
- Timeline?
- Tech stack?
→ Context enriched
```

**Step 3: Capability Planning**
```
Problem: Architecture decision
Registry query: capabilities=[debate, architecture]
Selected: openai.gpt-4o (Codex) - best for architecture
Playbook: architecture-decision.yaml
```

**Step 4: Draft Generation (Codex)**
```
Model: openai.gpt-4o
Rounds: 4 (balanced mode)
→ Primary response generated
```

**Step 5: Quality Gate (Codex)**
```
Model: openai.gpt-4o (same as draft)
Checks: Coverage, evidence tiers
→ PASS
```

**Step 6: Delivery**
```
Report saved: .debate-reports/...
User sees: Codex recommendation with confidence
```

**If Quality Gate FAILED:**
```
Stage 5: Escalation (Claude)
Model: anthropic.claude-3.5 (different perspective)
→ Revised response → Re-check quality gate
```

---

## File Structure (Proposed)

```
.claude/skills/ai-collaborative-solver/
├── core/
│   ├── model_adapter.py          # Protocol definition
│   ├── response_interpreter.py   # Pattern detection
│   ├── facilitator.py             # 7-stage pipeline
│   └── escalation_strategy.py    # Layer-2 selection
│
├── adapters/
│   ├── codex_adapter.py           # OpenAI Codex implementation
│   ├── gemini_adapter.py          # Google Gemini implementation
│   └── claude_adapter.py          # Anthropic Claude (future)
│
├── config/
│   ├── registry.yaml              # Capability registry
│   └── playbooks/
│       ├── architecture-decision.yaml
│       ├── code-review.yaml
│       └── research-task.yaml
│
└── scripts/
    ├── ai-debate.sh               # CLI entry point
    └── utils/
        ├── model-selector.sh
        └── hybrid-orchestrator.sh
```

---

## Migration Path

### Phase 1: Infrastructure (Week 1)
- [ ] Define ModelAdapter protocol
- [ ] Create capability registry format
- [ ] Implement Codex adapter (wrap existing)

### Phase 2: Facilitator (Week 2)
- [ ] Extract ResponseInterpreter
- [ ] Refactor facilitator to use adapters
- [ ] Regression test Codex parity

### Phase 3: Expansion (Week 3)
- [ ] Implement Gemini adapter
- [ ] Create playbook override system
- [ ] Test hybrid mode

### Phase 4: Polish (Week 4)
- [ ] Documentation
- [ ] Examples
- [ ] Performance tuning

---

## Success Metrics

**v1.0 Goals:**
- ✅ Codex behavior identical to V3.0
- ✅ Gemini adapter working for simple tasks
- ✅ Playbook overrides functional
- ✅ Hybrid mode produces comparison reports
- ✅ Zero regression in existing workflows

**v1.1+ Goals:**
- 🔮 3+ models supported (Codex, Gemini, Claude)
- 🔮 Cost reduction (25% via smart model selection)
- 🔮 Quality improvement (multi-model consensus)
- 🔮 User satisfaction (90%+ prefer multi-model)

---

## Conclusion

**AI-Collaborative-Solver = Generalized Codex V3.0**

**What stays the same:**
- All V3.0 quality features (Facilitator, gates, playbooks)
- All behavior when using Codex
- All existing workflows

**What's new:**
- Model abstraction layer
- Support for multiple AI models
- Intelligent model selection
- Cost optimization

**Implementation:** Start with v1.0 MVP, iterate based on feedback.

**Timeline:** 4 weeks to feature-complete v1.0

---

**Next Steps:**
1. Review this design with team
2. Start Phase 1 (Infrastructure)
3. Implement ModelAdapter protocol
4. Create Codex adapter (wrap existing)
5. Regression test to ensure parity

**Recommendation:** Proceed with implementation!
