---
title: "Personas and principals"
id: "I2"
lesson: 2
weight: 2
summary: "Humans get `AWS::SSO::PermissionSet` + `AWS::SSO::Assignment`, workloads get `AWS::IAM::Role`; no IAM users or groups (decision 5)."
# card — empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 1"
properties: ["V"]
closes: ["P2", "P3"]
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

- Humans get `AWS::SSO::PermissionSet` + `AWS::SSO::Assignment`, workloads get `AWS::IAM::Role`; no IAM users or groups (decision 5).
- Personas as a small set of permission-set and role files copied by convention; one principal per file; `tickets-api`, `tickets`, `rides-board`.
- `expires` on a grant is a date in the policy `Condition` (`aws:CurrentTime`) plus a tag; `scripts/proofs` flags the ones past due.

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

[issues](../../docs/issues.md) A4, A5; [personas](../../docs/design/personas.md).
