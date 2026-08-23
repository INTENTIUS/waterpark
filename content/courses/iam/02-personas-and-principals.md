---
title: "Personas and principals"
id: "I2"
lesson: 2
weight: 2
summary: "Humans get permission sets and workloads get roles."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 1"
properties: ["V"]
closes: ["P2", "P3"]
# media. provider is youtube, vimeo, file or todo
video:
  provider: todo
  title: ""
  length: ""
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "25 min"
  needs: []
  solo: true
  live: true
---

## Context

- Humans are `AWS::SSO::PermissionSet` and `AWS::SSO::Assignment` resources. Workloads are `AWS::IAM::Role` resources. There are no IAM users or groups (decision 5).
- A persona is a permission set or role file copied by convention. Each principal is one file. The examples are `tickets-api`, `tickets` and `rides-board`.
- A grant's `expires` is a date in the policy `Condition` on `aws:CurrentTime` plus a tag. `scripts/proofs` flags expired grants.

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

- [Issues](../../docs/issues.md) A4 and A5
- [Personas](../../docs/design/personas.md)
