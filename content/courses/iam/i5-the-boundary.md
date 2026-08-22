---
title: "The boundary"
number: "I5"
weight: 6
theme: "Accessible Ops VI (bounded blast radius). A permission boundary caps what any identity-based policy can grant; the apply credential is bounded too, so the system cannot escalate itself."
summary: "Accessible Ops VI (bounded blast radius). A permission boundary caps what any identity-based policy can grant; the apply credential is bounded too, so the system cannot escalate itself."
properties: ["VI"]
closes: ["P7"]
builds_on: ["I4"]
---

## Outcome

The baseline component: the boundary, the org policy set
(SCP + RCP + declarative, synthesized; deployable live only), password/MFA
policy, default-deny SGs and the typed network layer (A7), the
forbidden-actions list; every role references the boundary by
deterministic name.

## Steps

1. Start from the aws lexicon's landing-zone composites (A6); document
   the org-formation coexistence seam.
2. Boundary contents, lean from [design/delegation.md](../../docs/design/delegation.md):
   deny all IAM write, org and Identity Center, guardrail-path resources
   by name, boundary detachment; allow the service surface an app team
   plausibly needs.
3. The apply role's own boundary (decision 12): denies detaching itself
   and editing the apply role or baseline outside the pipeline.
4. SG composites, one per file; raw CIDR ingress fails unless allowlisted.

## Done when

Prescription 7's structure is in place (the proof that the
apply role cannot detach its boundary runs in I6 live); a role without
the boundary fails lint.

## Solo

Floci deploys the boundary and SGs; the org layer synthesizes
and is checked by lint only.

## Live

The org layer deploys to the management account from the
facilitator's org-tier credential; say that it is the narrowest
credential in the room.

## Depth

issues A6, A7; decisions 11, 12; [threat-model.md](../../docs/threat-model.md)
credential model.
