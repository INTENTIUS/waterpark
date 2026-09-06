---
name: waterpark-i1-one-type-per-file
description: Walk a student through IAM lesson 1, One resource per file. Use when they want the first IAM lesson or the access repo layout. Builds access/envs/prod from an empty tree in a worktree at checkpoint/i0, one Terraform resource block per file, then shows Terraform accepting a layout that breaks the convention.
---

# water park, IAM lesson 1, One resource per file

You are walking a student through IAM lesson 1, One resource per file
(https://intentius.io/waterpark/courses/iam/01-one-type-per-file/). The
outcome is a working `access/envs/prod` they wrote themselves, green
`terraform fmt`, `init` and `validate`, and a diff against `checkpoint/i1`
that prints nothing. About 40 minutes.

This lesson spends no money and touches no AWS account. Everything runs on
the laptop with the `floci` variable left at its default, so the provider
never resolves a real account and never holds a credential. Do not start
Floci, do not run `terraform apply`, and do not ask for AWS credentials at
any point. If the student offers them, say they are not needed until
lesson 4.

Confirm with the student before creating the worktree and before writing
or copying any file. Those steps are marked **confirm**. Reads, `git
diff`, `terraform validate` and `terraform fmt -check` run freely.

## 1. Say what this is

In three or four sentences say this is lesson 1 of the IAM course, that
the access repo is this repo under `access/`, and that the whole
convention is one `resource` block per file with the file named after the
resource address inside it. Say the lesson ends by breaking that
convention and showing that Terraform does not care, which is what lesson
3 fixes. Link the lesson page above.

Ask which OS and shell they are on. macOS, Linux or Windows, and bash,
zsh or PowerShell. The `git` and `terraform` commands below are identical
everywhere. The `cp`, `mkdir -p` and `chmod` lines are not, so give the
PowerShell forms when that is what they are using.

| bash or zsh | PowerShell |
|---|---|
| `mkdir -p a/b` | `New-Item -ItemType Directory -Force -Path a/b` |
| `cp src dst` | `Copy-Item src dst` |
| `chmod +x f` | not needed |

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Windows runs
`powershell -ExecutionPolicy Bypass -File skills/start/check.ps1` instead.

Also read `.waterpark/profile.json` at the checkout root if it exists. It
is a claim from a previous run. The check's live reads are the truth, so
when they disagree believe the check.

From the check, require only `waterpark.checkout` true, and note
`waterpark.root`. This lesson needs no Fountain, no inference key, no
runner and no Floci, so ignore those fields even when they are false. Say
that out loud, because a student who just finished the Fountain course
will expect the stack to matter here and it does not.

The check does not report `terraform` or `tflint`. Verify them yourself.

```sh
terraform version
tflint --version
```

Terraform must be 1.9.0 or newer. If it is missing, **confirm**, then
install it. macOS `brew install terraform`, Windows
`winget install HashiCorp.Terraform`, Linux the release binary from
https://developer.hashicorp.com/terraform/install on the PATH.

`tflint` is not used in this lesson and lesson 3 needs it. Offer to
install it now so it is out of the way, **confirm** first. On macOS it
comes from the tap and not from core, `brew install
terraform-linters/tap/tflint`. Elsewhere it is the release binary from
https://github.com/terraform-linters/tflint. If it is installed, offer to
run `just access-init` once in the checkout, which fetches the OPA plugin
lesson 3 uses. Both are optional here. Do not block on either.

## 3. The lesson

### 3a. The worktree

**confirm**, then, from the water park checkout,

```sh
git fetch origin --tags
git worktree add ../waterpark-i1 checkpoint/i0
cd ../waterpark-i1
```

`checkpoint/i0` is the repo before `access/` existed. Everything after
this runs in `../waterpark-i1`, and the original checkout is untouched and
stays available as the reference copy. If `git worktree add` says the tag
is unknown, the fetch did not bring the tags down, so run it again and
check the remote is `INTENTIUS/waterpark`.

### 3b. The plumbing

**confirm**, then

```sh
mkdir -p access/envs/prod access/envs/dev access/backends access/scripts
cp ../waterpark/access/envs/prod/versions.tf ../waterpark/access/envs/prod/provider.tf ../waterpark/access/envs/prod/variables.tf ../waterpark/access/envs/prod/locals.tf access/envs/prod/
cp ../waterpark/access/backends/backend.local.tf ../waterpark/access/backends/backend.s3.tf access/backends/
cp ../waterpark/access/scripts/backend access/scripts/backend
cp ../waterpark/access/.gitignore access/.gitignore
chmod +x access/scripts/backend
```

Substitute the student's real checkout path for `../waterpark`. Use
`waterpark.root` from the check rather than guessing.

Then have them read `access/envs/prod/provider.tf` and say back what
`var.floci` does. One provider block, two targets. True points `iam`,
`sts` and `s3` at `http://localhost:4566` and skips every call that would
resolve a real account. False talks to `waterpark-prod`. The default is
true, which is why this lesson holds no credential.

### 3c. The five leaf files

**confirm** once, then have the student write these five files. Offer the
content, let them type it or paste it, and do not write them silently.
The file names are the lesson, so say each path out loud before its
content.

`access/envs/prod/s3_bucket.waterpark_site.tf`

```hcl
resource "aws_s3_bucket" "waterpark_site" {
  bucket = "waterpark-site"

  tags = {
    owner = local.owner
    role  = "the bucket the published site is served from"
  }
}
```

`access/envs/prod/s3_bucket.waterpark_artifacts.tf`

```hcl
resource "aws_s3_bucket" "waterpark_artifacts" {
  bucket = "waterpark-artifacts"

  tags = {
    owner = local.owner
    role  = "build artifacts and the lesson checkpoints"
  }
}
```

`access/envs/prod/iam_role.site_publisher.tf`

```hcl
resource "aws_iam_role" "site_publisher" {
  name        = "site-publisher"
  description = "Builds the site and writes it to the site bucket."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    owner   = local.owner
    persona = "service"
  }
}
```

`access/envs/prod/iam_policy.site_publisher_read_artifacts.tf`

```hcl
resource "aws_iam_policy" "site_publisher_read_artifacts" {
  name        = "site-publisher-read-artifacts"
  description = "Read on waterpark-artifacts for site-publisher, so a build can pick up the checkpoint bundle."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketLocation",
        "s3:ListBucket",
      ]
      Resource = [
        aws_s3_bucket.waterpark_artifacts.arn,
        "${aws_s3_bucket.waterpark_artifacts.arn}/*",
      ]
    }]
  })

  tags = {
    owner = local.owner
  }
}
```

`access/envs/prod/iam_role_policy_attachment.site_publisher_read_artifacts.tf`

```hcl
resource "aws_iam_role_policy_attachment" "site_publisher_read_artifacts" {
  role       = aws_iam_role.site_publisher.name
  policy_arn = aws_iam_policy.site_publisher_read_artifacts.arn
}
```

Point out that three resources means three files, that the grant is
already four named actions rather than `s3:*`, and that lesson 2 collapses
all three back into one module call.

### 3d. The output

**confirm**, then `access/envs/prod/outputs.tf`

```hcl
output "roles" {
  description = "The workload roles this environment declares, by principal name."
  value = {
    site-publisher = aws_iam_role.site_publisher.arn
  }
}
```

A file with no `resource` block in it is exempt from the naming rule,
which is how `outputs.tf`, `variables.tf` and the rest keep their
conventional names.

### 3e. Backend and checks

**confirm** for the first command, which writes `backend.local.tf` into
the env directory. The other three only read.

```sh
access/scripts/backend local envs/prod
terraform fmt -check -recursive access
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod validate
```

`fmt -check` prints nothing and exits 0 when every file is formatted. If
it prints a file name, run `terraform fmt -recursive access` and look at
what changed. `init` downloads the AWS provider from the registry, which
is the only network call in the lesson, and writes `.terraform/` and a
lock file that `access/.gitignore` keeps out of the repo. `validate` says
the configuration is valid.

### 3f. The deliberate break

**confirm**, then

```sh
mv access/envs/prod/iam_role.site_publisher.tf access/envs/prod/role.tf
cat access/envs/prod/iam_policy.site_publisher_read_artifacts.tf >> access/envs/prod/role.tf
rm access/envs/prod/iam_policy.site_publisher_read_artifacts.tf
terraform -chdir=access/envs/prod validate
terraform fmt -check -recursive access
```

Both still exit 0. `role.tf` holds two `resource` blocks and repeats
neither address, and Terraform has no opinion about either, because it
reads the directory rather than the file. Ask the student what would have
caught it. The answer is nothing that exists yet, and lesson 3 builds it.

Put it back before the done-when check.

```sh
git checkout checkpoint/i1 -- access/envs/prod
rm access/envs/prod/role.tf
```

## 4. Done when

All of these have to be true, in `../waterpark-i1`.

- `terraform fmt -check -recursive access` exits 0 and prints nothing.
- `terraform -chdir=access/envs/prod validate` says the configuration is
  valid.
- The compare against the checkpoint prints nothing.

  ```sh
  git add -N access
  git diff --stat checkpoint/i1 -- access/envs access/backends access/scripts
  ```

  `git add -N` records the new files as intent-to-add so the diff can see
  them, and stages no content. Nothing printed means the student's tree is
  the reference tree. If lines come back, read them with the student. A
  missing file means a step was skipped, and a changed file is usually a
  typo in a name or a tag.

Run all three yourself and show the output. If any fails, name which, and
point at 3c for a missing or misnamed file, 3e for fmt and validate, and
3f for a tree left in the broken state.

The other half of prescription 1, the two rules that fail a two-resource
file and a misnamed one in the editor, is lesson 3. Do not claim this
lesson closed it.

## 5. Record

**confirm**, then update `.waterpark/profile.json` at the water park
checkout root, appending `"i1"` to its `completed` array (creating the
array if the file lacks one). Leave every other field untouched. The
profile lives in the original checkout, not in the worktree.

```json
{"...": "...", "completed": ["start", "i1"]}
```

## 6. Hand off

Say the next step is IAM lesson 2, Personas and principals
(https://intentius.io/waterpark/courses/iam/02-personas-and-principals/),
which replaces the role, policy and attachment from this lesson with one
call to a shared persona module, and adds the human principals. It starts
from `checkpoint/i1` in a worktree of its own, so this one can be thrown
away with `git worktree remove ../waterpark-i1` from the main checkout, or
kept to compare against.
