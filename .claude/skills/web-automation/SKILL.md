---
name: web-automation
description: Automate web browser tasks using Playwright MCP to navigate websites, fill forms, extract data, and generate API keys. Use this skill when users request browser automation like "get me an API key from GCP", "fill out this form", or "extract data from this website". Automatically handles Google OAuth login using persistent browser sessions. For non-Google authentication, pauses for user intervention when needed.
---

# Web Automation

## Overview

This skill enables automated web browser interactions using Playwright MCP tools. It orchestrates complex multi-step browser workflows with **automatic Google OAuth login** support. The browser uses persistent sessions to maintain login state, enabling seamless authentication for Google-based services. For non-Google authentication, it gracefully handles scenarios requiring user intervention (authentication, CAPTCHA, 2FA).

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

### Step 4.5: Handle Google OAuth Login (Automated)

**When a Google social login option is detected, attempt automatic login:**

1. **Detect Google login button** in the snapshot:
   - Look for buttons with text like "Continue with Google", "Sign in with Google", "Google"
   - Common patterns: "Google", "google", "Continue with Google", "Sign in with Google"

2. **Attempt automated Google OAuth flow**:
   ```
   a. Click the Google login button
   b. Wait for Google OAuth page to load (2-3 seconds)
   c. Take snapshot to check current state
   d. If already logged in (account selection page):
      - Look for account email in the snapshot
      - Click on the account to select it
      - Wait for redirect back to the service
   e. If Google login page appears:
      - Report to user that manual login is needed
      - Follow Step 5 (User Intervention Pattern)
   ```

3. **Handle account selection**:
   - If multiple Google accounts are available, automatically select the first one
   - If user wants to use a different account, they can interrupt and specify

4. **Verify successful login**:
   - After account selection, wait for redirect
   - Take snapshot to confirm login success
   - Look for user profile indicators or dashboard elements

**Example flow**:
```
[Detected "Continue with Google" button]
→ Clicking Google login button...
→ Waiting for Google OAuth page...
→ [Account selection page detected]
→ Found account: user@gmail.com
→ Selecting account...
→ Waiting for redirect...
→ ✓ Successfully logged in with Google account
```

**Fallback to manual intervention**:
If any of these conditions occur, fall back to Step 5 (User Intervention):
- Google login page requires password entry
- 2FA/verification is required
- Account selection page shows no accounts
- Unexpected page state after clicking Google login

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
- Login/authentication (non-Google) - Google OAuth is automated
- Two-factor authentication (2FA)
- CAPTCHA solving
- Security questions
- Important confirmations or approvals
- Manual data entry (when automation cannot access secure fields)

**Note**: Google OAuth login is handled automatically using persistent browser sessions. The browser maintains logged-in state across sessions, so account selection happens automatically.

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
8. **Prefer Google OAuth**: When multiple login options exist, prioritize "Sign in with Google" for automatic authentication
9. **Persistent session awareness**: Leverage persistent browser sessions to avoid repeated logins across different tasks
10. **Account selection**: When multiple Google accounts are available, select the first one automatically (user can interrupt if needed)

## Common Scenarios

### Scenario 1: Cloud Service API Key Generation

**Example request**: "Get me an API key from Google Cloud Vertex AI"

**Workflow**:
1. Navigate to Google Cloud Console
2. **[Automated]**: Click "Sign in with Google" if present
3. **[Automated]**: Select Google account from persistent browser session
4. Select correct project (or ask user which project)
5. Navigate to Vertex AI → API & Services → Credentials
6. Click "Create Credentials" → "API Key"
7. Copy generated key
8. Report key to user

**Note**: Steps 2-3 are fully automated thanks to persistent browser sessions. No user intervention needed for Google login.

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

**Example request**: "Change my notification settings to email-only on this service"

**Workflow**:
1. Navigate to service homepage
2. **[Automated or User intervention]**:
   - If Google login available → Automated login
   - If other auth required → User intervention
3. Navigate to Settings → Notifications
4. Locate notification preference controls
5. Uncheck non-email options, ensure email is checked
6. Click "Save" or "Update"
7. Verify success message
8. Take screenshot of updated settings

### Scenario 5: Service with Google OAuth (Linear, Notion, etc.)

**Example request**: "Get me an API key from Linear" or "Create a new page in Notion"

**Workflow**:
1. Navigate to service (e.g., linear.app/settings/api)
2. **[Automated]**: Detect "Continue with Google" button
3. **[Automated]**: Click Google login button
4. **[Automated]**: Wait for Google account selection page
5. **[Automated]**: Select account from persistent session
6. **[Automated]**: Wait for redirect back to service
7. Verify successful login (user profile visible)
8. Proceed with requested action (create API key, create page, etc.)
9. Report results to user

**Supported services**:
- Linear (Project management)
- Notion (Knowledge base)
- Figma (Design tool)
- Vercel (Deployment platform)
- Any service offering "Sign in with Google" option

**Advantages**:
- ✅ Zero user interaction required for login
- ✅ Works across Claude Code restarts (persistent browser)
- ✅ Automatic account selection
- ✅ Fast and seamless authentication

## Reference Documentation

For detailed information on available Playwright MCP tools, see:
- [references/playwright-tools.md](references/playwright-tools.md) - Complete tool reference

## Limitations

This skill cannot:
- Bypass security measures (CAPTCHA, 2FA) without user help
- Access password managers or autofill credentials (except Google OAuth via persistent browser)
- Perform actions requiring physical devices (hardware keys)
- Automate tasks on pages with heavy anti-bot protection
- Automatically handle non-Google authentication (GitHub, Apple, email/password, etc.)

**What IS automated**:
- ✅ Google OAuth login (via persistent browser sessions)
- ✅ Google account selection
- ✅ Redirect after Google authentication

**What still requires user intervention**:
- ❌ Non-Google login methods
- ❌ 2FA/verification codes
- ❌ CAPTCHA challenges
- ❌ Password entry (even for Google if not already logged in)

For non-automated scenarios, the skill will pause and request user assistance explicitly.
