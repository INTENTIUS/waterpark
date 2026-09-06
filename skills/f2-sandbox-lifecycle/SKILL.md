---
name: waterpark-f2-sandbox-lifecycle
description: Walk a student through Fountain lesson 2, The sandbox lifecycle. Use when they want lesson 2, or when they ask what happens to a sandbox that goes idle. Starts one conversation, finds its sandbox as a directory on the class stack's runner, puts a file in it, waits for Fountain to park it after two idle minutes, wakes it with a second prompt onto the same sandbox with the file intact, then terminates it and shows the directory gone. Needs no inference key.
---

# water park, Fountain lesson 2, The sandbox lifecycle

You are walking a student through Fountain lesson 2, The sandbox lifecycle
(https://intentius.io/waterpark/courses/fountain/02-sandbox-lifecycle/). The
outcome is one sandbox watched through a park and a wake, with the same
sandbox id and the same directory on both sides and a file that survived,
then a terminate that removes the directory and keeps the transcript.
About 15 minutes, three of them waiting.

Confirm with the student before applying the manifest, before starting the
conversation, before writing into the sandbox directory, before the wake
prompt, and before the terminate. Those steps are marked **confirm**. Every
read command, showing a conversation, fetching its events, listing a
directory on the runner, runs freely with no confirmation.

Nothing in this lesson needs a model reply. On a keyless account every
turn fails at the model and every check still passes, because the checks
are fields on the API and files on disk.

## 1. Say what this is

In two or three sentences say this is lesson 2 of the Fountain course. A
conversation runs in a sandbox with its own disk. Fountain keeps two
bounds on that sandbox (ADR 0017). Past the idle bound it is suspended,
its processes stop and its disk stays, and the next prompt reattaches to
the same disk. Past the lifetime ceiling it is destroyed and the disk goes.
The class stack sets the idle bound to two minutes so the park can be
watched in one sitting. Link the lesson page above.

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

Require, from the check's `fountain` object, `reachable` true,
`logged_in` true, and `runner_online` true, before doing anything else.
If `runner_online` is false, say `just runner` starts it and wait.

Do **not** require `inference_set`, and do not send the student back to
Start here step 7 if it is false. Never ask the student for an inference
key and never go looking for one. Tell them the lesson runs keyless and
what a key would add, which is the agent writing and reading the file
itself.

Note the check's `fountain.cli_url`. Every command below that names a
URL uses it, substitute the real value the check reported.

Then confirm the stack carries the idle bound. A read command.

```sh
docker compose -f compose/docker-compose.yml --env-file compose/.env exec fountain env | grep SANDBOX_
```

Expect `SANDBOX_IDLE_TIMEOUT_MINUTES=2` and `SANDBOX_MAX_LIFETIME_HOURS=24`
among the lines. If neither prints, the stack was started before the
bounds were added to the compose file. Say that `just up` recreates
Fountain with them and that the runner reconnects on its own a few seconds
later, and **confirm** before running it, since it restarts the student's
Fountain.

## 3. The lesson

### 3a. Write the manifest

The student writes one YAML file, `f2-manifest.yaml`, with two documents,
`---` separated. Use these exact names, the lesson page uses them too.

```yaml
apiVersion: fountain.dev/v1
kind: Environment
metadata:
  name: lesson2-env
spec:
  networking_type: unrestricted
---
apiVersion: fountain.dev/v1
kind: Agent
metadata:
  name: lesson2-agent
spec:
  model: anthropic/sonnet
  runtime: claude
  environment: lesson2-env
```

### 3b. Apply it

**confirm**, then

```sh
fountain apply -f f2-manifest.yaml
```

```
env  +  lesson2-env
agent  +  lesson2-agent
```

### 3c. Start the conversation

**confirm**, then

```sh
fountain run lesson2-agent -p 'Write the line  remember me  to a file named note.txt in your home directory, then reply with the contents of that file.'
```

```
▸ conversation d99d8cb5-b178-4dbf-8f02-a9164fc8040e
▸ provision: started
▸ provision: done
▸ turn: started
▸ turn failed
fountain: turn failed
```

Keep the full conversation id from the first line. Every later step
takes it, and the shortened id `fountain conv list` prints will not work.

Say before running it that the last two lines are the model call failing
for want of a key and are expected on a keyless account, exactly as in
lesson 3's contrast. `provision: done` is the line that matters. With a
key set the agent answers `remember me` and the command exits zero.

This run provisions a real sandbox and the account holds at most two at
once. If the run answers `http 429: You have 2 of 2 concurrent sandboxes
in use`, run `fountain conv list`, pick an older conversation, and
terminate it by its full id. A suspended sandbox holds no slot, so a
parked conversation is never the cause.

### 3d. Find the sandbox

Read commands. The CLI first.

```sh
fountain conv show <id>
```

```
conversation d99d8cb5-b178-4dbf-8f02-a9164fc8040e
  status:    idle
  agent:     8cebfeb1-9db2-4b50-a00f-6e4e45d61d0b
  sandbox:   0ffe62fe-9021-404f-b81f-83c5f701e1f4
  sprite:    runner-2ed85f37e61f4a5c91b691dbdab734d6-8430f8fa (ready)
  runtime:   claude
  inserted:  2026-09-06T21:29:32Z
```

`sandbox` is the sandbox's id in Fountain and `sprite` is its name at the
provider. Then the API, which says where it is. This is the page's
command verbatim, with the student's id and the check's `fountain.cli_url`
substituted.

```sh
FOUNTAIN_KEY=$(awk -v p="[${FOUNTAIN_PROFILE:-default}]" '$0==p{f=1;next} /^\[/{f=0} f && $1=="api_key"{gsub(/"/,"",$3); print $3; exit}' ~/.fountain/credentials)
curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" \
  "http://localhost:4000/api/conversations/<id>" \
  | jq '.data | {status, sandbox_id, sandbox: {status: .sandbox.status, provider: .sandbox.provider, path: .sandbox.runner.path}}'
```

```json
{
  "status": "idle",
  "sandbox_id": "0ffe62fe-9021-404f-b81f-83c5f701e1f4",
  "sandbox": {
    "status": "ready",
    "provider": "runner",
    "path": "/sandboxes/runner-2ed85f37e61f4a5c91b691dbdab734d6-8430f8fa"
  }
}
```

(PowerShell reads the credentials file with
`Select-String -Path "$env:USERPROFILE\.fountain\credentials" -Pattern api_key`
and sets `$env:FOUNTAIN_KEY` from the match. The curl call itself is
identical on every OS.)

Write down `sandbox_id` and `path`. 3g compares against both.

### 3e. Look at the disk

A read command. `just runner-sh` runs a shell command inside the runner
container. Use the student's own `path` from 3d.

```sh
just runner-sh ls -la /sandboxes/<sprite name>
```

```
drwx------ 5 runner runner 4096 Sep  6 21:29 .
drwxr-xr-x 3 runner runner 4096 Sep  6 21:29 ..
drwxr-xr-x 6 runner runner 4096 Sep  6 21:29 .claude
-rw------- 1 runner runner  389 Sep  6 21:29 .claude.json
-rw------- 1 runner runner  370 Sep  6 21:29 .env
drwxr-xr-x 3 runner runner 4096 Sep  6 21:29 .local
drwxr-xr-x 4 runner runner 4096 Sep  6 21:29 .npm-global
```

Say what is there. `.claude` holds the session transcript the runtime
resumes from, `.env` holds the conversation's own token back to Fountain,
`.local` holds the runtime binary. This directory is the agent's memory.

If `note.txt` is already in the listing the student has a key and the
agent wrote it in 3c, skip the write. Otherwise **confirm**, then write
it by hand.

```sh
just runner-sh 'echo "remember me" > /sandboxes/<sprite name>/note.txt'
```

### 3f. Wait for the park

Tell the student to do nothing to the conversation for three minutes,
and say why. Fountain checks the idle bound once a minute, so a two
minute bound parks the sandbox two to three minutes after the last turn.
Poll with a read command, no more often than every twenty seconds, until
the `sprite` line reads `(suspended)`.

```sh
fountain conv show <id> | grep sprite
```

```
  sprite:    runner-2ed85f37e61f4a5c91b691dbdab734d6-8430f8fa (suspended)
```

Then the events, a read command.

```sh
curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" \
  "http://localhost:4000/api/conversations/<id>/events" \
  | jq -r '.data[] | select(.kind!="output") | "\(.ts) \(.stage) \(.state) \(.data)"'
```

```
2026-09-06T21:29:33.000000Z provision started {}
2026-09-06T21:29:36.000000Z provision done {}
2026-09-06T21:29:36.000000Z turn started {"mode":"run","turn_id":"a189c94c-a333-4ca2-83fc-a15318955230","turn_number":1}
2026-09-06T21:29:36.000000Z turn failed {"reason":"acp: {:acp_error, :prompt, %{\"code\" => -32000, \"message\" => \"Authentication required\"}}","turn_id":"a189c94c-a333-4ca2-83fc-a15318955230","turn_number":1}
2026-09-06T21:32:33.000000Z sandbox done {"message":"Sandbox suspended after 2 minutes idle. Send another prompt to continue — the agent picks up right where it left off.","reason":"idle","event":"suspended"}
```

Walk the student through the last line. Fountain names the bound that
fired, the action it took, and what the next prompt will do, in copy that
is different on a provider that cannot park. Point out that
`fountain conv list` still says `idle`, since the conversation did not
change, the sandbox under it did. Then the disk again, a read command.

```sh
just runner-sh ls -la /sandboxes/<sprite name>
```

Expect the same listing plus a zero-byte `.fountain-suspended` and the
student's `note.txt`. The marker is the runner's word for parked. The
processes were stopped and the directory was left alone.

### 3g. Wake it

**confirm**, then

```sh
fountain conv prompt <id> -p 'Reply with the contents of note.txt in your home directory.'
```

```
▸ reattach: started
▸ reattach: done
▸ turn: started
▸ turn failed
fountain: turn failed
```

`reattach` where 3c said `provision`. Nothing was built. Run the 3d curl
again and compare. Same `sandbox_id`, same `path`, `sandbox.status` back
to `ready`. Then the disk, a read command.

```sh
just runner-sh cat /sandboxes/<sprite name>/note.txt
```

```
remember me
```

The marker is gone from the listing and the file is not. With a key set
the agent's reply to this prompt is those same two words, read from a
disk it last saw before the park.

### 3h. The ceiling, and the tidy up

Say that the other bound, the lifetime ceiling, is 24 hours on the class
stack, counts whole hours, and measures a continuous run from the last
wake, so it cannot be watched in a lesson. It destroys, and Fountain's
copy for it reads

```
Sandbox reclaimed after reaching the 24 hour maximum lifetime. Send another prompt to continue — the transcript above is kept, but the agent starts a fresh session and will not remember the earlier turns.
```

`fountain conv terminate` is the same destroy by hand. **confirm**, then

```sh
fountain conv terminate <id>
just runner-sh ls -la /sandboxes
```

```
terminated d99d8cb5-b178-4dbf-8f02-a9164fc8040e
total 8
drwxr-xr-x 2 runner runner 4096 Sep  6 21:35 .
drwxr-xr-x 1 root   root   4096 Sep  6 18:52 ..
```

The directory is gone. Show that `fountain conv show <id>` still answers
with every turn, and that the events call now ends in `terminate done`.
The transcript is Fountain's and survives, the disk was the sandbox's and
does not.

If other students' sandboxes share the runner the listing will not be
empty. The student's own directory, by the `sprite` name, is the one that
should be missing.

The Environment and Agent may stay. Nothing later in the course collides
with these names.

## 4. Done when

All three have to be true, checked the way the lesson page states them.

- After the wake in 3g, the 3d curl returns the same `sandbox_id` it
  returned before the park, with `sandbox.status` equal to `ready`. Run
  the curl yourself and compare the two values. Do not accept the CLI's
  `reattach: done` line alone, it does not print the id.
- The 3f events call returned a `sandbox` stage event whose data contains
  `"reason":"idle","event":"suspended"`, and the events after the wake
  show `reattach started` then `reattach done`.
- `note.txt` was still in the sandbox directory after the wake, read
  back in 3g.

If the first fails with a new `sandbox_id`, the wake provisioned a fresh
sandbox, which happens when the runner was offline at the wake or the
directory was gone. Check `runner_online` in the check and the runner's
`/sandboxes` listing. If the park never comes, the stack is running
without the idle bound, back to section 2. If the second shows
`"event":"reclaimed"` instead of `"event":"suspended"`, the provider
cannot park, which is not the runner and means the stack is on a hosted
provider without the suspend capability. Restart from lesson 1
(https://intentius.io/waterpark/courses/fountain/01-four-primitives/) as
the lesson card says.

## 5. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"f2"` to its `completed` array, keeping everything already in
it. Do not rewrite the array from scratch, a student who did lesson 1
should still see `"f1"` in there afterwards. Create the array only if
the file somehow lacks one. Leave every other field untouched.

```json
{"...": "...", "completed": ["start", "f1", "f2"]}
```

## 6. Hand off

Say the next step is Fountain lesson 3, The egress allowlist
(https://intentius.io/waterpark/courses/fountain/03-egress-allowlist/),
which also needs no inference key and shows what Fountain does with a
containment claim the runner cannot keep.
