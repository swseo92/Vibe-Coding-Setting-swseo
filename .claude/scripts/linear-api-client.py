#!/usr/bin/env python3
"""
Complete Linear API Client

Complements Linear MCP by providing ALL write operations.
MCP: Read-heavy operations
API: Write operations (create, update, delete, archive)

Usage:
    # Document operations
    python linear-api-client.py document create --title "My Doc" --content "# Hello"
    python linear-api-client.py document update --id DOC-123 --content "# Updated"
    python linear-api-client.py document delete --id DOC-123

    # Issue operations
    python linear-api-client.py issue delete --id ISSUE-123
    python linear-api-client.py issue archive --id ISSUE-123

    # Comment operations
    python linear-api-client.py comment update --id abc-123 --body "Updated comment"
    python linear-api-client.py comment delete --id abc-123

    # Cycle operations
    python linear-api-client.py cycle create --team TEAM-123 --name "Sprint 42"
    python linear-api-client.py cycle update --id CYCLE-123 --name "Sprint 42 Extended"

    # And many more...

Requirements:
    pip install requests python-dotenv
"""

import os
import sys
import json
import argparse
from typing import Optional, Dict, Any, List
from datetime import datetime

try:
    import requests
    from dotenv import load_dotenv
except ImportError:
    print("ERROR: Missing dependencies. Install with:")
    print("  pip install requests python-dotenv")
    sys.exit(1)

# Load environment variables from .env
load_dotenv()

# Linear GraphQL API endpoint
LINEAR_API_URL = "https://api.linear.app/graphql"
LINEAR_API_KEY = os.getenv("LINEAR_API_KEY")

if not LINEAR_API_KEY:
    print("ERROR: LINEAR_API_KEY not found in environment variables")
    print("Please set it in .env file or export it:")
    print("  export LINEAR_API_KEY='lin_api_...'")
    sys.exit(1)


class LinearAPIClient:
    """Complete Linear API client with all operations"""

    def __init__(self, api_key: str):
        self.api_key = api_key
        self.headers = {
            "Authorization": api_key,
            "Content-Type": "application/json",
        }

    def _execute_query(self, query: str, variables: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Execute a GraphQL query against Linear API"""
        payload = {"query": query}
        if variables:
            payload["variables"] = variables

        response = requests.post(
            LINEAR_API_URL,
            json=payload,
            headers=self.headers,
            timeout=30
        )

        if response.status_code != 200:
            raise Exception(f"API request failed: {response.status_code} - {response.text}")

        result = response.json()

        if "errors" in result:
            errors = result["errors"]
            error_messages = [err.get("message", str(err)) for err in errors]
            raise Exception(f"GraphQL errors: {', '.join(error_messages)}")

        return result.get("data", {})

    # ========== DOCUMENT OPERATIONS ==========

    def create_document(
        self,
        title: str,
        content: str,
        content_data: Optional[Dict] = None,
        project_id: Optional[str] = None,
        icon: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Create a new Linear document"""
        mutation = """
        mutation DocumentCreate($input: DocumentCreateInput!) {
            documentCreate(input: $input) {
                success
                document {
                    id
                    title
                    content
                    url
                    createdAt
                    updatedAt
                }
            }
        }
        """

        input_data = {"title": title, "content": content}
        if content_data:
            input_data["contentData"] = content_data
        if project_id:
            input_data["projectId"] = project_id
        if icon:
            input_data["icon"] = icon

        variables = {"input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("documentCreate", {})

    def update_document(
        self,
        document_id: str,
        title: Optional[str] = None,
        content: Optional[str] = None,
        content_data: Optional[Dict] = None,
        icon: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update an existing Linear document"""
        mutation = """
        mutation DocumentUpdate($id: String!, $input: DocumentUpdateInput!) {
            documentUpdate(id: $id, input: $input) {
                success
                document {
                    id
                    title
                    content
                    url
                    updatedAt
                }
            }
        }
        """

        input_data = {}
        if title is not None:
            input_data["title"] = title
        if content is not None:
            input_data["content"] = content
        if content_data is not None:
            input_data["contentData"] = content_data
        if icon is not None:
            input_data["icon"] = icon

        if not input_data:
            raise ValueError("At least one field must be provided for update")

        variables = {"id": document_id, "input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("documentUpdate", {})

    def delete_document(self, document_id: str) -> Dict[str, Any]:
        """Delete (trash) a Linear document"""
        mutation = """
        mutation DocumentDelete($id: String!) {
            documentDelete(id: $id) {
                success
            }
        }
        """
        variables = {"id": document_id}
        result = self._execute_query(mutation, variables)
        return result.get("documentDelete", {})

    def archive_document(self, document_id: str) -> Dict[str, Any]:
        """Archive a Linear document"""
        mutation = """
        mutation DocumentArchive($id: String!) {
            documentArchive(id: $id) {
                success
            }
        }
        """
        variables = {"id": document_id}
        result = self._execute_query(mutation, variables)
        return result.get("documentArchive", {})

    # ========== ISSUE OPERATIONS ==========

    def delete_issue(self, issue_id: str) -> Dict[str, Any]:
        """Delete an issue"""
        mutation = """
        mutation IssueDelete($id: String!) {
            issueDelete(id: $id) {
                success
            }
        }
        """
        variables = {"id": issue_id}
        result = self._execute_query(mutation, variables)
        return result.get("issueDelete", {})

    def archive_issue(self, issue_id: str) -> Dict[str, Any]:
        """Archive an issue"""
        mutation = """
        mutation IssueArchive($id: String!) {
            issueArchive(id: $id) {
                success
            }
        }
        """
        variables = {"id": issue_id}
        result = self._execute_query(mutation, variables)
        return result.get("issueArchive", {})

    def unarchive_issue(self, issue_id: str) -> Dict[str, Any]:
        """Unarchive an issue"""
        mutation = """
        mutation IssueUnarchive($id: String!) {
            issueUnarchive(id: $id) {
                success
            }
        }
        """
        variables = {"id": issue_id}
        result = self._execute_query(mutation, variables)
        return result.get("issueUnarchive", {})

    # ========== COMMENT OPERATIONS ==========

    def update_comment(
        self,
        comment_id: str,
        body: Optional[str] = None,
        body_data: Optional[Dict] = None,
    ) -> Dict[str, Any]:
        """Update a comment"""
        mutation = """
        mutation CommentUpdate($id: String!, $input: CommentUpdateInput!) {
            commentUpdate(id: $id, input: $input) {
                success
                comment {
                    id
                    body
                    updatedAt
                }
            }
        }
        """

        input_data = {}
        if body is not None:
            input_data["body"] = body
        if body_data is not None:
            input_data["bodyData"] = body_data

        if not input_data:
            raise ValueError("At least one field must be provided for update")

        variables = {"id": comment_id, "input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("commentUpdate", {})

    def delete_comment(self, comment_id: str) -> Dict[str, Any]:
        """Delete a comment"""
        mutation = """
        mutation CommentDelete($id: String!) {
            commentDelete(id: $id) {
                success
            }
        }
        """
        variables = {"id": comment_id}
        result = self._execute_query(mutation, variables)
        return result.get("commentDelete", {})

    # ========== PROJECT OPERATIONS ==========

    def delete_project(self, project_id: str) -> Dict[str, Any]:
        """Delete a project"""
        mutation = """
        mutation ProjectDelete($id: String!) {
            projectDelete(id: $id) {
                success
            }
        }
        """
        variables = {"id": project_id}
        result = self._execute_query(mutation, variables)
        return result.get("projectDelete", {})

    def archive_project(self, project_id: str) -> Dict[str, Any]:
        """Archive a project"""
        mutation = """
        mutation ProjectArchive($id: String!) {
            projectArchive(id: $id) {
                success
            }
        }
        """
        variables = {"id": project_id}
        result = self._execute_query(mutation, variables)
        return result.get("projectArchive", {})

    def unarchive_project(self, project_id: str) -> Dict[str, Any]:
        """Unarchive a project"""
        mutation = """
        mutation ProjectUnarchive($id: String!) {
            projectUnarchive(id: $id) {
                success
            }
        }
        """
        variables = {"id": project_id}
        result = self._execute_query(mutation, variables)
        return result.get("projectUnarchive", {})

    # ========== CYCLE OPERATIONS ==========

    def create_cycle(
        self,
        team_id: str,
        name: Optional[str] = None,
        starts_at: Optional[str] = None,
        ends_at: Optional[str] = None,
        description: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Create a new cycle"""
        mutation = """
        mutation CycleCreate($input: CycleCreateInput!) {
            cycleCreate(input: $input) {
                success
                cycle {
                    id
                    name
                    number
                    startsAt
                    endsAt
                }
            }
        }
        """

        input_data = {"teamId": team_id}
        if name:
            input_data["name"] = name
        if starts_at:
            input_data["startsAt"] = starts_at
        if ends_at:
            input_data["endsAt"] = ends_at
        if description:
            input_data["description"] = description

        variables = {"input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("cycleCreate", {})

    def update_cycle(
        self,
        cycle_id: str,
        name: Optional[str] = None,
        starts_at: Optional[str] = None,
        ends_at: Optional[str] = None,
        description: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update a cycle"""
        mutation = """
        mutation CycleUpdate($id: String!, $input: CycleUpdateInput!) {
            cycleUpdate(id: $id, input: $input) {
                success
                cycle {
                    id
                    name
                    startsAt
                    endsAt
                }
            }
        }
        """

        input_data = {}
        if name is not None:
            input_data["name"] = name
        if starts_at is not None:
            input_data["startsAt"] = starts_at
        if ends_at is not None:
            input_data["endsAt"] = ends_at
        if description is not None:
            input_data["description"] = description

        if not input_data:
            raise ValueError("At least one field must be provided for update")

        variables = {"id": cycle_id, "input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("cycleUpdate", {})

    def archive_cycle(self, cycle_id: str) -> Dict[str, Any]:
        """Archive a cycle"""
        mutation = """
        mutation CycleArchive($id: String!) {
            cycleArchive(id: $id) {
                success
            }
        }
        """
        variables = {"id": cycle_id}
        result = self._execute_query(mutation, variables)
        return result.get("cycleArchive", {})

    # ========== TEAM OPERATIONS ==========

    def create_team(
        self,
        name: str,
        key: str,
        description: Optional[str] = None,
        icon: Optional[str] = None,
        color: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Create a new team"""
        mutation = """
        mutation TeamCreate($input: TeamCreateInput!) {
            teamCreate(input: $input) {
                success
                team {
                    id
                    name
                    key
                    description
                    url
                }
            }
        }
        """

        input_data = {"name": name, "key": key}
        if description:
            input_data["description"] = description
        if icon:
            input_data["icon"] = icon
        if color:
            input_data["color"] = color

        variables = {"input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("teamCreate", {})

    def update_team(
        self,
        team_id: str,
        name: Optional[str] = None,
        key: Optional[str] = None,
        description: Optional[str] = None,
        icon: Optional[str] = None,
        color: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update a team"""
        mutation = """
        mutation TeamUpdate($id: String!, $input: TeamUpdateInput!) {
            teamUpdate(id: $id, input: $input) {
                success
                team {
                    id
                    name
                    key
                    description
                }
            }
        }
        """

        input_data = {}
        if name is not None:
            input_data["name"] = name
        if key is not None:
            input_data["key"] = key
        if description is not None:
            input_data["description"] = description
        if icon is not None:
            input_data["icon"] = icon
        if color is not None:
            input_data["color"] = color

        if not input_data:
            raise ValueError("At least one field must be provided for update")

        variables = {"id": team_id, "input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("teamUpdate", {})

    # ========== LABEL OPERATIONS ==========

    def update_label(
        self,
        label_id: str,
        name: Optional[str] = None,
        description: Optional[str] = None,
        color: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update an issue label"""
        mutation = """
        mutation IssueLabelUpdate($id: String!, $input: IssueLabelUpdateInput!) {
            issueLabelUpdate(id: $id, input: $input) {
                success
                issueLabel {
                    id
                    name
                    description
                    color
                }
            }
        }
        """

        input_data = {}
        if name is not None:
            input_data["name"] = name
        if description is not None:
            input_data["description"] = description
        if color is not None:
            input_data["color"] = color

        if not input_data:
            raise ValueError("At least one field must be provided for update")

        variables = {"id": label_id, "input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("issueLabelUpdate", {})

    def delete_label(self, label_id: str) -> Dict[str, Any]:
        """Delete an issue label"""
        mutation = """
        mutation IssueLabelDelete($id: String!) {
            issueLabelDelete(id: $id) {
                success
            }
        }
        """
        variables = {"id": label_id}
        result = self._execute_query(mutation, variables)
        return result.get("issueLabelDelete", {})

    # ========== ATTACHMENT OPERATIONS ==========

    def create_attachment(
        self,
        issue_id: str,
        url: str,
        title: Optional[str] = None,
        subtitle: Optional[str] = None,
        metadata: Optional[Dict] = None,
    ) -> Dict[str, Any]:
        """Create an attachment"""
        mutation = """
        mutation AttachmentCreate($input: AttachmentCreateInput!) {
            attachmentCreate(input: $input) {
                success
                attachment {
                    id
                    title
                    subtitle
                    url
                }
            }
        }
        """

        input_data = {"issueId": issue_id, "url": url}
        if title:
            input_data["title"] = title
        if subtitle:
            input_data["subtitle"] = subtitle
        if metadata:
            input_data["metadata"] = metadata

        variables = {"input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("attachmentCreate", {})

    def update_attachment(
        self,
        attachment_id: str,
        title: Optional[str] = None,
        subtitle: Optional[str] = None,
        metadata: Optional[Dict] = None,
    ) -> Dict[str, Any]:
        """Update an attachment"""
        mutation = """
        mutation AttachmentUpdate($id: String!, $input: AttachmentUpdateInput!) {
            attachmentUpdate(id: $id, input: $input) {
                success
                attachment {
                    id
                    title
                    subtitle
                }
            }
        }
        """

        input_data = {}
        if title is not None:
            input_data["title"] = title
        if subtitle is not None:
            input_data["subtitle"] = subtitle
        if metadata is not None:
            input_data["metadata"] = metadata

        if not input_data:
            raise ValueError("At least one field must be provided for update")

        variables = {"id": attachment_id, "input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("attachmentUpdate", {})

    def delete_attachment(self, attachment_id: str) -> Dict[str, Any]:
        """Delete an attachment"""
        mutation = """
        mutation AttachmentDelete($id: String!) {
            attachmentDelete(id: $id) {
                success
            }
        }
        """
        variables = {"id": attachment_id}
        result = self._execute_query(mutation, variables)
        return result.get("attachmentDelete", {})

    # ========== CUSTOM VIEW OPERATIONS ==========

    def create_custom_view(
        self,
        name: str,
        team_id: str,
        filters: Optional[Dict] = None,
        description: Optional[str] = None,
        icon: Optional[str] = None,
        color: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Create a custom view"""
        mutation = """
        mutation CustomViewCreate($input: CustomViewCreateInput!) {
            customViewCreate(input: $input) {
                success
                customView {
                    id
                    name
                    description
                    url
                }
            }
        }
        """

        input_data = {"name": name, "teamId": team_id}
        if filters:
            input_data["filters"] = filters
        if description:
            input_data["description"] = description
        if icon:
            input_data["icon"] = icon
        if color:
            input_data["color"] = color

        variables = {"input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("customViewCreate", {})

    def update_custom_view(
        self,
        view_id: str,
        name: Optional[str] = None,
        filters: Optional[Dict] = None,
        description: Optional[str] = None,
        icon: Optional[str] = None,
        color: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update a custom view"""
        mutation = """
        mutation CustomViewUpdate($id: String!, $input: CustomViewUpdateInput!) {
            customViewUpdate(id: $id, input: $input) {
                success
                customView {
                    id
                    name
                    description
                }
            }
        }
        """

        input_data = {}
        if name is not None:
            input_data["name"] = name
        if filters is not None:
            input_data["filters"] = filters
        if description is not None:
            input_data["description"] = description
        if icon is not None:
            input_data["icon"] = icon
        if color is not None:
            input_data["color"] = color

        if not input_data:
            raise ValueError("At least one field must be provided for update")

        variables = {"id": view_id, "input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("customViewUpdate", {})

    def delete_custom_view(self, view_id: str) -> Dict[str, Any]:
        """Delete a custom view"""
        mutation = """
        mutation CustomViewDelete($id: String!) {
            customViewDelete(id: $id) {
                success
            }
        }
        """
        variables = {"id": view_id}
        result = self._execute_query(mutation, variables)
        return result.get("customViewDelete", {})

    def archive_custom_view(self, view_id: str) -> Dict[str, Any]:
        """Archive a custom view"""
        mutation = """
        mutation CustomViewArchive($id: String!) {
            customViewArchive(id: $id) {
                success
            }
        }
        """
        variables = {"id": view_id}
        result = self._execute_query(mutation, variables)
        return result.get("customViewArchive", {})

    # ========== INITIATIVE OPERATIONS ==========

    def create_initiative(
        self,
        name: str,
        description: Optional[str] = None,
        target_date: Optional[str] = None,
        icon: Optional[str] = None,
        color: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Create an initiative"""
        mutation = """
        mutation InitiativeCreate($input: InitiativeCreateInput!) {
            initiativeCreate(input: $input) {
                success
                initiative {
                    id
                    name
                    description
                    targetDate
                    url
                }
            }
        }
        """

        input_data = {"name": name}
        if description:
            input_data["description"] = description
        if target_date:
            input_data["targetDate"] = target_date
        if icon:
            input_data["icon"] = icon
        if color:
            input_data["color"] = color

        variables = {"input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("initiativeCreate", {})

    def update_initiative(
        self,
        initiative_id: str,
        name: Optional[str] = None,
        description: Optional[str] = None,
        target_date: Optional[str] = None,
        icon: Optional[str] = None,
        color: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update an initiative"""
        mutation = """
        mutation InitiativeUpdate($id: String!, $input: InitiativeUpdateInput!) {
            initiativeUpdate(id: $id, input: $input) {
                success
                initiative {
                    id
                    name
                    description
                    targetDate
                }
            }
        }
        """

        input_data = {}
        if name is not None:
            input_data["name"] = name
        if description is not None:
            input_data["description"] = description
        if target_date is not None:
            input_data["targetDate"] = target_date
        if icon is not None:
            input_data["icon"] = icon
        if color is not None:
            input_data["color"] = color

        if not input_data:
            raise ValueError("At least one field must be provided for update")

        variables = {"id": initiative_id, "input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("initiativeUpdate", {})

    def delete_initiative(self, initiative_id: str) -> Dict[str, Any]:
        """Delete an initiative"""
        mutation = """
        mutation InitiativeDelete($id: String!) {
            initiativeDelete(id: $id) {
                success
            }
        }
        """
        variables = {"id": initiative_id}
        result = self._execute_query(mutation, variables)
        return result.get("initiativeDelete", {})

    def connect_initiative_to_project(
        self,
        initiative_id: str,
        project_id: str,
    ) -> Dict[str, Any]:
        """Connect an initiative to a project"""
        mutation = """
        mutation InitiativeToProjectCreate($input: InitiativeToProjectCreateInput!) {
            initiativeToProjectCreate(input: $input) {
                success
                initiativeToProject {
                    id
                }
            }
        }
        """

        input_data = {
            "initiativeId": initiative_id,
            "projectId": project_id,
        }

        variables = {"input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("initiativeToProjectCreate", {})

    # ========== ROADMAP OPERATIONS ==========

    def create_roadmap(
        self,
        name: str,
        description: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Create a roadmap"""
        mutation = """
        mutation RoadmapCreate($input: RoadmapCreateInput!) {
            roadmapCreate(input: $input) {
                success
                roadmap {
                    id
                    name
                    description
                    url
                }
            }
        }
        """

        input_data = {"name": name}
        if description:
            input_data["description"] = description

        variables = {"input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("roadmapCreate", {})

    def update_roadmap(
        self,
        roadmap_id: str,
        name: Optional[str] = None,
        description: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update a roadmap"""
        mutation = """
        mutation RoadmapUpdate($id: String!, $input: RoadmapUpdateInput!) {
            roadmapUpdate(id: $id, input: $input) {
                success
                roadmap {
                    id
                    name
                    description
                }
            }
        }
        """

        input_data = {}
        if name is not None:
            input_data["name"] = name
        if description is not None:
            input_data["description"] = description

        if not input_data:
            raise ValueError("At least one field must be provided for update")

        variables = {"id": roadmap_id, "input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("roadmapUpdate", {})

    def delete_roadmap(self, roadmap_id: str) -> Dict[str, Any]:
        """Delete a roadmap"""
        mutation = """
        mutation RoadmapDelete($id: String!) {
            roadmapDelete(id: $id) {
                success
            }
        }
        """
        variables = {"id": roadmap_id}
        result = self._execute_query(mutation, variables)
        return result.get("roadmapDelete", {})

    # ========== WORKFLOW STATE OPERATIONS ==========

    def create_workflow_state(
        self,
        team_id: str,
        name: str,
        type: str,  # backlog, unstarted, started, completed, canceled
        color: Optional[str] = None,
        description: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Create a workflow state"""
        mutation = """
        mutation WorkflowStateCreate($input: WorkflowStateCreateInput!) {
            workflowStateCreate(input: $input) {
                success
                workflowState {
                    id
                    name
                    type
                    color
                    description
                }
            }
        }
        """

        input_data = {"teamId": team_id, "name": name, "type": type}
        if color:
            input_data["color"] = color
        if description:
            input_data["description"] = description

        variables = {"input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("workflowStateCreate", {})

    def update_workflow_state(
        self,
        state_id: str,
        name: Optional[str] = None,
        color: Optional[str] = None,
        description: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update a workflow state"""
        mutation = """
        mutation WorkflowStateUpdate($id: String!, $input: WorkflowStateUpdateInput!) {
            workflowStateUpdate(id: $id, input: $input) {
                success
                workflowState {
                    id
                    name
                    color
                    description
                }
            }
        }
        """

        input_data = {}
        if name is not None:
            input_data["name"] = name
        if color is not None:
            input_data["color"] = color
        if description is not None:
            input_data["description"] = description

        if not input_data:
            raise ValueError("At least one field must be provided for update")

        variables = {"id": state_id, "input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("workflowStateUpdate", {})

    def archive_workflow_state(self, state_id: str) -> Dict[str, Any]:
        """Archive a workflow state"""
        mutation = """
        mutation WorkflowStateArchive($id: String!) {
            workflowStateArchive(id: $id) {
                success
            }
        }
        """
        variables = {"id": state_id}
        result = self._execute_query(mutation, variables)
        return result.get("workflowStateArchive", {})

    # ========== WEBHOOK OPERATIONS ==========

    def create_webhook(
        self,
        url: str,
        resource_types: List[str],
        label: Optional[str] = None,
        enabled: bool = True,
    ) -> Dict[str, Any]:
        """Create a webhook"""
        mutation = """
        mutation WebhookCreate($input: WebhookCreateInput!) {
            webhookCreate(input: $input) {
                success
                webhook {
                    id
                    url
                    label
                    enabled
                    resourceTypes
                }
            }
        }
        """

        input_data = {
            "url": url,
            "resourceTypes": resource_types,
            "enabled": enabled,
        }
        if label:
            input_data["label"] = label

        variables = {"input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("webhookCreate", {})

    def update_webhook(
        self,
        webhook_id: str,
        url: Optional[str] = None,
        label: Optional[str] = None,
        enabled: Optional[bool] = None,
    ) -> Dict[str, Any]:
        """Update a webhook"""
        mutation = """
        mutation WebhookUpdate($id: String!, $input: WebhookUpdateInput!) {
            webhookUpdate(id: $id, input: $input) {
                success
                webhook {
                    id
                    url
                    label
                    enabled
                }
            }
        }
        """

        input_data = {}
        if url is not None:
            input_data["url"] = url
        if label is not None:
            input_data["label"] = label
        if enabled is not None:
            input_data["enabled"] = enabled

        if not input_data:
            raise ValueError("At least one field must be provided for update")

        variables = {"id": webhook_id, "input": input_data}
        result = self._execute_query(mutation, variables)
        return result.get("webhookUpdate", {})

    def delete_webhook(self, webhook_id: str) -> Dict[str, Any]:
        """Delete a webhook"""
        mutation = """
        mutation WebhookDelete($id: String!) {
            webhookDelete(id: $id) {
                success
            }
        }
        """
        variables = {"id": webhook_id}
        result = self._execute_query(mutation, variables)
        return result.get("webhookDelete", {})


def main():
    """CLI entry point"""
    parser = argparse.ArgumentParser(
        description="Complete Linear API Client - Complements Linear MCP",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Document operations
  python linear-api-client.py document create --title "My Doc" --content "# Hello"
  python linear-api-client.py document update --id DOC-123 --content "# Updated"
  python linear-api-client.py document delete --id DOC-123
  python linear-api-client.py document archive --id DOC-123

  # Issue operations (delete/archive only - use MCP for create/update)
  python linear-api-client.py issue delete --id ISSUE-123
  python linear-api-client.py issue archive --id ISSUE-123
  python linear-api-client.py issue unarchive --id ISSUE-123

  # Comment operations
  python linear-api-client.py comment update --id abc-123 --body "Updated text"
  python linear-api-client.py comment delete --id abc-123

  # Cycle operations
  python linear-api-client.py cycle create --team TEAM-123 --name "Sprint 42"
  python linear-api-client.py cycle update --id CYCLE-123 --name "Sprint 42 Extended"
  python linear-api-client.py cycle archive --id CYCLE-123

  # Team operations
  python linear-api-client.py team create --name "Backend" --key "BACK"
  python linear-api-client.py team update --id TEAM-123 --description "New desc"

  # Label operations
  python linear-api-client.py label update --id LABEL-123 --color "#FF0000"
  python linear-api-client.py label delete --id LABEL-123

  # Attachment operations
  python linear-api-client.py attachment create --issue ISSUE-123 --url "https://github.com/..."
  python linear-api-client.py attachment delete --id ATT-123

  # Custom View operations
  python linear-api-client.py view create --name "My View" --team TEAM-123
  python linear-api-client.py view delete --id VIEW-123

  # Initiative operations
  python linear-api-client.py initiative create --name "Q4 Goals"
  python linear-api-client.py initiative connect --id INIT-123 --project PROJ-456

  # Roadmap operations
  python linear-api-client.py roadmap create --name "2025 Roadmap"

  # Workflow operations
  python linear-api-client.py workflow create --team TEAM-123 --name "Review" --type started

  # Webhook operations
  python linear-api-client.py webhook create --url "https://..." --types Issue Comment
        """
    )

    subparsers = parser.add_subparsers(dest="resource", help="Resource type")

    # ========== DOCUMENT COMMANDS ==========
    doc_parser = subparsers.add_parser("document", aliases=["doc"], help="Document operations")
    doc_subparsers = doc_parser.add_subparsers(dest="action", help="Action to perform")

    doc_create = doc_subparsers.add_parser("create", help="Create a document")
    doc_create.add_argument("--title", required=True, help="Document title")
    doc_create.add_argument("--content", required=True, help="Document content (Markdown)")
    doc_create.add_argument("--project-id", help="Project ID to associate with")
    doc_create.add_argument("--icon", help="Emoji icon")

    doc_update = doc_subparsers.add_parser("update", help="Update a document")
    doc_update.add_argument("--id", required=True, help="Document ID")
    doc_update.add_argument("--title", help="New document title")
    doc_update.add_argument("--content", help="New document content")
    doc_update.add_argument("--icon", help="Emoji icon")

    doc_delete = doc_subparsers.add_parser("delete", help="Delete a document")
    doc_delete.add_argument("--id", required=True, help="Document ID")

    doc_archive = doc_subparsers.add_parser("archive", help="Archive a document")
    doc_archive.add_argument("--id", required=True, help="Document ID")

    # ========== ISSUE COMMANDS ==========
    issue_parser = subparsers.add_parser("issue", help="Issue operations")
    issue_subparsers = issue_parser.add_subparsers(dest="action", help="Action to perform")

    issue_delete = issue_subparsers.add_parser("delete", help="Delete an issue")
    issue_delete.add_argument("--id", required=True, help="Issue ID")

    issue_archive = issue_subparsers.add_parser("archive", help="Archive an issue")
    issue_archive.add_argument("--id", required=True, help="Issue ID")

    issue_unarchive = issue_subparsers.add_parser("unarchive", help="Unarchive an issue")
    issue_unarchive.add_argument("--id", required=True, help="Issue ID")

    # ========== COMMENT COMMANDS ==========
    comment_parser = subparsers.add_parser("comment", help="Comment operations")
    comment_subparsers = comment_parser.add_subparsers(dest="action", help="Action to perform")

    comment_update = comment_subparsers.add_parser("update", help="Update a comment")
    comment_update.add_argument("--id", required=True, help="Comment ID")
    comment_update.add_argument("--body", help="New comment body")

    comment_delete = comment_subparsers.add_parser("delete", help="Delete a comment")
    comment_delete.add_argument("--id", required=True, help="Comment ID")

    # ========== PROJECT COMMANDS ==========
    project_parser = subparsers.add_parser("project", help="Project operations")
    project_subparsers = project_parser.add_subparsers(dest="action", help="Action to perform")

    project_delete = project_subparsers.add_parser("delete", help="Delete a project")
    project_delete.add_argument("--id", required=True, help="Project ID")

    project_archive = project_subparsers.add_parser("archive", help="Archive a project")
    project_archive.add_argument("--id", required=True, help="Project ID")

    project_unarchive = project_subparsers.add_parser("unarchive", help="Unarchive a project")
    project_unarchive.add_argument("--id", required=True, help="Project ID")

    # ========== CYCLE COMMANDS ==========
    cycle_parser = subparsers.add_parser("cycle", help="Cycle operations")
    cycle_subparsers = cycle_parser.add_subparsers(dest="action", help="Action to perform")

    cycle_create = cycle_subparsers.add_parser("create", help="Create a cycle")
    cycle_create.add_argument("--team", required=True, help="Team ID")
    cycle_create.add_argument("--name", help="Cycle name")
    cycle_create.add_argument("--starts-at", help="Start date (ISO 8601)")
    cycle_create.add_argument("--ends-at", help="End date (ISO 8601)")
    cycle_create.add_argument("--description", help="Cycle description")

    cycle_update = cycle_subparsers.add_parser("update", help="Update a cycle")
    cycle_update.add_argument("--id", required=True, help="Cycle ID")
    cycle_update.add_argument("--name", help="New cycle name")
    cycle_update.add_argument("--starts-at", help="New start date")
    cycle_update.add_argument("--ends-at", help="New end date")
    cycle_update.add_argument("--description", help="New description")

    cycle_archive = cycle_subparsers.add_parser("archive", help="Archive a cycle")
    cycle_archive.add_argument("--id", required=True, help="Cycle ID")

    # ========== TEAM COMMANDS ==========
    team_parser = subparsers.add_parser("team", help="Team operations")
    team_subparsers = team_parser.add_subparsers(dest="action", help="Action to perform")

    team_create = team_subparsers.add_parser("create", help="Create a team")
    team_create.add_argument("--name", required=True, help="Team name")
    team_create.add_argument("--key", required=True, help="Team key (e.g., BACK)")
    team_create.add_argument("--description", help="Team description")
    team_create.add_argument("--icon", help="Emoji icon")
    team_create.add_argument("--color", help="Color hex code")

    team_update = team_subparsers.add_parser("update", help="Update a team")
    team_update.add_argument("--id", required=True, help="Team ID")
    team_update.add_argument("--name", help="New team name")
    team_update.add_argument("--key", help="New team key")
    team_update.add_argument("--description", help="New description")
    team_update.add_argument("--icon", help="Emoji icon")
    team_update.add_argument("--color", help="Color hex code")

    # ========== LABEL COMMANDS ==========
    label_parser = subparsers.add_parser("label", help="Label operations")
    label_subparsers = label_parser.add_subparsers(dest="action", help="Action to perform")

    label_update = label_subparsers.add_parser("update", help="Update a label")
    label_update.add_argument("--id", required=True, help="Label ID")
    label_update.add_argument("--name", help="New label name")
    label_update.add_argument("--description", help="New description")
    label_update.add_argument("--color", help="Color hex code")

    label_delete = label_subparsers.add_parser("delete", help="Delete a label")
    label_delete.add_argument("--id", required=True, help="Label ID")

    # ========== ATTACHMENT COMMANDS ==========
    attachment_parser = subparsers.add_parser("attachment", aliases=["att"], help="Attachment operations")
    attachment_subparsers = attachment_parser.add_subparsers(dest="action", help="Action to perform")

    attachment_create = attachment_subparsers.add_parser("create", help="Create an attachment")
    attachment_create.add_argument("--issue", required=True, help="Issue ID")
    attachment_create.add_argument("--url", required=True, help="Attachment URL")
    attachment_create.add_argument("--title", help="Attachment title")
    attachment_create.add_argument("--subtitle", help="Attachment subtitle")

    attachment_update = attachment_subparsers.add_parser("update", help="Update an attachment")
    attachment_update.add_argument("--id", required=True, help="Attachment ID")
    attachment_update.add_argument("--title", help="New title")
    attachment_update.add_argument("--subtitle", help="New subtitle")

    attachment_delete = attachment_subparsers.add_parser("delete", help="Delete an attachment")
    attachment_delete.add_argument("--id", required=True, help="Attachment ID")

    # ========== CUSTOM VIEW COMMANDS ==========
    view_parser = subparsers.add_parser("view", help="Custom view operations")
    view_subparsers = view_parser.add_subparsers(dest="action", help="Action to perform")

    view_create = view_subparsers.add_parser("create", help="Create a custom view")
    view_create.add_argument("--name", required=True, help="View name")
    view_create.add_argument("--team", required=True, help="Team ID")
    view_create.add_argument("--description", help="View description")
    view_create.add_argument("--icon", help="Emoji icon")
    view_create.add_argument("--color", help="Color hex code")

    view_update = view_subparsers.add_parser("update", help="Update a custom view")
    view_update.add_argument("--id", required=True, help="View ID")
    view_update.add_argument("--name", help="New view name")
    view_update.add_argument("--description", help="New description")
    view_update.add_argument("--icon", help="Emoji icon")
    view_update.add_argument("--color", help="Color hex code")

    view_delete = view_subparsers.add_parser("delete", help="Delete a custom view")
    view_delete.add_argument("--id", required=True, help="View ID")

    view_archive = view_subparsers.add_parser("archive", help="Archive a custom view")
    view_archive.add_argument("--id", required=True, help="View ID")

    # ========== INITIATIVE COMMANDS ==========
    initiative_parser = subparsers.add_parser("initiative", aliases=["init"], help="Initiative operations")
    initiative_subparsers = initiative_parser.add_subparsers(dest="action", help="Action to perform")

    initiative_create = initiative_subparsers.add_parser("create", help="Create an initiative")
    initiative_create.add_argument("--name", required=True, help="Initiative name")
    initiative_create.add_argument("--description", help="Initiative description")
    initiative_create.add_argument("--target-date", help="Target date (ISO 8601)")
    initiative_create.add_argument("--icon", help="Emoji icon")
    initiative_create.add_argument("--color", help="Color hex code")

    initiative_update = initiative_subparsers.add_parser("update", help="Update an initiative")
    initiative_update.add_argument("--id", required=True, help="Initiative ID")
    initiative_update.add_argument("--name", help="New initiative name")
    initiative_update.add_argument("--description", help="New description")
    initiative_update.add_argument("--target-date", help="New target date")
    initiative_update.add_argument("--icon", help="Emoji icon")
    initiative_update.add_argument("--color", help="Color hex code")

    initiative_delete = initiative_subparsers.add_parser("delete", help="Delete an initiative")
    initiative_delete.add_argument("--id", required=True, help="Initiative ID")

    initiative_connect = initiative_subparsers.add_parser("connect", help="Connect initiative to project")
    initiative_connect.add_argument("--id", required=True, help="Initiative ID")
    initiative_connect.add_argument("--project", required=True, help="Project ID")

    # ========== ROADMAP COMMANDS ==========
    roadmap_parser = subparsers.add_parser("roadmap", help="Roadmap operations")
    roadmap_subparsers = roadmap_parser.add_subparsers(dest="action", help="Action to perform")

    roadmap_create = roadmap_subparsers.add_parser("create", help="Create a roadmap")
    roadmap_create.add_argument("--name", required=True, help="Roadmap name")
    roadmap_create.add_argument("--description", help="Roadmap description")

    roadmap_update = roadmap_subparsers.add_parser("update", help="Update a roadmap")
    roadmap_update.add_argument("--id", required=True, help="Roadmap ID")
    roadmap_update.add_argument("--name", help="New roadmap name")
    roadmap_update.add_argument("--description", help="New description")

    roadmap_delete = roadmap_subparsers.add_parser("delete", help="Delete a roadmap")
    roadmap_delete.add_argument("--id", required=True, help="Roadmap ID")

    # ========== WORKFLOW COMMANDS ==========
    workflow_parser = subparsers.add_parser("workflow", aliases=["wf"], help="Workflow state operations")
    workflow_subparsers = workflow_parser.add_subparsers(dest="action", help="Action to perform")

    workflow_create = workflow_subparsers.add_parser("create", help="Create a workflow state")
    workflow_create.add_argument("--team", required=True, help="Team ID")
    workflow_create.add_argument("--name", required=True, help="State name")
    workflow_create.add_argument("--type", required=True,
                                  choices=["backlog", "unstarted", "started", "completed", "canceled"],
                                  help="State type")
    workflow_create.add_argument("--color", help="Color hex code")
    workflow_create.add_argument("--description", help="State description")

    workflow_update = workflow_subparsers.add_parser("update", help="Update a workflow state")
    workflow_update.add_argument("--id", required=True, help="State ID")
    workflow_update.add_argument("--name", help="New state name")
    workflow_update.add_argument("--color", help="Color hex code")
    workflow_update.add_argument("--description", help="New description")

    workflow_archive = workflow_subparsers.add_parser("archive", help="Archive a workflow state")
    workflow_archive.add_argument("--id", required=True, help="State ID")

    # ========== WEBHOOK COMMANDS ==========
    webhook_parser = subparsers.add_parser("webhook", help="Webhook operations")
    webhook_subparsers = webhook_parser.add_subparsers(dest="action", help="Action to perform")

    webhook_create = webhook_subparsers.add_parser("create", help="Create a webhook")
    webhook_create.add_argument("--url", required=True, help="Webhook URL")
    webhook_create.add_argument("--types", required=True, nargs="+", help="Resource types (e.g., Issue Comment)")
    webhook_create.add_argument("--label", help="Webhook label")
    webhook_create.add_argument("--disabled", action="store_true", help="Create as disabled")

    webhook_update = webhook_subparsers.add_parser("update", help="Update a webhook")
    webhook_update.add_argument("--id", required=True, help="Webhook ID")
    webhook_update.add_argument("--url", help="New webhook URL")
    webhook_update.add_argument("--label", help="New label")
    webhook_update.add_argument("--enabled", type=bool, help="Enable/disable webhook")

    webhook_delete = webhook_subparsers.add_parser("delete", help="Delete a webhook")
    webhook_delete.add_argument("--id", required=True, help="Webhook ID")

    args = parser.parse_args()

    if not args.resource:
        parser.print_help()
        sys.exit(1)

    client = LinearAPIClient(LINEAR_API_KEY)

    try:
        # Route to appropriate handler
        resource = args.resource
        action = getattr(args, 'action', None)

        if not action:
            parser.print_help()
            sys.exit(1)

        result = None

        # ========== DOCUMENT HANDLERS ==========
        if resource in ["document", "doc"]:
            if action == "create":
                result = client.create_document(
                    title=args.title,
                    content=args.content,
                    project_id=getattr(args, 'project_id', None),
                    icon=getattr(args, 'icon', None),
                )
            elif action == "update":
                result = client.update_document(
                    document_id=args.id,
                    title=getattr(args, 'title', None),
                    content=getattr(args, 'content', None),
                    icon=getattr(args, 'icon', None),
                )
            elif action == "delete":
                result = client.delete_document(args.id)
            elif action == "archive":
                result = client.archive_document(args.id)

        # ========== ISSUE HANDLERS ==========
        elif resource == "issue":
            if action == "delete":
                result = client.delete_issue(args.id)
            elif action == "archive":
                result = client.archive_issue(args.id)
            elif action == "unarchive":
                result = client.unarchive_issue(args.id)

        # ========== COMMENT HANDLERS ==========
        elif resource == "comment":
            if action == "update":
                result = client.update_comment(
                    comment_id=args.id,
                    body=getattr(args, 'body', None),
                )
            elif action == "delete":
                result = client.delete_comment(args.id)

        # ========== PROJECT HANDLERS ==========
        elif resource == "project":
            if action == "delete":
                result = client.delete_project(args.id)
            elif action == "archive":
                result = client.archive_project(args.id)
            elif action == "unarchive":
                result = client.unarchive_project(args.id)

        # ========== CYCLE HANDLERS ==========
        elif resource == "cycle":
            if action == "create":
                result = client.create_cycle(
                    team_id=args.team,
                    name=getattr(args, 'name', None),
                    starts_at=getattr(args, 'starts_at', None),
                    ends_at=getattr(args, 'ends_at', None),
                    description=getattr(args, 'description', None),
                )
            elif action == "update":
                result = client.update_cycle(
                    cycle_id=args.id,
                    name=getattr(args, 'name', None),
                    starts_at=getattr(args, 'starts_at', None),
                    ends_at=getattr(args, 'ends_at', None),
                    description=getattr(args, 'description', None),
                )
            elif action == "archive":
                result = client.archive_cycle(args.id)

        # ========== TEAM HANDLERS ==========
        elif resource == "team":
            if action == "create":
                result = client.create_team(
                    name=args.name,
                    key=args.key,
                    description=getattr(args, 'description', None),
                    icon=getattr(args, 'icon', None),
                    color=getattr(args, 'color', None),
                )
            elif action == "update":
                result = client.update_team(
                    team_id=args.id,
                    name=getattr(args, 'name', None),
                    key=getattr(args, 'key', None),
                    description=getattr(args, 'description', None),
                    icon=getattr(args, 'icon', None),
                    color=getattr(args, 'color', None),
                )

        # ========== LABEL HANDLERS ==========
        elif resource == "label":
            if action == "update":
                result = client.update_label(
                    label_id=args.id,
                    name=getattr(args, 'name', None),
                    description=getattr(args, 'description', None),
                    color=getattr(args, 'color', None),
                )
            elif action == "delete":
                result = client.delete_label(args.id)

        # ========== ATTACHMENT HANDLERS ==========
        elif resource in ["attachment", "att"]:
            if action == "create":
                result = client.create_attachment(
                    issue_id=args.issue,
                    url=args.url,
                    title=getattr(args, 'title', None),
                    subtitle=getattr(args, 'subtitle', None),
                )
            elif action == "update":
                result = client.update_attachment(
                    attachment_id=args.id,
                    title=getattr(args, 'title', None),
                    subtitle=getattr(args, 'subtitle', None),
                )
            elif action == "delete":
                result = client.delete_attachment(args.id)

        # ========== CUSTOM VIEW HANDLERS ==========
        elif resource == "view":
            if action == "create":
                result = client.create_custom_view(
                    name=args.name,
                    team_id=args.team,
                    description=getattr(args, 'description', None),
                    icon=getattr(args, 'icon', None),
                    color=getattr(args, 'color', None),
                )
            elif action == "update":
                result = client.update_custom_view(
                    view_id=args.id,
                    name=getattr(args, 'name', None),
                    description=getattr(args, 'description', None),
                    icon=getattr(args, 'icon', None),
                    color=getattr(args, 'color', None),
                )
            elif action == "delete":
                result = client.delete_custom_view(args.id)
            elif action == "archive":
                result = client.archive_custom_view(args.id)

        # ========== INITIATIVE HANDLERS ==========
        elif resource in ["initiative", "init"]:
            if action == "create":
                result = client.create_initiative(
                    name=args.name,
                    description=getattr(args, 'description', None),
                    target_date=getattr(args, 'target_date', None),
                    icon=getattr(args, 'icon', None),
                    color=getattr(args, 'color', None),
                )
            elif action == "update":
                result = client.update_initiative(
                    initiative_id=args.id,
                    name=getattr(args, 'name', None),
                    description=getattr(args, 'description', None),
                    target_date=getattr(args, 'target_date', None),
                    icon=getattr(args, 'icon', None),
                    color=getattr(args, 'color', None),
                )
            elif action == "delete":
                result = client.delete_initiative(args.id)
            elif action == "connect":
                result = client.connect_initiative_to_project(
                    initiative_id=args.id,
                    project_id=args.project,
                )

        # ========== ROADMAP HANDLERS ==========
        elif resource == "roadmap":
            if action == "create":
                result = client.create_roadmap(
                    name=args.name,
                    description=getattr(args, 'description', None),
                )
            elif action == "update":
                result = client.update_roadmap(
                    roadmap_id=args.id,
                    name=getattr(args, 'name', None),
                    description=getattr(args, 'description', None),
                )
            elif action == "delete":
                result = client.delete_roadmap(args.id)

        # ========== WORKFLOW HANDLERS ==========
        elif resource in ["workflow", "wf"]:
            if action == "create":
                result = client.create_workflow_state(
                    team_id=args.team,
                    name=args.name,
                    type=args.type,
                    color=getattr(args, 'color', None),
                    description=getattr(args, 'description', None),
                )
            elif action == "update":
                result = client.update_workflow_state(
                    state_id=args.id,
                    name=getattr(args, 'name', None),
                    color=getattr(args, 'color', None),
                    description=getattr(args, 'description', None),
                )
            elif action == "archive":
                result = client.archive_workflow_state(args.id)

        # ========== WEBHOOK HANDLERS ==========
        elif resource == "webhook":
            if action == "create":
                result = client.create_webhook(
                    url=args.url,
                    resource_types=args.types,
                    label=getattr(args, 'label', None),
                    enabled=not getattr(args, 'disabled', False),
                )
            elif action == "update":
                result = client.update_webhook(
                    webhook_id=args.id,
                    url=getattr(args, 'url', None),
                    label=getattr(args, 'label', None),
                    enabled=getattr(args, 'enabled', None),
                )
            elif action == "delete":
                result = client.delete_webhook(args.id)

        if result is not None:
            print(json.dumps(result, indent=2))
        else:
            print("Unknown command or not implemented", file=sys.stderr)
            sys.exit(1)

    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
