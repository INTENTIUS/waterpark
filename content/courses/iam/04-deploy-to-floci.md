---
title: "Deploy to Floci"
id: "I4"
lesson: 4
weight: 4
summary: "The estate deploys to Floci with no account."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 3"
properties: ["XI", "I", "VII"]
closes: ["P6 (part)"]
# media. provider is youtube, vimeo, file or todo
video:
  provider: todo
  title: ""
  length: ""
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "20 min"
  needs: []
  solo: true
  live: true
---

## Context

- `scripts/assemble` then `aws cloudformation deploy` against Floci endpoints needs no account and no keys. Live sessions use a real sandbox account.
- Floci runs CloudFormation, IAM, STS and EC2 security groups in process. It has no Organizations, Identity Center or Access Analyzer. Those verdicts are recorded.
- `get-role` reads a role back. The file predicted it.
- A failed update rolls the stack back on its own. A change marked `replacement` is the risky case and waits for a person in lesson 14.

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

- [Issues](../../docs/issues.md) A13
- [Multi-account](../../docs/design/multi-account.md), item 3
- [Upstream](../../docs/upstream.md), Floci
