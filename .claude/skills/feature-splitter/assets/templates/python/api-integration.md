# Template: Third-Party API Integration

Pattern for integrating external APIs (Stripe, Twilio, SendGrid, etc.).

---

## Canonical Subtasks

### 1. {service}-config (0.5d)
**Goal**: API credentials and configuration

**Files**:
- `config.py` - API settings
- `.env` - API keys, secrets
- `.env.example` - Document required vars

**Example**:
```
STRIPE_API_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
SENDGRID_API_KEY=SG.xxx
```

**Dependency**: None

---

### 2. {service}-client (1d)
**Goal**: API client wrapper

**Files**:
- `services/{service}_client.py` - SDK wrapper
- `models/{service}.py` - Response models (optional)

**Example (Stripe)**:
```python
import stripe

class StripeClient:
    def __init__(self):
        stripe.api_key = settings.STRIPE_API_KEY

    def create_payment_intent(self, amount: int, currency: str = "usd"):
        return stripe.PaymentIntent.create(
            amount=amount,
            currency=currency
        )

    def retrieve_customer(self, customer_id: str):
        return stripe.Customer.retrieve(customer_id)
```

**Dependencies**: SDK library (`stripe`, `twilio`, `sendgrid`)

**Dependency**: {service}-config

**Risk**: MEDIUM-HIGH (external dependency)

---

### 3. {service}-webhooks (1d)
**Goal**: Receive events from third-party (if applicable)

**Files (Django)**: `apps/{service}/views.py`, `urls.py`
**Files (FastAPI)**: `routers/{service}_webhooks.py`

**Example (Stripe Webhooks)**:
```python
@router.post("/webhooks/stripe")
async def stripe_webhook(request: Request):
    payload = await request.body()
    sig_header = request.headers.get("stripe-signature")

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
    except ValueError:
        raise HTTPException(400, "Invalid payload")

    # Handle event
    if event["type"] == "payment_intent.succeeded":
        handle_successful_payment(event["data"]["object"])

    return {"status": "success"}
```

**Security**: Verify webhook signatures!

**Dependency**: {service}-client

---

### 4. {service}-endpoints (0.5-1d)
**Goal**: Expose API to trigger third-party actions

**Files (Django)**: `views.py`, `urls.py`
**Files (FastAPI)**: `routers/{service}.py`

**Example Endpoints**:
- `POST /payments/create` - Create Stripe payment
- `POST /sms/send` - Send Twilio SMS
- `POST /emails/send` - Send SendGrid email

**Dependency**: {service}-client

---

### 5. {service}-tests (1d)
**Goal**: Mock third-party API for testing

**Files**:
- `tests/test_{service}.py` - Integration tests
- `tests/mocks/{service}.py` - Mock responses

**Example (Mock Stripe)**:
```python
import pytest
from unittest.mock import patch

@patch("stripe.PaymentIntent.create")
def test_create_payment(mock_create):
    mock_create.return_value = {
        "id": "pi_123",
        "status": "succeeded"
    }

    result = stripe_client.create_payment_intent(1000)
    assert result["status"] == "succeeded"
```

**Dependency**: {service}-endpoints

---

## Dependency Graph

```
1. config → 2. client → 3. webhooks, 4. endpoints → 5. tests
```

**Parallel**: Steps 3 and 4 can be parallel after step 2

---

## Common Pitfalls

1. **Hardcoded API Keys**: Keys in code → Use environment variables
2. **No Webhook Verification**: Accepting fake webhooks → Verify signatures
3. **No Error Handling**: API failures crash app → Catch exceptions, retry
4. **Rate Limiting**: Exceeding API limits → Implement backoff, caching
5. **No Idempotency**: Duplicate charges → Use idempotency keys
6. **Testing in Production**: Using prod API keys in tests → Use test/sandbox keys

---

## Example: Stripe Idempotency

```python
def create_payment(order_id: int, amount: int):
    # Use order_id as idempotency key to prevent duplicate charges
    return stripe.PaymentIntent.create(
        amount=amount,
        currency="usd",
        idempotency_key=f"order_{order_id}"
    )
```

---

## Security Checklist

- [ ] API keys in environment variables (not code)
- [ ] Webhook signatures verified
- [ ] HTTPS enforced for webhook endpoints
- [ ] Sensitive data not logged (API keys, customer data)
- [ ] Error messages don't leak API internals
- [ ] Rate limiting implemented
- [ ] Timeouts set for API calls
- [ ] Test mode used in staging/dev

---

**Typical Duration**: 3-4 days
**Risk Level**: MEDIUM-HIGH (external dependency, security)
**Recommended Approach**: Sequential for client/webhooks, parallel for tests
