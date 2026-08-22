#!/usr/bin/env bash
# new_lesson.sh <course> <lesson> <id> <title>   e.g. new_lesson.sh iam 16 I16 "Title of the lesson"
set -euo pipefail
course=$1; n=$2; id=$3; title=$4
slug=$(printf '%02d-%s' "$n" "$title" | tr '[:upper:]' '[:lower:]' | sed -E "s/[^a-z0-9]+/-/g; s/^-//; s/-$//")
f="content/courses/${course}/${slug}.md"
[ -e "$f" ] && { echo "exists: $f" >&2; exit 1; }
cat > "$f" <<EOT
---
title: "${title}"
id: "${id}"
lesson: ${n}
weight: ${n}
summary: ""
# card — empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson $((n-1))"
properties: []
# media — provider: youtube | vimeo | file | todo
video:
  provider: todo
  title: ""
  length: ""
# activity — kind: hands-on | watch-along | discuss
activity:
  kind: hands-on
  time: ""
  needs: []
  solo: true
  live: true
---

## Context

- {{< todo "what's underneath; sources" >}}

## Watch

{{< todo "video script or link; optional" >}}

## Do

1. {{< todo >}}

## Self-paced

{{< todo >}}

## Live

{{< todo >}}

## Back office

{{< todo "links into content/docs" >}}
EOT
echo "$f"
