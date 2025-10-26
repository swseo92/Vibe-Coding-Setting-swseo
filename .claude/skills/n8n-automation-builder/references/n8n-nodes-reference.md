# n8n Nodes Reference

This document provides a comprehensive reference of commonly used n8n nodes for building automation workflows.

## Core Nodes

### Trigger Nodes

#### Webhook
- **Purpose**: Receive HTTP requests to trigger workflows
- **Use cases**: External API integrations, form submissions, incoming webhooks
- **Configuration**: Generate webhook URL, choose HTTP method (GET, POST, etc.)
- **Example**: Trigger workflow when a form is submitted on your website

#### Schedule Trigger
- **Purpose**: Run workflows at specified intervals or times
- **Use cases**: Daily reports, periodic data sync, scheduled backups
- **Configuration**: Cron expression or interval (minutes, hours, days)
- **Example**: Check inventory levels every morning at 9 AM

#### Manual Trigger
- **Purpose**: Manually start workflow execution
- **Use cases**: Testing, on-demand tasks, user-initiated processes
- **Configuration**: No configuration needed
- **Example**: Manually trigger a data processing workflow

#### Webhook Trigger (n8n Form)
- **Purpose**: Create forms that trigger workflows
- **Use cases**: Lead collection, survey responses, support tickets
- **Configuration**: Define form fields and validation
- **Example**: Collect customer feedback through a form

#### RSS Feed Trigger
- **Purpose**: Monitor RSS feeds and trigger on new items
- **Use cases**: Content aggregation, news monitoring, blog updates
- **Configuration**: Feed URL, polling interval
- **Example**: Auto-publish new blog posts from multiple sources

### Action Nodes

#### HTTP Request
- **Purpose**: Make HTTP requests to external APIs
- **Use cases**: API integrations, data fetching, webhook sending
- **Configuration**: URL, method, headers, authentication, body
- **Example**: Fetch weather data from OpenWeather API

#### IF (Conditional)
- **Purpose**: Branch workflow based on conditions
- **Use cases**: Decision logic, data filtering, error handling
- **Configuration**: Define conditions (equals, contains, greater than, etc.)
- **Example**: Send different emails based on order amount

#### Set
- **Purpose**: Transform and set data values
- **Use cases**: Data manipulation, field mapping, value calculation
- **Configuration**: Define operations (Set, Remove, Add)
- **Example**: Calculate total price from quantity and unit price

#### Code (JavaScript)
- **Purpose**: Execute custom JavaScript code
- **Use cases**: Complex transformations, custom logic, data processing
- **Configuration**: Write JavaScript code with access to input data
- **Example**: Parse complex JSON responses or perform custom calculations

#### Function
- **Purpose**: Execute custom Node.js code with full module access
- **Use cases**: Advanced data processing, complex algorithms
- **Configuration**: Write Node.js code with npm module imports
- **Example**: Advanced text parsing with NLP libraries

#### Split In Batches
- **Purpose**: Process large datasets in smaller batches
- **Use cases**: API rate limiting, memory management, chunked processing
- **Configuration**: Batch size, reset condition
- **Example**: Process 1000 records in batches of 50

#### Merge
- **Purpose**: Combine data from multiple workflow branches
- **Use cases**: Data consolidation, joining datasets, parallel processing
- **Configuration**: Merge mode (append, merge by key, etc.)
- **Example**: Combine user data from multiple sources

#### Wait
- **Purpose**: Pause workflow execution
- **Use cases**: Rate limiting, scheduled delays, waiting for external events
- **Configuration**: Duration or resume webhook
- **Example**: Wait 5 minutes between API calls

### AI & Language Processing

#### OpenAI
- **Purpose**: Integrate with OpenAI GPT models
- **Use cases**: Content generation, text analysis, Q&A, translation
- **Configuration**: API key, model selection, prompt, temperature
- **Example**: Generate blog post summaries from article text

#### Anthropic Claude
- **Purpose**: Integrate with Anthropic Claude models
- **Use cases**: Content creation, analysis, coding assistance
- **Configuration**: API key, model, system prompt, user message
- **Example**: Analyze customer feedback sentiment

#### AI Agent
- **Purpose**: Create autonomous AI agents with tool access
- **Use cases**: Complex reasoning, multi-step tasks, tool usage
- **Configuration**: System prompt, tools, memory
- **Example**: Research assistant that searches and summarizes information

### Communication Nodes

#### Email (IMAP)
- **Purpose**: Read emails from mailbox
- **Use cases**: Email monitoring, inbox automation, support ticket creation
- **Configuration**: Email server, credentials, filters
- **Example**: Monitor support inbox for new tickets

#### Email Send
- **Purpose**: Send emails via SMTP
- **Use cases**: Notifications, reports, marketing emails
- **Configuration**: SMTP server, sender, recipient, subject, body
- **Example**: Send daily sales report to team

#### Gmail
- **Purpose**: Interact with Gmail API
- **Use cases**: Email automation, label management, draft creation
- **Configuration**: Google OAuth, operations (send, read, label, etc.)
- **Example**: Automatically label and archive newsletters

#### Slack
- **Purpose**: Send messages and interact with Slack
- **Use cases**: Notifications, team alerts, bot interactions
- **Configuration**: Slack credentials, channel, message content
- **Authentication**: OAuth or Bot Token
- **Example**: Send build failure notifications to dev channel

#### Discord
- **Purpose**: Send messages to Discord channels
- **Use cases**: Community notifications, bot responses, alerts
- **Configuration**: Webhook URL or bot token, channel, message
- **Example**: Post new blog announcements to Discord community

#### Telegram
- **Purpose**: Send and receive Telegram messages
- **Use cases**: Personal notifications, chatbot, group management
- **Configuration**: Bot token, chat ID, message
- **Example**: Daily habit tracker reminders

#### Twilio
- **Purpose**: Send SMS and make phone calls
- **Use cases**: SMS notifications, 2FA codes, phone alerts
- **Configuration**: Account SID, auth token, phone numbers
- **Example**: Send order confirmation SMS

### Data Storage

#### Google Sheets
- **Purpose**: Read and write data to Google Sheets
- **Use cases**: Data logging, dashboards, shared databases
- **Configuration**: Google OAuth, spreadsheet ID, sheet name, operations
- **Example**: Log daily sales data to tracking spreadsheet

#### Airtable
- **Purpose**: Interact with Airtable databases
- **Use cases**: CRM, project management, content calendars
- **Configuration**: API key, base ID, table, operations
- **Example**: Add new leads to CRM base

#### MySQL / PostgreSQL
- **Purpose**: Execute SQL queries on databases
- **Use cases**: Data retrieval, analytics, database operations
- **Configuration**: Connection details, SQL queries
- **Example**: Fetch user records for reporting

#### MongoDB
- **Purpose**: Interact with MongoDB databases
- **Use cases**: NoSQL data operations, document storage
- **Configuration**: Connection string, database, collection, operations
- **Example**: Store customer interactions in documents

#### Redis
- **Purpose**: Cache and key-value storage
- **Use cases**: Session management, caching, rate limiting
- **Configuration**: Connection details, operations (get, set, delete)
- **Example**: Cache API responses to reduce external calls

### File & Document Processing

#### Read Binary File
- **Purpose**: Read files from filesystem
- **Use cases**: File processing, data import
- **Configuration**: File path
- **Example**: Read CSV file for data processing

#### Write Binary File
- **Purpose**: Write files to filesystem
- **Use cases**: Report generation, data export
- **Configuration**: File path, data
- **Example**: Generate and save PDF reports

#### Google Drive
- **Purpose**: Upload, download, and manage files in Google Drive
- **Use cases**: Document storage, file sharing, backup
- **Configuration**: Google OAuth, operations (upload, download, share)
- **Example**: Backup generated reports to Drive folder

#### Dropbox
- **Purpose**: Interact with Dropbox storage
- **Use cases**: File sync, storage, sharing
- **Configuration**: OAuth, operations
- **Example**: Archive processed documents to Dropbox

#### PDF
- **Purpose**: Create and manipulate PDF files
- **Use cases**: Report generation, document processing
- **Configuration**: Template, data, operations
- **Example**: Generate invoice PDFs from order data

#### HTML Extract
- **Purpose**: Extract data from HTML pages
- **Use cases**: Web scraping, data extraction
- **Configuration**: Selectors, extraction rules
- **Example**: Extract product prices from competitor websites

### Business & Productivity

#### WordPress
- **Purpose**: Create and manage WordPress content
- **Use cases**: Blog automation, content publishing
- **Configuration**: Site URL, credentials, operations (create post, update)
- **Example**: Auto-publish blog posts from content calendar

#### Notion
- **Purpose**: Interact with Notion databases and pages
- **Use cases**: Knowledge management, task tracking, content organization
- **Configuration**: API key, database/page ID, operations
- **Example**: Create tasks in Notion from email requests

#### Trello
- **Purpose**: Manage Trello boards, lists, and cards
- **Use cases**: Project management, task automation, workflow tracking
- **Configuration**: API credentials, board/list IDs, operations
- **Example**: Create cards for new customer requests

#### Asana
- **Purpose**: Manage Asana projects and tasks
- **Use cases**: Team collaboration, project tracking
- **Configuration**: Access token, workspace, operations
- **Example**: Create tasks from form submissions

#### Calendly
- **Purpose**: Manage appointments and bookings
- **Use cases**: Meeting automation, calendar sync
- **Configuration**: API key, event types, operations
- **Example**: Send reminder emails before scheduled meetings

### E-commerce & Payments

#### Shopify
- **Purpose**: Manage Shopify store operations
- **Use cases**: Order processing, inventory management, customer management
- **Configuration**: Shop URL, API credentials, operations
- **Example**: Sync order data to fulfillment system

#### WooCommerce
- **Purpose**: Interact with WooCommerce stores
- **Use cases**: Order automation, product management
- **Configuration**: Store URL, API keys, operations
- **Example**: Update inventory after receiving supplier shipment

#### Stripe
- **Purpose**: Handle payments and subscriptions
- **Use cases**: Payment processing, subscription management, invoice creation
- **Configuration**: API key, operations (create charge, subscription, etc.)
- **Example**: Send invoice reminders for unpaid subscriptions

#### PayPal
- **Purpose**: Process PayPal transactions
- **Use cases**: Payment tracking, refunds, payout management
- **Configuration**: Client ID, secret, operations
- **Example**: Process refund requests automatically

### Social Media

#### Twitter
- **Purpose**: Post tweets and interact with Twitter API
- **Use cases**: Social media automation, content scheduling, engagement
- **Configuration**: API credentials, operations (tweet, like, retweet)
- **Example**: Auto-post new blog articles to Twitter

#### Facebook
- **Purpose**: Post to Facebook pages and groups
- **Use cases**: Social media marketing, community management
- **Configuration**: Access token, page/group ID, operations
- **Example**: Share product launches to Facebook page

#### LinkedIn
- **Purpose**: Post content to LinkedIn
- **Use cases**: Professional networking, content sharing
- **Configuration**: OAuth, operations
- **Example**: Share company updates to LinkedIn page

#### Instagram
- **Purpose**: Post photos and manage Instagram account
- **Use cases**: Social media automation, content scheduling
- **Configuration**: Access token, operations
- **Example**: Schedule and post product photos

### Monitoring & Analytics

#### Google Analytics
- **Purpose**: Fetch analytics data
- **Use cases**: Reporting, data analysis, dashboards
- **Configuration**: OAuth, view ID, metrics, dimensions
- **Example**: Fetch daily website traffic for reports

#### Webhook Response
- **Purpose**: Send HTTP response for webhook workflows
- **Use cases**: API endpoints, synchronous responses
- **Configuration**: Status code, body, headers
- **Example**: Return success confirmation to webhook caller

#### Error Trigger
- **Purpose**: Handle workflow errors
- **Use cases**: Error notifications, fallback logic, debugging
- **Configuration**: Attach to workflows that need error handling
- **Example**: Send Slack alert when workflow fails

### Utility Nodes

#### DateTime
- **Purpose**: Format and manipulate dates and times
- **Use cases**: Date calculations, timezone conversions, formatting
- **Configuration**: Operations (format, add/subtract, timezone)
- **Example**: Calculate due dates 30 days from order date

#### Execute Command
- **Purpose**: Run shell commands
- **Use cases**: System operations, script execution
- **Configuration**: Command, arguments
- **Example**: Run backup scripts or system maintenance

#### Item Lists
- **Purpose**: Work with arrays and lists
- **Use cases**: Data aggregation, filtering, sorting
- **Configuration**: Operations (aggregate, filter, sort, limit)
- **Example**: Get top 10 highest-value orders

#### Edit Image
- **Purpose**: Manipulate images programmatically
- **Use cases**: Image resizing, cropping, watermarking
- **Configuration**: Operations, dimensions, quality
- **Example**: Resize product images for web display

#### RSS Read
- **Purpose**: Parse RSS/Atom feeds
- **Use cases**: Content aggregation, news monitoring
- **Configuration**: Feed URL
- **Example**: Collect latest posts from multiple blogs

## Node Selection Guidelines

### When to Use HTTP Request vs. Dedicated Nodes
- **Use dedicated nodes** when available - they provide better error handling and type safety
- **Use HTTP Request** for custom APIs or services without dedicated nodes
- **Example**: Use Gmail node instead of HTTP Request for Gmail operations

### When to Use Code vs. Set Node
- **Use Set node** for simple field mappings and basic transformations
- **Use Code node** for complex logic, loops, or advanced data manipulation
- **Example**: Use Set for renaming fields, Code for parsing nested JSON

### When to Use IF vs. Switch Node
- **Use IF** for simple binary conditions
- **Use Switch** for multiple condition branches (3+ outcomes)
- **Example**: IF for "is premium customer", Switch for "route by country"

### When to Use Split In Batches
- Processing large datasets (>100 items)
- API rate limits require throttling
- Memory constraints with large data
- **Example**: Process 1000 email sends in batches of 50

## Common Node Combinations

### Content Publishing Pipeline
```
RSS Feed Trigger → OpenAI (Summarize) → WordPress → Twitter
```

### Customer Support Automation
```
Gmail Trigger → IF (has "urgent") → Slack → Notion
```

### E-commerce Order Processing
```
Shopify Trigger → IF (high value) → Slack Alert → Google Sheets
```

### Data Sync Workflow
```
Schedule Trigger → MySQL → Transform (Code) → Airtable
```

### Form to CRM
```
Webhook → Set → Airtable → Email Send (Confirmation)
```

## Best Practices

1. **Error Handling**: Always include error workflow branches for critical automation
2. **Testing**: Use Manual Trigger for testing before enabling automatic triggers
3. **Logging**: Add Set nodes to log key data points for debugging
4. **Modularity**: Break complex workflows into sub-workflows
5. **Documentation**: Use Sticky Notes node to document workflow sections
6. **Security**: Store credentials securely using n8n credential system
7. **Rate Limiting**: Use Wait or Split In Batches for API rate limits
8. **Data Validation**: Validate input data before processing to prevent errors
