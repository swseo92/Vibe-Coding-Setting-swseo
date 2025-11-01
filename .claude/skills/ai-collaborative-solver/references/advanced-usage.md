# AI Collaborative Solver - Advanced Usage

This document covers advanced features and customization options for power users.

For basic usage, see the main [SKILL.md](../SKILL.md) documentation.

---

## Custom Mode Configuration

Create custom debate modes by defining mode files in `.claude/skills/ai-collaborative-solver/modes/`.

### Mode File Structure

```yaml
# modes/custom.yaml
name: custom
rounds: 5
agents:
  - explorer
  - critic
  - security
  - performance
  - synthesizer
```

### Available Agent Roles

| Role | Purpose | When to use |
|------|---------|-------------|
| `explorer` | Generate diverse approaches | Always (first round) |
| `critic` | Reality-check feasibility | Always (second round) |
| `synthesizer` | Recommend solution | Always (final round) |
| `security` | Security & risk analysis | Security-critical projects |
| `performance` | Scalability analysis | High-load systems |
| `integrator` | Comprehensive synthesis | Complex multi-faceted problems |

### Example: Security-Focused Mode

```yaml
# modes/security-heavy.yaml
name: security-heavy
rounds: 5
agents:
  - explorer          # Generate secure approaches
  - security          # Early security analysis
  - critic           # Reality-check
  - security         # Deep security dive
  - synthesizer      # Final recommendation
```

Use case: Payment systems, healthcare, compliance-heavy projects

### Example: Performance-Optimized Mode

```yaml
# modes/perf-focused.yaml
name: perf-focused
rounds: 5
agents:
  - explorer          # Generate solutions
  - performance       # Early perf analysis
  - critic           # Reality-check
  - performance      # Deep performance dive
  - synthesizer      # Final recommendation
```

Use case: High-traffic APIs, real-time systems, data processing pipelines

### Example: Rapid Prototyping Mode

```yaml
# modes/rapid.yaml
name: rapid
rounds: 2
agents:
  - explorer          # Quick exploration
  - synthesizer      # Fast recommendation
```

Use case: Proof-of-concepts, hackathons, time-sensitive experiments

---

## Using Custom Modes

```bash
# Create your custom mode file
cat > .claude/skills/ai-collaborative-solver/modes/my-mode.yaml <<EOF
name: my-mode
rounds: 4
agents:
  - explorer
  - critic
  - security
  - synthesizer
EOF

# Use your custom mode
./ai-debate.sh "Problem description" --mode my-mode
```

---

## Advanced Options

### Combining Auto-Select with Custom Mode

```bash
# Auto-select model + custom mode
./ai-debate.sh "Problem" --auto --mode security-heavy
```

### Hybrid + Custom Mode

```bash
# Multiple models + custom security mode
./ai-debate.sh "Payment processing design" \
  --models codex,claude \
  --mode security-heavy
```

### Output Directory Customization

```bash
# Save to custom directory
DEBATE_OUTPUT_DIR=./custom-reports ./ai-debate.sh "Problem" --auto
```

### Debug Mode

```bash
# Enable detailed logging
DEBUG=1 ./ai-debate.sh "Problem" --auto
```

---

## Integration with CI/CD

### Example: Architecture Decision Records

```bash
#!/bin/bash
# generate-adr.sh - Auto-generate ADR from debate

PROBLEM="$1"
ADR_NUMBER="$2"

# Run debate
./ai-debate.sh "$PROBLEM" --auto --mode balanced

# Extract report
LATEST_REPORT=$(ls -t .debate-reports/*.md | head -1)

# Convert to ADR format
cat > "docs/adr/ADR-${ADR_NUMBER}.md" <<EOF
# ADR ${ADR_NUMBER}: $(basename $LATEST_REPORT .md)

## Status
Proposed

## Context
Problem: $PROBLEM

## Decision
$(grep -A 50 "## Final Summary" $LATEST_REPORT)

## Consequences
$(grep -A 10 "## Risks & Mitigations" $LATEST_REPORT)

## Generated
$(date)
AI Debate Report: $LATEST_REPORT
EOF
```

Usage:
```bash
./generate-adr.sh "Database selection for user service" "015"
```

---

## Advanced Model Selection

### Cost-Based Selection

```bash
# Prefer free tier models
PREFER_FREE=1 ./ai-debate.sh "Problem" --auto

# Force premium models
FORCE_PREMIUM=1 ./ai-debate.sh "Problem" --auto
```

### Fallback Chains

If a model fails, the system automatically falls back to alternatives (defined in `registry.yaml`).

```yaml
# Example fallback chain
fallback_chains:
  codex:
    - openai.codex
    - anthropic.claude-sonnet  # If Codex unavailable
    - google.gemini-pro       # Last resort
```

---

## Performance Optimization

### Parallel Execution

```bash
# Run multiple debates in parallel
for problem in "A vs B" "C vs D" "E vs F"; do
  ./ai-debate.sh "$problem" --auto &
done
wait  # Wait for all to complete
```

### Caching

Enable response caching to avoid re-running identical debates:

```bash
# Enable caching (experimental)
ENABLE_CACHE=1 ./ai-debate.sh "Problem" --auto
```

---

## Custom Adapters

Create your own model adapters by following the adapter pattern:

```bash
# Create adapter directory
mkdir -p .claude/skills/ai-collaborative-solver/models/custom-model

# Create adapter script
cat > .claude/skills/ai-collaborative-solver/models/custom-model/adapter.sh <<'EOF'
#!/bin/bash
PROBLEM="$1"
MODE="$2"
STATE_DIR="$3"

# Your custom model integration here
# Must output JSON response to stdout

echo '{
  "response": "Custom model response",
  "confidence": 85,
  "metadata": {...}
}'
EOF

chmod +x .claude/skills/ai-collaborative-solver/models/custom-model/adapter.sh
```

Then register in `config/registry.yaml`:

```yaml
models:
  - id: custom.my-model
    adapter_path: models/custom-model/adapter.sh
    capabilities: [chat, json, debate]
    cost: {prompt_per_1k: 0.001, completion_per_1k: 0.003}
```

---

## Troubleshooting Advanced Features

### Custom Mode Not Loading

```bash
# Verify mode file syntax
cat .claude/skills/ai-collaborative-solver/modes/my-mode.yaml

# Check for YAML syntax errors
# Ensure 'name' and 'agents' fields are present
```

### Adapter Integration Issues

```bash
# Test adapter directly
bash .claude/skills/ai-collaborative-solver/models/custom-model/adapter.sh \
  "test problem" "simple" "./test-state"

# Check exit code
echo $?  # Should be 0
```

---

For registry customization details, see: [registry-config.md](registry-config.md)

**Back to:** [Main Documentation](../SKILL.md)
