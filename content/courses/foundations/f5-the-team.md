---
title: "The team"
number: "F5"
weight: 6
theme: "A teammate is a conversation bound to the reserved channel `fountain:team`; one ongoing thread per agent; the roster on the left, the thread on the right. Not a fifth primitive."
summary: "A teammate is a conversation bound to the reserved channel `fountain:team`; one ongoing thread per agent; the roster on the left, the thread on the right. Not a fifth primitive."
builds_on: ["F2"]
---

## Outcome

A teammate you can message, whose computer persists between
messages, visible on `/team` and on the stream.

## Steps

1. Add an agent to the team; watch it provision its computer.
2. Send a message; it is a follow-up turn. Suspend and wake apply.
3. Open `/api/team/stream` and send another message; read the event.
4. Remove the teammate; note what is terminated and what is kept.

## Done when

`GET /api/team` lists the teammate with presence, and the
stream shows the turn.

## Solo

Any instance.

## Live

One teammate per scenario on stage ("the concierge", "the desk",
"the mender"); the room sees the roster.

## Depth

Fountain `docs/primitives.md` (the team page), `docs/api.md`
(`/api/team`).
