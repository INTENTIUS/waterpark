---
title: "Schedules"
number: "F6"
weight: 7
theme: "A cron (five fields, UTC) that runs a teammate with a prompt. `run now` queues a turn. The team stream sends a `schedule` event so a client re-lists rather than polls."
summary: "A cron (five fields, UTC) that runs a teammate with a prompt. `run now` queues a turn. The team stream sends a `schedule` event so a client re-lists rather than polls."
builds_on: ["F5"]
---

## Outcome

A teammate that runs on a cadence, and the conversation that
shows each run.

## Steps

1. `POST /api/team/:agent_id/schedules` with `cron`, `prompt`, `name`.
2. `POST .../run` and watch the conversation take a turn.
3. `one_off: true` for a single future run; `enabled: false` to pause.
4. Read Rounds' cadence handling (`src/lib/cron.ts`) for how an app
   presents weekly/daily to a user.

## Done when

`last_run_at` is stamped and the turn is in the thread.

## Solo

Any instance; a five-minute cron is fine for the lesson.

## Live

Create the schedule, then `run now`; nobody waits for a cron.

## Depth

Fountain `docs/api.md` (Schedules); Rounds README (what one
round does).
