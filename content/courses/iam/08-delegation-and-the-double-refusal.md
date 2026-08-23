---
title: "Delegation and the double refusal"
id: "I8"
lesson: 8
weight: 8
summary: "A satellite may create roles only inside the boundary, checked twice."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 5"
properties: ["VI"]
closes: ["P8", "P10"]
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

- A satellite repo declares a queue and the role that reads it as CloudFormation inside the boundary. Its deploy role may call `CreateRole` only when `iam:PermissionsBoundary` equals the central ARN. The JSON Schema requires the boundary at build.
- Stripping the boundary fails the schema at build and fails IAM at apply. Floci enforcement of the condition key is unverified.
- The shared schema and the boundary ARN are the delegation contract. A new rule ships as a warning in a minor version and an error in a major version.

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

- [Delegation](../../docs/design/delegation.md)
- [Guardrail rollout](../../docs/design/guardrail-rollout.md)
- Decisions 9 and 20
