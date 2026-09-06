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

## Grants

A grant is a typed access level against a resource with an optional expiry
and a reason, not a list of actions. The module expands `read`, `list` and
`write` into actions and ARNs, so widening a level is one edit here.

An expiry becomes a `DateLessThan` condition on `aws:CurrentTime` in the
policy document, which the cloud enforces whether or not any job runs, plus
an `expires` tag carrying the same date so a read of the estate can see it
without parsing the policy. An expired grant is drift, which lesson 7 picks
up.
