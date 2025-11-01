# Quality Gate Checklist

**Run before finalizing any debate**

This checklist ensures the debate outcome meets minimum quality standards. All items must be addressed (either satisfied or explicitly documented as N/A with justification).

---

## 1. Assumptions Verification

**Question:** Have all assumptions been verified or explicitly marked as assumptions?

**Check:**
- [ ] All factual claims have supporting evidence OR marked as assumptions
- [ ] Assumption:fact ratio ≤ 2:1
- [ ] Each assumption has confidence level (Tier 1/2/3)
- [ ] Critical assumptions are highlighted

**If NO:**
- List unverified claims: _______________
- Action: Either verify or mark as assumptions with confidence penalty

---

## 2. User Constraints Honored

**Question:** Are all user-specified constraints respected in the solution?

**Check:**
- [ ] Technical constraints (language, framework, platform)
- [ ] Budget constraints
- [ ] Timeline constraints
- [ ] Team capability constraints
- [ ] Business/policy constraints

**If NO:**
- Which constraints violated: _______________
- Action: Revise solution or explain why constraint must be relaxed

---

## 3. Risks Surfaced

**Question:** Have potential risks been identified and mitigation strategies proposed?

**Check:**
- [ ] Technical risks identified
- [ ] Implementation risks identified
- [ ] Operational risks identified
- [ ] Business risks identified
- [ ] Each risk has: Impact (H/M/L), Probability (H/M/L), Mitigation strategy

**If NO:**
- Missing risk categories: _______________
- Action: Conduct stress pass, enumerate failure modes

---

## 4. Next Actions Concrete

**Question:** Are next steps specific, actionable, and executable?

**Check:**
- [ ] Each action has: What, Who (role), When (sequence)
- [ ] Success criteria defined for each action
- [ ] Dependencies between actions identified
- [ ] No vague actions like "improve performance" or "consider security"

**Example of GOOD:**
- ✅ "Add B-tree index on users.email column (DBA, immediate)"
- ✅ "Load test with 10k concurrent users, target <500ms p95 (QA, after index added)"

**Example of BAD:**
- ❌ "Optimize queries"
- ❌ "Think about caching"

**If NO:**
- Vague actions: _______________
- Action: Make actions SMART (Specific, Measurable, Actionable, Relevant, Time-bound)

---

## 5. Confidence Level Explicit

**Question:** Is overall confidence level stated with justification?

**Check:**
- [ ] Confidence level stated (e.g., "75% confident")
- [ ] Justification explains why (evidence quality, assumption count, etc.)
- [ ] Validation steps proposed for low-confidence elements
- [ ] User understands what could change recommendation

**Confidence Calibration:**
- **High (80-100%)**: Strong evidence (Tier 1), ≤2 minor assumptions, validated approach
- **Medium (50-79%)**: Mixed evidence (Tier 1-2), some assumptions, reasonable approach
- **Low (30-49%)**: Weak evidence (Tier 2-3), many assumptions, untested approach
- **Very Low (<30%)**: Mostly assumptions (Tier 3), speculative

**If NO:**
- Add confidence level: ___%
- Justify based on: _______________

---

## 6. Coverage Completeness (V3.0 Specific)

**Question:** Have critical dimensions been addressed?

**Check Coverage Matrix:**
- [ ] Architecture (if system design)
- [ ] Security (if handling data/auth)
- [ ] Performance (if scalability concern)
- [ ] Testing (always critical)
- [ ] Ops (if deployment/infrastructure)
- [ ] Cost (if budget-sensitive)
- [ ] Compliance (if regulated domain)
- [ ] UX (if user-facing)

**Minimum Requirements:**
- ≥3 critical dimensions addressed
- ≥5 total dimensions addressed

**If NO:**
- Missing critical dimensions: _______________
- Action: Address or document why N/A

---

## 7. Evidence Quality (V3.0 Specific)

**Question:** Is evidence quality sufficient for confidence level?

**Check:**
- [ ] Tier 1 evidence (90-100%): Code, benchmarks, docs
- [ ] Tier 2 evidence (60-80%): Analogies, best practices
- [ ] Tier 3 evidence (30-50%): Assumptions only

**Evidence-Confidence Alignment:**
- High confidence requires ≥70% Tier 1 evidence
- Medium confidence requires ≥50% Tier 1-2 evidence
- Low confidence accepts Tier 3 evidence with caveats

**If NO:**
- Evidence tier breakdown: T1=__% T2=__% T3=__%
- Action: Either gather better evidence or lower confidence

---

## 8. Stress Test Completed (V3.0 Specific)

**Question:** Has the last endorser enumerated failure modes?

**Check:**
- [ ] Stress pass conducted before consensus
- [ ] ≥3 failure modes identified
- [ ] Each failure mode has mitigation OR documented as accepted risk

**If NO:**
- Action: Conduct stress pass now

**Stress Pass Template:**
"You endorsed [solution]. Now enumerate failure modes:
1. What could go wrong?
2. What are we missing?
3. What assumptions might be wrong?
4. What changes would invalidate this recommendation?"

---

## Final Gate Decision

**Pass Criteria:** All 8 checks satisfied OR explicitly documented as N/A with justification

**If PASS:**
- ✅ Proceed to finalization
- Generate debate report
- Log structured data for playbook

**If FAIL:**
- ❌ Block finalization
- Return to debate with specific issues to address
- Document blockers for user

**User Override:**
User can override quality gate with `/debate-override Finalize despite quality gate` but this is logged and may affect playbook generation.

---

## Quality Gate Log

**Debate ID:** _______________
**Date:** _______________
**Facilitator:** V3.0

**Results:**
1. Assumptions: ☐ Pass ☐ Fail ☐ N/A
2. Constraints: ☐ Pass ☐ Fail ☐ N/A
3. Risks: ☐ Pass ☐ Fail ☐ N/A
4. Actions: ☐ Pass ☐ Fail ☐ N/A
5. Confidence: ☐ Pass ☐ Fail ☐ N/A
6. Coverage: ☐ Pass ☐ Fail ☐ N/A
7. Evidence: ☐ Pass ☐ Fail ☐ N/A
8. Stress Test: ☐ Pass ☐ Fail ☐ N/A

**Overall:** ☐ PASS ☐ FAIL (Override: ☐ Yes ☐ No)

**Facilitator Notes:**
_______________
_______________
_______________
