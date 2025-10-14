# Add New Persona

Create a new persona definition file in `.claude/personas/` directory.

This command will guide you through creating a structured persona file that can be used with the `/persona` command.

Steps:
1. Ask the user for the persona name (this will be the filename)
2. Collect the following information interactively:
   - **Objective and Role**: What is this persona's main purpose and role?
   - **Key Characteristics**: What are the defining traits of this persona?
   - **Instructions**: What specific steps or behaviors should this persona follow?
   - **Constraints**: What are the dos and don'ts for this persona?
   - **Context**: What context or background information is relevant?
   - **Output Format**: How should this persona format their responses?
   - **Examples** (optional): Any example interactions?

3. Create the persona file at `.claude/personas/{name}.md` with the following structure:

```markdown
# {Persona Name}

<OBJECTIVE_AND_PERSONA>
{Description of the persona's objective and role}
</OBJECTIVE_AND_PERSONA>

<INSTRUCTIONS>
{Specific instructions and steps the persona should follow}
</INSTRUCTIONS>

<CONSTRAINTS>
**Dos and don'ts for the following aspects**
**1. Dos**
{List of things the persona should do}

**2. Don'ts**
{List of things the persona should avoid}
</CONSTRAINTS>

<CONTEXT>
{Relevant context and background information}
</CONTEXT>

<OUTPUT_FORMAT>
{How the persona should format their responses}
</OUTPUT_FORMAT>

<FEW_SHOT_EXAMPLES>
{Optional: Example interactions demonstrating the persona}
</FEW_SHOT_EXAMPLES>

<RECAP>
{Re-emphasize key aspects, constraints, and output format}
</RECAP>
```

4. After creating the file, confirm the creation and remind the user they can activate it with `/persona {name}`

Important notes:
- The persona name should be lowercase and use hyphens for spaces (e.g., "code-reviewer")
- If the persona file already exists, ask the user if they want to overwrite it
- Always use the structured format shown above for consistency
- Make sure to create the `.claude/personas/` directory if it doesn't exist
