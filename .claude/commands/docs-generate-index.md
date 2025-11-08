---
runOnStart: false
---

# Generate Documentation Index

Create or update the central documentation index (`docs/index.md`) by scanning all README files in the project.

## What This Does

1. **Scans** all README files listed in `.readme-config.json`
2. **Categorizes** them by folder structure (Architecture, API, Guides, etc.)
3. **Extracts** titles from each README
4. **Generates** `docs/index.md` with:
   - Categorized table of contents
   - Quick reference by task type
   - Documentation statistics
   - Auto-generation timestamp

## Prerequisites

- `.readme-config.json` exists at project root
- At least one README file exists in target folders

## Execution

Use the `documentation-manager` skill with `--generate-index` flag:

```bash
# Read .readme-config.json
if [ ! -f ".readme-config.json" ]; then
  echo "❌ Error: .readme-config.json not found"
  echo "Run /documentation-manager --init-config first"
  exit 1
fi

# Parse targets from .readme-config.json
TARGETS=$(cat .readme-config.json | grep -A 100 '"targets"' | grep -o '"[^"]*/"' | tr -d '"')

# Find all README.md files in targets
READMES=""
for target in $TARGETS; do
  if [ -f "${target}README.md" ]; then
    READMES="$READMES ${target}README.md"
  fi
done

# Count READMEs
README_COUNT=$(echo "$READMES" | wc -w)
TOTAL_TARGETS=$(echo "$TARGETS" | wc -w)

echo "📊 Found $README_COUNT READMEs in $TOTAL_TARGETS target folders"

# Generate index using Codex
CODEX_PROMPT="Generate a documentation index for this project.

## Task

Create \`docs/index.md\` with the following structure:

\`\`\`markdown
<!-- AUTO-GENERATED: Do not edit manually! -->
<!-- Generated: $(date '+%Y-%m-%d %H:%M:%S') -->
<!-- Command: /docs-generate-index -->

# Project Documentation Index

## 📚 Overview
[Extract project description from claude.md if exists, otherwise use project root folder name]

## 🗂️ Documentation Categories

[Categorize READMEs found in: $READMES]

Use these categories:
- **Architecture**: folders matching *architecture*, *arch*, *design*
- **API Documentation**: folders matching *api*, *endpoints*, *routes*
- **Guides**: folders matching *guides*, *tutorials*, *docs*
- **Source Code**:
  - **Models**: folders matching *models*, *entities*
  - **Services**: folders matching *services*, *logic*
  - **Utilities**: folders matching *utils*, *helpers*
- **Testing**: folders matching *tests*, *testing*

For each README:
1. Read the first # heading for title
2. Add brief description (2nd line or first paragraph)
3. Create link: [Title](relative/path/to/README.md) - Description

## 🔍 Quick Reference

Create task-based shortcuts by analyzing folder names:
- **Authentication** → List auth-related folders
- **API** → List API-related folders
- **Database** → List model/migration folders
- **Testing** → List test folders

## 📊 Documentation Statistics
- Total folders: $TOTAL_TARGETS
- Documented folders: $README_COUNT (X%)
- Last updated: $(date '+%Y-%m-%d')
\`\`\`

## READMEs to index:
$READMES

## Instructions

1. Read each README file
2. Extract title (first # heading)
3. Categorize by folder path
4. Generate the index markdown above
5. Save to \`docs/index.md\`

**IMPORTANT**:
- Use Korean for category names and descriptions if claude.md is in Korean
- Keep links relative (e.g., ../src/models/README.md)
- Calculate documentation coverage percentage
- Add generation timestamp"

# Execute Codex
~/.claude/scripts/codex-session.sh new "$CODEX_PROMPT"
```

## After Generation

1. **Review**: Check `docs/index.md` for accuracy
2. **Commit**:
   ```bash
   git add docs/index.md
   git commit -m "docs: update documentation index"
   ```
3. **Update** `claude.md` with navigation guide (see below)

## Add to claude.md

```markdown
## Documentation Navigation

**New to this project? Start here:**

1. **Read** `docs/index.md` - Central documentation index
2. **Identify** relevant category (Architecture, API, Guides)
3. **Navigate** to specific README for your task
4. **Deep dive** into related docs as needed

**Example workflow for adding authentication:**
1. Check `docs/index.md` → "Quick Reference" section
2. Follow link to `src/auth/README.md`
3. Review `docs/architecture/security.md` for context
4. Implement feature

**Optimization**: Only read READMEs relevant to your task (use index categories)
```

## Automation

**GitHub Actions** (Optional):

```yaml
name: Update Documentation Index

on:
  push:
    paths:
      - '**/README.md'
      - '.readme-config.json'

jobs:
  update-index:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Generate Index
        run: /docs-generate-index
      - name: Commit if changed
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add docs/index.md
          git diff --staged --quiet || git commit -m "docs: update documentation index [skip ci]"
          git push
```

## Troubleshooting

**"Command not found"**: Ensure `~/.claude/scripts/codex-session.sh` exists
**"No READMEs found"**: Check `.readme-config.json` targets
**"Index not generated"**: Review Codex output for errors

## Cost

- **~$0.01** per run (Codex API cost)
- **5-15 seconds** execution time

---

**Related**:
- `/documentation-manager --recursive-readme` - Generate folder READMEs
- `/documentation-manager --check-recursive` - Validate existing READMEs
