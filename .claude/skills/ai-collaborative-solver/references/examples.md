# AI Collaborative Solver - Additional Examples

This document contains detailed examples demonstrating various use cases of the AI Collaborative Solver skill.

For basic examples, see the main [SKILL.md](../SKILL.md#examples) documentation.

---

## Example 2: Specify Gemini (Latest Trends)

**Input:**
```bash
./ai-debate.sh "2025년 Next.js 최신 베스트 프랙티스" --model gemini --search
```

**What happens:**
1. Gemini selected (specified)
2. Google Search enabled (--search)
3. Finds latest Next.js 15 documentation
4. Cites sources in report

**Use case:**
- Technology trend research
- Latest framework/library updates
- Current industry practices
- Finding documentation for new releases

---

## Example 3: Claude for Writing

**Input:**
```bash
./ai-debate.sh "Write API documentation for payment endpoint" --model claude --mode balanced
```

**What happens:**
1. Keywords detected: "write" + "documentation" → Claude
2. Claude excels at clear, structured writing
3. Produces well-organized documentation
4. Multiple refinement rounds improve clarity

**Output example:**
```markdown
# Payment API Endpoint Documentation

## Overview
This endpoint processes payment transactions with PCI DSS compliance.

## Endpoint
POST /api/v1/payments

## Request Format
{
  "amount": 1000,
  "currency": "USD",
  "payment_method": "card",
  "customer_id": "cus_xyz"
}

## Response Format
{
  "transaction_id": "tx_123",
  "status": "success",
  "timestamp": "2025-10-31T10:30:00Z"
}

## Error Handling
...
```

**Use case:**
- Technical documentation writing
- API specification creation
- Clear explanations and tutorials
- Well-structured content generation

---

## Example 4: Hybrid (Critical Decision)

**Input:**
```bash
./ai-debate.sh "Microservices vs Monolith for e-commerce" --models codex,claude,gemini --mode deep
```

**What happens:**
1. All three models analyze in parallel:
   - **Codex**: Technical implementation details
   - **Claude**: Reasoning about trade-offs
   - **Gemini**: Latest industry trends (2025)

2. Each model provides independent analysis:
   - **Codex perspective:** Code/architecture focus, implementation complexity
   - **Claude perspective:** Thoughtful trade-off analysis, team dynamics
   - **Gemini perspective:** Current trends (2025), cloud-native patterns

3. Hybrid orchestrator combines perspectives
4. Generates comprehensive synthesis report

**Output:**
```markdown
## Codex Analysis
**Recommendation:** Start with modular monolith
**Confidence:** 80%
**Reasoning:**
- Team size (5 developers) better suited for monolith
- Faster development velocity initially
- Reduced operational complexity
- Clear module boundaries enable future migration

**Implementation:**
1. Design clear module boundaries
2. Use dependency injection
3. Implement service interfaces
4. Plan for eventual extraction

## Claude Analysis
**Recommendation:** Modular monolith with migration plan
**Confidence:** 85%
**Reasoning:**
- Balanced approach reduces initial risk
- Provides clear path to microservices
- Allows team to learn patterns gradually
- Lower infrastructure costs initially

**Trade-offs:**
- Initial simplicity vs. long-term scalability
- Development speed vs. operational complexity
- Team learning curve vs. future flexibility

## Gemini Analysis
**Recommendation:** Microservices with service mesh
**Confidence:** 75%
**Reasoning:**
- 2025 trend: Cloud-native from start
- Modern tooling (Kubernetes, Istio) reduces complexity
- Industry shift toward distributed systems
- Better alignment with modern practices

**Current trends (2025):**
- Service mesh adoption: 65% of new projects
- Kubernetes native development
- Serverless integration patterns

## Synthesis
**Consensus:** Phased approach (monolith → microservices)

**Agreement:**
- All three models agree: Start simple, plan for migration
- Modular monolith provides best balance
- Clear boundaries essential for future extraction

**Key difference:**
- Timeline: Claude suggests 18 months before migration, Codex/Gemini suggest 12 months
- Approach: Gemini emphasizes cloud-native patterns from day 1

**Final Recommendation:**
1. **Phase 1 (Months 1-12):** Modular monolith
   - Design clear service boundaries
   - Use async messaging patterns
   - Implement feature flags
   - Deploy to cloud with container orchestration

2. **Phase 2 (Months 12-18):** Evaluate and extract
   - Identify high-load modules
   - Extract as microservices gradually
   - Implement service mesh if needed
   - Monitor and iterate

**Confidence:** 88% (combined consensus)
```

**Use case:**
- Critical business decisions
- Comprehensive analysis from multiple perspectives
- Validating assumptions
- Building consensus on complex topics
- Understanding trade-offs from different angles

---

**Back to:** [Main Documentation](../SKILL.md)
