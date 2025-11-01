# Example: Auto Model Selection

## Problem

"코드 리뷰 필요: Django 인증 모듈"

## Command

```bash
./ai-debate.sh "코드 리뷰 필요: Django 인증 모듈" --auto --mode balanced
```

## What Happens

### Step 1: Keyword Analysis

```
Keywords detected:
- "코드 리뷰" → Code review indicator
- "Django" → Framework (technical)
- "인증" → Authentication (security)

Match: Code review pattern
→ Auto-select: Codex
```

### Step 2: Model Selected

```
Model: codex (auto-selected)
Reason: Code review + technical analysis
Mode: balanced (4 rounds)
```

### Step 3: Debate Execution

```
Round 1: Explorer (Codex)
- Analyzes Django authentication patterns
- Identifies 3-5 approaches

Round 2: Critic (Codex)
- Reality-checks each approach
- Points out Django-specific issues

Round 3: Synthesizer (Codex)
- Recommends best approach
- Provides implementation steps

Round 4: Security Analyst (Codex)
- Analyzes security implications
- Suggests mitigations
```

### Step 4: Output

```markdown
## Codex Analysis

### Recommended Solution
Use Django's built-in authentication with custom user model

**Confidence:** 85%

### Key Rationale
1. Django auth is battle-tested
2. Custom user model provides flexibility
3. Follows Django best practices

### Implementation Steps
1. Create custom User model (AbstractBaseUser)
2. Configure AUTH_USER_MODEL in settings
3. Add custom fields (phone, avatar, etc.)
4. Create authentication backends
5. Set up JWT tokens for API

### Risks & Mitigations
1. **Risk:** Migration complexity
   **Mitigation:** Start with custom user from day 1

2. **Risk:** Token security
   **Mitigation:** Use httpOnly cookies + CSRF

3. **Risk:** Password reset flows
   **Mitigation:** Use django-allauth

**Report:** .debate-reports/2025-10-31-XX-XX-ai-debate-codex.md
```

---

## Why Codex Was Selected

✅ **Correct choice because:**
- Problem involves **code review**
- Requires **Django expertise** (framework-specific)
- Security analysis needed (code-level)
- Implementation details required

❌ **Gemini would be wrong because:**
- Not code-focused
- Wouldn't provide Django-specific details
- Better for trends, not implementation

---

## Alternative: Manual Override

If you wanted Gemini instead (for research):

```bash
./ai-debate.sh "Django 인증 2025년 최신 트렌드" --model gemini --search
```

This would research **latest Django auth trends**, not review code.

---

## Hybrid: Both Models

```bash
./ai-debate.sh "Django vs FastAPI authentication" --models codex,gemini
```

**Output:**
- **Codex**: Technical implementation comparison
- **Gemini**: 2025 adoption trends, community feedback
- **Synthesis**: Best-of-both recommendation
