# AI Collaborative Solver - Registry Configuration

This document provides detailed information on customizing the model capability registry.

For basic usage, see the main [SKILL.md](../SKILL.md) documentation.

---

## Registry Structure

The capability registry (`config/registry.yaml`) defines all available models and their properties.

```yaml
models:
  - id: openai.codex
    capabilities: [chat, json, tool, debate, code_execution, thread_continuity]
    cost:
      prompt_per_1k: 0.005
      completion_per_1k: 0.015
    limits:
      context_window: 128000
      rate_limit: 10000
    quality_tier: premium

  - id: anthropic.claude-sonnet
    capabilities: [chat, json, tool, debate, long_context]
    cost:
      prompt_per_1k: 0.003
      completion_per_1k: 0.015
    limits:
      context_window: 200000
      rate_limit: 1000
    quality_tier: premium

  - id: google.gemini-pro
    capabilities: [chat, json, debate, grounding, large_context]
    cost:
      prompt_per_1k: 0.001
      completion_per_1k: 0.005
      free_tier: true
    limits:
      context_window: 1000000
      rate_limit: 60
    quality_tier: standard

selection_rules:
  - pattern: "(코드|code|리뷰|review|버그|bug)"
    model: openai.codex
    priority: 10

  - pattern: "(write|작성|document|문서)"
    model: anthropic.claude-sonnet
    priority: 10

  - pattern: "(2025|최신|latest|트렌드|trend)"
    model: google.gemini-pro
    priority: 10

fallback_chains:
  openai.codex:
    - openai.codex
    - anthropic.claude-sonnet
    - google.gemini-pro

  anthropic.claude-sonnet:
    - anthropic.claude-sonnet
    - openai.codex
    - google.gemini-pro

  google.gemini-pro:
    - google.gemini-pro
    - anthropic.claude-sonnet

cost_presets:
  minimal:
    models: [google.gemini-pro]
    max_cost: 0

  balanced:
    models: [google.gemini-pro, anthropic.claude-sonnet]
    max_cost: 0.50

  premium:
    models: [openai.codex, anthropic.claude-sonnet, google.gemini-pro]
    max_cost: 5.00

  hybrid:
    models: [openai.codex, google.gemini-pro]
    max_cost: 2.00
```

---

## Field Definitions

### Model Definition

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✅ | Unique model identifier (format: `provider.model-name`) |
| `capabilities` | list | ✅ | Supported capabilities (see below) |
| `cost` | object | ✅ | Pricing information |
| `limits` | object | ❌ | Context window, rate limits |
| `quality_tier` | string | ❌ | `premium` \| `standard` \| `experimental` |
| `adapter_path` | string | ❌ | Custom adapter path (defaults to `models/{provider}/adapter.sh`) |

### Capabilities

Available capability flags:

| Capability | Description | Example Models |
|------------|-------------|----------------|
| `chat` | Conversational interaction | All models |
| `json` | Structured JSON output | Codex, Claude, Gemini |
| `tool` | Function calling / tools | Codex, Claude |
| `debate` | Multi-round reasoning | All models |
| `code_execution` | Execute code | Codex |
| `thread_continuity` | Maintain conversation threads | Codex, Claude |
| `grounding` | External knowledge grounding | Gemini |
| `large_context` | >100k token context | Claude, Gemini |
| `long_context` | Extended context handling | Claude |

### Cost Structure

```yaml
cost:
  prompt_per_1k: 0.003      # Cost per 1k prompt tokens (USD)
  completion_per_1k: 0.015  # Cost per 1k completion tokens (USD)
  free_tier: true           # Optional: free tier available
  subscription: 20.00       # Optional: monthly subscription (USD)
```

---

## Selection Rules

Define pattern-based automatic model selection:

```yaml
selection_rules:
  - pattern: "(regex pattern)"
    model: model.id
    priority: 10           # Higher = checked first
    conditions:            # Optional conditions
      - capability: code_execution
      - quality_tier: premium
```

### Rule Evaluation Order

1. Rules sorted by priority (highest first)
2. Pattern matching (regex, case-insensitive)
3. Condition validation
4. First matching rule wins

### Example: Advanced Selection Rules

```yaml
selection_rules:
  # Security-specific
  - pattern: "(보안|security|취약점|vulnerability|CVE)"
    model: openai.codex
    priority: 15
    conditions:
      - capability: code_execution

  # Performance optimization
  - pattern: "(성능|performance|최적화|optimize|latency)"
    model: openai.codex
    priority: 12

  # Latest trends (override for 2025+)
  - pattern: "(2025|2026|latest|newest)"
    model: google.gemini-pro
    priority: 11
    conditions:
      - capability: grounding

  # Writing tasks
  - pattern: "(write|작성|document|문서|explain|설명)"
    model: anthropic.claude-sonnet
    priority: 10

  # Default: code/tech
  - pattern: ".*"
    model: openai.codex
    priority: 1
```

---

## Fallback Chains

Define model fallbacks for reliability:

```yaml
fallback_chains:
  # If Codex fails, try Claude, then Gemini
  openai.codex:
    - openai.codex
    - anthropic.claude-sonnet
    - google.gemini-pro

  # If Claude fails, try Codex (premium fallback)
  anthropic.claude-sonnet:
    - anthropic.claude-sonnet
    - openai.codex
    - google.gemini-pro
```

### Fallback Triggers

Fallback occurs when:
- Model returns error status
- Rate limit exceeded
- Authentication failure
- Network timeout (>60s)

---

## Cost Presets

Pre-defined cost/quality configurations:

```yaml
cost_presets:
  # Free tier only
  minimal:
    models: [google.gemini-pro]
    max_cost: 0
    quality_tier: standard

  # Balanced cost/quality
  balanced:
    models: [google.gemini-pro, anthropic.claude-sonnet]
    max_cost: 0.50
    quality_tier: [standard, premium]

  # Best quality
  premium:
    models: [openai.codex, anthropic.claude-sonnet]
    max_cost: 5.00
    quality_tier: premium

  # Hybrid analysis
  hybrid:
    models: [openai.codex, google.gemini-pro]
    max_cost: 2.00
    description: "Premium code analysis + free trend research"
```

### Using Presets

```bash
# Use preset
./ai-debate.sh "Problem" --preset minimal

# Override preset
./ai-debate.sh "Problem" --preset balanced --model codex
```

---

## Adding a New Model

### Step 1: Create Adapter

```bash
# Create model directory
mkdir -p .claude/skills/ai-collaborative-solver/models/new-provider

# Create adapter script
cat > .claude/skills/ai-collaborative-solver/models/new-provider/adapter.sh <<'EOF'
#!/bin/bash
PROBLEM="$1"
MODE="$2"
STATE_DIR="$3"

# Model-specific API call
curl -X POST https://api.new-provider.com/v1/chat \
  -H "Authorization: Bearer $NEW_PROVIDER_API_KEY" \
  -d "{
    \"messages\": [{\"role\": \"user\", \"content\": \"$PROBLEM\"}],
    \"model\": \"new-model-v1\"
  }"
EOF

chmod +x .claude/skills/ai-collaborative-solver/models/new-provider/adapter.sh
```

### Step 2: Register in Registry

```yaml
models:
  - id: new-provider.new-model
    capabilities: [chat, json, debate]
    cost:
      prompt_per_1k: 0.002
      completion_per_1k: 0.008
    limits:
      context_window: 100000
      rate_limit: 1000
    quality_tier: standard
    adapter_path: models/new-provider/adapter.sh
```

### Step 3: Add Selection Rule (Optional)

```yaml
selection_rules:
  - pattern: "(특정|specific|use-case)"
    model: new-provider.new-model
    priority: 8
```

### Step 4: Test

```bash
# Test adapter directly
bash .claude/skills/ai-collaborative-solver/models/new-provider/adapter.sh \
  "Test problem" "simple" "./test-state"

# Test via orchestrator
./ai-debate.sh "Test problem" --model new-provider.new-model
```

---

## Environment Variables

Configure registry behavior via environment:

```bash
# Custom registry path
export REGISTRY_PATH=./custom-registry.yaml

# Override default model
export DEFAULT_MODEL=google.gemini-pro

# Force cost preset
export COST_PRESET=minimal

# Disable fallbacks (fail fast)
export DISABLE_FALLBACKS=1
```

---

## Validation

Validate registry syntax:

```bash
# Check YAML syntax
yamllint config/registry.yaml

# Test model selection
./scripts/test-selection.sh "코드 리뷰 필요"
# Expected: openai.codex

./scripts/test-selection.sh "2025 최신 트렌드"
# Expected: google.gemini-pro
```

---

For advanced usage examples, see: [advanced-usage.md](advanced-usage.md)

**Back to:** [Main Documentation](../SKILL.md)
