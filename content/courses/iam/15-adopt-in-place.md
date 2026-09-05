---
title: "Adopt in place"
id: "I15"
lesson: 15
weight: 15
summary: "Existing resources come under management by import with nothing touched."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 6"
properties: ["I", "XII"]
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

- An `import` block brings a pre-existing role and security group under management. You write the file and plan, or let `terraform plan -generate-config-out` write the first draft of the file from what is live. Nothing changes on day one, and the plan proves it by showing no changes. A `removed` block backs a resource out of management without destroying it.
- The estate stays in native form, so walking away means keeping the HCL and dropping everything else. There is no export bundle to build because there is nothing proprietary to export from.

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

- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A14 and A21
- Decision 2
- [Landscape](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/landscape.md), IAMbic
