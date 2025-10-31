---
name: blueprint-orchestrator
description: Execute multi-skill pipelines defined in YAML blueprints with variable substitution, conditional execution, and state management. This skill should be used when users request running blueprint files or automated multi-step workflows.
---

# Blueprint Orchestrator

Execute complex, multi-step workflows by orchestrating Claude Code skills according to YAML blueprint definitions.

## When to Use

This skill should be used when:
- User provides a blueprint YAML file path
- User requests "run this blueprint" or "execute this pipeline"
- User wants to automate a multi-skill workflow
- User needs to chain multiple skills together with data flow

## Blueprint Structure

Blueprints define workflows with:
- **inputs**: Required variables provided by user
- **pipeline**: Ordered steps calling skills
- **state management**: Outputs passed between steps via `${{ variable }}` syntax
- **failure handling**: `stop`/`warn`/`rollback` directives per step

For detailed schema, read `references/schema.md` when needed.

## Execution Process

### Step 1: Load Blueprint

To load a blueprint file:
1. Use Read tool on the blueprint path provided by user
2. Parse YAML using `scripts/parse_blueprint.py` via Bash tool
3. Store parsed structure in memory

```bash
python .claude/skills/blueprint-orchestrator/scripts/parse_blueprint.py < blueprint.yaml > parsed.json
```

If script fails, fall back to manual YAML parsing with Read tool.

### Step 2: Initialize Execution State

Create state tracking map:
1. Initialize empty state dictionary with blueprint inputs
2. Create `scratch/` directory using Bash tool if needed
3. Write initial state to `scratch/bp-state.json` using Write tool

State format:
```json
{
  "inputs": {
    "project_name": "my-api",
    "openapi_spec": "spec.yaml"
  },
  "steps": {}
}
```

### Step 3: Execute Pipeline Steps

For each step in the pipeline, perform these actions in order:

#### A. Resolve Variables

To substitute `${{ variable }}` tokens:
1. Use Read tool to load current state from `scratch/bp-state.json`
2. Call `scripts/render_template.py` to resolve tokens in step inputs
3. Replace tokens with actual values from state

```bash
python .claude/skills/blueprint-orchestrator/scripts/render_template.py \
  --template "$input_text" \
  --state scratch/bp-state.json
```

If script fails, manually replace `${{ steps.STEP_ID.outputs.FIELD }}` patterns with values from state dictionary.

#### B. Evaluate Conditions

If step has `when:` expression:
1. Resolve variables in the condition expression
2. Evaluate the resulting boolean expression
3. Skip step if evaluation is false
4. Mark step as "skipped" in state

#### C. Invoke Skill

To call the skill defined in the step:
1. Prepare inputs with all variables resolved
2. Log the skill invocation (skill name and inputs)
3. Use Skill tool with the skill name from blueprint
4. Capture the complete response from the skill

#### D. Extract Outputs

To parse skill response for outputs:
1. Look for structured data in JSON blocks or markdown code blocks
2. Extract key information mentioned in skill response
3. Normalize outputs to consistent format
4. If output is ambiguous, prompt the skill again requesting JSON format
5. Store best-effort extraction even if partial

#### E. Update State

To persist step results:
1. Add step outputs to state map under `steps.STEP_ID.outputs`
2. Set step status to "completed", "failed", or "skipped"
3. Use Write tool to save updated state to `scratch/bp-state.json`

Example state after step completion:
```json
{
  "inputs": {...},
  "steps": {
    "generate-client": {
      "status": "completed",
      "outputs": {
        "client_path": "generated/"
      }
    }
  }
}
```

#### F. Handle Failures

If step execution fails, check `on_failure` directive:
- **stop**: Report error to user and abort pipeline immediately
- **warn**: Log warning message and continue to next step
- **rollback**: Attempt to reverse step effects if rollback action is defined, then stop

### Step 4: Complete Execution

After all steps execute or pipeline stops:
1. Generate execution summary showing:
   - Total steps executed
   - Successful steps with key outputs
   - Failed or skipped steps with reasons
2. Report final pipeline status (success/partial/failed)
3. List any warnings encountered
4. Optionally clean up `scratch/` directory (ask user first)

## Data Flow Pattern

Variables flow between steps using `${{ ... }}` syntax:

```yaml
pipeline:
  - id: generate
    skill: api-client-generator
    inputs:
      spec: ${{ inputs.openapi_spec }}    # From blueprint inputs
    outputs:
      client_path: generated/

  - id: test
    skill: test-generator
    inputs:
      code_path: ${{ steps.generate.outputs.client_path }}  # From previous step
```

Execution:
1. Step "generate": Produces `{client_path: "generated/"}`
2. State updated: `steps.generate.outputs.client_path = "generated/"`
3. Step "test": Token `${{ steps.generate.outputs.client_path }}` resolves to `"generated/"`
4. Test generator receives `code_path: "generated/"`

## Conditional Execution

Handle `when:` expressions to skip steps based on state:

```yaml
- id: fix-issues
  skill: auto-fixer
  when: ${{ steps.test.outputs.passed == false }}
```

Processing:
1. Resolve variables: `${{ steps.test.outputs.passed == false }}` → `true == false`
2. Evaluate: `true == false` → `false`
3. Skip step "fix-issues" and mark as skipped

## Parallel Simulation

Steps marked `parallel: true` indicate logical independence:

```yaml
- id: test
  parallel: true
- id: lint
  parallel: true
```

Execution approach:
1. Group consecutive steps marked `parallel: true`
2. Execute them sequentially (Claude operates linearly)
3. Tag outputs to indicate they were logically parallel
4. Continue pipeline after all "parallel" steps complete

Note: True concurrent execution is not supported. The parallel flag documents logical independence and enables future optimization.

## Bundled Resources

### scripts/parse_blueprint.py

Converts YAML blueprint to JSON for reliable parsing.

**Usage**:
```bash
python .claude/skills/blueprint-orchestrator/scripts/parse_blueprint.py < blueprint.yaml
```

**When to use**: Always try this first for consistent YAML parsing. Fall back to manual parsing only if script fails.

### scripts/render_template.py

Substitutes `${{ variable }}` tokens with values from state.

**Usage**:
```bash
python .claude/skills/blueprint-orchestrator/scripts/render_template.py \
  --template "text with ${{ tokens }}" \
  --state scratch/bp-state.json
```

**When to use**: For every step input that contains `${{ ... }}` syntax. Fall back to manual string replacement if script fails.

### references/schema.md

Complete blueprint YAML schema with field descriptions and examples.

**When to use**: Read this when user asks about blueprint structure, or when encountering unfamiliar blueprint fields.

### references/examples/

Sample blueprints for common workflows.

**When to use**: Show these to users as starting points, or read them to understand blueprint patterns.

### assets/templates/

Basic blueprint templates users can copy and customize.

**When to use**: Offer these when user wants to create a new blueprint.

## Error Handling

### When Scripts Fail

If `parse_blueprint.py` or `render_template.py` fail:
1. Log the failure for debugging
2. Fall back to manual processing:
   - Manual YAML parsing with Read tool
   - Manual variable substitution with string operations
3. Continue execution with best effort
4. Inform user that scripts failed but processing continued

### When Skills Fail

If a skill invocation fails:
1. Check step's `on_failure` directive
2. Update state with failure status
3. Take appropriate action (stop/warn/rollback)
4. Report clear error message to user

## Best Practices

When executing blueprints:

1. **Validate inputs first**: Check all required blueprint inputs are provided before starting
2. **Log progress clearly**: Report each step completion with brief summary
3. **Handle errors gracefully**: Don't silently fail; inform user of issues
4. **Preserve state**: Always save state after each step for debugging
5. **Clean summaries**: Provide concise final summary focused on outcomes

## Example Usage

**User request**: "Run the API project blueprint"

**Execution workflow**:

1. "Loading blueprint from `.claude/blueprints/api-project.yaml`..."
   - Read YAML file
   - Parse with script
   - Validate structure

2. "Initializing execution state..."
   - Create scratch/bp-state.json
   - Store inputs

3. "Step 1/4: Generating API client..."
   - Resolve: `${{ inputs.openapi_spec }}` → `"spec.yaml"`
   - Invoke: Skill tool with "api-client-generator"
   - Capture: `{client_path: "generated/"}`
   - Update state

4. "Step 2/4: Creating tests..."
   - Resolve: `${{ steps.generate-client.outputs.client_path }}` → `"generated/"`
   - Invoke: Skill tool with "test-coverage-booster"
   - Capture: `{coverage: 85}`
   - Update state

5. "Step 3/4: Running security scan..."
   - Check condition: `when: ${{ steps.generate-tests.outputs.coverage >= 80 }}`
   - Evaluate: `85 >= 80` → `true`
   - Invoke: Skill tool with "security-auditor"
   - Update state

6. "Step 4/4: Generating documentation..."
   - Invoke: Skill tool with "doc-auto-generator"
   - Update state

7. "Blueprint execution complete!"
   ```
   Summary:
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ✓ API client generated: generated/
   ✓ Test coverage: 85%
   ✓ Security scan: 0 issues
   ✓ Documentation: docs/
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

## Troubleshooting

**Blueprint not found**:
- Verify file path is correct
- Check file has `.yaml` or `.yml` extension
- Ensure file is readable

**Variable not resolving**:
- Check state file `scratch/bp-state.json` for available outputs
- Verify step ID matches exactly
- Ensure previous step completed successfully

**Script errors**:
- Check Python is available on PATH
- Verify script file permissions
- Review script output for specific error
- Fall back to manual processing

**Skill not found**:
- Verify skill name matches exactly
- Check skill is installed
- Ensure no typos in blueprint

**State corruption**:
- Delete `scratch/bp-state.json` and restart
- Check for disk space issues
- Verify Write tool permissions

## Output Format Requirements

**CRITICAL**: You MUST provide detailed, structured progress logging throughout execution. Users need visibility into each phase.

### Phase 1: Initialization

When starting blueprint execution, output:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BLUEPRINT INITIALIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Loading blueprint: {blueprint_name}
├─ Reading file... ✓
├─ Parsing YAML with parse_blueprint.py... ✓ (or: ⚠ fallback to manual)
├─ Validating structure... ✓
└─ Initializing state at scratch/bp-state.json... ✓
```

### Phase 2: Input Processing

Show each input with its value:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INPUTS LOADED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✓ {input_name}: "{value}"
  ✓ {another_input}: {number}

[Show ALL inputs that were loaded]
```

### Phase 3: Step Execution

For EACH step, provide this detailed output:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Step {N}/{TOTAL}: {step_id}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Resolving variables...
   ${{ inputs.message }} → "Hello"
   ${{ steps.prev.outputs.data }} → "result123"
   [Show EACH variable resolution]

2. Checking conditions...
   when: ${{ steps.test.outputs.coverage >= 80 }}
   Evaluated: 85 >= 80 → true
   Result: EXECUTE (or: SKIP)

3. Invoking skill: {skill_name}
   Inputs:
     - param1: "value1"
     - param2: "value2"

4. Skill response...
   [Brief summary of what the skill did]

5. Capturing outputs...
   ✓ {output_key}: {output_value}
   [Show EACH output captured]

6. Updating state... ✓
   Duration: {X.X}s

Status: ✓ COMPLETED (or: ✗ FAILED, or: ⊘ SKIPPED)
```

**If step fails:**
```
5. Error encountered... ✗
   Error: {error_message}
   on_failure: {stop|warn|rollback}
   Action: {description of what happens next}
```

### Phase 4: Final Summary

After all steps complete:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EXECUTION COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Blueprint: {blueprint_name}
Status: {SUCCESS|PARTIAL|FAILED}

SUMMARY:
  Total steps: {N}
  ✓ Completed: {X}
  ✗ Failed: {Y}
  ⊘ Skipped: {Z}

  Total duration: {XX.X}s

KEY OUTPUTS:
  ✓ {important_output_1}: {value}
  ✓ {important_output_2}: {value}
  [List the most important outputs from the workflow]

State saved to: scratch/bp-state.json
```

### Logging Requirements

1. **Always show variable resolution**: Don't just show final values, show the transformation
   - Bad: `text="Hello"`
   - Good: `${{ inputs.message }} → "Hello"`

2. **Always show script usage**: Make it clear when scripts are used vs manual fallback
   - `Parsing YAML with parse_blueprint.py... ✓`
   - `Resolving variables with render_template.py... ✓`
   - `Script failed, using manual parsing... ⚠`

3. **Always show timing**: Include duration for each step and total
   - `Duration: 2.3s` (per step)
   - `Total duration: 45.7s` (final summary)

4. **Always show status clearly**: Use consistent symbols
   - ✓ = Success
   - ✗ = Failure
   - ⊘ = Skipped
   - ⚠ = Warning

5. **Always structure with boxes**: Use ━━━ separators for major sections

This level of detail is REQUIRED for all blueprint executions.
