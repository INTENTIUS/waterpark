---
title: "Drift"
number: "I7"
weight: 8
theme: "Accessible Ops XI (the live system is the truth) and XIII (manage only what you declare). A cron diff over every owned resource; a hand edit is a finding within one cycle; the reconcile proposes, never purges, and never reopens what a human closed (decision 28)."
summary: "Accessible Ops XI (the live system is the truth) and XIII (manage only what you declare). A cron diff over every owned resource; a hand edit is a finding within one cycle; the reconcile proposes, never purges, and never reopens what a human closed (decision 28)."
properties: ["XI", "XIII"]
closes: ["P11"]
builds_on: ["I6", "F9"]
---

## Outcome

`wp-watch` and `wp-reconcile` (A8) on a schedule; an expired
grant surfaces as drift. This lesson moves the cloud back to the declared
state; I13 is the other direction, proposing changes to the declared state
from findings. Same rules, opposite direction.

## Steps

1. `diff --live` over owned resources on a cron; severity: SG and trust
   drift page-worthy, the rest PR-worthy.
2. Hand-widen `tickets-prod`'s SG ingress (console, or the AWS CLI
   against Floci). The watch flags it.
3. The reconcile opens one PR per resource, branch `reconcile/<key>`,
   marker in the body. The PR restores the declared state (revert); an
   operator who wants the change kept edits the PR to declare it instead.
   Closing it unmerged is a no for that finding until relabeled.
4. Let a grant expire; it appears in the same watch.

## Done when

Prescription 11: flagged within one cycle; the reconcile PR
contains only the owned change; a foreign resource never gets a PR.

## Solo

Floci supports the SG edit and the read path; a five-minute cron
is fine.

## Live

Console edit on screen, watch fires, PR appears. The line: "the
system noticed before the room did."

## Depth

issues A8; decision 28; Rounds README (reconcile against its own
past work).
