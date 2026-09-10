---
title: "The self-hosted runner"
id: "F10"
lesson: 10
weight: 10
summary: "A runner is a machine you own, in trusted mode, and it must be online."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/f10-self-hosted-runner"
# card. empty renders as TODO
goal: "Read the class stack's runner as what it is, one process on one machine that dials out with your key and serves directories as sandboxes. Then show the three things Fountain's own decision record says a runner has none of, an egress policy, isolation between sandboxes, and reachability when the daemon is down, each on the stack rather than in a sentence, and say what lesson 3 no longer guarantees here."
done_when: >-
  `GET /api/runners` lists the class stack's runner with `online` true and
  `root` `/sandboxes`, a `limited` environment refuses to provision with
  `provider: runner` in its `network` event, a second sandbox lists its
  sibling's directory under `/sandboxes` in a turn while both directories
  read as the same user from the runner's shell, `fountain run` with the
  runner container stopped answers `http 409` naming `fountain runner`, a
  prompt to the parked conversation fails with `runner_offline`, and the
  same prompt answers once the container is started.
restart_from: "lesson 1"
properties: ["VI"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "25 min"
  needs: ["the Start-here stack running (`just up`, `just register`, `just runner`) with a runner online, in the checkout `just up` ran in", "an inference key set, this lesson makes three model turns", "jq and curl"]
  solo: true
  live: true
---

## Context

- `fountain runner` is a daemon on a machine you own. It authenticates with your ordinary API key, opens a socket to Fountain and holds it, and Fountain routes every sandbox operation for your account over that socket. A sandbox is a directory under the daemon's root, every command runs as the daemon's user with `HOME` set to that directory, and everything else, the toolchain, the network and the agent CLIs, is the host's (Fountain ADR 0022).
- The decision record says the rest in one line, and the course borrows it. Trusted mode is the only mode. There is no VM, no container, no egress policy, and the daemon must be online for the sandbox to be reachable. A container mode is compatible with the protocol and is not built. The class stack's runner is one Docker container, which is the container mode, from the outside, for the whole runner rather than per sandbox.
- Lessons 2, 4 and 5 met the runner without naming it. Lesson 2 found the sandbox as a directory with a `.fountain-suspended` marker. Lesson 4 found every credential a sandbox holds, the inference token included, in that directory's `.env`, and found a parked directory surviving its termination. Lesson 5 stopped the container and read `machine_offline`. This lesson reads those facts as one trade.
- The trade is the counterexample for Accessible Ops VI. A runner has no bounded blast radius between sandboxes, because they are directories under one user, and no bound on egress, because the network is the host's. What it has instead is your hardware, your LAN, state that never ages out and nothing billed by the minute. Decision 29 says a containment claim needs a hosted provider, and this is the lesson that shows why.
- Lesson 3 was the refusal. A `limited` environment fails to provision on a runner, on purpose, with `backend_lacks_network_policy` and `provider: runner` in the event. This lesson replays it in one step and then shows what an unrestricted sandbox on the same runner can reach, which is everything the host can.
- The runner holds your API key, because that is what authenticates its socket, and on the class stack it also holds the emulator's throwaway pair. Anyone with a shell on the runner has both. That is not a bug in the stack, it is what a runner is.

## Do

Lesson 3 said the runner could not hold an egress policy and moved on. This lesson stays on the runner and reads everything it cannot hold.

1. Read the runner three ways, from Fountain, from Docker and from inside.

   ```sh
   FOUNTAIN_KEY=$(awk -v p="[${FOUNTAIN_PROFILE:-default}]" '$0==p{f=1;next} /^\[/{f=0} f && $1=="api_key"{gsub(/"/,"",$3); print $3; exit}' ~/.fountain/credentials)
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/runners | jq '.data[]'
   ```

   ```json
   {
     "id": "4316504e-d80b-4610-b118-6ca558e70858",
     "name": "waterpark",
     "version": "dev",
     "os": "linux",
     "root": "/sandboxes",
     "hostname": "9ce7de500f4c",
     "connected_at": "2026-09-10T21:51:53Z",
     "arch": "arm64",
     "last_seen_at": "2026-09-10T22:27:14Z",
     "online": true,
     "created_at": "2026-09-10T21:14:13Z"
   }
   ```

   That is everything Fountain knows about the machine. A name, a root, an
   architecture, and whether a socket is open right now. Nothing here is a
   credential, and the id is the string every sandbox name on this runner
   starts with, which lessons 2 and 4 saw as `runner-4316504e...`.

   ```sh
   docker compose -f compose/docker-compose.yml --env-file compose/.env --profile runner ps --format '{{.Name}} {{.Image}} {{.Status}}'
   just runner-sh 'id; tr "\0" " " < /proc/1/cmdline; echo; env | grep -E "^(FOUNTAIN|AWS)" | sed "s/=.*/=.../"'
   ```

   ```
   compose-runner-1 ghcr.io/intentius/waterpark-runner:latest Up 37 minutes

   uid=1001(runner) gid=1001(runner) groups=1001(runner)
   fountain runner --name waterpark --root /sandboxes
   AWS_ENDPOINT_URL=...
   AWS_DEFAULT_REGION=...
   AWS_ACCESS_KEY_ID=...
   AWS_SECRET_ACCESS_KEY=...
   FOUNTAIN_BASE_URL=...
   FOUNTAIN_API_KEY=...
   ```

   One container, one process at PID 1, one user, and an environment that
   holds your API key and the emulator's pair. The daemon runs whatever the
   agent runs, as that user, with that environment's host. Every sandbox on
   this runner is a directory that user owns.

2. Write two environments and two agents to `f10-manifest.yaml` and apply it. One environment is unrestricted with a secret, the other is lesson 3's `limited` with a named host.

   ```yaml
   apiVersion: fountain.dev/v1
   kind: Environment
   metadata:
     name: lesson10-env
   spec:
     networking_type: unrestricted
     secrets:
       RUNNER_SECRET: runner-secret-777
   ---
   apiVersion: fountain.dev/v1
   kind: Agent
   metadata:
     name: lesson10-agent
   spec:
     model: anthropic/sonnet
     runtime: claude
     environment: lesson10-env
   ---
   apiVersion: fountain.dev/v1
   kind: Environment
   metadata:
     name: lesson10-locked
   spec:
     networking_type: limited
     networking_config:
       allowed_hosts:
         - api.github.com
   ---
   apiVersion: fountain.dev/v1
   kind: Agent
   metadata:
     name: lesson10-locked-agent
   spec:
     model: anthropic/sonnet
     runtime: claude
     environment: lesson10-locked
   ```

   ```sh
   fountain apply -f f10-manifest.yaml
   ```

   Two `env  +`, one `secret  ~`, two `agent  +`.

3. No egress policy. This is lesson 3 in one step, and it goes first because a refused run holds no sandbox slot.

   ```sh
   fountain run lesson10-locked-agent -p 'Fetch https://api.github.com and tell me the HTTP status.'
   ```

   ```
   ▸ conversation 8514ce6b-...
   ▸ provision: started
   ▸ network: failed
   ▸ provisioning failed — the sandbox never started
   fountain: provisioning failed — the sandbox never started
   ```

   Lesson 3's events call had the reason,
   `{"reason":"backend_lacks_network_policy","type":"limited","provider":"runner"}`,
   and it is the same reason today. The decision record says the provider
   does not advertise a network policy and a `limited` environment fails on
   it on purpose. What the unrestricted agent can reach is the host's whole
   network, which on the class stack is your laptop's.

4. No isolation. Start two conversations on the unrestricted agent, and have the second one look around.

   ```sh
   fountain run lesson10-agent -p 'Run the shell command  ls /sandboxes  and reply with only the lines it prints.'
   fountain run lesson10-agent -p 'Run the shell command  ls /sandboxes  and reply with only the lines it prints.'
   ```

   The first answers with one directory, its own. The second answers with
   two.

   ```
   runner-4316504ed80b4610b1186ca558e70858-2efc5530
   runner-4316504ed80b4610b1186ca558e70858-b03f9dac▸ turn done (exit_code=)
   ```

   A sandbox can see its sibling. Now read the two from the runner's shell.

   ```sh
   just runner-sh 'ls -la /sandboxes; for f in /sandboxes/*/.env; do echo "$f"; grep -E "^(FOUNTAIN_CONVERSATION_ID|RUNNER_SECRET)=" "$f"; done'
   ```

   ```
   drwx------ 5 runner runner 4096 Sep 10 22:27 runner-4316504ed80b4610b1186ca558e70858-2efc5530
   drwx------ 5 runner runner 4096 Sep 10 22:27 runner-4316504ed80b4610b1186ca558e70858-b03f9dac
   /sandboxes/runner-4316504ed80b4610b1186ca558e70858-2efc5530/.env
   FOUNTAIN_CONVERSATION_ID='6daff683-...'
   RUNNER_SECRET='runner-secret-777'
   /sandboxes/runner-4316504ed80b4610b1186ca558e70858-b03f9dac/.env
   FOUNTAIN_CONVERSATION_ID='0b8bd9dd-...'
   RUNNER_SECRET='runner-secret-777'
   ```

   Read the mode and the owner together. `drwx------` and `runner runner`
   on both, so the mode keeps other users out and there is only one user.
   A process in either sandbox runs as `runner` and can open the other's
   `.env`, its transcript, its `.claude` state and anything else in it. The
   decision record's words are that the daemon runs whatever the agent runs,
   as the daemon's user, and there is no VM, no container and no
   `sandbox-exec`. Lesson 4's credential table has one row for a runner's
   disk, and this is why that row's readers column says anyone with the
   runner's disk. Two agents with two vaults would sit side by side here
   with both values readable from either.

5. Must be online. Free a slot, stop the container, and ask Fountain for the runner and for a sandbox.

   ```sh
   fountain conv list
   fountain conv terminate <the second conversation's full id>
   docker compose -f compose/docker-compose.yml --env-file compose/.env --profile runner stop runner
   sleep 5
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/runners | jq -c '.data[] | {name, online, last_seen_at}'
   ```

   `{"name":"waterpark","online":false,"last_seen_at":"2026-09-10T22:30:14Z"}`.
   The socket closed and Fountain noticed within seconds. Now a new
   conversation, and then a prompt to the one already parked.

   ```sh
   fountain run lesson10-agent -p 'Reply with the single word hi.'
   fountain conv prompt <the first conversation's full id> -p 'Reply with the single word hi.'
   ```

   ```
   fountain: http 409: this agent runs on a self-hosted runner and none of yours is connected — start `fountain runner` on the machine and try again
   ```

   ```
   ▸ turn: started
   ▸ turn failed
   fountain: turn failed
   ```

   The new run is refused before anything is minted, with the fix in the
   message. The parked one accepts the turn and fails it, and the events
   call from lesson 3 shows the reason as `{:unavailable, :runner_offline}`,
   which is the taxonomy's word for a directory on a machine that is
   switched off. The decision record says that is transient and never
   `not_found`, because the directory is still the agent's memory. Start
   the container and prove that.

   ```sh
   docker compose -f compose/docker-compose.yml --env-file compose/.env --profile runner start runner
   sleep 5
   curl -s -H "Authorization: Bearer $FOUNTAIN_KEY" http://localhost:4000/api/runners | jq -c '.data[] | {online, connected_at}'
   fountain conv prompt <the first conversation's full id> -p 'Reply with the single word back.'
   ```

   `online` true with a new `connected_at`, and then `back`. Same
   conversation, same directory, and a machine that was off for a minute.
   Nothing you own was reachable while it was off, and nothing you own was
   lost.

6. Write down the trade. This is the table the decision record's consequences section is, filled in for the stack in front of you.

   | A runner has | A runner has none of | Where you saw it |
   |---|---|---|
   | your hardware and your LAN | a bound on what a sandbox can reach | step 3, and every host the unrestricted agent can name |
   | one user and one disk that never ages out | isolation between sandboxes | step 4, two directories, one owner |
   | state that stays, parked for free | reachability when the daemon is down | step 5, `409` and `runner_offline` |
   | your key on the daemon, no vendor account | a credential the sandbox cannot read | step 1, and lesson 4's `.env` |
   | nothing billed by the minute | a ceiling on what a runaway costs | lesson 2's lifetime bound is the only one |

   The right column is what lesson 3 no longer guarantees, and it is the
   whole of Accessible Ops VI. A hosted provider gives you that column and
   takes the left one. Decision 29 is the course saying which of the two it
   will let a containment claim rest on.

7. Terminate both conversations and remove what parked.

   ```sh
   fountain conv list
   fountain conv terminate <the first conversation's full id>
   just runner-sh 'ls /sandboxes; rm -rf /sandboxes/runner-*; ls /sandboxes | wc -l'
   ```

   The parked directory from lesson 4's finding survives the terminate and
   the `rm -rf` is yours, then `0`. The locked run from step 3 held nothing
   to remove.

## Self-paced

This lesson needs an inference key and makes three short turns, two in step 4 and one at the end of step 5, plus one that fails on purpose. It runs entirely on the class stack, and it is the class stack described accurately, which is the point.

What a hosted provider changes. With `SANDBOX_PROVIDER` set to Sprites, E2B or Daytona and its token in `compose/.env`, step 3 provisions a sandbox that cannot reach `example.com`, step 4's second sandbox lists only itself, and step 5 has no container to stop, because the machine is the provider's. What you give up is the left column of step 6's table, and the course never asks you to make that trade. One inference key is the ceiling of what Start here asks for.

Two things the decision record lists as not built and this lesson does not pretend are. A container or VM mode per sandbox, which would give the runner isolation, and per-agent runner pinning, so today the daemon that serves you is your most recently connected online one. The class stack has exactly one, so the second never bites here.

## Live

Twenty minutes, with the runner container's log on one side of the projector and a shell on the other.

Open on step 1 and read the environment listing aloud. The line to say is that the daemon holds the presenter's API key because that is what authenticates it, and every sandbox on this runner is a directory the same user owns. Then step 4 whole, and let the room watch the second sandbox print the first one's name. Ask what the mode on the two directories protects against, and let somebody say another user, and then ask how many users there are.

Then step 5 with the container stopped in front of them. The `409` names the fix, the parked turn fails with the machine's word for switched off, and the restart brings the same conversation back. The honesty line is that this is the course's own stack, that every lesson before this one ran on it, and that what a runner gives you is a computer you own and what it takes is every promise a sandbox provider makes about the space between two agents.

## Further reading

- Fountain ADR 0022, `decisions/0022-self-hosted-runner-provider.md` at the pinned commit, the whole of what this lesson reads
- Fountain ADR 0016, for the egress chokepoint a runner sits outside of
- [Threat model](../../docs/threat-model.md), boundary 5
- [Design, workload identity](../../docs/design/workload-identity.md), the sandbox exception
- Decisions 15 and 29
- [Lesson 3, the egress allowlist](03-egress-allowlist.md), the refusal replayed here
- [Lesson 4, credentials and vaults](04-credentials-and-vaults.md), the file on the disk
- [Upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md), the parked directory and the credentials in it
