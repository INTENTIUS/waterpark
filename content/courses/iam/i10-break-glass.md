---
title: "Break-glass"
number: "I10"
weight: 11
theme: "Accessible Ops VII (reversible before risky) and VIII (escalate the judgment). The grant carries cloud-side expiry; saga compensation cleans up; the watch flags leftovers. A dead executor can delay cleanup and never extend access."
summary: "Accessible Ops VII (reversible before risky) and VIII (escalate the judgment). The grant carries cloud-side expiry; saga compensation cleans up; the watch flags leftovers. A dead executor can delay cleanup and never extend access."
properties: ["VII", "VIII"]
closes: ["P9"]
builds_on: ["I6"]
---

## Outcome

The break-glass Op (A9): pluggable approval signal, timed
grant, revocation as compensation, hard cloud-side TTL; TEAM interop
documented.

## Steps

1. ml's on-call requests prod access (scenario 3); the gate is satisfied
   on the local executor by a second human's CLI confirmation, or by a
   Temporal signal where one is deployed.
2. The grant: time-conditioned, 2h TTL, cloud-enforced.
3. Kill the worker mid-grant. Access still ends at the TTL; the watch
   flags the leftover artifact; the restarted worker cleans it up.
4. The Op-manifest diff: a PR removing the gate renders loudly.

## Done when

Prescription 9.

## Solo

Floci evaluates time conditions in enforcement mode; the TTL
expiry is demonstrable. Temporal optional (local executor path).

## Live

Real; this answers "it's 2am Saturday."

## Depth

[design/break-glass.md](../../docs/design/break-glass.md); decision 8.
