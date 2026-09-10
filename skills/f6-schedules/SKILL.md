---
name: waterpark-f6-schedules
description: Walk a student through Fountain lesson 6, Schedules. Use when they want lesson 6, or when they ask how a teammate runs on a cron or who stamps a scheduled run. Gets @reboot refused, makes a disabled daily schedule before the teammate exists and reads the error a run stamps, puts the agent on the team, creates an every-minute schedule and catches the fire on the stream and in the thread, disables it and runs it by hand, runs a one-off on a fresh sandbox, and removes the teammate to find its schedules gone. Three model turns.
---

# water park, Fountain lesson 6, Schedules

You are walking a student through Fountain lesson 6, Schedules
(https://intentius.io/waterpark/courses/fountain/06-schedules/). The outcome
is a scheduled run the scheduler stamped rather than the student, in the
teammate's own thread, and a one-off that opened a fresh computer instead.
About 25 minutes, two of which are waiting for a minute boundary and a
minute after it.

Confirm with the student before applying the manifest, before each
schedule create, before adding the teammate, before each `run`, before the
`PATCH`, before the remove, and before the terminate. Those steps are
marked **confirm**. Reads run freely, which is every `GET`, the stream, and
`fountain conv list`.

This lesson makes three model turns, the fire in 3d, the run in 3e and the
one-off in 3f. Say so before the first one. Between 3d and 3e an
every-minute cron is live, so keep the student moving there, and if the
student stops for any reason disable it first.

## 1. Say what this is

In two or three sentences say this is lesson 6 of the Fountain course. A
schedule is a five-field UTC cron plus a prompt on a teammate, the prompt
goes into the teammate's own thread unless the schedule is one-off, and the
scheduler stamps every run with when it ran, which conversation it went to
and what went wrong. The question the lesson answers is who did the run.
Link the lesson page above.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Also read `.waterpark/profile.json` at the checkout root if it exists.
Trust what it says about the student only when the check's own
`fountain.logged_in` is `true` and `fountain.email` matches the profile's
`email`. A profile file is a claim from a previous run. The check's live
call is the truth, so when they disagree believe the check. If `completed`
lacks `"f5"`, say lesson 5 is where a teammate comes from and this lesson
makes one in a single call, and offer to carry on.

Require, from the check's `fountain` object, `reachable` true, `logged_in`
true, `runner_online` true and `inference_set` true. If `inference_set` is
false, send the student to Start here step 7 and wait. Never ask the
student for an inference key and never go looking for one.

`jq` and `curl` are needed. Ask the student to open a second terminal for
the stream, and tell them every command in it needs the same two shell
variables 3a sets.

Run `fountain conv list` before starting. An account holds two sandboxes at
once and this lesson uses both, the teammate's and the one-off's. If an
earlier lesson left a conversation that is not `terminated`, offer to
terminate it by its full id first. The schedule check waits for 3a, where
the key is set.

## 3. The lesson

### 3a. A plain agent, and the stream

The student writes `f6-manifest.yaml` from step 1 of the lesson page,
which is `content/courses/fountain/06-schedules.md` in this checkout. Read
it from there.

**confirm**, then

```sh
fountain apply -f f6-manifest.yaml
```

`env  +  lesson6-env` and `agent  +  lesson6-agent`. Then the two
variables in both terminals, from step 1. With the key set, read
`curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/schedules | jq '.data | length'`,
and if it is not `0`, say an earlier schedule is live and offer to delete
it, because a stray every-minute cron costs a turn a minute. Then the
stream in the second terminal, `rm -f f6-stream.log` first so a restart
counts from zero, then `tee -a f6-stream.log`. `: connected` and a
heartbeat every fifteen seconds.

(PowerShell reads the credentials file with
`Select-String -Path "$env:USERPROFILE\.fountain\credentials" -Pattern api_key`
and sets `$env:FOUNTAIN_KEY` from the match. The curl calls are identical
on every OS.)

### 3b. Refused, and stamped

**confirm**, then the `@reboot` create from step 2.
`{"errors":{"cron":["@reboot is not a schedule"]}} 422`. Say that a
schedule is a time and not an event.

**confirm**, then the disabled `@daily` create. `201`, `next_run_at` at
midnight UTC tomorrow, and a `schedule` event on the stream. Point at the
timezone, which is UTC whatever the student's clock says. Then the `run`
and the read. `{"error":"not_found"} 404`, and the schedule reads
`last_error` `agent is not on the team` with a `last_run_at`. Say that the
scheduler wrote that stamp for a run that never happened, and that a cron
firing on it overnight would leave the same three fields.

### 3c. On the team

**confirm**, then the add from step 3. `201`, then `TEAMCONV` set to the
teammate's conversation id. Keep it, 3d compares against it.

### 3d. Every minute, and the fire

**confirm**, then the create from step 4. `201`, `next_run_at` the next
whole minute, `last_run_at` `null`. Say what the poll waits for and run
it. When it returns, read the three fields with the student, and point at
the stream, where the fire's `schedule` event lands right after the turn's
first `stage` event and before its `output`.
`last_run_at` on the whole minute, the scheduler's clock. `last_conversation_id`
equal to `TEAMCONV`, the teammate's own thread. `next_run_at` already the
minute after, because the cron does not stop. Then the roster read after
fifteen seconds, `preview.text` `tick`, and say that nobody typed that
prompt.

If `last_run_at` is set and `last_error` reads `conversation_busy`, the
fire landed while the add's provisioning turn was still up, and the next
minute's fire will land. Wait for it.

### 3e. Disable, then run by hand

**confirm**, then the `PATCH` from step 5. `enabled` `false` and
`next_run_at` unchanged. Then the seventy-second wait and the read, the
same `last_run_at` as 3d. Say that disabled means the cron is ignored and
nothing else.

**confirm**, then the `run` and the read after twenty seconds. `202` with
the teammate's conversation id, then a `last_run_at` off the whole minute
and the same conversation. Say that `run` is the cron's own path, stamped
the same way, and works on a disabled schedule because enabled is about
the cron. If it answered `400 conversation_busy`, the previous turn was
still running, wait ten seconds and run it again.

### 3f. A one-off

**confirm**, then the create and the `run` from step 6. `201`, then `202`
with a conversation id that is not `TEAMCONV`. After thirty seconds, the
schedule's `last_conversation_id` names that conversation, `GET
/api/conversations/<id>` shows `channel_id` `null`, and `fountain conv
list` shows two idle conversations under one agent id. Say that the
one-off is not the teammate and never was, that the team stream carried
its two `schedule` events and nothing from the run because the run's
conversation is not on the channel, and that lesson 9's watcher is exactly
this shape.

If the `run` answered `http 429`, the account's second slot is held by an
earlier conversation, and the fix is in section 2.

### 3g. Count, remove, terminate

The `grep -c` from step 7 reads `8`, and if it does not, say which of the
eight the stream missed or which extra call added one, from the list on
the page. Then the schedule list, three rows.

**confirm**, then the `DELETE`. `204`, then the schedule list reads `0`.
Say that removing the teammate deleted every schedule it had, one more
`schedule` event on the stream for all three, and that the one-off's
conversation stayed because it was never bound.

**confirm**, then `fountain conv terminate $ONECONV`, and have the student
close the stream. Leaving the environment and the agent is fine.

## 4. Done when

All four have to be true, checked against the calls rather than the
student's memory.

- The every-minute schedule's `last_run_at` in 3d was on a whole minute,
  its `last_conversation_id` equalled `TEAMCONV`, and the roster's
  `preview.text` read `tick`.
- The `run` in 3e answered `202` and the schedule's `last_run_at` changed
  to a time off the whole minute.
- The one-off's `last_conversation_id` in 3f was a different conversation
  and its `channel_id` was `null`.
- `f6-stream.log` holds a `schedule` event for the create in 3d and one
  for the fire, which is `grep -c '^event: schedule' f6-stream.log` at
  least 2 by the end of 3d.

If the fire never comes, `enabled` is false on the every-minute schedule or
the stream of turns is busy, read `last_error`. If the one-off's
conversation is the teammate's, `one_off` was not `true` in the create,
delete it and restart 3f.

## 5. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"f6"` to its `completed` array, keeping everything already in
it, creating the file and the array if either is missing. Leave every other
field untouched.

```json
{"...": "...", "completed": ["start", "f1", "f2", "f3", "f4", "f5", "f6"]}
```

## 6. Hand off

Say the next step is Fountain lesson 7, Talking to an agent from an app
(https://intentius.io/waterpark/courses/fountain/07-driving-an-agent-from-an-app/),
which is the protocol a page uses to drive a teammate. Tell the student
plainly that lesson 7 is not written yet, so the link is a placeholder
for now.
