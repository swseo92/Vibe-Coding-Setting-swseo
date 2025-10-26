# Playwright MCP Tools Reference

Complete reference for all available Playwright MCP browser automation tools.

## Navigation Tools

### browser_navigate

Navigate to a URL.

**Parameters**:
- `url` (string, required): The URL to navigate to

**Usage**:
```
Navigate to https://console.cloud.google.com
```

**Best practices**:
- Use absolute URLs (include https://)
- Wait for page load after navigation (use browser_snapshot)

---

### browser_navigate_back

Go back to the previous page.

**Parameters**: None

**Usage**:
```
Go back to previous page
```

---

## Page State Tools

### browser_snapshot

Capture accessibility snapshot of the current page. This is the primary tool for understanding page structure and identifying elements.

**Parameters**: None

**Returns**: Hierarchical page structure with element references (refs)

**Usage**:
```
Take snapshot to see page structure
```

**Best practices**:
- **Always use this instead of screenshots** for automation decisions
- Take snapshot after every navigation or significant page change
- Extract element `ref` values from snapshot for reliable targeting
- Use human-readable descriptions when interacting with elements

---

### browser_take_screenshot

Take a screenshot of the current page or specific element.

**Parameters**:
- `element` (string, optional): Human-readable element description to screenshot
- `ref` (string, optional): Exact element reference from snapshot
- `filename` (string, optional): File name to save (defaults to `page-{timestamp}.png`)
- `fullPage` (boolean, optional): Capture full scrollable page (default: false, cannot be used with element screenshots)
- `type` (string, optional): Image format - "png" or "jpeg" (default: "png")

**Usage**:
```
Take screenshot of entire page
Take screenshot of element "Login form" with ref "abc123"
Take full page screenshot with filename "results.png"
```

**Best practices**:
- Use screenshots for **user feedback** and **debugging**, not for automation decisions
- Use browser_snapshot for automation decisions
- Take screenshots at user intervention points
- Use fullPage for long pages when showing complete context

---

### browser_console_messages

Returns all console messages from the page.

**Parameters**:
- `onlyErrors` (boolean, optional): Only return error messages

**Usage**:
```
Get all console messages
Get console errors only
```

**Best practices**:
- Check console for JavaScript errors when debugging
- Use after page load to detect issues

---

### browser_network_requests

Returns all network requests since loading the page.

**Parameters**: None

**Usage**:
```
Get all network requests
```

**Best practices**:
- Use to verify API calls were made
- Debug loading issues
- Monitor background requests

---

## Interaction Tools

### browser_click

Perform click on a web page element.

**Parameters**:
- `element` (string, required): Human-readable element description
- `ref` (string, required): Exact target element reference from page snapshot
- `button` (string, optional): Button to click - "left", "right", "middle" (default: "left")
- `doubleClick` (boolean, optional): Perform double click (default: false)
- `modifiers` (array, optional): Modifier keys - ["Alt", "Control", "ControlOrMeta", "Meta", "Shift"]

**Usage**:
```
Click button "Submit" with ref "xyz789"
Double-click link "Download" with ref "abc123"
Right-click element "Context menu" with ref "def456"
```

**Best practices**:
- Always get `ref` from latest snapshot
- Use descriptive element names for permission clarity
- Wait for page changes after clicking (use browser_snapshot)

---

### browser_type

Type text into editable element.

**Parameters**:
- `element` (string, required): Human-readable element description
- `ref` (string, required): Exact target element reference from snapshot
- `text` (string, required): Text to type
- `slowly` (boolean, optional): Type one character at a time (default: false)
- `submit` (boolean, optional): Press Enter after typing (default: false)

**Usage**:
```
Type "user@example.com" into "Email field" with ref "abc123"
Type "password123" slowly into "Password field" with ref "def456"
Type "search query" into "Search box" with ref "ghi789" and submit
```

**Best practices**:
- Use `slowly: true` when page has key handlers or auto-complete
- Use `submit: true` for search boxes and single-field forms
- Clear existing text first if needed (select all + type)

---

### browser_press_key

Press a key on the keyboard.

**Parameters**:
- `key` (string, required): Key name or character (e.g., "Enter", "Tab", "ArrowLeft", "a")

**Usage**:
```
Press "Enter"
Press "Tab"
Press "Escape"
```

**Best practices**:
- Use for keyboard shortcuts
- Navigate forms with Tab
- Trigger actions with Enter
- Close dialogs with Escape

---

### browser_fill_form

Fill multiple form fields at once.

**Parameters**:
- `fields` (array, required): Array of field objects with:
  - `name` (string): Human-readable field name
  - `ref` (string): Exact field reference from snapshot
  - `type` (string): Field type - "textbox", "checkbox", "radio", "combobox", "slider"
  - `value` (string): Value to fill (use "true"/"false" for checkboxes)

**Usage**:
```
Fill form with fields:
[
  {"name": "First Name", "ref": "a1", "type": "textbox", "value": "John"},
  {"name": "Last Name", "ref": "a2", "type": "textbox", "value": "Doe"},
  {"name": "Subscribe", "ref": "a3", "type": "checkbox", "value": "true"},
  {"name": "Country", "ref": "a4", "type": "combobox", "value": "USA"}
]
```

**Best practices**:
- More efficient than typing into each field individually
- Get all refs from snapshot first
- Verify field types match form elements

---

### browser_select_option

Select an option in a dropdown.

**Parameters**:
- `element` (string, required): Human-readable element description
- `ref` (string, required): Exact target element reference from snapshot
- `values` (array, required): Array of values to select (supports multi-select)

**Usage**:
```
Select option ["USA"] in dropdown "Country" with ref "abc123"
Select options ["apple", "banana"] in multi-select "Fruits" with ref "def456"
```

**Best practices**:
- Use exact option values from snapshot
- For multi-select, pass array with multiple values
- Verify selection with snapshot after

---

### browser_hover

Hover over element on page.

**Parameters**:
- `element` (string, required): Human-readable element description
- `ref` (string, required): Exact target element reference from snapshot

**Usage**:
```
Hover over button "Show tooltip" with ref "abc123"
```

**Best practices**:
- Use to reveal hidden menus or tooltips
- Wait briefly after hover for UI to update

---

### browser_drag

Perform drag and drop between two elements.

**Parameters**:
- `startElement` (string, required): Human-readable source element description
- `startRef` (string, required): Exact source element reference from snapshot
- `endElement` (string, required): Human-readable target element description
- `endRef` (string, required): Exact target element reference from snapshot

**Usage**:
```
Drag "Task item" with ref "abc123" to "Completed column" with ref "def456"
```

**Best practices**:
- Get both refs from same snapshot
- Verify result with new snapshot after drag

---

## Advanced Tools

### browser_evaluate

Evaluate JavaScript expression on page or element.

**Parameters**:
- `function` (string, required): JavaScript function to execute
  - Page-level: `() => { /* code */ }`
  - Element-level: `(element) => { /* code */ }`
- `element` (string, optional): Human-readable element description (for element-level)
- `ref` (string, optional): Exact element reference (for element-level)

**Usage**:
```
Evaluate page-level: "() => { return document.title; }"
Evaluate on element "Price table" with ref "abc123": "(element) => { return element.textContent; }"
```

**Returns**: Result of the JavaScript expression

**Best practices**:
- Use for complex data extraction
- Access DOM directly when snapshot doesn't provide enough info
- Return JSON-serializable data
- Avoid modifying page state if possible

**Example - Extract table data**:
```javascript
() => {
  const table = document.querySelector('.pricing-table');
  return Array.from(table.querySelectorAll('tr')).map(row => {
    return Array.from(row.querySelectorAll('td')).map(cell => cell.textContent.trim());
  });
}
```

---

### browser_file_upload

Upload one or multiple files.

**Parameters**:
- `paths` (array, optional): Absolute paths to files to upload (omit to cancel file chooser)

**Usage**:
```
Upload files ["/path/to/file1.pdf", "/path/to/file2.jpg"]
Cancel file upload by omitting paths
```

**Best practices**:
- Use absolute paths
- Trigger file input dialog first (click file input element)
- Verify upload success after

---

### browser_handle_dialog

Handle a dialog (alert, confirm, prompt).

**Parameters**:
- `accept` (boolean, required): Whether to accept the dialog
- `promptText` (string, optional): Text for prompt dialog

**Usage**:
```
Accept dialog
Dismiss dialog
Accept prompt with text "example input"
```

**Best practices**:
- Listen for dialogs before they appear
- Respond promptly to avoid blocking

---

## Tab Management

### browser_tabs

List, create, close, or select a browser tab.

**Parameters**:
- `action` (string, required): Operation - "list", "new", "close", "select"
- `index` (number, optional): Tab index for close/select (0-based)

**Usage**:
```
List all tabs
Create new tab
Close current tab
Close tab at index 1
Select tab at index 0
```

**Best practices**:
- List tabs first to get indices
- Close tabs to free resources
- Switch tabs to handle multi-page workflows

---

## Utility Tools

### browser_wait_for

Wait for text to appear or disappear or a specified time to pass.

**Parameters** (one of):
- `text` (string, optional): Text to wait for to appear
- `textGone` (string, optional): Text to wait for to disappear
- `time` (number, optional): Time to wait in seconds

**Usage**:
```
Wait for text "Success" to appear
Wait for text "Loading..." to disappear
Wait 3 seconds
```

**Best practices**:
- Wait for dynamic content to load
- Wait for loading indicators to disappear
- Use time-based waits as last resort (prefer text-based)
- Default timeout is reasonable; don't wait unnecessarily long

---

### browser_resize

Resize the browser window.

**Parameters**:
- `width` (number, required): Width in pixels
- `height` (number, required): Height in pixels

**Usage**:
```
Resize browser to 1920x1080
```

**Best practices**:
- Test responsive layouts
- Capture full-width screenshots
- Standard sizes: 1920x1080 (desktop), 768x1024 (tablet), 375x667 (mobile)

---

### browser_close

Close the page.

**Parameters**: None

**Usage**:
```
Close browser
```

**Best practices**:
- Close browser when workflow is complete
- Clean up resources

---

### browser_install

Install the browser specified in config.

**Parameters**: None

**Usage**:
```
Install browser
```

**Best practices**:
- Call this if you get errors about browser not being installed
- Usually only needed once per environment

---

## Workflow Patterns

### Pattern 1: Navigate and Interact

```
1. browser_navigate to target URL
2. browser_snapshot to see page structure
3. browser_click on element with ref from snapshot
4. browser_wait_for expected change
5. browser_snapshot to verify new state
```

### Pattern 2: Form Filling

```
1. browser_snapshot to identify form fields
2. browser_fill_form with all field data
   OR
   browser_type into each field individually
3. browser_click submit button
4. browser_wait_for confirmation message
5. browser_snapshot to verify success
```

### Pattern 3: Data Extraction

```
1. browser_navigate to data source
2. browser_snapshot to understand structure
3. browser_evaluate to extract data with JavaScript
4. Format and return extracted data
```

### Pattern 4: Multi-Step Workflow with User Intervention

```
1. browser_navigate to starting point
2. browser_snapshot to verify page
3. [If login needed]
   a. browser_take_screenshot for user
   b. Ask user to login
   c. Wait for user confirmation
   d. browser_snapshot to verify logged in
4. Continue automated steps
5. browser_snapshot at each major step
6. Extract final result
```

### Pattern 5: Error Recovery

```
1. Try action (click, type, etc.)
2. browser_wait_for expected result
3. browser_snapshot to check outcome
4. If unexpected:
   a. browser_console_messages to check for errors
   b. browser_take_screenshot for debugging
   c. Report to user with context
   d. Ask for guidance or retry
```

## Common Pitfalls

1. **Not taking snapshots frequently**: Take snapshot after every major action
2. **Using outdated refs**: Always get refs from the latest snapshot
3. **Not waiting for page loads**: Use browser_wait_for or check snapshot for expected content
4. **Relying on screenshots for automation**: Use browser_snapshot for decisions, screenshots for user feedback
5. **Not handling dialogs**: Listen for and handle alerts/confirms promptly
6. **Clicking too fast**: Give pages time to respond between actions
7. **Ignoring console errors**: Check console when things behave unexpectedly
8. **Not verifying actions**: Always confirm actions succeeded with snapshot

## Debugging Tips

1. **Take screenshot** when behavior is unexpected
2. **Check console messages** for JavaScript errors
3. **Review network requests** to see if API calls failed
4. **Wait longer** for dynamic content (SPAs, lazy loading)
5. **Verify element refs** haven't changed due to page updates
6. **Test in isolation** - break complex workflows into smaller testable steps
7. **Ask user** for clarification if page structure is unexpected
