---
title: "One type per file, the path is the index"
number: "I1"
weight: 2
theme: "Accessible Ops I (honor the lower layer). A stranger reads the source and predicts the CloudFormation from the text alone; a path guess finds any resource."
summary: "Accessible Ops I (honor the lower layer). A stranger reads the source and predicts the CloudFormation from the text alone; a path guess finds any resource."
properties: ["I"]
closes: ["P1", "P2"]
builds_on: ["F1", "I0"]
---

## Outcome

`pepperoni/access` exists: `chant.config.ts`, `src/` layout,
a justfile, tests, an empty-but-valid baseline stack, and the two layout
lint rules.

## Steps

1. Scaffold the repo from scratch (A1): npm consuming published chant,
   `just check` green, `chant build` synthesizes.
2. Add the layout rules (A2): one-type-per-file and path-matches-name,
   with fix-its.
3. Put one resource in the wrong place and in the wrong file; watch both
   fail.
4. `chant build` and read the CloudFormation next to the source.

## Done when

Prescriptions 1 and 2: a file with two declarables fails, a
path/name mismatch fails, both in the editor; a sibling copy with typed
fields edited is a valid new file.

## Solo

Nothing to deploy yet; no Floci needed.

## Live

Checkpoint `I1` is the scaffold; if the teammate stalls, restart
from it.

## Depth

issues A1, A2.
