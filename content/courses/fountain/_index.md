---
title: "Fountain"
kicker: "Course 1 · start here"
weight: 1
summary: "The agent side. Primitives, lifecycle, egress, credentials, the team, schedules, driving an agent from an app, the propose loop interactive and ambient, the self-hosted runner, and the gate Fountain does not have."
video:
  provider: todo
  title: "course intro"
  length: ""
---

## Context

- The course demonstrates the properties on the agent runtime. An agent is the newest hire. The lessons cover what its sandbox can reach, what it holds and what it may do.
- Lessons 8 and 9 build up to [the propose loop](../../propose-loop/), abstracted from Mend, Rounds and dns-desk. That page is their depth.
- The course needs a Fountain instance with an inference key and the water park checkout. Self-hosted is fine. Containment claims need a hosted sandbox provider.

## Intro

Eleven lessons take an Environment, an Agent and a Conversation from a single apply to a team you can talk to.

Four primitives opens the CLI and shows what those objects hold. The sandbox lifecycle follows one conversation from a fresh sandbox to suspension and back, and traces what survives a restart. The egress allowlist locks a sandbox down to named hosts and proves the lock holds. Credentials and vaults cover the two places secrets live and which one wins when both set the same key.

The team turns a conversation into a teammate with its own thread, and schedules puts a cron on top of it so the teammate speaks without being asked. Driving an agent from an app leaves the web UI behind and calls the same API from your own code.

Lessons 8 and 9 build the propose loop, first as something you trigger by hand, then as something that runs on its own from an event. Both are abstracted from real systems, Mend, Rounds and dns-desk, and the propose loop page is where that depth lives.

The self-hosted runner replaces the hosted sandbox with a container you run yourself, trading egress policy for a laptop you already trust. The course ends with the gate Fountain does not have, and what has to stand in for one.
