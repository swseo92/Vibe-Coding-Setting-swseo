# Persona Switcher

Read the persona definition file where {ARG} is the argument provided by the user (e.g., `/persona cofounder`).

**Persona Search Order:**
1. First, check for the persona in the local project: `.claude/personas/{ARG}.md`
2. If not found locally, check the global system directory:
   - Linux/macOS: `~/.claude/personas/{ARG}.md` (resolves to `/home/{user}/.claude/personas/` or `/Users/{user}/.claude/personas/`)
   - Windows: `~/.claude/personas/{ARG}.md` (resolves to `C:\Users\{user}\.claude\personas\`)
3. Use the first match found

**Implementation Note:**
Use `~/.claude/personas/` in the search path - the shell will automatically resolve `~` to the appropriate home directory for the current OS.

After reading the persona file, adopt that persona's role, characteristics, and instructions for the rest of this conversation until the user switches to a different persona or explicitly asks you to stop.

**Listing Available Personas:**
If no argument is provided or the persona file doesn't exist in both locations:
1. Search for .md files in `.claude/personas/` (local project)
2. Search for .md files in `~/.claude/personas/` (global system)
3. Display a combined list showing:
   - Local personas with a `[Local]` tag
   - Global personas with a `[Global]` tag
4. Ask the user which one they'd like to use

**Important Notes:**
- Once you adopt a persona, maintain that persona consistently throughout the conversation until switched
- Local personas take precedence over global personas with the same name
- When listing personas, clearly indicate which are local and which are global
