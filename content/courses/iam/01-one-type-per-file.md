---
title: "One resource type per file"
id: "I1"
lesson: 1
weight: 1
summary: "The repo is CloudFormation JSON with one resource per file."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "Fountain lesson 1"
properties: ["I"]
closes: ["P1", "P2"]
# media. provider is youtube, vimeo, file or todo
video:
  provider: todo
  title: ""
  length: ""
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "30 min"
  needs: []
  solo: true
  live: true
---

## Context

- `splashdown/access` holds CloudFormation resources at `stacks/<stack>/<Type>/<LogicalId>.json`. `scripts/assemble` merges one directory into one template with `jq`.
- A JSON Schema per resource type checks shape in the editor. A small check requires the file name to equal the logical id.
- A reader predicts the template from the file. No toolchain is involved.

## Watch

{{< todo "Video script or link. Optional." >}}

## Do

{{< todo "Numbered steps. Imperative. One job." >}}

1. {{< todo >}}
2. {{< todo >}}
3. {{< todo >}}

## Self-paced

{{< todo "What Floci or your own machine can and cannot show." >}}

## Live

{{< todo "What the room sees. Timing. The line to say." >}}

## Further reading

- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A1 and A2
- [The AWS desk](../../docs/aws-desk.md)
- Decision 31
