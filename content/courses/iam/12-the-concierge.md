---
title: "The concierge"
id: "I12"
lesson: 12
weight: 12
summary: "The AWS desk turns a request into a one-file PR."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "Fountain lessons 4, 7 and 8 and lesson 6"
properties: ["V", "VIII", "IX"]
closes: ["P13"]
# media. provider is youtube, vimeo, file or todo
video:
  provider: todo
  title: ""
  length: ""
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "45 min"
  needs: []
  solo: true
  live: true
---

## Context

- The desk in repo mode takes a request in words, edits one file, runs `terraform plan`, runs `check-no-new-access`, renders the access delta and opens a PR with a PR-only token. The merge is the approval (decision 18). The sandbox holds no cloud credential.
- The worked request is "site-publisher needs read on waterpark-artifacts". An unmapped requester gets a refusal that names the enrollment path. A request that needs the boundary changed gets a refusal that names the platform path.
- The desk's rows join the credential table from Fountain lesson 4. The parts table is filled from the propose loop page.

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

- [The AWS desk](../../docs/aws-desk.md)
- [The propose loop](../../propose-loop.md)
- [Agentic](../../docs/design/agentic.md)
- Decisions 14, 15, 17, 18 and 30
