---
title: "Sign the plan, not the paperwork"
id: "I14"
shift: 14
weight: 14
subtitle: "approve the change, not the diff"
summary: "approve the change, not the diff"
today: "The reviewer approves the rendered manifest (the access delta and its proofs) bound by digest; apply refuses if the recompiled manifest or the live park diverges. This shift waits on chant items 1, 2 and 9; as of chant 0.44.14 none has landed, so until then it teaches the mechanics and shows the plain-text renderer."
done_when: "Prescription 3's check once the renderer exists."
clock_in: "shift 6"
rule: "Escalate the judgment (handbook VIII); verify the artifact (XIV)."
properties: ["VIII", "XIV"]
closes: ["P3"]
---

## Steps

1. The five primitives: scope, plan, present, gate, serialize/freshness.
2. The manifest as the reviewable object; the PR as the envelope.
3. A lexicon bump on unchanged source: the digest changes, apply refuses.
4. Terraform's plan JSON reduced to the same schema (E1) so review is backend-blind.

## Self-paced

Same as with the shift lead until the upstream lands.

## With the shift lead

Same.

## Back office

decisions 6, 23, 24; [pr-automation](../../docs/pr-automation.md).
