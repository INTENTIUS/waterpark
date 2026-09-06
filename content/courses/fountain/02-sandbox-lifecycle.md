---
title: "The sandbox lifecycle"
id: "F2"
lesson: 2
weight: 2
summary: "A conversation is a sandbox with a disk."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/f2-sandbox-lifecycle"
# card. empty renders as TODO
goal: "Start one conversation and find its sandbox as a directory on the class stack's runner. Put a file in it, wait for Fountain to park the sandbox after two idle minutes, then wake it with a second prompt and find the same sandbox, the same directory and your file. Terminate it at the end and watch the directory go, which is what the lifetime ceiling does on its own."
done_when: >-
  After the wake, a GET to `/api/conversations/<id>` with your Bearer key
  reports the same `sandbox_id` it reported before the suspend with
  `sandbox.status` back to `ready`, the conversation's `/events` carry a
  `sandbox` stage event whose data reads `"reason":"idle","event":"suspended"`
  followed by `reattach started` and `reattach done`, and `note.txt` is
  still in the sandbox directory on the runner.
restart_from: "lesson 1"
properties: ["VII"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "15 min"
  needs: ["the Start-here stack running (`just up`, `just register`, `just runner`) with a runner online", "no inference key, every check in this lesson is a field on the API or a file on disk"]
  solo: true
  live: true
---

## Context

- A conversation runs in a sandbox with its own disk. On the class stack's runner the sandbox is a directory under `/sandboxes` in the runner container, and the agent's `HOME` points at it.
- Fountain keeps two bounds on a sandbox (ADR 0017). Past the idle bound the sandbox is suspended, its processes stop and its disk stays. Past the lifetime ceiling it is destroyed and the disk goes with it. The conversation stays `idle` and resumable through both, and the transcript survives both.
- Fountain's own defaults are 60 minutes idle and 24 hours of lifetime. The class stack sets the idle bound to 2 minutes, `SANDBOX_IDLE_TIMEOUT_MINUTES` in `compose/docker-compose.yml`, so the park fits in one sitting. Fountain checks the bound once a minute.
- A suspended sandbox holds no concurrency slot. Waking one runs the quota gate again, so a parked conversation is never the reason for a `429`.

## Do

Nothing in this lesson needs a model reply. The sandbox provisions, parks and wakes on either side of the model call, and every check is a field on the API or a file on the runner. With an inference key set the turns answer as well and the agent does the writing and the reading itself. Without one they fail at the model, exactly as lesson 3's contrast did, the commands that run a turn exit non-zero, and you do the writing by hand. `bash skills/start/check.sh doctor` keeps flagging the missing key, and for this lesson that line can be ignored.

1. Confirm your stack carries the bound.

   ```sh
   docker compose -f compose/docker-compose.yml --env-file compose/.env exec fountain env | grep SANDBOX_
   ```

   ```
   SANDBOX_MAX_LIFETIME_HOURS=24
   SANDBOX_IDLE_TIMEOUT_MINUTES=2
   SANDBOX_RUNNERS_ENABLED=true
   SANDBOX_PROVIDER=runner
   ```

   If the two bounds are missing, your stack was started before they were added to the compose file. `just up` recreates Fountain with them, and the runner reconnects on its own a few seconds later.

2. Write the manifest below to a file named `f2-manifest.yaml`. An unrestricted Environment and an Agent on it, nothing else.

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

   ```sh
   fountain apply -f f2-manifest.yaml
   ```

   ```
   env  +  lesson2-env
   agent  +  lesson2-agent
   ```

3. Start a conversation. Note the conversation id on the first line, every later step takes it.

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

   The last two lines are the model call failing for want of a key, and the sandbox is up regardless. `provision: done` is the line that matters here. With a key set the agent answers `remember me` instead and the command exits zero.

4. Find the sandbox. The CLI shows it on two lines.

   ```sh
   fountain conv show d99d8cb5-b178-4dbf-8f02-a9164fc8040e
   ```

   ```
   conversation d99d8cb5-b178-4dbf-8f02-a9164fc8040e
     status:    idle
     agent:     8cebfeb1-9db2-4b50-a00f-6e4e45d61d0b
     sandbox:   0ffe62fe-9021-404f-b81f-83c5f701e1f4
     sprite:    runner-2ed85f37e61f4a5c91b691dbdab734d6-8430f8fa (ready)
     runtime:   claude
     inserted:  2026-09-06T21:29:32Z

   turns (1):
     #1 failed exit=  Write the line  remember me  to a file named note.txt in your home directory, th…
   ```

   `sandbox` is the sandbox's id in Fountain and `sprite` is its name at the provider, a word kept from Fountain's first backend. The `turns` block lists every prompt so far, and `exit=` stays blank on a turn that failed before the runtime reported a code. The API says where the sandbox is. Substitute your own host if your stack is not on port 4000, the Start-here check prints it as `fountain.cli_url` when you run `bash skills/start/check.sh`.

   ```sh
   FOUNTAIN_KEY=$(awk -v p="[${FOUNTAIN_PROFILE:-default}]" '$0==p{f=1;next} /^\[/{f=0} f && $1=="api_key"{gsub(/"/,"",$3); print $3; exit}' ~/.fountain/credentials)
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" \
     "http://localhost:4000/api/conversations/d99d8cb5-b178-4dbf-8f02-a9164fc8040e" \
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

   `path` is a directory in the runner container. Keep this output, you compare `sandbox_id` against it after the wake. The directory listings below drop the `total` line `ls` prints first.

5. Look at the disk. `just runner-sh` runs a shell command inside the runner container. Use your own path from step 4.

   ```sh
   just runner-sh ls -la /sandboxes/runner-2ed85f37e61f4a5c91b691dbdab734d6-8430f8fa
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

   The runtime already left its state here. `.claude` holds the session transcript the runtime resumes from, `.env` holds the conversation's own token back to Fountain, and `.local` holds the runtime binary. This directory is the agent's memory, and it is what the rest of the lesson watches. Put a file in it.

   ```sh
   just runner-sh 'echo "remember me" > /sandboxes/runner-2ed85f37e61f4a5c91b691dbdab734d6-8430f8fa/note.txt'
   ```

   With a key set the agent wrote `note.txt` itself in step 3, so list first and skip the write if the file is there.

6. Wait. Do nothing to the conversation for three minutes. Fountain checks the idle bound once a minute, so a two-minute bound parks the sandbox two to three minutes after the last turn. Poll the `sprite` line every twenty seconds or so until it reads `(suspended)`.

   ```sh
   fountain conv show d99d8cb5-b178-4dbf-8f02-a9164fc8040e | grep sprite
   ```

   ```
     sprite:    runner-2ed85f37e61f4a5c91b691dbdab734d6-8430f8fa (suspended)
   ```

   Then ask the platform what it did. The events endpoint carries the park as a `sandbox` stage event, and the message in it is Fountain's own copy for this bound on this provider.

   ```sh
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" \
     "http://localhost:4000/api/conversations/d99d8cb5-b178-4dbf-8f02-a9164fc8040e/events" \
     | jq -r '.data[] | select(.kind!="output") | "\(.ts) \(.stage) \(.state) \(.data)"'
   ```

   ```
   2026-09-06T21:29:33.000000Z provision started {}
   2026-09-06T21:29:36.000000Z provision done {}
   2026-09-06T21:29:36.000000Z turn started {"mode":"run","turn_id":"a189c94c-a333-4ca2-83fc-a15318955230","turn_number":1}
   2026-09-06T21:29:36.000000Z turn failed {"reason":"acp: {:acp_error, :prompt, %{\"code\" => -32000, \"message\" => \"Authentication required\"}}","turn_id":"a189c94c-a333-4ca2-83fc-a15318955230","turn_number":1}
   2026-09-06T21:32:33.000000Z sandbox done {"message":"Sandbox suspended after 2 minutes idle. Send another prompt to continue — the agent picks up right where it left off.","reason":"idle","event":"suspended"}
   ```

   Read the last line. The stage is `sandbox`, the state is `done`, and what happened is in the data. Fountain names the bound that fired, the action it took, and what the next prompt will do. It would say something else on a provider that cannot park. `fountain conv list` still shows the conversation as `idle`, because the conversation did not change, the sandbox under it did. Now the disk.

   ```sh
   just runner-sh ls -la /sandboxes/runner-2ed85f37e61f4a5c91b691dbdab734d6-8430f8fa
   ```

   ```
   drwx------ 5 runner runner 4096 Sep  6 21:32 .
   drwxr-xr-x 3 runner runner 4096 Sep  6 21:29 ..
   drwxr-xr-x 6 runner runner 4096 Sep  6 21:29 .claude
   -rw------- 1 runner runner  389 Sep  6 21:29 .claude.json
   -rw------- 1 runner runner  370 Sep  6 21:29 .env
   -rw------- 1 runner runner    0 Sep  6 21:32 .fountain-suspended
   drwxr-xr-x 3 runner runner 4096 Sep  6 21:29 .local
   drwxr-xr-x 4 runner runner 4096 Sep  6 21:29 .npm-global
   -rw-r--r-- 1 runner runner   12 Sep  6 21:33 note.txt
   ```

   `.fountain-suspended` is the runner's word for parked. The sandbox's processes were stopped and the directory was left alone, with your file in it.

7. Wake it. A follow-up prompt is the only thing that wakes a parked sandbox.

   ```sh
   fountain conv prompt d99d8cb5-b178-4dbf-8f02-a9164fc8040e -p 'Reply with the contents of note.txt in your home directory.'
   ```

   ```
   ▸ reattach: started
   ▸ reattach: done
   ▸ turn: started
   ▸ turn failed
   fountain: turn failed
   ```

   `reattach`, where step 3 said `provision`. Nothing was built. In the events the `reattach done` line carries `"outcome":"no_running_turn"`, which says no turn was in flight when the sandbox parked and is the normal case. Run the step 4 query again and compare.

   ```sh
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" \
     "http://localhost:4000/api/conversations/d99d8cb5-b178-4dbf-8f02-a9164fc8040e" \
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

   Same `sandbox_id`, same path, status back to `ready`. On the disk the marker is gone and the file is not.

   ```sh
   just runner-sh cat /sandboxes/runner-2ed85f37e61f4a5c91b691dbdab734d6-8430f8fa/note.txt
   ```

   ```
   remember me
   ```

   With a key set, the agent's reply to this prompt is the same two words, read from a disk it last saw before the park. That is the whole claim, and you have now checked it without the model's help.

8. The other bound. The lifetime ceiling is 24 hours on the class stack, it counts whole hours, and it measures a continuous run from the last wake, so a parked week does not count against it. You cannot watch it in a lesson. What it does is destroy, and Fountain's copy for that says so.

   ```
   Sandbox reclaimed after reaching the 24 hour maximum lifetime. Send another prompt to continue — the transcript above is kept, but the agent starts a fresh session and will not remember the earlier turns.
   ```

   `fountain conv terminate` is the same destroy, by hand. Run it and look at the disk.

   ```sh
   fountain conv terminate d99d8cb5-b178-4dbf-8f02-a9164fc8040e
   just runner-sh ls -la /sandboxes
   ```

   ```
   terminated d99d8cb5-b178-4dbf-8f02-a9164fc8040e
   drwxr-xr-x 2 runner runner 4096 Sep  6 21:35 .
   drwxr-xr-x 1 root   root   4096 Sep  6 18:52 ..
   ```

   The directory is gone. `fountain conv show` still answers with every turn, and the events endpoint still carries the whole stage log ending in `terminate done`. The transcript is Fountain's, the disk was the sandbox's, and only one of them survives a destroy.

## Self-paced

Every check above happens outside the model, so an account with no inference key reaches every line of output. With a key set, step 3 has the agent write the file and step 7 has it read the file back after the wake, which is the resumed runtime session doing what the event message promised. Floci plays no part.

The class stack's provider is the self-hosted runner, which is what makes the disk a directory you can list. On Sprites the sandbox scales itself to zero when idle and Fountain's suspend is a no-op, so the same `suspended` status and the same event appear with no directory to look at. On a provider that cannot park at all, the idle bound destroys instead, and the event message says so in the words shown in step 8.

## Live

Fifteen minutes, and the wait is the awkward part. Start the conversation before saying anything else, then do the reading in steps 4 and 5 while it idles. Have the events endpoint on screen when the `sandbox` event lands, then wake it and show the same `sandbox_id` on the next line.

Say this when the marker file appears. The disk is the agent's memory, and Fountain parks it instead of deleting it. When it does delete, it tells you in the transcript, in the same place, that the agent will not remember. A runtime that dropped the disk and said nothing would leave you trusting an agent that had forgotten.

## Further reading

- Fountain ADR 0017, suspend idle sandboxes instead of destroying them
- Fountain `docs/integrations/runners.md`, how the contract maps
- Fountain `docs/primitives.md`
- [Lesson 10, the self-hosted runner](10-self-hosted-runner.md), for what else lives on that disk
