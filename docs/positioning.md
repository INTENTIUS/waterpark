# water park — positioning

Derived from the [landscape survey](landscape.md), 2026-07-27.

## The empty box

The landscape sorts into four boxes: a dead direct attempt (IAMbic),
single-layer survivors (org-formation; linters and auditors that advise
but don't manage), commercial SaaS (JIT brokers, CIEM), and raw cloud
primitives. water park takes the empty box:

**Your org's access, as a repo everyone can PR.**

Typed, compiled to native artifacts, drift-reconciled, spanning the org
layer and the app layer the org layer usually neglects.

## Three claims

1. **Against the SaaS boxes.** Not a service your requests route through —
   a repo you own. The write path is a PR, the audit trail is git, the
   approval is a review. Nothing sits in the credential path: no
   connector, no broker holding standing permissions, no vendor in the
   blast radius. (The concierge of [design/agentic.md](design/agentic.md)
   is no exception — it holds no cloud credentials and never touches the
   grant. It writes a file.)
2. **Against IAMbic's ghost.** No new format, no vendor lifeline. Typed
   source in, native artifacts out, and the export bundle means the
   estate outlives the toolchain.
3. **Against the advisory tools.** Linters tell you what's wrong. water
   park is the layer where fixing it is a one-file PR that fails in the
   editor if dangerous, carries a machine-checked no-new-access proof,
   and gets reconciled if changed out of band.

One line: the pattern that works — one type per file, centralized,
PR-driven — shipped as a repo, with the conventions enforced by machinery
instead of by a tired reviewer.

## What it deliberately is not

- **JIT access** (Apono, Opal, Britive, AWS TEAM): temporary
  permissions where the approver's click *is* the grant and the broker
  holds standing permissions. water park takes the intake and refuses
  the write path — a request produces a pull request. Same front door,
  opposite mechanism, and the difference shows on audit day. No
  entitlement catalog: the menu is the repo.
- **CSPM** (Prowler, Wiz): estate-wide posture scanning — the
  chant-audit funnel's job.
- **CIEM** (Veza, Tenable): "who can actually reach what" over every
  identity. water park answers reachability over the declared graph
  only.
- **PAM** (CyberArk, BeyondTrust): pre-cloud credential vaults for
  enterprises. Not the market.

## Ideal customer

A platform or security team of two to ten engineers at a company of
roughly 50–500 engineers. Multi-account AWS with Organizations and
Identity Center. SOC 2 obligations, access reviews done by spreadsheet.
App teams blocked on a ticket queue for IAM changes. The champion is the
staff platform engineer who is currently the human gatekeeper — either
built the bad internal GUI or is being pressured to. Secondary:
consultancies and MSPs who stamp water park per client.

Not the target: big enterprise (has PAM, CIEM, dedicated IAM engineering)
and tiny startups (no pain yet). The middle is where the pain peaks.

## Market size, honestly

The pain is near-universal, and SOC 2 drags thousands of new B2B
companies into needing an access-review story every year; the crowded
commercial JIT space is demand evidence. The narrowing: the population
that adopts a repo pattern is smaller than the population with the
pain. Three things soften the barrier: reference-existing plus
ownership markers mean day one touches nothing; the security team
learns the tool, the org just uses its verbs; and the Terraform backend
(decision 23) meets the majority where their IaC already is.

## Strategic role, revised (decision 25)

water park is currently a seed for the live demo: the wedge is showing
what Fountain can do for an ops crowd, with IAM as the
credibility-maximizing payload. The pattern is the takeaway; chant and
Fountain are what the audience watches working. IAM remains close to
the ideal first chant workload — small estates, no data-plane risk,
high organizational visibility — and if the kit un-parks, this doc's
audience section is where it re-starts. The Terraform backend widens
the funnel without moving the ceiling: chant stays the realization
where the pattern is cheapest.
