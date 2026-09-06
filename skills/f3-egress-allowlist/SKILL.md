---
name: waterpark-f3-egress-allowlist
description: Walk a student through Fountain lesson 3, The egress allowlist. Use when they want lesson 3, or when they ask why a limited-networking environment will not provision. Declares a default-deny Environment, watches Fountain refuse to provision it on a self-hosted runner, reads the stage events that name the missing capability and the provider, and contrasts with an unrestricted environment that starts. Needs no inference key.
---

# water park, Fountain lesson 3, The egress allowlist

You are walking a student through Fountain lesson 3, The egress allowlist
(https://intentius.io/waterpark/courses/fountain/03-egress-allowlist/). The
outcome is a default-deny environment that applies cleanly, a run that
refuses to provision, and a stage event in which the platform names the
capability it wanted and the backend that could not supply it. About 15
minutes.

Confirm with the student before applying either manifest and before
starting either conversation. Those steps are marked **confirm**. Every
read command, listing environments, agents or conversations, showing one,
fetching a conversation's events, runs freely with no confirmation.

Nothing in this lesson calls a model, so nothing in it spends money.

## 1. Say what this is

In two or three sentences say this is lesson 3 of the Fountain course.
`networking_type: limited` with `networking_config.allowed_hosts` is a
default-deny egress allowlist and an empty list denies everything. The
policy is enforced by the sandbox backend, not by Fountain, and the
class stack's backend is the self-hosted runner, which has no egress
policy at all (Fountain ADR 0022). So the lesson is about what Fountain
does with a claim it cannot keep. Link the lesson page above.

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
The runner has to be up because a refusal to provision is only
interesting once there is a backend to refuse on. If `runner_online` is
false, say `just runner` starts it and wait.

Do **not** require `inference_set`, and do not send the student back to
Start here step 7 if it is false. Both halves of this lesson finish
before a model is called. The locked environment fails at provisioning,
and the unrestricted contrast only needs the sandbox to start. This is
the one lesson in the course a student can complete with no key set, and
it is worth telling them so. Never ask the student for an inference key
and never go looking for one.

Note the check's `fountain.cli_url`. Every command below that names a
URL uses it, substitute the real value the check reported.

## 3. The lesson

### 3a. Write the locked manifest

The student writes one YAML file, `f3-manifest.yaml`, with two documents,
`---` separated. Use these exact names, the lesson page uses them too.

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

Point out what the fields buy. `networking_type` takes `unrestricted` or
`limited`. Under `limited`, `networking_config.allowed_hosts` is the
whole of what the sandbox may reach, so an empty list is a sandbox with
no network. The Agent names a `model` as `provider/alias` and a
`runtime`, and references the Environment by name. The runtime accepts
the aliases `sonnet`, `opus` and `haiku` and refuses fully qualified
ids. Nothing here will actually reach the model, but the fields still
have to be valid for the Agent to apply.

### 3b. Apply it

**confirm**, then

```sh
fountain apply -f f3-manifest.yaml
```

This creates two objects on the student's real Fountain account. Expect
`+` on each line.

```
env  +  lesson3-locked
agent  +  lesson3-locked-agent
```

### 3c. Read the policy back

A read command, no confirmation needed.

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

Say what just happened, because it is easy to miss. The policy applied
exactly as written and nothing warned about anything. Whether the
backend can enforce it is not an apply-time question.

### 3d. Run it and get refused

**confirm**, then

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

The CLI exits non-zero. Keep the full conversation id from the first
line, 3e needs it and the shortened id `fountain conv list` prints will
not work. This is the expected result on the class stack, so say so
before running it, otherwise a failure looks like the student's mistake.
The agent never ran because the sandbox never existed.

`fountain conv list` is a read command and shows the conversation with
status `failed`. The failure is recorded, not discarded.

### 3e. Read the events, the payoff

A read command. This is the page's command verbatim. Substitute the
student's own full conversation id from 3d, and the check's
`fountain.cli_url` for the host if the stack is not on port 4000.

```sh
FOUNTAIN_KEY=$(awk -v p="[${FOUNTAIN_PROFILE:-default}]" '$0==p{f=1;next} /^\[/{f=0} f && $1=="api_key"{gsub(/"/,"",$3); print $3; exit}' ~/.fountain/credentials)
curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" \
  "http://localhost:4000/api/conversations/<id>/events" \
  | jq -r '.data[] | "\(.stage) \(.state) \(.data)"'
```

```
provision started {}
network failed {"reason":"backend_lacks_network_policy","type":"limited","provider":"runner"}
provision failed {"reason":"{:network_policy, :unsupported_by_backend}"}
```

(PowerShell reads the same file with
`Select-String -Path "$env:USERPROFILE\.fountain\credentials" -Pattern api_key`
and sets `$env:FOUNTAIN_KEY` from the match. The curl call itself is
identical on every OS.)

Walk the student through the middle line. Fountain names the capability
it wanted, a network policy, the networking type the environment asked
for, `limited`, and the backend that could not supply it, `runner`. The
later `provision` event carries the same fact as the internal reason
`{:network_policy, :unsupported_by_backend}`. This is the lesson. A
refusal that names the missing capability and the provider is something
you can act on. A silent downgrade to unrestricted would not be.

### 3f. Show it is the capability, not the list

**confirm** for the apply and the run. Change `allowed_hosts` in
`f3-manifest.yaml` from `[]` to one real host, then re-apply and run
again.

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

Expect `~` on both apply lines and a refusal identical to 3d, down to
the exit code. Keep this short. The point is one sentence. A named host does not
help, because there is nothing on this backend that could hold the name.

### 3g. The contrast

**confirm** for the apply and the run. The student writes `f3-open.yaml`.

This run provisions a real sandbox and the account holds at most two of
those at once. Lesson 1 leaves its conversation alive, so a student who
came straight from it has one slot gone already. If the run answers with
`http 429: You have 2 of 2 concurrent sandboxes in use`, run
`fountain conv list`, pick an older conversation, and terminate it by its
full id the way 3h does. The two refused runs above hold no slot, their
sandboxes never started.

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

`provision: done` on the same runner, with the same agent shape. One
field changed and the sandbox starts. The contrast is complete by line
three and the rest is the model call.

Say this before running it, because the last two lines look like another
refusal and are not. On a keyless account the turn cannot reach a model,
so it fails and the command exits non-zero, exactly as 3d and 3f did, but
one stage later. The CLI prints only `turn failed`. The reason lives in
the events, so run the 3e curl against this conversation and read the
`turn failed` line, which carries
`"message" => "Authentication required"`. That is a missing key and has
nothing to do with networking. With a key set the turn answers instead
and the command exits zero.

### 3h. Tidy up

**confirm**, then terminate the conversation 3g left running, so it
stops holding one of the account's two sandbox slots.

```sh
fountain conv terminate <id>
```

Use the full conversation id from the first line of the 3g output.
`fountain conv list` shortens the id column to eight characters, and
`terminate` refuses that shortened form. The error it gives back,
`http 400: detail: Bad Request`, does not say the id was the wrong shape.

If the student wants the objects gone too, `fountain env list --json`
and `fountain agent list --json` give the ids and
`DELETE /api/agents/<id>` then `DELETE /api/environments/<id>` with the
same Bearer key remove them. Delete the agents first. Leaving them is
fine, nothing later in the course collides with these names.

## 4. Done when

Both of these have to be true, checked the way the lesson page states
them.

- The locked run from 3d exited non-zero, and the events call in 3e
  returned a `network` stage event whose data is
  `{"reason":"backend_lacks_network_policy","type":"limited","provider":"runner"}`.
  Run the 3e curl yourself and read the middle line. Do not accept the
  stream output alone as proof, the stream says `network: failed`
  without naming the provider.
- The unrestricted run from 3g streamed `provision: started` then
  `provision: done`.

If the first fails and the events show something other than
`backend_lacks_network_policy`, the stack is probably on a hosted
provider rather than the runner, in which case the sandbox may well have
started and the lesson's refusal will not appear. Check the check's
`fountain.cli_url` stack and `SANDBOX_PROVIDER` in `compose/.env`. If the
second fails, the runner is likely offline, restart from lesson 1
(https://intentius.io/waterpark/courses/fountain/01-four-primitives/) as
the lesson card says.

## 5. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"f3"` to its `completed` array, keeping everything already in
it. Do not rewrite the array from scratch, a student who did lesson 1
should still see `"f1"` in there afterwards. Create the array only if
the file somehow lacks one. Leave every other field untouched.

```json
{"...": "...", "completed": ["start", "f1", "f3"]}
```

## 6. Hand off

Say the next step is Fountain lesson 4, Credentials and vaults
(https://intentius.io/waterpark/courses/fountain/04-credentials-and-vaults/),
which covers the two places secrets live and which one wins when both set
the same key. Tell the student plainly that lesson 4 is not written yet,
so the link is a placeholder for now.
