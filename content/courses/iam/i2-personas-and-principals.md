---
title: "Personas and principals"
number: "I2"
weight: 3
theme: "Accessible Ops V (named secrets, least privilege). Humans get permission sets, workloads get roles, nobody gets an IAM user; grants are typed access levels with an optional `expires`."
summary: "Accessible Ops V (named secrets, least privilege). Humans get permission sets, workloads get roles, nobody gets an IAM user; grants are typed access levels with an optional `expires`."
properties: ["V"]
closes: ["P2", "P3"]
builds_on: ["I1"]
---

## Outcome

The persona composites and `OrgPrincipal`; one principal per
file under `src/principals/<team>/`; `tickets-api`, `tickets`,
`rides-board` exist as near-data leaf files.

## Steps

1. The archetype set from [design/personas.md](../../docs/design/personas.md):
   `developer`, `operator`, `auditor`, `service`, `deployer`; human →
   permission set, workload → role.
2. Grants as access levels × resource, expanded at synth; `expires` as a
   first-class field.
3. Add `tickets-api` by copying `rides-board` and editing typed
   fields; misspell a persona and read the type error.
4. An IAM user in a leaf file: lint fails it (decision 5).

## Done when

Prescriptions 2 and 3: sibling copy works, wrong persona is a
type error, IAM user fails lint; an expired grant will surface as drift in
I7.

## Solo

The human half (permission sets) synthesizes but cannot deploy
to Floci (no Identity Center); the workload half can.

## Live

Same, except the human half deploys for real in I4.

## Depth

issues A4, A5; decision 5.
