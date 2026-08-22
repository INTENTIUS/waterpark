---
title: "One gate in"
id: "I6"
shift: 6
weight: 6
subtitle: "the PR is the only write path"
summary: "the PR is the only write path"
today: "Wire the gate. CODEOWNERS generated from the principal files and watched; branch protection declared; PR checks that hold no credential; the three credential tiers in gated jobs via OIDC (the anchor typed in full in shift 9); Access Analyzer proofs only where an untrusted author cannot trigger them."
done_when: "Adding a principal reroutes review with no CODEOWNERS edit; a hand-edit is flagged within one cycle; a fork PR cannot reach a credentialed job; the apply role cannot detach its own boundary (proof check)."
clock_in: "shift 5"
rule: "One path to prod (handbook IV); attributable (IX); verify the artifact (XIV)."
properties: ["IV", "IX", "XIV"]
closes: ["P5", "P6", "P7"]
---

## Steps

1. Derive CODEOWNERS from the principal files; guardrail paths route to security by rule; emit it and declare it, with branch protection, as watched resources (A20). Add a principal: review reroutes with no CODEOWNERS edit.
2. PR jobs: emulator-backed validation plus the full lint pack, no cloud credential (A12). Prove with a fork PR that no credentialed job is reachable.
3. Wire the three tiers into jobs (A17): plan (read) in the post-merge job, apply (write, bounded since shift 5) only on protected branches, org tier separate and rare. Short-lived via OIDC.
4. CheckNoNewAccess against the base branch in the post-merge job (A3b); a PR widening a policy fails with the verdict rendered.

## Self-paced

Steps 1–2 in full on Floci; steps 3–4 need an account, so read a recorded verdict and say so.

## With the shift lead

Everything real. Open the fork PR, show the job list.

## Back office

[issues](../../docs/issues.md) A20, A17, A12, A3b; decisions 21, 22; [threat model](../../docs/threat-model.md).
