---
title: "One path to prod"
id: "I6"
lesson: 6
weight: 6
summary: "The PR is the only path to the estate."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 5"
properties: ["IV", "IX", "XIV", "II"]
closes: ["P5", "P6", "P7"]
# media. provider is youtube, vimeo, file or todo
video:
  provider: todo
  title: ""
  length: ""
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "60 min"
  needs: []
  solo: true
  live: true
---

## Context

- CODEOWNERS is generated from the principal files. Branch protection is declared (A20).
- PR jobs hold no cloud credential. They run `assemble`, the JSON Schema, `validate-policy` and a changeset against Floci. The real changeset and `check-no-new-access` run after the merge queue or behind a maintainer label (decision 22).
- The three credential tiers use OIDC. The plan tier creates and describes changesets. The apply tier runs `cloudformation deploy` under its boundary. The org tier is separate.
- The PR job runs the checks the editor ran.

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

- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A20, A17, A12 and A3b
- Decisions 21 and 22
- [The AWS desk](../../docs/aws-desk.md), the apply job
