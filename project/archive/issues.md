**Kit-era doc.** "water park" below names the IAM access-repo kit these
items were filed for; under decision 26 the kit is the IAM scenario and
each item is source material for a lesson. The map:

| Lesson | Items |
|---|---|
| I1 | A1, A2 |
| I2 | A4, A5 |
| I3 | A3 |
| I4 | A13 |
| I5 | A6, A7 |
| I6 | A3b, A12, A17, A20 |
| I7 | A8 |
| I8 | C1, C2, C3, C6 |
| I9 | A17 (rotation), A18 |
| I10 | A9 |
| I11 | A10, A11 |
| I12 | A15, D0, D1 |
| I13 | D3 |
| I14 | C4, C5, E1 |
| I15 | A14, A21 |
| IA | A19, B1–B4, E2, E3; D2 |

Open unknowns ride with their lessons: cross-repo refs (C1, I8),
cross-cloud persona equivalence (Track B, IA), cross-repo reachability
(A11/C6, I8 and I11), the manifest schema (E1, I14). Acceptance criteria
below are each lesson's *done when* in long form.

Filed 2026-07-28; amended 2026-08-19 ([upstream.md](../../project/upstream.md)) and
2026-08-21 (this header). A19–A21, C6, and Track E were never filed on
GitHub.

## Epic

**water park — org IAM/security kit.** Central one-type-per-file repo,
PR-driven, drift-watched, gated Ops, satellites, agent concierge, dual
backend. Tracks A (AWS core), B (cross-cloud), C (satellites), D
(agentic), E (Terraform backend).

## Track A — central repo, AWS first

**A1. Repo skeleton.** `chant.config.ts`, `src/` layout, justfile,
vitest, npm consuming published chant.
AC: fresh clone installs, `just check` green, `chant build` synthesizes
an empty-but-valid baseline stack.

**A2. Layout lint rules.** one-type-per-file and path-matches-name.
AC: two declarables in a file fails; a path/name mismatch fails; both
with fix-its.

**A3. Security lint pack.** no-wildcard-action, no-open-ingress,
boundary-required, no-inline-policy, tag-owner-required,
sg-reference-not-cidr; rule IDs mapped to parliament/cloudsplaining
taxonomies. chant's audit tier ships WAW056-058 — cover what the
catalogs do not.
AC: failing and passing fixtures per rule; rules fire in editor via LSP.

**A3b. Access Analyzer proof checks.** CheckNoNewAccess against the
base branch, CheckAccessNotGranted for the forbidden-actions list,
public-access checks. Never in a job an untrusted author can trigger
(decision 22).
AC: a PR widening a policy fails with the verdict rendered for the
reviewer; no credentialed workflow reachable from an unprivileged
`pull_request` event, proven by a fork-PR test.

**A4. Persona composites.** The design/personas.md set: human personas
→ permission sets, workload personas → roles; grants as typed access
levels expanded at synth; first-class `expires`.
AC: each persona instantiates from params only; boundary on every role;
an expired grant surfaces as drift; snapshot tests over policy JSON.

**A5. OrgPrincipal composite + leaf-file layout.** One principal per
file under `src/principals/<team>/`, AWS leg only; no IAM users or
groups (decision 5).
AC: a new principal is addable by copying a sibling file; wrong persona
name is a type error; the estate names throughout.

**A6. Baseline component. needs-design (boundary contents, warden
cycle design)** Permission boundaries, org policy set (SCP + RCP +
declarative), password/MFA policy, default-deny SGs, forbidden-actions
list. Start from the aws lexicon's landing-zone composites;
org-formation coexistence seam documented.
AC: deploys to Floci and a real account; every other stack references
the boundary by deterministic name.

**A7. Typed network layer.** SG composites with intent-level API,
one SG per file.
AC: raw CIDR ingress fails lint unless allowlisted; cross-SG references
resolve by deterministic name.

**A8. Drift watch + reconcile Ops.** `wp-watch` (diff --live on cron)
and `wp-reconcile` (owned-only cloud-to-code PRs).
AC: hand-edit an owned SG, watch flags it within one cycle, reconcile
opens a PR containing only the owned change.

**A9. Break-glass Op.** Gated Temporal Op per design/break-glass.md:
pluggable approval signal, timed grant, revocation as compensation,
hard cloud-side TTL. TEAM interop documented, not replaced.
AC: approve path grants and auto-revokes; kill the worker mid-grant and
revocation still occurs; every transition in the audit trail.

**A10. Offboard Op (AWS leg).** Remove a principal from every stack
that references it, one gated run.
AC: role, memberships, and SG references removed in a single PR +
apply; graph shows zero remaining references.

**A11. Access-review Op.** Quarterly artifact: every principal, its
personas, reachable resources, last-changed, expired/expiring grants,
satellite package versions. Written as SOC 2 evidence; not the Q&A
substrate (`chant search` is). Evaluate OKF before inventing a format.
AC: runs on the local executor; a single artifact a compliance reviewer
accepts; scheduled CI workflow, opt-in gated.

**A12. Generated CI.** Pipelines for the three code hosts from the
component graph, gated deploy, scheduled watch/reconcile/access-review.
AC: `just github-validate` (and peers) pass; runtime E2E against Floci.

**A13. Local path.** Full kit deploys to Floci, `just local-up`.
AC: baseline + personas + a demo principal reach CREATE_COMPLETE
locally; the A8 drift demo runs locally.

**A14. Adoption seams.** reference-existing on boundaries, zones,
pre-existing roles — day one touches nothing. A carve walkthrough is
documented for orgs that choose the chant backend; it is optional and
never pushed (decision 23).
AC: adopting a pre-existing role and SG deploys with zero composite
edits; carve walkthrough validated against a sample TF state.

**A15. SKILL.md + docs site.** Agent capability map, docs site, the
pattern doc naming the central-repo layout and the no-write-GUI
principle.
AC: from a bare checkout an agent answers "add read access to the artifacts bucket
for team Y" with the correct file path and PR flow.

**A17. Threat-model hardening.** Apply-role boundary (with A6), OIDC
wiring per tier, guardrail-path CODEOWNERS + high-severity rendering,
branch-protection-as-code. Includes rotating the few static secrets the
estate cannot avoid (break-glass signing material) — an estate of
federated short-lived credentials has nothing else to rotate, so the
old standalone rotation issue folds in here.
AC: the apply role cannot detach its own boundary (proven by A3b); a PR
touching `.chant/rules/` renders high-severity; branch protection is
declared and drift-watched; no static credential outlives the policy
window without a finding.

**A18. Trust layer. needs-design (design/workload-identity.md)**
`src/trust/`: one typed form for CI OIDC, k8s service-account, and
SPIFFE issuers, serialized to AWS federation trust. Strictest lint and
top drift severity; BYO-issuer (decision 13).
AC: a workload principal declares a subject and its AWS leg synthesizes
the trust; a wildcard subject fails lint; a hand-edited trust policy is
flagged within one cycle.

**A19. Governance reconcile (decision 16).** The AWS half of aws-warden
as Ops over typed source: OU tree, SCPs, Identity Center, org trail.
Ownership-gated deletes, removal-delta cap, dry-run by default, account
creation surfacing in the plan rather than being attempted.
AC: the four cycles reconcile water park's declared org; a removal beyond the
cap refuses; the break-glass permission set cannot be removed by a
reconcile.

**A20. Generated CODEOWNERS (decision 21).** Derive the routing from
the principal files, emit it, declare it as a watched resource.
Guardrail paths route to security by rule.
AC: adding a principal routes its review with no CODEOWNERS edit; a
hand-edit is flagged within one cycle; a rerouting PR renders
high-severity.

**A21. Export bundle (decision 2).** The walk-away artifact:
synthesized CloudFormation, policy JSON, marker inventory, provenance.
AC: build the water park estate, delete the kit and every chant dependency,
deploy the bundle with the AWS CLI alone, byte-identical. If the AC
cannot run, decision 2 gets softened instead.

## Track B — cross-cloud fan-out

**needs-design (open question 9)** — gated on cross-cloud persona
equivalence (design/personas.md item 4).

**B1. GCP leg.** **B2. Azure leg.** **B3. K8s + code-host legs.**
**B4. Cross-cloud offboard demo** — the flagship.
AC pattern: one leaf file, N clouds; the archetype maps to an equivalent
grant per leg; offboard removes all legs in one run.

## Track C — satellite repos + PR automation

Design source: [pr-automation.md](../../project/archive/pr-automation.md).

**C1. Refs module spike. needs-design (open question 3)** Hand-written
vs generated vs chant feature; output is a decision doc and, if
warranted, a chant issue.

**C2. Org context package.** `the shared module`: config preset,
naming helper, guardrail rules (re-export shims until rule packages),
typed refs per C1.
AC: a new satellite is one dep + three-line config + one resource file
with the full guardrail set enforced; an upgrade adding a rule cannot
break a satellite without a warn cycle.

**C3. Satellite example repo.** An app-team monorepo consuming the
package, declaring resources *and their workload roles* inside the
guardrails, running generated PR CI.
AC: a guardrail violation fails with no central-team involvement;
deploys against Floci end to end; the delegation double-refusal test.

**C6. Delegated boundary + `WorkloadRole` composite (decision 20).** The
boundary policy in the baseline, the condition on the satellite deploy
credential, the composite that applies boundary, marker, and naming.
AC: a satellite leaf file is a persona plus grants and nothing else;
the deploy credential cannot create an unbounded role even with lint
disabled; tightening the boundary follows the warn cycle.

**C4. PR automation adoption.** Real dependency: chant epic items 1, 2,
and 9 — the manifest spine of decision 24. Present adapters are
opportunistic; the semantic access delta stays deterministic
(decision 14).
AC: the pr-automation flow works end to end on all three CI providers
against Floci; a security-relevant PR shows "grants X on Y to team Z"
rather than a JSON diff; a PR removing an Op gate is flagged loudly.

**C5. Runner requirements doc.** Not a runner — a requirements capture
for whatever the compiled story cannot do, filed on chant when concrete.

## Track D — agentic

Design source: [design/agentic.md](../../content/docs/design/agentic.md). Depends on A15
and the threat-model agent boundary; D1 unblocks the rest.

**Sequencing: demo-first against a fixture.** The request→PR loop is
built end to end against a fixed water park estate checked into the repo,
real Track A backfilling behind it. The rationale, re-derived after the
chat front-end was deferred: the loop is the earliest end-to-end
exercise of the verb layer and the manifest rendering, and scenario 6
is the demo that sells the pattern. A fixture proves the
intake/verb/PR seams and nothing about the estate underneath; no
D-series AC may claim otherwise.

**D0. Domain verbs.** `wp-request` intent Op (structured intent →
deterministic leaf edit → lint + proof → PR), lifecycle projections
(`expiring`, `offboard-preview`), SKILL.md golden paths. File the chant
gap: project-local MCP tools. chant#1290 means `wp-request` returns its
PR URL as a search attribute or artifact.
AC: `chant run wp-request` with typed args produces the same PR the
agent flow produces; verbs callable without any agent.

**D1. Concierge environment + Q&A/request flows.** The reference
Fountain Environment manifest in-repo: checkout, SKILL.md,
conversation-scoped verb-API token, default-deny egress allowlist
naming the verb service and code host, no cloud credentials
(decision 15). Restricting who may open conversations stays as depth.
Includes intake-identity enrollment (decision 17): an identity field on
a human principal's leaf file, lint (well-formed, unique across the
estate, never on a workload principal), and the refusal path for
unmapped identities — enrollment is access-relevant and gets CODEOWNERS
routing.
AC: `fountain apply` stands up the concierge; "who can reach the
receipts bucket?" answers from the D0 projection; water park scenario 6
yields a correct one-file PR passing lint and CheckNoNewAccess with no
human edit; an unmapped identity gets a refusal naming the enrollment
path and no PR; a boundary-exception request gets a directed refusal.

**D2. Explain agents.** Drift/reconcile PR annotation (CloudTrail: who,
when) and reviewer-side commentary, labeled. needs-design: CloudTrail
credential scope.
AC: scenario 2's reconcile PR carries an accurate who/when annotation;
commentary is visually distinct from the plan.

**D3. Hygiene agent.** Scheduled: unused-access findings + expiring
grants → burndown PRs. needs-design: cadence/volume caps.
AC: an unused grant becomes a removal PR citing the finding; volume
respects the cap; no PR for foreign resources.

## Track E — Terraform backend (decision 23)

**needs-design (open question 14)** — nothing in Tracks A–D depends on
it.

**E1. Manifest schema + normalization.** The common change-manifest
schema and the reduction of Terraform plan JSON into it; the chant half
is pr-automation epic items 1–2.
AC: the same access-delta rendering and digest-bound approval (decision
24) produced from a chant change set and from a Terraform plan of the
equivalent change.

**E2. Terraform authoring path.** The repo layout in HCL, guardrails as
CI policy checks (tflint/conftest-class), drift via plan; generated
CODEOWNERS and the delegation boundary unchanged (AWS mechanics, not
backend mechanics). Honest scope: reconcile *authoring* is chant-only —
cloud-to-code needs an emit path Terraform lacks, so this backend
detects and reports drift and a human authors the fix.
AC: the water park central repo in Terraform passes the same guardrail
intent; scenario 5's double refusal holds with the Terraform deploy
credential; drift on an owned resource is detected and reported within
one cycle, and the docs state the no-auto-reconcile boundary.

**E3. Coexistence doc.** What a mixed estate (components per backend)
means for the watch, the manifest, and the access review. Backend
choice is the org's; carve is referenced as an available chant feature,
not recommended as a path.

## Chant-epic dependencies

| water park issue | needs chant epic items |
|---|---|
| C2 | 8 (rule packages — shims until then) |
| C4 plan/gate/freshness | 1, 2 |
| C4 Op-manifest + semantic | 9; 11–12 for drift-aware plan + provenance |
| A17 high-severity rendering | 9 (or interim path-based rendering) |
| E1 | 1, 2 (the manifest schema is the renderer's input) |

Status 2026-08-19: none of items 1–12 has landed except gitlab's
`MrPlanReport`. The epic shrank: an agent with the host's API is a
universal present adapter, so items 3–5 are opportunistic, item 6 is
dropped, and C4's real dependency is 1, 2, and 9.

## Filing order

- **A20** is small and makes the most powerful object in the estate
  visible — early.
- **A21** can run against a thin estate; the sooner, the sooner
  decision 2 is proven or softened.
- **A19** after A6 and A8. **C6** with A6 — one mechanism, two tiers.
- **D0–D1** do not wait for Track A (demo-first).
- **E1** can start as a schema spike alongside pr-automation items 1–2;
  E2–E3 wait for it.
