# LangGraph TDD: Visual Guide

**Understanding Mock-First vs VCR-Based through diagrams**

---

## Traditional TDD Cycle

```
┌──────────────────────────────────────────────┐
│  RED → GREEN → REFACTOR                      │
├──────────────────────────────────────────────┤
│  1. Write failing test                       │
│     ❌ Test fails (no implementation)        │
│                                              │
│  2. Write minimal implementation             │
│     ✅ Test passes (requirement met)         │
│                                              │
│  3. Refactor and improve                     │
│     ✅ Test still passes (quality improved)  │
└──────────────────────────────────────────────┘
```

**Key Principle:** Test MUST fail first, then pass with real implementation

---

## Current Approach: Mock-First TDD

```
Day 1: MOCK PHASE
┌─────────────────────────┐
│ Write Mock              │
│ IMPLEMENTED = False     │
│ return "Mock result"    │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Write Test              │
│ assert result == "Mock" │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Run Test                │
│ ✅ PASSES               │
│ (but validates NOTHING) │
└─────────────────────────┘

Day 2: REAL IMPLEMENTATION
┌─────────────────────────┐
│ Write Real Code         │
│ IMPLEMENTED = True      │
│ llm.invoke(...)         │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Run Test                │
│ ❓ PASS or FAIL?        │
│ (first real test!)      │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ If FAIL → Debug         │
│ ❌ Time wasted          │
│ ⏰ Late feedback        │
└─────────────────────────┘
```

**Problem:** Test never had a RED phase with real implementation!

---

## Recommended Approach: VCR-Based TDD

```
Day 1: REAL IMPLEMENTATION + VCR

Step 1: Write Test (RED)
┌─────────────────────────────────┐
│ @pytest.mark.vcr()              │
│ def test_researcher():          │
│     result = researcher(state)  │
│     assert len(result) > 0      │
└───────────┬─────────────────────┘
            │
            ▼
┌─────────────────────────────────┐
│ Run Test                        │
│ ❌ FAILS                        │
│ (no implementation yet)         │
│ TRUE RED PHASE ✅               │
└─────────────────────────────────┘

Step 2: Write Real Code (GREEN)
┌─────────────────────────────────┐
│ def researcher(state):          │
│     llm = ChatOpenAI()          │
│     response = llm.invoke(...)  │
│     return response.content     │
└───────────┬─────────────────────┘
            │
            ▼
┌─────────────────────────────────┐
│ Run Test (First Time)           │
│ 📞 Calls Real API               │
│ 💾 Records to cassette          │
│ ✅ PASSES                       │
│ TRUE GREEN PHASE ✅             │
└───────────┬─────────────────────┘
            │
            ▼
┌─────────────────────────────────┐
│ Run Test (Subsequent Times)     │
│ 📼 Replays cassette             │
│ ⚡ 0.1 seconds                  │
│ ✅ PASSES                       │
│ FREE ✅                         │
└─────────────────────────────────┘
```

**Benefit:** True RED → GREEN cycle with real API validation!

---

## VCR Recording Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    FIRST TEST RUN                             │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Test Code                 VCR                Real API       │
│  ┌──────┐                ┌─────┐            ┌────────┐      │
│  │ call │────request────▶│     │───────────▶│ OpenAI │      │
│  │ node │                │ VCR │            │        │      │
│  │      │◀───response────│     │◀───────────│  GPT-4 │      │
│  └──────┘                └─────┘            └────────┘      │
│                              │                               │
│                              │                               │
│                              ▼                               │
│                        ┌──────────┐                          │
│                        │ cassette │                          │
│                        │   .yaml  │                          │
│                        └──────────┘                          │
│                        💾 RECORDED                           │
│                                                              │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                  SUBSEQUENT TEST RUNS                         │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Test Code                 VCR                               │
│  ┌──────┐                ┌─────┐            ┌────────┐      │
│  │ call │────request────▶│     │            │ OpenAI │      │
│  │ node │                │ VCR │            │        │      │
│  │      │◀───response────│     │            │  GPT-4 │      │
│  └──────┘                └─────┘            └────────┘      │
│                              ▲                   ▲           │
│                              │                   │           │
│                              │              NOT CALLED       │
│                        ┌──────────┐                          │
│                        │ cassette │                          │
│                        │   .yaml  │                          │
│                        └──────────┘                          │
│                        📼 REPLAYED                           │
│                        ⚡ 0.1 seconds                        │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Cost Comparison Over Time

```
MOCK-FIRST APPROACH
─────────────────────────────────────────────────────────────
Dev Cycle 1:  $0 (mock only)  ⏱️  0.5s
Dev Cycle 2:  $20 (real API)  ⏱️  5 min   ← First real test
Dev Cycle 3:  $20 (real API)  ⏱️  5 min
Dev Cycle 4:  $20 (real API)  ⏱️  5 min
Dev Cycle 5:  $20 (real API)  ⏱️  5 min
─────────────────────────────────────────────────────────────
Total:        $80             ⏱️  20 min + 0.5s


VCR-BASED APPROACH
─────────────────────────────────────────────────────────────
Dev Cycle 1:  $5 (record)     ⏱️  5s      ← First real test
Dev Cycle 2:  $0 (cassette)   ⏱️  0.1s    ← Replay
Dev Cycle 3:  $0 (cassette)   ⏱️  0.1s    ← Replay
Dev Cycle 4:  $0 (cassette)   ⏱️  0.1s    ← Replay
Dev Cycle 5:  $0 (cassette)   ⏱️  0.1s    ← Replay
─────────────────────────────────────────────────────────────
Total:        $5              ⏱️  5.4s

SAVINGS:      $75 (94%)       ⏱️  20 min (99%)
```

---

## Feedback Loop Comparison

```
MOCK-FIRST: Slow Feedback
═══════════════════════════════════════════════════════════════

Day 1                Day 2                Day 3
┌─────────┐         ┌─────────┐         ┌─────────┐
│ Write   │         │ Write   │         │ Find    │
│ Mock    │────────▶│ Real    │────────▶│ Bug     │
│         │         │ Code    │         │         │
│ ✅ Pass │         │ ❓ Test │         │ ❌ Fix  │
└─────────┘         └─────────┘         └─────────┘
    │                    │                    │
    └────────────────────┴────────────────────┘
           48-72 hours to real validation


VCR-BASED: Fast Feedback
═══════════════════════════════════════════════════════════════

Day 1 (Morning)     Day 1 (Afternoon)   Day 1 (Evening)
┌─────────┐         ┌─────────┐         ┌─────────┐
│ Write   │         │ Write   │         │ All     │
│ Test    │────────▶│ Real    │────────▶│ Tests   │
│         │         │ Code    │         │ Pass    │
│ ❌ Fail │         │ ✅ Pass │         │ ✅ Fast │
└─────────┘         └─────────┘         └─────────┘
    │                    │                    │
    └────────────────────┴────────────────────┘
              8 hours to validated solution
```

---

## Development Timeline Comparison

```
MOCK-FIRST: 4 Days
═══════════════════════════════════════════════════════════════

Day 1                 Day 2                 Day 3-4
├──────────────────┼──────────────────┼──────────────────┤
│                  │                  │                  │
│ Design           │ Implement        │ Debug & Fix      │
│ Write Mocks      │ Real Code        │ Integration      │
│ Test Topology    │ First Real Test  │ Issues           │
│                  │ (may fail!)      │                  │
│ ✅ Confidence:   │ ⚠️  Confidence:  │ ✅ Confidence:   │
│    100% (false)  │     40%          │    90%           │
└──────────────────┴──────────────────┴──────────────────┘
                  48-96 hours total


VCR-BASED: 3 Days
═══════════════════════════════════════════════════════════════

Day 1                 Day 2                 Day 3
├──────────────────┼──────────────────┼──────────────────┤
│                  │                  │                  │
│ Design           │ Next Node        │ Integration      │
│ Implement Real   │ Same Pattern     │ Testing          │
│ VCR Tests Pass   │ Fast & Confident │ Ready!           │
│ (real API!)      │                  │                  │
│ ✅ Confidence:   │ ✅ Confidence:   │ ✅ Confidence:   │
│    95%           │    95%           │    95%           │
└──────────────────┴──────────────────┴──────────────────┘
                    72 hours total
                    25% FASTER
```

---

## Confidence Level Over Time

```
                                        Confidence (%)
100% ┤                                     ╭─────────────────
     │                                    ╱ VCR-Based
 90% ┤                                  ╱
     │                                ╱
 80% ┤                              ╱
     │                            ╱
 70% ┤                          ╱           ╭───────────────
     │                        ╱            ╱  Mock-First
 60% ┤                      ╱            ╱
     │                    ╱            ╱
 50% ┤                  ╱            ╱
     │                ╱            ╱
 40% ┤              ╱            ╱
     │            ╱            ╱
 30% ┤          ╱            ╱
     │        ╱            ╱
 20% ┤      ╱            ╱
     │    ╱            ╱
 10% ┤  ╱            ╱
     │╱            ╱
  0% ┼───────────────────────────────────────────────────▶ Time
     Day 1      Day 2      Day 3      Day 4

     VCR:   0% → 95% in 1 day  ✅
     Mock:  100% → 40% → 70% over 4 days  ❌
            (false confidence on Day 1!)
```

---

## Test Pyramid with VCR

```
                    ┌────────────────┐
                    │    E2E Tests   │ 20%
                    │  (Real APIs)   │
                    │  Slow, Costly  │
                    └────────────────┘
                           ▲
                           │
        ┌──────────────────┴──────────────────┐
        │      Integration Tests              │ 40%
        │   (VCR Cassettes - First Run Real)  │
        │      Fast After Recording           │
        └─────────────────────────────────────┘
                           ▲
                           │
    ┌──────────────────────┴──────────────────────┐
    │           Unit Tests                        │ 40%
    │    (Mocks for pure logic only)              │
    │         Instant, Free                       │
    └─────────────────────────────────────────────┘
```

**Key:** Integration tests use VCR, so they're as fast as unit tests (after first recording)!

---

## CI/CD Pipeline Comparison

```
MOCK-FIRST CI/CD
═══════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────┐
│  git push                                               │
│     │                                                   │
│     ▼                                                   │
│  ┌────────────────┐                                    │
│  │ Run Unit Tests │  ⏱️  10s   ✅                      │
│  │ (mocks only)   │                                    │
│  └────────┬───────┘                                    │
│           │                                            │
│           ▼                                            │
│  ┌────────────────┐                                    │
│  │ Run Integration│  ⏱️  5 min  ⚠️                     │
│  │ (real API or   │  💰 $5      ⚠️                     │
│  │  skip them)    │  🔑 Need API Key ⚠️                │
│  └────────┬───────┘                                    │
│           │                                            │
│           ▼                                            │
│  ┌────────────────┐                                    │
│  │ Deploy         │                                    │
│  └────────────────┘                                    │
│                                                        │
│  Total: 5-10 minutes, $5 per run                      │
│  Problem: Either skip integration tests OR pay $$     │
└─────────────────────────────────────────────────────────┘


VCR-BASED CI/CD
═══════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────┐
│  git push                                               │
│     │                                                   │
│     ▼                                                   │
│  ┌────────────────┐                                    │
│  │ Run Unit Tests │  ⏱️  10s   ✅                      │
│  │ (mocks)        │                                    │
│  └────────┬───────┘                                    │
│           │                                            │
│           ▼                                            │
│  ┌────────────────┐                                    │
│  │ Run Integration│  ⏱️  15s   ✅                      │
│  │ (VCR cassettes)│  💰 $0     ✅                      │
│  └────────┬───────┘  🔑 No API Key ✅                  │
│           │                                            │
│           ▼                                            │
│  ┌────────────────┐                                    │
│  │ Deploy         │                                    │
│  └────────────────┘                                    │
│                                                        │
│  Total: 25 seconds, $0 per run                        │
│  Benefit: Full test coverage, fast & free! ✅         │
└─────────────────────────────────────────────────────────┘
```

---

## Node Implementation Pattern Comparison

```
MOCK-FIRST CODE STRUCTURE
═══════════════════════════════════════════════════════════

nodes/researcher.py:
┌─────────────────────────────────────────────────────────┐
│ IMPLEMENTED = False  ← Extra flag to manage             │
│                                                         │
│ def researcher_node(state):                            │
│     if not IMPLEMENTED:  ← Conditional complexity      │
│         # Mock implementation                          │
│         return state | {                               │
│             "results": ["Mock"],  ← Dead code later    │
│         }                                              │
│                                                         │
│     # Real implementation                              │
│     llm = ChatOpenAI()                                 │
│     response = llm.invoke(...)                         │
│     return state | {"results": [response.content]}     │
└─────────────────────────────────────────────────────────┘

tests/test_researcher.py:
┌─────────────────────────────────────────────────────────┐
│ def test_mock():                                        │
│     result = researcher_node(state)                    │
│     assert result == ["Mock"]  ← Tests mock output     │
│                                                         │
│ @pytest.mark.skipif(not IMPLEMENTED, ...)  ← Ugly     │
│ def test_real():                                        │
│     result = researcher_node(state)                    │
│     assert len(result) > 0                             │
└─────────────────────────────────────────────────────────┘


VCR-BASED CODE STRUCTURE
═══════════════════════════════════════════════════════════

nodes/researcher.py:
┌─────────────────────────────────────────────────────────┐
│ def researcher_node(state):  ← Clean, no flags         │
│     """Research using OpenAI GPT-4"""                   │
│     try:                                                │
│         llm = ChatOpenAI(model="gpt-4")                │
│         response = llm.invoke(f"Research: {state.q}")  │
│         return state.model_copy(update={               │
│             "results": [response.content],             │
│             "completed_branches": ...                  │
│         })                                             │
│     except Exception as e:                             │
│         return state.model_copy(update={               │
│             "errors": state.errors + [...]             │
│         })                                             │
└─────────────────────────────────────────────────────────┘

tests/test_researcher.py:
┌─────────────────────────────────────────────────────────┐
│ @pytest.mark.vcr()  ← Just add decorator               │
│ def test_researcher():                                  │
│     """Test with real API (recorded to cassette)"""    │
│     result = researcher_node(state)                    │
│     assert len(result.results) > 0  ← Real assertions  │
│     assert "quantum" in result.results[0].lower()      │
│                                                         │
│ @pytest.mark.vcr()                                      │
│ def test_researcher_empty_query():                      │
│     result = researcher_node(WorkflowState(query=""))  │
│     assert len(result.errors) == 0  ← Graceful         │
└─────────────────────────────────────────────────────────┘

CLEANER CODE:
- No IMPLEMENTED flag
- No conditional mock logic
- No dead code after implementation
- No skip decorators
- Just clean, real implementation + VCR tests
```

---

## Decision Tree

```
                    Need to test LangGraph node?
                              │
                              ▼
                ┌─────────────────────────────┐
                │  What are you testing?      │
                └─────────────┬───────────────┘
                              │
                ┌─────────────┴─────────────┐
                │                           │
                ▼                           ▼
    ┌────────────────────┐      ┌────────────────────┐
    │  Pure logic        │      │  LLM/API           │
    │  (no API calls)    │      │  integration       │
    └──────┬─────────────┘      └──────┬─────────────┘
           │                           │
           ▼                           ▼
    ┌────────────────────┐      ┌────────────────────┐
    │  Use Mock          │      │  Use VCR           │
    │  ✅ Fast (0.1s)    │      │  ✅ Real (Day 1)   │
    │  ✅ Free           │      │  ✅ Fast (0.1s)    │
    │  ✅ Simple         │      │  ✅ Cost ($5 once) │
    └────────────────────┘      └────────────────────┘
           │                           │
           ▼                           ▼
    @patch('...')              @pytest.mark.vcr()
```

**Rule of thumb:**
- **Mock:** Pure logic, calculations, routing decisions
- **VCR:** Anything that calls external APIs (LLM, web, database)

---

## Summary Visualization

```
╔═══════════════════════════════════════════════════════════╗
║            WHY VCR-BASED TDD IS BETTER                    ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  1. TRUE TDD                                              ║
║     Mock: ✅ Pass → ✅ Pass (never fails!)                ║
║     VCR:  ❌ Fail → ✅ Pass (real RED-GREEN cycle)        ║
║                                                           ║
║  2. REAL VALIDATION                                       ║
║     Mock: Tests your assumptions                          ║
║     VCR:  Tests actual API behavior                       ║
║                                                           ║
║  3. FAST FEEDBACK                                         ║
║     Mock: 0.5s always                                     ║
║     VCR:  5s first run, 0.1s thereafter (faster!)        ║
║                                                           ║
║  4. COST EFFICIENT                                        ║
║     Mock: $0 but no validation                            ║
║     VCR:  $2-5 once, then free forever                   ║
║                                                           ║
║  5. CI/CD FRIENDLY                                        ║
║     Mock: Fast but skips integration tests                ║
║     VCR:  Fast AND tests real integration                 ║
║                                                           ║
║  6. CLEANER CODE                                          ║
║     Mock: IMPLEMENTED flags, conditional logic            ║
║     VCR:  Just real code, no flags                        ║
║                                                           ║
║  7. HIGHER CONFIDENCE                                     ║
║     Mock: 60% (tested assumptions only)                   ║
║     VCR:  95% (tested real behavior)                      ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

## Migration Path Visualization

```
FROM: Mock-First
┌─────────────────────────────────────────────────────────┐
│  nodes/researcher.py:                                   │
│    IMPLEMENTED = False  ❌                              │
│    if not IMPLEMENTED: return mock                      │
│                                                         │
│  tests/test_researcher.py:                              │
│    @pytest.mark.skipif(not IMPLEMENTED)  ❌             │
│    assert result == ["Mock"]  ❌                        │
└─────────────────────────────────────────────────────────┘
                           │
                           │ MIGRATION (2 hours per node)
                           ▼
TO: VCR-Based
┌─────────────────────────────────────────────────────────┐
│  nodes/researcher.py:                                   │
│    # No IMPLEMENTED flag ✅                             │
│    # Just real code ✅                                  │
│                                                         │
│  tests/test_researcher.py:                              │
│    @pytest.mark.vcr()  ✅                               │
│    assert len(result.results) > 0  ✅                   │
│                                                         │
│  tests/cassettes/test_researcher.yaml:  ✅              │
│    # Recorded API responses                             │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
                    BENEFITS
                           │
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
   ⚡ Faster          💰 Cheaper          ✅ Confident
   (25% time)        (93% cost)          (95% vs 60%)
```

---

## The Bottom Line (Visual)

```
                    User's Question
                         │
        "Mock 말고 실제 API로 테스트해야 하는 거 아닌가?"
        "Shouldn't we test with real APIs?"
                         │
                         ▼
                  ┌──────────────┐
                  │   ANSWER:    │
                  │     YES!     │
                  │  User is     │
                  │   CORRECT    │
                  └──────┬───────┘
                         │
                         ▼
                 ┌───────────────┐
                 │   Solution:   │
                 │   VCR-Based   │
                 │      TDD      │
                 └───────┬───────┘
                         │
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
    Real API      Cassette        Best of
   Validation     Replay         Both Worlds
   (Day 1)        (0.1s)         (✅ ✅ ✅)
```

---

**Remember:**

```
╔════════════════════════════════════════╗
║  VCR = Real validation + Mock speed    ║
╚════════════════════════════════════════╝
```

---

**Print these diagrams for your team!**

They make the concept crystal clear and help everyone understand why VCR-based TDD is the right approach for LangGraph projects.
