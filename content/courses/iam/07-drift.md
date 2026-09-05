---
title: "Drift"
id: "I7"
lesson: 7
weight: 7
summary: "A scheduled plan detects drift and a PR restores the declared state."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 6 and Fountain lesson 9"
properties: ["XI", "XIII"]
closes: ["P11"]
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

- `terraform plan -detailed-exitcode` runs on a schedule over every workspace. Exit 0 means the estate matches, exit 2 means it moved and the plan JSON says which resources and attributes. Security group and trust drift pages someone. Other drift opens a PR.
- The reconcile PR restores what the repo declares, under Rounds' rules (decision 28). The watcher in lesson 13 opens it. Restoring is automatic because the file already says what should be true. Keeping an out-of-band change instead means a human writes it into the file, and that asymmetry is deliberate.
- Expired grants surface in the same watch.

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

- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A8
- Decision 28
- [The AWS desk](../../docs/aws-desk.md), the watch
