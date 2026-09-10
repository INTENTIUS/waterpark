---
name: waterpark-f10-self-hosted-runner
description: Walk a student through Fountain lesson 10, The self-hosted runner. Use when they want lesson 10, or when they ask what the class stack's runner isolates or guarantees. Reads the runner from the API, Docker and inside its container, replays the limited-environment refusal, has a second sandbox list its sibling's directory, reads both directories as one user from the runner's shell, stops the container to get a 409 on a new run and a runner_offline failure on a parked one, restarts it, and fills the trade table. Three model turns.
---

# water park, Fountain lesson 10, The self-hosted runner

You are walking a student through Fountain lesson 10, The self-hosted
runner
(https://intentius.io/waterpark/courses/fountain/10-self-hosted-runner/).
The outcome is the class stack's runner read as what it is, and the three
things Fountain's decision record says it has none of, an egress policy,
isolation between sandboxes, and reachability when the daemon is down, each
shown on the stack. About 25 minutes.

Confirm with the student before applying the manifest, before each
conversation, before stopping and starting the runner container, before
each terminate, and before the `rm -rf` on the runner. Those steps are
marked **confirm**. Reads run freely, which is every `GET`, `docker compose
ps`, the runner shell listings, and `fountain conv list`.

This lesson makes three model turns, two in 3d and one at the end of 3e,
plus one that fails on purpose while the runner is down. Say so before the
first one.

## 1. Say what this is

In two or three sentences say this is lesson 10 of the Fountain course, that
`fountain runner` is a daemon on a machine you own which dials out with your
API key and serves directories as sandboxes, and that Fountain's own
decision record says trusted mode is the only mode, no VM, no container, no
egress policy, and the daemon must be online. The lesson reads each of
those on the stack every earlier lesson ran on. Link the lesson page above.

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

`jq` and `curl` are needed. Step 3e stops and starts the runner container
with `docker compose`, and `just runner-sh` reads `compose/.env`, so this
runs in the checkout `just up` ran in. On a second checkout,
`bash compose/bin/env.sh` writes one.

Run `fountain conv list` before starting. An account holds two sandboxes at
once and 3d uses both. If an earlier lesson left a conversation that is not
`terminated`, offer to terminate it by its full id first.

## 3. The lesson

### 3a. Read the runner three ways

Set the key from step 1 of the lesson page, which is
`content/courses/fountain/10-self-hosted-runner.md` in this checkout, and
run the three reads there. The API answer with `name`, `root`
`/sandboxes`, `online` true and an `id` that every sandbox name on this
runner starts with. The compose listing with one `compose-runner-1`
container. The shell listing with `uid=1001(runner)`, PID 1 reading
`fountain runner --name waterpark --root /sandboxes`, and an environment
holding `FOUNTAIN_API_KEY` and the emulator's `AWS_` pair.

Say what to read off that. One container, one process, one user, and the
student's own API key on the daemon because that is what authenticates its
socket. Every sandbox here is a directory that user owns.

(PowerShell reads the credentials file with
`Select-String -Path "$env:USERPROFILE\.fountain\credentials" -Pattern api_key`
and sets `$env:FOUNTAIN_KEY` from the match. The curl calls are identical
on every OS.)

### 3b. The manifest

The student writes `f10-manifest.yaml` from step 2 of the page. Two
environments, one unrestricted with a secret and one `limited` with
`api.github.com` allowed, and an agent on each.

**confirm**, then

```sh
fountain apply -f f10-manifest.yaml
```

Two `env  +`, one `secret  ~`, two `agent  +`.

### 3c. No egress policy

**confirm**, then the locked run from step 3. `provision: started`,
`network: failed`, `provisioning failed — the sandbox never started`, and
a non-zero exit. Say that this is lesson 3 in one step, that the events
call there names `backend_lacks_network_policy` and `provider: runner`,
and that it goes first because a refused run holds no sandbox slot. Say
what the unrestricted agent can reach instead, which is the host's whole
network.

### 3d. No isolation

**confirm**, then the two runs from step 4, the same prompt twice. The
first answers with one directory and the second with two. Say that a
sandbox can see its sibling. Then the runner shell listing. Both
directories `drwx------` and `runner runner`, both `.env` files holding
`RUNNER_SECRET='runner-secret-777'` beside their conversation ids.

Walk the mode and the owner together. The mode keeps other users out and
there is one user, so a process in either sandbox can open the other's
`.env`, transcript and state. Point at lesson 4's credential table, whose
runner-disk row says anyone with the runner's disk, and say this is why.

### 3e. Must be online

**confirm**, then `fountain conv list`, and terminate the second
conversation by its full id to free a slot. **confirm**, then stop the
container with the `docker compose ... stop runner` line from step 5,
wait five seconds, and read the runners endpoint. `online` false with a
`last_seen_at`.

**confirm**, then the new run and the prompt to the first conversation.
The run answers `http 409` saying this agent runs on a self-hosted runner
and none of yours is connected, with `start fountain runner on the machine
and try again` as the fix, and the prompt streams `turn: started`, `turn failed`. Say that the new run
is refused before anything is minted, with the fix in the message, and that
the parked one's events show `{:unavailable, :runner_offline}`, the word for
a directory on a machine that is switched off, which the decision record
says is never `not_found` because the directory is still the memory.

**confirm**, then `start runner`, wait five seconds, read the runners
endpoint, `online` true with a new `connected_at`, and prompt the first
conversation again. `back`. Say that nothing was reachable while the
machine was off and nothing was lost.

### 3f. The trade table

Show the student the table in step 6 of the page and have them read each
row against the step it names. Say that the right column is what lesson 3
no longer guarantees on a runner, that it is the whole of Accessible Ops
VI, and that decision 29 is the course saying a containment claim rests on
a hosted provider and not on this.

### 3g. Tidy up

**confirm**, then terminate the first conversation by its full id.
**confirm**, then the runner shell line from step 7 with the `rm -rf`. The
parked directory survives the terminate, which lesson 4 found, and the
listing reads `0` after the remove. Leaving the environments and agents is
fine.

## 4. Done when

All four have to be true, checked against the calls rather than the
student's memory.

- `GET /api/runners` listed the runner with `online` true and `root`
  `/sandboxes`, and the `limited` run in 3c exited non-zero on
  `network: failed`.
- The second run in 3d listed two directories, and the runner shell showed
  both as `runner runner` with the same `RUNNER_SECRET` in each `.env`.
- With the container stopped, `fountain run` answered `http 409` naming
  `fountain runner`, and the prompt to the parked conversation printed
  `turn failed`.
- With the container started, the runners endpoint read `online` true and
  the same conversation answered `back`.

If the second run in 3d answers `http 429`, an earlier conversation holds a
slot, terminate it and run again. If the runner does not go offline within
a minute of the stop, `docker compose ... ps` will show whether the stop
took, and the fix is to run it from the checkout `just up` ran in. If the
prompt after the restart fails, wait for `online` true before sending it.

## 5. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"f10"` to its `completed` array, keeping everything already in
it, creating the file and the array if either is missing. Leave every other
field untouched.

```json
{"...": "...", "completed": ["start", "f1", "f2", "f3", "f4", "f5", "f6", "f10"]}
```

## 6. Hand off

Say the next step is Fountain lesson 11, No approval gate in Fountain
(https://intentius.io/waterpark/courses/fountain/11-no-gate-in-fountain/),
which closes the course with the one thing the runtime will not do and the
map of where each scenario's gate is instead.
