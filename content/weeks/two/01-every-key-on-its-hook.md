---
title: "Every key on its hook"
id: "I1"
shift: 1
weight: 1
subtitle: "one resource type per file; the path is the index"
summary: "one resource type per file; the path is the index"
today: "Scaffold `splashdown/access` from nothing and add the two layout rules, so any resource can be found by guessing its path and a file with two things in it fails before it is saved."
done_when: "A file with two declarables fails, a path/name mismatch fails, both in the editor; a sibling copy with typed fields edited is a valid new file."
clock_in: "week one, shift 1 (if the co-hire does the typing)"
rule: "Honor the lower layer (handbook I): a stranger reads the source and predicts the CloudFormation."
properties: ["I"]
closes: ["P1", "P2"]
---

## Steps

1. Scaffold the repo (A1): npm consuming published chant, `just check` green, `chant build` synthesizes an empty-but-valid baseline stack.
2. Add the layout rules (A2): one-type-per-file and path-matches-name, with fix-its.
3. Put one resource in the wrong place and in the wrong file; watch both fail.
4. `chant build` and read the CloudFormation next to the source.

## Self-paced

Nothing to deploy yet; no Floci needed.

## With the shift lead

Checkpoint `I1` is the scaffold. If the co-hire stalls, clock in there.

## Back office

[issues](../../docs/issues.md) A1, A2.
