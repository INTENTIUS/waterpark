---
title: "The egress allowlist"
id: "F3"
lesson: 3
weight: 3
summary: "Limited networking denies all egress except the listed hosts."
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 1"
properties: ["VI"]
# media. provider is youtube, vimeo, file or todo
video:
  provider: todo
  title: ""
  length: ""
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "15 min"
  needs: []
  solo: true
  live: true
---

## Context

- `networking_type` set to `limited` with `allowed_hosts` is a default-deny egress allowlist. An empty list denies everything.
- The allowlist holds only on a hosted sandbox provider. A self-hosted runner has no egress policy (lesson 10).
- The allowlist is the first containment claim a scenario makes.

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

- Fountain `docs/primitives.md`, networking
- [Threat model](../../docs/threat-model.md), boundary 5
- Decision 29
