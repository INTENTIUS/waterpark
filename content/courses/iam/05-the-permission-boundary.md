---
title: "The permission boundary"
id: "I5"
lesson: 5
weight: 5
summary: "The baseline stack: the boundary `AWS::IAM::ManagedPolicy` every role references by name; the apply role's own boundary (decision 12); the org policy set (live only); default-deny `AWS::EC2::SecurityGroup`s."
# card — empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 4"
properties: ["VI"]
closes: ["P7"]
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

- The baseline stack: the boundary `AWS::IAM::ManagedPolicy` every role references by name; the apply role's own boundary (decision 12); the org policy set (live only); default-deny `AWS::EC2::SecurityGroup`s.
- Boundary contents lean from [delegation](../../docs/design/delegation.md).
- Every other stack references the boundary by deterministic name.

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

[issues](../../docs/issues.md) A6, A7; decisions 11, 12; [threat model](../../docs/threat-model.md).
