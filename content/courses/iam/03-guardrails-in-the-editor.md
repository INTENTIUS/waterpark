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

- JSON Schema checks shape in the editor. It requires the boundary, forbids inline policies, requires the owner tag and forbids CIDR sources on security groups.
- Access Analyzer `validate-policy` checks policy documents for wildcard actions and open access. Rule ids map to the parliament and cloudsplaining taxonomies.
- The agent and the PR job run the same checks and get the same diagnostic.
- The design docs list cfn-lint and chant as alternatives. The site names neither.

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
