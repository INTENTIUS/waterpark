---
title: "Delegation and the double refusal"
number: "I8"
weight: 9
theme: "Accessible Ops VI. Role creation decentralizes; authority does not. A satellite's deploy credential may create roles only when `iam:PermissionsBoundary` equals the central ARN; lint enforces the same at build."
summary: "Accessible Ops VI. Role creation decentralizes; authority does not. A satellite's deploy credential may create roles only when `iam:PermissionsBoundary` equals the central ARN; lint enforces the same at build."
properties: ["VI"]
closes: ["P8", "P10"]
builds_on: ["I5"]
---

## Outcome

`@splashdown/waterpark-context` (C2) with the guardrails and
`WorkloadRole`; `splashdown-tickets` (C3) declaring an SQS queue and the
role that reads it, inside the boundary; the boundary condition on the
satellite deploy credential (C6).

## Steps

1. Publish the context package; a new satellite is one dep, three lines of
   config, one resource file.
2. `WorkloadRole({ persona: "service", grants: [read(queue)] })` in the
   satellite; deploy.
3. Strip the boundary: lint refuses at build. Bypass lint (hand-rolled
   template): IAM refuses at apply.
4. Bump the package with a new rule: it lands as warn in a minor; the
   satellite sees it for a cycle before it errors.

## Done when

Prescriptions 8 and 10: two independent refusals with no
platform human involved; an upgrade cannot break a consumer without a warn
cycle.

## Solo

The lint refusal is real. Floci has an IAM enforcement mode that
evaluates boundaries and conditions; whether it honors
`iam:PermissionsBoundary` on `CreateRole` is unverified (plan.md, what is
next). Until it is, solo shows one refusal and says so.

## Live

Both refusals real; the best thirty seconds of any session.

## Depth

[design/delegation.md](../../docs/design/delegation.md);
[design/guardrail-rollout.md](../../docs/design/guardrail-rollout.md); decisions 9, 20.
