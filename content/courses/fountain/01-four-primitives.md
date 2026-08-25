---
title: "Four primitives"
id: "F1"
lesson: 1
weight: 1
summary: "Fountain is made of four objects."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/f1-four-primitives"
# card. empty renders as TODO
goal: "Apply a three-document manifest that defines an Environment, an Agent and a Vault, confirm the API lists a secret's key without ever returning its value, then start a conversation with the agent and see it reply."
done_when: "The conversation you start replies, and a GET to the environment's secrets endpoint lists the key you set with no value field anywhere in the response."
restart_from: "none, this is the first lesson"
properties: ["III"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "20 min"
  needs: ["the Start-here stack running (`just up`, `just register`, `just runner`)", "an inference key set in the browser"]
  solo: true
  live: true
---

## Context

- Environment, Vault, Agent and Conversation are the only objects in Fountain.
- `fountain apply -f` applies documents with `apiVersion` `fountain.dev/v1`. The API never returns a secret value.
- The UI, the API and the CLI expose the same objects. The CLI wraps the API.

## Do

Start here kept the CLI optional and said it would earn its place once it appeared in a lesson. This is that lesson. Applying a manifest and re-applying it are a CLI job. The web UI has no equivalent for either.

1. Write the manifest below to a file named `manifest.yaml`. It is three YAML documents in one file, separated by `---`. The first is an Environment with a plain env var and one secret, the second is an Agent that references the environment by name, and the third is a Vault with one override for the same key. The web UI equivalent is filling in the New Environment, New Agent and New Vault forms one at a time, under `/environments`, `/agents` and `/vaults`.

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

2. Apply it with `fountain apply -f manifest.yaml`. It prints one line per object, `+` for created, and one line per secret underneath. There is nothing to click for this step. Applying three objects in one request is what the CLI is for.

3. Read the environment back without its secret's value. `fountain env list` prints a table with no id column, and `fountain env show` needs an id, not a name (a name gives an HTTP 400). Get the id from the JSON form of the list.

   ```sh
   fountain env list --json | jq -r '.[] | select(.name=="lesson1-env") | .id'
   ```

   Then `fountain env show <id>`. The response names the key `DEMO_API_KEY` with an id and timestamps and no `value` field. `curl` `GET /api/environments/<id>/secrets` with your Bearer key returns the same shape. The environment's page under `/environments` in the web UI shows the same thing, a key name and nothing else.

4. Start a conversation with the agent using `fountain run lesson1-agent -p "say hello"`, or `curl -X POST /api/conversations` with `agent_id` and `prompt` in the body. With the inference key you set in Start here, the sandbox provisions and the agent's reply streams into your terminal, or onto the conversation's page under `/conversations` in the web UI.

5. Change one field and apply again. Edit `STAGE` under the environment's `env_vars`, then run `fountain apply -f manifest.yaml` a second time. The environment updates in place, `~` instead of `+`, and `fountain env list` still shows one row, not two.

## Self-paced

Floci plays no part in this lesson. Everything runs on the Start-here stack, so the reply the agent gives is a real one from your own inference key, not a simulation of one.

## Live

Ten minutes. The room watches `fountain apply -f` create the three objects, the environment's secret row show a key with no value beside it, then the conversation's reply stream in. Say this when that row appears. Once a secret is stored, nobody in this room, including the facilitator, can read it back, only overwrite it.

## Further reading

- Fountain `docs/primitives.md`
- Fountain `cli/README.md`
