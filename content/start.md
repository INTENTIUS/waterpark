---
title: "Start here"
summary: "What you need, how long it takes, self-paced or live."
weight: 0
skill: "skills/start"
---

## What you need

{{< todo "setup list, verified on a clean machine" >}}

- A checkout of this repo (`git clone https://github.com/INTENTIUS/waterpark`). The skills, the check scripts, your progress file and the exercises live in it. You do not need a repo of your own. The site also runs offline with `docker run --rm -p 8080:80 ghcr.io/intentius/waterpark`.
- Docker. Docker Desktop on macOS and Windows (WSL 2 backend), Docker Engine on Linux. Fountain's server runs only as a container.
- A Fountain instance you are logged in to. Self-hosted is `docker compose up -d` in a Fountain checkout, then `FOUNTAIN_BASE_URL=http://localhost:4000 fountain auth login`, once. The CLI remembers the URL after that. The CLI ships for macOS and Linux. On Windows use it in WSL 2 or use the web UI and `curl`. Register in the browser first, then log in. An inference key goes in during onboarding. Conversations need a sandbox provider, a sprites.dev token in `.env` or `SANDBOX_PROVIDER=runner` plus `fountain runner` on your machine.
- For self-paced, Floci, either the `floci` CLI (Homebrew, install script, PowerShell script or Scoop) with `floci start`, or `docker run -d -p 4566:4566 floci/floci:latest`. No AWS account. For live, a facilitator brings real sandbox accounts.
- About ten minutes, once.

## Self-paced or live

Every lesson has both. Self-paced is you, a laptop and Floci, and each lesson says what Floci cannot show. Live is a facilitator at a checkpoint and a room watching or following. The [live session guide](docs/demo/) has the playlists.

## Order

[Fountain](courses/fountain/) first, about four hours self-paced. Then [the IAM repo](courses/iam/), about seven and a half. Each lesson opens with a card that names the properties it demonstrates, the goal, how you know it worked, and which lesson to restart from if it breaks.
