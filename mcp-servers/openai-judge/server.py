#!/usr/bin/env python3
"""
OpenAI Judge MCP Server

Provides tools for using OpenAI models as LLM judges for code review.
"""

import os
from typing import Any

from mcp.server.fastmcp import FastMCP
from openai import OpenAI
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize FastMCP server
mcp = FastMCP("openai-judge")

# Initialize OpenAI client
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


@mcp.tool()
def review_code(
    code: str,
    context: str = "",
    model: str = "gpt-4-turbo-preview",
    review_aspects: str = "bugs,security,performance,readability,best-practices",
) -> dict[str, Any]:
    """
    Review code using OpenAI as an LLM judge.

    Args:
        code: The code to review (can be a diff or full code)
        context: Additional context about the code (e.g., file path, purpose)
        model: OpenAI model to use (gpt-4-turbo-preview, gpt-3.5-turbo, o1-preview)
        review_aspects: Comma-separated aspects to review

    Returns:
        dict with:
            - overall_score: 0-100
            - severity_counts: {critical, warning, suggestion}
            - issues: List of found issues
            - recommendation: commit/needs_work/major_refactor
            - summary: Brief summary
    """
    aspects = [a.strip() for a in review_aspects.split(",")]

    system_prompt = f"""You are an expert code reviewer acting as an LLM judge.
Your task is to review code critically and objectively.

Review the following aspects: {', '.join(aspects)}

Provide your review in this exact JSON format:
{{
    "overall_score": <0-100>,
    "severity_counts": {{
        "critical": <count>,
        "warning": <count>,
        "suggestion": <count>
    }},
    "issues": [
        {{
            "severity": "critical|warning|suggestion",
            "aspect": "bugs|security|performance|readability|best-practices",
            "line": <line number or null>,
            "description": "...",
            "suggestion": "..."
        }}
    ],
    "recommendation": "commit|needs_work|major_refactor",
    "summary": "Brief overall assessment"
}}

Be critical and thorough. Your job is to find problems, not to praise.
"""

    user_prompt = f"""Review this code:

{context}

```
{code}
```

Provide a detailed code review as JSON."""

    try:
        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0.3,  # Lower temperature for more consistent reviews
            response_format={"type": "json_object"},
        )

        result = response.choices[0].message.content

        # Parse and validate JSON
        import json
        review_result = json.loads(result)

        return review_result

    except Exception as e:
        return {
            "error": str(e),
            "overall_score": 0,
            "severity_counts": {"critical": 0, "warning": 0, "suggestion": 0},
            "issues": [],
            "recommendation": "error",
            "summary": f"Error during review: {str(e)}",
        }


@mcp.tool()
def compare_code_versions(
    original_code: str,
    modified_code: str,
    context: str = "",
    model: str = "gpt-4-turbo-preview",
) -> dict[str, Any]:
    """
    Compare two versions of code and assess if changes are improvements.

    Args:
        original_code: Original version of the code
        modified_code: Modified version of the code
        context: Additional context
        model: OpenAI model to use

    Returns:
        dict with:
            - is_improvement: bool
            - improvement_score: -100 to 100 (negative = worse)
            - improvements: List of positive changes
            - regressions: List of negative changes
            - summary: Brief comparison
    """
    system_prompt = """You are an expert code reviewer comparing two versions of code.
Assess whether the modified version is an improvement over the original.

Provide your assessment in this exact JSON format:
{
    "is_improvement": <true|false>,
    "improvement_score": <-100 to 100>,
    "improvements": ["...", "..."],
    "regressions": ["...", "..."],
    "summary": "Brief assessment"
}

Be objective. Consider: readability, maintainability, performance, correctness, security.
"""

    user_prompt = f"""Compare these code versions:

{context}

ORIGINAL:
```
{original_code}
```

MODIFIED:
```
{modified_code}
```

Assess if the modified version is better."""

    try:
        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0.3,
            response_format={"type": "json_object"},
        )

        result = response.choices[0].message.content

        import json
        comparison_result = json.loads(result)

        return comparison_result

    except Exception as e:
        return {
            "error": str(e),
            "is_improvement": False,
            "improvement_score": 0,
            "improvements": [],
            "regressions": [],
            "summary": f"Error during comparison: {str(e)}",
        }


@mcp.tool()
def suggest_improvements(
    code: str,
    issues: str = "",
    context: str = "",
    model: str = "gpt-4-turbo-preview",
) -> dict[str, Any]:
    """
    Get specific code improvement suggestions from OpenAI.

    Args:
        code: The code to improve
        issues: Known issues to address (from review_code)
        context: Additional context
        model: OpenAI model to use

    Returns:
        dict with:
            - improved_code: Suggested improved version
            - changes_made: List of changes
            - explanation: Why these changes improve the code
    """
    system_prompt = """You are an expert code refactoring assistant.
Provide improved code that addresses the issues while maintaining functionality.

Provide your response in this exact JSON format:
{
    "improved_code": "...",
    "changes_made": ["...", "..."],
    "explanation": "Why these changes are improvements"
}
"""

    issues_context = f"\n\nKnown issues to address:\n{issues}" if issues else ""

    user_prompt = f"""Improve this code:

{context}{issues_context}

ORIGINAL CODE:
```
{code}
```

Provide improved version with explanations."""

    try:
        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0.5,
            response_format={"type": "json_object"},
        )

        result = response.choices[0].message.content

        import json
        improvement_result = json.loads(result)

        return improvement_result

    except Exception as e:
        return {
            "error": str(e),
            "improved_code": code,
            "changes_made": [],
            "explanation": f"Error generating improvements: {str(e)}",
        }


if __name__ == "__main__":
    # Run the MCP server
    mcp.run()
