# modules/persona

A principal file is a call to this module plus a list of grants and nothing
else (prescription 2). The module carries the complexity, so a first-time
contributor copies a sibling file, changes a few strings, and gets it right.

The persona set is four and it is closed (decision 41).

| Persona | Kind | Compiles to |
|---|---|---|
| `reader` | human | permission set, read and list across the accounts a team is scoped to |
| `platform` | human | permission set, owns the guardrail path |
| `service` | workload | role, app runtime, grants per principal |
| `deployer` | workload | role, CI deploy, never satellite-declared |

An unknown persona name fails `terraform validate` rather than applying
something surprising, because `persona` carries a `validation` block naming
the four.

## Humans are live only on the solo path

`reader` and `platform` compile to `aws_ssoadmin_permission_set` and
`aws_ssoadmin_account_assignment`, and Floci runs no Identity Center. So the
module refuses a human persona unless the root sets `identity_center = true`,
and the human principals live in `access/identity/`, which is validated on
every check but applied only against a real account. That is prescription 3
standing as written rather than being softened for the emulator.

## The boundary is applied here

Every workload role the module makes carries `permissions_boundary`, so a
grant never restates it and no leaf file can forget it. The ARN comes from
`access/baseline`, which is one boundary for the whole estate (decision 36).
It is null only in a sandbox, which carries no boundary at all.

## Two trust shapes

A workload role is trusted either by service principal or by a declared OIDC
provider, and nothing in the module lets it be both. `trusted_services` is
the default and is what a role running inside AWS uses. `federated_trust` is
what a job running outside AWS uses, and it takes the provider ARN, the
issuer host, the audience and the exact subjects.

The subject is spelled out rather than matched, and the module refuses a `*`
in one, because a wildcard `sub` claim trusts every repository the issuer
serves rather than the one workload it was meant for. The issuer host is a
field rather than a slice of the provider ARN, because the ARN is not known
until the provider is created and a trust policy that reads "known after
apply" is a trust policy nobody reviewed.

The apply role in lesson 6 is the worked example. Federation trust in general
is lesson 9.

## Grants

A grant is a typed access level against a resource with an optional expiry
and a reason, not a list of actions. The module expands `read`, `list`,
`write` and `push` into actions and ARNs, so widening a level is one edit
here.

`push` arrived in lesson 8, because a satellite that declares its own
registry needs a level that means it and a satellite writing raw actions
would be a leaf file that is no longer near-data. It carries one action the
service refuses to scope to a resource, `ecr:GetAuthorizationToken`, which
mints the registry login and is account wide by the API's own design. That
lands as a second statement rather than as a wildcard smuggled into the
first. Every level with nothing account wide renders exactly the one
statement it always did, so no existing policy moved when `push` was added.

An expiry becomes a `DateLessThan` condition on `aws:CurrentTime` in the
policy document, which the cloud enforces whether or not any job runs, plus
an `expires` tag carrying the same date so a read of the estate can see it
without parsing the policy. An expired grant is drift, which lesson 7 picks
up.

## Break-glass

A grant with a `granted_at` is a break-glass grant (decision 60). It needs
an `expires` no more than `break_glass_max_ttl_hours` later and a `reason`,
and the module refuses anything else at plan. The policy it renders carries
the same `DateLessThan aws:CurrentTime` condition every expiring grant
does, plus `break_glass`, `granted_at` and `approved_by` tags. The apply job
writes `approved_by` after the apply, from the merged pull request's
approving review, and the module ignores that one tag on the next plan.
`access/scripts/break-glass` writes and revokes the block, so nobody types
the timestamps.

A human persona's grants render as the permission set's inline policy, live
only, which is how the same grant lands on the on-call's permission set
rather than on a role.
