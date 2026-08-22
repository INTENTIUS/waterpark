---
title: "The practice pool"
id: "I4"
shift: 4
weight: 4
subtitle: "deploy with no account"
summary: "deploy with no account"
today: "Take the estate to CREATE_COMPLETE. Self-paced, that is Floci: no account, no keys, nothing to leak. With the shift lead, it is a real sandbox account. Either way there is no state file; read a role back and see that the source predicted it."
done_when: "CREATE_COMPLETE and a read-back that matches the source."
clock_in: "shift 3"
rule: "The live system is the truth (handbook XI)."
properties: ["XI"]
closes: ["P6 (part)"]
---

## Steps

1. Self-paced: `floci start`, `eval $(floci env)`, `just local-up` (A13).
2. With the shift lead: the plan and apply roles from shift 6 are not built yet; the lead applies with a bounded account credential and says so.
3. Read a deployed role back: the source predicted it.
4. Note what the practice pool cannot do: Organizations, Identity Center, Access Analyzer. Everything else in this shift is real on both paths.

## Self-paced

Floci, zero cloud credentials; the co-hire variant (week one, shift 3) holds nothing but the local endpoint.

## With the shift lead

Real account; checkpoint `I4` is a deployed estate, so later shifts can start from a live one.

## Back office

[issues](../../docs/issues.md) A13; [multi-account](../../docs/design/multi-account.md) item 3.
