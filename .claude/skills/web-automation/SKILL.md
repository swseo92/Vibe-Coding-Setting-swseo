---
name: web-automation
description: Automate web browser tasks using Playwright MCP to navigate websites, fill forms, extract data, and generate API keys. Use this skill when users request browser automation like "get me an API key from GCP", "fill out this form", or "extract data from this website". Handles login and authentication by pausing for user intervention when needed.
---

# Web Automation

## Overview

This skill enables automated web browser interactions using Playwright MCP tools. It orchestrates complex multi-step browser workflows while gracefully handling scenarios requiring user intervention (authentication, CAPTCHA, 2FA).

## When to Use This Skill

Activate this skill when users request:

- **API key/token generation**: "Generate an API key from Google Cloud Vertex AI"
- **Form submission**: "Fill out this registration form with my details"
- **Data extraction**: "Extract the pricing table from this website"
- **Account configuration**: "Change my notification settings on this service"
- **Multi-step workflows**: "Navigate to X, then do Y, then retrieve Z"

Trigger keywords: web automation, browser, navigate to, API key, fill form, extract from website, scrape, login to

## Core Workflow

### Step 1: Understand the User's Goal

Parse the user request to identify:

1. **Target website/URL** (if provided)
2. **Desired outcome** (API key, form submission, data extraction, etc.)
3. **Credentials/inputs needed** (ask user if not provided)
4. **Steps requiring user intervention** (login, 2FA, CAPTCHA)

Ask clarifying questions if:
- Target URL is ambiguous
- Required credentials are unclear
- Multiple paths exist to achieve the goal

### Step 2: Plan the Automation Sequence

Break down the workflow into discrete steps:

1. **Navigation steps**: Which pages to visit in order
2. **Interaction points**: Buttons to click, forms to fill, dropdowns to select
3. **Wait conditions**: When to wait for page loads, dynamic content
4. **User intervention points**: Where authentication or decisions are needed
5. **Data extraction points**: What information to capture
6. **Verification steps**: How to confirm success

Document the plan clearly before execution.

### Step 3: Initialize Browser Session

Start the browser session:

```
Use mcp__microsoft-playwright-mcp__browser_navigate to open the target URL
```

**Initial snapshot**: Always take a snapshot after navigation to understand page state:

```
Use mcp__microsoft-playwright-mcp__browser_snapshot
```

### Step 4: Execute Automated Steps

For each step in the plan that doesn't require user intervention:

1. **Take snapshot** to understand current page state
2. **Identify target elements** using human-readable descriptions and refs
3. **Perform action** (click, type, select, etc.)
4. **Verify result** by taking another snapshot or checking for expected changes
5. **Report progress** to user ("Navigated to API keys page...")

**Available actions**:
- `browser_click`: Click buttons, links, checkboxes
- `browser_type`: Enter text into input fields
- `browser_select_option`: Choose from dropdowns
- `browser_fill_form`: Fill multiple form fields at once
- `browser_drag`: Drag and drop elements
- `browser_press_key`: Press keyboard keys (Enter, Tab, etc.)
- `browser_wait_for`: Wait for text to appear/disappear or time to pass

**Best practices**:
- Always use human-readable element descriptions (e.g., "Submit button", "Email input field")
- Use exact `ref` values from snapshots for reliable targeting
- Wait for page loads after navigation or clicks
- Take snapshots frequently to verify state changes

### Step 5: Handle User Intervention Points

When reaching a step requiring user action (login, 2FA, CAPTCHA):

1. **Take screenshot** of current state:
   ```
   Use mcp__microsoft-playwright-mcp__browser_take_screenshot
   ```

2. **Clearly explain** what the user needs to do:
   ```
   "I've navigated to the login page. Please log in with your credentials.
   Here's the current page: [screenshot]

   Once you've completed the login, reply with 'done' or 'continue'."
   ```

3. **Wait for user confirmation**: Pause execution until user signals completion

4. **Resume automation**: After user confirmation, take a new snapshot and continue

**Common intervention scenarios**:
- Login/authentication
- Two-factor authentication (2FA)
- CAPTCHA solving
- Security questions
- Account selection (when multiple accounts exist)
- Important confirmations or approvals
- Manual data entry (when automation cannot access secure fields)

### Step 6: Extract and Report Results

After completing the workflow:

1. **Capture final state**: Take snapshot or screenshot
2. **Extract target data**: Use `browser_evaluate` if needed for complex extraction
3. **Present results clearly**:
   ```
   "Successfully generated API key: [key-value]

   Summary:
   - Navigated to Vertex AI console
   - Selected project: [project-name]
   - Created API key: [key]

   The key has been saved to the console. [Screenshot attached]"
   ```

4. **Clean up** (optional): Close browser if workflow is complete

## User Intervention Pattern

**Detection**: Identify intervention needs by:
- Recognizing login/auth pages (presence of "password" fields, "sign in" buttons)
- Detecting CAPTCHA challenges
- Encountering permission requests or security prompts
- Hitting unexpected error states

**Communication template**:
```
[EMOJI: 🔐] User action required

Current step: [describe what needs to be done]
Current page: [screenshot]

What you need to do:
1. [Specific instruction 1]
2. [Specific instruction 2]

Reply with "done" when complete, and I'll continue.
```

**Resumption**:
- Always take a fresh snapshot after user intervention
- Verify expected state change occurred
- If state is unexpected, ask user for clarification

## Error Handling

**Page load failures**:
- Wait up to 30 seconds for pages to load
- If timeout occurs, inform user and ask if they want to retry

**Element not found**:
- Take snapshot to show current page state
- Explain what element was expected vs. what's present
- Ask user if they want to adjust the approach

**Unexpected page states**:
- Show screenshot of current state
- Ask user for guidance on how to proceed

**Console errors**:
- Use `browser_console_messages` to check for JavaScript errors
- Report critical errors to user

## Best Practices

1. **Transparency**: Always explain what you're doing at each step
2. **Verification**: Take snapshots before and after critical actions
3. **Patience**: Use appropriate wait conditions for dynamic content
4. **User respect**: Never guess credentials or bypass security measures
5. **Screenshots for context**: Provide visual feedback at intervention points
6. **Progressive disclosure**: Don't overwhelm with technical details unless debugging
7. **Graceful degradation**: If automation fails, clearly explain what manual steps are needed

## Common Scenarios

### Scenario 1: Cloud Service API Key Generation

**Example request**: "Get me an API key from Google Cloud Vertex AI"

**Workflow**:
1. Navigate to Google Cloud Console
2. **[User intervention]**: Login page → Ask user to authenticate
3. Select correct project (or ask user which project)
4. Navigate to Vertex AI → API & Services → Credentials
5. Click "Create Credentials" → "API Key"
6. Copy generated key
7. Report key to user

### Scenario 2: Form Submission

**Example request**: "Fill out this job application form"

**Workflow**:
1. Navigate to form URL
2. Identify all form fields (snapshot analysis)
3. Ask user for required information if not provided
4. Fill fields using `browser_fill_form` or `browser_type`
5. Review filled form with user (screenshot)
6. **[User approval]**: Confirm before submission
7. Click submit button
8. Confirm success (check for confirmation message)

### Scenario 3: Data Extraction

**Example request**: "Extract the pricing table from this SaaS website"

**Workflow**:
1. Navigate to pricing page
2. Take snapshot to identify table structure
3. Use `browser_evaluate` to extract table data:
   ```javascript
   () => {
     const table = document.querySelector('.pricing-table');
     return Array.from(table.querySelectorAll('.plan')).map(plan => ({
       name: plan.querySelector('.plan-name').textContent,
       price: plan.querySelector('.price').textContent,
       features: Array.from(plan.querySelectorAll('.feature')).map(f => f.textContent)
     }));
   }
   ```
4. Format extracted data as markdown table
5. Present to user

### Scenario 4: Account Settings Update

**Example request**: "Change my notification settings to email-only"

**Workflow**:
1. Navigate to service homepage
2. **[User intervention]**: Login if needed
3. Navigate to Settings → Notifications
4. Locate notification preference controls
5. Uncheck non-email options, ensure email is checked
6. Click "Save" or "Update"
7. Verify success message
8. Take screenshot of updated settings

## Reference Documentation

For detailed information on available Playwright MCP tools, see:
- [references/playwright-tools.md](references/playwright-tools.md) - Complete tool reference

## Limitations

This skill cannot:
- Bypass security measures (CAPTCHA, 2FA) without user help
- Access password managers or autofill credentials
- Perform actions requiring physical devices (hardware keys)
- Automate tasks on pages with heavy anti-bot protection

For these scenarios, request user assistance explicitly.
