# water park — issue breakdown

Filed 2026-07-28 (gating leans confirmed — plan.md open questions 2/4/5
settled by lean). This doc remains the design source; the GitHub epic
issue carries the live checklist. Issues marked **needs-design** carry
open sub-items in their linked design doc.

## Epic

**water park — cross-cloud IAM/security kit on chant.** Central
one-type-per-file repo, PR-driven, drift-watched, gated Ops, satellite-repo
enablement, agent concierge. Tracks A (AWS core), B (cross-cloud fan-out),
C (satellites), D (agentic).

## Track A — central repo, AWS first

**A1. Repo skeleton.**
`chant.config.ts` (aws + temporal lexicons, ownership marker, buildParams),
`src/` layout per plan, justfile, vitest, npm consuming published chant.
AC: fresh clone installs, `just check` green, `chant build` synthesizes an
empty-but-valid baseline stack.

**A2. Layout lint rules.**
`.chant/rules/one-type-per-file.ts` and `path-matches-name.ts`.
AC: a file with two declarables fails lint; a principal file whose path
disagrees with its logical name fails; both with fix-it messages pointing at
the convention doc. (Packaging decision — open question 1 — does not block
this; rules land in-repo first.)

**A3. Security lint pack.**
no-wildcard-action, no-open-ingress (0.0.0.0/0 outside an allowlist),
boundary-required, no-inline-policy, tag-owner-required,
sg-reference-not-cidr. Rule IDs mapped to established finding taxonomies
(parliament / cloudsplaining) per landscape.md, the GHA0xx/WGL0xx catalog
pattern.
AC: each rule has a failing and passing fixture; rules fire in editor via
LSP, not only in CI; catalog doc cross-references the upstream finding ids.

**A3b. Access Analyzer proof checks.**
Live post-synth checks calling IAM Access Analyzer custom policy checks:
CheckNoNewAccess against the base branch's synthesized policies,
CheckAccessNotGranted for a declared forbidden-actions list, public-access
checks. Runs in the PR pipeline with credentials (same wiring as the plan
job); skipped without credentials.
AC: a PR widening a policy fails with the automated-reasoning verdict
rendered on the PR; the forbidden-actions list is a typed config in the
baseline.

**A4. Persona composites. needs-design (open question 2)**
developer / deployer / auditor / break-glass as composites, split human vs
workload: human personas compile to Identity Center permission sets,
workload personas to IAM roles. Grants as typed access levels (Policy
Sentry model) expanded at synth; optional first-class `expires` per grant.
AC: each persona instantiates from params only; permission boundary applied
to every role; an expired grant surfaces as drift in the watch Op; snapshot
tests over synthesized policy JSON.

**A5. OrgPrincipal composite + leaf-file shape.**
One principal per file under `src/principals/<team>/`. AWS leg only. A
human principal (e.g. `payments`) emits Identity Center permission-set
assignments; a workload principal (e.g. `payments-api`) emits a role with
the boundary. No IAM users or groups (decision 5).
AC: a new principal is addable by copying a sibling file and editing typed
fields; wrong persona name is a type error; human synth emits assignments,
workload synth emits role + boundary; demo-org.md names used throughout.

**A6. Baseline component. needs-design (open question 4)**
Permission boundaries, org policy set (SCPs + RCPs + declarative policies),
account password/MFA policy, default-deny SGs, forbidden-actions list
consumed by A3b. Coexistence seam documented for org-formation shops.
AC: deploys to Floci and a real account; every other stack references the
boundary by deterministic name, no hardcoded ARNs.

**A7. Typed network layer.**
SG composites with intent-level API (allowFrom(otherSg, port)), leaf files
one SG per file.
AC: raw CIDR ingress fails lint unless allowlisted; cross-SG references
resolve by deterministic name.

**A8. Drift watch + reconcile Ops.**
`wp-watch` (diff --live on cron, every resource the repo owns) and
`wp-reconcile` (owned-only cloud-to-code PRs). Direct port of the loomster
pair, scoped to security resources.
AC: hand-edit an owned SG in a live account (or Floci), watch flags it
within one cycle, reconcile opens a PR containing only the owned change.

**A9. Break-glass Op. needs-design (open question 5)**
Gated Temporal Op: approval gate (pluggable signal source — CLI, CI, or a
Slack webhook forwarding the signal), timed elevated grant, revocation as
saga compensation, plus a hard TTL on the grant itself. Scoped per
landscape.md: no JIT-catalog UX; Identity Center shops get a documented
TEAM interop note instead of a replacement.
AC: approve path grants and auto-revokes on schedule; kill the worker
mid-grant and revocation still occurs (compensation or TTL); every
transition lands in the audit trail.

**A10. Offboard Op (AWS leg).**
Remove a principal from every stack that references it, as one gated run.
AC: offboarding a demo principal removes role, group memberships, and SG
references in a single PR + apply; graph shows zero remaining references.

**A11. Access-review Op.**
Quarterly report artifact: every principal, its personas, its reachable
resources, last-changed from git, expired/expiring grants, satellite
context-package versions. Shaped as SOC 2 access-review evidence (the
spreadsheet this replaces).
AC: runs on the local executor with no Temporal; output is a single
reviewable artifact a compliance reviewer accepts; scheduled CI workflow,
opt-in gated like loomster's.

**A16. Rotation Op.**
Rotate any static credentials the estate declares (the break-glass
signing material, any unavoidable access keys, KMS where relevant).
Loomster's rotate pattern scoped to the security estate.
AC: gated run rotates and verifies; nothing static in the estate is
older than the policy window without a finding.

**A17. Threat-model hardening.**
Implement threat-model.md's settled items: apply-role permission boundary
(with A6), OIDC credential wiring per tier, guardrail-path CODEOWNERS +
high-severity rendering, branch-protection-as-code for the repo itself.
AC: the apply role cannot detach its own boundary (proven by A3b's
CheckAccessNotGranted); a PR touching `.chant/rules/` renders
high-severity; repo branch protection is declared and drift-watched.

**A18. Trust layer. needs-design (design/workload-identity.md)**
`src/trust/` — federation trust as estate: one typed form for CI OIDC,
k8s service-account, and SPIFFE issuers, serialized to AWS OIDC providers
+ role trust policies (Roles Anywhere documented as the X.509 variant).
Strictest lint (pinned issuer/audience, no wildcard subject or SPIFFE
path) and top drift severity. BYO-issuer per decision 13.
AC: a workload principal declares a SPIFFE ID or k8s/CI subject and its
AWS leg synthesizes the federation trust; a wildcard subject condition
fails lint; a hand-edited trust policy is flagged by the watch within one
cycle.

**A12. Generated CI.**
github/gitlab/forgejo pipelines from the component graph, gated deploy,
scheduled watch/reconcile/access-review workflows, validate-on-drift jobs.
AC: `just github-validate` (and gitlab/forgejo) pass; runtime E2E via act /
gitlab-ci-local against Floci.

**A13. Local path.**
Full kit deploys to Floci with no AWS account, `just local-up`.
AC: baseline + personas + a demo principal reach CREATE_COMPLETE locally;
drift demo (A8) runnable locally.

**A14. Adoption seams + carve path. needs-design (open question 6)**
reference-existing on boundaries, zones, and pre-existing roles; documented
`chant carve` path from Terraform-managed IAM.
AC: a demo adopting a pre-existing role and SG deploys with zero composite
edits; carve walkthrough doc validated against a sample TF state.

**A15. SKILL.md + docs site.**
Agent capability map, docs site (Astro Starlight like loomster), the
pattern doc that names the central-repo shape, and the no-write-GUI
principle written down (open question 8 resolved in prose).
AC: from a bare checkout an agent can answer "add read access to bucket X
for team Y" with the correct file path and PR flow.

## Track B — cross-cloud fan-out

**needs-design (open question 9)** — all of Track B is gated on
cross-cloud persona equivalence ([design/personas.md](design/personas.md)
item 4).

**B1. GCP leg.** OrgPrincipal grows a gcp service-account + IAM-binding leg;
gcpApply local path.
**B2. Azure leg.** Azure RBAC assignment leg; azApply local path.
**B3. K8s + code-host legs.** K8s RBAC plus github/gitlab/forgejo team and
repo access as principal legs.
**B4. Cross-cloud offboard demo.** A10 extended across every leg; the
flagship demo and docs page.

AC pattern for all four: one leaf file, N clouds; the persona archetype maps
to an equivalent grant on each leg; offboard removes all legs in one run.

## Track C — satellite repos + PR automation

Design source: [pr-automation.md](pr-automation.md) (the five primitives,
the compiled-runner position, the chant-side epic).

**C1. Refs module spike. needs-design (open question 3)**
Decide hand-written vs generated vs chant feature. Output is a decision doc
plus, if warranted, a chant issue for typed component-output export.

**C2. Org context package.**
`@org/waterpark-context` bundling the chant.config preset, naming/tagging
helper, guardrail lint rules (re-export shims into `.chant/rules/` until
chant has rule packages), and the typed refs module per C1.
AC: a new satellite is `package.json` (one dep) + a three-line
`chant.config.ts` + one resource file, and `chant lint`/`build` enforce
the full org guardrail set; a package upgrade adding a rule cannot break a
satellite without a warn cycle (design/guardrail-rollout.md).

**C3. Satellite example repo.**
An app-team monorepo consuming the context package, declaring app-scoped
resources inside the guardrails, running generated PR CI.
AC: PR in the satellite fails on a guardrail violation (e.g. open ingress)
without any central-team involvement; deploys against Floci end to end.

**C4. PR automation adoption.**
As the chant-side PR epic lands (renderers, PrPlanComment, `pullRequests`
generator option, freshness digest), wire it through central and satellite:
plan presented per platform, gates on the native primitive, applies
serialized, semantic access-delta rendering for IAM change sets, and
Op-manifest diffs on PRs touching `ops/` (a weakened break-glass gate or
TTL renders high-severity).
AC: the pr-automation.md water-park flow works end to end on all three CI
providers against Floci; a security-relevant PR shows "grants X on Y to
team Z" rather than a JSON diff; a PR removing an Op approval gate is
flagged loudly on the PR.

**C5. Runner requirements doc.**
Not a runner. A requirements capture for whatever the compiled story cannot
do (cross-repo orchestration, richer interactivity), accumulated from C1–C4
friction, filed on chant when concrete.

## Track D — agentic

Design source: [design/agentic.md](design/agentic.md). Depends on A15
(SKILL.md) and the threat-model agent boundary; D1 unblocks the rest.

**D0. Domain verbs.**
`wp-request` intent Op (structured intent → deterministic leaf-file edit
→ local lint + proof → PR), access lens + lifecycle projections
(reachability, expiring, offboard-preview), and the A11 index artifact as
the Q&A source. File the chant gap: project-local MCP tools
(`.chant/tools/` analog of `.chant/rules/`).
AC: `chant run wp-request` with typed args produces the same PR the
agent flow produces; the reachability question is answered by a
projection, not a graph walk; verbs are callable without any agent.

**D1. Concierge environment + Q&A/request flows.**
The reference Fountain Environment manifest in-repo (water park checkout,
SKILL.md, chant MCP, plan-tier read-only creds, `egress_only`), plus
SKILL.md hardening for ladder levels 1–2. Flows terminate in D0's verbs —
the agent extracts intent, the Op authors.
AC: `fountain apply` stands up the concierge; "who can reach the invoices
bucket?" answers from the D0 projection; "payments-api needs read on the
invoices bucket" yields a correct one-file PR via `wp-request` that
passes lint and CheckNoNewAccess with no human edit (flume scenario 1 and
the Q&A variants); a boundary-exception request gets a directed refusal
with the escalation path.

**D2. Explain agents.**
Drift/reconcile PR annotation (CloudTrail: who, when) and reviewer-side
commentary on human PRs, layered on the deterministic rendering, labeled
as commentary. needs-design: CloudTrail credential scope (agentic.md
item 2).
AC: flume scenario 2's reconcile PR carries an accurate who/when
annotation; commentary is visually distinct from the deterministic plan.

**D3. Hygiene agent.**
Scheduled: Access Analyzer unused-access findings + expiring grants →
burndown PRs, volume-capped. needs-design: cadence/volume (agentic.md
item 3).
AC: an unused grant in the demo estate becomes a removal PR with the
finding cited; PR volume respects the cap; no PR for foreign resources.

## Chant-epic dependencies (Track C ↔ pr-automation.md epic)

| water park issue | needs chant epic items |
|---|---|
| C2 (context package) | 8 (rule packages — shims until then) |
| C4 plan/present/gate | 1–5 |
| C4 Op-manifest + semantic | 9; 11–12 for drift-aware plan + provenance |
| A17 high-severity rendering | 9 (or interim path-based rendering) |
| C5 | none — accumulates from friction |

## Filing order

Gate cleared 2026-07-28: leans in docs/design/ adopted for questions 2, 4,
and 5. Question 3's spike is C1 itself; question 9 keeps Track B
needs-design until design/personas.md item 4 settles the human half.
