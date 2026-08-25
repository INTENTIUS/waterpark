---
name: waterpark-f1-four-primitives
description: Walk a student through Fountain lesson 1, Four primitives. Use when they finished Start here and want lesson 1. Writes a three-document manifest (Environment, Agent, Vault), applies it, starts a conversation, and checks idempotence.
---

# water park, Fountain lesson 1: Four primitives

You are walking a student through Fountain lesson 1, Four primitives
(https://intentius.io/waterpark/courses/fountain/01-four-primitives/). The
outcome is one manifest applied, a conversation that replied, and a look at
why secret values never come back over the API. About 20 minutes.

Confirm with the student before applying the manifest and before starting
the conversation. Those two steps are marked **confirm**. Every read
command, listing environments, agents, vaults or conversations, showing
one, streaming one, runs freely with no confirmation. The student's
inference key is never asked for and never shown. It was set in Start
here step 7 and this lesson only spends against it.

## 1. Say what this is

In two or three sentences say this is lesson 1 of the Fountain course, and
that Fountain is built from four objects: Environment, Vault, Agent,
Conversation. This lesson has the student create one of each of the first
three, apply them together, and watch the fourth run. Link the lesson
page above.

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
true, and `inference_set` true, before doing anything else. This lesson
ends with a conversation that must actually reply, and a reply needs the
inference key.

If `inference_set` is false, stop here. Say Start here step 7 sets the
key (browser onboarding or the one curl the student runs themselves) and
send them back to it. Do not attempt the rest of this lesson without it.

Note the check's `fountain.cli_url`. Every command below that names a URL
uses it, substitute the real value the check reported.

## 3. The lesson

### 3a. Write the manifest

The student writes one YAML file with three documents, `---` separated,
`apiVersion: fountain.dev/v1` on each. Offer this as a starting point and
let them rename things.

```yaml
apiVersion: fountain.dev/v1
kind: Environment
metadata:
  name: lesson1-env
spec:
  networking_type: unrestricted
  env_vars:
    STAGE: dev
  secrets:
    DEMO_API_KEY: sk-demo-12345
---
apiVersion: fountain.dev/v1
kind: Agent
metadata:
  name: lesson1-agent
spec:
  model: anthropic/claude-sonnet-4-6
  runtime: claude
  environment: lesson1-env
---
apiVersion: fountain.dev/v1
kind: Vault
metadata:
  name: lesson1-vault
spec:
  secrets:
    DEMO_API_KEY: sk-vault-override-67890
```

Point out what each field is buying. `env_vars` on the Environment is
plain, the API returns it as written. `secrets` is a map of key to value. The list form some upstream docs show applies silently with zero secrets, so use the map. `secrets` is encrypted per tenant
and write-only, once stored the API never returns the value again, only
the key and a timestamp. The Vault carries its own `secrets` and, on a
key collision with the Environment's, the vault's value wins when
Fountain builds the conversation's env vars. The Agent names a `model` as
`provider/model-id`, a `runtime` (`claude` here, matching the provider),
and references the Environment by name.

Save it as `f1-manifest.yaml` in the checkout, or wherever the student
prefers, the path below just has to match.

### 3b. Apply it

**confirm**, then

```sh
fountain apply -f f1-manifest.yaml
```

This creates the three objects on the student's real Fountain account.
Say that out loud before running it, it is the first step in this lesson
that writes anything. Expect one line per resource, `+` for created. The
same `fountain apply -f` command reconciles by name, so running it again
later updates instead of duplicating, that comes back in 3e.

### 3c. Read it back, keys never values

Read commands run freely, no confirmation needed.

```sh
fountain env list        # copy the environment id
fountain env show <id>
```

The output carries `env_vars` with `STAGE` printed plainly, and a
`secrets` list with `DEMO_API_KEY`'s key, id and timestamps, no `value`
field at all. That is the same shape `GET /api/environments/:id` (for
`env_vars`) and `GET /api/environments/:id/secrets` (for the keys) return
over the API, `fountain env show` just calls both and merges them. To see
it directly,

```sh
FOUNTAIN_KEY=$(awk -F'"' '/api_key/{print $2; exit}' ~/.fountain/credentials)
curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" "$CLI_URL/api/environments/<id>/secrets" | jq .
```

(PowerShell reads the same file with
`Select-String -Path "$env:USERPROFILE\.fountain\credentials" -Pattern api_key`
and sets `$env:FOUNTAIN_KEY` from the match. The curl call itself is
identical on every OS.) Substitute the check's `fountain.cli_url` for
`$CLI_URL`. Either way the point is the same: a secret value goes in once
and is never readable again, from the CLI, the API, or the UI's
environment page.

### 3d. Start a conversation

**confirm**, then

```sh
fountain run lesson1-agent -p "Say hello and tell me what STAGE is set to."
```

Say before running it that this spends the student's own inference
credits, on the key they set in Start here, and provisions a real sandbox
for the agent to run in. `fountain run` creates the conversation and
streams it until the turn finishes, so the reply shows up in the same
terminal. `fountain conv list` and `fountain conv show <id>` are read
commands and need no confirmation if the student wants to look at it
again afterward.

### 3e. Re-apply, see idempotence

Read the manifest once more, then apply it again the same way as 3b
(**confirm** again, it is the same writing step). This time expect `~`
instead of `+` on each line, updated, not a second Environment or a
second Agent. Same name, same object, reconciled in place. That is what
"apply" buys over "create": running it twice is safe.

## 4. Done when

Both of these have to be true.

- The conversation from 3d actually replied. Ask the student what it
  said, do not assume from the stream output alone, they should be able
  to tell you the agent's answer named the stage, dev.
- The environment's secrets read back as keys only, never a value. Verify
  this yourself by running `fountain env show <id>` (or the curl in
  3c) again and checking the `secrets` entries have no `value` field.

If either is false, say which, and point back at 3c (for the secrets
check) or 3d (for the conversation) as the restart point.

## 5. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"f1"` to its `completed` array (creating the array if the file
somehow lacks one). Leave every other field in the file untouched.

```json
{"...": "...", "completed": ["start", "f1"]}
```

## 6. Hand off

Say the next step is Fountain lesson 2, the sandbox lifecycle
(https://intentius.io/waterpark/courses/fountain/02-sandbox-lifecycle/),
which picks up the conversation this lesson just started and follows it
through suspend, wake and the max-lifetime ceiling.
