# water park — plan

A drop-in kit for cross-cloud IAM and security, built on chant. This is a
domain kit, a third category alongside lexicons and product adoption kits
like loomster. There is no upstream product to pin. The upstream is a pattern
that is known to work.

## The big three

1. **Centralized core infra.** One type per file, a hierarchy that makes
   every resource findable by path guess, anyone PRs their way in.
2. **Team monorepos with context.** A team creates an infra project with
   nothing but a resource defined. In the Terraform world this took
   Terragrunt, because Terraform buries every module in backend, provider,
   and state wiring. chant carries far less config, so the goal is nearer —
   what remains is packaging the org's context, not inventing an include
   system. See the satellite section.
3. **Pull request automation.** The full design is in
   [pr-automation.md](pr-automation.md). chant grows a compiled, per-CI PR
   story; water park is its first implementation.

Everything else in this plan serves one of the three.

## The pattern being productized

The best version of centralized security config observed in the wild:

- A fully centralized repo owned by the security/platform team.
- Exactly one Terraform resource type per file.
- Folder structure that makes every resource findable by path guess.
- Anyone in the org can PR their way to the access they need.

It worked because finding a resource was a path lookup, the PR diff was
exactly the blast radius, and git blame was a per-resource audit trail.

The worst version: internal GUIs over security groups and IAM. No diff, no
review, no history, no way to propose a change to something you don't own,
and drift invisible. Two separate GUIs meant no unified view.

The lessons are the spec. Config wins, GUIs lose. The write path is always
the PR. Browsing belongs in a read-only viewer (behold), never a write GUI.

## What chant adds over the Terraform original

The one-type-per-file convention was social in the Terraform shop. Someone
enforced it in review. chant makes it structural — a project-local lint rule
enforces one declarable per file and path-matches-name, failing in the
editor. The pattern survives the hundredth contributor.

Centralized Terraform also pays a state tax. Shared state means a global
mutex on apply and eventual forced workspace sharding. chant has no state
file to contend on, so the centralized layout scales without eroding.

Beyond parity, chant's treatment is unusually strong for this domain:

- Drift on IAM/SGs is an incident, not noise. `chant lifecycle diff --live`
  on a cron plus owned-only reconcile PRs is a security control.
- Break-glass access is a gated Temporal Op: approval gate, timed grant,
  revocation as the saga compensation. If the workflow dies, revocation
  still runs.
- Ownership markers plus reference-existing seams mean the kit sits beside a
  decade of existing IAM and only touches what it declares. Adoption without
  re-homing.
- Policy is typed lint at build, left of the platform. A wildcard action or
  open ingress fails in the editor, before review.
- One principal definition fans out across clouds via existing lexicons
  (aws, gcp, azure, k8s, github, gitlab, forgejo). Offboarding a principal
  everywhere at once is the cross-cloud killer demo.

This kit is the living proof of three published arguments: policy belongs
left of the platform, governance without the state file, and the
consolidation problem.

## Repo shape

```
src/baseline/        org guardrails — permission boundaries, org policies
                     (SCP + RCP + declarative), account password/MFA
                     policy, default-deny SGs, the forbidden-actions list
src/personas/        typed archetypes as composites — human personas
                     compile to Identity Center permission sets, workload
                     personas to IAM roles; grants as typed access levels
src/principals/      the PR surface — one file per human team or workload;
                     OrgPrincipal fans out to permission-set assignments
                     (humans) or roles (workloads), later per cloud
src/network/         security groups / firewall rules with typed
                     intent — SG references, not raw CIDRs
.chant/rules/        one-type-per-file, path-matches-name,
                     no-wildcard-action, no-open-ingress,
                     boundary-required, no-inline-policy, tag-owner
ops/                 watch, reconcile, break-glass, offboard,
                     access-review, rotation
```

Leaf files under `src/principals/` and `src/network/` must be boring enough
that a first-time contributor copies a sibling file and gets it right. The
composites carry the complexity. Leaves are close to data. CODEOWNERS routes
`src/principals/<team>/**` to that team plus security, so central review
shrinks to exceptions.

Standard treatment from loomster: generated CI for github/gitlab/forgejo
with a gated deploy, a Floci/azApply/gcpApply local path so changes are
testable with no cloud account, SKILL.md agent map, docs site, export
bundle. Consumes published `@intentius/chant` from npm, adds zero chant
surface.

## Tracks

**Track A — central repo, AWS first.** The org scenario starts with AWS
centralization, so the kit does too. First milestone is three demos: the
drift watch catching a hand-edited SG and opening a PR, the break-glass Op
granting and auto-revoking, and lint failing a wildcard policy in the
editor.

**Track B — cross-cloud fan-out.** OrgPrincipal grows gcp, azure, k8s, and
github/gitlab team-access legs. The offboard Op becomes the demo that lands.

**Track C — satellite repos.** See below.

On the AWS/cross-cloud tension: the title promise is cross-cloud, the
positioning and landscape are AWS-only. Both are intentional. AWS is the
wedge — it is where orgs centralize, where the verification APIs exist, and
where the ideal customer lives. Cross-cloud is act two, it is what the
OrgPrincipal shape is designed for, and it is genuinely unsolved: persona
equivalence across clouds (what "developer" compiles to in Azure RBAC or
GCP IAM terms) is a design problem nobody in the landscape has solved
either, which is why Track B is needs-design (open question 9).

## Satellite repos (the terragrunt/atlantis dimension)

In the original org, app teams had their own monorepos leaning on the
central one-type-per-file repo. Terragrunt supplied context and cross-stack
references. Atlantis ran plan on PRs and applied on approval.

First, why Terragrunt existed at all. Terraform makes every module carry
backend config, provider config, state wiring, and per-env var plumbing.
Terragrunt is an include system that DRYs that overhead away. chant has
almost none of that overhead — a project is `package.json`,
`chant.config.ts`, and source files. So the chant version of "context" is
not a hierarchy of includes. It is one npm package.

**The org context package.** The central repo publishes (or the org forks)
a single package bundling everything a satellite needs: a `chant.config.ts`
preset (lexicons, ownership convention, buildParams, lint config — spread
into a three-line local config, no chant feature needed since the config is
TS), the naming/tagging helper, the org guardrail lint rules, and the typed
refs module. The target developer experience for a new satellite:

```
package.json      one dependency: @org/waterpark-context
chant.config.ts   three lines extending the preset
src/queue.ts      the resource — the only file with content
```

That is "an infra project with nothing but a resource defined." Terragrunt
needed a folder hierarchy and an include DSL to fake this. A typed language
gets it with an import.

One chant gap stands in the way: lint rules load only from a walked-up
`.chant/rules/` directory (`packages/core/src/lint/rule-loader.ts`), not
from a dependency. A satellite can shim it with one-line re-export files,
but first-class rule packages (config-declared rule sources) is the right
fix and goes on the chant epic. This also settles open question 1 harder
than "when a second consumer exists" — satellites are consumers from day
one, so the rule catalog and context move to a package early.

**References.** Terragrunt reads remote state at plan time, which needs
credentials and a live backend. water park's naming scheme is deterministic
(the loomster `{project}-{env}-{instance}-{component}-{resource}`
convention), so references are computable at build time. The refs module in
the context package exposes typed getters — boundary ARNs, SG ids, role
ARNs. Typed, versioned, no credentials at build. A validate step can
optionally live-check that referenced resources exist. `stackOutput()` is
intra-repo in chant today, so the refs module is the cross-repo answer.
Whether it is hand-written, generated from the central build, or points at
a future chant feature (typed export artifact of component outputs) is an
open question below.

**PR automation.** The Atlantis role. Designed in full in
[pr-automation.md](pr-automation.md): plan-on-PR compiled into the
generated pipelines of all three CI lexicons, per-platform present adapters
(GitLab's MR widget already ships), gates mapped to native primitives,
concurrency plus a plan-digest freshness check replacing Atlantis locks,
and a standing runner explicitly deferred.

**What ships in Track C now.** The context package, a satellite example
repo showing an app-team monorepo that imports it and declares app-scoped
resources inside the central guardrails, the generated PR pipeline running
against it, and a doc naming the pattern so orgs can replicate it.

## Scope line

water park manages what it declares and audits what it owns. It is not a
CSPM. Scanning the rest of the estate is chant-audit's job (chant#350), and
the two form a funnel — the auditor finds the mess, water park is the
remediation.

## Open questions to settle before filing issues

1. **Rule catalog packaging.** Largely settled by the context-package
   design: satellites are consumers from day one, so rules and config
   presets live in `@org/waterpark-context` early. Remaining sub-question
   is the chant-side mechanism — `.chant/rules/` re-export shims now vs
   first-class rule packages (filed on chant).
2. **Persona set.** Which archetypes are actually universal. Needs a pass
   over a few real org models (startup, centralized enterprise, cell-based).
   If the archetypes are wrong, orgs fork the composites and the kit
   collapses into a starter template. This is the main design risk.
   Landscape constraint ([landscape.md](landscape.md)): personas must split
   human vs workload — human personas compile to Identity Center permission
   sets, workload personas to IAM roles. Grant vocabulary should be typed
   access levels (the Policy Sentry model), expanded at synth. Every grant
   carries an optional first-class `expires` (IAMbic's good idea) — an
   expired grant is drift the watch flags and reconcile removes.
3. **Cross-repo refs mechanism.** Hand-written module vs generated from the
   central build vs a new chant feature (typed component-output export).
   Needs a spike. May produce a chant issue.
4. **Multi-account AWS.** Real orgs centralize IAM across many accounts, and
   the org layer now has three policy types (SCP, RCP, declarative) plus
   Identity Center permission sets, all org-scoped. Multi-account via
   Organizations is the default shape, single-account the degenerate case.
   Accounts as environments, components, or instances? Coexistence seam
   with org-formation for orgs already on it? Needs design before the
   baseline component is real.
5. **Break-glass guarantees.** What happens when Temporal is down mid-grant.
   Is saga compensation a sufficient guarantee for a security control?
   Document failure modes honestly; consider a belt-and-suspenders TTL on
   the grant itself (e.g. IAM session duration or a conditional expiry).
6. **Adoption entry point.** Greenfield init vs `chant carve` from existing
   Terraform IAM vs import from live. Probably all three, but which is the
   documented first path?
7. **Demo org.** Resolved — [demo-org.md](demo-org.md) defines flume, the
   fictional org threaded through docs and acceptance criteria.
8. **GUI stance in docs.** Resolved — written down in
   [positioning.md](positioning.md) and pinned in
   [decisions.md](decisions.md).
9. **Cross-cloud persona equivalence.** What each persona archetype
   compiles to on the gcp / azure / k8s / code-host legs, and where
   equivalence is honest vs forced. Blocks Track B. Skeleton in
   [design/personas.md](design/personas.md).

Design-in-progress docs for the gating questions live under
[design/](design/): [personas](design/personas.md),
[multi-account](design/multi-account.md),
[break-glass](design/break-glass.md),
[guardrail-rollout](design/guardrail-rollout.md). The threat and credential
model is [threat-model.md](threat-model.md). Pinned decisions are in
[decisions.md](decisions.md).

## Terms

- **principal** — an identity water park manages: a human team or a
  workload. One leaf file each.
- **persona** — a typed archetype (developer, deployer, auditor,
  break-glass) a principal instantiates. Human personas compile to Identity
  Center permission sets, workload personas to IAM roles.
- **grant** — one typed access statement inside a principal file: access
  level × resource, optional `expires`.
- **leg** — one cloud/provider projection of a principal (aws leg, gcp
  leg, code-host leg).
- **estate** — everything live that water park owns or watches.
- **satellite** — an app-team repo consuming the org context package.
- **context package** — `@org/waterpark-context`: config preset, naming
  helper, guardrail rules, typed refs.
