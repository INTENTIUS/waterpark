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
a service, or writes a file. Those steps are marked **confirm**.

## 1. Say what this is

In three sentences say what the two courses are and that this step gets
two things in place, water park and Fountain. Ask which mode they want,
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

## 3. Run the check

Find out the student's OS and shell first. macOS and Linux use
`bash skills/start/check.sh`. Windows uses
`powershell -ExecutionPolicy Bypass -File skills/start/check.ps1`, or the
bash script inside WSL or Git Bash. Show the output. Both scripts only
read. They report, as JSON, whether this is a water park checkout, which
of `docker`, `fountain`, `floci`, `aws`, `jq` and `gh` are installed with
versions, whether the Fountain URL answers and the CLI is logged in, and
whether Floci answers. Read a script before you run it if you want. Do
not guess at anything it can report.

## 4. Get Fountain

Ask whether the student already has a Fountain instance. If yes, take its
URL and go to the login in 4.3. If no, run one. Fountain's server ships
only as a container image, so the server path is Docker on every OS.

4.1 **Docker is the prerequisite.** Docker Desktop on macOS and Windows,
Docker Engine on Linux. On Windows, Docker Desktop with the WSL 2 backend.
If `docker` is missing, **confirm**, then point the student at the
installer for their OS and wait.

4.2 **Run the server.** The Fountain repo is
https://github.com/BinaryBourbon/fountain. If it is not reachable, stop
and ask the student where their copy is or for an instance URL. Do not
look elsewhere for it. **confirm**, then in a Fountain checkout

```sh
cp .env.compose.example .env      # fill the generated keys as the file says
docker compose up -d
```

The instance is at `http://localhost:4000`. On Windows run these in
PowerShell or WSL. Same commands.

4.3 **Install the CLI and log in.** Offer the path for their OS.

| OS | CLI |
|---|---|
| macOS | `brew install BinaryBourbon/tap/fountain`, or the `fountain-darwin-arm64` / `-amd64` binary from the GitHub release |
| Linux | the `fountain-linux-amd64` / `-arm64` binary from the GitHub release, on the PATH |
| Windows | no native build yet. Use the Linux binary inside WSL 2, or skip the CLI. Everything the CLI does is the web UI or `curl` against `/api`, and the lessons say which. |

**confirm** before installing. Then log in once with the URL in front of
the command. The CLI writes the URL into `~/.fountain/credentials` next to
the key, so every later `fountain` call uses it with nothing else set.
The student types their credentials, not you.

```sh
FOUNTAIN_BASE_URL=http://localhost:4000 fountain auth login        # bash, zsh, WSL
```

```powershell
$env:FOUNTAIN_BASE_URL = "http://localhost:4000"; fountain auth login   # PowerShell, if a CLI is present
```

A student who also uses a hosted Fountain keeps both with profiles.
Add `--profile local` to the login, then set `FOUNTAIN_PROFILE=local`
for the lessons.

4.4 Ask the student to open `http://localhost:4000` once and finish
onboarding. Fountain asks for an inference key there. Never ask for the
key and never store it.

Re-run the check and confirm `fountain.reachable` and
`fountain.logged_in` (or, with no CLI, `fountain.reachable` alone) before
moving on.

## 5. Self-paced extras

For live, skip this step. For self-paced, Floci. Offer two paths and let
the student pick. Both need Docker for the Docker-backed services, and
the Docker path needs nothing else.

**OS install, the `floci` CLI.** **confirm**, then

| OS | Install |
|---|---|
| macOS, Linux | `brew install floci-io/floci/floci`, or `curl -fsSL https://floci.io/install.sh \| sh` |
| Windows | `iwr https://floci.io/install.ps1 \| iex` in PowerShell, or `scoop bucket add floci https://github.com/floci-io/scoop-floci` then `scoop install floci` |

Then `floci start`, and put the AWS variables in the shell.

```sh
eval $(floci env)                                  # bash, zsh
floci env --shell powershell | Invoke-Expression   # PowerShell
```

**Docker only.** **confirm**, then

```sh
docker run -d --name floci -p 4566:4566 floci/floci:latest
```

and set the variables by hand, `AWS_ENDPOINT_URL=http://localhost:4566`,
`AWS_DEFAULT_REGION=us-east-1`, `AWS_ACCESS_KEY_ID=test`,
`AWS_SECRET_ACCESS_KEY=test` (PowerShell uses `$env:NAME = "value"`).

Either way, confirm `floci.reachable` with the check. If `aws`, `jq` or
`gh` are missing, **confirm**, then install them with the package manager
the student already uses (Homebrew, apt, winget or scoop).

## 6. Verify done when

Done when the check shows a water park checkout, Fountain reachable and
logged in (reachable alone on Windows without a CLI), and, for
self-paced, Floci reachable. If anything is false,
say which and stop. Nothing in the lessons works around a missing
Fountain.

## 7. Record and hand off

**confirm**, then write `.waterpark/profile.json` at the checkout root.

```json
{"mode":"self-paced","waterpark_root":"…","fountain_url":"…","floci":true,"completed":["start"]}
```

Say the next step is the Fountain course, lesson 1, Four primitives
(https://intentius.io/waterpark/courses/fountain/01-four-primitives/), and
that its skill reads this profile.
