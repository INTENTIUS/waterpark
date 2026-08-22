---
title: "Your own machine"
number: "F10"
weight: 11
theme: "The self-hosted runner (`fountain runner`): a daemon on a machine you own dials out to Fountain and serves the sandbox contract. Sandboxes are directories, processes stay alive between turns, nothing bills by the minute. Trusted mode only: no VM isolation, no egress policy, and the daemon must be online for the sandbox to be reachable (ADR 0022)."
summary: "The self-hosted runner (`fountain runner`): a daemon on a machine you own dials out to Fountain and serves the sandbox contract. Sandboxes are directories, processes stay alive between turns, nothing bills by the minute. Trusted mode only: no VM isolation, no egress policy, and the daemon must be online for the sandbox to be reachable (ADR 0022)."
builds_on: ["F2", "F3"]
---

## Outcome

A runner serving a sandbox, and a clear statement of what F3
no longer guarantees on it.

## Steps

1. Start `fountain runner` on a machine; register it.
2. Create a conversation on it; note the state that stays.
3. Re-run F3 step 1 on the runner: the fetch succeeds. Say why.
4. Decide which scenarios may run on a runner (your own repo, your own
   zone) and which must not (anything reading untrusted input while
   holding a credential).

## Done when

You can finish the sentence "on a runner the sandbox is
…" correctly.

## Solo

This is the free path for people with a spare machine.

## Live

Do not run the IAM concierge on a runner in front of a room and
call it sandboxed. The honesty line writes itself.

## Depth

Fountain ADR 0022; ADR 0018 (sandbox provider abstraction).
