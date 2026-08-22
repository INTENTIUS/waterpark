---
title: "The shed, the locker, the co-hire, the shift"
id: "F1"
shift: 1
weight: 1
subtitle: "Fountain's four primitives"
summary: "Fountain's four primitives"
today: "Meet the four things Fountain is made of. The shed is the Environment your co-hire works out of: packages, plain env vars, encrypted secrets, a networking policy. The locker is a Vault: keys that override the shed's on collision. The co-hire's job card is the Agent: model, runtime, system prompt, skills, MCP servers. The shift is a Conversation: a running session on a computer of its own. Apply a three-file manifest and get a reply."
done_when: "The conversation replies, and `GET /api/environments` lists secret keys but never values."
clock_in: "none; this is the first shift"
rule: "Everything the co-hire gets is written down first (handbook III, documentation is law)."
---

## Steps

1. Point at an instance (`fountain auth login`) or run one (`docker compose up -d`).
2. Write three documents under `apiVersion: fountain.dev/v1`: an `Environment` (packages, `networking_type`, optionally a secret), an `Agent` (`model`, `runtime`, `environment`, `system`), a `Vault` with one override. `fountain apply -f` the directory.
3. `POST /api/conversations` with the agent id and a prompt; follow the stream until it answers.
4. Do the same three things in the web UI. Same objects, three surfaces (UI, API, CLI); the CLI is a wrapper over the API.

## Self-paced

A self-hosted compose instance and your own inference key is the whole setup.

## With the shift lead

Apply the manifest on screen; the crew applies the same file against their own instance or watches. Five minutes.

## Back office

Fountain `docs/primitives.md`; `cli/README.md`.
