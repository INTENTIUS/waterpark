---
title: "The egress allowlist"
id: "F3"
lesson: 3
weight: 3
summary: "`networking_type: limited` with `allowed_hosts` is default-deny; an empty list denies everything."
# card — empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 1"
properties: ["VI"]
# media — provider: youtube | vimeo | file | todo
video:
  provider: todo
  title: ""
  length: ""
# activity — kind: hands-on | watch-along | discuss
activity:
  kind: hands-on
  time: "15 min"
  needs: []
  solo: true
  live: true
---

## Context

- `networking_type: limited` with `allowed_hosts` is default-deny; an empty list denies everything.
- Holds only on a hosted sandbox provider; a self-hosted runner has no egress policy (lesson 10).
- The first containment claim any scenario makes.

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

## Further reading

Fountain `docs/primitives.md` (networking); [threat model](../../docs/threat-model.md) boundary 5; decision 29.
