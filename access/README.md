# access

The access repo is this repo (decision 33). This directory is the Terraform
root for water park's own AWS estate, the one
[the estate](../content/docs/estate.md) describes. It sits beside `content/`
and `skills/`, so one clone, one PR flow and one CI cover the course and the
estate it manages.

Terraform is the applier (decision 31). Nothing here assembles anything,
because Terraform already loads every `.tf` in a directory as one module.

## The layout

```
access/
  envs/
    prod/        waterpark-prod, the published site and the artifacts bucket
    dev/         waterpark-dev, the same shapes with no traffic, empty for now
  identity/      the human principals, live only, validated on every check
  baseline/      the estate boundary, and the constants later lessons read
  modules/
    persona/     the four archetypes a principal file instantiates
  backends/      the two backend files, one of which is copied into an env
  scripts/       backend, and check, which is the whole check stack
  .tflint.d/
    policies/    the rule pack, as Rego
  tests/
    fixtures/    a failing and a passing case per rule
```

`waterpark-mgmt` and `waterpark-security` are accounts rather than
environments. The management account holds the org layer and Identity Center,
which are live only. The security account holds the Terraform state bucket,
which the backend below points at rather than declares.

## One resource per file, and the path is the index

A file is named `<resource_type>.<label>.tf` with the provider prefix dropped,
and it holds exactly one `resource` block whose address the file name repeats.
`aws_iam_role.site_publisher` lives in `iam_role.site_publisher.tf`.
`aws_s3_bucket.waterpark_artifacts` lives in
`s3_bucket.waterpark_artifacts.tf`.

So a stranger finds a resource by guessing a path, and predicts the file name
from a resource address in a plan. That is the whole index, and it is
prescription 1.

Files that hold no resource block are exempt from the naming rule, which is
how `provider.tf`, `variables.tf`, `versions.tf`, `locals.tf` and
`outputs.tf` keep their conventional names.

## Principals and personas

A principal file is a call to `modules/persona` plus a list of grants and
nothing else, so a new principal is a copied sibling with a few strings
changed (prescription 2). The persona set is `reader`, `platform`, `service`
and `deployer`, and it is closed (decision 41). An unknown persona name fails
`terraform validate` rather than applying something surprising.

`site-publisher`, `runner-builder` and `desk-operator` are workloads and live
in `envs/prod`, each as one `iam_role.<name>.tf` holding one module call.
`platform` and `course-author` are humans and live in `identity/`, which is
live only because Floci runs no Identity Center. See
[modules/persona](modules/persona/README.md) and
[identity](identity/README.md).

The file naming rule reads the same for a module call. A leaf file named
`iam_role.site_publisher.tf` holds the module call that produces
`aws_iam_role.site_publisher`, so the path still predicts the address.

## The boundary

One permission boundary covers the whole estate, and it lives in
[baseline](baseline/README.md) as an `aws_iam_policy` under a deterministic
name (decision 36). Every workload role carries it, applied by
`modules/persona` so no grant restates it, and a leaf file names it once as
`permissions_boundary = module.baseline.boundary_arn`.

A boundary caps what an identity-based policy can grant, because effective
permissions are the intersection of the two. So a role inside the estate
cannot be made more powerful than the boundary says, whatever its own policy
claims, and that is what makes delegating role creation safe in lesson 8.

There are two enforcement layers and they are deliberately redundant. At
build, `boundary-required` fails a role declared without it, in the editor.
At apply, IAM refuses the call. The convenient layer gives fast feedback and
the cloud layer gives the guarantee.

The Sandbox OU carries no boundary at all, because sandboxes exist to be
broken. Pass `sandbox = true` to the baseline module and it emits no policy
and hands back a null ARN.

`baseline` also holds the constants later lessons read, the two hour
break-glass maximum (decision 37) and the watcher's cap of five open PRs
(decision 40), as outputs rather than numbers in a page.

## The checks

```sh
brew install terraform-linters/tap/tflint
just access-init      # once per clone, installs the tflint OPA plugin
just access-check     # fmt, validate, tflint, and the rule fixtures
```

`access/scripts/check` is everything a PR job runs, in the order it runs it,
and `just access-check` is a thin wrapper over it. It takes `fmt`, `validate`,
`lint`, `fixtures` or `plan` to run one stage. The `plan` stage runs the
credential-free plan against Floci and says so and moves on when Floci is not
up.

Three layers. `terraform fmt -check` catches shape, `terraform validate`
catches types and the persona set, and `tflint` catches the rules. Nothing in
the stack needs a credential, which is the credential-free half of
prescription 6.

### The rule pack

The custom rules are Rego, run by
[tflint-ruleset-opa](https://github.com/terraform-linters/tflint-ruleset-opa),
and they live in `.tflint.d/policies`. The OPA ruleset hands a policy the
declaration range of every block, file name included, so the two layout rules
are Rego like the rest rather than a side script.

| Rule | Severity | Fails |
|---|---|---|
| `one-type-per-file` | error | a file holding two `resource` blocks |
| `path-matches-name` | error | a file whose name does not repeat the address inside it |
| `no-wildcard-action` | error | an `Allow` statement whose `Action` carries a `*` |
| `no-inline-policy` | error | `aws_iam_role_policy` and its user and group siblings |
| `no-iam-user-or-group` | error | any IAM user, group, access key or attachment to one |
| `tag-owner-required` | error | a role, policy, bucket, registry or permission set with no `owner` tag |
| `boundary-required` | error | a role with no `permissions_boundary` |
| `no-open-ingress` | warning | an ingress rule naming `0.0.0.0/0` or `::/0` |
| `sg-reference-not-cidr` | warning | an ingress rule naming a raw CIDR instead of a source group |

Severity is the function-name prefix in the Rego, `deny_` for an error and
`warn_` for a warning, so a new rule lands as a warning and is promoted in a
later lesson once the estate conforms (decision 9). `boundary-required` is
the worked example. It landed as a warning in lesson 3, because the boundary
it asks for did not exist yet, and lesson 5 promoted it to an error once
every role carried one. The promotion is the one-word edit from `warn_` to
`deny_` in `security.rego` plus the matching line in `scripts/check`.
`no-open-ingress` and `sg-reference-not-cidr` stay warnings because the
estate declares no security groups yet, so there is nothing live for them to
ratchet against.

`no-wildcard-action` skips a policy tagged `guardrail = "boundary"`, because
a boundary is a ceiling rather than a grant and a wildcard there narrows the
estate instead of widening it. The exemption is a tag rather than a name
match, so it is deliberate and greppable, and it has its own passing fixture.

Every rule has a failing and a passing fixture under `tests/fixtures`, and
`check fixtures` runs each pair with `--only` set to that one rule, so a
fixture proves its own rule and nothing else.

### In the editor

`tflint --langserver` is the language server that carries these rules, and it
is a separate process from `terraform-ls`, which serves `validate` and
completion. An editor that runs both gets the same diagnostics this script
prints, on the same rule ids, before the commit.

## State and the two backends

Terraform hosts a state file, which is exactly what Accessible Ops XI warns
about, and the course names that cost out loud rather than hiding it
(decision 32). State is bookkeeping and never the system of record, every
read of the estate in these lessons goes to the cloud instead, and the drift
watch compares declared against live.

There are two backends and exactly one is present in an env directory at a
time, because Terraform allows one backend block per root module.

- `backend.local.tf` keeps state in the env directory. This is what ships
  checked in, so a fresh clone runs `terraform init` with no AWS account, no
  credentials and no bucket to create first. It is the solo path.
- `backends/backend.s3.tf` puts state in the `waterpark-terraform-state`
  bucket in `waterpark-security`, encrypted, with `use_lockfile` for locking.
  It is the live path.

Swap between them with

```sh
access/scripts/backend s3 envs/prod
terraform -chdir=access/envs/prod init -reconfigure
```

and back with `access/scripts/backend local envs/prod`.

The provider lock file is not committed, because a lock file records provider
hashes for the platforms it was generated on and students run this on three
of them.

## Floci or a real account

One variable picks the target. `floci` defaults to `true`, which points the
provider's `iam`, `sts` and `s3` endpoints at `http://localhost:4566`, hands
it the throwaway `test` key pair and skips every call that would resolve a
real account. The live path passes `-var floci=false` and the same code talks
to `waterpark-prod`.

## Deploy to Floci

Floci runs the AWS APIs in process, so the Terraform is real, the IAM is real
and the account is not. Use the patched image, which fixes the two permission
boundary bugs the upstream one has (see
[upstream](../project/upstream.md)). Start it, apply, and prove the estate
converged.

```sh
docker run -d --name wp-access-floci -p 4566:4566 \
  -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
  ghcr.io/lex00/floci:iam-boundary

terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod apply -auto-approve
terraform -chdir=access/envs/prod plan -detailed-exitcode
```

The third command is the check. `-detailed-exitcode` exits 0 for no changes,
2 for a diff and 1 for an error, so a green apply that has not converged is
caught rather than believed.

Read a role back from the cloud rather than from state, and it matches the
file that declared it.

```sh
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 \
  aws --endpoint-url http://localhost:4566 iam get-role --role-name site-publisher
```

`RoleName`, `Description`, the `owner` and `persona` tags, the trust policy
and the `PermissionsBoundary` block all come back as
`iam_role.site_publisher.tf` and `modules/persona` wrote them. The boundary
reading back is the fact that fails on the upstream Floci image and passes on
the patched one, and it is why a bounded estate can reach a clean plan on a
laptop.

When you are done.

```sh
terraform -chdir=access/envs/prod destroy -auto-approve
docker rm -f wp-access-floci
```

Two things Floci cannot show. It runs no Organizations and no Identity
Center, which is why the human principals in `identity/` are live only, and
it runs no Access Analyzer, so the `validate-policy` proofs are live only
too. A failed apply also stops where it failed and leaves behind what it
already made, with no rollback, which is why a change lands as a small plan
rather than a big one.
