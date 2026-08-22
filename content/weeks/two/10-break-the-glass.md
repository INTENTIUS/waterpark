---
title: "Break the glass"
id: "I10"
shift: 10
weight: 10
subtitle: "break-glass with a cloud-side TTL"
summary: "break-glass with a cloud-side TTL"
today: "It is noon on the hottest Saturday of the season, gates open, and the waits on-call needs prod. Grant it with a cloud-side TTL, then kill the worker mid-grant: access still ends on time, the watch flags the leftover artifact, the restarted worker cleans it up. A dead executor can delay cleanup and never extend access."
done_when: "Kill the worker mid-grant; access still ends at the TTL; the watch flags the leftover; the restarted worker removes it."
clock_in: "shift 6"
rule: "Reversible before risky (handbook VII); escalate the judgment (VIII)."
properties: ["VII", "VIII"]
closes: ["P9"]
---

## Steps

1. The on-call requests prod access (scenario 3); the gate is satisfied on the local executor by a second human's CLI confirmation, or by a Temporal signal where one is deployed (A9).
2. The grant: time-conditioned, 2h TTL, cloud-enforced.
3. Kill the worker mid-grant. Access still ends at the TTL; the watch flags the artifact; the restarted worker cleans it up.
4. The Op-manifest diff: a PR removing the gate renders loudly.

## Self-paced

Floci evaluates time conditions in enforcement mode; the TTL expiry is demonstrable. Temporal optional (local executor path).

## With the shift lead

Real; this answers the hottest-Saturday question.

## Back office

[break-glass](../../docs/design/break-glass.md); decision 8.
