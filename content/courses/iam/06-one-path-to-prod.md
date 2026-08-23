---
title: "One path to prod"
id: "I6"
lesson: 6
weight: 6
summary: "CODEOWNERS generated from the principal files and declared; branch protection declared (A20)."
# card — empty renders as TODO
goal: ""
done_when: ""
restart_from: "lesson 5"
properties: ["IV", "IX", "XIV", "II"]
closes: ["P5", "P6", "P7"]
# media — provider: youtube | vimeo | file | todo
video:
  provider: todo
  title: ""
  length: ""
# activity — kind: hands-on | watch-along | discuss
activity:
  kind: hands-on
  time: "60 min"
  needs: []
  solo: true
  live: true
---

## Context

- CODEOWNERS generated from the principal files and declared; branch protection declared (A20).
- PR jobs with no cloud credential: `assemble`, JSON Schema, `validate-policy` against Floci, a changeset against Floci; the real changeset and `check-no-new-access` post-merge-queue or behind a maintainer label (decision 22).
- Three credential tiers via OIDC: plan (create-change-set, describe), apply (`cloudformation deploy`, bounded), org.
- The PR job runs the identical checks the editor ran (property II).

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

[issues](../../docs/issues.md) A20, A17, A12, A3b; decisions 21, 22; [the AWS desk](../../docs/aws-desk.md) (the apply job).
