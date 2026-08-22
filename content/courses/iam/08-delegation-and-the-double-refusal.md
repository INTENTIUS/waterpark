---
title: "Delegation and the double refusal"
id: "I8"
lesson: 8
weight: 8
summary: "A satellite repo declares a queue and the role that reads it inside the boundary; the deploy credential may create roles only when `iam:PermissionsBoundary` equals the central ARN; the same check in tflint/conftest at build."
# card — empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 5"
properties: ["VI"]
closes: ["P8", "P10"]
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

- A satellite repo declares a queue and the role that reads it inside the boundary; the deploy credential may create roles only when `iam:PermissionsBoundary` equals the central ARN; the same check in tflint/conftest at build.
- Strip the boundary: refused at build; bypass: refused by IAM at apply. Floci enforcement-mode support for the condition key is unverified.
- The shared module / policy package is the delegation contract; rollout warn-minor / error-major.

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

[delegation](../../docs/design/delegation.md); [guardrail rollout](../../docs/design/guardrail-rollout.md); decisions 9, 20.
