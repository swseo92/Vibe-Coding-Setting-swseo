# n8n Workflow Patterns

This document provides common workflow patterns and examples for automating various business processes with n8n.

## Pattern Categories

### 1. Content Automation Patterns

#### Blog Publishing Automation

**Use Case**: Automate content creation, publishing, and promotion for blogs

**Workflow Pattern**:
```
RSS Feed Trigger
  ↓
AI Summarization (OpenAI/Claude)
  ↓
Google Docs (Store draft)
  ↓
[Manual Review]
  ↓
Webhook Trigger (After approval)
  ↓
WordPress (Publish post)
  ↓
Split to multiple branches:
  ├→ Twitter (Share link)
  ├→ Facebook (Share link)
  └→ LinkedIn (Share link)
```

**Key Automation Points**:
- Automatic content discovery via RSS
- AI-powered summarization/rewriting
- Multi-channel distribution
- Manual quality control checkpoint

**Required Nodes**:
- RSS Feed Trigger
- OpenAI or Claude API
- Google Docs
- Webhook
- WordPress
- Social media nodes (Twitter, Facebook, LinkedIn)

**Time Saved**: 2-3 hours per blog post

---

#### Newsletter Curation

**Use Case**: Aggregate content from multiple sources into weekly newsletter

**Workflow Pattern**:
```
Schedule Trigger (Weekly)
  ↓
Multiple RSS Feed Read nodes (parallel)
  ↓
Merge
  ↓
AI Agent (Curate and rank content)
  ↓
Set (Format for email)
  ↓
Email Send (Newsletter)
  ↓
Google Sheets (Log sent newsletters)
```

**Key Automation Points**:
- Scheduled content aggregation
- AI-powered content curation
- Automated email distribution
- Analytics tracking

**Time Saved**: 4-5 hours per week

---

#### Social Media Cross-Posting

**Use Case**: Post content once, distribute everywhere

**Workflow Pattern**:
```
Webhook Trigger (New content)
  ↓
Set (Extract content data)
  ↓
IF (Has image?)
  ├→ Yes: Edit Image (Resize for each platform)
  └→ No: Continue
  ↓
Split to multiple branches:
  ├→ Twitter (Post tweet)
  ├→ Instagram (Post image)
  ├→ LinkedIn (Post update)
  └→ Facebook (Post to page)
  ↓
Merge
  ↓
Notion (Log posted content)
```

**Key Automation Points**:
- Single content input
- Platform-specific formatting
- Image optimization
- Cross-platform tracking

**Time Saved**: 30-45 minutes per post

---

### 2. E-commerce & Inventory Patterns

#### Inventory Monitoring & Reordering

**Use Case**: Automated inventory tracking and supplier ordering

**Workflow Pattern**:
```
Schedule Trigger (Daily at 9 AM)
  ↓
Google Sheets (Read inventory levels)
  ↓
Item Lists (Filter low stock items)
  ↓
IF (Any items below threshold?)
  ├→ No: Stop
  └→ Yes: Continue
      ↓
      Slack (Alert team)
      ↓
      Code (Generate purchase order)
      ↓
      PDF (Create PO document)
      ↓
      [Manual Approval Checkpoint]
      ↓
      Webhook (After approval)
      ↓
      Email Send (Send PO to supplier)
      ↓
      Google Sheets (Update order status)
```

**Key Automation Points**:
- Daily automated stock checks
- Threshold-based alerts
- Automatic PO generation
- Approval workflow integration

**Required Nodes**:
- Schedule Trigger
- Google Sheets
- Item Lists
- IF
- Slack
- Code
- PDF
- Webhook
- Email Send

**Time Saved**: 1-2 hours per day

---

#### Order Fulfillment Automation

**Use Case**: Process e-commerce orders from payment to shipping

**Workflow Pattern**:
```
Shopify Trigger (New order)
  ↓
Set (Extract order details)
  ↓
IF (Order value > $500?)
  ├→ Yes: Slack (Alert for manual review)
  └→ No: Continue automatically
  ↓
HTTP Request (Check inventory API)
  ↓
IF (All items in stock?)
  ├→ No: Email (Notify customer of delay)
  └→ Yes: Continue
      ↓
      HTTP Request (Create shipping label)
      ↓
      Shopify (Update order with tracking)
      ↓
      Email Send (Shipping confirmation to customer)
      ↓
      Google Sheets (Log fulfilled order)
```

**Key Automation Points**:
- Automatic order processing
- High-value order flagging
- Stock validation
- Shipping automation
- Customer notifications

**Time Saved**: 15-20 minutes per order

---

#### Price Monitoring & Competitor Analysis

**Use Case**: Track competitor prices and adjust your pricing

**Workflow Pattern**:
```
Schedule Trigger (Every 6 hours)
  ↓
HTTP Request (Scrape competitor sites)
  ↓
HTML Extract (Extract prices)
  ↓
Google Sheets (Log competitor prices)
  ↓
Code (Calculate price differences)
  ↓
IF (Your price > competitor + margin?)
  ├→ No: Stop
  └→ Yes: Slack (Alert pricing team)
      ↓
      [Manual pricing decision]
      ↓
      Shopify (Update product prices)
```

**Key Automation Points**:
- Automated price scraping
- Real-time competitor monitoring
- Alert-based pricing reviews

**Time Saved**: 2-3 hours per day

---

### 3. Customer Support Patterns

#### Support Ticket Routing

**Use Case**: Automatically route support emails to correct team

**Workflow Pattern**:
```
Gmail Trigger (New email in support inbox)
  ↓
AI Agent (Analyze email content and priority)
  ↓
Set (Extract classification results)
  ↓
Switch (Route by category)
  ├→ Technical: Assign to dev team
  ├→ Billing: Assign to finance team
  ├→ Sales: Assign to sales team
  └→ General: Assign to support team
  ↓
Notion (Create ticket in appropriate board)
  ↓
Slack (Notify assigned team)
  ↓
Gmail (Send auto-reply to customer)
```

**Key Automation Points**:
- AI-powered categorization
- Intelligent routing
- Team notifications
- Auto-acknowledgment

**Required Nodes**:
- Gmail Trigger
- AI Agent or OpenAI
- Set
- Switch
- Notion
- Slack
- Gmail Send

**Time Saved**: 10-15 minutes per ticket

---

#### Customer Feedback Analysis

**Use Case**: Analyze customer feedback and extract insights

**Workflow Pattern**:
```
Schedule Trigger (Weekly)
  ↓
Google Forms (Fetch responses from last week)
  ↓
Split In Batches (Process 10 at a time)
  ↓
OpenAI (Sentiment analysis + key themes)
  ↓
Set (Structure results)
  ↓
Google Sheets (Append analysis results)
  ↓
Code (Aggregate insights)
  ↓
IF (Negative sentiment > 30%?)
  ├→ Yes: Slack (Alert management)
  └→ No: Continue
  ↓
PDF (Generate weekly feedback report)
  ↓
Email Send (Send report to team)
```

**Key Automation Points**:
- Batch sentiment analysis
- Trend detection
- Alert-based escalation
- Automated reporting

**Time Saved**: 3-4 hours per week

---

### 4. Data Synchronization Patterns

#### CRM to Marketing Sync

**Use Case**: Keep CRM and marketing tools in sync

**Workflow Pattern**:
```
Schedule Trigger (Every 15 minutes)
  ↓
Airtable (Fetch new/updated contacts)
  ↓
IF (No new records?)
  ├→ Yes: Stop
  └→ No: Continue
  ↓
Split In Batches (Process 50 at a time)
  ↓
HTTP Request (Check if contact exists in marketing tool)
  ↓
IF (Contact exists?)
  ├→ Yes: HTTP Request (Update contact)
  └→ No: HTTP Request (Create new contact)
  ↓
Airtable (Mark as synced)
  ↓
Google Sheets (Log sync activity)
```

**Key Automation Points**:
- Incremental sync
- Duplicate detection
- Batch processing
- Sync logging

**Time Saved**: Manual sync eliminated

---

#### Multi-Database Aggregation

**Use Case**: Combine data from multiple sources for reporting

**Workflow Pattern**:
```
Schedule Trigger (Daily at midnight)
  ↓
Parallel branches:
  ├→ MySQL (Fetch sales data)
  ├→ PostgreSQL (Fetch customer data)
  └→ MongoDB (Fetch product data)
  ↓
Merge
  ↓
Code (Join datasets)
  ↓
Set (Calculate metrics)
  ↓
Google Sheets (Update dashboard)
  ↓
IF (Sales < target?)
  ├→ Yes: Slack (Alert sales team)
  └→ No: Continue
  ↓
Email Send (Daily report to management)
```

**Key Automation Points**:
- Multi-source data fetching
- Data transformation
- Automated dashboards
- Conditional alerts

**Time Saved**: 2-3 hours per day

---

### 5. Lead Generation & Sales Patterns

#### Lead Qualification Pipeline

**Use Case**: Automatically qualify and route inbound leads

**Workflow Pattern**:
```
Webhook (Form submission)
  ↓
Set (Extract form data)
  ↓
HTTP Request (Enrich lead data from Clearbit/Hunter)
  ↓
AI Agent (Score lead quality)
  ↓
Switch (Route by score)
  ├→ High (>80):
  │   ↓
  │   Salesforce (Create opportunity)
  │   ↓
  │   Slack (Alert sales manager)
  │   ↓
  │   Email Send (Personalized outreach)
  │
  ├→ Medium (50-80):
  │   ↓
  │   Airtable (Add to nurture campaign)
  │   ↓
  │   Email Send (Educational content)
  │
  └→ Low (<50):
      ↓
      Google Sheets (Add to cold list)
      ↓
      Email Send (Generic resources)
```

**Key Automation Points**:
- Automatic lead enrichment
- AI-powered scoring
- Intelligent routing
- Personalized outreach

**Time Saved**: 20-30 minutes per lead

---

#### Follow-up Automation

**Use Case**: Automated sales follow-up sequences

**Workflow Pattern**:
```
Airtable Trigger (New lead added)
  ↓
Set (Prepare lead data)
  ↓
Email Send (Initial contact)
  ↓
Wait (3 days)
  ↓
Airtable (Check if lead responded)
  ↓
IF (No response?)
  ├→ No: Stop (Lead is engaged)
  └→ Yes: Continue follow-up
      ↓
      Email Send (Second follow-up)
      ↓
      Wait (5 days)
      ↓
      Airtable (Check response again)
      ↓
      IF (No response?)
        ├→ No: Stop
        └→ Yes: Email Send (Final follow-up)
            ↓
            Slack (Notify to try different approach)
```

**Key Automation Points**:
- Timed follow-ups
- Response detection
- Multi-touch sequences
- Manual intervention alerts

**Time Saved**: 30-40 minutes per lead

---

### 6. Personal Productivity Patterns

#### Daily Briefing Generator

**Use Case**: Compile daily news, tasks, and calendar into one email

**Workflow Pattern**:
```
Schedule Trigger (Daily at 7 AM)
  ↓
Parallel branches:
  ├→ RSS Read (Fetch news from favorite sources)
  ├→ Google Calendar (Get today's events)
  ├→ Notion (Get today's tasks)
  └→ Gmail (Get unread important emails count)
  ↓
Merge
  ↓
OpenAI (Format into readable briefing)
  ↓
Set (Structure email content)
  ↓
Email Send (Send briefing)
```

**Key Automation Points**:
- Multi-source aggregation
- AI-powered formatting
- Scheduled delivery

**Time Saved**: 30-45 minutes per day

---

#### Meeting Notes Automation

**Use Case**: Automatically process and distribute meeting notes

**Workflow Pattern**:
```
Google Drive Trigger (New file in "Meeting Notes" folder)
  ↓
Google Docs (Read document content)
  ↓
OpenAI (Extract action items and key decisions)
  ↓
Split to branches:
  ├→ Notion (Create tasks from action items)
  ├→ Google Calendar (Add follow-up events)
  └→ Slack (Post summary to team channel)
  ↓
Email Send (Send full notes to attendees)
```

**Key Automation Points**:
- Automatic action item extraction
- Task creation
- Multi-channel distribution

**Time Saved**: 15-20 minutes per meeting

---

### 7. Financial & Invoicing Patterns

#### Invoice Generation & Tracking

**Use Case**: Automatically create and send invoices

**Workflow Pattern**:
```
Schedule Trigger (1st of each month)
  ↓
Google Sheets (Fetch active subscriptions)
  ↓
Split In Batches (Process 20 at a time)
  ↓
Code (Calculate invoice amounts with tax)
  ↓
Stripe (Create invoice)
  ↓
PDF (Generate invoice PDF)
  ↓
Email Send (Send invoice to customer)
  ↓
Google Sheets (Update invoice sent date)
  ↓
Wait (30 days)
  ↓
Stripe (Check payment status)
  ↓
IF (Unpaid?)
  ├→ Yes: Email Send (Payment reminder)
  └→ No: Stop
```

**Key Automation Points**:
- Automated invoice creation
- Payment tracking
- Reminder automation

**Time Saved**: 2-3 hours per month

---

#### Expense Tracking

**Use Case**: Automatically categorize and track expenses

**Workflow Pattern**:
```
Gmail Trigger (Receipt emails)
  ↓
Set (Extract receipt data)
  ↓
OpenAI (Categorize expense)
  ↓
Google Sheets (Log expense)
  ↓
IF (Amount > $500?)
  ├→ Yes: Slack (Alert for approval)
  └→ No: Continue
  ↓
IF (Monthly total > budget?)
  ├→ Yes: Email (Budget warning)
  └→ No: Stop
```

**Key Automation Points**:
- Email-based receipt capture
- AI categorization
- Budget monitoring

**Time Saved**: 1-2 hours per week

---

## Workflow Design Principles

### 1. Start Simple, Add Complexity
Begin with core functionality, then add error handling, notifications, and logging.

### 2. Use Checkpoints for Critical Actions
Add manual approval steps before irreversible actions (payments, deletions, public posts).

### 3. Plan for Failures
Include error workflows to handle API failures, missing data, or unexpected states.

### 4. Log Important Data
Use Google Sheets or databases to track workflow executions for debugging and analytics.

### 5. Test with Small Batches
When processing large datasets, test with small samples first.

### 6. Consider Rate Limits
Use Split In Batches and Wait nodes to respect API rate limits.

### 7. Make Workflows Observable
Add Slack/email notifications for key milestones and errors.

## Common Anti-Patterns to Avoid

### ❌ No Error Handling
**Problem**: Workflows fail silently
**Solution**: Add Error Trigger nodes and notification paths

### ❌ Hardcoded Values
**Problem**: Difficult to maintain and adapt
**Solution**: Use Set nodes and workflow variables

### ❌ Processing Too Much at Once
**Problem**: Timeout errors, memory issues
**Solution**: Use Split In Batches for large datasets

### ❌ No Testing Strategy
**Problem**: Bugs in production workflows
**Solution**: Use Manual Trigger and test environments

### ❌ Missing User Feedback
**Problem**: Users don't know workflow status
**Solution**: Add confirmation emails/notifications

### ❌ Overcomplicated Logic
**Problem**: Difficult to debug and maintain
**Solution**: Break into sub-workflows, use clear naming

## Workflow Optimization Tips

1. **Parallel Processing**: Run independent branches in parallel to speed up execution
2. **Caching**: Use Redis node to cache frequently accessed data
3. **Conditional Execution**: Use IF nodes to skip unnecessary processing
4. **Batch Operations**: Combine multiple API calls when possible
5. **Data Transformation**: Transform data early to reduce processing downstream
6. **Webhook Responses**: Send quick responses before long-running operations
7. **Sub-workflows**: Reuse common patterns across multiple workflows

## Testing Checklist

Before deploying a workflow to production:

- [ ] Test with valid input data
- [ ] Test with invalid/edge case data
- [ ] Verify error handling paths
- [ ] Check API rate limits won't be exceeded
- [ ] Confirm notification recipients are correct
- [ ] Validate security and credential usage
- [ ] Test manual approval flows (if any)
- [ ] Verify database/sheet updates are correct
- [ ] Check timezone handling for scheduled triggers
- [ ] Monitor first few production executions closely
