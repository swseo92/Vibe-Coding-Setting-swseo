# Template: Search Feature

Pattern for adding full-text search (ElasticSearch, PostgreSQL FTS, etc.).

---

## Canonical Subtasks

### 1. search-infrastructure (1d)
**Goal**: Set up search engine

**Options**:
- **ElasticSearch**: Powerful, scalable (separate service)
- **PostgreSQL Full-Text Search**: Built-in, simpler
- **Algolia**: Hosted, easy integration

**Files**:
- `config.py` - Search engine connection
- `.env` - Connection URL
- `docker-compose.yml` - ElasticSearch service (if self-hosted)

**Example (ElasticSearch)**:
```python
from elasticsearch import Elasticsearch

es = Elasticsearch([settings.ELASTICSEARCH_URL])
```

**Dependency**: None

**Risk**: MEDIUM (infrastructure dependency)

---

### 2. search-indexing (1d)
**Goal**: Index data into search engine

**Files**:
- `services/search_indexer.py` - Indexing logic
- `tasks.py` - Background indexing tasks

**Django Example**:
```python
from elasticsearch_dsl import Document, Text, Date

class ProductDocument(Document):
    name = Text()
    description = Text()
    price = Float()
    created_at = Date()

    class Index:
        name = 'products'

    def save(self, **kwargs):
        # Index on save
        return super().save(**kwargs)
```

**FastAPI Example**:
```python
def index_product(product: Product):
    doc = {
        "name": product.name,
        "description": product.description,
        "price": product.price
    }
    es.index(index="products", id=product.id, document=doc)
```

**Indexing Strategies**:
- **Real-time**: Index on save (Django signals, SQLAlchemy events)
- **Batch**: Periodic background job (Celery)
- **Bulk**: Initial index + periodic full reindex

**Dependency**: search-infrastructure

---

### 3. search-api (1d)
**Goal**: Search endpoint

**Files (Django)**: `views.py`, `urls.py`
**Files (FastAPI)**: `routers/search.py`

**Endpoint**: `GET /search?q={query}&filter={filter}`

**Example (FastAPI)**:
```python
@router.get("/search")
async def search_products(
    q: str,
    category: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    limit: int = 20
):
    query = {
        "query": {
            "bool": {
                "must": [
                    {"multi_match": {"query": q, "fields": ["name", "description"]}}
                ],
                "filter": []
            }
        }
    }

    if category:
        query["query"]["bool"]["filter"].append({"term": {"category": category}})
    if min_price:
        query["query"]["bool"]["filter"].append({"range": {"price": {"gte": min_price}}})

    results = es.search(index="products", body=query, size=limit)
    return [hit["_source"] for hit in results["hits"]["hits"]]
```

**Features**:
- Full-text search
- Filters (category, price range)
- Pagination
- Sorting (relevance, price, date)
- Fuzzy matching

**Dependency**: search-indexing

---

### 4. search-sync (0.5d)
**Goal**: Keep search index in sync with database

**Files**:
- `signals.py` (Django) - Auto-index on save/delete
- `tasks.py` - Periodic full reindex

**Django Signals Example**:
```python
from django.db.models.signals import post_save, post_delete

@receiver(post_save, sender=Product)
def index_product_on_save(sender, instance, **kwargs):
    ProductDocument(
        meta={'id': instance.id},
        name=instance.name,
        description=instance.description
    ).save()

@receiver(post_delete, sender=Product)
def delete_product_from_index(sender, instance, **kwargs):
    ProductDocument.get(id=instance.id).delete()
```

**Periodic Reindex**:
```python
@celery_app.task
def reindex_all_products():
    # Clear index
    es.indices.delete(index="products", ignore=[400, 404])

    # Bulk index
    for product in Product.objects.all():
        index_product(product)
```

**Dependency**: search-api

---

### 5. search-tests (0.5d)
**Goal**: Test search functionality

**Files**: `tests/test_search.py`

**Test Cases**:
- [ ] Search returns relevant results
- [ ] Filters work correctly
- [ ] Pagination works
- [ ] Empty query handled
- [ ] No results handled
- [ ] Special characters escaped

**Mock vs Real**:
- **Unit tests**: Mock ElasticSearch
- **Integration tests**: Use test ElasticSearch instance

**Dependency**: search-sync

---

## Dependency Graph

```
1. infrastructure → 2. indexing → 3. api → 4. sync → 5. tests
```

**Sequential**: All steps must be sequential

---

## Search Engine Comparison

| Feature | ElasticSearch | PostgreSQL FTS | Algolia |
|---------|---------------|----------------|---------|
| **Setup** | Complex (separate service) | Simple (built-in) | Easy (hosted) |
| **Scalability** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Features** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Cost** | Free (self-hosted) | Free (included) | $$$  (paid) |
| **Best For** | Large scale | Small-medium projects | Fast time-to-market |

---

## Common Pitfalls

1. **No Index Updates**: DB changes not reflected in search → Use signals or periodic reindex
2. **Slow Queries**: Searching entire text → Add filters, limits
3. **Stale Index**: Index out of sync → Monitor lag, reindex periodically
4. **No Fuzzy Matching**: Typos return no results → Enable fuzzy search
5. **Poor Relevance**: Random result order → Tune boosting, scoring
6. **Missing Pagination**: Returning all results → Always paginate

---

## PostgreSQL Full-Text Search Example

**Simple Alternative to ElasticSearch**:

```python
# Django ORM
from django.contrib.postgres.search import SearchVector, SearchQuery

Product.objects.annotate(
    search=SearchVector('name', 'description')
).filter(
    search=SearchQuery('laptop')
)

# Create index for performance
# Migration:
operations = [
    migrations.RunSQL(
        "CREATE INDEX product_search_idx ON products USING GIN(to_tsvector('english', name || ' ' || description));"
    )
]
```

**Pros**: No separate service, easy setup
**Cons**: Less powerful than ElasticSearch

---

## Performance Tips

### 1. Index Only What You Search
Don't index large fields you don't search (e.g., full article content if you only search titles)

### 2. Use Filters Before Search
```python
# Efficient
query = {
    "query": {
        "bool": {
            "filter": [{"term": {"category": "electronics"}}],  # Filter first
            "must": [{"match": {"name": "laptop"}}]  # Then search
        }
    }
}
```

### 3. Limit Result Size
Always set `size` parameter (default 10-20)

### 4. Use Bulk Indexing
```python
# Don't do this
for product in products:
    es.index(index="products", id=product.id, document=doc)

# Do this
from elasticsearch.helpers import bulk

actions = [
    {"_index": "products", "_id": p.id, "_source": p.to_dict()}
    for p in products
]
bulk(es, actions)
```

---

**Typical Duration**: 3-4 days
**Risk Level**: MEDIUM (infrastructure, performance)
**Recommended Approach**: Sequential
