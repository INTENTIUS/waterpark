---
title: "Demo org: splashdown"
---

The fictional company threaded through the IAM lessons, examples, and
acceptance criteria — and the live session's stage set: the scenarios
below are the source material for the IAM playlist in
[demo.md](demo.md). All names are canonical — use them verbatim.

**splashdown** is a regional water-park operator — a dozen parks, 200 engineers —
on multi-account AWS with Organizations and Identity Center. It sells day
tickets and season passes online and takes card payments, so it carries
SOC 2 and PCI scope — which is why its access story matters and why an
ops audience recognizes it instantly. The platform team owns
the access repo (`splashdown/access`).

## Accounts

| Account | Purpose |
|---|---|
| `splashdown-mgmt` | management account — org policies, Identity Center |
| `splashdown-security` | audit tooling, Access Analyzer, log archive |
| `splashdown-shared` | shared services (ECR, artifacts, DNS) |
| `splashdown-tickets-prod` / `-dev` | tickets team — ticketing, season passes, card payments |
| `splashdown-rides-prod` / `-dev` | rides team — ride status boards and queue times |
| `splashdown-waits-prod` / `-dev` | waits team — queue wait-time prediction |

## Teams and principals

- **platform** — owns `splashdown/access` and
  `@splashdown/waterpark-context`; the security reviewers in CODEOWNERS.
- **tickets** — has the satellite monorepo `splashdown-tickets`
  (lesson I8). Principals: `tickets` (human team),
  `tickets-api` (workload service), `tickets-deployer` (workload
  deployer).
- **rides** — central-repo-only, no satellite; shows the pattern works
  without one. Principals: `rides`, `rides-board`.
- **waits** — files the break-glass request in scenario 3.

## Canonical scenarios

1. **The PR** — a tickets engineer adds S3 read access for
   `tickets-api` by editing one file in `splashdown/access`; lint
   passes, CheckNoNewAccess renders on the PR, platform+tickets
   CODEOWNERS approve, merge applies.
2. **The drift** — someone hand-widens `tickets-prod` SG ingress in
   the console; watch flags it within a cycle, reconcile opens the PR.
3. **The heatwave** — waits' on-call needs prod access at noon on the
   hottest Saturday of the season, gates open; break-glass Op grants with a 2h cloud-side TTL, revokes,
   everything in the audit trail.
4. **The departure** — a rides engineer leaves; offboard removes every
   leg in one run.
5. **The satellite** — `splashdown-tickets` declares an SQS queue *and
   the workload role that reads it* inside the guardrails; stripping
   the boundary is refused twice — lint at build,
   `iam:PermissionsBoundary` at apply — with no platform involvement
   either time.
6. **The request** — a tickets engineer asks the concierge in plain
   language: "tickets-api needs read on the receipts bucket."
   `wp-request` authors the one-file edit; the requester gets the PR
   link with the access delta rendered, then the applied confirmation
   with its provenance sha. Scenario 1's mechanism, entered from a
   sentence. Two variants matter as much: an unmapped intake identity
   gets a refusal naming the enrollment route and no PR (decision 17),
   and a boundary exception gets a directed refusal pointing at the
   platform escalation path.
