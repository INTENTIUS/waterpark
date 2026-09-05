---
title: "Design: delegated role creation (decision 20)"
---

A satellite declares a resource of its own, say the registry the sandbox
runner image is pushed to. Under the layout as first written, the role
that pushes to it took a second PR in the access repo, which is the ticket
queue this pattern exists to remove wearing a git costume. This doc says
satellites create their own workload roles, and names the mechanism that
makes it safe.

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
rules, hand-rolled HCL, a compromised runner, still cannot
create an unbounded role, because IAM refuses the call.

Same layering as break-glass: the convenient layer gives fast
feedback, the cloud layer gives the guarantee. A Terraform shop can
build the second layer and usually does not, because nothing makes the
first one cheap.

## What stays central

| Central (the access repo) | Satellite |
|---|---|
| The boundary policy itself | Workload roles inside it |
| Personas | Which persona a workload instantiates |
| Human principals and assignments | Nothing — humans are never satellite-declared |
| The org layer | Nothing |
| Guardrail rules (via the shared module) | Consumes them |
| The account registry | References its own account |

The line: **a satellite may create identities that act on its own
resources; it may never change what an identity is allowed to be.**
Human access stays central without exception — a permission set's blast
radius is every account it is assigned into, and no boundary analogue
makes delegating it safe. (This is why decision 5's no-IAM-users rule
matters: if humans could get IAM users, a satellite could mint one.)

## The composite is the contract

Satellites do not write a raw `aws_iam_role`. The shared module exports
`workload_role`, which takes a persona and a grant list and applies the
boundary, the ownership marker and the naming itself.

```hcl
# waterpark-runner/iam_role.runner_builder.tf, the whole file
module "runner_builder" {
  source  = "waterpark/workload-role/aws"
  version = "~> 1.2"

  persona = "service"
  grants  = [local.push_registry, local.read_artifacts]
}
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

**Reachability spans repos.** The access review answers that by reading
the live account instead of the declared HCL, so a role a satellite
created is in the evidence whoever declared it (decision 42).

**Ownership crosses a repo boundary.** A satellite-created role carries
the satellite's marker; central reconcile treats it as foreign, and
each satellite watches its own.

## Decided

1. **Boundary contents.** It denies all IAM write, Organizations and
   Identity Center, the guardrail-path resources by name, and boundary
   detachment, and it allows the service surface an app team plausibly
   needs. It sits with the apply-role boundary in A6, one mechanism at
   two tiers (decision 36).
2. **One boundary, not several.** One policy covers the whole estate,
   and splitting per OU waits until an OU needs it (decision 36).
3. **Cross-repo reachability.** The access review reads the live
   account rather than any satellite's HCL, so a satellite-created role
   shows up whoever declared it. The question does not need an answer
   (decision 42).
4. **`deployer` is not delegable.** A satellite creates only `service`
   roles (decision 36).
5. **Sandbox accounts.** The Sandbox OU carries no boundary, because
   sandboxes exist to be broken (decision 36).

## Acceptance test (drives C3's AC)

Declare a queue and a `WorkloadRole` that reads it, deploy against
Floci, confirm the boundary. Then strip the boundary and confirm two
independent refusals — lint at build, `iam:PermissionsBoundary` at
apply — with nobody from the platform team involved.
