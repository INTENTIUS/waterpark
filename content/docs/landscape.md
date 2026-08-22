---
title: "AWS IAM / policy management landscape"
---

**Kit-era doc.** "water park" here names the IAM access-repo kit, now
the course's IAM scenario; this is lesson I0's survey. Surveyed
2026-07-27. Repo activity verified via the GitHub API.

## IAM-as-code / GitOps — the lane water park enters

**IAMbic** (noqdev/iambic, 302 stars) is the closest prior art:
"version control for IAM," Git↔cloud sync, first-class expiry on
grants. Last push November 2024; the company behind it is gone. Adopt
its two good ideas — expiry as a first-class field, cloud-to-code sync
as the adoption path. Why it died anyway: its own YAML format and
bespoke engine, so adopting it re-homed your IAM into a startup's
format that died with the startup. water park's counter-position: typed
source, native artifacts, no new format, an engine that exists
independently of this kit.

**org-formation** (1.5k stars, active) manages AWS Organizations as
code — the living tool at the org layer. water park covers org policies
fully and documents the coexistence seam.

**The real incumbent is a pile of Terraform.** Most orgs doing
IAM-as-code do it with hand-rolled modules and Terragrunt hierarchies —
state-taxed, convention-by-review. That, not any product, is what water
park addresses — on the Terraform backend for shops as they are
(decision 23), with `chant carve` available upstream for shops that
choose to move (A14).

**The code host is part of the estate.** Merge rights on the water park
repo are grant rights on everything it manages. The
github/gitlab/forgejo lexicons can declare team and repo permissions,
closing the loop on the repo's own protection (threat-model.md) and
forming the B3 leg.

## Verification — the biggest design impact

**IAM Access Analyzer custom policy checks** are API-callable automated
reasoning over policies, built for CI: `CheckNoNewAccess`,
`CheckAccessNotGranted`, and public/critical resource checks. Every PR
touching a policy gets a provable claim — "grants no new access relative
to main" — next to the semantic access-delta rendering. The rendering
makes review readable; the check makes it provable. Runs as a live
post-synth check (needs credentials; see decision 22 for where).

## JIT / break-glass — crowded, stay scoped

Commercial: Apono, Opal, Britive, CyberArk, BeyondTrust. AWS's own
**TEAM** covers human JIT for Identity Center shops. Do not compete on
JIT UX. The break-glass Op stays scoped to what the crowd can't do —
durable execution with revocation as compensation, the grant in the same
audit trail as the estate, a pluggable approval signal. For Identity
Center shops, document TEAM interop rather than replacing it.

## Least-privilege authoring

**Policy Sentry** (Salesforce, 2.2k stars) generates least-privilege
policies from CRUD-level intent. The persona/grant language is a typed
version of this model — access levels against resource types, expanded
at synth. That vocabulary keeps principal files near-data.

## Linters and auditors — map to, don't reinvent

**Parliament** lints policy documents; **Cloudsplaining** assesses risk;
**Prowler** (14.5k stars) is the dominant OSS auditor. water park's lint
pack maps its rule IDs to the established finding taxonomies, the same
catalog pattern chant's CI security rules used. Prowler is the funnel
companion to chant-audit, not competition.

## Workload identity — SPIFFE/SPIRE

Healthy and consolidating. Complementary, not competing: SPIFFE does
authentication, water park does authorization, the seam is **federation
trust config** — declarable, security-critical estate. SPIFFE IDs are
the universal workload principal name for cross-cloud (the equivalence
unknown's workload half). water park never operates the issuer
([design/workload-identity.md](design/workload-identity.md)). Scope
line: **Athenz** bundles authn + policy and overlaps — a docs sentence,
not an integration.

## Access graphs / CIEM

Commercial CIEM (Wiz, Veza, Tenable) owns the space. The access-review
Op and a behold lens answer reachability at the declared-graph level.
Do not build a CIEM.

## Platform reality that changes the design

1. **Humans come through Identity Center permission sets**, workloads
   through IAM roles. The persona model fans out to both.
2. **The org layer has three policy types** — SCPs, RCPs, declarative.
   An SCP-only baseline is a 2023 baseline. Multi-account is the norm;
   single-account is the degenerate case.

## Net effect

The gap is real and recently re-vacated: the one direct GitOps-IAM
attempt is dead and nothing typed took its place. The survivors are
single-layer, advisory, or SaaS. Nothing occupies "typed, compiled,
drift-reconciled IAM across the org and app layers, in a repo anyone
can PR." Adopt IAMbic's good ideas, avoid its fatal one, integrate the
verification APIs AWS built for exactly this job, and stay out of the
three crowded rooms.
