---
title: "The fence"
id: "I5"
shift: 5
weight: 5
subtitle: "the permission boundary and the baseline"
summary: "the permission boundary and the baseline"
today: "Build the baseline: the permission boundary every role carries, the apply role's own boundary so the system cannot escalate itself, the org policy set (SCP, RCP, declarative; synthesized, deployable live only), password and MFA policy, default-deny security groups and the typed network layer, the forbidden-actions list. Nothing in the park gets more than the fence allows."
done_when: "A role without the boundary fails lint; every stack references the boundary by deterministic name; the apply role's boundary is in place for shift 6's proof."
clock_in: "shift 4"
rule: "Bounded blast radius (handbook VI)."
properties: ["VI"]
closes: ["P7"]
---

## Steps

1. Start from the aws lexicon's landing-zone composites (A6); document the org-formation coexistence seam.
2. Boundary contents, lean from [delegation](../../docs/design/delegation.md): deny all IAM write, org and Identity Center, guardrail-path resources by name, boundary detachment; allow the service surface a team plausibly needs.
3. The apply role's own boundary (decision 12): denies detaching itself and editing the apply role or baseline outside the pipeline.
4. SG composites, one per file (A7); raw CIDR ingress fails unless allowlisted.

## Self-paced

Floci deploys the boundary and SGs; the org layer synthesizes and is checked by lint only.

## With the shift lead

The org layer deploys to the management account from your org-tier credential; say that it is the narrowest credential in the room.

## Back office

[issues](../../docs/issues.md) A6, A7; decisions 11, 12; [threat model](../../docs/threat-model.md) credential model.
