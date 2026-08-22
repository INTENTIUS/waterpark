---
title: "Approve the change, not the diff"
number: "I14"
weight: 15
theme: "Accessible Ops VIII and XIV. The reviewer approves a rendered manifest, the semantic access delta with its proofs, bound by digest; apply refuses when the recompiled manifest or the live estate diverges."
summary: "Accessible Ops VIII and XIV. The reviewer approves a rendered manifest, the semantic access delta with its proofs, bound by digest; apply refuses when the recompiled manifest or the live estate diverges."
properties: ["VIII", "XIV"]
closes: ["P3"]
builds_on: ["I6"]
---

## Outcome

Manifest rendering and digest-bound approval in the
pipeline; Op-manifest diffs rendering gate removals loudly.

## Status

Waits on chant epic items 1, 2 and 9 ([pr-automation.md](../../docs/pr-automation.md));
as of chant 0.44.14 none has landed. Until then the lesson teaches the
mechanics and shows the plain-text renderer.

## Steps

1. The five primitives: scope, plan, present, gate, serialize/freshness.
2. The manifest as the reviewable object; the PR as the envelope.
3. A lexicon bump on unchanged source: the digest changes, apply refuses.
4. Terraform's plan JSON reduced to the same schema (E1) so review is
   backend-blind.

## Done when

Prescription 3's check once the renderer exists.

## Solo / Live

Same until the upstream lands.

## Depth

decisions 6, 23, 24; [pr-automation.md](../../docs/pr-automation.md).
