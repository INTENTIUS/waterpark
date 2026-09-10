---
name: waterpark-f5-the-team
description: Walk a student through Fountain lesson 5, The team. Use when they want lesson 5, or when they ask what a teammate is or where the roster comes from. Adds an agent to the team with curl, watches the team stream, reads the roster and the channel-filtered conversation list as two views of one conversation, messages the teammate and sees the turn on the stream and in the preview, gets a 400 for a second message mid-turn, lets it sleep and wakes it, stops the runner to read machine_offline, and removes it. Three model turns.
---

# water park, Fountain lesson 5, The team

You are walking a student through Fountain lesson 5, The team
(https://intentius.io/waterpark/courses/fountain/05-the-team/). The outcome
is a teammate that answers on the team channel, a stream event that shows its
turn under its agent id, and the fact that nothing new was created to do it.
About 25 minutes.

Confirm with the student before applying the manifest, before adding the
teammate, before each message, before stopping and starting the runner, and
before removing the teammate. Those steps are marked **confirm**. Reads run
freely, which is every `GET`, the stream, and `fountain conv list` and
`show`.

This lesson makes three model turns, one word each, in 3e, 3g and 3h. Say
so before the first one. The CLI has no team commands at v0.12.0, so every
write here is `curl` with the student's Bearer key.

## 1. Say what this is

In two or three sentences say this is lesson 5 of the Fountain course. A
teammate is an Agent with one Conversation that continues, bound to the
reserved channel `fountain:team`, and there is no team table and no
teammate record. The roster, the presence and the stream are views over
that conversation, and one thread per agent is what makes the work
attributable, which is Accessible Ops IX. Link the lesson page above.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Also read `.waterpark/profile.json` at the checkout root if it exists.
Trust what it says about the student only when the check's own
`fountain.logged_in` is `true` and `fountain.email` matches the profile's
`email`. A profile file is a claim from a previous run. The check's live
call is the truth, so when they disagree believe the check.

Require, from the check's `fountain` object, `reachable` true, `logged_in`
true, `runner_online` true and `inference_set` true. If `inference_set` is
false, send the student to Start here step 7 and wait. Never ask the
student for an inference key and never go looking for one.

`jq` and `curl` are needed. Step 3h stops and starts the runner container
with `docker compose`, which needs `compose/.env` in this checkout, the one
`just up` ran in. On a second checkout, `bash compose/bin/env.sh` writes
one.

Ask the student to open a second terminal for the stream, and tell them
every command in it needs the same two shell variables 3a sets.

Run `fountain conv list` before starting. An account holds two sandboxes at
once and the teammate takes one. If an earlier lesson left a conversation
that is not `terminated`, offer to terminate it by its full id first.

## 3. The lesson

### 3a. A plain agent

The student writes `f5-manifest.yaml` from step 1 of the lesson page, which
is `content/courses/fountain/05-the-team.md` in this checkout. Read it from
there. Say that nothing in it says team.

**confirm**, then

```sh
fountain apply -f f5-manifest.yaml
```

`env  +  lesson5-env` and `agent  +  lesson5-agent`. Then the two
variables, in both terminals.

```sh
FOUNTAIN_KEY=$(awk -v p="[${FOUNTAIN_PROFILE:-default}]" '$0==p{f=1;next} /^\[/{f=0} f && $1=="api_key"{gsub(/"/,"",$3); print $3; exit}' ~/.fountain/credentials)
AGENT=$(fountain agent list --json | jq -r '.[] | select(.name=="lesson5-agent") | .id')
echo $AGENT
```

(PowerShell reads the credentials file with
`Select-String -Path "$env:USERPROFILE\.fountain\credentials" -Pattern api_key`
and sets `$env:FOUNTAIN_KEY` from the match. The curl calls are identical
on every OS.)

### 3b. The stream

In the second terminal.

```sh
curl -sN -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/team/stream | tee -a f5-stream.log
```

`: connected`, then a `: heartbeat` comment every fifteen seconds. Say that
it carries every teammate's events on one connection and the heartbeats
keep it open, and that if it does close the student runs it again and the
`-a` keeps the log.

### 3c. Add the teammate

**confirm**, then the `POST /api/team` from step 3 of the page. `201`,
and the body has a conversation with `status` `pending` and `channel_id`
`fountain:team`, and a presence reading `starting`. Keep the conversation
id. In the second terminal, a `team` event, then `provision started` and
`provision done` stage events, each with the agent id.

### 3d. Two views

Both `GET`s from step 4 of the page. The roster's one entry and the
conversation list filtered to the channel name the same conversation id,
presence now `online` with the label `ready · waiting for a turn`. Say
that the second call went nowhere near the team API, and that `/team` in
the web UI redirects to the team app, which draws these two answers as a
roster and a thread.

### 3e. Message it

**confirm**, then the first `POST .../messages` from step 5. `202` with
`queued` and the conversation id. Then immediately the second message.
`{"error":"conversation_busy"} 400` if the first turn is still running,
`202` if it already finished, and say that both are the same rule, one
thread takes one turn at a time and says so.

Then walk the three places. The stream in the second terminal, `turn
started`, `output` events and `turn done`, each with `agent_id` and
`conversation_id`. The roster after twenty seconds, `preview.text` reading
`hello` and `last_turn.status` `completed`. And the conversation itself,
`fountain conv show <full id>`.

### 3f. One thread per agent

The second `POST /api/team` from step 6, which writes the body to a file
and prints the code. `200`, not `201`, and the same conversation id. Say that two people messaging this teammate talk to the
same thread on the same machine, and that this is IX by construction.

### 3g. Sleep and wake

The poll from step 7 waits for `asleep`, two minutes after the reply,
which is the class stack's idle bound. Say what the label reads,
`asleep · wakes on message`, and point at the `sandbox` stage event on the
stream that presence is derived from.

**confirm**, then the wake message. `working` two seconds later with the
preview `null`, then `online` with `awake` as the preview once the turn is
done, a few seconds on.

### 3h. The runner away

Say this one is optional and worth doing once. **confirm**, then the
`docker compose ... stop runner` from step 8, the presence read, and the
message.

`machine_offline` with the label
`machine offline · wakes when the runner reconnects`, then the message
accepted with `202`. Then have the student read the stream log. The turn
started and failed in the same millisecond with
`{:unavailable, :runner_offline}`, and the roster shows the prompt as the
preview with `kind` `you` and `last_turn` `failed`. Say that issue 85
expected a `503` on the message and the stack answers one layer down and
a step later, that nothing redelivers it, and that the caller has to read
presence before sending or the stream after.

**confirm**, then `start runner`, the poll, and the read. `online` within
a second, the preview still the unanswered prompt, `last_turn` still
`failed`. If the student waits, the sandbox parks again two minutes on.

### 3i. Remove

**confirm**, then the `DELETE` from step 9 and the three reads. `204`,
`0`, `0`, and `fountain conv list` with the conversation `terminated`. Say
that what was removed was a binding and what is kept is the record. Then
have the student close the stream and count the `team` events.

```sh
grep -c '^event: team' f5-stream.log
```

`4` with step 8, `2` without, and `grep -c runner_offline f5-stream.log`
is `1` with step 8.

Leaving the environment and the agent is fine. Lesson 6 makes its own.

## 4. Done when

All four have to be true, checked against the calls rather than the
student's memory.

- `GET /api/team` returned the teammate with `presence.state` `online` and
  `preview.text` equal to the reply, at step 5 or step 7. After step 8 the
  preview is the lost prompt, which is that step's own point.
- `GET /api/conversations?channel_id=fountain:team` returned exactly that
  one conversation.
- `f5-stream.log` holds a `turn` stage event carrying the agent id and the
  conversation id. `grep -c '"stage":"turn"' f5-stream.log` is at least 2.
- After the `DELETE`, both listings returned `0` and `fountain conv list`
  shows the conversation as `terminated`.

If the add answered `404`, `$AGENT` is empty and 3a's second variable did
not set, restart from 3a. If presence never reaches `asleep`, the stack's
idle bound is not two minutes, check `SANDBOX_IDLE_TIMEOUT_MINUTES` in
`compose/.env`, and carry on from the wake without waiting. If the stream
closed during a step, its log is missing those events, and `tee -a` means
a re-run appends rather than starts over.

## 5. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"f5"` to its `completed` array, keeping everything already in
it, creating the file and the array if either is missing. Leave every other
field untouched.

```json
{"...": "...", "completed": ["start", "f1", "f2", "f3", "f4", "f5"]}
```

## 6. Hand off

Say the next step is Fountain lesson 6, Schedules
(https://intentius.io/waterpark/courses/fountain/06-schedules/), where a
cron runs a teammate with a prompt and the stream sends a `schedule` event
when it fires.
