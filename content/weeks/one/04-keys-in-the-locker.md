---
title: "Keys in the locker"
id: "F4"
shift: 4
weight: 4
subtitle: "named credentials, one per blast radius"
summary: "named credentials, one per blast radius"
today: "Give two co-hires two lockers with one key each and prove neither can see the other's. Env vars are the shed's secrets first, then the locker's, and the locker wins; a locker binds to one shift when the teammate is created; `allowed_environment_ids` / `allowed_vault_ids` bound what a caller may attach. The shed holds no keys, and the key that can write never goes in a locker at all: Mend keeps the clone token (read, one repo) in that repo's vault and the pull-request token (write) in the browser."
done_when: "Two co-hires, two lockers, neither sees the other's key; and the key table for your own job (who / holds / can), with read and write never in the same row. Shift 8 and week two reuse this table."
clock_in: "shift 3"
rule: "Named secrets, least privilege (handbook V); bounded blast radius (VI)."
properties: ["V", "VI"]
---

## Steps

1. Put `TARGET=staging` on the shed and `TARGET=prod` in a locker bound to the shift; ask the co-hire to print it. The locker's value.
2. One shed, no secrets. Two lockers, each a read-only token for one repo. Two co-hires, one locker each. Each prints its environment and sees its own key only.
3. Attach a locker to a teammate that already exists: it is rebuilt and the thread starts fresh. Say so before you do it.
4. Read Mend's `src/lib/spec.ts`: why the shed's description says "no credentials belong here", and the trade Mend names when you reuse the PR token as the clone token.
5. Write the table for your job: one row per key; who holds it, where it lives, what it is for, read or write.

## Self-paced

Two fine-grained GitHub tokens are enough.

## With the shift lead

Show the locker bound at teammate creation. Three minutes.

## Back office

[workload identity](../../docs/design/workload-identity.md) (the sandbox exception); decision 15; Mend README (the toolkit environment).
