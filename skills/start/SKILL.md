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
OS before any command. Docker is not assumed.

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

Docker is not a prerequisite. It is needed only if the student self-hosts
Fountain (step 4b) or runs Floci as a container (step 5). Do not install
it before one of those asks for it.

## 4. Fountain

Ask one question first. **Do you have a Fountain URL to use?** A class
usually does, the facilitator's instance or a hosted one. Take the URL.
If there is none, the student self-hosts, which is Docker.

### 4a. With a URL, the CLI is all they need

Install the CLI for their OS. **confirm** first.

| OS | CLI |
|---|---|
| macOS | `brew install BinaryBourbon/tap/fountain`. Without Homebrew, the `fountain-darwin-arm64` or `-amd64` binary from the GitHub release, made executable and on the PATH |
| Linux | the `fountain-linux-amd64` or `-arm64` binary from the GitHub release, on the PATH |
| Windows | no native build yet. The Linux binary inside WSL 2, or no CLI at all. Everything the CLI does is also the web UI or `curl` against `/api`, and the lessons say which |

Then register and log in. If the student has no account on that instance
yet, they open the URL in a browser and register first. Then, once, with
the URL in front of the command. The CLI writes the URL into
`~/.fountain/credentials` next to the key, so later `fountain` calls
need nothing else set. The student types their credentials, not you.

```sh
FOUNTAIN_BASE_URL=https://the.instance fountain auth login       # bash, zsh, WSL
```

```powershell
$env:FOUNTAIN_BASE_URL = "https://the.instance"; fountain auth login   # PowerShell, if a CLI is present
```

A student who uses two instances keeps both with profiles. Add
`--profile <name>` to the login, then set `FOUNTAIN_PROFILE=<name>`.

Onboarding in the browser asks for an inference key. Never ask for the
key and never store it. Skip to step 5.

### 4b. Without a URL, self-host

The server ships only as a container image, so this path needs Docker.

1. If `docker` is missing, **confirm**, then. macOS `brew install --cask docker`,
   or the Docker Desktop `.dmg` from https://www.docker.com/products/docker-desktop/
   without Homebrew. Windows `winget install Docker.DockerDesktop`, or the
   installer from the same page, with the WSL 2 backend. Linux, the
   distribution's `docker` packages. Wait until `docker version` answers.
2. The Fountain repo is https://github.com/BinaryBourbon/fountain. If it
   is not reachable, stop and ask the student where their copy is, or go
   back to 4a with a URL. Do not look elsewhere for it.
3. **confirm**, then in a Fountain checkout, `cp .env.compose.example .env`,
   fill the generated keys as the file says, and set one of the two
   sandbox-provider lines. Without one the app starts and every
   conversation fails. `SPRITES_TOKEN=` for hosted sandboxes from
   sprites.dev, the default and the one the egress lesson needs. Or
   `SANDBOX_PROVIDER=runner`, no credential, and the student runs
   `fountain runner` on the same machine once the CLI is in. That is
   trusted mode on their laptop and lesson 3's containment claims do not
   hold there. Say so. Then `docker compose up -d`. The instance is at
   `http://localhost:4000`, in PowerShell or WSL on Windows, same commands.
4. Do 4a against `http://localhost:4000`. Register first, the first account
   self-verifies and becomes admin with the compose defaults.
5. If they chose the runner, start it now in a second terminal,
   `fountain runner`, and leave it running.

Re-run the check and confirm `fountain.reachable` and `fountain.logged_in`
(reachable alone with no CLI) before moving on.

## 5. Floci, self-paced only

For live, skip. Floci is the local AWS for the lessons. Ask which way.

- **The `floci` CLI, which runs Floci as a container.** Needs Docker. If
  `docker` is missing, install it as in 4b.1. **confirm**, then install
  the CLI. macOS and Linux `brew install floci-io/floci/floci`, or
  without Homebrew the install script at https://floci.io/install.sh,
  which the student runs. Windows `iwr https://floci.io/install.ps1 | iex`,
  or Scoop. Then `floci start`, and the AWS variables into the shell,
  `eval $(floci env)` for bash and zsh, `floci env --shell powershell | Invoke-Expression`
  for PowerShell. `floci env` sets `AWS_ENDPOINT_URL` to
  `http://localhost.floci.io:4566`, a name for the local machine. The check
  reads that variable.
- **Docker without the CLI.** `docker run -d --name floci -p 4566:4566 floci/floci:latest`,
  then `AWS_ENDPOINT_URL=http://localhost:4566`, `AWS_DEFAULT_REGION=us-east-1`,
  `AWS_ACCESS_KEY_ID=test`, `AWS_SECRET_ACCESS_KEY=test` by hand (PowerShell uses
  `$env:NAME = "value"`).
- **No Docker at all.** Floci also ships the emulator as a native binary on
  its releases page. The student downloads it for their OS and runs it.
  It listens on 4566. Then the same four variables by hand. No `floci`
  CLI is involved.

Confirm `floci.reachable` with the check. If `aws`, `jq` or `gh` are
missing, **confirm**, then install them with a package manager from the
check's list, or from each tool's own site if there is none.

## 6. Verify done when

Done when the check shows a water park checkout, Fountain reachable and
logged in (reachable alone on Windows without a CLI), and, for
self-paced, Floci reachable. If anything is false, say which and stop.
Nothing in the lessons works around a missing Fountain.

## 7. Record and hand off

**confirm**, then write `.waterpark/profile.json` at the checkout root.

```json
{"mode":"self-paced","waterpark_root":"…","fountain_url":"…","floci":true,"completed":["start"]}
```

Say the next step is the Fountain course, lesson 1, Four primitives
(https://intentius.io/waterpark/courses/fountain/01-four-primitives/), and
that its skill reads this profile.
