# Threat and credential model

water park's write path to org IAM runs through a git repo and its CI.
That is the point, and it is also the attack surface. Scaffold —
sections marked *open* need design before Track A files.

## Assets

The repo controls, directly or transitively: every managed IAM role and
permission set, the org policy layer, security groups, and the apply
credentials. Compromising the merge path or the apply credentials is
equivalent to compromising org IAM. The repo is the crown jewels — not
a reason to avoid the pattern (GUIs and tickets have the same power
with less audit), but it must be stated.

## Trust boundaries

1. **The code host.** Merge rights are grant rights on the estate.
   Account security (MFA, branch protection, no force-push, signed
   commits *open*) is part of the posture; the code-host config itself
   should be managed — the code-host lexicons can declare branch
   protection and CODEOWNERS as watched resources.
2. **The CI runner.** A compromised runner in an apply job is full
   compromise. Mitigations: OIDC short-lived credentials, apply only
   from protected branches, no apply credentials in PR-triggered jobs,
   self-hosted posture *open*.
3. **Temporal.** A forged approval signal is an approval. Signal
   authentication *open*.
4. **The context package registry.** A poisoned release weakens every
   satellite's guardrails. Provenance/signing *open*.
5. **The concierge agent.** An agent authors PRs from plain-language
   requests ([design/agentic.md](design/agentic.md)). It is an untrusted
   author and its sandbox is untrusted compute: assume everything
   readable inside is exfiltrated. So the sandbox holds no cloud
   credentials and is never a federation subject (decision 15); its
   verbs are served by a chant MCP process outside the boundary, holding
   the plan-tier credential behind a network-bound trust anchor, itself
   a water park principal. The sandbox receives only a
   conversation-scoped verb-API token, and its egress is a default-deny
   allowlist naming the verb service and the code host. Request text is
   a prompt-injection surface — tolerable because the verification stack
   treats agent PRs exactly like human PRs. The requester's identity is
   a declared claim (decision 17): a forged one yields a PR naming the
   wrong asker — reviewer-facing social engineering, not escalation,
   since CODEOWNERS approval is still what applies anything.

## Attack paths and mitigations

| Path | Mitigation |
|---|---|
| Over-broad PR merged by tired reviewer | lint in editor, CheckNoNewAccess proof (A3b), generated CODEOWNERS (decision 21) |
| Plan credential exercised by an untrusted PR author | decision 22 — PR-time validation is credential-free; proofs run post-merge-queue or behind a maintainer label |
| Review routing quietly changed | CODEOWNERS generated and drift-watched; a reroute is a diff (A20) |
| Satellite mints an over-powered role | lint refuses at build, `iam:PermissionsBoundary` at apply, independently (decision 20) |
| PR weakens the guardrails themselves | guardrail paths require security review and render high-severity (Op-manifest diff for Ops) |
| Out-of-band console change | drift watch on cron; owned-only reconcile PR; SG/trust drift is page-worthy (*open*: severity routing) |
| Stale plan applied after estate moved | manifest-digest freshness check (decision 24); apply refuses |
| Apply-credential theft from runner | OIDC short-lived creds, protected-branch-only apply, the apply boundary |
| Forged Temporal approval signal | *open* — [design/break-glass.md](design/break-glass.md) |
| Prompt-injected agent opens a malicious PR | verified identically to human PRs; no creds in the sandbox; agent cannot approve/apply/signal |
| Forged requester identity | rendered on the PR as an unverified claim (decision 17); enrollment is itself a reviewed change |
| Credential exfiltration from the sandbox | nothing to steal (decision 15); trust anchor pinned to cluster egress so a replayed token fails at STS; per-conversation `sts:SourceIdentity` |
| Orphaned/stale access | first-class `expires` → drift; access-review and offboard Ops |
| water park escalating itself | the apply role's own boundary (decision 12) |

## Credential model

Three tiers, never mixed in one job:

1. **Plan (read).** Describe/list plus Access Analyzer check APIs,
   short-lived via OIDC. Not present in jobs an untrusted author can
   trigger (decision 22).
2. **Apply (write).** Only in gated jobs on protected branches, or held
   by the Temporal worker. The most powerful credential in the org, and
   bounded: its boundary denies boundary-detachment and editing the
   apply role or baseline outside the pipeline, and scopes writes to
   owned resources. Exact policy *open* — belongs in the baseline.
3. **Org (management account).** Org policies and Identity Center;
   separate credential, separate gate, narrowest use
   ([design/multi-account.md](design/multi-account.md)).

Floci needs none of these — every PR validates locally first. All three
are federated short-lived credentials whose trust config is code
(`src/trust/`); a loose subject condition on any federation trust is a
standing backdoor, so those resources get the strictest lint and drift
severity in the estate.

## What water park does not defend against

Root/management-account compromise. A malicious security-team insider
with merge rights on guardrail paths. Cloud control-plane compromise.
Unmanaged (foreign) resources — estate-wide scanning is the chant-audit
funnel. Compromise of an enrolled intake identity: the holder can open
PRs in that principal's name, which CODEOWNERS still has to approve;
revoking it is a PR against the same leaf file.

## Open items

Signed commits policy. Severity routing for drift. Signal
authentication. Registry provenance. The apply boundary policy. The
read-tier action list. These graduate into Track A issues as they
settle; the boundary policy joins A6.
