---
title: "The rota"
id: "F6"
shift: 6
weight: 6
subtitle: "team schedules"
summary: "team schedules"
today: "Put a crew member on a rota: a cron (five fields, UTC) that runs them with a prompt; `run now` when you can't wait; a `schedule` event on the team stream so an app re-lists instead of polling."
done_when: "`last_run_at` is stamped and the turn is in the thread."
clock_in: "shift 5"
rule: "If nobody is watching, the rota is. The night shift (shift 9) depends on this."
---

## Steps

1. `POST /api/team/:agent_id/schedules` with `cron`, `prompt`, `name`.
2. `POST .../run` and watch the shift take a turn.
3. `one_off: true` for a single future run; `enabled: false` to pause.
4. Read how Rounds presents weekly and daily to a person (`src/lib/cron.ts`).

## Self-paced

Any instance; a five-minute cron is fine.

## With the shift lead

Create the schedule, then `run now`. Nobody waits for a cron.

## Back office

Fountain `docs/api.md` (Schedules); Rounds README (what one round does).
