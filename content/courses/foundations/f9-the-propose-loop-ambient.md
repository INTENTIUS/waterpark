---
title: "The propose loop, ambient: Rounds"
number: "F9"
weight: 10
theme: "Same loop, nobody watching, so the defaults invert: a schedule; a reconcile against its own past work before anything else (an open PR for that file → leave it; closed unmerged → a no, until relabeled; merged and the finding is back → new); fix and verify, and a failed verify opens nothing; a server as the propose step that mints a one-target write token for one proposal, checks policy and history, writes the PR body from the findings; a cap; refusals rendered as rows. State lives in GitHub: branch name plus a marker, nothing to sync."
summary: "Same loop, nobody watching, so the defaults invert: a schedule; a reconcile against its own past work before anything else (an open PR for that file → leave it; closed unmerged → a no, until relabeled; merged and the finding is back → new); fix and verify, and a failed verify opens nothing; a server as the propose step that mints a one-target write token for one proposal, checks policy and history, writes the PR body from the findings; a cap; refusals rendered as rows. State lives in GitHub: branch name plus a marker, nothing to sync."
properties: ["XIII"]
builds_on: ["F6", "F8"]
---

## Outcome

You can say which of Rounds' rules live in the server and
which only in the prompt, and why that split is the whole point.

## Steps

1. Run Rounds on a repo of yours: install the App, enroll, `run now`,
   read the round block and the per-cluster diffs; close a PR unmerged;
   run again and see `declined`; label it `rounds:reconsider`; run again.
2. Read *The credential* and *Why there is a server here*: the grant is
   HMAC-signed, the repository is read off the signature, a proposal for
   another repo is refused before GitHub is called, there is deliberately
   no personal-token path.
3. Read the rules table. Draw the line between server-enforced and
   prompt-only.
4. Sketch your own ambient operator in the same table: what the cap is,
   what a decline means for its kind of finding, where the declined list
   lives.

## Done when

The rules table for your own ambient operator, with an
enforcement column.

## Solo

A repo of yours and the GitHub App.

## Live

`run now` on stage; close one; run again.

## Depth

[the propose loop](../../propose-loop.md); Rounds README; decision 28.
