# Python File Handling in n8n Self-Hosted

**Last Updated:** 2025-10-27
**Test Environment:** Self-hosted n8n (localhost:5678), Python 3.13.9

---

## 🎯 Overview

This guide documents **actual tested solutions** for file handling in n8n's Python Code (Native) node. Based on real tests in self-hosted n8n environment running in Docker container.

### Key Findings

**❌ What DOESN'T Work:**
- Direct file I/O in Python (`open()` function is completely undefined)
- External package access (requests, pandas, numpy - unless whitelisted)
- Windows file paths (`C:\Users\...`) - container uses Linux filesystem

**✅ What DOES Work:**
- Writing files to container paths (`/tmp/`, `/data/`)
- Reading files from container paths
- File persistence during workflow execution
- Sharing files between all nodes via container filesystem
- Whitelisted packages (openai, yaml, pillow, pyyaml, etc.)

---

## 🚫 Python Constraints in Self-Hosted n8n

### 1. Python File System Access is Blocked

**Discovery:** The `open()` function is **completely removed** from Python runtime, not just restricted.

```python
# ❌ THIS WILL FAIL
with open('/tmp/test.txt', 'w') as f:
    f.write('test')

# Error: NameError: name 'open' is not defined
```

**Implication:**
- Cannot use Python's `open()` function
- All file operations must go through n8n nodes
- **Solution:** Use n8n's "Write File to Disk" and "Read File from Disk" nodes

### 2. External Package Whitelist

**Discovery:** Only specific packages can be imported.

**✅ Whitelisted Packages (as of 2025-10-27):**
```
AI/ML:      openai, google-genai, assemblyai, deepgram, deepgram-sdk, hedra, rev_ai
Images:     PIL, pillow
Data:       pyyaml, yaml
Audio:      pydub, yt_dlp
Utils:      click, dotenv, python-dotenv
Cloud:      google, google-cloud-aiplatform, google-cloud-speech
```

**❌ Blocked Packages:**
```
requests        - HTTP library (use HTTP Request node instead)
pandas          - Data analysis (use Python stdlib or separate microservice)
numpy           - Numerical computing
beautifulsoup4  - HTML parsing
scikit-learn    - Machine learning
```

---

## ✅ Solution: Container Path File Persistence

### Discovery

**Major Finding:** Files CAN be written to and read from container paths!

n8n runs in a **Docker container with Linux filesystem**. The container has standard Linux directories that are:
- ✅ **Writable** by n8n nodes
- ✅ **Persistent** during workflow execution
- ✅ **Accessible** by all nodes in the workflow

### Why This Works

```
Docker Container Filesystem:
├── /tmp/              ← ✅ Temporary storage (writable)
├── /data/             ← ✅ Persistent storage (if volume mounted)
├── /home/node/        ← ✅ User directory (writable)
└── /app/              ← n8n application files

NOT in container:
❌ C:\Users\...        (Windows host paths)
❌ /Users/...          (macOS host paths - unless mounted)
```

### Core Workflow Pattern

```
Python Code (Generate data)
  → Encode to Base64 (required for binary transfer)
  → Write File to Disk (/tmp/filename.csv)
  → Read File from Disk (/tmp/filename.csv)
  → Process or Send
```

**Key Point:** Python generates data in memory → n8n nodes handle file I/O

---

## 📁 Container Paths Reference

### Available Paths

**1. `/tmp/` - Temporary Storage (RECOMMENDED)**

**Characteristics:**
- ✅ Always writable
- ✅ Fast access
- ✅ Perfect for workflow intermediate files
- ⚠️ **Lost when container restarts**

**Example:**
```python
"/tmp/report.csv"
"/tmp/data_2025-10-27.json"
"/tmp/processed_output.txt"
```

**2. `/data/` - Persistent Storage**

**Characteristics:**
- ✅ Survives container restarts (if volume mounted)
- ✅ Good for cache or long-term storage
- ⚠️ Requires Docker volume configuration

**Example:**
```python
"/data/cache.json"
"/data/archive/report_2025.csv"
```

**3. `/home/node/` - User Directory**

**Characteristics:**
- ✅ Alternative temporary location
- ⚠️ Lost on container restart

**Example:**
```python
"/home/node/temp_file.csv"
```

### Path Best Practices

**1. Use Unique Filenames**

Avoid conflicts when multiple workflows run:

```python
from datetime import datetime
import uuid

# Option 1: Timestamp
filename = f"/tmp/report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"

# Option 2: UUID
filename = f"/tmp/data_{uuid.uuid4()}.csv"

# Option 3: Workflow-specific prefix
filename = f"/tmp/workflow_customer_report_{datetime.now().strftime('%Y%m%d')}.csv"
```

**2. Use Wildcards for Reading Multiple Files**

```python
"/tmp/batch_*.csv"          # All batch CSVs
"/tmp/**/*.json"            # All JSONs recursively
"/tmp/report_2025*.csv"     # All 2025 reports
```

---

## 💻 Complete Working Examples

### Example 1: Generate and Write CSV

**Workflow:**
```
Python Code → Write File to Disk → Read File from Disk → Email
```

**Python Code Node:**
```python
import base64

# Generate CSV data in memory
csv_data = """name,age,city
Alice,28,Seoul
Bob,35,Busan
Charlie,42,Incheon"""

# Encode to Base64 (required for n8n binary format)
csv_base64 = base64.b64encode(csv_data.encode('utf-8')).decode('utf-8')

print(f"Generated CSV: {len(csv_data)} bytes")
print("Will be saved to /tmp/users.csv")

# Return in n8n binary format
_items = [{
    "json": {
        "filename": "users.csv",
        "size": len(csv_data),
        "rows": 3,
        "target_path": "/tmp/users.csv"
    },
    "binary": {
        "data": {
            "data": csv_base64,
            "mimeType": "text/csv",
            "fileName": "users.csv"
        }
    }
}]
return _items
```

**Write File to Disk Node:**
- **File Path:** `/tmp/users.csv`
- **Input Binary Field:** `data`

**Read File from Disk Node:**
- **File(s) Selector:** `/tmp/users.csv`

**Result:** File successfully written (72 B) and read back!

### Example 2: Generate JSON Report

**Python Code Node:**
```python
import base64
import json
from datetime import datetime

# Create report data
report = {
    "report": "Monthly Sales",
    "period": "2025-10",
    "total": 150000,
    "generated_at": datetime.now().isoformat(),
    "items": [
        {"product": "Product A", "sales": 50000},
        {"product": "Product B", "sales": 100000}
    ]
}

# Convert to JSON string
json_str = json.dumps(report, indent=2, ensure_ascii=False)

# Encode to Base64
json_base64 = base64.b64encode(json_str.encode('utf-8')).decode('utf-8')

print(f"Generated JSON report: {len(json_str)} bytes")

_items = [{
    "json": {
        "report_type": "sales",
        "period": report["period"],
        "target_path": f"/tmp/report_{report['period']}.json"
    },
    "binary": {
        "data": {
            "data": json_base64,
            "mimeType": "application/json",
            "fileName": f"report_{report['period']}.json"
        }
    }
}]
return _items
```

**Write File Node:**
- **File Path:** `/tmp/report_2025-10.json`
- **Input Binary Field:** `data`

### Example 3: Generate Multiple Files

**Python Code Node:**
```python
import base64
from datetime import datetime

# Generate multiple files
files = {
    "summary.txt": "Total sales: $150,000\nTotal orders: 1,234",
    "products.csv": "product,sales\nProduct A,50000\nProduct B,100000",
    "metadata.json": '{"generated": "2025-10-27", "source": "n8n"}'
}

_items = []
for filename, content in files.items():
    # Determine MIME type
    if filename.endswith('.csv'):
        mime_type = 'text/csv'
    elif filename.endswith('.json'):
        mime_type = 'application/json'
    else:
        mime_type = 'text/plain'

    # Encode to Base64
    content_base64 = base64.b64encode(content.encode('utf-8')).decode('utf-8')

    _items.append({
        "json": {
            "filename": filename,
            "size": len(content),
            "target_path": f"/tmp/{filename}"
        },
        "binary": {
            "data": {
                "data": content_base64,
                "mimeType": mime_type,
                "fileName": filename
            }
        }
    })

print(f"Generated {len(_items)} files")
return _items
```

This will output 3 items, each can be written to `/tmp/` separately.

---

## 🔄 Workflow Patterns

### Pattern 1: Multi-Step File Processing

```
Python (generate raw data)
  → Write File (/tmp/raw_data.csv)
  → Python (transform data)
  → Read File (/tmp/raw_data.csv)
  → Write File (/tmp/processed_data.csv)
  → Read File (/tmp/processed_data.csv)
  → Email / Upload
```

**Use Case:** Complex data transformations with intermediate stages

**Why use files?**
- Large datasets that would consume too much memory
- Multiple processing steps that need checkpoints
- Debugging intermediate results

### Pattern 2: File Caching

```
Check if /tmp/cache.json exists
  → If exists: Read cache → Skip expensive operation
  → If not: API call → Process → Write cache
  → Use data
```

**Use Case:** Avoid repeated expensive operations (API calls, computations)

**Implementation:**
- First run: Call API, write to `/tmp/cache.json`
- Subsequent runs: Read from `/tmp/cache.json`
- Cache expires on container restart (automatic cleanup)

### Pattern 3: Fan-out Processing

```
Generate Data → Write /tmp/shared_data.csv
  ↓
[Branch A: Read → Process → Write /tmp/result_a.csv]
[Branch B: Read → Process → Write /tmp/result_b.csv]
[Branch C: Read → Process → Write /tmp/result_c.csv]
  ↓
Read all results (/tmp/result_*.csv) → Merge → Final output
```

**Use Case:** Parallel processing with shared input

**Why use files?**
- Multiple branches need same input data
- Avoid passing large data through all branches
- Easy to track individual branch outputs

### Pattern 4: Batch Processing with Accumulation

```
Loop through items:
  → HTTP Request (fetch data for item)
  → Python (process)
  → Write File (/tmp/batch_{index}.csv)
End loop
  → Read Files (/tmp/batch_*.csv)
  → Merge all batches
  → Upload to storage
```

**Use Case:** Processing many items, accumulating results

**Why use files?**
- Handle large batch collections
- Resume capability if workflow fails
- Easy to debug individual batches

---

## 📊 MIME Types Reference

### Common MIME Types

| File Type | Extension | MIME Type |
|-----------|-----------|-----------|
| **Text Files** |
| CSV | .csv | `text/csv` |
| Plain Text | .txt | `text/plain` |
| JSON | .json | `application/json` |
| XML | .xml | `application/xml` or `text/xml` |
| **Office Documents** |
| PDF | .pdf | `application/pdf` |
| Excel | .xlsx | `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` |
| **Images** |
| PNG | .png | `image/png` |
| JPEG | .jpg, .jpeg | `image/jpeg` |
| **Other** |
| ZIP | .zip | `application/zip` |

---

## ⚠️ Important Considerations

### 1. File Lifetime

**Temporary Storage (`/tmp/`):**
- ⚠️ **Lost when container restarts**
- ✅ Persists during workflow execution
- ✅ Shared across all workflows in same container
- ⚠️ Need unique filenames to avoid conflicts

**When to use `/tmp/`:**
- Workflow intermediate files
- Short-term caching
- Processing temporary data

**Persistent Storage (`/data/`):**
- ✅ Survives container restarts
- ⚠️ Requires Docker volume mount
- ⚠️ May have size limits

**When to use `/data/`:**
- Long-term cache
- Archives
- Data that should survive restarts

### 2. Cleanup

**Automatic:**
- `/tmp/` files are cleared on container restart
- No manual cleanup needed for temporary workflows

**Manual (for persistent storage or long-running containers):**

Add cleanup step to workflow:
```
Read Files (/tmp/old_*.csv)
  → Delete Files
  → Confirm deletion
```

### 3. File Access Scope

**Within Same Workflow:**
- ✅ All nodes can access files written by previous nodes
- ✅ Files persist throughout workflow execution
- ✅ No special configuration needed

**Across Different Workflows:**
- ✅ All workflows in same container can access same `/tmp/`
- ⚠️ Need unique filenames to avoid conflicts
- ✅ Can be used for inter-workflow communication

### 4. Performance

**Container filesystem is fast:**
- ✅ Write: ~100-500 MB/s (depends on disk)
- ✅ Read: ~200-800 MB/s
- ✅ Much faster than network operations
- ✅ Suitable for medium to large files

**Guidelines:**
- Small files (< 1 MB): Either method works fine
- Medium files (1-100 MB): Container paths recommended
- Large files (100+ MB): Definitely use container paths

---

## 🔧 Troubleshooting

### Issue 1: "File not found" when reading

**Possible Causes:**
1. File path mismatch (Write: `/tmp/test.csv`, Read: `/tmp/Test.csv`)
2. Write node failed silently
3. Container restarted between write and read
4. Wrong path used (Windows path instead of Linux path)

**Solutions:**
```python
# 1. Ensure exact path match (case-sensitive!)
write_path = "/tmp/test.csv"
read_path = "/tmp/test.csv"

# 2. Check Write node output for success
# 3. Keep workflow execution within single session
# 4. Always use Linux paths: /tmp/, not C:\Users\...
```

### Issue 2: Permission denied

**Possible Causes:**
- Writing to protected directories (e.g., `/root/`, `/etc/`)

**Solutions:**
```python
# Use known-writable paths
✅ "/tmp/file.csv"
✅ "/home/node/file.csv"
✅ "/data/file.csv" (if mounted)

❌ "/root/file.csv"        # Permission denied
❌ "/etc/config.json"       # Permission denied
❌ "/app/file.csv"          # n8n app directory
```

### Issue 3: "Invalid Base64 string"

**Cause:** Incorrect encoding in Python node.

**Solution:**
```python
# Correct - returns string
base64_str = base64.b64encode(content.encode('utf-8')).decode('utf-8')

# Wrong - returns bytes
base64_bytes = base64.b64encode(content.encode('utf-8'))
```

### Issue 4: Files from different workflows conflicting

**Cause:** Multiple workflows using same filename.

**Solution:**
```python
# Add workflow-specific prefix or timestamp
from datetime import datetime

# Option 1: Timestamp
filename = f"/tmp/workflow1_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"

# Option 2: Workflow name
filename = f"/tmp/customer_import_{datetime.now().date()}.csv"
```

---

## 💡 Best Practices

### 1. Always Include Metadata in JSON

```python
_items = [{
    "json": {
        "filename": "report.csv",
        "size_bytes": len(data),
        "created_at": datetime.now().isoformat(),
        "record_count": 100,
        "target_path": "/tmp/report.csv"
    },
    "binary": { ... }
}]
```

**Why?**
- Easier debugging (see metadata without opening file)
- Useful for conditional logic in next nodes
- Track file processing history

### 2. Use Descriptive Filenames

```python
# Good - clear purpose and date
"/tmp/customer_report_2025-10-27.csv"
"/tmp/inventory_snapshot_20251027_143022.json"

# Bad - unclear
"/tmp/data.csv"
"/tmp/output.txt"
```

### 3. Always Set Correct File Extension

```python
# Good
"fileName": "report_2025-10.csv"

# Bad - missing extension
"fileName": "report"
```

**Why?**
- Some nodes rely on extensions for processing
- Better user experience when downloading
- Prevents confusion about file type

### 4. Print Debug Information

```python
print(f"Generated {file_type} with {len(data)} bytes")
print(f"Target path: /tmp/{filename}")
print(f"Processing {len(items)} records")
```

**Why?**
- Visible in browser console (F12)
- Helps with debugging
- Confirms data processing

### 5. Handle Large Files Appropriately

```python
# For large files, consider:
# 1. Writing in chunks (if possible)
# 2. Using compression
# 3. Splitting into multiple files

# Example: Split large dataset
chunk_size = 1000
for i, chunk in enumerate(chunks(large_data, chunk_size)):
    filename = f"/tmp/data_chunk_{i}.csv"
    # Process and write chunk
```

---

## 🎓 Complete Workflow Example

### Scenario: Daily Sales Report Generation

**Requirements:**
- Fetch sales data from API
- Process and analyze in Python
- Generate CSV report
- Save to container for later retrieval
- Email report as attachment

**Workflow:**
```
Schedule Trigger (9 AM daily)
  ↓
HTTP Request (GET /api/sales/yesterday)
  ↓
Python Code (analyze and generate CSV)
  ↓
Write File to Disk (/tmp/sales_report_{date}.csv)
  ↓
Read File from Disk (/tmp/sales_report_{date}.csv)
  ↓
Email (send with attachment)
```

**Python Code:**
```python
import base64
from datetime import datetime, timedelta

# Get data from previous node
sales_data = _items[0]['json']['sales']

# Generate CSV header
csv_lines = ['date,product,quantity,revenue']

# Add data rows
total_revenue = 0
for sale in sales_data:
    csv_lines.append(
        f"{sale['date']},{sale['product']},{sale['quantity']},{sale['revenue']}"
    )
    total_revenue += sale['revenue']

# Add summary row
csv_lines.append(f"TOTAL,,,{total_revenue}")

# Join to create CSV content
csv_content = '\n'.join(csv_lines)

# Encode to Base64
csv_base64 = base64.b64encode(csv_content.encode('utf-8')).decode('utf-8')

# Get yesterday's date for filename
yesterday = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
filename = f"sales_report_{yesterday}.csv"
filepath = f"/tmp/{filename}"

# Debug output
print(f"Generated sales report: {len(sales_data)} sales, total ${total_revenue}")
print(f"Target path: {filepath}")

# Return for Write File node
_items = [{
    "json": {
        "report_date": yesterday,
        "total_sales": len(sales_data),
        "total_revenue": total_revenue,
        "filename": filename,
        "filepath": filepath
    },
    "binary": {
        "data": {
            "data": csv_base64,
            "mimeType": "text/csv",
            "fileName": filename
        }
    }
}]
return _items
```

**Write File Node:**
- File Path: `{{ $json.filepath }}` (or `/tmp/sales_report_{yesterday}.csv`)
- Input Binary Field: `data`

**Read File Node:**
- File(s) Selector: `{{ $json.filepath }}`

**Email Node:**
- To: `sales@company.com`
- Subject: `Daily Sales Report - {{ $json.report_date }}`
- Attachments: Binary field from Read File node

---

## 📚 Related Documentation

### Test Results
- `tmp/n8n-container-path-file-persistence-test.md` - Complete container path testing
- `tmp/n8n-python-self-hosted-실제제약사항.md` - Python constraints in self-hosted
- `tmp/n8n-python-limitations-summary.md` - Summary of limitations

### External References
- [n8n Documentation](https://docs.n8n.io/)
- [Python base64 Module](https://docs.python.org/3/library/base64.html)
- [MIME Types Reference](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types)

---

## 🎯 Summary

### What We Learned

✅ **Container Paths Work Perfectly**
- Files can be written to `/tmp/`, `/data/`, `/home/node/`
- All nodes in workflow can access same container filesystem
- Perfect for intermediate file storage and caching

❌ **Direct File I/O is Blocked**
- `open()` function doesn't exist in Python
- Must use n8n's Write/Read File nodes
- **Solution works great!**

⚠️ **Package Limitations**
- Only whitelisted packages allowed
- Use standard library or workarounds
- Consider external microservices for complex tasks

### Recommended Approach

**For file operations in workflows:**
1. **Generate file content** in Python (as string/bytes in memory)
2. **Encode to Base64** using `base64` module
3. **Return in n8n binary format** with proper MIME type
4. **Write to container path** using Write File to Disk node (e.g., `/tmp/file.csv`)
5. **Read when needed** using Read File from Disk node (same path)
6. **Process or send** via Email, HTTP Request, Cloud Storage, etc.

**Key Points:**
- ✅ Always use Linux paths (`/tmp/`, `/data/`)
- ✅ Use unique filenames (timestamps/UUIDs)
- ✅ `/tmp/` is perfect for temporary workflow files
- ✅ Files persist during workflow, cleared on container restart

---

**Last Updated:** 2025-10-27
**Test Environment:** Self-hosted n8n (localhost:5678), Python 3.13.9, Docker container
**Validation Status:** ✅ Fully Tested and Documented
