---
title: "The whistle"
id: "I3"
shift: 3
weight: 3
subtitle: "guardrails that fail in the editor"
summary: "guardrails that fail in the editor"
today: "Write the six guardrails and their fixtures, then type a wildcard action and watch the whistle blow before the file is saved. The check that draws a squiggle for you hands the same diagnostic to your co-hire, at the keystroke. Then point Mend at the repo and see the same findings sorted by fix confidence."
done_when: "Every rule has failing and passing fixtures and fires via LSP."
clock_in: "shift 2"
rule: "The same check, left of the commit (handbook II)."
properties: ["II"]
closes: ["P4"]
---

## Steps

1. Write the rules under `.chant/rules/` (A3): no-wildcard-action, no-open-ingress, boundary-required, no-inline-policy, tag-owner-required, sg-reference-not-cidr; map ids to the parliament/cloudsplaining taxonomies. chant's audit tier already ships WAW056-058; cover what the catalogs do not.
2. Fixtures per rule, both directions.
3. Open a policy file, type `"Action": "*"`, watch it fail before save, with a fix-it.
4. Same file edited by the co-hire: the diagnostic in its transcript is the one you saw.
5. Point Mend at `splashdown/access` (week one, shift 8): `chant audit`'s aws catalog reads the synthesized CloudFormation and the repo's own rules are the judgement tier. Mend as-is is the interactive audit form on IAM.

## Self-paced

Any editor with the chant LSP.

## With the shift lead

The first whistle the crew hears; it is in every playlist.

## Back office

[issues](../../docs/issues.md) A3; [guardrail rollout](../../docs/design/guardrail-rollout.md) for adding a rule later without breaking a consumer.
