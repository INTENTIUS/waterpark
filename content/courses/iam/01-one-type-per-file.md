---
title: "One resource per file"
id: "I1"
lesson: 1
weight: 1
summary: "The repo is Terraform with one resource per file."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "Fountain lesson 1"
properties: ["I"]
closes: ["P1", "P2"]
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

- The access repo holds Terraform at `envs/<env>/<resource_type>.<label>.tf`, one `resource` block per file. Terraform already reads every `.tf` in a directory as one module, so there is no assemble step and no generated artifact.
- `terraform validate` checks shape in the editor through the language server. A small check requires the file name to repeat the address of the resource inside it, and fails a file holding two.
- A reader finds a resource by guessing a path and predicts the file from the resource address. That is the whole index.

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

- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A1 and A2
- [The AWS desk](../../docs/aws-desk.md)
- Decision 31
