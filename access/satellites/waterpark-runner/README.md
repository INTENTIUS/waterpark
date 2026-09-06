# satellites/waterpark-runner

The satellite. It declares the registry the sandbox runner image is pushed to
and the role that pushes to it, inside a permission boundary this repo owns,
and it declares no human (estate.md scenario 5).

It is a sibling root under `access/` rather than a second GitHub repository
(decision 49). Everything else about it is what a real satellite is. Its own
provider, its own state, its own team in CODEOWNERS, its own deploy
credential, and the shared module and the rule pack arriving from central
under a pinned contract.

## What it declares, and what it does not

| Here | Central |
|---|---|
| the registry | the boundary policy |
| the role that pushes to it | the personas |
| which persona that role instantiates | the guardrail rules |
| its own grants | every human principal |

The line is that a satellite may create identities that act on its own
resources, and may never change what an identity is allowed to be
(decision 20). `deployer` is not delegable, so a satellite makes `service`
roles and nothing else (decision 36).

## The delegation contract, in three files

`iam_role.runner_builder.tf` calls `modules/persona`. The module was going to
be a separate `workload_role` wrapper (decision 10), and it is `persona`
itself, because a wrapper forwarding a dozen variables is a dozen variables
declared twice and the wrapper adds no rule the boundary and the rule pack do
not already hold. The workload half of the persona set is the workload role
module.

`data.tf` reads the boundary live by its deterministic name. Not
`terraform_remote_state`, which would hand a satellite read access to central
state, and not a copied ARN, which goes stale. A satellite that plans before
central has applied the boundary fails, which is the right order made
unavoidable.

`.tflint.hcl` runs the central rule pack. See
[.tflint.d](../../.tflint.d/README.md) for the warn-minor and error-major
convention the pinned ref carries.

## The module source

Committed with the local path, because a checkout has to be green on its own
and the tag is cut after the commit lands.

```sh
access/scripts/satellite-source show
access/scripts/satellite-source git checkpoint/i8
access/scripts/satellite-source local
```

The pinned form, which is what a satellite in its own repository uses
(decision 50), is

```
git::https://github.com/INTENTIUS/waterpark.git//access/modules/persona?ref=checkpoint/i8
```

Terraform takes no variable in a module source, so this is a file rewrite
rather than a flag, the same mechanism and for the same reason as
`access/scripts/backend`.

## Running it

Central applies first, because the boundary has to exist to be read.

```sh
terraform -chdir=access/envs/prod apply -auto-approve
terraform -chdir=access/satellites/waterpark-runner init
terraform -chdir=access/satellites/waterpark-runner apply -auto-approve
terraform -chdir=access/satellites/waterpark-runner plan -detailed-exitcode
```

Read the role back from the account and it carries the central boundary that
nobody in this directory could have chosen.

```sh
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 \
  aws --endpoint-url http://localhost:4566 iam get-role --role-name runner-builder
```

## The registry, and what decision 48 left open

Decision 48 deferred ECR because the Floci provider override covered only
iam, sts and s3 and the fork build's ECR support was untested. It is tested
now. The patched image runs `ecr`, an `aws_ecr_repository` applies with an
`ecr` endpoint override, its tags read back, and the immediate replan exits 0.
So the registry is declared here rather than stood in for by a bucket.
