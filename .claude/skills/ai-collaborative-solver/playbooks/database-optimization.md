# Playbook: Database Query Optimization

**Generated:** 2025-10-31
**Expiry:** 2025-12-30 (60 days)
**Source Debates:** [Example seed - will be populated from real debates]
**Success Rate:** N/A (newly seeded)
**Confidence:** Medium (60-75% typical)

---

## Problem Signature

**When to use this playbook:**
- Application experiencing slow database queries
- Response times degrading as data grows
- N+1 query problems
- ORM performance issues
- Database becoming bottleneck

**Keywords:**
- "slow queries", "database performance", "N+1", "ORM", "query optimization", "indexing", "caching"

**Problem characteristics:**
- Performance degradation over time
- Often related to ORM usage
- Scale-dependent (works fine at small scale)
- Multiple potential causes

**Domains:**
- Web development, API development, backend engineering

---

## Key Questions to Explore

### 1. Current State Analysis
- What's the current query performance? (actual metrics, not feelings)
- How many queries per request?
- Are there N+1 patterns?
- What's the data volume?
- What's the expected scale (3 months, 1 year)?

### 2. Infrastructure
- Current database (PostgreSQL, MySQL, MongoDB, etc.)?
- Existing indexes?
- Connection pooling setup?
- Caching layer present?

### 3. Code Patterns
- ORM used (Django, SQLAlchemy, ActiveRecord, etc.)?
- Raw SQL or ORM queries?
- Eager loading implemented?
- Pagination present?

---

## Common Tradeoffs

### Tradeoff 1: Indexes vs Write Performance
**Choice:** Add indexes vs Keep writes fast

**Add indexes when:**
- Read-heavy workload (>80% reads)
- Slow queries identified on specific columns
- Acceptable write latency increase (<10%)

**Skip indexes when:**
- Write-heavy workload
- Columns change frequently
- Table size small (<10k rows)

**Past decisions breakdown:**
- Add indexes: ~75% of cases
- Skip indexes: ~25% of cases

### Tradeoff 2: Eager Loading vs Lazy Loading
**Choice:** Load everything upfront vs Load on demand

**Eager loading when:**
- Accessing related data is certain
- N+1 problem confirmed
- Data relationships are bounded (not unbounded lists)

**Lazy loading when:**
- Related data rarely accessed
- Relationships are very large (thousands of items)
- Memory constrained

### Tradeoff 3: Application Caching vs Database Optimization
**Choice:** Add Redis/Memcached vs Fix queries

**Fix queries first when:**
- Queries are objectively bad (missing indexes, N+1)
- Data changes frequently
- Cache invalidation would be complex

**Add caching when:**
- Queries are already optimized
- Data is relatively static
- Read:write ratio very high (>100:1)

---

## Evidence Sources

**Tier 1 Evidence (Prefer):**
- Actual database query logs (EXPLAIN ANALYZE output)
- APM metrics (New Relic, DataDog, etc.)
- Database profiling data
- Benchmarks from actual codebase

**Tier 2 Evidence (Acceptable):**
- ORM documentation (Django docs, SQLAlchemy docs)
- Database documentation (PostgreSQL performance tips)
- Industry benchmarks for similar scale

**Common Assumptions (Mark as Tier 3):**
- "Users will complain at >2s response time"
- "10x growth expected in next year"
- "Team can maintain complex caching layer"

---

## Typical Solutions

**Solution Pattern A: Index Addition**
- **When:** Missing indexes on foreign keys or filter columns
- **Pros:** Immediate impact, low risk, easy to implement
- **Cons:** Slightly slower writes, storage overhead
- **Confidence:** High (85-95%) if indexes are clearly missing
- **Success stories:** Most common fix, ~80% of optimization cases

**Solution Pattern B: Eager Loading (ORM)**
- **When:** N+1 query pattern confirmed
- **Pros:** Reduces queries dramatically, minimal code change
- **Cons:** May load unused data, memory increase
- **Confidence:** High (80-90%) for bounded relationships
- **Success stories:** ~60% of Django/Rails optimizations

**Solution Pattern C: Query Caching**
- **When:** Read-heavy, data relatively static
- **Pros:** Dramatic speedup possible, offloads DB
- **Cons:** Cache invalidation complexity, infrastructure needed
- **Confidence:** Medium (60-75%) depending on invalidation strategy
- **Success stories:** ~40% of cases, after query optimization

**Solution Pattern D: Pagination**
- **When:** Loading large datasets without limits
- **Pros:** Predictable performance, better UX
- **Cons:** Requires UI changes, offset-based pagination has issues at scale
- **Confidence:** High (85%) for improving perceived performance
- **Success stories:** Standard practice, ~90% of list views

---

## Common Pitfalls

1. **Premature Caching**
   - Description: Adding Redis before fixing bad queries
   - How to avoid: Always optimize queries first (indexes, N+1 fixes)
   - Seen in: ~30% of debates

2. **Over-indexing**
   - Description: Adding indexes on every column "just in case"
   - How to avoid: Index based on actual query patterns, measure impact
   - Seen in: ~20% of debates

3. **Ignoring Connection Pooling**
   - Description: Optimizing queries while opening new connections constantly
   - How to avoid: Check connection pool settings early
   - Seen in: ~25% of debates

4. **Assuming Scale Without Data**
   - Description: Over-engineering for "millions of users" when at 100
   - How to avoid: Optimize for 10x current scale, not 1000x
   - Seen in: ~35% of debates

---

## Coverage Dimensions

**Critical for this problem type:**
- Performance (obviously)
- Testing (must validate improvements)
- Ops (monitoring query performance)

**Often relevant:**
- Architecture (query patterns, data access layer)
- Cost (larger instances if optimization fails)

**Usually N/A:**
- UX (unless pagination changes UI)
- Compliance (unless caching user data)

---

## Recommended Mode

**Default mode:** balanced

**Reasoning:**
- Need to explore 2-3 approaches (indexes, eager loading, caching)
- But also need concrete implementation plan
- Balanced mode provides both

**Override to execution when:**
- Problem is clearly N+1 (obvious fix)
- Missing index on foreign key (obvious fix)

**Override to exploration when:**
- Complex data model with many optimization paths
- Unclear what's causing slowness

---

## Past Debate References

**High-quality debates:**
[To be populated from real debates]

**Failed debates (learning opportunities):**
[To be populated from real debates]

---

## Success Metrics

**What makes this solution successful:**
- Query time: Target <100ms for p95
- Queries per request: Target <10
- Response time: Target <500ms for API endpoints
- Throughput: Handle 10x current load

**Typical implementation time:** 2-8 hours (indexes), 1-3 days (caching)

**Typical confidence range:** 70-90%

---

## Validation Checklist

Before finalizing recommendation for database optimization:

- [ ] Actual query metrics provided (not guesses)
- [ ] Database type and version confirmed
- [ ] Current scale and expected growth clarified
- [ ] Existing indexes reviewed
- [ ] N+1 pattern explicitly checked
- [ ] Connection pooling verified
- [ ] Standard quality gate checks

---

## Expiry & Re-validation

**Expiry date:** 2025-12-30

**Re-validation triggers:**
- Date expired
- Major ORM version changes (e.g., Django 5.0, SQLAlchemy 2.0)
- New database features (e.g., PostgreSQL auto-vacuum improvements)

**Re-validation process:**
1. Review recent database optimization debates
2. Update with new ORM best practices
3. Incorporate new caching strategies
4. Reset expiry date

---

## Metadata

**Playbook ID:** db-opt-001
**Version:** 1.0
**Status:** active (seeded)
**Creator:** human_seeded
**Validation status:** draft (needs real debate data)
**Tags:** performance, database, optimization, N+1, ORM

---

## Change Log

**v1.0 - 2025-10-31**
- Initial playbook seeded manually for V3.0 demonstration
- Will be updated with actual debate data as debates occur

---

## Notes

This is a seed playbook created to demonstrate the playbook structure. It will be enriched with data from actual debates matching this pattern.

**Common debate flow for this problem:**
1. Round 1: Investigate metrics → Identify N+1 or missing indexes
2. Round 2: Codex reality-checks scale needs → Avoid over-engineering
3. Round 3: Converge on phased approach (indexes first, then caching if needed)
