---
title: "Teams bring their own rides"
id: "I8"
shift: 8
weight: 8
subtitle: "delegation and the double refusal"
summary: "delegation and the double refusal"
today: "Let the tickets team declare an SQS queue and the role that reads it in their own repo, inside the fence: a satellite's deploy credential may create roles only when `iam:PermissionsBoundary` equals the central ARN, and lint enforces the same at build. Then strip the fence: lint refuses at build; bypass lint: IAM refuses at apply. Nobody from the platform team is involved either time."
done_when: "Two independent refusals with no platform human involved; a context-package upgrade cannot break a satellite without a warn cycle."
clock_in: "shift 5"
rule: "Bounded blast radius (handbook VI): rides decentralize, the fence does not."
properties: ["VI"]
closes: ["P8", "P10"]
---

## Steps

1. Publish `@splashdown/waterpark-context` (C2): guardrails, presets, `WorkloadRole`. A new satellite is one dep, three lines of config, one resource file.
2. In `splashdown-tickets` (C3): `WorkloadRole({ persona: "service", grants: [read(queue)] })`; deploy.
3. Strip the boundary: lint refuses at build. Bypass lint with a hand-rolled template: IAM refuses at apply (C6).
4. Bump the package with a new rule: it lands as warn in a minor; the satellite sees it for a cycle before it errors.

## Self-paced

The lint refusal is real. Floci has an IAM enforcement mode that evaluates boundaries and conditions; whether it honors `iam:PermissionsBoundary` on `CreateRole` is unverified. Until it is, show one refusal and say so.

## With the shift lead

Both refusals real; the best thirty seconds of any session.

## Back office

[delegation](../../docs/design/delegation.md); [guardrail rollout](../../docs/design/guardrail-rollout.md); decisions 9, 20.
