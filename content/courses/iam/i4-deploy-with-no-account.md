---
title: "Deploy with no account"
number: "I4"
weight: 5
theme: "Accessible Ops XI (the live system is the truth). There is no state file; chant reads back from the live estate. Solo, \"live\" is Floci; with a group, it is a real sandbox account (decision 27)."
summary: "Accessible Ops XI (the live system is the truth). There is no state file; chant reads back from the live estate. Solo, \"live\" is Floci; with a group, it is a real sandbox account (decision 27)."
properties: ["XI"]
closes: ["P6 (part)"]
builds_on: ["I3", "F3"]
---

## Outcome

The baseline, personas and a principal reach CREATE_COMPLETE.

## Steps

1. Solo: `floci start`, `eval $(floci env)`, `just local-up` (A13).
2. Live: the plan and apply roles from I6 are not built yet; for this
   lesson the facilitator applies with a bounded account credential and
   says so.
3. Read a deployed role back: the source predicted it.
4. Note what Floci cannot do: Organizations, Identity Center, Access
   Analyzer. Everything else in this lesson is real on both paths.

## Done when

CREATE_COMPLETE and a read-back that matches the source.

## Solo

Floci, zero cloud credentials; the teammate variant (F3) holds
nothing but the local endpoint.

## Live

Real account; checkpoint `I4` is a deployed estate, so later
lessons can start from a live one.

## Depth

issues A13; [design/multi-account.md](../../docs/design/multi-account.md)
item 3.
