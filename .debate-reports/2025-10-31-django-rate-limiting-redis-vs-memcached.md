# Debate Report: Django API Rate Limiting - Redis vs Memcached (10k req/sec)

**Date:** 2025-10-31
**Participants:** Claude (Anthropic) vs Codex (OpenAI GPT-5)
**Rounds:** 1 (Brief debate as requested)
**Thread ID:** 019a3931-643d-70c2-8692-b1953d13a848

---

## Problem Statement

**Scenario:** Django REST API handling ~10,000 requests/second
**Question:** Should we use Redis or Memcached as the backend store for rate limiting?
**Context:** Django 4.x, PostgreSQL, need reliable rate limiting to prevent abuse

---

## Round 1: Initial Positions

### Claude's Initial Analysis

**Recommendation:** Redis

**Key Arguments:**
1. **Atomic Operations**: `INCR` with `EXPIRE` in pipelines for accurate counting
2. **Persistence**: Can survive restarts, maintaining rate limit state
3. **Data Structures**: Sorted sets for sliding window algorithms
4. **Django Ecosystem**: Better integration (django-ratelimit, django-redis)
5. **TTL Precision**: Millisecond-level expiration control

**Acknowledged Memcached Strengths:**
- 10-15% faster for simple key-value operations
- Better memory efficiency for pure caching
- Simpler operational model

### Codex's Response (Critical Analysis)

**Nuanced Position:** Redis is safer, but not for all of Claude's stated reasons.

**Key Corrections:**

1. **Atomicity Overstatement**
   - Memcached's `incr` IS atomic
   - Real gap: Redis can bundle `INCR`+`EXPIRE` (Lua scripts) to prevent orphaned hot keys
   - Memcached requires pre-creating keys with TTLs or accepting small races

2. **Persistence Red Herring**
   - Rate-limit counters are ephemeral by definition
   - Losing them on restart just resets limits (acceptable)
   - Redis persistence is nice for mixed workloads, but not critical here

3. **TTL Granularity Critical**
   - Memcached: 1-second TTL granularity → coarse fixed windows
   - Redis: Millisecond precision → better for bursty workloads
   - Matters significantly at 10k req/sec

4. **Throughput Reality Check**
   - Both can handle 10k ops/sec comfortably (<1ms latency)
   - 10-15% speed difference unlikely to matter at this scale
   - Risk is client jitter, not CPU limits

5. **Operational Trade-offs**
   - **Memcached simpler**: No replication elections, no persistence backlog
   - **Redis better tooling**: Built-in clustering, replication, Sentinel
   - At 10k req/sec with 20+ workers, Redis clustering advantage is significant

6. **Alternative Approach**
   - **Edge layer rate limiting** (Envoy/NGINX/Cloudflare)
   - Already have Redis-like stores + sliding windows + observability
   - **Two-tier approach**: Edge for coarse limits + Django/Redis for fine-grained

---

## Consensus Solution

### Agreed Framework

**Use Redis when:**
- ✅ Bursty traffic patterns (millisecond precision needed)
- ✅ Multiple Django workers (20+) requiring distributed coordination
- ✅ Complex algorithms (sliding window, token bucket)
- ✅ Already using Redis for caching/sessions

**Use Memcached when:**
- ✅ Coarse rate limits acceptable (per-second granularity sufficient)
- ✅ Small deployment (single cache instance)
- ✅ Minimal infrastructure desired
- ✅ Only simple counters needed

### Recommended Architecture (Best Practice)

**Two-Tier Approach:**

1. **Edge Layer** (Envoy/Cloudflare/NGINX)
   - Coarse limits: 100 requests/sec per IP
   - Built-in sliding windows
   - Minimal latency overhead
   - DDoS protection

2. **Application Layer** (Django + Redis)
   - Fine-grained business logic: 10 API calls/user/minute
   - Complex rules: different limits per endpoint/user tier
   - Millisecond precision for fairness
   - Integration with Django auth/permissions

**Why this works:**
- Edge stops brute force attacks before hitting Django
- Application layer enforces business rules Redis excels at
- Best of both worlds: performance AND precision

---

## Key Insights

### What Claude Got Right
- Redis ecosystem stronger for Django
- TTL precision matters at scale
- Data structures enable sophisticated algorithms

### What Codex Corrected
- Both have atomic operations (not Redis-only)
- Persistence not critical for rate limiting specifically
- Edge layer rate limiting often better than in-app
- Memcached's simplicity can be advantage in right scenario

### Critical Decision Factors

1. **Traffic Pattern**: Bursty → Redis; Steady → Either
2. **Scale**: 20+ workers → Redis clustering; Single instance → Either
3. **Precision**: Sub-second fairness → Redis; Coarse OK → Either
4. **Existing Stack**: Already using Redis → Redis; Greenfield → Consider edge layer

---

## Implementation Guidance

### If Choosing Redis

```python
# settings.py
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}

# Using django-ratelimit
from django_ratelimit.decorators import ratelimit

@ratelimit(key='user', rate='10/m', method='POST')
def api_endpoint(request):
    # Sliding window, millisecond precision
    pass
```

### If Choosing Memcached

```python
# settings.py
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.PyMemcacheCache',
        'LOCATION': '127.0.0.1:11211',
    }
}

# Note: Use fixed window (1-second granularity)
# Pre-create keys with TTL to avoid orphaned counters
```

### Edge Layer (Recommended First Step)

```nginx
# NGINX example
limit_req_zone $binary_remote_addr zone=api:10m rate=100r/s;

location /api/ {
    limit_req zone=api burst=20 nodelay;
    proxy_pass http://django_backend;
}
```

---

## Conclusion

**Winner:** Redis for most Django use cases, BUT edge layer rate limiting should be evaluated first.

**Tradeoffs Acknowledged:**
- Memcached simpler operationally but lacks precision at scale
- Redis adds complexity but necessary for 10k req/sec with bursty traffic
- Edge layer solution (Envoy/Cloudflare) often superior to both

**Final Recommendation:**
1. Start with edge layer rate limiting if possible
2. If in-app required, use Redis for 10k req/sec scale
3. Only use Memcached if deployment is simple AND coarse limits acceptable

---

**Token Usage:**
- Round 1: 3,610 input (3,072 cached) + 1,605 output = 5,215 tokens
- Debate approach: Stateful session (67% token savings vs stateless)

**Session:** Completed and cleaned up
