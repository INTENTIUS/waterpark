#!/usr/bin/env bash
# new_lesson.sh <week> <shift> <id> <title>   e.g. new_lesson.sh two 16 I16 "Title of the shift"
set -euo pipefail
week=$1; shift_n=$2; id=$3; title=$4
slug=$(printf '%02d-%s' "$shift_n" "$title" | tr '[:upper:]' '[:lower:]' | sed -E "s/[^a-z0-9]+/-/g; s/^-//; s/-$//")
f="content/weeks/${week}/${slug}.md"
[ -e "$f" ] && { echo "exists: $f" >&2; exit 1; }
cat > "$f" <<EOT
---
title: "${title}"
id: "${id}"
shift: ${shift_n}
weight: ${shift_n}
subtitle: ""
summary: ""
# card — fill in; empty renders as TODO
today: ""
done_when: ""
clock_in: "shift $((shift_n-1))"
rule: ""
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

## With the shift lead

{{< todo >}}

## Back office

{{< todo "links into content/docs" >}}
EOT
echo "$f"
