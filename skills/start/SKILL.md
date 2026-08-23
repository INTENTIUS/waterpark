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
student's profile and the exercises live here. The student does not need
a repo of their own.

## 3. Ask the OS, then run the check

Ask which OS and shell the student is on. macOS, Linux, or Windows, and
bash, zsh, or PowerShell. Do not assume. Then run the check for that OS
and show the output. macOS and Linux run `bash skills/start/check.sh`.
Windows runs `powershell -ExecutionPolicy Bypass -File skills/start/check.ps1`,
or the bash script inside WSL or Git Bash. Both only read. They report
the OS, which package managers are present (brew, apt, winget, scoop and
so on), whether this is a water park checkout, which of `docker`,
`fountain`, `floci`, `aws`, `jq` and `gh` are installed with versions,
whether the Fountain URL answers and the CLI is logged in, and whether
Floci answers. Do not guess at anything the check can report.

## 4. Docker, yes or no

Settle this before installing anything, and say it to the student in
these words. Docker is needed for exactly two things here. Running Floci
the default way, and self-hosting Fountain. Nothing else.

| The student is | Docker |
|---|---|
| live, with a Fountain URL from the facilitator | not needed |
| self-paced, with a Fountain URL | needed, for Floci |
| self-hosting Fountain (facilitators, or a student with no URL) | needed |

If the answer is needed and `docker` is missing, **confirm**, then install
Docker Desktop and wait until `docker version` answers.

| OS | Install |
|---|---|
| macOS | `brew install --cask docker`, or the Docker Desktop `.dmg` from https://www.docker.com/products/docker-desktop/ without Homebrew. Open Docker.app once |
| Windows | `winget install Docker.DockerDesktop`, or the installer from the same page. Choose the WSL 2 backend when asked. Log out and in if it says so |
| Linux | the distribution's `docker` packages, then add the user to the `docker` group |

If the answer is not needed, skip Docker entirely and never mention it
again.

## 5. Fountain

Ask. **Do you have a Fountain URL to use?** In a class the facilitator
gives one. Take it. Only with no URL does the student self-host (5b).

### 5a. With a URL. The CLI, then log in. No Docker.

Install the CLI for their OS. **confirm** first.

| OS | CLI |
|---|---|
| macOS | `brew install BinaryBourbon/tap/fountain`. Without Homebrew, the `fountain-darwin-arm64` or `-amd64` binary from the GitHub release, made executable and on the PATH |
| Linux | the `fountain-linux-amd64` or `-arm64` binary from the GitHub release, on the PATH |
| Windows | no native build yet. The Linux binary inside WSL 2, or no CLI at all. Everything the CLI does is also the web UI or `curl` against `/api`, and the lessons say which |

Register, then log in. If the student has no account on that instance,
they open the URL in a browser and register first. Then, once, with the
URL in front of the command. The CLI writes the URL into
`~/.fountain/credentials` next to the key, so later `fountain` calls need
nothing else set. The student types their credentials, not you.

```sh
FOUNTAIN_BASE_URL=https://the.instance fountain auth login       # bash, zsh, WSL
```

```powershell
$env:FOUNTAIN_BASE_URL = "https://the.instance"; fountain auth login   # PowerShell, if a CLI is present
```

Two instances are kept apart with `--profile <name>` on the login and
`FOUNTAIN_PROFILE=<name>` afterwards. Onboarding in the browser asks for
an inference key. Never ask for the key and never store it.

### 5b. Without a URL. Self-host. Docker.

This is the facilitator's path, or a student working alone. The server
ships only as a container image. The compose file also runs Postgres
(`postgres:16`) and the app migrates its own database at boot, so Docker
is the only thing to install.

1. The Fountain repo is https://github.com/BinaryBourbon/fountain. If it
   is not reachable, stop and ask the student where their copy is, or go
   back to 5a with a URL. Do not look elsewhere for it.
2. **confirm**, then in a Fountain checkout, `cp .env.compose.example .env`,
   fill the generated keys as the file says, and set one of the two
   sandbox-provider lines. Without one the app starts and every
   conversation fails. `SPRITES_TOKEN=` for hosted sandboxes from
   sprites.dev, the default and the one the egress lesson needs. Or
   `SANDBOX_PROVIDER=runner`, no credential, and `fountain runner` runs on
   the same machine once the CLI is in. That is trusted mode on the
   laptop and lesson 3's containment claims do not hold there. Say so.
3. `docker compose up -d`. The instance is at `http://localhost:4000`.
   Same commands in PowerShell or WSL on Windows.
4. Do 5a against `http://localhost:4000`. Register first. The first
   account self-verifies and becomes admin with the compose defaults.
5. If they chose the runner, start it in a second terminal,
   `fountain runner`, and leave it running.

Re-run the check and confirm `fountain.reachable` and `fountain.logged_in`
(reachable alone with no CLI) before moving on.

## 6. Floci, self-paced only

For live, skip. Floci is the local AWS for the lessons. The default is
Docker plus the `floci` CLI, because it is the path a facilitator can
support in a room. The native binary is the fallback for a machine that
cannot run Docker.

**Default. Docker and the CLI.** Docker is installed from step 4.
**confirm**, then install the CLI. macOS and Linux
`brew install floci-io/floci/floci`, or without Homebrew the install
script at https://floci.io/install.sh, which the student runs. Windows
`iwr https://floci.io/install.ps1 | iex`, or Scoop. Then `floci start`,
which launches the Floci container, and the AWS variables into the
shell. `eval $(floci env)` for bash and zsh,
`floci env --shell powershell | Invoke-Expression` for PowerShell.
`floci env` sets `AWS_ENDPOINT_URL` to `http://localhost.floci.io:4566`, a
name for the local machine, and the check reads that variable.

**Fallback. No Docker.** Floci ships the emulator as a native binary on
its releases page. The student downloads it for their OS and runs it. It
listens on 4566. Then the four variables by hand,
`AWS_ENDPOINT_URL=http://localhost:4566`, `AWS_DEFAULT_REGION=us-east-1`,
`AWS_ACCESS_KEY_ID=test`, `AWS_SECRET_ACCESS_KEY=test` (PowerShell uses
`$env:NAME = "value"`). No `floci` CLI is involved.

Confirm `floci.reachable` with the check. If `aws`, `jq` or `gh` are
missing, **confirm**, then install them with a package manager from the
check's list, or from each tool's own site if there is none.

## 7. Verify done when

Done when the check shows a water park checkout, Fountain reachable and
logged in (reachable alone on Windows without a CLI), and, for
self-paced, Floci reachable. If anything is false, say which and stop.
Nothing in the lessons works around a missing Fountain.

## 8. Record and hand off

**confirm**, then write `.waterpark/profile.json` at the checkout root.

```json
{"mode":"self-paced","waterpark_root":"…","fountain_url":"…","floci":true,"completed":["start"]}
```

Say the next step is the Fountain course, lesson 1, Four primitives
(https://intentius.io/waterpark/courses/fountain/01-four-primitives/), and
that its skill reads this profile.
