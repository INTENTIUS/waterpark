---
title: "Prescriptions"
---

The concrete, checkable pattern the IAM lessons build. Each prescription
carries its conformance check, because a prescription without a check is an
opinion, and names the lesson that closes it. The check is that lesson's
*done when*. The checks are written for Terraform (decision 31). Where a
check needs a real account, the lesson's self-paced section says what Floci
shows instead.

1. **(I1) One resource per file, and the path is the index.** The folder
   structure makes every resource findable by guessing a path, and a
   file's name repeats the address of the one resource inside it. Nothing
   assembles anything, because Terraform already reads the directory.
   *Check:* the checks fail a file holding two `resource` blocks, and fail
   a file whose name does not match the resource address inside it, in the
   editor.
2. **(I1, I2) Leaf files are near-data.** A principal file is a call to
   the persona module plus a list of grants and nothing else. The module
   carries the complexity. A first-time contributor copies a sibling file
   and gets it right.
   *Check:* a new principal is a copied sibling with a few strings
   changed, and an unknown persona name fails `terraform validate` rather
   than applying something surprising.
3. **(I2, I7) Humans get permission sets, workloads get roles.** No IAM
   users and no IAM groups. Grants are typed access levels against a
   resource with an optional expiry, and an expired grant is drift.
   *Check:* an `aws_iam_user` anywhere in the repo fails the checks, and
   an expired grant surfaces in the watch.
4. **(I3) Guardrails fail in the editor.** no-wildcard-action,
   no-open-ingress, boundary-required, no-inline-policy, tag-owner,
   sg-reference-not-cidr. Before review, not after.
   *Check:* every rule has a failing and a passing fixture, and fires in
   the editor through the language server rather than only in CI.
5. **(I6) CODEOWNERS is generated.** Derived from the principal files it
   routes, with guardrail paths routed to platform by rule, and the
   emitted file is drift-watched.
   *Check:* adding a principal reroutes its review with no CODEOWNERS
   edit, and a hand edit is flagged within one watch cycle.
6. **(I4, I6) The PR check stack is credential-free until merge.** PR
   events run a plan against Floci plus the full check pack with no cloud
   credential, and the access delta renders on the PR. Live proofs run
   after the merge queue or behind a label a maintainer applies.
   *Check:* a fork PR cannot reach any credentialed job, proven by a
   test.
7. **(I5, I6) Three credential tiers, never mixed.** Plan reads, apply
   writes and runs only in gated jobs on protected branches, and org
   touches the management account and is used most narrowly. The apply
   role carries its own permission boundary, because the system must not
   be able to escalate itself.
   *Check:* the apply role cannot detach its own boundary, proven by a
   proof check.
8. **(I8) Delegation is boundary-conditioned, twice.** A satellite's
   deploy credential may create roles only when `iam:PermissionsBoundary`
   equals the central ARN, and the checks enforce the same thing at build.
   *Check:* strip the boundary and it is refused by the checks at build
   and by IAM at apply, independently, with nobody from platform
   involved.
9. **(I10) Break-glass is three layers.** The grant carries cloud-side
   expiry, a scheduled cleanup removes the artifact, and the watch flags
   leftovers.
   *Check:* kill the cleanup mid-grant and access still ends at the
   expiry.
10. **(I8) Guardrails roll out as a warning first.** A new rule lands as a
    warning in a minor version of the shared module and becomes an error
    only in a major one, with shrink-only baselines for what already
    violates it.
    *Check:* an upgrade that adds a rule cannot break a consumer without a
    warning cycle first.
11. **(I7) Drift is watched and reconciled.** A scheduled
    `terraform plan -detailed-exitcode` over every workspace, and
    reconciliation is one owned-only PR per resource that restores what
    the repo declares. Keeping an out-of-band change instead means a human
    writes it into the file, because restoring is automatic and adopting
    is not.
    *Check:* a hand-edited owned security group is flagged within one
    cycle, and the reconcile PR touches only the owned change.
12. **(I9) Federation trust is estate, and the issuer is never operated.**
    CI OIDC, Kubernetes service-account and SPIFFE trust anchors in one
    typed form, carrying the strictest checks and the highest drift
    severity in the repo.
    *Check:* a wildcard subject condition fails the checks, and a
    hand-edited trust policy is flagged within one cycle.
13. **(I12, I13) The agent proposes, the pipeline verifies, humans
    approve.** Intake extracts intent, a deterministic path authors the
    edit, and the PR carries the verification. The agent never approves,
    applies or signals a gate, its sandbox holds no cloud credentials, and
    its egress is a default-deny allowlist.
    *Check:* the same command an agent invokes produces the same PR with
    no agent involved, and a refusal names the escalation path.
