# Design: personas (open questions 2 and 9)

Gates A4/A5 and Track B. Not settled. This doc accumulates the design.

## Constraints already decided

- Human personas compile to Identity Center permission sets; workload
  personas compile to IAM roles. No IAM users, no IAM groups.
- Grant vocabulary is typed access levels (the Policy Sentry model:
  read / list / write / tagging / permissions-management per service or
  resource type), expanded to actions at synth.
- Every grant takes an optional `expires`; expired grants are drift.
- Every role gets the permission boundary. No exceptions, enforced by lint.
- Leaf files must stay near-data — a principal file instantiates a persona
  and lists grants, nothing else.

## Candidate archetype set (strawman)

| Persona | Kind | Compiles to | Sketch |
|---|---|---|---|
| `developer` | human | permission set | read/list on team accounts, write on dev, no permissions-management |
| `operator` | human | permission set | developer + operational writes (restart, scale) on prod, no IAM |
| `auditor` | human | permission set | org-wide read/list, security-tooling read, nothing else |
| `admin` | human | permission set | permissions-management inside the boundary, guardrail paths excluded |
| `service` | workload | role | app runtime — grants listed per principal, boundary applied |
| `deployer` | workload | role | CI deploy — write scoped to owned resources, the apply tier in threat-model.md |
| `break-glass` | human | Op-granted | not standing — exists only as the break-glass Op's grant target |

## To validate before settling

1. Survey three org models against the strawman: a 50-eng startup (flat),
   a centralized enterprise (the field-lesson org), a cell-based org
   (account per team). Does the set survive without per-org forks?
2. Where do team-scoped variants live — parameters on the persona
   (`developer(team)`) or per-team permission sets? Identity Center caps
   and assignment mechanics matter here.
3. Is `admin` real or a trap? Maybe permissions-management never gets a
   standing persona and always goes through the repo.
4. Cross-cloud equivalence (open question 9, blocks Track B): what does
   each archetype compile to on gcp (roles/bindings), azure (RBAC role
   assignments, PIM interplay), k8s (RBAC), code hosts (team/repo perms)?
   Where equivalence is forced, prefer per-leg explicitness over a false
   common denominator.

## Current lean

Ship the five personas that survive the survey; keep the set small and
closed at first (adding a persona is a kit release, not a leaf-file edit).
Team scoping via parameters. No standing `admin` beyond guardrail-path
CODEOWNERS.
