---
title: "Credentials and vaults"
id: "F4"
lesson: 4
weight: 4
summary: "Env vars merge environment secrets then vault secrets; the vault wins."
# card — empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 3"
properties: ["V", "VI"]
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

- Env vars merge environment secrets then vault secrets; the vault wins.
- A vault binds to one conversation at creation; `allowed_environment_ids` / `allowed_vault_ids` bound what a caller may attach.
- Mend's split: read token in the repo's vault, write token in the browser, never the sandbox. The credential table (who / holds / can) is reused by lessons 8 and 12 of the IAM course.

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

[workload identity](../../docs/design/workload-identity.md); decision 15; Mend README.
