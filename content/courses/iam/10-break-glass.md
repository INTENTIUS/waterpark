---
title: "Break-glass"
id: "I10"
lesson: 10
weight: 10
summary: "The grant carries cloud-side expiry (time-conditioned policy / temporary assignment, 2h TTL); cleanup by a scheduled job or Op; the watch flags leftovers."
# card — empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 6"
properties: ["VII", "VIII"]
closes: ["P9"]
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

- The grant carries cloud-side expiry (time-conditioned policy / temporary assignment, 2h TTL); cleanup by a scheduled job or Op; the watch flags leftovers.
- Terraform has no executor: the gate is a second human's approval in the workflow; revocation never depends on it.
- Kill the cleanup mid-grant; access still ends at the TTL.

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

[break-glass](../../docs/design/break-glass.md); decision 8.
