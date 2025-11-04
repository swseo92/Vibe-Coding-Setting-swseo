---
name: claude-md-manager
description: Review and maintain project claude.md quality by validating against language-specific templates. Trigger when user says "커밋 리뷰", "commit review", "claude.md 검토", "review claude.md", or before committing changes. Validates completeness, consistency, and ensures language-specific best practices are present.
---

# Claude.md Manager

## Purpose

Validate and maintain project `claude.md` files by comparing them against language-specific templates. Ensure required sections are present while preserving user customizations. This skill prevents critical documentation gaps and maintains consistency across projects.

## When to Use

**Automatically trigger when:**
- User says "커밋 리뷰" or "commit review"
- User says "claude.md 검토" or "review claude.md"
- Before creating a git commit with significant changes

**Manually trigger when:**
- User explicitly requests "update claude.md"
- Setting up a new project and ensuring template compliance

## Workflow

### Step 1: Detect Project Language(s)

Identify the project language(s) by checking for language markers in priority order:

1. **Python**: Check for `pyproject.toml`, `setup.py`, or `requirements.txt`
2. **JavaScript/TypeScript**: Check for `package.json`
3. **Go**: Check for `go.mod`
4. **Rust**: Check for `Cargo.toml`
5. **Common**: Fallback if no language detected

**For multi-language projects** (e.g., Python + JavaScript fullstack):
- Detect ALL present languages
- Validate against ALL corresponding templates
- Accumulate required sections from all templates

**Implementation**:
```python
# Use Read tool to check file existence
detected_languages = []
if file_exists("pyproject.toml"):
    detected_languages.append("python")
if file_exists("package.json"):
    detected_languages.append("javascript")
# ... etc

if not detected_languages:
    detected_languages = ["common"]
```

### Step 2: Load Language Template(s)

For each detected language, load the corresponding template:

**Template locations**:
- `templates/python/claude.md`
- `templates/javascript/claude.md`
- `templates/common/claude.md` (fallback)

**Parse template metadata** (if present):
```markdown
---
required_sections:
  - "Exception Handling"
  - "환경변수 관리"
optional_sections:
  - "테스트 가이드"
---
```

If YAML frontmatter is absent, extract section names by parsing H2 headers (##).

**Use scripts/parse_markdown_sections.py**:
```bash
python .claude/skills/claude-md-manager/scripts/parse_markdown_sections.py \
  templates/python/claude.md
```

Output:
```json
{
  "sections": [
    {"name": "Exception Handling", "level": 2, "content": "..."},
    {"name": "환경변수 관리", "level": 2, "content": "..."}
  ]
}
```

### Step 3: Parse Project claude.md

Parse the project's `claude.md` (or `CLAUDE.md`) using the same script:

```bash
python .claude/skills/claude-md-manager/scripts/parse_markdown_sections.py \
  claude.md
```

Extract all H2-level sections (##) and their content.

**Handle malformed Markdown gracefully**:
- If heading levels are inconsistent (e.g., `####` without `###`), normalize to H3
- Flag anomalies in the dry-run report for manual review
- Never fail hard on parsing errors—degrade gracefully

### Step 4: Compare Sections (Append-Only Strategy)

**Core Principle: NEVER overwrite existing sections. Only add missing ones.**

For each template section:

1. **Check if section exists in project claude.md**:
   - Match by H2 header name (case-insensitive, fuzzy match allowed)
   - Example: "Exception Handling" matches "exception handling"

2. **If section exists**:
   - ✅ **Preserve it completely** (even if content differs from template)
   - Log: `"✅ 'Exception Handling' exists. Preserving user content."`
   - **Do NOT prompt user to overwrite**

3. **If section missing**:
   - Add to `missing_sections` list
   - Prepare to insert template content

**Why Append-Only?**
- User may have customized section content (e.g., added team-specific notes)
- Overwriting risks data loss
- Missing sections are safe to add (no conflict)

### Step 5: Generate Dry-Run Report

**Before making any changes**, create a preview report showing what will change.

**Use scripts/generate_dry_run_report.py**:
```bash
python .claude/skills/claude-md-manager/scripts/generate_dry_run_report.py \
  --missing "Exception Handling,환경변수 관리" \
  --custom "우리 팀 가이드,배포 프로세스" \
  --languages "python,javascript"
```

**Output format**:
```markdown
📊 claude-md-manager 검증 결과

**언어 탐지**: Python, JavaScript

✅ **누락된 필수 섹션** (3개):
  1. ## Exception Handling (Python 템플릿)
  2. ## 환경변수 관리 (Python 템플릿)
  3. ## npm Scripts (JavaScript 템플릿)

💚 **기존 커스텀 섹션** (보존됨):
  - ## 우리 팀 특화 가이드
  - ## 배포 프로세스

⚠️ **충돌**: 없음

📌 **변경사항**:
  - 3개 섹션 추가 (덮어쓰기 없음)
  - 커스텀 내용 100% 보존

적용하시겠습니까?
```

**Display this report to the user** before proceeding.

### Step 6: User Confirmation (Interactive)

**If 1-3 missing sections**: Present all at once
```
AskUserQuestion:
"3개 섹션이 누락되었습니다. 어떻게 하시겠습니까?"
Options:
  - 모두 추가
  - 개별 선택 (다음 단계에서)
  - 건너뛰기
```

**If 4-10 missing sections**: Batch by 5
```
"10개 섹션이 누락되었습니다. 첫 5개부터 확인하시겠습니까?"
```

**If 10+ missing sections**: Warn
```
"⚠️ 10개 이상 섹션이 누락되어 템플릿과 크게 다릅니다.
수동 검토를 권장합니다. 계속하시겠습니까?"
```

**Unattended mode** (CI/CD):
- If invoked with `--auto-add-missing` flag (future feature), skip confirmation
- Auto-add all missing sections
- Exit code: 0 (no changes), 1 (changes made), 2 (manual review needed)

### Step 7: Apply Changes

**For each missing section user approved**:

1. **Find insertion point**:
   - Append to end of file (safest)
   - OR insert after related sections (if heuristics available)

2. **Insert template content**:
   ```markdown
   ## Exception Handling

   [Template content here...]
   ```

3. **Preserve formatting**:
   - Match existing line endings (LF vs CRLF)
   - Maintain consistent heading style

4. **Log changes**:
   ```
   ✅ Added section: "## Exception Handling" (123 lines)
   ```

**Use Edit tool to modify claude.md**:
```python
# Read current content
current_content = read_file("claude.md")

# Append missing sections
new_content = current_content + "\n\n" + missing_section_content

# Write back
edit_file("claude.md", old_string=current_content, new_string=new_content)
```

### Step 8: Verification

After applying changes:

1. **Re-parse claude.md** to confirm sections were added
2. **Generate summary**:
   ```
   ✅ claude-md-manager 완료

   추가된 섹션:
   - ## Exception Handling (Python 템플릿)
   - ## 환경변수 관리 (Python 템플릿)

   보존된 커스텀 섹션:
   - ## 우리 팀 가이드

   파일 저장됨: claude.md
   ```

3. **Suggest next steps**:
   ```
   다음 단계:
   - 추가된 섹션 내용을 프로젝트에 맞게 커스터마이징
   - git add claude.md
   - git commit -m "docs: add missing claude.md sections"
   ```

## Edge Cases

### Multi-Language Projects

**Scenario**: Project has both `pyproject.toml` and `package.json`

**Handling**:
- Detect both Python and JavaScript
- Load both templates
- Merge required sections (union, not intersection)
- In dry-run report, indicate source template for each section

**Example**:
```
✅ 누락된 섹션 (5개):
  1. ## Exception Handling (Python 템플릿)
  2. ## 환경변수 관리 (Python 템플릿)
  3. ## npm Scripts (JavaScript 템플릿)
  4. ## ESLint 설정 (JavaScript 템플릿)
  5. ## TypeScript 설정 (JavaScript 템플릿)
```

### No Template Available

**Scenario**: Detected language has no template (e.g., Rust not yet supported)

**Handling**:
- Fallback to `templates/common/claude.md`
- Warn user:
  ```
  ⚠️ Rust 템플릿이 없습니다. 공통 템플릿으로 검증합니다.
  Rust 관련 베스트 프랙티스는 수동으로 추가하세요.
  ```

### Fuzzy Section Matching

**Scenario**: Template has "Exception Handling", project has "예외 처리"

**Handling**:
- **Phase 1 (MVP)**: Exact match only (case-insensitive)
  - "Exception Handling" ≠ "예외 처리" → Missing
- **Phase 2 (Future)**: Fuzzy matching
  - Use Levenshtein distance or keyword overlap
  - "Exception Handling" ≈ "예외 처리" → Match

### User Deleted Section Intentionally

**Scenario**: Template has "Testing Guidelines", but user intentionally removed it

**Handling**:
- Skill will detect as missing and suggest adding
- User selects "건너뛰기" during confirmation
- **Add suppression mechanism (future)**:
  ```markdown
  <!-- claude-md-manager:ignore Testing Guidelines -->
  ```

## Bundled Scripts

### scripts/parse_markdown_sections.py

**Purpose**: Parse Markdown file and extract H2/H3 sections.

**Usage**:
```bash
python parse_markdown_sections.py <markdown-file>
```

**Output**: JSON with section metadata
```json
{
  "sections": [
    {
      "name": "Exception Handling",
      "level": 2,
      "content": "Full section content...",
      "line_start": 42,
      "line_end": 78
    }
  ]
}
```

**Features**:
- Tolerant parsing (handles malformed Markdown)
- Normalizes heading levels (#### → H3 if ### missing)
- Extracts YAML frontmatter (if present)

**Dependencies**: `markdown-it-py` (install if missing)

### scripts/generate_dry_run_report.py

**Purpose**: Generate consistent dry-run report format.

**Usage**:
```bash
python generate_dry_run_report.py \
  --missing "Section1,Section2" \
  --custom "Custom1,Custom2" \
  --languages "python,javascript"
```

**Output**: Formatted Markdown report (stdout)

**Benefits**:
- Consistent formatting across runs
- Deterministic output (no AI hallucination)
- Easy to test and validate

## Quality Checklist

Before completing the skill execution, verify:

- ✅ All detected languages are reported
- ✅ Dry-run report shown before changes
- ✅ User confirmation obtained (unless --auto mode)
- ✅ No existing sections were overwritten
- ✅ Missing sections inserted correctly
- ✅ File saved and verified
- ✅ Summary provided with next steps

## Limitations (Phase 1 MVP)

**Current limitations**:
- Only H2-level section matching (no sub-sections)
- Exact name matching only (no fuzzy matching)
- No suppression mechanism (user can't mark sections as "intentionally excluded")
- No baseline tracking (can't detect template updates)

**Future enhancements (Phase 2)**:
- 3-way merge with baseline snapshots
- Paragraph-level diff within sections
- Fuzzy section name matching
- Suppression comments (`<!-- ignore:SectionName -->`)
- Template version tracking
- Metadata sync tool for template authors

## Example Run

```
User: "커밋 리뷰"

Claude (you):
[Triggers claude-md-manager skill]

1. Detecting language...
   ✅ Found: pyproject.toml → Python

2. Loading template: templates/python/claude.md
   ✅ Parsed 5 required sections

3. Parsing project claude.md...
   ✅ Found 3 sections

4. Comparing sections...
   ⚠️ Missing: "Exception Handling", "환경변수 관리"
   ✅ Custom: "우리 팀 가이드"

5. Generating dry-run report...

📊 claude-md-manager 검증 결과

**언어 탐지**: Python

✅ **누락된 필수 섹션** (2개):
  1. ## Exception Handling (Python 템플릿)
  2. ## 환경변수 관리 (Python 템플릿)

💚 **기존 커스텀 섹션** (보존됨):
  - ## 우리 팀 가이드

적용하시겠습니까?

[User selects "모두 추가"]

6. Applying changes...
   ✅ Added: "## Exception Handling"
   ✅ Added: "## 환경변수 관리"

7. Verification...
   ✅ claude.md updated successfully

✅ 완료! 다음 단계:
- 추가된 섹션을 프로젝트에 맞게 커스터마이징
- git add claude.md && git commit -m "docs: add missing sections"
```
