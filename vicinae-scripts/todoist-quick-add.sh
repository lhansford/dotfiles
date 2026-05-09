#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title Todoist - Quick Add
# @vicinae.icon https://app.todoist.com/todoist.svg
# @vicinae.mode terminal
# @vicinae.argument1 { "type": "text", "placeholder": "task" }
set -euo pipefail

TODOIST_API_TOKEN="@TODOIST_API_TOKEN@"

if [[ $# -eq 0 ]]; then
	echo "Usage: todoist-quick-add <task content>" >&2
	exit 1
fi

content="$*"

response=$(curl -s -w "\n%{http_code}" \
	"https://api.todoist.com/api/v1/tasks" \
	-H "Authorization: Bearer ${TODOIST_API_TOKEN}" \
	-H "Content-Type: application/json" \
	-d "{\"content\": \"${content}\"}")

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" -ne 200 ]]; then
	echo "Error: Todoist API returned HTTP ${http_code}" >&2
	echo "$body" >&2
	exit 1
fi

echo "Task created: $(echo "$body" | jq -r '.url // .content')"
