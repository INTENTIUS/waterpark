---
title: "Design: delegated role creation (decision 20)"
---

Track C says a satellite declares an SQS queue. Under the layout as
first written, the role that reads it took a second PR in
`pepperoni/access` — the ticket queue the product exists to remove, wearing
a git costume. This doc says satellites create their own workload roles,
and names the mechanism that makes it safe.

## The mechanism was already in the repo

Every role water park emits carries a permission boundary, mandatory and
lint-enforced. A boundary caps what an identity-based policy can grant —
effective permissions are the intersection. AWS lets you condition role
*creation* on it: a policy can permit `iam:CreateRole` /
`iam:PutRolePolicy` only when `iam:PermissionsBoundary` equals a
specific ARN, and deny `iam:DeleteRolePermissionsBoundary` outright. So
a satellite's deploy credential can create roles it cannot make more
powerful than the boundary the central repo owns. **Role creation
decentralizes; authority does not.**

## Two enforcement layers, deliberately redundant

**At build, lint.** `boundary-required` fails a role declared without
the boundary, in the editor, with a fix-it. The fast layer contributors
feel.

**At apply, the cloud.** A satellite that defeats the lint — patched
rules, hand-rolled CloudFormation, a compromised runner — still cannot
create an unbounded role, because IAM refuses the call.

Same layering as break-glass: the convenient layer gives fast
feedback, the cloud layer gives the guarantee. A Terraform shop can
build the second layer and usually does not, because nothing makes the
first one cheap.

## What stays central

| Central (`pepperoni/access`) | Satellite |
|---|---|
| The boundary policy itself | Workload roles inside it |
| Personas | Which persona a workload instantiates |
| Human principals and assignments | Nothing — humans are never satellite-declared |
| The org layer | Nothing |
| Guardrail rules (via context package) | Consumes them |
| The account registry | References its own account |

The line: **a satellite may create identities that act on its own
resources; it may never change what an identity is allowed to be.**
Human access stays central without exception — a permission set's blast
radius is every account it is assigned into, and no boundary analogue
makes delegating it safe. (This is why decision 5's no-IAM-users rule
matters: if humans could get IAM users, a satellite could mint one.)

## The composite is the contract

Satellites do not write `new Role({...})`. The context package exports
`WorkloadRole`, which takes a persona and a grant list and applies the
boundary, ownership marker, and naming itself:

```ts
// pepperoni-payments/src/roles/queue-consumer.ts — the whole file
export default WorkloadRole({
  persona: "service",
  grants: [read(queue), write(deadLetterQueue)],
});
```

A satellite that needs something the composite cannot express is a
central PR, and that is correct — it is a request to change what an
identity may be.

## What this costs

**The boundary becomes a bottleneck.** Too tight and every satellite
files a central PR anyway; too loose and delegation grants more than
intended. Expect it to be the most-revised object in the baseline —
and tightening it can break existing roles at apply time, which lint
will not catch, so guardrail-rollout's warn discipline applies.

**Reachability spans repos.** Either satellites publish a graph
artifact the access review folds in, or A11's evidence states the gap
(the reachability unknown, issues.md).

**Ownership crosses a repo boundary.** A satellite-created role carries
the satellite's marker; central reconcile treats it as foreign, and
each satellite watches its own.

## To decide

1. **Boundary contents.** Lean: deny all IAM write, org and Identity
   Center, guardrail-path resources by name, boundary detachment; allow
   the service surface an app team plausibly needs. Belongs to A6 with
   the apply-role boundary — same mechanism, two tiers.
2. **One boundary or several.** Lean: start with one; split per OU when
   needed.
3. **Cross-repo reachability** — the refs and reachability unknowns
   (issues.md).
4. **Whether `deployer` is delegable.** Lean: no — satellites create
   only `service` roles. Confirm against A18.
5. **Sandbox accounts.** Looser boundary or none for the Sandbox OU.

## Acceptance test (drives C3's AC)

Declare a queue and a `WorkloadRole` that reads it, deploy against
Floci, confirm the boundary. Then strip the boundary and confirm two
independent refusals — lint at build, `iam:PermissionsBoundary` at
apply — with nobody from the platform team involved.
