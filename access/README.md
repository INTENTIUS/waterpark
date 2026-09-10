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
  satellites/
    waterpark-runner/   the satellite, its registry and the role that pushes
  baseline/      the estate boundary, and the constants later lessons read
  modules/
    persona/     the four archetypes a principal file instantiates
  backends/      the two backend files, one of which is copied into an env
  scripts/       backend, check, and the lesson 6 to 11 scripts below
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

`site-publisher`, `desk-operator` and `waterpark-apply` are workloads and
live in `envs/prod`, each as one `iam_role.<name>.tf` holding one module
call. `runner-builder` is a workload too and lives in
`satellites/waterpark-runner`, because the satellite declares the registry
and the role that pushes to it. `platform` and `course-author` are humans and
live in `identity/`, which is live only because Floci runs no Identity
Center. See [modules/persona](modules/persona/README.md),
[identity](identity/README.md) and
[satellites/waterpark-runner](satellites/waterpark-runner/README.md).

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
| `trust-subject-pinned` | error | a federated trust with no subject condition, a subject matched by pattern, or a subject carrying a wildcard |
| `trust-audience-pinned` | error | a federated trust with no `StringEquals` audience, or an OIDC provider that lists no client id or is not https |
| `break-glass-ttl` | error | a grant with a `granted_at` and no `expires` or `reason`, or an expiry more than the baseline TTL after it |

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
timestamp and the prior state dropped, and on an update in place only the
attributes that differ from before, so the same plan against the same
estate gives the same digest and any change to what would be created,
changed or destroyed gives a different one. The reduction on updates was
learned from the first in-place change the pipeline merged, lesson 9's trust
change, which the apply job refused because a role's `create_date` and
`unique_id` had been copied into the after-value from a container that no
longer existed.

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

## Lesson 7, drift

The estate is what the account holds, not what the repo says, and the gap
between the two has a name.

```
.github/
  workflows/
    drift.yml    weekdays at 06:00 UTC, and on demand
access/
  scripts/
    drift        declared against live, over every root that applies
    reconcile    a drift report to reconcile PRs, under Rounds rules
    README.md    the asymmetry, and where each rule is enforced
```

`drift` runs `terraform plan -detailed-exitcode` over every root that
applies, which is `envs/prod` and any satellite root that exists. Exit 0
means every root matches, exit 2 means at least one moved, and exit 1 means
the watch itself broke, which is a different thing and is reported as such.
`identity/` and `github/` are not on the list, because there is nothing on a
laptop for them to have drifted from.

The plan JSON is read down to resources and attributes, so a finding names
the attribute and prints what the repo declares beside what the account
holds. Expired grants come through the same run, read from the persona
module's `grants` output, because a grant whose `DateLessThan` has passed
grants nothing while the repo still says it exists.

Severity routes on blast radius. A security group or a changed
`assume_role_policy` is `page`, because a widened group is reachable the
moment it lands and a changed trust policy changes who may become a principal,
which revoking a grant cannot undo. Everything else is `pr`.

### The walkthrough

Start from an applied estate.

```sh
terraform -chdir=access/envs/prod apply -auto-approve
access/scripts/drift
```

That exits 0 and says every watched root matches. Now move the account
underneath it, the way a person in a console would.

```sh
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1

aws --endpoint-url http://localhost:4566 iam detach-role-policy \
  --role-name site-publisher \
  --policy-arn arn:aws:iam::000000000000:policy/site-publisher-read-waterpark-artifacts

aws --endpoint-url http://localhost:4566 iam tag-role \
  --role-name runner-builder --tags Key=owner,Value=intruder
```

Run the watch again.

```sh
access/scripts/drift
echo $?
```

Exit 2, and two findings. The detached policy comes back as an attachment
that will be created, with `policy_arn` declared and `absent` live. The
retagged role comes back as an update on `tags`, with `owner` reading
`platform` in the repo and `intruder` in the account. Both are `pr`, because
neither is a security group or a trust policy.

Then the reconcile plan.

```sh
access/scripts/reconcile --dry-run
```

One PR per resource, so two here, each on a branch derived from the resource
address, neither of them opened. The dry run is the default and it says so at
the end. `--open` with an authenticated `gh` is what files them.

Widen a trust policy instead and watch the routing change.

```sh
aws --endpoint-url http://localhost:4566 iam update-assume-role-policy \
  --role-name desk-operator \
  --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"*"},"Action":"sts:AssumeRole"}]}'

access/scripts/drift --json | jq -c '.findings[] | {severity, address}'
access/scripts/reconcile --dry-run
```

The trust finding is `page` and `reconcile` refuses to file it as paperwork.
It prints it for a human instead.

Put the account back.

```sh
terraform -chdir=access/envs/prod apply -auto-approve
access/scripts/drift
```

### What the scheduled job proves, and what it does not

`.github/workflows/drift.yml` runs weekdays at 06:00 UTC, the same cron the
desk teammate runs on, and on demand. It starts an empty Floci, applies the
estate into it, and asks whether the estate matches. It always does, because
nothing else has touched that container. So a green run means the declared
estate converges and stays converged, and it means nothing about a real
account, where drift comes from a human in a console. The lesson seeds the
drift by hand for exactly that reason, and the job says so in its own
summary.

### Restoring is automatic, adopting is not

A reconcile PR carries no file change. The repo already says what the
resource should be, so merging it is what runs the apply that puts the
account back. If the change in the account was the right one, the PR is not
merged and a human edits the file that declares the resource. That
asymmetry is deliberate and it is written out in
[scripts](scripts/README.md).

## Lesson 8, delegation and the double refusal

A satellite creates its own roles and cannot make them more powerful than the
estate allows, and the way you know is that stripping the boundary gets
refused twice by two things that have never heard of each other.

```
access/
  satellites/
    waterpark-runner/
      README.md
      .tflint.hcl                        the central rule pack, pinned
      data.tf                            the boundary, read live by name
      ecr_repository.waterpark_runner.tf the registry
      iam_role.runner_builder.tf         the whole leaf file
      provider.tf  variables.tf  locals.tf  outputs.tf  versions.tf
      backend.local.tf
  .tflint.d/README.md                    warn-minor and error-major, as tags
  scripts/
    satellite-source            swap the module source, local or pinned
    mint-satellite-credential   the deploy credential, on Floci
    double-refusal              strip the boundary, get refused twice
```

`runner-builder` moved here from `envs/prod`. estate.md says the satellite
declares the registry and the role that pushes to it, and lessons 1 to 5 are
tagged checkpoints of the tree as it was, so nothing earlier breaks.

### The module, and why it is persona rather than a wrapper

Decision 10 named a `workload_role` module. It is `modules/persona`, because
a wrapper forwarding a dozen variables is a dozen variables declared twice
and the wrapper enforces no rule that the boundary and the rule pack do not
already enforce. The workload half of the persona set is the workload role
module, and `deployer` is not delegable, so a satellite passes `service`.

### How the satellite gets central identifiers

By name, read live. `data.tf` looks the boundary up by its deterministic
name, so the satellite gets the boundary that exists rather than the one a
file claims exists, and a satellite planning before central applied fails
loudly instead of creating an unbounded role. `terraform_remote_state` is
refused, because it would hand every satellite read access to central state,
which is bookkeeping and never the system of record.

### The module source, local and pinned

The pinned form is decision 50.

```
git::https://github.com/INTENTIUS/waterpark.git//access/modules/persona?ref=checkpoint/i8
```

The committed form is the local path, because a checkout has to be green on
its own and the tag is cut after the commit lands. Terraform takes no
variable in a module source, so swapping is a file rewrite.

```sh
access/scripts/satellite-source show
access/scripts/satellite-source git checkpoint/i8
access/scripts/satellite-source local
```

The lesson uses `local`.

### The deploy credential

```sh
access/scripts/mint-satellite-credential
access/scripts/mint-satellite-credential --delete
```

It mints an IAM user `waterpark-runner-deploy` on Floci allowed
`iam:CreateRole` and `iam:PutRolePermissionsBoundary` only under
`StringEquals iam:PermissionsBoundary` equal to the central ARN
(decision 20), denied `iam:DeleteRolePermissionsBoundary` outright, and
allowed the ordinary role, policy and registry calls an apply needs.

A user, not a role, because a satellite in the world federates through its
own issuer and there is no OIDC subject on a laptop to bind to. Floci honors
trust policies, so a role trusting an issuer is a role nothing here can
become. The page says so. The user is minted and deleted by the script and is
never declared, so decision 5 and the `no-iam-user-or-group` rule still hold.

The credential does not itself carry the estate boundary, and that is
deliberate. The estate boundary denies all IAM write, so a credential inside
it could not create the role the satellite exists to create. Its cap is the
condition, which is narrower and aimed at exactly one thing, the shape of the
roles it may make.

### The double refusal

```sh
terraform -chdir=access/envs/prod apply -auto-approve
terraform -chdir=access/satellites/waterpark-runner init
terraform -chdir=access/satellites/waterpark-runner apply -auto-approve
access/scripts/double-refusal
```

It copies the satellite root to a sibling directory, renames the role and the
registry with a `-proof` suffix so it can create and destroy its own
resources without touching the applied satellite, and then does four things.

First the control. It applies the copy as the deploy credential with the
boundary in place, and the role is created and reads back carrying the
central ARN. Without this step the refusals below would prove only that a
credential was broken.

Then refusal one. It deletes the `permissions_boundary` line and runs
`tflint`, which fails `boundary-required` with the fix in the message. This
fires in the editor, before the commit.

Then refusal two. With the linter switched off, which is the satellite
defeating its own guardrails, it runs `terraform apply` as the deploy
credential and IAM answers `AccessDenied` on `iam:CreateRole`. No role is
created.

Then it restores, destroys the copy and deletes the credential.

Both refusals happen against Floci on the patched image. The condition key
works there, which the upstream image could not do, and the read-back works
too, which is why the control can prove the boundary landed.

### The satellite in the check stack

`access/scripts/check` picks up any directory under `satellites/` that holds
a `versions.tf`, and lints, validates and plans it alongside central. The
satellite plans after `envs/prod`, because it reads the boundary live and
cannot plan before central has applied it. A satellite running weaker checks
than central would make the delegation contract a suggestion.

## Lesson 9, federation trust

Who may become a principal is the one edit revoking a grant cannot undo, so
it is the most checked thing in the repo.

```
access/
  envs/prod/
    iam_openid_connect_provider.actions.tf   the anchor, beside the roles that trust it
    iam_role.site_publisher.tf               federated, subject pinned to the github-pages environment
    iam_role.waterpark_apply.tf              federated since lesson 6, subject pinned to main
  .tflint.d/policies/
    trust.rego                               trust-subject-pinned and trust-audience-pinned
  baseline/
    locals.tf                                static_secret_max_age_days
  scripts/
    rotation                                 every access key in the account, against the window
    drift                                    a changed anchor pages, like a changed trust policy
```

### Where an anchor lives

An OIDC provider is account scoped, so it is declared in the environment
whose roles federate through it, beside those roles, and `identity/` holds
none (decision 59). A second issuer, a Kubernetes cluster or a SPIFFE trust
domain, is one more `iam_openid_connect_provider.<issuer>.tf` in the same
directory and the same three pins on every role that trusts it. The repo
never operates an issuer (decision 13).

### The three pins, checked twice

A federated trust names an issuer, an audience and a subject. The issuer is
the provider the statement's `Principal` points at. The audience is the
`aud` claim pinned with `StringEquals`, so a token minted for some other
consumer cannot be replayed here. The subject is the exact workload,
`repo:INTENTIUS/waterpark:environment:github-pages` for the publisher and
`repo:INTENTIUS/waterpark:ref:refs/heads/main` for the apply role, pinned
with `StringEquals` and spelled out in full. `StringLike` is refused even
without a star in it, because a pattern is a wildcard waiting for one.

A leaf file goes through `modules/persona`, whose `federated_trust`
variable refuses a wildcard subject, an empty audience and an issuer host
with a scheme or a wildcard, at `terraform validate`. A raw `aws_iam_role`
is read by the two Rego rules at lint. Same fact, two layers that have not
heard of each other, the same shape as `boundary-required` and IAM.

### Severity

`scripts/drift` routes a changed `assume_role_policy` to `page` since lesson
7, and a changed `aws_iam_openid_connect_provider` the same way since this
one, because an anchor that gained a client id or lost its issuer is the
same edit one level up. Neither is filed as a reconcile PR. Somebody wakes
up, which is prescription 12's "flagged within one cycle".

### Rotation

Credentials are short-lived everywhere. Workloads get a token per job,
humans get an Identity Center session, and decision 5 bans IAM users, so a
conforming account holds nothing to rotate. `scripts/rotation` reads the
account anyway, lists every access key with its age against
`static_secret_max_age_days` from `baseline/`, and exits 2 when one is at
or over the window. It rides the drift watch's cron (decision 39), so one
schedule drives both. A window of zero says no static secret may stand at
all.

```sh
access/scripts/rotation
access/scripts/rotation --max-age-days 0
```

Break-glass signing material joins the list in lesson 10. Application
secrets in Secrets Manager or Parameter Store are not principals and are
not on it.

### What Floci cannot show

The provider applies and reads back, and a role trusting it applies and
plans clean. `AssumeRoleWithWebIdentity` is a stub that mints credentials
for any non-empty token, so a forged token is accepted on the solo path
and refused on a real account. The lesson runs the forged call on purpose
and says so. The satellite's deploy credential stays a script-minted user
here, and its federated form waits on the second boundary decision 58 has
not taken (decision 59).

## Lesson 10, break-glass

Access that exists for an incident, ends on its own, and leaves a trail.

```
access/
  envs/prod/
    iam_role.on_call.tf                  the on-call's stand-in on the solo path, empty at rest
  modules/persona/
    variables.tf                         granted_at on a grant, and the TTL refusal
    iam_policy.grant.tf                  the break_glass, granted_at and approved_by tags
    ssoadmin_permission_set_inline_policy.grants.tf   a human's grants, live only
  .tflint.d/policies/
    break-glass.rego                     break-glass-ttl
  scripts/
    break-glass                          grant, list, revoke, sweep
```

### Three layers

Prescription 9. The grant carries its own expiry, a `DateLessThan
aws:CurrentTime` condition the module renders, so the cloud ends the access
with nothing alive. The sweep removes the artifact, one PR per principal
file, on the drift cron. The drift watch reports an expired grant as a
finding until the sweep's PR merges. Killing the sweep delays cleanup and
never extends access (decision 8).

### The grant

```sh
access/scripts/break-glass grant access/envs/prod/iam_role.on_call.tf \
  waterpark-site write --reason "A release broke the site." --hours 2
access/scripts/break-glass list
access/scripts/break-glass sweep
access/scripts/break-glass revoke <id>
```

`grant` writes one grant block into the principal file, fenced by marker
comments carrying an id, with `granted_at` now and `expires` no later than
the baseline TTL. The file is then a pull request like any other. `revoke`
removes the block by id, and `sweep` revokes every block whose expiry has
passed, planning by default and opening one PR per principal file with
`--open`.

### The TTL, refused three times

The script refuses a longer grant before writing it. `break-glass-ttl`
refuses one at lint, in the editor. The persona module refuses one at plan.
`terraform validate` does not, because a validation that reads another
variable is evaluated at plan rather than at validate, and the page says so.
The constant is `break_glass_max_ttl_hours` in `baseline/`, restated as the
rule's literal and the module's default, and `check fixtures` fails when the
three differ.

### The approver

The apply job reads the merged pull request's approving review and stamps
`approved_by` on every policy tagged `break_glass`, after the apply, so the
approval and the artifact name the same human (decision 37). The module
ignores that one tag on the next plan. On the solo path the tag reads
`unapproved`, because nobody did.

### What Floci cannot show

The grant applies and reads back with its condition and tags, the checks
refuse a long one, the watch reports it once expired and the sweep removes
it. Floci evaluates no condition on an allow, so the access itself is
denied throughout on the emulator, and the drill where the access works and
then ends at the expiry is live only ([upstream](../project/upstream.md),
decision 60).

## Lesson 11, offboard and the access review

A principal leaves in one pull request and one apply with nothing left
naming them, and a reviewer gets an artifact read from the account.

```
access/
  scripts/
    lib-live.sh      the read side every script below shares
    whocan           who can reach a resource
    expiring         every dated grant, soonest first
    offboard         remove a principal and every reference
    access-review    the quarterly artifact
.github/workflows/
  access-review.yml  the quarterly cron
```

### Everything reads the account

`whocan`, `expiring` and `access-review` read `get-role`,
`list-attached-role-policies`, `list-policy-tags` and `get-policy-version`
and never a file (decision 42). A role the satellite created is in every
answer whichever repo declared it, and so is a policy somebody attached in
a console, which the drift watch reports beside it. The grant's access
level and resource are read off the policy name the persona module writes,
and the expiry, the reason and the break-glass marks off its tags.

```sh
access/scripts/whocan waterpark-artifacts
access/scripts/expiring --within 120
access/scripts/access-review
LIVE=true access/scripts/access-review
```

### Offboard

```sh
access/scripts/offboard --preview course-author
access/scripts/offboard desk-operator
```

The declared side is the principal file, the output lines that name it,
the variable a human's assignment reads, and the CODEOWNERS line derived
from it. The live side is the role, its boundary and its attached policies,
so the preview says what the apply takes away. After the change the script
greps for the name outside a comment, and `terraform plan` is the proof,
because a dangling reference fails it. `access/identity` is live only and
the preview says so instead of reading it.

### The artifact

The review is Markdown for a person and JSON for the desk. It says where
each fact came from, lists what expires ninety days out, names the
unused-access section as a skip until an analyzer answers, lists humans as
declared because Identity Center is read only live, folds in the rotation
check, and closes with what it did not see. `access-review.yml` runs it
quarterly against a Floci the job filled itself, which proves the shape and
not a real account, and uploads the artifact for four hundred days.
