---
title: "One path to prod"
number: "I6"
weight: 7
theme: "Accessible Ops IV (one path to prod), IX (attributable), XIV (verify the artifact). The PR is the only write path; review routing is generated from the files it routes; PR checks hold no credential; proofs run only where an untrusted author cannot trigger them."
summary: "Accessible Ops IV (one path to prod), IX (attributable), XIV (verify the artifact). The PR is the only write path; review routing is generated from the files it routes; PR checks hold no credential; proofs run only where an untrusted author cannot trigger them."
properties: ["IV", "IX", "XIV"]
closes: ["P5", "P6", "P7"]
builds_on: ["I5"]
---

## Outcome

Generated CODEOWNERS and branch protection, declared and
watched (A20); generated CI for the code host whose PR jobs hold no
credential (A12); the plan, apply and org roles wired into gated jobs via
OIDC (A17; the trust anchor is typed in full in I9); Access Analyzer
proofs post-merge-queue or behind a maintainer label (A3b).

## Steps

1. Derive CODEOWNERS from the principal files; guardrail paths route to
   security by rule; emit it and declare it, with branch protection, as
   watched resources. Add a principal: review reroutes with no CODEOWNERS
   edit.
2. PR jobs: emulator-backed validation plus the full lint pack, no cloud
   credential. Prove with a fork PR that no credentialed job is reachable.
3. Wire the three tiers into jobs: plan (read) in the post-merge job,
   apply (write, bounded since I5) only on protected branches, org tier
   separate and rare. Short-lived via OIDC; the anchor is a minimal
   declaration here and the full typed form in I9.
4. CheckNoNewAccess against the base branch in the post-merge job; a PR
   widening a policy fails with the verdict rendered.

## Done when

Prescriptions 5, 6, 7: reroute without edit, hand-edit
flagged within one cycle, fork PR cannot reach credentials, apply role
cannot detach its boundary (proof check).

## Solo

Steps 1–2 in full on Floci; steps 3–4 need an account, so the
solo path reads a recorded verdict and says so.

## Live

Everything real. Beat: open the fork PR, show the job list.

## Depth

issues A20, A17, A12, A3b; decisions 21, 22; [threat-model.md](../../docs/threat-model.md).
