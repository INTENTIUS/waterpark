---
title: "Start here"
summary: "What you need, how long it takes, self-paced or live."
weight: 0
skill: "skills/start"
---

## What you need

{{< todo "setup list, verified on a clean machine" >}}

- A checkout of this repo (`git clone https://github.com/INTENTIUS/waterpark`). The skills, the check scripts, your progress file and the exercises live in it. You do not need a repo of your own. The site also runs offline with `docker run --rm -p 8080:80 ghcr.io/intentius/waterpark`.
- A Fountain instance you are logged in to (self-hosted is fine, `docker compose up -d`, then `fountain auth login`) and an inference key entered in its onboarding.
- Self-paced: Floci (`floci start`); no AWS account. Live: a facilitator brings real sandbox accounts.
- About ten minutes, once.

## Self-paced or live

Every lesson has both. Self-paced is you, a laptop, Floci; the lesson says what Floci cannot show. Live is a facilitator at a checkpoint and a room watching or following; the [live session guide](docs/demo/) has the playlists.

## Order

[Fountain](courses/fountain/) first (about four hours self-paced), then [the IAM repo](courses/iam/) (about seven and a half). Each lesson opens with a card: the properties it demonstrates, the goal, how you know it worked, and which lesson to restart from if it breaks.
