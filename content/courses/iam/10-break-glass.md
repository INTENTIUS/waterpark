---
title: "Break-glass"
id: "I10"
lesson: 10
weight: 10
summary: "Break-glass access expires cloud-side whatever else fails."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 6"
properties: ["VII", "VIII"]
closes: ["P9"]
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

- The grant carries cloud-side expiry through a time-conditioned policy or a temporary Identity Center assignment with a two-hour TTL. A scheduled cleanup removes the artifact. The watch flags leftovers.
- The gate is a second human in the workflow. Revocation never depends on the gate.
- Killing the cleanup mid-grant still ends access at the TTL.

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

- [Break-glass](../../docs/design/break-glass.md)
- Decision 8
