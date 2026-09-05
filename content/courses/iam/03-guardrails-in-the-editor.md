---
title: "Guardrails in the editor"
id: "I3"
lesson: 3
weight: 3
summary: "The guardrails run in the editor, for the agent and in the PR job alike."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 2"
properties: ["II"]
closes: ["P4"]
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

- `terraform validate` catches shape and `tflint` catches the rules, both in the editor through the language server. The rules require the boundary, forbid inline policies, require the owner tag and forbid raw CIDR sources on security groups.
- Access Analyzer `validate-policy` checks policy documents for wildcard actions and open access. It is a cloud API rather than part of any toolchain, so it works the same whatever the repo is written in. Rule ids map to the parliament and cloudsplaining taxonomies.
- The agent and the PR job run the same checks and get the same diagnostic.

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

- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A3
- [Guardrail rollout](../../docs/design/guardrail-rollout.md)
