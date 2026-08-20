# water park — plan

A drop-in kit for org IAM and security: a domain kit, with no upstream
product to pin — the upstream is a pattern known to work. chant is the
reference backend; Terraform/OpenTofu is a supported backend
(decision 23, Track F).

## The big three

1. **Centralized core infra.** One type per file, every resource
   findable by path guess, anyone PRs their way in.
2. **Team monorepos with context.** A team creates an infra project
   with nothing but a resource defined.
3. **Pull request automation.** [pr-automation.md](pr-automation.md).
   The PR is the authorization envelope; the reviewer approves the
   normalized change manifest, bound by digest (decision 24).

Everything else in this plan serves one of the three.

## The pattern being productized

The best version of centralized security config observed in the wild: a
fully centralized repo owned by the security/platform team, one resource
type per file, folder structure that makes every resource findable by
path guess, anyone able to PR their way to the access they need. It
worked because finding a resource was a path lookup, the PR diff was
exactly the blast radius, and git blame was a per-resource audit trail.
The worst version: internal GUIs over IAM — no diff, no review, no
history, drift invisible. The lessons are the spec: config wins, GUIs
lose, the write path is always the PR, browsing belongs in a read-only
viewer (behold).

## Two backends

The pattern is tool-agnostic; the enforcement machinery is not.

**Carries to any backend:** the repo shape and one-type-per-file
convention; the PR as the only write path; drift watch and reconcile
PRs; generated CODEOWNERS; boundary delegation (pure AWS mechanics);
Access Analyzer proofs and the semantic access delta (they operate on
policy documents, not authoring language); cloud-side break-glass
expiry; the manifest.

**chant-only amplifiers:** no state file, so no apply mutex; typed lint
in the editor rather than in CI; Floci for credential-free PR
validation; the three-file satellite.

**Terraform backend (Track F, needs-design).** Same repo shape in HCL,
guardrails as CI policy checks instead of editor lint, drift via plan,
the manifest normalized from plan JSON. `chant carve` remains the
migration for orgs that move (A14); the backend is for the majority that
has the pain without the TypeScript comfort and won't.

## The manifest

Intent compiles to source deterministically (`wp-request` proves it), so
the source diff is a build artifact and the wrong altitude for review.
The typed change set — the manifest — is what the reviewer actually
approves: the semantic access delta, proof verdicts, Op-manifest diff.
Approval binds to its digest; apply refuses on divergence. The PR
supplies what the manifest cannot: authority and the durable record. The
manifest is never the system of record — that would be the IAMbic
failure (decision 2). It is also what makes two backends one product:
chant emits it natively, Terraform's plan JSON normalizes into it.

## Repo shape

```
src/baseline/        org guardrails — boundaries, org policies
                     (SCP + RCP + declarative), default-deny SGs,
                     the forbidden-actions list
src/personas/        typed archetypes — human → permission sets,
                     workload → IAM roles
src/principals/      the PR surface — one file per team or workload
src/network/         SGs with typed intent — references, not raw CIDRs
src/trust/           federation trust as estate — CI OIDC, k8s SA,
                     SPIFFE issuers in one typed form
.chant/rules/        one-type-per-file, path-matches-name,
                     no-wildcard-action, no-open-ingress,
                     boundary-required, no-inline-policy, tag-owner
ops/                 watch, reconcile, break-glass, offboard,
                     access-review, rotation, request
CODEOWNERS           generated, never hand-authored, drift-watched
```

Leaf files must be boring enough that a first-time contributor copies a
sibling file and gets it right; composites carry the complexity.
CODEOWNERS routes `src/principals/<team>/**` to that team plus security,
so central review shrinks to exceptions. Standard loomster treatment:
generated CI for the three code hosts, a Floci local path, SKILL.md,
docs site, export bundle. Consumes published `@intentius/chant`, adds
zero chant surface.

## Tracks

**Track A — central repo, AWS first.** First milestone is three demos:
the drift watch catching a hand-edited SG and opening a PR, the
break-glass Op granting and auto-revoking, and lint failing a wildcard
policy in the editor.

**Track B — cross-cloud fan-out.** OrgPrincipal grows gcp, azure, k8s,
and code-host legs; the offboard Op becomes the demo that lands.
needs-design until persona equivalence is solved (open question 9) — the
title promise is cross-cloud, and it is genuinely unsolved by anyone in
the landscape.

**Track C — satellite repos.** See below.

**Track D — agentic.** [design/agentic.md](design/agentic.md). Intake is
CLI, ticket-webhook, and Fountain conversations; a chat front-end is
deferred, with decisions 17 and 18 pinning the rules for when it
returns. The demo: an engineer asks the concierge for access and a
reviewable PR appears, the whole verification stack between the sentence
and the grant. Sequenced demo-first against a fixed flume estate
fixture, with real Track A backfilling behind it; a fixture proves the
intake/verb/PR seams and nothing about the estate underneath, and every
AC a fixture cannot honestly satisfy says so.

**Track F — Terraform backend.** The manifest normalization and the
guardrail/drift parity described above. needs-design; nothing in Tracks
A–D depends on it.

## Satellite repos

App teams keep their own monorepos leaning on the central repo.
Terragrunt existed because Terraform buries every module in backend,
provider, and state wiring; chant's version of "context" is one npm
package. `@org/waterpark-context` bundles a config preset, the
naming/tagging helper, the guardrail rules, and the typed refs module. A
new satellite is one dependency, a three-line config, and one resource
file.

**References.** The deterministic naming scheme makes cross-repo
references computable at build time: typed getters (boundary ARNs, SG
ids, role ARNs), no credentials, no remote-state read. Mechanism open
(question 3).

**Roles, not just resources.** The interesting satellite case is the
role that reads the queue. Under decision 20 a satellite declares its
own workload roles inside a boundary the central repo owns — enforced by
lint at build and by the `iam:PermissionsBoundary` condition at apply. A
satellite may create identities that act on its own resources; it may
never change what an identity is allowed to be
([design/delegation.md](design/delegation.md)).

**Ships in Track C:** the context package, a satellite example repo
declaring resources and their roles inside the guardrails, the generated
PR pipeline, and a doc naming the pattern. One chant gap: lint rules
load only from a walked-up `.chant/rules/`, so satellites shim with
re-exports until rule packages land (filed on chant).

## Scope line

water park manages what it declares and audits what it owns. Not a CSPM:
scanning the rest of the estate is chant-audit's job (chant#350), and the
two form a funnel — the auditor finds the mess, water park is the
remediation.

## Open questions

Settled: personas (design/personas.md strawman adopted), multi-account
(design/multi-account.md hybrid adopted), break-glass (three-layer answer
adopted), demo org (flume, demo-org.md), GUI stance (decision 1).

1. **Rule catalog packaging.** Settled in shape — rules live in the
   context package from day one; open sub-question: re-export shims now
   vs first-class rule packages (filed on chant).
3. **Cross-repo refs mechanism.** Hand-written vs generated vs a chant
   feature (typed component-output export). Needs a spike.
6. **Adoption entry point.** Greenfield init vs `chant carve` vs import
   from live. Probably all three; carve is the strongest documented
   first path because it prices the move first. Confirm in A14.
9. **Cross-cloud persona equivalence.** What each archetype compiles to
   per leg, and where equivalence is honest vs forced. Blocks Track B.
10. **How much of aws-warden to take.** Decision 16 adopts the
    reconcile; the shape is open — Ops over typed source, keeping the
    cycle decomposition and guardrail set. Belongs to A6.
11. **The access-review artifact format.** OKF is a candidate with a
    spec and validator; A11's first task.
12. **The delegated boundary's contents.** The most-revised object in
    the baseline. Belongs to A6 with the apply-role boundary.
13. **Cross-repo reachability.** Once satellites create roles, "who can
    reach X" spans repos: satellites publish a graph artifact, or A11
    scopes to the central estate and states the gap.
14. **Manifest schema and Terraform normalization.** The common schema
    and the plan-JSON reduction. Gates Track F; the chant half is
    pr-automation epic items 1–2.

## Terms

- **principal** — an identity water park manages: a human team or a
  workload. One leaf file each.
- **persona** — a typed archetype (developer, deployer, auditor,
  break-glass) a principal instantiates.
- **grant** — one typed access statement inside a principal file: access
  level × resource, optional `expires`.
- **leg** — one cloud/provider projection of a principal.
- **estate** — everything live that water park owns or watches.
- **satellite** — an app-team repo consuming the org context package.
- **context package** — `@org/waterpark-context`: config preset, naming
  helper, guardrail rules, typed refs.
- **manifest** — the normalized change set a reviewer approves, bound
  by digest (decisions 23, 24). Backend-blind.
- **backend** — the authoring toolchain behind the manifest: chant or
  Terraform/OpenTofu.
- **delegated boundary** — the permission boundary a satellite's roles
  are created inside (decision 20).
