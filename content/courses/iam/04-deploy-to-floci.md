---
title: "Deploy to Floci"
id: "I4"
lesson: 4
weight: 4
summary: "The estate deploys to Floci with no account."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 3"
properties: ["XI", "I"]
closes: ["P6 (part)"]
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

- A provider block with endpoint overrides points Terraform at Floci, so `terraform apply` needs no account and no keys. Live sessions point the same code at a real sandbox account.
- Floci runs IAM, STS, S3 and EC2 security groups in process. It has no Organizations, Identity Center or Access Analyzer. Those verdicts are recorded.
- `get-role` reads a role back from the cloud rather than from state. The file predicted it.
- Terraform keeps a state file, which is the thing property XI warns about. The lesson names the cost rather than hiding it (decision 32). State goes in its own bucket with locking, it is never the system of record, and every read in these lessons goes to the cloud instead.
- A failed apply stops and leaves behind what it already made, with no automatic rollback. That is a real difference from an applier that rolls back, and the answer is small changes planned first, not a bigger apply.

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

- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A13
- [Multi-account](../../docs/design/multi-account.md), item 3
- [Upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md), Floci
