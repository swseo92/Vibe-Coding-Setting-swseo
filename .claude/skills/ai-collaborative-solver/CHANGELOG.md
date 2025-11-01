# Changelog

All notable changes to AI Collaborative Solver will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-11-01

### Added - Phase 3: Advanced Debate Quality

#### Phase 3.1: Mid-debate User Input
- **Interactive Clarification System** 🤔
  - Heuristic detection for uncertainty keywords (unclear, uncertain, depends on)
  - Heuristic detection for disagreement patterns (however, disagree, alternatively)
  - User input prompt displayed in interactive mode only
  - User input saved to `round{N}_user_input.txt`
  - Context propagation to next round
  - Round 2+ trigger (minimum 1 round history needed)

#### Phase 3.2: Stress-pass Questions (Devil's Advocate)
- **Automatic Critical Challenge System** 💡
  - Dominance pattern detection (>80% agreement threshold)
  - Checks last 2 rounds for agreement imbalance
  - 5-question critical evaluation prompt:
    1. Potential Issues or Edge Cases
    2. What Could Go Wrong
    3. Alternative Approaches
    4. Hidden Assumptions
    5. Trade-offs
  - Visual indicator: `💡 Devil's Advocate challenge added to next round`

#### Phase 3.3: Anti-pattern Detection
- **4 Automated Quality Checks** ⚠️

  1. **Information Starvation** ⚠️
     - Detects excessive assumptions/hedging
     - Hedging keywords: probably, might be, could be, perhaps, assuming, maybe, possibly, likely, uncertain, unclear, depends on
     - Assumption keywords: assume, assumption, supposing, guessing, estimate
     - Threshold: ≥5 hedging words OR ≥3 assumptions

  2. **Rapid Turn Detection** ⏱️
     - Identifies shallow exploration through short responses
     - Threshold: <50 words for 2 consecutive rounds
     - Checks both current and previous round

  3. **Policy Trigger** 📋
     - Flags ethical/legal considerations
     - Keywords: ethics, ethical, legal, policy, regulation, regulatory, moral, compliance, privacy, gdpr, hipaa
     - Escalates to user for human judgment

  4. **Premature Convergence** 🚨
     - Detects agreement too quickly without exploring alternatives
     - Threshold: >70% agreement in ≤2 rounds
     - Warns user to consider more options

### Changed
- README.md: Added Phase 3 features table
- README.md: Updated "What's New" section
- README.md: Version bumped to 2.0.0
- USAGE.md: Added Phase 3.2 and 3.3 usage examples
- facilitator.sh:
  - Added 163 lines for anti-pattern detection
  - Added 106 lines for mid-debate user input
  - Added 117 lines for devil's advocate

### Technical Details
- **Total Lines Added**: ~386 lines of bash code
- **New Functions**: 10 detection/intervention functions
- **Integration Points**: Round 2+ loop in facilitator.sh
- **Backward Compatible**: Yes (all features are opt-in via heuristics)

### Testing
- Mock adapter tests: ✅ All passing
- Syntax validation: ✅ No errors
- Integration tests: ✅ Verified with real sessions

## [1.0.0] - 2025-10-31

### Initial Release
- Multi-model debate system (Codex, Claude, Gemini)
- Auto model selection
- 3 quality modes (simple, balanced, deep)
- Hybrid debates
- Interactive wrapper scripts (ai-debate.sh, ai-debate.cmd)
- Facilitator V2.0 with 30-line truncation optimization

---

## Legend

- 🤔 Mid-debate User Input
- 💡 Devil's Advocate
- ⚠️ Anti-pattern Detection
- 📋 Policy Trigger
- ⏱️ Rapid Turn
- 🚨 Premature Convergence
