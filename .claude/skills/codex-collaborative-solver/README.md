# Codex Collaborative Solver V3.0

**Status:** 🧪 Experimental (Testing vs V2.0)
**Created:** 2025-10-31
**Based On:** Meta-debate Session ID 019a37e1-6dc5-7d91-824e-52cae43772eb

---

## Quick Start

**For New Users:** Read `skill.md` first, then `references/v2-vs-v3-comparison.md`

**For V2.0 Users:** Go straight to `references/v2-vs-v3-comparison.md`

---

## What is V3.0?

V3.0 is a quality-first debate architecture that adds:

1. **3-Layer Facilitator** - Monitors debate health, detects failures
2. **3 Quality Modes** - exploration/balanced/execution
3. **Automated Playbooks** - Learn from past debates
4. **Tiered Evidence** - T1/T2/T3 with confidence levels
5. **Information Scarcity Protocol** - Aborts when missing critical data
6. **10 Failure Detections** - Explicit handling of edge cases

---

## Directory Structure

```
codex-collaborative-solver-v3/
├── skill.md                    # Main documentation (START HERE)
├── README.md                   # This file
│
├── facilitator/                # Quality assurance system
│   ├── rules/
│   │   ├── coverage-monitor.yaml      # 8-dimension tracking
│   │   ├── anti-patterns.yaml         # Failure detection
│   │   └── scarcity-thresholds.yaml   # Information handling
│   ├── prompts/
│   │   └── ai-escalation.md           # Escalation templates
│   └── quality-gate.md                # Final checklist
│
├── modes/                      # Quality mode definitions
│   ├── exploration.yaml        # Creative exploration (5-7 rounds)
│   ├── balanced.yaml           # Default mode (3-5 rounds)
│   └── execution.yaml          # Fast execution (2-3 rounds)
│
├── playbooks/                  # Reusable knowledge
│   ├── _template.md            # Playbook structure
│   └── database-optimization.md # Example playbook
│
├── schemas/                    # Data structures (planned)
│   ├── debate-log.json
│   ├── playbook-schema.json
│   └── metrics.json
│
├── scripts/                    # Automation (planned)
│   └── facilitator/
│       ├── check-coverage.py
│       ├── detect-anti-patterns.py
│       └── generate-playbook.py
│
└── references/                 # Documentation
    ├── v2-vs-v3-comparison.md  # Feature comparison
    └── v3-design-debate.md     # Original design document
```

---

## Key Differences vs V2.0

| Feature | V2.0 | V3.0 |
|---------|------|------|
| **Quality Assurance** | Manual | Automated Facilitator |
| **Adaptability** | Fixed | 3 Modes |
| **Knowledge Reuse** | None | Playbooks |
| **Evidence** | Implicit | Tiered (T1/T2/T3) |
| **Failure Detection** | None | 10 mechanisms |
| **Actionability** | 60% | 90% (expected) |

**Full comparison:** `references/v2-vs-v3-comparison.md`

---

## Implementation Status

### ✅ Phase 1: Design (Complete)

- [x] Main skill.md documentation
- [x] Facilitator rules (coverage, anti-patterns, scarcity)
- [x] Quality gate checklist
- [x] AI escalation prompts
- [x] 3 mode definitions
- [x] Playbook template + example
- [x] V2 vs V3 comparison
- [x] Design debate reference

### 🚧 Phase 2: Automation (Planned)

- [ ] Structured logging implementation
- [ ] Auto-tagging system (NLP)
- [ ] Playbook clustering logic
- [ ] LLM summarizer for playbook drafts
- [ ] Mode auto-detection
- [ ] Facilitator automation scripts

### 🔮 Phase 3: Feedback Loop (Future)

- [ ] User feedback collection
- [ ] Telemetry for coverage drift
- [ ] Playbook expiration system
- [ ] Heuristic tuning
- [ ] Meta-analysis dashboard

---

## Current Limitations

**V3.0 is currently a DESIGN SPEC**, not fully automated:

1. **Facilitator checks are manual** - Claude must apply rules from YAML files
2. **No automatic playbook generation** - Playbooks must be created manually
3. **Mode detection is manual** - User or Claude must select mode
4. **No telemetry** - Can't automatically tune heuristics yet

**However, the STRUCTURE is complete:**
- All rules are defined and can be applied manually
- Quality gate checklist can be run
- Modes provide clear guidance
- Playbook template ready for use

---

## How to Test V3.0

### Option 1: Manual Application

When using Codex collaborative solver:

1. **Select mode** based on problem type (or use balanced)
2. **Load playbook** if one exists for problem type
3. **Apply facilitator rules** from `facilitator/rules/`
4. **Run quality gate** from `facilitator/quality-gate.md` before finalizing
5. **Compare results** vs V2.0 debate

### Option 2: Side-by-Side Comparison

Run same problem through both:
- V2.0: Use existing skill
- V3.0: Apply V3.0 rules manually
- Compare: Which produced better quality?

### Option 3: Build Automation (Phase 2)

Implement scripts in `scripts/facilitator/`:
- `check-coverage.py` - Automate coverage monitoring
- `detect-anti-patterns.py` - Automate failure detection
- Generate structured logs for playbook pipeline

---

## Expected Improvements (To Be Validated)

Based on meta-debate analysis:

| Metric | V2.0 Baseline | V3.0 Target |
|--------|---------------|-------------|
| Actionability | 60% | 90% |
| Confidence Clarity | 10% | 100% |
| Coverage | 4/8 dims | 7/8 dims |
| Appropriate Pauses | 0% | 20-30% |
| User Satisfaction | ? | 4.5/5 |

**Validate these claims through real usage!**

---

## Next Steps

### For Contributors:

1. **Test the design** - Apply V3.0 rules manually in debates
2. **Collect feedback** - Does V3.0 improve quality?
3. **Build automation** - Implement Phase 2 scripts
4. **Tune thresholds** - Adjust facilitator rules based on results
5. **Generate playbooks** - Create more playbook examples

### For Users:

1. **Read `skill.md`** - Understand V3.0 architecture
2. **Compare with V2.0** - Read `references/v2-vs-v3-comparison.md`
3. **Try manual application** - Use V3.0 rules in next debate
4. **Provide feedback** - What worked? What didn't?

---

## Documentation

**Primary:**
- `skill.md` - Complete V3.0 documentation

**Reference:**
- `references/v2-vs-v3-comparison.md` - Feature comparison
- `references/v3-design-debate.md` - Original design session

**Configuration:**
- `facilitator/` - Quality assurance system
- `modes/` - Mode definitions
- `playbooks/` - Reusable knowledge templates

---

## Questions?

**"Should I use V3.0 or V2.0?"**
- V2.0: Speed matters, low stakes, simple problems
- V3.0: Quality matters, high stakes, need coverage

**"Is V3.0 ready for production?"**
- Design: Yes (complete)
- Automation: No (manual application required)
- Validation: No (needs real-world testing)

**"How do I contribute?"**
- Test V3.0 rules manually
- Build automation scripts
- Create playbooks for your domain
- Provide feedback on thresholds

---

## Credits

**Designed by:** Claude (Anthropic) + Codex (OpenAI) in meta-debate
**Meta-Debate Session:** 019a37e1-6dc5-7d91-824e-52cae43772eb
**Date:** 2025-10-31
**Debate Report:** `.debate-reports/2025-10-31-debate-skill-v3-design.md`

**Key Insight from Codex:**
> "Claude's proposals add ceremony without payoff. Structure for value, not for form."

This insight shaped the entire V3.0 design.

---

**Version:** 3.0.0-experimental
**Status:** Design complete, automation pending
**License:** Same as parent project
