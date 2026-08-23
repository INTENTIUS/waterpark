---
title: "Approve the change, not the diff"
id: "I14"
lesson: 14
weight: 14
summary: "The reviewer approves the plan block (access delta + proof verdicts) bound by a digest over template, parameters and changeset; the apply job re-creates the changeset and refuses if the digest or the stack moved."
# card — empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 6"
properties: ["VIII", "XIV", "VII"]
closes: ["P3"]
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

- The reviewer approves the plan block (access delta + proof verdicts) bound by a digest over template, parameters and changeset; the apply job re-creates the changeset and refuses if the digest or the stack moved.
- The changeset is the manifest; `describe-change-set` JSON is its native form (the kit's E1 schema is the cross-backend version).
- Provenance is a stated gap (property XIV): the digest proves the plan did not move, not who built the template; an OIDC-attested build checked before `deploy` is the follow-on lesson.

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

decisions 6, 23, 24; [pr-automation](../../docs/pr-automation.md); [the AWS desk](../../docs/aws-desk.md) (the digest).
