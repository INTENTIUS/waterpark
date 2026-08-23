---
title: "Approve the change, not the diff"
id: "I14"
lesson: 14
weight: 14
summary: "The reviewer approves the rendered plan, bound by a digest."
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

- The reviewer approves the plan block. It holds the access delta, the proof verdicts and a digest over template, parameters and changeset. The apply job re-creates the changeset and refuses if the digest or the stack moved.
- The changeset is the manifest. `describe-change-set` JSON is its native form. The kit's E1 schema is the cross-backend version.
- A change marked `replacement` waits for a person.
- Provenance is a stated gap. The digest proves the plan did not move and not who built the template. An OIDC-attested build checked before `deploy` is the follow-on lesson.

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
- [PR automation](../../docs/pr-automation.md)
- [The AWS desk](../../docs/aws-desk.md), the digest
