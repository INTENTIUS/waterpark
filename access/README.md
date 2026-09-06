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
  github/        branch protection and the required check, live only
  baseline/      the estate boundary, and the constants later lessons read
  modules/
    persona/     the four archetypes a principal file instantiates
  backends/      the two backend files, one of which is copied into an env
  scripts/       backend, check, and the lesson 6 to 8 scripts below
  codeowners.map team name to GitHub handle, the one place the two meet
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
`s3_bucket.waterpark_artifacts.tf`. The prefix comes off whichever provider
it is, so `github_branch_protection.main` lives in
`branch_protection.main.tf`. The rule lists the prefixes it knows rather than
guessing, because a type whose first word happens to look like a provider
would otherwise get a name nobody could predict.

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
and `just access-check` is a thin wrapper over it. It takes `fmt`,
`validate`, `lint`, `fixtures`, `codeowners`, `workflow` or `plan` to run one
stage. The `plan` stage runs the credential-free plan against Floci and says
so and moves on when Floci is not up.

That stage takes one option, `--plan-mode`, and it decides what a plan that
is not empty means. On a laptop, the default, Floci already holds the applied
estate, so a diff is something nobody applied and the stage fails until it is
applied. In CI the account is a container the job filled from the base branch
minutes earlier, so a diff is the change the pull request proposes and the
stage records it and stays green. The workflow passes
`access/scripts/check --plan-mode ci`; `ACCESS_PLAN_MODE=ci` does the same.

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
| `boundary-required` | error | a role, or a principal file that makes one, with no `permissions_boundary` |
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

## Lesson 6, one path to prod

The PR is the only way in, and after this lesson that is a fact about the
repository rather than a rule people follow.

```
.github/
  workflows/
    access.yml   the pr job and the apply job, and nothing else writes
  CODEOWNERS     generated, never authored
access/
  codeowners.map        team name to GitHub handle
  github/               branch protection as code, live only
  envs/prod/
    iam_openid_connect_provider.actions.tf   the trust anchor
    iam_role.waterpark_apply.tf              the role the job federates into
  scripts/
    gen-codeowners      emit .github/CODEOWNERS from the principal files
    render-delta        plan JSON to the semantic access delta
    proofs              Access Analyzer, when it answers
    plan-digest         the digest approval binds to
    prove-no-detach     prescription 7, run against Floci
```

### The two jobs

`pr` runs on `pull_request`. It starts Floci as a service container in its
own job, installs terraform and tflint, runs `access/scripts/check`, saves a
plan, renders the access delta, runs the proofs, and writes the delta, the
proof verdict and the plan digest to the job summary. It names no secret and
asks for no `id-token`, so there is no credential a fork PR can reach.

`apply` runs on push to main. It starts its own Floci, replans, recomputes
the digest, compares it against the digest the PR job recorded, refuses on a
mismatch, and otherwise applies the saved plan. It carries
`if: github.event_name == 'push'`, so it never runs on a pull request at all.

The whole path needs no AWS account, because both jobs talk to a Floci
service container in the same runner (decision 51). What that path proves is
the digest check, not a cloud apply, and the lesson says so.

### The account each job plans against

A plan is a diff against an account, so a job that plans against the wrong
account is reviewing the wrong thing. Your Floci holds the estate you applied
in lesson 4, and a plan there is the change your branch proposes. A CI job's
Floci is a container that started a minute ago and holds nothing, and a plan
against that is the whole estate, every resource a create, whoever opened the
pull request and whatever they touched. A root that reads a central
identifier live instead of out of a state file (decision 50) is blunter about
it: it errors outright when the thing it reads has never been applied.

So each job builds the account it is supposed to review against, before it
plans anything. It checks the base commit out into a temporary worktree,
applies `envs/prod` and then every satellite there, and copies the
`terraform.tfstate` each apply produced into the matching root directory of
the tree under review. The committed backend is `local` with
`path = "terraform.tfstate"`, so the file in a root directory is exactly what
that backend reads; the state travels as that file rather than through a
`-state` flag, which means every later command in the job, `check`'s plan
stage included, sees the base estate with nothing to remember.

The `pr` job applies `github.event.pull_request.base.sha` and plans the head.
The `apply` job applies the merged pull request's own base sha and plans the
merge commit. Same base, same tree, so the two digests match by construction
and a mismatch means something really moved.

Every root the job knows about gets planned. The digest covers `envs/prod`,
because `envs/prod` is what the apply job applies. A satellite root, once
lesson 8 adds one, is planned beside it, so a pull request that breaks the
delegation contract fails in CI rather than in somebody's lesson.

### The digest, and how it reaches the apply job

Two honest mechanisms were on the table. The digest could live in a file the
PR itself commits, which makes the approved digest part of the reviewed diff.
That was rejected, because a digest over a plan is a digest over a plan
against a particular account, and a student whose Floci already holds the
estate computes a different one from CI, whose Floci is empty. The file would
be wrong for everyone who ran the lesson.

So the digest travels with the plan that produced it. The `pr` job uploads
`plan.json` and `plan.digest` as an artifact named
`access-plan-<head sha>`. The `apply` job asks the API which pull request
this merge commit closed, takes that PR head sha, finds the successful run of
this workflow on that sha, downloads the artifact by that name, and compares.
No artifact and no match both mean refuse.

`access/scripts/plan-digest` is what both jobs run. It hashes a normalised
reading of the plan, meaning the resource changes sorted by address with the
timestamp and the prior state dropped, so the same plan against the same
estate gives the same digest and any change to what would be created,
changed or destroyed gives a different one.

### CODEOWNERS is generated

`access/scripts/gen-codeowners` reads the `teams` list out of every principal
file, maps each team name to a GitHub handle through `access/codeowners.map`,
and emits `.github/CODEOWNERS`. The guardrail paths, which are `baseline/`,
`.tflint.d/`, `scripts/`, `codeowners.map`, `github/`, the workflow and
CODEOWNERS itself, route to `@INTENTIUS/platform` by rule and sit last in the
file so they win.

Team names in a leaf file are estate names rather than GitHub handles,
because a team outlives a code host. `codeowners.map` is the one place the
two vocabularies meet, and a team named in a principal file and missing from
the map is a hard failure rather than a silent route to nobody.

`access/scripts/check codeowners` fails when the committed file differs from
the generated one, which is what makes a hand edit to the routing visible.

```sh
access/scripts/gen-codeowners            # write it
access/scripts/gen-codeowners --check    # what CI runs
```

### The fork-PR property, as a test

```sh
access/scripts/check workflow
```

It reads `.github/workflows/access.yml`, treats every job not gated to
`push` as reachable from a pull request, and fails when such a job names
`secrets.` or asks for `id-token: write`. Those are the two ways a cloud
credential could get into a job an untrusted author triggers, and this is
prescription 6's check.

`GITHUB_TOKEN` is a different thing and the `pr` job uses it as
`github.token`. On a fork PR GitHub issues it read-only whatever the workflow
asks, and the job caps itself at `contents: read` besides. The two places the
job wants more, adding the `guardrail-change` label and posting the delta as
a comment, run only when the head branch is in this repository and are
skipped without failing when it is not. The delta always lands in the job
summary, which is the surface that works for everyone.

### The apply role, and a cost named out loud

`waterpark-apply` is declared in `envs/prod` as a `deployer` persona with a
federated trust. It is assumable by the GitHub Actions issuer alone, for
`INTENTIUS/waterpark`, on `refs/heads/main`, with the audience pinned and no
wildcard in the subject, which the persona module refuses. The trust anchor
itself is `aws_iam_openid_connect_provider.actions` beside it, because an
OIDC provider is account scoped and this one belongs to `waterpark-prod`
rather than to the management account `identity/` targets.

It carries the estate boundary, and `access/scripts/prove-no-detach` is the
proof that it cannot take it off.

```sh
terraform -chdir=access/envs/prod apply -auto-approve
access/scripts/prove-no-detach
```

Now the cost. The estate boundary denies all IAM write (decision 36), so
against a real account this role could not apply the estate it exists to
apply. On the taught path that never bites, because the apply job talks to a
Floci service container with the throwaway `test` credentials and never
assumes the role. A real account needs an apply-specific boundary, one that
permits IAM write inside the estate while keeping the detachment and
guardrail-path denies, and that is a second boundary decision 36 has not
taken. The role therefore carries no grants, and the file says why rather
than shipping a policy that the boundary would cancel anyway.

`prove-no-detach` mints a stand-in rather than assuming the role, and it says
so while it runs. Floci honors the trust policy, and there is no web identity
token on a laptop, so the proof creates an IAM user carrying the same
boundary with an allow-everything policy attached, which is the apply role's
shape, and asks that credential to detach a boundary. The user is deleted
when the script exits. Decision 5 bans IAM users from the estate and the rule
pack fails one in HCL. A credential minted for a proof and destroyed at the
end of it is not an estate identity.

### The severity line

A PR touching the rule pack, the baseline, the scripts, `codeowners.map`,
`access/github/`, the workflow or CODEOWNERS is a guardrail change. The `pr`
job writes a high-severity block at the top of the job summary naming the
files, and adds a `guardrail-change` label when the token can. The summary
line is the part that always happens.

### Branch protection

`access/github/` declares protection on `main` with the `pr` job as the
required status check, one required review, code-owner review required, no
force push and no exemption for administrators. It is live only, the same way
`identity/` is, because there is no emulator for a code host. See
[github](github/README.md).
