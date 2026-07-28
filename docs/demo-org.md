# Demo org: flume

The fictional org threaded through docs, examples, and acceptance
criteria, the way loomster's tiers thread through its docs. All names
below are canonical — use them verbatim in ACs and examples.

**flume** is a 200-engineer B2B company on multi-account AWS with
Organizations and Identity Center, carrying SOC 2. The platform team owns
the water park repo (`flume/access`).

## Accounts

| Account | Purpose |
|---|---|
| `flume-mgmt` | management account — org policies, Identity Center, delegated admin only |
| `flume-security` | audit tooling, Access Analyzer, log archive |
| `flume-shared` | shared services (ECR, artifacts, DNS) |
| `flume-payments-prod` / `-dev` | payments team |
| `flume-search-prod` / `-dev` | search team |
| `flume-ml-prod` / `-dev` | ml team |

## Teams and principals

- **platform** — owns `flume/access` and the context package
  `@flume/waterpark-context`; the security reviewers in CODEOWNERS.
- **payments** — has the satellite monorepo `flume-payments` (the Track C
  example repo). Principals: `payments` (human team), `payments-api`
  (workload service), `payments-deployer` (workload deployer).
- **search** — central-repo-only team, no satellite; shows the pattern
  works without one. Principals: `search`, `search-indexer`.
- **ml** — the team that files the break-glass request in the A9 demo.

## Canonical scenarios

1. **The PR** — a payments engineer adds read access to an S3 bucket for
   `payments-api` by editing one file in `flume/access`; lint passes,
   CheckNoNewAccess renders on the PR, platform+payments CODEOWNERS
   approve, merge applies.
2. **The drift** — someone hand-widens `payments-prod` SG ingress in the
   console; watch flags it within a cycle, reconcile opens the PR.
3. **The 3am** — ml's on-call needs prod access during an incident;
   break-glass Op grants with a 2h cloud-side TTL, revokes, everything in
   the audit trail.
4. **The departure** — a search engineer leaves; offboard removes every
   leg in one run.
5. **The satellite** — `flume-payments` declares an SQS queue inside the
   guardrails with one resource file; an open-ingress attempt in that repo
   fails its own CI, no platform involvement.
