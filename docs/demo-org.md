# Demo org: flume

The fictional org threaded through docs, examples, and acceptance
criteria. All names are canonical — use them verbatim.

**flume** is a 200-engineer B2B company on multi-account AWS with
Organizations and Identity Center, carrying SOC 2. The platform team
owns the water park repo (`flume/access`).

## Accounts

| Account | Purpose |
|---|---|
| `flume-mgmt` | management account — org policies, Identity Center |
| `flume-security` | audit tooling, Access Analyzer, log archive |
| `flume-shared` | shared services (ECR, artifacts, DNS) |
| `flume-payments-prod` / `-dev` | payments team |
| `flume-search-prod` / `-dev` | search team |
| `flume-ml-prod` / `-dev` | ml team |

## Teams and principals

- **platform** — owns `flume/access` and `@flume/waterpark-context`;
  the security reviewers in CODEOWNERS.
- **payments** — has the satellite monorepo `flume-payments` (the
  Track C example). Principals: `payments` (human team), `payments-api`
  (workload service), `payments-deployer` (workload deployer).
- **search** — central-repo-only, no satellite; shows the pattern works
  without one. Principals: `search`, `search-indexer`.
- **ml** — files the break-glass request in the A9 demo.

## Canonical scenarios

1. **The PR** — a payments engineer adds S3 read access for
   `payments-api` by editing one file in `flume/access`; lint passes,
   CheckNoNewAccess renders on the PR, platform+payments CODEOWNERS
   approve, merge applies.
2. **The drift** — someone hand-widens `payments-prod` SG ingress in
   the console; watch flags it within a cycle, reconcile opens the PR.
3. **The 3am** — ml's on-call needs prod access during an incident;
   break-glass Op grants with a 2h cloud-side TTL, revokes, everything
   in the audit trail.
4. **The departure** — a search engineer leaves; offboard removes every
   leg in one run.
5. **The satellite** — `flume-payments` declares an SQS queue *and the
   workload role that reads it* inside the guardrails; stripping the
   boundary is refused twice — lint at build, `iam:PermissionsBoundary`
   at apply — with no platform involvement either time.
6. **The request** — a payments engineer asks the concierge in plain
   language: "payments-api needs read on the invoices bucket."
   `wp-request` authors the one-file edit; the requester gets the PR
   link with the access delta rendered, then the applied confirmation
   with its provenance sha. Scenario 1's mechanism, entered from a
   sentence. Two variants matter as much: an unmapped intake identity
   gets a refusal naming the enrollment route and no PR (decision 17),
   and a boundary exception gets a directed refusal pointing at the
   platform escalation path.
