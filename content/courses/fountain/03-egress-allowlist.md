---
title: "The egress allowlist"
id: "F3"
lesson: 3
weight: 3
summary: "Limited networking denies all egress except the listed hosts."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/f3-egress-allowlist"
# card. empty renders as TODO
goal: "Declare an Environment whose egress is default-deny, point an Agent at it, and watch Fountain refuse to provision the sandbox because the class stack's backend cannot enforce the policy. Then read the stage events until the platform tells you, in its own words, which capability is missing and which provider is missing it, and run the same agent against an unrestricted environment to see the sandbox start."
done_when: >-
  `fountain run lesson3-locked-agent` exits non-zero, and a GET to that
  conversation's `/api/conversations/<id>/events` with your Bearer key
  returns a `network` stage event whose data reads
  `{"reason":"backend_lacks_network_policy","type":"limited","provider":"runner"}`,
  while the same prompt against the `unrestricted` environment streams
  `provision: started` then `provision: done`.
restart_from: "lesson 1"
properties: ["VI"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "15 min"
  needs: ["the Start-here stack running (`just up`, `just register`, `just runner`) with a runner online", "no inference key, this lesson never calls a model"]
  solo: true
  live: true
---

## Context

- `networking_type: limited` with `networking_config.allowed_hosts` is a default-deny egress allowlist. An empty list denies everything.
- The allowlist is enforced by the sandbox backend, not by Fountain. Sprites, E2B and Daytona advertise the capability. The self-hosted runner does not (ADR 0022, decision 29).
- So Fountain will not start a `limited` sandbox on a runner. It fails provisioning and names the missing capability and the provider in the conversation's stage events.
- The class stack's provider is the runner, which makes this lesson a refusal rather than a packet capture. Lesson 10 covers what else a runner gives up.

## Do

Every step here runs before a model is ever called, so none of it needs an inference key. Two objects, one refusal, one contrast.

1. Write the manifest below to a file named `f3-manifest.yaml`. It is two documents in one file. The Environment declares limited networking with an empty allowlist, which denies every host. The Agent points at it by name.

   ```yaml
   apiVersion: fountain.dev/v1
   kind: Environment
   metadata:
     name: lesson3-locked
   spec:
     networking_type: limited
     networking_config:
       allowed_hosts: []
   ---
   apiVersion: fountain.dev/v1
   kind: Agent
   metadata:
     name: lesson3-locked-agent
   spec:
     model: anthropic/sonnet
     runtime: claude
     environment: lesson3-locked
   ```

2. Apply it with `fountain apply -f f3-manifest.yaml`. Both objects are created.

   ```
   env  +  lesson3-locked
   agent  +  lesson3-locked-agent
   ```

3. Read the policy back, so you know Fountain stored what you wrote and not some coerced version of it.

   ```sh
   fountain env list --json | jq '.[] | select(.name=="lesson3-locked") | {networking_type, networking_config}'
   ```

   ```json
   {
     "networking_type": "limited",
     "networking_config": {
       "allowed_hosts": []
     }
   }
   ```

   The policy applies cleanly. Nothing has warned you yet.

4. Start a conversation with the agent. Note the conversation id on the first line, you need it in step 6.

   ```sh
   fountain run lesson3-locked-agent -p 'Fetch https://example.com and tell me the HTTP status.'
   ```

   ```
   ▸ conversation cd5a7080-400d-4778-80bb-91e1b206a6c0
   ▸ provision: started
   ▸ network: failed
   ▸ provisioning failed — the sandbox never started
   fountain: provisioning failed — the sandbox never started
   ```

   The CLI exits non-zero. The agent never ran, because the sandbox never existed.

5. Confirm the conversation kept the failure rather than vanishing. `fountain conv list` shows it with status `failed`, which is a record you can go back to. Earlier lessons leave their conversations in this list too, so look for the one whose id starts with the id from step 4.

   ```
   status  id        agent_id  runtime  started
   ------  --------  --------  -------  --------------------
   failed  cd5a7080  b23e9d79  claude   2026-09-06T19:03:33Z
   ```

   The id column is shortened to eight characters for the table. Commands that take a conversation id want the full one from step 4.

6. Ask the platform why. The stage events carry the reason, and this is the payoff of the lesson. Substitute your own conversation id from step 4, and the check's `fountain.cli_url` for the host if your stack is not on port 4000.

   ```sh
   FOUNTAIN_KEY=$(awk -v p="[${FOUNTAIN_PROFILE:-default}]" '$0==p{f=1;next} /^\[/{f=0} f && $1=="api_key"{gsub(/"/,"",$3); print $3; exit}' ~/.fountain/credentials)
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" \
     "http://localhost:4000/api/conversations/cd5a7080-400d-4778-80bb-91e1b206a6c0/events" \
     | jq -r '.data[] | "\(.stage) \(.state) \(.data)"'
   ```

   ```
   provision started {}
   network failed {"reason":"backend_lacks_network_policy","type":"limited","provider":"runner"}
   provision failed {"reason":"{:network_policy, :unsupported_by_backend}"}
   ```

   Read the middle line again. Fountain names the capability it wanted, `network policy`, the networking type you asked for, `limited`, and the backend that could not supply it, `runner`. That is a refusal with an address on it, not a generic error.

7. Prove it is the capability and not your list. Change `allowed_hosts` in `f3-manifest.yaml` from `[]` to one real host, re-apply, and run again.

   ```yaml
   spec:
     networking_type: limited
     networking_config:
       allowed_hosts:
         - api.github.com
   ```

   ```sh
   fountain apply -f f3-manifest.yaml
   fountain run lesson3-locked-agent -p 'Fetch https://api.github.com and tell me the HTTP status.'
   ```

   The refusal is identical, down to the exit code. A named host does not help, because there is nothing on this backend that could hold the name.

8. Now the contrast. Write `f3-open.yaml` with an unrestricted Environment and its own Agent, apply it, and run the same prompt. This one provisions a real sandbox, and an account may hold only two of those at once. If an earlier lesson left a conversation alive you will get this instead of a run.

   ```
   fountain: http 429: You have 2 of 2 concurrent sandboxes in use. Terminate a conversation before starting another.
   ```

   Clear a slot with `fountain conv terminate` and the full id of an older conversation, then come back. The two refused runs above hold no slot, because their sandboxes never started.

   ```yaml
   apiVersion: fountain.dev/v1
   kind: Environment
   metadata:
     name: lesson3-open
   spec:
     networking_type: unrestricted
   ---
   apiVersion: fountain.dev/v1
   kind: Agent
   metadata:
     name: lesson3-open-agent
   spec:
     model: anthropic/sonnet
     runtime: claude
     environment: lesson3-open
   ```

   ```sh
   fountain apply -f f3-open.yaml
   fountain run lesson3-open-agent -p 'Fetch https://example.com and tell me the HTTP status.'
   ```

   ```
   ▸ conversation ece7e0df-f062-489f-8f4a-73776e2a20dc
   ▸ provision: started
   ▸ provision: done
   ▸ turn: started
   ▸ turn failed
   fountain: turn failed
   ```

   `provision: done` on the same runner, with the same agent shape. The only field that changed is the networking type, and the sandbox starts. That is the whole contrast, and it is already complete by line three.

   The last two lines are the model call, not the sandbox. With no inference key set the turn cannot reach a model, so it fails and the command exits non-zero the way steps 4 and 7 did. The difference is where. Fetch this conversation's events the same way you did in step 6 and the `turn failed` line carries `"message" => "Authentication required"` as its reason, which is a missing key and nothing to do with networking. With a key set the turn answers instead and the command exits zero.

9. Terminate the conversation the contrast left running, so it stops holding a sandbox slot. Use the full conversation id from the first line of the step 8 output, not the eight-character id the table in step 5 prints, which `terminate` rejects with `http 400: detail: Bad Request`.

   ```sh
   fountain conv terminate ece7e0df-f062-489f-8f4a-73776e2a20dc
   ```

## Self-paced

This is the only lesson in the course you can finish with no inference key at all. The refusal in step 4 and the successful provisioning in step 8 both happen before the model is called, so an account with no key set reaches every line of output above. Floci plays no part.

The class stack's sandbox provider is the self-hosted runner, so what you get here is the declaration and the refusal, not enforced egress. Sprites, E2B and Daytona advertise the network policy capability, which is what `provider: runner` in that event reason is telling you about your own stack. If you have an account with one of them, `SANDBOX_PROVIDER` and its token in `compose/.env` followed by `docker compose up -d` will get you the enforcement and turn step 4 into a sandbox that starts and cannot reach `example.com`. That is optional and it is never a prerequisite. The course already asks you for one inference key and that is the ceiling.

## Live

Fifteen minutes. The room watches an empty allowlist apply without complaint, then watches the run refuse three lines later, then watches the events endpoint name `backend_lacks_network_policy` and `provider: runner`. Put the unrestricted contrast last so the refusal is what people are still holding when the events land.

Say this out loud when the refusal appears. The lock is real and this backend cannot hold it, so the platform refuses instead of pretending. A runtime that quietly ran your default-deny environment wide open would be worse than one that will not run it at all, because you would go on believing the claim.

## Further reading

- Fountain `docs/primitives.md`, networking
- [Threat model](../../docs/threat-model.md), boundary 5
- Decision 29
- [Lesson 10, the self-hosted runner](10-self-hosted-runner.md), for everything else a runner trades away
