---
title: "Credentials and vaults"
id: "F4"
lesson: 4
weight: 4
summary: "A vault binds one credential to one conversation."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/f4-credentials-and-vaults"
# card. empty renders as TODO
goal: "Declare one Environment with a shared secret and two Vaults that each override it, give two Agents one vault each, and start a conversation on each. Then read the merged secret off the runner's own disk to see the vault win and neither sandbox hold the other's value, watch Fountain refuse a vault the agent is not allowed, ask the agent for the value and hear it decline, and empty an allowlist to see a new conversation fall back to the environment's value while the one already running keeps what it was given."
done_when: >-
  `fountain run lesson4-agent-a --vault lesson4-vault-b` answers
  `http 422: vault is not in the agent's allowed_vault_ids`, `just runner-sh`
  lists two sandbox `.env` files whose `SHARED_TOKEN` lines read
  `vault-a-token-111` beside agent a's conversation id and `vault-b-token-222`
  beside agent b's with neither holding the other's, and after agent a's
  allowlist is emptied its new conversation's file reads `env-token-000` while
  the parked one still reads `vault-a-token-111`.
restart_from: "lesson 1"
properties: ["V", "VI", "X"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "25 min"
  needs: ["the Start-here stack running (`just up`, `just register`, `just runner`) with a runner online, in the checkout `just up` ran in, because `just runner-sh` reads its `compose/.env`", "an inference key set, this lesson makes four model turns", "jq"]
  solo: true
  live: true
---

## Context

- Fountain merges secrets in one direction at spawn. The Environment's secrets go in first and the attached Vault's second, and the Vault wins on a key collision. A key only the Environment sets survives, so a vault is a patch and never a replacement.
- A vault floats free. It belongs to no agent and no environment, and it attaches to one conversation at creation. `allowed_vault_ids` on the Agent is what decides which vaults a conversation may attach, `null` permits every one, `[]` permits none, and a list is an allowlist. `allowed_environment_ids` has the same shape for a launch under a different environment.
- Values are write-only. A vault listing returns keys and timestamps and no endpoint returns a value, not even to the owner. What Fountain audits is the write, by key and by size, and not the read, because the read happens inside the sandbox.
- On the class stack the merged secrets enter the sandbox as environment variables, and the runner writes them to a `.env` file in the sandbox's directory. That file is where the credential lives, on the runner's disk, beside the inference token the runtime uses. Lesson 2 found the file and lesson 10 says what a runner trades away. A hosted account with the egress broker on sends the real values to the broker instead and the sandbox gets a placeholder.
- Mend keeps the read token in the repo's vault and the write token in the browser, so the sandbox never holds the thing that can push. That split is the credential table this lesson ends on, and it comes back in lesson 8 and in IAM lesson 12.
- Removing a vault from an agent's allowlist revokes it for every later conversation and for nothing already running. By then the value is in a process environment on a machine, and Fountain's own vault doc says so. On the class stack it is also in a file, and a sandbox that parked before it was terminated keeps that file, so step 10 removes it by hand. A vault is not rotation, not revocation, not a read audit and not returnable, and each of those four is a sentence this lesson keeps.
- The Claude runtime declines to print a value that looks like a credential, and declines a substring of it too. So the proof that the vault won is not a model turn. It is the sandbox file on the runner, and the turns in this lesson ask the agent only whether the variable is set.
- A manifest resolves `environment` by name and does not resolve `allowed_vault_ids`, which are ids. A name in that list is a `500` from the server rather than a `422`, recorded in [upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md), so the agents are applied in a second file once the vault ids are known.

## Do

Lesson 3 was a refusal before the model was called. This lesson has four model turns, each of which asks the agent one harmless question, and the interesting facts are all read from somewhere else.

1. Write the shared half. One Environment with a secret, and two Vaults that each override the same key with their own value. Write it to `f4-manifest.yaml`.

   ```yaml
   apiVersion: fountain.dev/v1
   kind: Environment
   metadata:
     name: lesson4-env
   spec:
     networking_type: unrestricted
     secrets:
       SHARED_TOKEN: env-token-000
   ---
   apiVersion: fountain.dev/v1
   kind: Vault
   metadata:
     name: lesson4-vault-a
   spec:
     secrets:
       SHARED_TOKEN: vault-a-token-111
   ---
   apiVersion: fountain.dev/v1
   kind: Vault
   metadata:
     name: lesson4-vault-b
   spec:
     secrets:
       SHARED_TOKEN: vault-b-token-222
   ```

   ```sh
   fountain apply -f f4-manifest.yaml
   ```

   ```
   env  +  lesson4-env
     secret  ~  lesson4-env/SHARED_TOKEN
   vault  +  lesson4-vault-a
     secret  ~  lesson4-vault-a/SHARED_TOKEN
   vault  +  lesson4-vault-b
     secret  ~  lesson4-vault-b/SHARED_TOKEN
   ```

   The objects are `+` and the secrets are `~` even on a first write, which
   is how the CLI reports a secret it set. The three values are fixtures whose last three characters say where they
   came from, and that is the only reason they are readable at all.

2. Read a vault back and notice what is missing.

   ```sh
   fountain vault show lesson4-vault-a
   ```

   The response carries `secret_count`, and under `secrets` one entry with a
   `key`, an `id`, a `vault_id` and two timestamps. There is no `value`
   field. That is not
   a CLI choice, no endpoint returns a vault value, and the web UI's vault
   page under `/vaults` shows the same key and nothing else. What you can
   learn from Fountain about a secret is when it was written and how big it
   was.

3. Write the two agents, each allowed exactly one vault. The allowlist takes ids, so read them first.

   ```sh
   fountain vault list --json | jq -r '.[] | "\(.name)  \(.id)"'
   ```

   ```
   lesson4-vault-b  78ea3837-75d0-477f-917e-fb061383e598
   lesson4-vault-a  233db924-cdb0-4e5f-be8f-2a0cc4104885
   ```

   Write `f4-agents.yaml`, putting your own two ids where the two below are.

   ```yaml
   apiVersion: fountain.dev/v1
   kind: Agent
   metadata:
     name: lesson4-agent-a
   spec:
     model: anthropic/sonnet
     runtime: claude
     environment: lesson4-env
     allowed_vault_ids:
       - 233db924-cdb0-4e5f-be8f-2a0cc4104885
   ---
   apiVersion: fountain.dev/v1
   kind: Agent
   metadata:
     name: lesson4-agent-b
   spec:
     model: anthropic/sonnet
     runtime: claude
     environment: lesson4-env
     allowed_vault_ids:
       - 78ea3837-75d0-477f-917e-fb061383e598
   ```

   ```sh
   fountain apply -f f4-agents.yaml
   fountain agent list --json | jq -c '.[] | select(.name | startswith("lesson4")) | {name, allowed_vault_ids}'
   ```

   `agent  +` twice, then each agent listing its one vault id. The
   `environment` line resolved a name because the manifest resolves that
   field. `allowed_vault_ids` is stored as ids and the manifest passes it
   through, so a vault name there is not a validation error but a `500` from
   the server, `Ecto.ChangeError` in the log, with the agents left uncreated
   and the vaults already made. Two files is the honest shape until that is
   fixed upstream.

4. Start one conversation on each agent, each with its own vault. The prompt asks whether the variable is set and nothing else, for a reason step 6 shows. Keep both conversation ids from the first line of each run.

   ```sh
   fountain run lesson4-agent-a --vault lesson4-vault-a \
     -p 'Run the shell command  test -n "$SHARED_TOKEN" && echo set || echo unset  and reply with only the word it prints.'
   fountain run lesson4-agent-b --vault lesson4-vault-b \
     -p 'Run the shell command  test -n "$SHARED_TOKEN" && echo set || echo unset  and reply with only the word it prints.'
   ```

   ```
   ▸ conversation 5990cf3b-17eb-4177-9be5-55c67d77d9d7
   ▸ provision: started
   ▸ provision: done
   ▸ turn: started

   [Terminal]
     ✓ completed
   set▸ turn done (exit_code=)
   ```

   The two lines between `turn: started` and `set` are the runtime's tool
   call, the shell command it ran. Both answer `set`, and both sandboxes are now parked on the runner holding
   whatever they were given. An account holds two sandboxes at once, and
   these are the two.

5. Read the merged secret off the runner's disk. This is the proof.

   ```sh
   just runner-sh 'for f in /sandboxes/*/.env; do grep -h "^FOUNTAIN_CONVERSATION_ID=\|^SHARED_TOKEN=" "$f"; echo; done'
   ```

   ```
   FOUNTAIN_CONVERSATION_ID='5990cf3b-17eb-4177-9be5-55c67d77d9d7'
   SHARED_TOKEN='vault-a-token-111'

   FOUNTAIN_CONVERSATION_ID='6b9e9405-ad61-4b14-9956-dfd205c27c97'
   SHARED_TOKEN='vault-b-token-222'
   ```

   Agent a's conversation carries vault a's value and agent b's carries vault
   b's. Neither carries `env-token-000`, because the vault won the merge, and
   neither carries the other's, because a vault attaches to one conversation.
   That file is the environment the runtime started with, written by the
   runner into the sandbox's directory, and it is readable by anyone who can
   run a shell on the runner, which on the class stack is you. Lesson 2
   found this file for a different reason. Look at the rest of it.

   ```sh
   just runner-sh 'grep -ho "^[A-Z_]*=" /sandboxes/*/.env | sort -u'
   ```

   `CLAUDE_CODE_OAUTH_TOKEN=` or `ANTHROPIC_API_KEY=`, whichever you set in
   Start here, `FOUNTAIN_TOKEN=`, `FOUNTAIN_CONVERSATION_ID=`,
   `FOUNTAIN_BASE_URL=`, `TRACEPARENT=`, the four git author lines, and
   `SHARED_TOKEN=`. Your inference credential is in every sandbox on this
   runner, on disk, because the runtime inside needs it and a runner has
   nowhere else to put it. That is the trade lesson 10 is about, and it is
   the first line of the credential table in step 9.

6. Ask the agent for the value, and read what it says. This turn is optional and it is the one you should watch.

   ```sh
   fountain conv prompt 5990cf3b-17eb-4177-9be5-55c67d77d9d7 \
     -p 'Run the shell command  echo SHARED_TOKEN=$SHARED_TOKEN  and reply with exactly the line it prints.'
   ```

   The Claude runtime declines. The wording varies and the shape does not.
   The variable is named like a credential, printing it would put the value
   in a transcript that gets stored, and it offers to check whether it is set
   or how long it is instead. Ask for the last three characters and it
   declines that too, as a substring of the same secret. Two things follow.
   The transcript is a record, and the agent knows it. And the proof of what
   a sandbox holds is never going to come from the sandbox saying so, which is
   why step 5 read the disk.

7. Attach the wrong vault and get refused. Agent a is allowed vault a only.

   ```sh
   fountain run lesson4-agent-a --vault lesson4-vault-b \
     -p 'Run the shell command  test -n "$SHARED_TOKEN" && echo set || echo unset  and reply with only the word it prints.'
   ```

   ```
   fountain: http 422: vault is not in the agent's allowed_vault_ids
   ```

   No conversation, no sandbox, no turn, and no slot used. The refusal is a
   validation of the request, before anything is provisioned, so it costs
   nothing and it names the field.

8. Revoke, and see what that word means here. Empty agent a's allowlist by applying a third file, `f4-revoke.yaml`.

   ```yaml
   apiVersion: fountain.dev/v1
   kind: Agent
   metadata:
     name: lesson4-agent-a
   spec:
     model: anthropic/sonnet
     runtime: claude
     environment: lesson4-env
     allowed_vault_ids: []
   ```

   ```sh
   fountain apply -f f4-revoke.yaml
   fountain run lesson4-agent-a --vault lesson4-vault-a \
     -p 'Run the shell command  test -n "$SHARED_TOKEN" && echo set || echo unset  and reply with only the word it prints.'
   ```

   `agent  ~  lesson4-agent-a`, then the same `422` as step 7, this time for
   the vault that worked in step 4. No later conversation of agent a can
   attach it. Now free a slot and start agent a with no vault at all.

   ```sh
   fountain conv terminate 6b9e9405-ad61-4b14-9956-dfd205c27c97
   fountain run lesson4-agent-a \
     -p 'Run the shell command  test -n "$SHARED_TOKEN" && echo set || echo unset  and reply with only the word it prints.'
   just runner-sh 'for f in /sandboxes/*/.env; do grep -h "^FOUNTAIN_CONVERSATION_ID=\|^SHARED_TOKEN=" "$f"; echo; done'
   ```

   ```
   FOUNTAIN_CONVERSATION_ID='5bb56db2-ceff-4be5-9f9a-168235a51466'
   SHARED_TOKEN='env-token-000'

   FOUNTAIN_CONVERSATION_ID='5990cf3b-17eb-4177-9be5-55c67d77d9d7'
   SHARED_TOKEN='vault-a-token-111'
   ```

   The new conversation answered `set` and its file carries the environment's
   value, which is what a key only the environment sets looks like with no
   vault on top. The first conversation's file still carries the vault's
   value, and will until that sandbox is destroyed, because the merge happened
   once at spawn and nothing after it reaches a running machine. Agent b's
   directory is gone with its conversation. That is what Fountain's doc means
   by not revocation, and the honest reading is that the allowlist governs
   who may start with a credential and nothing governs who already has one.

9. Write the credential table, which is the thing this lesson exists to hand to lesson 8 and IAM lesson 12. It is Mend's shape, who holds which credential and what it can do, filled in for this stack.

   | Credential | Where it lives | Who can read it | What it can do |
   |---|---|---|---|
   | `SHARED_TOKEN`, environment value | the Environment, encrypted, and every sandbox with no vault, on the runner's disk | any conversation of any agent on `lesson4-env` | whatever the token is for, as the baseline |
   | `SHARED_TOKEN`, vault a's value | vault a, encrypted, and agent a's sandboxes, on the runner's disk | conversations that attached vault a, while they run, and anyone with the runner's disk after one parks, until its directory is removed by hand | the same, with vault a's scope |
   | `SHARED_TOKEN`, vault b's value | vault b, encrypted, and agent b's sandboxes | conversations that attached vault b | the same, with vault b's scope |
   | your inference key | your account, and every sandbox on the runner, on disk | every conversation you start | spend against your model account |
   | `FOUNTAIN_TOKEN` | every sandbox | the conversation it was minted for | talk to Fountain as that conversation |

   Mend's version has two rows this stack does not, a read-only token in the
   repo's vault and a write token that never leaves the browser, and the
   whole of Mend's safety is that the sandbox row has no write anywhere in
   its last column. Lesson 8 takes it from there.

10. Let the first conversation park, then terminate both and look at the disk once more. The class stack parks a sandbox two minutes after its last turn, which is lesson 2's bound, and the first conversation's last turn was step 6. Wait for its marker before going on, and `fountain conv list` will not tell you, because it reads `idle` either way.

    ```sh
    just runner-sh 'ls /sandboxes/*/.fountain-suspended'
    ```

    When that prints one path, terminate both conversations by their full ids
    and list again.

    ```sh
    fountain conv terminate 5990cf3b-17eb-4177-9be5-55c67d77d9d7
    fountain conv terminate 5bb56db2-ceff-4be5-9f9a-168235a51466
    just runner-sh 'ls /sandboxes'
    ```

    Both conversations read `terminated`, and the listing is not empty. A
    sandbox that was awake when it was terminated loses its directory,
    which is what lesson 2 saw and what the second conversation's sandbox
    just did. A sandbox that had already parked keeps it, with its `.env`
    and the value inside, and the runner does not come back for it. The
    first conversation's directory is the one still there, and
    `SHARED_TOKEN='vault-a-token-111'` is still in it. That is recorded
    in [upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md),
    and until it is fixed the one revocation a runner does have is a shell.

    ```sh
    just runner-sh 'rm -rf /sandboxes/runner-*; ls /sandboxes'
    ```

    Now the listing is empty, and every copy of every fixture is gone from
    the disk because you removed it, not because anything else did.

## Self-paced

This lesson needs an inference key, because a sandbox has to reach the turn to park with its environment in place, and it makes four short turns, two in step 4, one in step 6 and one in step 8. Each asks the agent whether a variable is set and nothing that costs more than a few tokens. Floci plays no part.

Everything the lesson proves, it proves on the class stack. The vault wins the merge, a vault attaches to one conversation, the allowlist refuses before anything is provisioned, and emptying it changes later conversations and not running ones. What the runner adds is the disk. On a hosted provider the merged secrets still enter the sandbox as environment variables, and you would not have a shell on the host to read the file, which is a difference in who can see it and not in what the sandbox holds. On a hosted account with the egress broker on, the sandbox gets a placeholder and the broker attaches the real value on the way out, which is the only configuration where step 5 would show something other than the value. The class stack does not run the broker, and the course does not ask you to.

The model's refusal in step 6 is the Claude runtime's judgment, and it is not a guarantee. A different runtime or a different prompt might print the value. The lesson leans on it for nothing.

## Live

Twenty minutes, and the room needs steps 5, 7 and 8.

Open on step 5 with both sandboxes already parked. Put the runner listing on the projector and let the room read two conversation ids and two different values for the same key. Then run the second `grep` and point at the inference token line. The line to say is that the runtime needs a credential to call a model and a runner has exactly one place to put it, which is the disk in front of you.

Then step 7, and the `422` arriving before `provision: started` would have. Then step 8 whole, and stop on the second listing. The new conversation holds the environment's value and the old one still holds the vault's, and ask the room which of those two lines the word revoke describes. The answer is the first one only, and Fountain's own doc says so in its sentence about not revocation.

One honesty line. The values in this lesson are fixtures with their origin in their last three characters, so a listing that prints them is harmless. A real token in that file is read the same way by the same command, and the runner does not know the difference.

## Further reading

- Fountain `docs/concepts/vault.md`, the merge rule and the four things a vault is not
- Fountain `docs/sdk.md`, `allowed_vault_ids` and `allowed_environment_ids`
- [Workload identity](../../docs/design/workload-identity.md), the sandbox exception
- Decision 15
- [Lesson 2, the sandbox lifecycle](02-sandbox-lifecycle.md), where the file was first found
- [Lesson 10, the self-hosted runner](10-self-hosted-runner.md), what the disk costs
- Mend README, the credential table this one copies
- [Upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md), names in `allowed_vault_ids`
