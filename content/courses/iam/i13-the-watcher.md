---
title: "The watcher"
number: "I13"
weight: 14
theme: "Accessible Ops XIII. Rounds' form on IAM: a scheduled teammate turns unused-access findings and expiring grants into burndown PRs, one per finding, capped, never reopening what a human closed; a clean round is a good round. Where I7 restores declared state, this proposes changes to it."
summary: "Accessible Ops XIII. Rounds' form on IAM: a scheduled teammate turns unused-access findings and expiring grants into burndown PRs, one per finding, capped, never reopening what a human closed; a clean round is a good round. Where I7 restores declared state, this proposes changes to it."
properties: ["XIII"]
builds_on: ["F6", "F9", "I7", "I12"]
---

## Outcome

Rounds as-is enrolled on `pepperoni/access` for the lint
tier; the hygiene agent (D3) as the same form over the I7 watch and the
I11 projections, with a server-side policy (cap, declined list, branch
prefix) the prompt cannot override.

## Steps

1. A teammate on a weekly cron; the prompt is the spec; the propose
   endpoint is the enforcement.
2. An unused grant becomes a removal PR citing the finding; volume respects
   the cap; no PR for foreign resources.
3. Close one unmerged; next round it is `declined`; label it to take the
   no back.
4. The round report: findings, cluster status, diff; the PR body rendered
   from the same objects.

## Done when

D3's acceptance criteria, the rules table from F9 with its enforcement column, and the credential row added to F4's table.

## Solo

Floci plus Fountain; a five-minute cron.

## Live

`run now` on stage.

## Depth

Rounds README (what one round does; the rules it runs under);
decision 28.
