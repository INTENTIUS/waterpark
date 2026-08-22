---
title: "An agent gets a computer"
number: "F2"
weight: 3
theme: "A conversation is a sandbox with a disk. Provision, run, idle, suspend (memory kept), destroy at the ceiling (memory lost, transcript kept, conversation resumable)."
summary: "A conversation is a sandbox with a disk. Provision, run, idle, suspend (memory kept), destroy at the ceiling (memory lost, transcript kept, conversation resumable)."
builds_on: ["F1"]
---

## Outcome

You have watched a sandbox park and wake, and know which bound
keeps the agent's memory and which does not.

## Steps

1. Start a conversation; ask the agent to write a file.
2. Wait past the idle timeout (or lower `SANDBOX_IDLE_TIMEOUT_MINUTES` on
   a self-hosted instance); observe `suspended`.
3. Prompt again; the file is still there.
4. Read the lifecycle: `pending -> running -> idle -> running`, `failed`,
   `terminated`; the max-lifetime reclaim and why the next turn starts
   fresh after it.

## Done when

You can say what survives suspend, what survives a reclaim,
and what survives `terminate`.

## Solo

Works on any provider; on a self-hosted runner (F10) there is
nothing to park.

## Live

Lower the timeout beforehand so the suspend happens inside the
lesson.

## Depth

Fountain ADR 0017 (suspend idle sandboxes), `docs/primitives.md`.
