---
title: "Prescriptions"
---

The concrete, checkable pattern the IAM lessons build. Each prescription
carries its conformance check — a prescription without a check is an
opinion — and names the lesson that closes it; the check is that
lesson's *done when*. The checks are written for the chant backend; the
Terraform variant is appendix lesson IA. Where a check needs a real
account, the lesson's *Solo* section says what Floci shows instead.

1. **(I1) One resource type per file; the path is the index.** Folder
   structure makes every resource findable by path guess; a file's path
   matches its logical name.
   *Check:* lint fails a file with two declarables or a path/name
   mismatch, in the editor.
2. **(I1, I2) Leaf files are near-data.** A principal file instantiates a
   persona and lists grants, nothing else; composites carry the
   complexity. A first-time contributor copies a sibling file and gets
   it right.
   *Check:* a new principal is a copied sibling with typed fields
   edited; a wrong persona name is a type error.
3. **(I2, I7) Humans get permission sets, workloads get roles.** No IAM users,
   no IAM groups. Grants are typed access levels × resource with an
   optional `expires`; an expired grant is drift.
   *Check:* an IAM user fails lint; an expired grant surfaces in the
   watch.
4. **(I3) Guardrails fail in the editor.** no-wildcard-action,
   no-open-ingress, boundary-required, no-inline-policy, tag-owner,
   sg-reference-not-cidr — before review, not after.
   *Check:* each rule has failing and passing fixtures and fires via
   LSP.
5. **(I6) CODEOWNERS is generated.** Derived from the principal files it
   routes; guardrail paths route to security by rule; the emitted file
   is drift-watched.
   *Check:* adding a principal reroutes review with no CODEOWNERS
   edit; a hand-edit is flagged within one watch cycle.
6. **(I4, I6) The PR check stack is credential-free until merged.** PR events
   run emulator-backed validation plus the full lint pack with no
   cloud credential; the semantic access delta renders on the PR; live
   proofs (CheckNoNewAccess) run post-merge-queue or behind a
   maintainer label.
   *Check:* a fork PR cannot reach any credentialed job, proven by
   test.
7. **(I5, I6) Three credential tiers, never mixed:** plan (read), apply
   (write, gated, on protected branches only), org (management
   account, narrowest use). The apply role carries its own permission
   boundary — the system must not be able to escalate itself.
   *Check:* the apply role cannot detach its own boundary, proven by a
   proof check.
8. **(I8) Delegation is boundary-conditioned, twice.** A satellite's deploy
   credential may create roles only when `iam:PermissionsBoundary`
   equals the central ARN; lint enforces the same at build.
   *Check:* strip the boundary — refused by lint at build and by IAM
   at apply, independently, with no platform human involved.
9. **(I10) Break-glass is three layers.** The grant carries cloud-side
   expiry; saga compensation cleans up; the watch flags leftovers.
   *Check:* kill the worker mid-grant — access still ends at the TTL.
10. **(I8) Guardrails roll out warn-minor / error-major** with shrink-only
    ratchet baselines and bot-PR propagation.
    *Check:* an upgrade adding a rule cannot break a consumer without
    a warn cycle.
11. **(I7) Drift is watched and reconciled.** A cron diff over every owned
    resource; reconciliation is one owned-only PR per resource that
    restores the declared state, under Rounds' rules (decision 28); on
    Terraform, drift is detected and a human authors the fix.
    *Check:* a hand-edited owned SG is flagged within one cycle and
    the reconcile PR contains only the owned change.
12. **(I9) Federation trust is estate; never operate the issuer.** CI OIDC,
    k8s service-account, and SPIFFE trust anchors in one typed form,
    with the strictest lint and drift severity in the repo.
    *Check:* a wildcard subject condition fails lint; a hand-edited
    trust policy is flagged within one cycle.
13. **(I12, I13) The agent proposes; the pipeline verifies; humans approve.**
    Intake extracts intent, a deterministic Op authors the edit, the
    PR carries the verification. The agent never approves, applies, or
    signals a gate; its sandbox holds no cloud credentials and its
    egress is a default-deny allowlist.
    *Check:* the same typed command an agent invokes produces the same
    PR with no agent; a refusal names the escalation path.
