---
title: "The night shift"
id: "F9"
shift: 9
weight: 9
subtitle: "the propose loop, ambient (Rounds)"
summary: "the propose loop, ambient (Rounds)"
today: "Same loop, nobody watching, so the defaults invert: a schedule; a reconcile against its own past work before anything else; fix and verify, and a failed verify opens nothing; a server as the propose step that mints a one-target write token for one proposal, checks policy and history, and writes the PR body from the findings; a cap; refusals rendered as rows. State lives in GitHub: branch name plus a marker, nothing to sync."
done_when: "The rules table for your own ambient operator, with an enforcement column."
clock_in: "shift 6 and shift 8"
rule: "Manage only what you declare (handbook XIII); a clean round is a good round."
properties: ["XIII"]
---

## Steps

1. Run Rounds on a repo of yours: install the App, enroll, `run now`, read the round block and the per-cluster diffs. Close a PR unmerged; run again; it is `declined`. Label it `rounds:reconsider`; run again.
2. Read *The credential* and *Why there is a server here*: the grant is HMAC-signed, the repository is read off the signature, a proposal for another repo is refused before GitHub is called, there is deliberately no personal-token path.
3. Read the rules table. Draw the line between server-enforced and prompt-only.
4. Sketch your own night-shift operator in the same table: what the cap is, what a decline means for its kind of finding, where the declined list lives.

## Self-paced

A repo of yours and the GitHub App.

## With the shift lead

`run now` on stage; close one; run again.

## Back office

[the propose loop](../../propose-loop.md); Rounds README; decision 28.
