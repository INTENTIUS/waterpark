---
title: "The crew"
id: "F5"
shift: 5
weight: 5
subtitle: "the team page"
summary: "the team page"
today: "Put a co-hire on the crew. A teammate is one ongoing shift bound to the reserved channel `fountain:team`, with a computer that persists between messages; the roster on the left, the thread on the right. Not a fifth primitive."
done_when: "`GET /api/team` lists the teammate with presence, and `/api/team/stream` shows the turn."
clock_in: "shift 2"
rule: "One crew member, one thread; you can always find what they did."
---

## Steps

1. Add an agent to the team; watch it provision its computer.
2. Send a message; it is a follow-up turn. Suspend and wake apply as in shift 2.
3. Open `/api/team/stream` and send another message; read the event.
4. Remove the teammate; note what is terminated and what is kept.

## Self-paced

Any instance.

## With the shift lead

One teammate per job on stage ("the desk", "the watcher"); the crew sees the roster.

## Back office

Fountain `docs/primitives.md` (the team page); `docs/api.md` (`/api/team`).
