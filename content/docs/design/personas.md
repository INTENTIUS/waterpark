---
title: "Design: personas"
---

Gates A4/A5 and Track B. Adopted as the working design and settled as
the set for this estate (decision 41).

## Constraints already decided

- Human personas compile to Identity Center permission sets; workload
  personas to IAM roles. No IAM users, no IAM groups.
- Grant vocabulary is typed access levels (the Policy Sentry model),
  expanded to actions by the module that renders the policy.
- Every grant takes an optional `expires`; expired grants are drift.
- Every role gets the permission boundary, enforced by lint.
- Leaf files stay near-data: a principal file instantiates a persona and
  lists grants, nothing else.

## The archetype set

Four personas, and the set is closed. Adding one is a module release,
not a leaf-file edit.

| Persona | Kind | Compiles to | Sketch |
|---|---|---|---|
| `reader` | human | permission set | read/list across the accounts a team is scoped to, security-tooling read, nothing else |
| `platform` | human | permission set | owns the guardrail path, permissions-management only through the repo |
| `service` | workload | role | app runtime — grants per principal, boundary applied |
| `deployer` | workload | role | CI deploy — write scoped to owned resources, never satellite-declared (decision 36) |

Break-glass is not a persona. It exists only as the break-glass Op's
grant target, and the grant expires cloud-side (decision 37). A larger
org than this one would revisit the set, and the survey that would tell
it what to add is out of scope here.

## Settled, and what is left

1. **The three-org survey is dropped.** This estate is one small org and
   the course is not a product, so the set is what this estate needs
   rather than what three org models share. A larger org would revisit
   it (decision 41).
2. **Team scoping is module parameters**, not per-team permission sets,
   which also keeps clear of the Identity Center caps (decision 41).
3. **`admin` is a trap, and there is no standing one.** Permissions
   management always goes through the repo. The set is `reader`,
   `deployer`, `service` and the `platform` persona that owns the
   guardrail path, and it is closed (decision 41).
4. Still to decide, parked with Track B (decision 19). Cross-cloud
   equivalence: what each archetype compiles to on gcp / azure / k8s /
   code-host legs. Where equivalence is forced, prefer per-leg
   explicitness over a false common denominator. For workloads, a
   SPIFFE ID on the principal is the candidate universal name
   ([design/workload-identity.md](workload-identity.md)); the human half
   remains the hard part.

## Where the estate's principals land

Each principal in [the estate](../estate.md) instantiates one of the
four. `platform` and `course-author` are humans, on the `platform` and
`reader` personas. `site-publisher`, `runner-builder` and
`desk-operator` are workloads, on `service`, with `deployer` for the CI
role that applies.
