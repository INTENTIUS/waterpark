---
title: "One resource type per file"
id: "I1"
lesson: 1
weight: 1
summary: "Scaffold `splashdown/access` as plain CloudFormation JSON: `stacks/<stack>/<Type>/<LogicalId>."
# card — empty renders as TODO
goal: ""
done_when: ""
restart_from: "Fountain course, lesson 1"
properties: ["I"]
closes: ["P1", "P2"]
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

- Scaffold `splashdown/access` as plain CloudFormation JSON: `stacks/<stack>/<Type>/<LogicalId>.json`, one resource per file, the path as the index; `scripts/assemble` (a `jq` merge) makes one template per stack.
- Layout checks: a JSON Schema per resource type (from the CloudFormation resource spec) for the editor, and a tiny check that file name equals logical id.
- No toolchain: a stranger reads a file and predicts the template ([the AWS desk](../../docs/aws-desk.md), the target).

## Watch

{{< todo "video script or link; optional, drop the section if no video" >}}

## Do

{{< todo "the activity: numbered steps, imperative, one job" >}}

1. {{< todo >}}
2. {{< todo >}}
3. {{< todo >}}

## Self-paced

{{< todo "what Floci / your own machine can and cannot show for this lesson" >}}

## Live

{{< todo "what the room sees; timing; the honesty line" >}}

## Back office

[issues](../../docs/issues.md) A1, A2; [the AWS desk](../../docs/aws-desk.md); decision 31.
