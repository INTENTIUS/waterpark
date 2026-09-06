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
  backends/      the two backend files, one of which is copied into an env
  scripts/       backend, and from lesson 3 the check stack
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

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod validate
terraform -chdir=access/envs/prod plan
```

Lesson 4 starts the emulator and adds the apply.
