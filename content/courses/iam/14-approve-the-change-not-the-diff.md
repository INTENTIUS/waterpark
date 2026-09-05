---
title: "Approve the change, not the diff"
id: "I14"
lesson: 14
weight: 14
summary: "The reviewer approves the rendered plan, bound by a digest."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: ""
# card. empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 6"
properties: ["VIII", "XIV", "VII"]
closes: ["P3"]
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

- The reviewer approves the plan block. It holds the access delta, the proof verdicts and a digest over the saved plan file. The apply job replans and refuses if the digest or the estate moved. Terraform refuses a saved plan whose state has moved on its own, so the check and the applier agree.
- The saved plan is the manifest. `terraform show -json tfplan` is its native form. The E1 schema is the cross-backend version of the same object (decision 23).
- A change that replaces a resource rather than updating it waits for a person. Terraform names these in the plan, and on IAM a replacement means an ARN changes underneath whatever trusts it.
- Provenance is a stated gap. The digest proves the plan did not move, not who produced it. An OIDC-attested build checked before apply is the follow-on lesson, and property XIV is only half closed until then.

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

- Decisions 6, 23 and 24
- [PR automation](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/pr-automation.md)
- [The AWS desk](../../docs/aws-desk.md), the digest
