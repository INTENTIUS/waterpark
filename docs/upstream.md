# Upstream: what water park consumes, and what moved

water park's upstream is two codebases:
[chant](https://intentius.io/chant) (compiler, lifecycle, Ops) and
[Fountain](https://github.com/BinaryBourbon/fountain) (agent runtime).
This doc records what landed since 2026-07-29. Its job under
decision 25: what exists today that the demo can use, and what the
parked kit would inherit.

## chant — 0.33 → 0.44.14

### Landed, and water park had planned to need it

**Graph lenses and `chant search`.** An edge-aware query grammar over
the declared graph, live estate, or a snapshot — "which roles reference
this boundary" is one query. Demotes the A11 artifact from Q&A substrate
to compliance evidence.

**`chant carve`.** The whole chain exists: `advise` ranks a Terraform
estate by peelability, `emit` adopts from `.tfstate` offline, `bridge`
patches the surviving Terraform, `apply` graduates. ~50 AWS types
including the IAM surface. A chant feature water park documents for
orgs that choose to move to the chant backend (A14) — not a path water
park pushes; the Terraform backend is a first-class end state
(decision 23).

**AWS landing-zone governance authoring.** The landing-zone composites
plus `landingZoneConfig()` emitting an OU/account/SCP tree. A6 no longer
starts from an empty file.

**A governance audit tier.** Nine post-synth checks across the cloud
catalogs (WAW056-058 and peers). A3 covers what these do not.

**Organizational policy as post-synth checks.** Project-authored checks
in `lint.policies` plus `policyGate()` as an Op step — the mechanism the
agentic and pr-automation designs assumed. Caveat: under `--sandbox` a
policy reads the project directory only.

**A read path worth trusting for IAM drift.** SigV4, per-type read
routing, physical-identity reads, ambient-resource observation. A8
inherits all of it.

**An apply contract with a conformance harness** plus native appliers
with endpoint overrides — A13's Floci path is the same code path as a
real account.

**Lifecycle detail.** `plan --json` carries the resolved query address;
builds record their lexicon version. Both make the manifest digest
(decision 24) cheaper to build.

**OKF knowledge bundles.** `chant explain --format okf` emits a spec'd,
validated bundle — the candidate format A11 evaluates first.

### The aws-warden problem

In August 2026 chant grew an `aws-warden` — OU tree, SCPs, Identity
Center, org trail, protected break-glass — on a stateless,
ownership-gated reconcile, then removed every warden from the monorepo.
aws-warden had no repo and survives only on an archive branch. The
config producer shipped in the aws lexicon; the reconciler is unowned —
and what it reconciles is the AWS half of water park's charter. Hence
[decision 16](decisions.md): adopt the reconcile on water park's terms —
typed source, the PR as write path, the cycle design and guardrail set
taken verbatim.

### Still missing — water park's filed chant gaps

| Gap | Blocks |
|---|---|
| Lint rule packages (config-declared rule sources) | C2 ships re-export shims |
| Project-local MCP tools (`.chant/tools/`) | D0 verbs surface as skills + Ops, not MCP tools |
| Change-set renderers, plan digest (pr-automation items 1–2) | C4, and the manifest (decision 24) |
| Op-manifest diff | A17 high-severity rendering |
| A step referencing a prior step's output ([chant#1290](https://github.com/INTENTIUS/chant/issues/1290)) | `wp-request` returns its PR URL only as a search attribute |

## Fountain — 0.9 → 0.12+

### Two facts in [design/agentic.md](design/agentic.md) were wrong

**Egress.** `networking_type: limited` with `allowed_hosts` is a
**default-deny egress allowlist**; an empty allowlist denies all egress.
The credential design still assumes exfiltration — the provider-adapter
translation is the weak joint — but the allowlist is a real containment
boundary. **The vault-override gap closed**: an agent carries
`allowed_environment_ids` / `allowed_vault_ids`, checked at conversation
time; restricting who may open conversations is belt-and-braces now.

### New surface water park can use

**The hosted-MCP pattern.** Fountain serves MCP itself, authenticated by
the conversation's sandbox token, the provider credential never entering
the sandbox — the verb-service custody shape of
[decision 15](decisions.md), with working instances to copy.

**The team surface.** Agents as teammates, cron schedules, presence.
D3's hygiene agent has a runtime that already does cadence; D2's explain
agent can be a distinct teammate.

**`GET /api/search`** across conversations with per-turn token usage —
"which requests did the concierge handle this quarter" is a query, not
a log grep.

**Sign in with Fountain** (OAuth 2.0 + PKCE) and the **self-hosted
runner** — for orgs that won't put an IAM concierge on shared
infrastructure.

### What Fountain still does not have

ADR 0016 — a PDP answering allow/deny/escalate per tool call — is
Proposed and unbuilt. Read as confirmation, not blocker:
[decision 14](decisions.md) puts the gate at the PR merge and nowhere
else. The dependency to avoid is designing any part of Track D as if a
runtime-side approval gate were coming.
