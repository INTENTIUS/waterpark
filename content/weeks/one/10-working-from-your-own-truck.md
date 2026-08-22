---
title: "Working from your own truck"
id: "F10"
shift: 10
weight: 10
subtitle: "the self-hosted runner"
summary: "the self-hosted runner"
today: "Run `fountain runner` on a machine you own and put a shift on it. Sandboxes are directories, processes stay alive between turns, nothing bills by the minute. Then re-run shift 3's bounce: it doesn't bounce. A runner is trusted mode: no VM isolation, no egress policy, and the daemon has to be online for the sandbox to be reachable."
done_when: "A runner serves a sandbox and you can finish \"on a runner the sandbox is …\" correctly."
clock_in: "shift 3"
rule: "Don't call your own truck a sandbox in front of the crew."
---

## Steps

1. Start `fountain runner` on a machine; register it.
2. Create a shift on it; note the state that stays.
3. Re-run shift 3 step 1 on the runner: the fetch succeeds. Say why.
4. Decide which jobs may run on a runner (your own repo, your own zone) and which must not (anything reading untrusted input while holding a key).

## Self-paced

The free path for people with a spare machine.

## With the shift lead

Never run the access desk on a runner in front of the crew and call it sandboxed.

## Back office

Fountain ADR 0022; ADR 0018 (sandbox provider abstraction); decision 29.
