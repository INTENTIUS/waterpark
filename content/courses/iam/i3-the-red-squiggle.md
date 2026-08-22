---
title: "The red squiggle"
number: "I3"
weight: 4
theme: "Accessible Ops II (the same check, left of the commit). The check that draws a squiggle for a human hands the same diagnostic to an agent, at the keystroke."
summary: "Accessible Ops II (the same check, left of the commit). The check that draws a squiggle for a human hands the same diagnostic to an agent, at the keystroke."
properties: ["II"]
closes: ["P4"]
builds_on: ["I2"]
---

## Outcome

The security lint pack: no-wildcard-action, no-open-ingress,
boundary-required, no-inline-policy, tag-owner-required,
sg-reference-not-cidr; rule ids mapped to parliament/cloudsplaining
taxonomies; each with failing and passing fixtures; firing over LSP.

## Steps

1. Write the rules under `.chant/rules/` (A3); chant's audit tier already
   ships WAW056-058 — cover what the catalogs do not.
2. Fixtures per rule, both directions.
3. Open a policy file, type `"Action": "*"`, watch it fail before save,
   with a fix-it.
4. Same file edited by a teammate: the diagnostic in its transcript is the
   one you saw.
5. Point Mend at `pepperoni/access` (F8): `chant audit`'s aws catalog
   reads the synthesized CloudFormation and the repo's own rules are the
   judgement tier. Mend as-is is the interactive audit form on IAM
   ([the propose loop](../../propose-loop.md)).

## Done when

Prescription 4: every rule has both fixtures and fires via
LSP.

## Solo

Any editor with the chant LSP.

## Live

This is the first refusal the room sees; it is in every playlist.

## Depth

issues A3; [design/guardrail-rollout.md](../../docs/design/guardrail-rollout.md)
for how a rule is added later without breaking a consumer.
