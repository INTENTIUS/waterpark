---
title: "Who works here"
id: "I2"
shift: 2
weight: 2
subtitle: "personas and principals"
summary: "personas and principals"
today: "Add the people and the machines. Humans get permission sets, workloads get roles, nobody gets an IAM user; grants are typed access levels with an optional `expires`. Put `tickets-api`, `tickets` and `rides-board` in as one near-data leaf file each."
done_when: "A sibling copy works, a misspelled persona is a type error, an IAM user fails lint; an expired grant will surface as drift in shift 7."
clock_in: "shift 1"
rule: "Named secrets, least privilege (handbook V)."
properties: ["V"]
closes: ["P2", "P3"]
---

## Steps

1. The archetype set from [personas](../../docs/design/personas.md): `developer`, `operator`, `auditor`, `service`, `deployer`; human → permission set, workload → role.
2. Grants as access levels × resource, expanded at synth; `expires` as a first-class field.
3. Add `tickets-api` by copying `rides-board` and editing typed fields; misspell a persona and read the type error.
4. An IAM user in a leaf file: lint fails it (decision 5).

## Self-paced

The human half (permission sets) synthesizes but cannot deploy to Floci (no Identity Center); the workload half can.

## With the shift lead

Same, except the human half deploys for real in shift 4.

## Back office

[issues](../../docs/issues.md) A4, A5; decision 5.
