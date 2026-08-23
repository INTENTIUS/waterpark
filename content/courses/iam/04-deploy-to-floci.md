---
title: "Deploy to Floci"
id: "I4"
lesson: 4
weight: 4
summary: "`scripts/assemble` then `aws cloudformation deploy` against Floci endpoints; no account, no keys; live: a real sandbox account."
# card — empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 3"
properties: ["XI", "I", "VII"]
closes: ["P6 (part)"]
# media — provider: youtube | vimeo | file | todo
video:
  provider: todo
  title: ""
  length: ""
# activity — kind: hands-on | watch-along | discuss
activity:
  kind: hands-on
  time: "20 min"
  needs: []
  solo: true
  live: true
---

## Context

- `scripts/assemble` then `aws cloudformation deploy` against Floci endpoints; no account, no keys; live: a real sandbox account.
- Floci: CloudFormation, IAM, STS, EC2 SGs in-process; no Organizations, Identity Center, Access Analyzer (recorded verdicts for those).
- Read a role back with `get-role`; the file predicted it.
- Rollback is native (property VII): a failed update rolls the stack back on its own; a `replacement: true` change is the risky case and waits for a person (lesson 14).

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

[issues](../../docs/issues.md) A13; [multi-account](../../docs/design/multi-account.md) item 3; [upstream](../../docs/upstream.md) (Floci).
