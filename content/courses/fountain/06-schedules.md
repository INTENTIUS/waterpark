---
title: "Schedules"
id: "F6"
lesson: 6
weight: 6
summary: "A cron that runs a teammate with a prompt."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/f6-schedules"
# card. empty renders as TODO
goal: "Put a schedule on a teammate and watch the scheduler, not you, stamp the run. Get a cron refused, make a schedule before the teammate exists and read the error it records, create one that fires every minute and catch the fire on the stream and in the thread, disable it and see it go quiet, run it by hand, and run a one-off that opens a fresh computer rather than the teammate's own."
done_when: >-
  the every-minute schedule's `last_run_at` is stamped on the whole minute
  by the scheduler with `last_conversation_id` equal to the teammate's
  conversation and `tick` as the teammate's preview, `run` on the disabled
  schedule answers `202` and stamps a new `last_run_at`, the one-off
  schedule's `last_conversation_id` names a different conversation whose
  `channel_id` is `null`, and `f6-stream.log` holds a `schedule` event for
  the create and for the fire.
restart_from: "lesson 5"
properties: ["XIII"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "25 min"
  needs: ["the Start-here stack running (`just up`, `just register`, `just runner`) with a runner online", "an inference key set, this lesson makes three model turns", "jq, curl, and a second terminal for the stream", "lesson 5, or at least its idea of a teammate"]
  solo: true
  live: true
---

## Context

- A schedule is a five-field cron plus a prompt, on a teammate. `0 9 * * 1-5` is nine in the morning on weekdays, and the times are UTC with no other option. The `@daily` names work and `@reboot` does not, because a schedule is a time and not an event.
- By default the prompt goes into the teammate's own conversation, as if you had typed it, so the reply lands in the thread and in the memory the teammate works from. `one_off: true` opens a fresh conversation on a new sandbox each run, from the same agent, environment and vault the teammate was added with, and the thread stays as it is.
- The scheduler stamps `last_run_at`, `last_conversation_id` and `last_error` on every run, whether the cron fired it or `run` did. That is what makes a scheduled run attributable. The stamp is the scheduler's and not the caller's, and the run is a turn in a thread under an agent id like any other.
- `run` is the same path as the page's Run now. It answers `400 conversation_busy` while the teammate's previous turn is running and `404` when an in-thread schedule's agent is not on the team, and the sandbox quota and subscription refusals are the ones `POST /api/conversations` gives. A schedule can be created for an agent that is not on the team yet, and each run then fails with `agent is not on the team` until it is.
- The team stream sends a `schedule` event, data `{"reason":"changed"}`, when a schedule is created, updated, deleted or fired, and the client re-lists `/api/team/schedules`. Removing a teammate deletes its schedules.
- A schedule that has to fire inside a lesson is `* * * * *`, and that runs a model turn every minute until you stop it, so this lesson disables it after one fire. The three turns here are that fire, one `run` by hand, and one one-off.
- Schedules are the basis of the ambient propose loop in lesson 9, where the teammate on the cron is the watcher and nobody is at the keyboard. Property XIII, manage only what you declare, is what a scheduled operator has to prove every run, and the stamp is the first half of proving it.

## Do

Lesson 5 made a teammate and everything it did was because somebody sent a message. This lesson puts a clock on it, and the interesting question is who did the run.

1. Write a plain environment and an agent to `f6-manifest.yaml`, apply it, and set the two variables every call below uses.

   ```yaml
   apiVersion: fountain.dev/v1
   kind: Environment
   metadata:
     name: lesson6-env
   spec:
     networking_type: unrestricted
   ---
   apiVersion: fountain.dev/v1
   kind: Agent
   metadata:
     name: lesson6-agent
   spec:
     model: anthropic/sonnet
     runtime: claude
     environment: lesson6-env
   ```

   ```sh
   fountain apply -f f6-manifest.yaml
   FOUNTAIN_KEY=$(awk -v p="[${FOUNTAIN_PROFILE:-default}]" '$0==p{f=1;next} /^\[/{f=0} f && $1=="api_key"{gsub(/"/,"",$3); print $3; exit}' ~/.fountain/credentials)
   AGENT=$(fountain agent list --json | jq -r '.[] | select(.name=="lesson6-agent") | .id')
   echo $AGENT
   ```

   Then open the stream in a second terminal with the same two variables
   set there, and leave it open.

   ```sh
   curl -sN -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/stream | tee -a f6-stream.log
   ```

2. Get a cron refused, and make a schedule for a teammate that does not exist yet. The agent is not on the team, and neither call needs it to be.

   ```sh
   curl -s -w ' %{http_code}\n' -X POST -H "Authorization: Bearer $FOUNTAIN_KEY" -H 'Content-Type: application/json' \
     -d '{"cron":"@reboot","prompt":"Reply with the single word tick."}' \
     http://localhost:4000/api/team/$AGENT/schedules
   ```

   `{"errors":{"cron":["@reboot is not a schedule"]}} 422`. A schedule is a
   time. Now one that is a time, disabled so it never fires on its own.

   ```sh
   curl -s -o f6-daily.json -w '%{http_code}\n' -X POST -H "Authorization: Bearer $FOUNTAIN_KEY" -H 'Content-Type: application/json' \
     -d '{"cron":"@daily","prompt":"Reply with the single word tick.","enabled":false,"name":"daily"}' \
     http://localhost:4000/api/team/$AGENT/schedules
   jq -c '.data | {id, cron, enabled, next_run_at, one_off}' f6-daily.json
   DAILY=$(jq -r .data.id f6-daily.json)
   ```

   ```
   201
   {"id":"b0d12f6b-...","cron":"@daily","enabled":false,"next_run_at":"2026-09-11T00:00:00Z","one_off":false}
   ```

   `next_run_at` is midnight, and it is midnight UTC whatever your clock
   says, because that is the only timezone a schedule has. In the second
   terminal the stream printed its first `schedule` event, for the create.
   Now run it, with the agent still not on the team.

   ```sh
   curl -s -w ' %{http_code}\n' -X POST -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/$AGENT/schedules/$DAILY/run
   sleep 3
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/$AGENT/schedules/$DAILY \
     | jq -c '.data | {last_run_at, last_error, last_conversation_id}'
   ```

   ```
   {"error":"not_found"} 404
   {"last_run_at":"2026-09-10T21:59:01Z","last_error":"agent is not on the team","last_conversation_id":null}
   ```

   The run was refused, and the schedule remembers the refusal in its own
   words with a time on it. That is the stamp, and it was written by the
   scheduler for a run that never happened. A cron firing on this schedule
   overnight would leave the same three fields, which is how you would find
   out in the morning that nobody was on the team.

3. Put the agent on the team, the way lesson 5 did.

   ```sh
   curl -s -o /dev/null -w '%{http_code}\n' -X POST -H "Authorization: Bearer $FOUNTAIN_KEY" -H 'Content-Type: application/json' \
     -d "{\"agent_id\":\"$AGENT\"}" http://localhost:4000/api/team
   sleep 6
   TEAMCONV=$(curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team | jq -r '.data[0].conversation.id')
   echo $TEAMCONV
   ```

   `201`, then the teammate's conversation id. Keep it, because step 4 is
   about whether the scheduler writes it.

4. Create a schedule that fires every minute, and catch the fire.

   ```sh
   curl -s -o f6-minute.json -w '%{http_code}\n' -X POST -H "Authorization: Bearer $FOUNTAIN_KEY" -H 'Content-Type: application/json' \
     -d '{"cron":"* * * * *","prompt":"Reply with the single word tick.","name":"every-minute"}' \
     http://localhost:4000/api/team/$AGENT/schedules
   jq -c '.data | {id, cron, enabled, next_run_at, last_run_at}' f6-minute.json
   MINUTE=$(jq -r .data.id f6-minute.json)
   date -u +%H:%M:%SZ
   ```

   ```
   201
   {"id":"38f5df90-...","cron":"* * * * *","enabled":true,"next_run_at":"2026-09-10T22:00:00Z","last_run_at":null}
   21:59:10Z
   ```

   `next_run_at` is the next whole minute. Wait for it, polling the
   schedule until `last_run_at` is set, then read what the scheduler wrote.

   ```sh
   until curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/$AGENT/schedules/$MINUTE | jq -e '.data.last_run_at != null' >/dev/null; do sleep 5; done
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/$AGENT/schedules/$MINUTE \
     | jq -c '.data | {last_run_at, last_conversation_id, last_error, next_run_at}'
   echo $TEAMCONV
   ```

   ```
   {"last_run_at":"2026-09-10T22:00:00Z","last_conversation_id":"8bb13c9d-ea30-402d-9b4b-7caa152e3bd8","last_error":null,"next_run_at":"2026-09-10T22:01:00Z"}
   8bb13c9d-ea30-402d-9b4b-7caa152e3bd8
   ```

   Three things to read. `last_run_at` is on the whole minute, which is
   the scheduler's clock and not your `sleep`. `last_conversation_id` is
   the teammate's own conversation, so the run went into the thread as a
   typed message would. And `next_run_at` has already moved on, because
   this cron does not stop. In the second terminal the stream printed a
   `schedule` event for the create and another for the fire, and between
   them the turn's `stage` and `output` events under the teammate's agent
   id. Then read the thread.

   ```sh
   sleep 15
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team \
     | jq -c '.data[0] | {presence, preview, last_turn: .last_turn.prompt}'
   ```

   ```
   {"presence":{"label":"online","state":"online"},"preview":{"text":"tick","kind":"them"},"last_turn":"Reply with the single word tick."}
   ```

   Nobody typed that prompt. The scheduler did, into the same thread lesson
   5 typed into, and the reply is in the teammate's memory now the way any
   reply is.

5. Disable it before it fires again, and prove it went quiet. Then run it by hand.

   ```sh
   curl -s -X PATCH -H "Authorization: Bearer $FOUNTAIN_KEY" -H 'Content-Type: application/json' \
     -d '{"enabled":false}' http://localhost:4000/api/team/$AGENT/schedules/$MINUTE | jq -c '.data | {enabled, next_run_at}'
   ```

   `{"enabled":false,"next_run_at":"2026-09-10T22:01:00Z"}`. The next run
   is still written down, and it will not happen. Wait past it and read
   `last_run_at` again.

   ```sh
   sleep 70
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/$AGENT/schedules/$MINUTE | jq -c '.data | {last_run_at, enabled}'
   ```

   The same `last_run_at` as step 4, on the minute that fired, and nothing
   for the minute after. Disabled means the cron is ignored and nothing
   else. Run it by hand.

   ```sh
   curl -s -w ' %{http_code}\n' -X POST -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/$AGENT/schedules/$MINUTE/run
   sleep 20
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/$AGENT/schedules/$MINUTE | jq -c '.data | {last_run_at, last_conversation_id}'
   ```

   `{"status":"queued","conversation_id":"8bb13c9d-..."} 202`, then a new
   `last_run_at` that is not on a whole minute, and the same conversation.
   `run` is the same path the cron takes, stamped the same way, and it
   works on a disabled schedule because enabled is about the cron. If you
   sent this while the previous turn was still running, it would have
   answered `400 conversation_busy` like a message does, one thread and
   one turn at a time.

6. Run one on a fresh computer. A one-off schedule opens a new conversation per run, from the teammate's agent, environment and vault, and leaves the thread alone.

   ```sh
   curl -s -o f6-oneoff.json -w '%{http_code}\n' -X POST -H "Authorization: Bearer $FOUNTAIN_KEY" -H 'Content-Type: application/json' \
     -d '{"cron":"0 6 * * 1-5","prompt":"Reply with the single word once.","one_off":true,"name":"one-off"}' \
     http://localhost:4000/api/team/$AGENT/schedules
   ONEOFF=$(jq -r .data.id f6-oneoff.json)
   curl -s -w ' %{http_code}\n' -X POST -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/$AGENT/schedules/$ONEOFF/run
   ```

   `201`, then `{"status":"queued","conversation_id":"b9261ef6-..."} 202`,
   and that conversation id is not the teammate's. It provisions a second
   sandbox, which is the account's other slot. Wait for it and read where
   the run went.

   ```sh
   sleep 30
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/$AGENT/schedules/$ONEOFF | jq -c '.data | {last_run_at, last_conversation_id, last_error}'
   ONECONV=$(curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/$AGENT/schedules/$ONEOFF | jq -r .data.last_conversation_id)
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/conversations/$ONECONV | jq -c '.data | {id, channel_id, status}'
   fountain conv list
   ```

   ```
   {"last_run_at":"2026-09-10T22:00:45Z","last_conversation_id":"b9261ef6-7a9b-4c7a-9602-c9d2ad55d7ea","last_error":null}
   {"id":"b9261ef6-7a9b-4c7a-9602-c9d2ad55d7ea","channel_id":null,"status":"idle"}
   ```

   The one-off's conversation has no channel, so it is not the teammate
   and never was, and `fountain conv list` shows two idle conversations
   under the same agent id, the thread and the one-off. The weekday cron
   on it is real and will open a fresh sandbox at six every weekday morning
   until step 7, which is what a watcher that must start clean each run
   looks like, and lesson 9 uses exactly this.

7. Count the events, then remove the teammate and find what went with it.

   ```sh
   grep -c '^event: schedule' f6-stream.log
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/schedules | jq -c '.data[] | {name, enabled, one_off}'
   curl -s -o /dev/null -w '%{http_code}\n' -X DELETE -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/$AGENT
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/schedules | jq '.data | length'
   fountain conv terminate $ONECONV
   ```

   `8`, one each for the create and the refused run in step 2, the create
   and the fire in step 4, the disable and the run in step 5, and the create
   and the run in step 6. The refused `@reboot` sent nothing, because nothing
   was created. Then three schedules listed, `204`, and `0`. Removing the teammate deleted every
   schedule it had, the disabled one and the one-off included, and the
   one-off's conversation stayed because it was never bound to anything.
   Terminate it by hand, and close the stream with Ctrl-C.

## Self-paced

This lesson needs an inference key and makes three short turns, the fire in step 4, the run in step 5 and the one-off in step 6. Between step 4 and step 5 the every-minute cron is live, so do not walk away with it enabled. Floci plays no part.

Everything the lesson shows, it shows on the class stack, and the runner changes nothing here except that the one-off's fresh sandbox is a second directory under `/sandboxes` on the same runner, which lesson 4's listing command shows.

The event count in step 7 is the one number on this page that depends on you. A `schedule` event is sent when a schedule is created, updated, deleted or fired, so every extra `run` or `PATCH` you tried adds one, and fewer than eight means the stream was not open for one of the eight the page asks for.

## Live

Twenty minutes, with the stream and the schedule list side by side on the projector.

Open on step 2 and let the room see a run refused with `agent is not on the team` written into the schedule by the scheduler. The line to say is that this is the stamp, and it was written for a run that never happened, which is exactly the record you want to find in the morning.

Then step 4 with the clock visible. Create the every-minute schedule at twenty seconds past, and let the room watch nothing happen for forty seconds and then everything happen at once, the `schedule` event, the turn under the agent id, and `tick` in the thread. Then disable it immediately in front of them and say why, which is that a cron costs a model turn every time it fires and this one fires every minute.

Close on step 6, and on the two conversations in `fountain conv list` under one agent. The honesty line is that the thread is the teammate's memory and the one-off has none, and which one a schedule should use is the first design decision of lesson 9.

## Further reading

- Fountain `docs/concepts/teammates.md`, the schedules section
- Fountain's own OpenAPI at `/api/openapi.json` on your instance, the schedule routes, which is where `last_run_at`, `last_conversation_id` and `last_error` are defined
- [The propose loop](../../propose-loop.md), ambient form
- [Lesson 5, the team](05-the-team.md), the teammate a schedule runs on
- [Lesson 9, the propose loop, ambient](09-propose-loop-ambient.md), where a schedule becomes a watcher
