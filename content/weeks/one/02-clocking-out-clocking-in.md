---
title: "Clocking out, clocking in"
id: "F2"
shift: 2
weight: 2
subtitle: "the sandbox lifecycle"
summary: "the sandbox lifecycle"
today: "Watch your co-hire's computer park when idle and wake with its memory intact, then learn which bound keeps the memory and which does not: suspend keeps the disk; the 24-hour ceiling destroys it (the transcript survives and the conversation stays resumable, but the next turn starts fresh)."
done_when: "You have watched a sandbox suspend and wake with the file still there, and can say what survives suspend, a reclaim, and `terminate`."
clock_in: "shift 1"
rule: "The computer is the co-hire's memory; the transcript is the park's record."
---

## Steps

1. Start a shift; ask the co-hire to write a file.
2. Wait past the idle timeout (or lower `SANDBOX_IDLE_TIMEOUT_MINUTES` on a self-hosted instance); watch the status go to suspended.
3. Prompt again. The file is still there.
4. Read the lifecycle: `pending -> running -> idle -> running`, `failed`, `terminated`; the max-lifetime reclaim and why the next turn after it answers without the earlier ones.

## Self-paced

Any provider. On your own truck (shift 10) there is nothing to park.

## With the shift lead

Lower the timeout beforehand so the suspend happens inside the shift.

## Back office

Fountain ADR 0017 (suspend idle sandboxes); `docs/primitives.md`.
