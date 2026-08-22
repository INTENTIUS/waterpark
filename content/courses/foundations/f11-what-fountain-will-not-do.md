---
title: "What Fountain will not do for you"
number: "F11"
weight: 12
theme: "There is no approval gate inside the loop. Every runtime runs with its permission prompt bypassed because a headless CLI has no channel back to a human; the audit trail is retrospective by construction; ADR 0016 (governance as an ACP proxy) is proposed and unbuilt. So the gate lives where the write lands: the PR merge, the `APPROVE` message the desk waits for, the server that refuses a proposal."
summary: "There is no approval gate inside the loop. Every runtime runs with its permission prompt bypassed because a headless CLI has no channel back to a human; the audit trail is retrospective by construction; ADR 0016 (governance as an ACP proxy) is proposed and unbuilt. So the gate lives where the write lands: the PR merge, the `APPROVE` message the desk waits for, the server that refuses a proposal."
builds_on: ["F8", "F9"]
---

## Outcome

For each scenario you can point at its gate and say why it is
not in Fountain.

## Steps

1. Read ADR 0016's first two sections.
2. dns-desk: approval is a plain message; enforced by convention today and
   by gates "once those exist" (fountain#643).
3. Mend and Rounds: the gate is the human opening the PR, or the server's
   policy.
4. IAM: decision 14 puts the gate at the PR and nowhere else; design
   nothing as if a runtime-side gate were coming.

## Done when

You can answer "what stops the agent from doing X?" with
the honest answer for each scenario.

## Solo

Reading.

## Live

This is the answer to the room's first governance question; say
it before they ask.

## Depth

Fountain ADR 0016; waterpark decision 14; [upstream.md](../../docs/upstream.md).
