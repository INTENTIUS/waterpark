---
title: "Someone moved the ropes"
id: "I7"
shift: 7
weight: 7
subtitle: "drift"
summary: "drift"
today: "Put the watch on the rota, then widen a security group by hand in the console. It is flagged within a cycle and one PR appears that puts the ropes back, under Rounds' rules (decision 28). This shift moves the park back to what is declared; shift 13 is the other direction, proposing changes to what is declared."
done_when: "Flagged within one cycle; the reconcile PR contains only the owned change; a foreign resource never gets a PR."
clock_in: "shift 6; week one, shift 9"
rule: "The live system is the truth (handbook XI); manage only what you declare (XIII)."
properties: ["XI", "XIII"]
closes: ["P11"]
---

## Steps

1. `diff --live` over owned resources on a cron (`wp-watch`, A8); severity: SG and trust drift page-worthy, the rest PR-worthy.
2. Hand-widen `tickets-prod`'s SG ingress (console, or the AWS CLI against Floci). The watch flags it.
3. `wp-reconcile` opens one PR per resource, branch `reconcile/<key>`, marker in the body. The PR restores the declared state; an operator who wants the change kept edits the PR to declare it instead. Closing it unmerged is a no for that finding until relabeled.
4. Let a grant expire; it appears in the same watch.

## Self-paced

Floci supports the SG edit and the read path; a five-minute cron is fine.

## With the shift lead

Console edit on screen, watch fires, PR appears. "The park noticed before the crew did."

## Back office

[issues](../../docs/issues.md) A8; decision 28; Rounds README (reconcile against its own past work).
