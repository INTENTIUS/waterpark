---
title: "The propose loop, interactive: Mend and the desk"
number: "F8"
weight: 9
theme: "The propose loop ([the propose loop](../../propose-loop.md)): a target the agent does not control, a deterministic read, an operator that can read and nothing more, a plan rendered as a diff, a verify before propose, a propose step held by something that is not the operator, rules enforced where the write happens, the conversation or the code host as the record, refusals as outcomes. Interactive means a human is the propose step: Mend when the read is an audit, dns-desk when the read is a request."
summary: "The propose loop ([the propose loop](../../propose-loop.md)): a target the agent does not control, a deterministic read, an operator that can read and nothing more, a plan rendered as a diff, a verify before propose, a propose step held by something that is not the operator, rules enforced where the write happens, the conversation or the code host as the record, refusals as outcomes. Interactive means a human is the propose step: Mend when the read is an audit, dns-desk when the read is a request."
properties: ["IV", "VIII"]
builds_on: ["F4", "F7"]
---

## Outcome

You can fill the parts table for Mend and for the desk from
memory, and say which part differs between them.

## Steps

1. Run Mend against a repo of yours: the report with its three tiers,
   the plan with applied/proposed/skipped, the per-fix diffs, the PR
   opened from your browser with your token; note the mender's vault
   still holds only a read token.
2. Run dns-desk against a throwaway zone: the state, the plan as a diff,
   `APPROVE plan-id`, the re-read before apply, the status derived from
   the conversation and never stored.
3. Read Mend's *Opening a pull request* (every context line re-verified
   against the file as it is on GitHub now; refuse if it moved) next to
   the desk's re-read-before-apply. Same part, two targets.
4. Fill the parts table from [the propose loop page](../../propose-loop.md) for each. The
   credential rows are F4's table; do not redo them here.

## Done when

Two filled parts tables, and the one part that differs
between an audit-driven and a request-driven operator.

## Solo

A repo and a zone of yours.

## Live

Mend on the room's repo; the PR from the facilitator's browser.
Point at the token that did it.

## Depth

[the propose loop](../../propose-loop.md); Mend and dns-desk READMEs; decisions
14, 15, 18, 30.
