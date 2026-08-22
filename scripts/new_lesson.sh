#!/usr/bin/env bash
# new_lesson.sh <course> <number> <title>   e.g. new_lesson.sh iam I16 "Title of the lesson"
set -euo pipefail
course=$1; number=$2; title=$3
slug=$(printf '%s-%s' "$number" "$title" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-//; s/-$//')
f="content/courses/${course}/${slug}.md"
[ -e "$f" ] && { echo "exists: $f" >&2; exit 1; }
w=$(( $(printf '%s' "$number" | tr -dc '0-9') + 1 ))
cat > "$f" <<EOT
---
title: "${title}"
number: "${number}"
weight: ${w}
theme: ""
summary: ""
properties: []
builds_on: []
---

## Outcome

## Steps

1.

## Done when

## Solo

## Live

## Depth
EOT
echo "$f"
