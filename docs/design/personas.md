# Design: personas

Gates A4/A5 and Track B. Adopted as the working design; the org-model
survey (item 1) can amend the set before it ships.

## Constraints already decided

- Human personas compile to Identity Center permission sets; workload
  personas to IAM roles. No IAM users, no IAM groups.
- Grant vocabulary is typed access levels (the Policy Sentry model),
  expanded to actions at synth.
- Every grant takes an optional `expires`; expired grants are drift.
- Every role gets the permission boundary, enforced by lint.
- Leaf files stay near-data: a principal file instantiates a persona and
  lists grants, nothing else.

## Candidate archetype set

| Persona | Kind | Compiles to | Sketch |
|---|---|---|---|
| `developer` | human | permission set | read/list on team accounts, write on dev, no permissions-management |
| `operator` | human | permission set | developer + operational writes on prod, no IAM |
| `auditor` | human | permission set | org-wide read/list, security-tooling read |
| `admin` | human | permission set | permissions-management inside the boundary, guardrail paths excluded |
| `service` | workload | role | app runtime — grants per principal, boundary applied |
| `deployer` | workload | role | CI deploy — write scoped to owned resources |
| `break-glass` | human | Op-granted | not standing — exists only as the break-glass Op's grant target |

## To validate before settling

1. Survey three org models (flat startup, centralized enterprise,
   cell-based org) — does the set survive without per-org forks?
2. Team-scoped variants: parameters on the persona vs per-team
   permission sets. Identity Center caps matter here.
3. Is `admin` real or a trap? Maybe permissions-management never gets a
   standing persona and always goes through the repo.
4. Cross-cloud equivalence (open question 9, blocks Track B): what each
   archetype compiles to on gcp / azure / k8s / code-host legs. Where
   equivalence is forced, prefer per-leg explicitness over a false
   common denominator. For workloads, a SPIFFE ID on the principal is
   the candidate universal name
   ([design/workload-identity.md](workload-identity.md)); the human half
   remains the hard part.

## Current lean

Ship the personas that survive the survey; keep the set small and closed
(adding a persona is a kit release, not a leaf-file edit). Team scoping
via parameters. No standing `admin` beyond guardrail-path CODEOWNERS.
