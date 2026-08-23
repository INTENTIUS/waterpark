---
title: "Four primitives"
id: "F1"
lesson: 1
weight: 1
summary: "Fountain is made of four objects."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "none, this is the first lesson"
properties: ["III"]
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

- Environment, Vault, Agent and Conversation are the only objects in Fountain.
- `fountain apply -f` applies documents with `apiVersion` `fountain.dev/v1`. The API never returns a secret value.
- The UI, the API and the CLI expose the same objects. The CLI wraps the API.

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

- Fountain `docs/primitives.md`
- Fountain `cli/README.md`
