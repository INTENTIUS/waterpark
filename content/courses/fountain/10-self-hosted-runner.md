---
title: "The self-hosted runner"
id: "F10"
lesson: 10
weight: 10
summary: "A self-hosted runner serves sandboxes from your own machine with no isolation."
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 3"
properties: ["VI"]
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

- `fountain runner` runs on a machine you own. Sandboxes are directories and processes stay alive between turns.
- A runner is trusted mode. It has no VM isolation and no egress policy and must be online to be reachable (ADR 0022).
- Lesson 3 rerun here shows the allowlist not applying. A runner is the counterexample for bounded blast radius.

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

- Fountain ADR 0022
- Fountain ADR 0018
- Decision 29
