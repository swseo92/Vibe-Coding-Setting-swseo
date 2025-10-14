# Update Existing Persona

Update an existing persona definition file in `.claude/personas/` or `~/.claude/personas/` directory.

This command will guide you through updating a structured persona file.

**Persona Search Order:**
1. First, check local project: `.claude/personas/{ARG}.md`
2. If not found locally, check global: `~/.claude/personas/{ARG}.md`
3. Use the first match found

**Steps:**

1. **Find the persona to update:**
   - If user provides an argument (e.g., `/persona.update cofounder`), search for that persona
   - If no argument provided, list all available personas from both local and global locations:
     - Local personas tagged with `[Local]`
     - Global personas tagged with `[Global]`
   - Ask the user which persona they want to update

2. **Read and display current content:**
   - Read the existing persona file
   - Display the current structure and content
   - Show which sections exist: OBJECTIVE_AND_PERSONA, INSTRUCTIONS, CONSTRAINTS, CONTEXT, OUTPUT_FORMAT, FEW_SHOT_EXAMPLES, RECAP

3. **Collect update information:**
   Ask the user what they want to update:
   - **Option 1**: Full replacement - Provide entirely new content for the persona
   - **Option 2**: Section-by-section update - Update specific sections:
     - OBJECTIVE_AND_PERSONA
     - INSTRUCTIONS
     - CONSTRAINTS
     - CONTEXT
     - OUTPUT_FORMAT
     - FEW_SHOT_EXAMPLES
     - RECAP
   - **Option 3**: Provide new content in full structured format

4. **Update the file:**
   - Apply the changes to the persona file
   - Maintain the structured format:

```markdown
# {Persona Name}

<OBJECTIVE_AND_PERSONA>
{Updated or original content}
</OBJECTIVE_AND_PERSONA>

<INSTRUCTIONS>
{Updated or original content}
</INSTRUCTIONS>

<CONSTRAINTS>
**Dos and don'ts for the following aspects**
**1. Dos**
{Updated or original content}

**2. Don'ts**
{Updated or original content}
</CONSTRAINTS>

<CONTEXT>
{Updated or original content}
</CONTEXT>

<OUTPUT_FORMAT>
{Updated or original content}
</OUTPUT_FORMAT>

<FEW_SHOT_EXAMPLES>
{Updated or original content}
</FEW_SHOT_EXAMPLES>

<RECAP>
{Updated or original content}
</RECAP>
```

5. **Confirm the update:**
   - Show a summary of what was changed
   - Confirm the file location (local vs global)
   - Remind the user they can activate it with `/persona {name}`

**Important Notes:**
- Local personas take precedence over global personas with the same name
- If updating a global persona, changes will affect all projects
- If updating a local persona, changes only affect the current project
- The command will ask for confirmation before overwriting
- Always maintain the structured format for consistency
- If the user provides the entire updated persona content, use that directly

**Usage Examples:**
```bash
# Update a specific persona
/persona.update cofounder

# List all personas and choose one to update
/persona.update
```
