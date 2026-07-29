# Threat and credential model

water park's write path to org IAM runs through a git repo and its CI.
That is the point, and it is also the attack surface. This doc is honest
about both. Scaffold — sections marked *open* need design before Track A
files.

## Assets

The repo controls, directly or transitively: every managed IAM role and
permission set, the org policy layer (SCP/RCP/declarative), security
groups, and the credentials the CI uses to apply changes. Compromising the
repo's merge path or its apply credentials is equivalent to compromising
org IAM. The repo is the crown jewels and must be treated as such — that
is not a reason to avoid the pattern (the alternative write paths, GUIs
and tickets, have the same power with less audit), but it must be stated.

## Trust boundaries

1. **The code host.** Merge rights on this repo are grant rights on the
   estate. GitHub/GitLab/Forgejo account security (MFA/passkeys, branch
   protection, no force-push, signed commits *open*) is part of the
   security posture, not an externality. The code-host config itself
   should be managed — the github/gitlab lexicons can declare branch
   protection and CODEOWNERS as watched resources, closing the loop
   (governance-without-the-state-file applied to the repo's own settings).
2. **The CI runner.** Runs with plan (read) or apply (write) credentials.
   A compromised runner in an apply job is full compromise of the managed
   estate. Mitigations: OIDC-federated short-lived credentials, apply only
   from protected branches/environments, no apply credentials in PR-
   triggered jobs, self-hosted-runner posture *open*.
3. **Temporal.** Ops with gates run here. A forged approval signal is an
   approval. Signal authentication and who may signal *open*.
4. **The context package registry.** Satellites inherit rules from a
   package; a poisoned release weakens every satellite's guardrails.
   Registry account security, provenance/signing *open*.
5. **The concierge agent.** An agent (Fountain-hosted or ad hoc) authors
   PRs from plain-language requests ([design/agentic.md](design/agentic.md)).
   It is an untrusted author by design: plan-tier read-only credentials
   only, its identity is a water park principal via the trust layer, and
   it can never approve, apply, or signal a gate. Request text is a
   prompt-injection surface — tolerable because the verification stack
   (lint, proofs, CODEOWNERS, gates) treats agent PRs exactly like human
   PRs.

## Attack paths and mitigations

| Path | Mitigation |
|---|---|
| Over-broad PR merged by tired reviewer | typed lint in editor, Access Analyzer CheckNoNewAccess proof on PR (A3b), CODEOWNERS routing |
| PR weakens the guardrails themselves (`.chant/rules/`, CODEOWNERS, baseline, break-glass Op) | meta-governance: these paths require security-team review via CODEOWNERS; PRs touching them render high-severity in PR automation (Op-manifest diff for Ops; equivalent loud rendering for rule/baseline paths) |
| Out-of-band change in the console | drift watch on cron; owned-only reconcile PR; SG/trust-policy changes are page-worthy, not just PR-worthy (*open*: severity routing) |
| Stale plan applied after estate moved | plan-digest freshness check; apply refuses and re-plans |
| Apply-credential theft from runner | OIDC short-lived creds, protected-branch-only apply, credential permission boundary (below) |
| Forged Temporal approval signal | *open* — signal auth design in [design/break-glass.md](design/break-glass.md) |
| Prompt-injected agent opens a malicious PR | agent PRs verified identically to human PRs (lint, proofs, CODEOWNERS); agent creds read-only; agent cannot approve/apply/signal |
| Orphaned/stale access accumulating | first-class `expires` on grants → drift; access-review Op; offboard Op |
| water park escalating itself | the apply role carries its own permission boundary (below) |

## Credential model

Three credential tiers, never mixed in one job:

1. **Plan (read).** PR pipelines. Read-only: describe/list plus Access
   Analyzer check APIs. Short-lived via OIDC. Present in PR jobs, so
   assume any PR author can exercise it — it must not read secrets.
2. **Apply (write).** Only in gated jobs on protected branches, or held by
   the Temporal worker for Op-backed applies. The most powerful credential
   in the org, and it must be **bounded**: the apply role itself carries a
   permission boundary that denies boundary-detachment, denies editing the
   apply role and the baseline guardrails outside the pipeline, and scopes
   writes to owned (marker-tagged) resources where the service supports
   condition keys. water park must not be able to escalate water park.
   Exact boundary policy *open* — belongs in the baseline component.
3. **Org (management account).** SCPs/RCPs/declarative policies and
   Identity Center apply from the management or a delegated-admin account.
   Separate credential, separate gate, narrowest use. Design in
   [design/multi-account.md](design/multi-account.md).

Floci needs none of these — every PR validates locally first, which keeps
the read tier out of most pipeline runs entirely (*open*: which checks
genuinely need live credentials on PR vs merge).

All three tiers are instances of the same mechanism: federated short-lived
credentials whose trust config is code. The `src/trust/` layer
([design/workload-identity.md](design/workload-identity.md)) declares that
config for workloads generally — CI OIDC, k8s service-account, SPIFFE —
and the tiers above are its first consumers. A loose subject condition on
any federation trust is a standing backdoor; those resources get the
strictest lint and drift severity in the estate.

## What water park does not defend against

Root/management-account compromise. A malicious security-team insider with
merge rights on guardrail paths (it narrows who, it cannot remove the
role). Cloud-provider control-plane compromise. Unmanaged (foreign)
resources — the watch sees owned resources only; estate-wide scanning is
the auditor's job (chant-audit funnel).

## Open items

Signed commits policy. Severity routing for drift (page vs PR). Signal
authentication. Registry provenance for the context package. The apply
boundary policy document. Read-tier exact action list. These graduate into
Track A issues as they settle; the boundary policy joins A6.
