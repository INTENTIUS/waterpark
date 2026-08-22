---
title: "Demo org: pepperoni"
---

The fictional company threaded through the IAM lessons, examples, and
acceptance criteria — and the live session's stage set: the scenarios
below are the source material for the IAM playlist in
[demo.md](demo.md). All names are canonical — use them verbatim.

**pepperoni** is a 200-engineer pizza-delivery company on multi-account
AWS with Organizations and Identity Center. It takes card payments, so
it carries SOC 2 and PCI scope — which is why its access story matters
and why an ops audience recognizes it instantly. The platform team owns
the access repo (`pepperoni/access`).

## Accounts

| Account | Purpose |
|---|---|
| `pepperoni-mgmt` | management account — org policies, Identity Center |
| `pepperoni-security` | audit tooling, Access Analyzer, log archive |
| `pepperoni-shared` | shared services (ECR, artifacts, DNS) |
| `pepperoni-payments-prod` / `-dev` | payments team — card processing |
| `pepperoni-search-prod` / `-dev` | search team — store and menu search |
| `pepperoni-ml-prod` / `-dev` | ml team — delivery ETA prediction |

## Teams and principals

- **platform** — owns `pepperoni/access` and
  `@pepperoni/waterpark-context`; the security reviewers in CODEOWNERS.
- **payments** — has the satellite monorepo `pepperoni-payments`
  (lesson I8). Principals: `payments` (human team),
  `payments-api` (workload service), `payments-deployer` (workload
  deployer).
- **search** — central-repo-only, no satellite; shows the pattern works
  without one. Principals: `search`, `search-indexer`.
- **ml** — files the break-glass request in scenario 3.

## Canonical scenarios

1. **The PR** — a payments engineer adds S3 read access for
   `payments-api` by editing one file in `pepperoni/access`; lint
   passes, CheckNoNewAccess renders on the PR, platform+payments
   CODEOWNERS approve, merge applies.
2. **The drift** — someone hand-widens `payments-prod` SG ingress in
   the console; watch flags it within a cycle, reconcile opens the PR.
3. **The 3am** — ml's on-call needs prod access during a delivery-eve
   incident; break-glass Op grants with a 2h cloud-side TTL, revokes,
   everything in the audit trail.
4. **The departure** — a search engineer leaves; offboard removes every
   leg in one run.
5. **The satellite** — `pepperoni-payments` declares an SQS queue *and
   the workload role that reads it* inside the guardrails; stripping
   the boundary is refused twice — lint at build,
   `iam:PermissionsBoundary` at apply — with no platform involvement
   either time.
6. **The request** — a payments engineer asks the concierge in plain
   language: "payments-api needs read on the invoices bucket."
   `wp-request` authors the one-file edit; the requester gets the PR
   link with the access delta rendered, then the applied confirmation
   with its provenance sha. Scenario 1's mechanism, entered from a
   sentence. Two variants matter as much: an unmapped intake identity
   gets a refusal naming the enrollment route and no PR (decision 17),
   and a boundary exception gets a directed refusal pointing at the
   platform escalation path.
