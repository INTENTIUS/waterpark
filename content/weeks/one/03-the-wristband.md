---
title: "The wristband"
id: "F3"
shift: 3
weight: 3
subtitle: "the egress allowlist"
summary: "the egress allowlist"
today: "Give your co-hire a wristband that opens two gates and no others, then watch it get turned away at a third. `networking_type: limited` is a default-deny egress allowlist (`allowed_hosts`; an empty list denies everything). It is the first containment claim any job makes, and it holds only on a hosted sandbox provider."
done_when: "The denied fetch and the allowed fetch are both in the transcript, and you can finish \"the wristband holds only when …\"."
clock_in: "shift 1"
rule: "Bounded blast radius (handbook VI)."
properties: ["VI"]
---

## Steps

1. Hand it a wristband with no gates on it: `networking_type: limited`, no `allowed_hosts`. Send it to fetch anything. It bounces.
2. Add the two gates the job needs: the code host and the thing it operates. Send it again.
3. Run the same Environment from your own truck (shift 10). It gets in everywhere; a runner has no egress policy.
4. Note that `unrestricted` is a no-op on Sprites, which are open by default. `limited` is the only setting that says anything.

## Self-paced

Hosted providers only (Sprites, E2B, Daytona) for the bounce.

## With the shift lead

The bounce is the first thing the crew sees in any job: "this co-hire cannot leave its box except to two gates."

## Back office

Fountain `docs/primitives.md` (networking); [threat model](../../docs/threat-model.md) boundary 5; decision 29.
