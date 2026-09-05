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

- Humans are `aws_ssoadmin_permission_set` and `aws_ssoadmin_account_assignment`. Workloads are `aws_iam_role`. There are no IAM users and no IAM groups (decision 5).
- A persona is a call to a shared module, so a principal file is that call plus a list of grants and nothing else. Each principal is one file. The examples are `site-publisher`, `course-author` and `runner-builder`.
- A grant's expiry is a date in the policy `Condition` on `aws:CurrentTime` plus a tag carrying the same date. `scripts/proofs` flags the ones past due.

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

- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A4 and A5
- [Personas](../../docs/design/personas.md)
