---
title: "Four primitives"
number: "F1"
weight: 2
theme: "Environment, Vault, Agent, Conversation. Nothing else exists; the team page, schedules and apps are views over these four."
summary: "Environment, Vault, Agent, Conversation. Nothing else exists; the team page, schedules and apps are views over these four."
builds_on: ["F0"]
---

## Outcome

A manifest of three documents applied to a Fountain instance
and a conversation that answers.

## Steps

1. Point at an instance (`fountain auth login`), or run one
   (`docker compose up -d`).
2. Write `Environment` (packages, optional secrets, `networking_type`),
   `Agent` (`model`, `runtime`, `environment`, `system`, optional `skills`
   and `mcp_servers`), and a `Vault` with one override. `apiVersion:
   fountain.dev/v1`; `fountain apply -f` walks the directory.
3. `POST /api/conversations` with the agent id and a prompt; follow the
   stream.
4. Same three things from the web UI, to see they are the same objects.

## Done when

The conversation replies, and `GET /api/environments` lists
secret keys but never values.

## Solo

A self-hosted compose instance and a BYO inference key is the
whole setup.

## Live

Facilitator applies the manifest on screen; the room applies the
same file against their own instance or watches. Five minutes.

## Depth

Fountain `docs/primitives.md`; `cli/README.md`.
