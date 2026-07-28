# water park — positioning

Derived from the [landscape survey](landscape.md), 2026-07-27.

## The empty box

The landscape sorts into four boxes: a dead direct attempt (IAMbic),
single-layer survivors (org-formation at the org layer; linters and
auditors that advise but don't manage), commercial SaaS (JIT access
brokers, CIEM), and raw cloud primitives (Identity Center, Access
Analyzer, SCP/RCP). water park takes the empty box:

**Your org's access, as a repo everyone can PR.**

Typed, compiled to native artifacts, drift-reconciled, spanning the org
layer and the app layer the org layer usually neglects.

## Three claims

1. **Against the SaaS boxes.** Not a service your access requests route
   through — a repo you own. The write path is a PR, the audit trail is
   git, the approval is a review. No agent, no broker in the credential
   path, no vendor in the blast radius.
2. **Against IAMbic's ghost.** No new format, no vendor lifeline.
   TypeScript in, CloudFormation out, and the export bundle means the
   artifacts outlive the toolchain. Adopting water park does not re-home
   your IAM — the thing that killed the last attempt at this.
3. **Against the advisory tools.** Linters and auditors tell you what's
   wrong. water park is the layer where fixing it is a one-file PR that
   fails in the editor if dangerous, carries a machine-checked
   no-new-access proof on the PR, and gets reconciled if anyone changes it
   out of band.

One line: the pattern that works — one type per file, centralized,
PR-driven — shipped as a repo, with the conventions enforced by the
compiler instead of by a tired reviewer.

## What it deliberately is not

Three adjacent product categories water park stays out of. Definitions,
since the acronyms are everywhere in this space:

- **JIT access** (just-in-time): products that grant temporary, expiring
  cloud permissions on request — an engineer asks (often in Slack), an
  approver clicks, the tool grants a role for two hours and revokes it.
  Apono, Opal, Britive; AWS's own TEAM. water park's break-glass Op covers
  the emergency slice with a durable, git-audited workflow, but does not
  compete on request catalogs and chat UX.
- **CSPM** (cloud security posture management): scanners that continuously
  audit an entire cloud estate against best practices and compliance
  frameworks and report findings — public buckets, unencrypted volumes,
  over-permissive policies. Prowler (open source), Wiz (commercial). water
  park manages what it declares; scanning the other 95% is the auditor's
  job, and chant-audit (chant#350) is the funnel.
- **CIEM** (cloud infrastructure entitlement management): analysis
  products that ingest every identity and policy in an estate and answer
  "who can actually reach what," including indirect privilege-escalation
  paths, then recommend right-sizing. Veza, Tenable, Wiz's entitlement
  module. water park's access-review Op answers reachability over the
  declared graph only — it does not model the whole estate.
- Adjacent but older: **PAM** (privileged access management) — enterprise
  vaults and session brokers for privileged credentials (CyberArk,
  BeyondTrust). Same pain, pre-cloud lineage, sold to enterprises with
  dedicated IAM teams. Not water park's market.

## Ideal customer

A platform or security team of two to ten engineers at a company of
roughly 50–500 engineers. Multi-account AWS with Organizations and
Identity Center. SOC 2 or similar obligations, access reviews currently
done by spreadsheet. App teams blocked on a ticket queue for IAM and SG
changes. The champion is the staff platform engineer who is currently the
human gatekeeper — the consolidation-problem persona. Comfortable in
TypeScript, already doing IaC, and either built the bad internal GUI or is
being pressured to.

Secondary adopters: consultancies and MSPs (managed service providers —
firms that operate cloud infrastructure for many client companies) who can
stamp water park per client. One adopter, many deployments.

Not the target: big enterprise (they have PAM, CIEM, and dedicated IAM
engineering) and tiny startups (one account, three engineers, no pain
yet). The middle is where the pain peaks — big enough to need centralized
control, too small to staff or buy the enterprise stack.

## Market size, honestly

The pain is near-universal: every multi-account AWS org with more than one
team has a version of it, and SOC 2 drags thousands of new B2B companies
into needing an access-review story every year. The crowded commercial JIT
space is demand evidence — the pain funds five-plus venture-backed
companies. Prowler's 14.5k stars show a large population reaching for open
source security tooling. Against the adoption-kit filter, criterion 4
passes harder here than loomster: loomster's ceiling is "people who want
Loom," water park's is "people who have AWS accounts and coworkers."

The narrowing: the population that adopts a repo pattern is smaller than
the population with the pain. SaaS is organizationally easier to buy,
water park demands TypeScript comfort, and security teams are conservative
about the write path to IAM. The realistic wedge is the builder-minded
platform team — the minority that adopted Terraform early, and the same
people who hate the internal GUI they own. Two features soften the
barrier: reference-existing plus ownership markers mean day one touches
nothing, and the loomster property — run it by its verbs, not by knowing
chant — means the security team learns chant, not the whole org.

## Strategic role for chant

IAM is close to the ideal first chant workload: small estates, no
data-plane risk (a role is not a database), incremental by nature, high
organizational visibility. water park is a beachhead — an org's first
contact with chant is the repo their whole engineering staff PRs into.
