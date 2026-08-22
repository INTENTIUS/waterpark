---
title: "What the sandbox can reach"
number: "F3"
weight: 4
theme: "`networking_type: limited` is a default-deny egress allowlist (`allowed_hosts`; an empty list denies everything). Egress is the only way anything leaves the sandbox, so the allowlist is the first containment claim any scenario makes, and it holds only on a hosted sandbox provider."
summary: "`networking_type: limited` is a default-deny egress allowlist (`allowed_hosts`; an empty list denies everything). Egress is the only way anything leaves the sandbox, so the allowlist is the first containment claim any scenario makes, and it holds only on a hosted sandbox provider."
builds_on: ["F1"]
---

## Outcome

An agent that can reach exactly the two hosts its job needs
and nothing else, and a clear statement of where that claim does not
hold.

## Steps

1. Environment with `networking_type: limited` and no `allowed_hosts`; ask
   the agent to fetch anything. It cannot.
2. Add the two hosts a job needs (the code host and the thing it
   operates); try again.
3. Run the same Environment on a self-hosted runner: the fetch succeeds,
   because a runner has no egress policy (F10).
4. Note that `unrestricted` is a no-op on Sprites, which are open by
   default; `limited` is the only setting that says anything.

## Done when

The denied fetch and the allowed fetch are both in the
transcript, and you can finish "the allowlist holds only when …".

## Solo

Hosted providers only (Sprites, E2B, Daytona) for the denial.

## Live

The denied `curl` is the first thing the room sees in any
scenario: "this agent cannot leave its box except to two hosts."

## Depth

Fountain `docs/primitives.md` (networking); waterpark
[threat-model.md](../../docs/threat-model.md) boundary 5; decision 29.
