# AWS IAM / policy management landscape

Surveyed 2026-07-27. Repo activity verified via the GitHub API, not search
summaries. Impact on the design at the end of each section and collected in
plan.md's open questions.

## IAM-as-code / GitOps — the lane water park enters

**IAMbic** (noqdev/iambic, 302 stars) is the closest prior art: "version
control for IAM," bi-directional Git↔cloud sync, multi-provider (AWS, Okta,
Azure AD, Google Workspace), and first-class expiry — `expires_at` on a
grant, removed automatically. Last push November 2024. Noq, the company
behind it, is gone; their earlier product lineage (Netflix ConsoleMe,
3.2k stars) is archived too.

Two lessons from the body. What it got right and water park should adopt:
expiry as a first-class field on every grant (an expired grant is drift the
watch Op flags and the reconcile Op removes), and cloud-to-code sync as the
adoption path (water park already has this in the reconcile design). Why it
died anyway: its own YAML format and bespoke Python engine — adopting it
meant re-homing your IAM into a startup's format, and when the startup died
the format died. water park's counter-position is exactly chant's: typed
TypeScript compiled to CloudFormation, native artifacts, no new format, and
the engine is a general-purpose IaC toolchain that exists independently of
this kit.

**org-formation** (org-formation-cli, 1.5k stars, active) manages AWS
Organizations as code: accounts, OUs, SCPs. It is the living tool at the
org layer. water park's baseline overlaps it on SCPs. Decision needed:
cover org policies fully (SCP + RCP + declarative) or document coexistence
with org-formation for orgs already on it. Leaning: cover them — they are
plain CloudFormation-adjacent org resources and the aws lexicon types them
— and document the coexistence seam anyway.

**The real incumbent is a pile of Terraform.** Most orgs doing IAM-as-code
at all do it with hand-rolled Terraform modules and Terragrunt hierarchies
— per-cloud, state-taxed, convention-by-review. That, not any product, is
what water park displaces, and `chant carve` is the migration path (A14).
The field-lesson org in plan.md is the best case of the incumbent; water
park's pitch to those shops is the same pattern without the state mutex
and with the conventions compiled in.

**Scope line: Cedar / Amazon Verified Permissions** is application-level
authorization (can this user perform this action in your app), not
infrastructure IAM. Out of scope; worth one docs sentence because readers
conflate them.

**The code host is part of the estate.** Merge rights on the water park
repo are grant rights on everything it manages, and team/repo permissions
on the code host are themselves access. The github/gitlab/forgejo lexicons
can declare them, which both closes the loop on the repo's own protection
(threat-model.md) and is the B3 leg.

## Verification — the biggest design impact

**IAM Access Analyzer custom policy checks** are API-callable automated
reasoning over policies, built for CI: `CheckNoNewAccess` (does the
candidate policy grant more than the reference), `CheckAccessNotGranted`
(prove specific actions/resources are never granted), and public/critical
resource access checks. This slots directly into the PR automation story:
every PR touching a policy gets a provable claim — "grants no new access
relative to main," or "cannot touch the billing actions" — next to the
semantic access-delta rendering. The rendering makes review readable; the
check makes it provable. Layered, they are stronger than anything the
generic PR tools show. Runs as a live post-synth check in the PR pipeline
(needs credentials, same wiring as the plan job).

## JIT / break-glass — crowded, stay scoped

Commercial: Apono, Opal, Britive, CyberArk, BeyondTrust. AWS's own
**TEAM** (temporary elevated access, Identity-Center-based, aws-samples,
active) covers human JIT for Identity Center shops. Common Fate's OSS is
archived. Impact: do not compete on JIT UX (Slack flows, catalogs). The
break-glass Op stays scoped to what the crowd can't do — durable execution
with revocation as compensation, the grant in the same audit trail as the
rest of the estate, and a pluggable approval signal (a Temporal signal can
come from anywhere, including Slack). For Identity Center shops, document
TEAM interop rather than replacing it.

## Least-privilege authoring

**Policy Sentry** (Salesforce, 2.2k stars, active) generates least-privilege
policies from CRUD-level intent (service, resource, access level →
expanded actions). Impact: the persona/grant language should be a typed
version of this model — grants expressed as access levels against resource
types, expanded at synth. That is the leaf-file vocabulary that keeps
principal files near-data.

## Linters and auditors — map to, don't reinvent

**Parliament** (1.1k, active) lints policy documents; **Cloudsplaining**
(2.2k, active) assesses risk (privilege escalation, resource exposure);
**Prowler** (14.5k, very active) is the dominant OSS auditor;
cfn-guard/checkov cover template-level policy. Impact: water park's lint
pack should map its rule IDs to the established finding taxonomies
(parliament/cloudsplaining checks), the same catalog pattern chant's CI
security rules used (GHA0xx/WGL0xx). Prowler is the funnel companion to
chant-audit (#350), not competition — water park manages what it declares.

## Workload identity — SPIFFE/SPIRE (surveyed 2026-07-28)

**SPIFFE** (CNCF standard: `spiffe://` workload identities, short-lived
X.509/JWT SVIDs via attestation) and **SPIRE** (reference implementation)
are healthy and consolidating: both repos active, hardened helm chart
maintained, IETF WIMSE formalizing federation, Istio identity is SPIFFE
underneath, and a real commercial layer (SPIRL/Defakto, Teleport Workload
Identity, Tetrate, HPE, Aembit). Impact: complementary, not competing —
SPIFFE does authentication, water park does authorization, and the seam is
**federation trust config** (AWS OIDC providers + trust policies / IAM
Roles Anywhere, GCP WIF pools, Azure federated credentials), which is
declarable estate and security-critical. SPIFFE IDs are also the universal
workload principal name for cross-cloud (open question 9's workload half).
water park never operates the issuer — BYO-issuer; k8s SA tokens and CI
OIDC are the same mechanism class and the zero-infra default. Full design
in [design/workload-identity.md](design/workload-identity.md). Scope line:
**Athenz** bundles authn + RBAC/policy and is the one adjacent tool that
overlaps water park's territory — a docs sentence, not an integration.

## Access graphs / CIEM

PMapper (1.6k, stale since 2024) answered "who can reach what" via privilege
escalation graphs; commercial CIEM (Wiz, Veza, Tenable) owns this space
now. Impact: the access-review Op and a behold lens answer reachability at
the declared-graph level. Do not build a CIEM.

## Platform reality that reshapes the design

Two facts about how AWS access is actually structured in 2026:

1. **Humans come through Identity Center permission sets**, not IAM users
   or hand-assumed roles. Workloads use IAM roles. The persona model must
   fan out to both: a human persona compiles to a permission set
   (org-level), a workload persona to roles. This reshapes open question 2.
2. **The org layer has three policy types now** — SCPs, RCPs (launched
   Nov 2024, service coverage still expanding through 2026), and
   declarative policies. A baseline that only does SCPs is a 2023 baseline.
   RCPs are the resource-side complement (what can be done TO resources)
   and belong in the baseline from day one. Multi-account via Organizations
   is the norm, single-account the degenerate case — open question 4 is not
   optional design, it is the default shape.

## Net effect on water park

The gap is real and recently re-vacated: the one direct GitOps-IAM attempt
is dead, its host company with it, and nothing typed took its place. The
survivors are either single-layer (org-formation), advisory (linters,
auditors), or commercial SaaS (JIT, CIEM). Nothing occupies "typed,
compiled, drift-reconciled IAM across the org and app layers, in a repo
anyone can PR." Adopt IAMbic's two good ideas (expiry, cloud-to-code),
avoid its fatal one (a format that dies with its vendor), integrate the
verification APIs AWS built for exactly this CI shape, and stay out of the
three crowded rooms (JIT UX, CSPM, CIEM).
