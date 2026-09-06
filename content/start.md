---
title: "Start here"
summary: "What you need, how long it takes, self-paced or live."
weight: 0
skill: "skills/start"
---

## What you need

- A checkout of this repo (`git clone https://github.com/INTENTIUS/waterpark`). The skills, the check scripts, your progress file, the exercises and the class stack live in it. You do not need a repo of your own.
- Docker, unless you are live with a Fountain URL from the facilitator. Docker Desktop on macOS and Windows (WSL 2 backend), Docker Engine on Linux.
- `just`, the command runner behind every command on this page (`brew install just` on macOS, `winget install Casey.Just` on Windows, the release binary from https://github.com/casey/just on Linux).
- Then one shot. `just up` starts Fountain (with its database) and Floci from `compose/`. `just register you@example.com` makes your account on the local instance and logs the CLI in, prompting for the password so it stays out of shell history. `just runner` starts the sandboxes.
- An inference key goes in once, yours. Sign in to the Fountain web UI and open Inference Keys in the left sidebar, not API keys, which lists the CLI key the register script minted. The onboarding wizard may not appear after sign in, and `/onboarding` on the instance URL opens it directly. Either the Anthropic API key slot or the Claude Code OAuth token slot satisfies lesson 1, since the check reports `inference_set` true for either. Or set it yourself with one `curl` you run. The agent never sees it.
- If port 4000 is already taken, `just up` says so. Set `PORT` and `FLOCI_PORT` in `compose/.env` and run it again. Everything else follows those two ports.
- Live with a URL instead. Install the Fountain CLI (`brew install BinaryBourbon/tap/fountain` on macOS, the release binary on Linux, WSL 2 or the web UI on Windows) and register on the class instance.
- About ten minutes, once. Check what you already have with `just doctor` (or, without `just`, `bash skills/start/check.sh doctor`, PowerShell `powershell -ExecutionPolicy Bypass -File skills/start/check.ps1 doctor`), which prints the install line for whatever is missing.

## Self-paced or live

Every lesson has both. Self-paced is you, a laptop and Floci, and each lesson says what Floci cannot show. Live is a facilitator at a checkpoint and a room watching or following. The [live session guide](docs/demo/) has the playlists.

## Order

[Fountain](courses/fountain/) first, about four hours self-paced. Then [the IAM repo](courses/iam/), about seven and a half. Each lesson opens with a card that names the properties it demonstrates, the goal, how you know it worked, and which lesson to restart from if it breaks.
