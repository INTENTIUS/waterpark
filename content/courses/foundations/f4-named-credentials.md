---
title: "Named credentials, one per blast radius"
number: "F4"
weight: 5
theme: "Accessible Ops V and VI. Env vars are materialized environment secrets first, then vault secrets, and the vault wins on collision; a vault binds to one conversation when the teammate is created; the agent's `allowed_environment_ids` / `allowed_vault_ids` bound what a caller may attach. So the credential an agent holds is named, scoped to one target, and revoked by removing the vault, and a shared environment holds no secret an agent reading untrusted input should hold. Mend's table is the worked reference: the clone token (read, one repo) lives in that repo's vault; the pull-request token (write) stays in the browser and never reaches the sandbox."
summary: "Accessible Ops V and VI. Env vars are materialized environment secrets first, then vault secrets, and the vault wins on collision; a vault binds to one conversation when the teammate is created; the agent's `allowed_environment_ids` / `allowed_vault_ids` bound what a caller may attach. So the credential an agent holds is named, scoped to one target, and revoked by removing the vault, and a shared environment holds no secret an agent reading untrusted input should hold. Mend's table is the worked reference: the clone token (read, one repo) lives in that repo's vault; the pull-request token (write) stays in the browser and never reaches the sandbox."
properties: ["V", "VI"]
builds_on: ["F3"]
---

## Outcome

Two teammates on one environment with no secrets, two
vaults, neither able to read the other's token; and the credential table
(who / holds / can) for your own scenario. This is the one table the
course reuses: F8 fills it for Mend and the desk, the scenario fills it
for the concierge.

## Steps

1. Put `TARGET=staging` on an environment and `TARGET=prod` in a vault
   bound to the conversation; ask the agent to print it. The vault's
   value.
2. One environment, no secrets. Two vaults, each with a read-only token
   for one repo. Two agents, one vault each. Each prints its environment
   and sees its own token only.
3. Attach a vault to a teammate that already exists: it is rebuilt and
   the thread starts fresh. Say so before you do it.
4. Read Mend's `src/lib/spec.ts`: why the environment description says
   "no credentials belong here", and the trade Mend names when you reuse
   the PR token as the clone token.
5. Write the table for your scenario: one row per credential; who holds
   it, where it lives, what it is for, read or write.

## Done when

The table, with read and write never in the same row.

## Solo

Two fine-grained GitHub tokens are enough.

## Live

Show the vault bound at teammate creation. Three minutes.

## Depth

[design/workload-identity.md](../../docs/design/workload-identity.md)
(the sandbox exception); decision 15; Mend README (the toolkit
environment).
