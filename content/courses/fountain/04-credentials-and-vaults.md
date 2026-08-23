---
title: "Credentials and vaults"
id: "F4"
lesson: 4
weight: 4
summary: "A vault binds one credential to one conversation."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 3"
properties: ["V", "VI", "X"]
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

- Fountain merges environment secrets first and vault secrets second. The vault wins.
- A vault binds to one conversation at creation. `allowed_environment_ids` and `allowed_vault_ids` limit what a caller may attach.
- Mend keeps the read token in the repo's vault and the write token in the browser. The sandbox never holds the write token.
- Removing the vault revokes the credential. No rotation ceremony is needed.
- The table of who holds which credential and what it can do is reused in Fountain lesson 8 and IAM lesson 12.

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

- [Workload identity](../../docs/design/workload-identity.md)
- Decision 15
- Mend README
