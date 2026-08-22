---
title: "Night rounds"
id: "I13"
shift: 13
weight: 13
subtitle: "the watcher, in Rounds' form"
summary: "the watcher, in Rounds' form"
today: "Put the co-hire on the rota. Unused-access findings and expiring grants become burndown PRs, one per finding, capped, never reopening what a human closed; a clean round is a good round. Rounds as-is runs against `splashdown/access` for the lint tier; the IAM projections ride the same form. Where shift 7 restores declared state, this proposes changes to it."
done_when: "An unused grant becomes a removal PR citing the finding; volume respects the cap; a closed PR stays declined until relabeled; no PR for foreign resources; the rules table from week one shift 9 filled with its enforcement column."
clock_in: "shift 7, shift 12; week one, shift 9"
rule: "Manage only what you declare (handbook XIII)."
properties: ["XIII"]
---

## Steps

1. Enroll `splashdown/access` in Rounds as-is for the lint tier.
2. A teammate on a weekly cron over the shift 7 watch and the shift 11 projections (D3); the prompt is the spec; the propose endpoint is the enforcement (cap, declined list, branch prefix).
3. An unused grant becomes a removal PR citing the finding; volume respects the cap; no PR for foreign resources.
4. Close one unmerged; next round it is `declined`; label it to take the no back. Read the round report: findings, cluster status, diff; the PR body rendered from the same objects.

## Self-paced

Floci plus Fountain; a five-minute cron.

## With the shift lead

`run now` on stage.

## Back office

Rounds README (what one round does; the rules it runs under); decision 28.
