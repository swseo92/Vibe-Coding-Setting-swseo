# Blueprint YAML Schema

Complete schema reference for blueprint files.

## Root Fields

```yaml
name: string (required)
description: string (optional)
inputs: array (optional)
pipeline: array (required)
on_success: object (optional)
on_failure: object (optional)
```

## Input Schema

```yaml
inputs:
  - name: string (required)
    type: string|number|boolean|file|array (required)
    required: boolean (default: false)
    default: any (optional)
    description: string (optional)
```

## Pipeline Step Schema

```yaml
pipeline:
  - id: string (required, unique)
    skill: string (required)
    inputs: object (optional)
    outputs: object (optional)
    when: string (optional, expression)
    depends_on: array of step ids (optional)
    parallel: boolean (default: false)
    on_failure: stop|warn|rollback (default: stop)
    rollback: object (optional)
      action: string
      params: object
```

## Variable Syntax

Access inputs:
```
${{ inputs.FIELD_NAME }}
```

Access step outputs:
```
${{ steps.STEP_ID.outputs.FIELD_NAME }}
```

## Conditional Expressions

Supported comparisons in `when:`:
- `==` equal
- `!=` not equal
- `>` greater than
- `<` less than
- `>=` greater or equal
- `<=` less or equal

Example:
```yaml
when: ${{ steps.test.outputs.coverage >= 80 }}
```

## Complete Example

```yaml
name: "API Project Setup"
description: "Generate API client with tests and docs"

inputs:
  - name: openapi_spec
    type: file
    required: true
    description: "Path to OpenAPI 3.0 spec"

  - name: target_coverage
    type: number
    default: 80
    description: "Minimum test coverage percentage"

pipeline:
  - id: generate-client
    skill: api-client-generator
    inputs:
      spec: ${{ inputs.openapi_spec }}
      languages: [python, typescript]
    outputs:
      client_path: string

  - id: generate-tests
    skill: test-coverage-booster
    inputs:
      code_path: ${{ steps.generate-client.outputs.client_path }}
      target: ${{ inputs.target_coverage }}
    outputs:
      coverage: number
      test_count: number

  - id: quality-check
    skill: llm-decision
    when: ${{ steps.generate-tests.outputs.coverage >= inputs.target_coverage }}
    inputs:
      question: "Is code quality acceptable?"
    outputs:
      approved: boolean

  - id: generate-docs
    skill: doc-auto-generator
    when: ${{ steps.quality-check.outputs.approved == true }}
    inputs:
      source: ${{ steps.generate-client.outputs.client_path }}
    on_failure: warn
```
