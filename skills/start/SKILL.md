---
name: waterpark-start
description: Walk a student through water park's Start here page. Use when someone wants to begin the courses or set up. Clones water park, gets Fountain installed and logged in, checks the tools, writes .waterpark/profile.json, and points at the first lesson.
---

# water park, Start here

You are walking a student through Start here
(https://intentius.io/waterpark/start/). The outcome is a water park
checkout, a Fountain instance they are logged in to, and a profile file
the next lesson reads. About ten minutes.

Confirm with the student before each step that installs software, starts
a service, or writes a file. Those steps are marked **confirm**. Ask the
OS before any command. Docker is settled in step 4 and never assumed.

## 1. Say what this is

In three sentences say what the two courses are and that this step gets
two things in place, water park and access to a Fountain. Ask which mode
they want,
self-paced (their laptop, Floci, no AWS account) or live (a facilitator
brings accounts). Default to self-paced.

## 2. Get water park

If the current directory is not a water park checkout (no `hugo.toml` and
no `skills/start/SKILL.md`), **confirm**, then clone it and move there.

```sh
git clone https://github.com/INTENTIUS/waterpark && cd waterpark
```

If it is a checkout, `git pull`. The skills, the check script, the
student's profile, the exercises and the compose stack all live here. The
student does not need a repo of their own.

## 3. Ask the OS, then run the check

Ask which OS and shell the student is on. macOS, Linux, or Windows, and
bash, zsh, or PowerShell. Do not assume. Then run the check for that OS
and show the output. macOS and Linux run `bash skills/start/check.sh`.
Windows runs `powershell -ExecutionPolicy Bypass -File skills/start/check.ps1`,
or the bash script inside WSL or Git Bash. Both only read. For the
student's own eyes there is also `just doctor` (or
`bash skills/start/check.sh doctor` on macOS/Linux,
`powershell -ExecutionPolicy Bypass -File skills/start/check.ps1 doctor`
on Windows), the same checks as a human report
with the install line under each missing item. You read the JSON, the
student reads the doctor. They report
the OS, which package managers are present (brew, apt, winget, scoop and
so on), whether this is a water park checkout, which of `docker`,
`fountain`, `floci`, `aws`, `jq` and `gh` are installed with versions,
whether the Fountain URL answers and the CLI is logged in, and whether
Floci answers. Do not guess at anything the check can report.

## 4. Docker, yes or no

Settle this before installing anything, and say it to the student in
these words. Docker runs the class stack, Fountain with its database,
Floci, and the sandbox runner, from one compose file in this repo.

| The student is | Docker |
|---|---|
| live, with a Fountain URL from the facilitator | not needed |
| anything else | needed, it runs the whole stack |

If needed and `docker` is missing, **confirm**, then install Docker
Desktop and wait until `docker version` answers.

| OS | Install |
|---|---|
| macOS | `brew install --cask docker`, or the Docker Desktop `.dmg` from https://www.docker.com/products/docker-desktop/ without Homebrew. Open Docker.app once |
| Windows | `winget install Docker.DockerDesktop`, or the installer from the same page. Choose the WSL 2 backend when asked. Log out and in if it says so |
| Linux | the distribution's `docker` packages, then add the user to the `docker` group |

## 5. Fountain

Ask. **Do you have a Fountain URL to use?** In a class the facilitator
may give one. Otherwise the stack from this repo is the instance.

### 5a. The stack, one shot

From the water park checkout. **confirm**, then

```sh
just up          # Fountain at :4000, Floci at :4566, keys generated into compose/.env
```

It ends by proving both answer (two check-mark lines) and printing the
next command. If it fails it names the step, `just logs` shows why, and
`just up` is safe to re-run. It will not mint a second set of keys over
the first. If port 4000 is already taken, `just up` says so. Set `PORT`
and `FLOCI_PORT` in `compose/.env` and run it again. Everything below
follows those two ports.

(Without `just`, `compose/bin/env.sh` then
`docker compose -f compose/docker-compose.yml --env-file compose/.env up -d`.
Windows runs these in WSL or Git Bash.)

Then register the student. This instance is temporary and local, so you
handle it. Ask for an email and a password, saying both of these
sentences first. This account lives only in the class instance on this
laptop. Do not reuse a password you care about. Then **confirm** and run

```sh
just register their@email
```

It prompts for the password silently, keeping it out of shell history.

The script calls `POST /api/auth/register` and `POST /api/auth/token`, writes
`~/.fountain/credentials` the way `fountain auth login` does, and gives
the runner service its key. Accounts self-verify on this instance. Then
**confirm** and start the sandbox runner

```sh
just runner
```

Then re-run the check and confirm `fountain.runner_online` is true. The
runner is the one service whose failure nothing else surfaces.

The runner is a container with node, bun, git, the AWS CLI and jq. Its
sandboxes are directories inside it, not on the laptop. One caveat to
say out loud. `networking_type: limited` does not provision on a runner,
so the egress lesson (Fountain lesson 3) needs a hosted sandbox provider,
`SPRITES_TOKEN` in `compose/.env` and `SANDBOX_PROVIDER=sprites`, then
`just up` again.

If the student signs in to the web UI at any point, the onboarding
wizard may ask for the inference key before step 7 mentions it. That is
fine. Step 7 verifies it either way.

The CLI is optional with the stack (the web UI covers the lessons until
the CLI appears in one). When wanted, install it as in 5b.

### 5b. With a facilitator's URL, the CLI and an account

Install the CLI for their OS. **confirm** first.

| OS | CLI |
|---|---|
| macOS | `brew install BinaryBourbon/tap/fountain`. Without Homebrew, the `fountain-darwin-arm64` or `-amd64` binary from the GitHub release, on the PATH |
| Linux | the `fountain-linux-amd64` or `-arm64` binary from the GitHub release, on the PATH |
| Windows | no native build yet. The Linux binary inside WSL 2, or no CLI at all. Everything the CLI does is also the web UI or `curl` against `/api` |

Register the student on the class instance the same way, after the two
sentences and a **confirm**.

```sh
compose/bin/register.sh their@email 'their-password' class https://the.instance
```

With a remote base URL it registers, mints a key and writes the CLI
credentials under the named profile, and touches nothing else. Then
`export FOUNTAIN_PROFILE=class`. Look at the check's `fountain.profile`
and `fountain.cli_url` first. If a `default` profile already points at
another host, the named profile keeps them apart. The inference key is
the browser onboarding, as above, at the facilitator's URL.

## 6. Floci

With the stack from 5a, Floci is already running at `http://localhost:4566`.
Put the variables in the shell and nothing else is needed.

```sh
export AWS_ENDPOINT_URL=http://localhost:4566 AWS_DEFAULT_REGION=us-east-1 AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test
```

(PowerShell uses `$env:NAME = "value"`.) The `floci` CLI is optional,
`brew install floci-io/floci/floci` and `eval $(floci env)` do the same
with `floci start` managing its own container. Live students skip Floci.
A machine that cannot run Docker uses Floci's native binary from its
releases page, listening on 4566, with the same four variables.

## 7. The inference key

Conversations run on the student's own provider token (Fountain never
sees inference traffic), so nothing works until one key is set. Say
that, and that the key is the one thing you will never see or type.
Anthropic is the one the runtimes ask for first, and a key comes from
https://console.anthropic.com (or the facilitator hands them out).

Two ways, the student picks.

- **Browser.** Open the instance URL, sign in with the account from
  step 5, and the onboarding wizard asks for the key.
- **Terminal, theirs.** Print this command with `PASTE-KEY-HERE` left in
  it, and have the student replace the placeholder and run it in their
  own terminal. Do not run it for them and do not watch for the value.

  Substitute the real instance URL when you print it. Nothing exports
  `$FOUNTAIN_URL`, so a pasted `$FOUNTAIN_URL` is an empty string.

  ```sh
  curl -X PUT "http://localhost:4000/api/account/inference-credentials/anthropic_api_key" \
    -H "Authorization: Bearer $(awk -F'"' '/api_key/{print $2; exit}' ~/.fountain/credentials)" \
    -H 'Content-Type: application/json' -d '{"value":"PASTE-KEY-HERE"}'
  ```

  A `200` means stored and validated against the provider. A `422` means
  the provider rejected it, re-paste. Then close the wizard so a later
  browser visit does not re-enter it.

  ```sh
  curl -X POST "http://localhost:4000/api/account/onboarding/complete" \
    -H "Authorization: Bearer $(awk -F'"' '/api_key/{print $2; exit}' ~/.fountain/credentials)"
  ```

You may verify either way yourself. `GET /api/account/inference-credentials`
reports only set or not-set per provider, never a value, and the check
script reports it as `fountain.inference_set`.

## 8. Verify done when

Done when the check shows a water park checkout, `fountain.logged_in`
true (it is an authenticated call now, a stale credentials file cannot
pass it), `inference_set` true, `runner_online` true when the stack's
runner is the provider, and, for self-paced, Floci reachable. If anything is false, say
which and stop. Nothing in the lessons works around a missing Fountain
or a missing key.

## 9. Record and hand off

**confirm**, then write `.waterpark/profile.json` at the checkout root.

```json
{"mode":"self-paced","waterpark_root":"…","fountain_url":"…","email":"their@email","floci":true,"completed":["start"]}
```

Say the next step is the Fountain course, lesson 1, Four primitives
(https://intentius.io/waterpark/courses/fountain/01-four-primitives/), and
that its skill reads this profile.
