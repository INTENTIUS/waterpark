---
title: "The permission boundary"
id: "I5"
lesson: 5
weight: 5
summary: "The permission boundary caps every role and the apply role itself."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 4"
properties: ["VI", "III"]
closes: ["P7"]
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

- The `baseline/` module holds the boundary as an `aws_iam_policy`. Every role references it, and the shared module applies it for you.
- The apply role carries its own boundary so the system cannot escalate itself (decision 12). The org policy set deploys live only. Default-deny security groups live in the baseline too.
- The boundary contents follow the lean in the delegation note.
- The why lives in the repo. The boundary's `description`, and a comment beside each deny, say why it is there. A grant carries its rationale beside its expiry. The decisions ledger is the long form.

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

- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A6 and A7
- Decisions 11 and 12
- [Threat model](../../docs/threat-model.md)
- [Delegation](../../docs/design/delegation.md)
