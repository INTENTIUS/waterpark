---
title: "Start here"
summary: "What you need, how long it takes, self-paced or live."
weight: 0
skill: "skills/start"
---

## What you need

{{< todo "setup list, verified on a clean machine" >}}

- A checkout of this repo (`git clone https://github.com/INTENTIUS/waterpark`). The skills, the check scripts, your progress file, the exercises and the class stack live in it. You do not need a repo of your own.
- Docker, unless you are live with a Fountain URL from the facilitator. Docker Desktop on macOS and Windows (WSL 2 backend), Docker Engine on Linux.
- Then one shot. `just up` starts Fountain (with its database), Floci and the sandbox runner from `compose/`. `just register you@example.com 'password'` makes your account on the local instance and logs the CLI in. `just runner` starts the sandboxes. An inference key goes in once, in the browser onboarding.
- Live with a URL instead. Install the Fountain CLI (`brew install BinaryBourbon/tap/fountain` on macOS, the release binary on Linux, WSL 2 or the web UI on Windows) and register on the class instance.
- About ten minutes, once.

## Self-paced or live

Every lesson has both. Self-paced is you, a laptop and Floci, and each lesson says what Floci cannot show. Live is a facilitator at a checkpoint and a room watching or following. The [live session guide](docs/demo/) has the playlists.

## Order

[Fountain](courses/fountain/) first, about four hours self-paced. Then [the IAM repo](courses/iam/), about seven and a half. Each lesson opens with a card that names the properties it demonstrates, the goal, how you know it worked, and which lesson to restart from if it breaks.
