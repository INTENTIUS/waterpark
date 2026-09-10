---
name: waterpark-f4-credentials-and-vaults
description: Walk a student through Fountain lesson 4, Credentials and vaults. Use when they want lesson 4, or when they ask which of an environment's secret and a vault's secret a sandbox gets, or where a credential lives on the class stack. Declares one Environment and two Vaults overriding the same key, two Agents allowed one vault each, reads the merged secret off the runner's disk, gets a disallowed vault refused with a 422, hears the agent decline to print the value, and empties an allowlist to see a new conversation fall back while the running one keeps its value. Makes four model turns.
---

# water park, Fountain lesson 4, Credentials and vaults

You are walking a student through Fountain lesson 4, Credentials and vaults
(https://intentius.io/waterpark/courses/fountain/04-credentials-and-vaults/).
The outcome is two sandboxes on the runner each holding its own vault's
value for one shared key, a refusal naming `allowed_vault_ids`, and the
difference between a revoked allowlist and a running sandbox, read off the
runner's disk. About 25 minutes.

Confirm with the student before applying each of the three manifests,
before starting each conversation, before the prompt in 3f, before each
terminate, and before the runner shell in 3e and 3h. Those steps are marked
**confirm**. Reads run freely, which is listing environments, vaults, agents
and conversations, showing a vault, and the runner listings once the student
has agreed to them.

This lesson makes four model turns, two in 3d, one in 3f and one in 3h.
Each asks the agent whether a variable is set and costs a few tokens. Say
so before the first one.

## 1. Say what this is

In two or three sentences say this is lesson 4 of the Fountain course. An
Environment's secrets go into a sandbox first and an attached Vault's second,
and the Vault wins on a key collision. A vault attaches to one conversation,
`allowed_vault_ids` on the agent decides which vaults may be attached, and
the lesson reads where the merged value actually lives, which on the class
stack is a file on the runner's disk. Link the lesson page above.

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
true, `runner_online` true and `inference_set` true. This lesson needs all
four. The runner is where the file is read from, and the turns need a key.
If `inference_set` is false, send the student to Start here step 7 and wait.
Never ask the student for an inference key and never go looking for one.

`jq` is needed for the id lookups. If it is missing, `brew install jq`,
`apt install jq` or `winget install jqlang.jq`.

Note the check's `fountain.cli_url`. Every command below assumes the stack
on port 4000.

Run `fountain conv list` before starting. An account holds two sandboxes at
once and this lesson uses both. If an earlier lesson left a conversation
that is not `terminated`, say so, and offer to terminate it by its full id
before 3d.

## 3. The lesson

### 3a. The shared half

The student writes `f4-manifest.yaml`, one Environment and two Vaults. Use
these exact names and values, the page uses them and the fixture values are
readable on purpose, their last three characters say where each came from.
The body is in step 1 of the lesson page, which is
`content/courses/fountain/04-credentials-and-vaults.md` in this checkout.
Read it from there rather than from memory.

**confirm**, then

```sh
fountain apply -f f4-manifest.yaml
```

Six lines, `+` on each, one per object and one per secret.

### 3b. Read a vault back

```sh
fountain vault show lesson4-vault-a
```

`secret_count` 1, one entry under `secrets` with a `key`, an `id` and two
timestamps, and no `value` field. Say that this is not the CLI hiding it.
No endpoint returns a vault value, not to the owner, and the web UI's vault
page shows the same.

### 3c. The two agents, by id

```sh
fountain vault list --json | jq -r '.[] | "\(.name)  \(.id)"'
```

Two lines, a name and an id each. The student writes `f4-agents.yaml` from
step 3 of the page with their own two ids in the two `allowed_vault_ids`
lists. Say why ids, from the page: the manifest resolves `environment` by
name and passes `allowed_vault_ids` through, and a name there is a `500`
from the server with the agents left uncreated. Do not let the student try
the name form to see it, the vaults from that file would already exist and
the apply would half succeed.

**confirm**, then

```sh
fountain apply -f f4-agents.yaml
fountain agent list --json | jq -c '.[] | select(.name | startswith("lesson4")) | {name, allowed_vault_ids}'
```

`agent  +` twice, then each agent with its one vault id.

### 3d. One conversation on each

Say what the prompt does before running it. It asks the agent to test
whether `SHARED_TOKEN` is set and reply `set` or `unset`, and nothing else,
because 3f shows why asking for the value gets nowhere.

**confirm**, then

```sh
fountain run lesson4-agent-a --vault lesson4-vault-a \
  -p 'Run the shell command  test -n "$SHARED_TOKEN" && echo set || echo unset  and reply with only the word it prints.'
fountain run lesson4-agent-b --vault lesson4-vault-b \
  -p 'Run the shell command  test -n "$SHARED_TOKEN" && echo set || echo unset  and reply with only the word it prints.'
```

Each streams `provision: started`, `provision: done`, `turn: started`, the
word `set` and `turn done`. Keep both full conversation ids from the first
line of each. If either answers `http 429`, an earlier conversation holds a
slot, and the fix is in section 2.

### 3e. The proof, on the runner's disk

**confirm**, then

```sh
just runner-sh 'for f in /sandboxes/*/.env; do grep -h "^FOUNTAIN_CONVERSATION_ID=\|^SHARED_TOKEN=" "$f"; echo; done'
```

Two blocks. Agent a's conversation id with `SHARED_TOKEN='vault-a-token-111'`,
agent b's with `SHARED_TOKEN='vault-b-token-222'`. Walk the two facts. The
vault won, because neither reads `env-token-000`. A vault attaches to one
conversation, because neither reads the other's. Say what the file is, the
environment the runtime started with, written by the runner into the
sandbox's directory, readable by anyone with a shell on the runner. Then

```sh
just runner-sh 'grep -ho "^[A-Z_]*=" /sandboxes/*/.env | sort -u'
```

Point at the inference credential line, `CLAUDE_CODE_OAUTH_TOKEN=` or
`ANTHROPIC_API_KEY=`. The student's own model key is in every sandbox on
this runner, on disk, because the runtime inside needs it and a runner has
nowhere else to put it. Say that lesson 10 is about that trade and that
this is the first row of the table in 3i.

### 3f. Ask the agent, and hear it decline

**confirm**, then, with agent a's conversation id,

```sh
fountain conv prompt <agent a's id> \
  -p 'Run the shell command  echo SHARED_TOKEN=$SHARED_TOKEN  and reply with exactly the line it prints.'
```

The Claude runtime declines, in its own words, because the variable is
named like a credential and the transcript is stored, and it offers to check
whether it is set instead. Say two things. The transcript is a record and
the agent knows it. And the proof of what a sandbox holds never comes from
the sandbox saying so, which is why 3e read the disk. If the runtime does
print the value, say that the refusal is the model's judgment and not a
guarantee, which the page's self-paced section says too, and move on. The
lesson leans on it for nothing.

### 3g. The wrong vault

```sh
fountain run lesson4-agent-a --vault lesson4-vault-b \
  -p 'Run the shell command  test -n "$SHARED_TOKEN" && echo set || echo unset  and reply with only the word it prints.'
```

`fountain: http 422: vault is not in the agent's allowed_vault_ids`. No
conversation, no sandbox, no slot. This one needs no confirmation because
it provisions nothing, and say so, since the student will otherwise expect
a run.

### 3h. Revoke, and what the word means

The student writes `f4-revoke.yaml` from step 8 of the page, agent a with
`allowed_vault_ids: []`.

**confirm**, then

```sh
fountain apply -f f4-revoke.yaml
fountain run lesson4-agent-a --vault lesson4-vault-a \
  -p 'Run the shell command  test -n "$SHARED_TOKEN" && echo set || echo unset  and reply with only the word it prints.'
```

`agent  ~  lesson4-agent-a`, then the same `422` as 3g for the vault that
worked in 3d.

**confirm**, then terminate agent b's conversation by its full id to free a
slot, start agent a with no vault, and read the disk again.

```sh
fountain conv terminate <agent b's id>
fountain run lesson4-agent-a \
  -p 'Run the shell command  test -n "$SHARED_TOKEN" && echo set || echo unset  and reply with only the word it prints.'
just runner-sh 'for f in /sandboxes/*/.env; do grep -h "^FOUNTAIN_CONVERSATION_ID=\|^SHARED_TOKEN=" "$f"; echo; done'
```

The new conversation answers `set` and its block reads `env-token-000`. The
first conversation's block still reads `vault-a-token-111`. Agent b's block
is gone. Walk the difference with the student. The allowlist governs who may
start with a credential, and nothing governs who already has one, because
the merge happened once at spawn. That is Fountain's own "not revocation".

### 3i. The credential table

Show the student the table in step 9 of the page and have them read it
against what they just saw, one row per credential, where it lives, who can
read it, what it can do. Say that Mend's version has two rows this stack
does not, a read-only token in the repo's vault and a write token that never
leaves the browser, and that the sandbox row having no write in its last
column is the whole of Mend's safety. Lesson 8 takes it from there.

### 3j. Tidy up

**confirm**, then terminate the two parked conversations by their full ids.

```sh
fountain conv list
fountain conv terminate <agent a's first id>
fountain conv terminate <agent a's second id>
just runner-sh 'ls /sandboxes'
```

The listing is empty. Say that every copy of every fixture went with the
directories, which is the one revocation a runner does have. Leaving the
environment, the vaults and the agents is fine, nothing later collides with
these names.

## 4. Done when

All three have to be true, checked the way the page states them.

- 3g answered `http 422: vault is not in the agent's allowed_vault_ids`.
- 3e listed two `.env` blocks, `vault-a-token-111` beside agent a's
  conversation id and `vault-b-token-222` beside agent b's, and neither
  held the other's value.
- After 3h the new conversation's block read `env-token-000` while the
  parked one still read `vault-a-token-111`.

If 3e shows `env-token-000` in both, the runs in 3d were started without
`--vault`, restart from 3d. If 3g does not refuse, `allowed_vault_ids` on
agent a is `null` rather than a list, restart from 3c. If the runner
listing is empty, the sandboxes idled out past lesson 2's two-minute bound
before the read, restart from 3d and read the disk sooner.

## 5. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"f4"` to its `completed` array, keeping everything already in
it, creating the file and the array if either is missing. Leave every other
field untouched.

```json
{"...": "...", "completed": ["start", "f1", "f2", "f3", "f4"]}
```

## 6. Hand off

Say the next step is Fountain lesson 5, The team
(https://intentius.io/waterpark/courses/fountain/05-the-team/), where a
teammate is one conversation on the team channel and the roster and the
stream are views over it.
