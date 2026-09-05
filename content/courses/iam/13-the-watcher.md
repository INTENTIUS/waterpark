---
title: "The watcher"
id: "I13"
lesson: 13
weight: 13
summary: "The desk on a schedule turns findings into capped PRs."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lessons 7 and 12 and Fountain lesson 9"
properties: ["XIII"]
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

- The desk on a schedule turns drift, expired grants and unused-access findings into reconcile and burndown PRs. One PR per finding. Declines stick under Rounds' rules. The same weekday cron drives the rotation check from lesson 9.
- At most five desk PRs are open at once. Five is a constant in `access/baseline/`, the watcher's prompt says so, and the credential-free PR job counts open PRs carrying the desk marker and fails a sixth, so the cap holds when the prompt is ignored (decision 40).
- Rounds as-is can enroll the repo for what its catalogs cover. The IAM projections use the same form.

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

- [The AWS desk](../../docs/aws-desk.md), the watch
- Rounds README
- Decision 28
- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) D3
