---
name: waterpark-i2-personas-and-principals
description: Walk a student through IAM lesson 2, Personas and principals. Use when they finished IAM lesson 1 and want lesson 2, or want the persona module and the human principals. Replaces the raw role, policy and attachment with one module call, adds two more workload principals and the two humans, and proves the two refusals.
---

# water park, IAM lesson 2, Personas and principals

You are walking a student through IAM lesson 2, Personas and principals
(https://intentius.io/waterpark/courses/iam/02-personas-and-principals/).
The outcome is three workload principals that are each one module call
plus grants, two human principals in a root of their own, and two
refusals the student has seen fire. About 45 minutes.

This lesson spends no money and touches no AWS account. Do not start
Floci, do not run `terraform apply`, and do not ask for AWS credentials.
`terraform plan` is used twice here and it reaches nothing, because the
state is empty and every resource is a create.

Confirm with the student before creating the worktree and before anything
that writes, deletes or checks out a file. Those steps are marked
**confirm**. `terraform validate`, `terraform plan`, `git diff` and
reading files run freely.

## 1. Say what this is

In three or four sentences say this is lesson 2 of the IAM course, that a
persona is a call to one shared module, that humans compile to Identity
Center permission sets and workloads compile to IAM roles, and that the
set of personas is four and closed. Say the lesson ends with two
deliberate refusals, one at `validate` and one at `plan`. Link the lesson
page above.

Ask which OS and shell they are on. The `git` and `terraform` commands are
identical everywhere. `rm`, `cp` and `sed` are not, so give the PowerShell
forms when that is what they are using, or have them make the edits by
hand in the editor, which is what the `sed` lines stand in for.

| bash or zsh | PowerShell |
|---|---|
| `rm f` | `Remove-Item f` |
| `cp src dst` | `Copy-Item src dst` |
| `sed -i '' 's/a/b/' f` | edit the file in the editor |

Note for Linux students that GNU `sed` wants `sed -i` with no argument
where macOS wants `sed -i ''`.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Windows runs
`powershell -ExecutionPolicy Bypass -File skills/start/check.ps1` instead.

Also read `.waterpark/profile.json` at the checkout root if it exists. It
is a claim from a previous run, and the check's live reads are the truth,
so when they disagree believe the check.

From the check, require `waterpark.checkout` true and note
`waterpark.root`. Nothing else in the check matters here. This lesson
needs no Fountain, no inference key, no runner and no Floci.

If the profile's `completed` array does not contain `i1`, say so and ask
whether they want lesson 1 first
(https://intentius.io/waterpark/courses/iam/01-one-type-per-file/). They
can still do this one, because it starts from `checkpoint/i1` rather than
from whatever lesson 1 left behind, but the leaf files will be unfamiliar.

The check does not report `terraform`. Verify it yourself with
`terraform version` and require 1.9.0 or newer. Variable validation that
reads a second variable is a 1.9 feature and step 3g depends on it.

## 3. The lesson

### 3a. The worktree

**confirm**, then, from the water park checkout,

```sh
git worktree add ../waterpark-i2 checkpoint/i1
cd ../waterpark-i2
```

`checkpoint/i1` is the tree lesson 1 ends at. If the tag is unknown, run
`git fetch origin --tags` and try again. Everything after this runs in
`../waterpark-i2`.

### 3b. The module

**confirm**, then

```sh
git checkout checkpoint/i2 -- access/modules/persona access/identity/provider.tf access/identity/variables.tf access/identity/versions.tf access/identity/README.md
```

Say why this one is a checkout rather than something they type. The module
is about three hundred lines, reading it is the lesson and typing it is
not.

Then have them read two files and say back what each does.

`access/modules/persona/variables.tf`. Two `validation` blocks on
`persona`. The first names the four and refuses anything else. The second
refuses `reader` and `platform` unless the root sets `identity_center`.
Those are the two refusals 3g and 3h fire.

`access/modules/persona/locals.tf`. The grant vocabulary. `read`, `list`
and `write` each expand to a list of actions and a list of ARN patterns.
A leaf file says a level and the module says the actions.

### 3c. Drop what the module makes redundant

**confirm**, then

```sh
rm access/envs/prod/iam_policy.site_publisher_read_artifacts.tf
rm access/envs/prod/iam_role_policy_attachment.site_publisher_read_artifacts.tf
```

The grant is not being deleted. It becomes a typed access level in the
next file, and the module renders the `aws_iam_policy` and the attachment
itself. After this lesson no leaf file in the estate declares a policy.

### 3d. The three workload principals

**confirm** once, then have the student write these. Offer the content and
let them paste it. Say each path out loud before its content.

`access/envs/prod/iam_role.site_publisher.tf`, replacing what is there.

```hcl
module "site_publisher" {
  source = "../../modules/persona"

  persona     = "service"
  name        = "site-publisher"
  description = "Builds the site and writes it to the site bucket."
  owner       = local.owner
  teams       = ["platform"]

  grants = [
    {
      resource = "waterpark-site"
      access   = "write"
      reason   = "Publishes the built site."
    },
    {
      resource = "waterpark-site"
      access   = "list"
      reason   = "Compares the build against what is already published."
    },
    {
      resource = "waterpark-artifacts"
      access   = "read"
      reason   = "Picks up the checkpoint bundle a lesson restarts from."
    },
  ]
}
```

The file name did not change, because the rule reads the same for a module
call. `iam_role.site_publisher.tf` holds the call that produces
`aws_iam_role.site_publisher`.

Now the second one, and have them make it the way prescription 2 says a
contributor would. Copy first, then edit.

```sh
cp access/envs/prod/iam_role.site_publisher.tf access/envs/prod/iam_role.runner_builder.tf
```

Then five edits in the copy, the module label, the `name`, the
`description` and the two grants. The persona stays `service`.

```hcl
module "runner_builder" {
  source = "../../modules/persona"

  persona     = "service"
  name        = "runner-builder"
  description = "Builds the sandbox runner image and pushes it."
  owner       = local.owner
  teams       = ["platform"]

  grants = [
    {
      resource = "waterpark-artifacts"
      access   = "write"
      reason   = "Publishes the runner build's artifacts."
    },
    {
      resource = "waterpark-artifacts"
      access   = "list"
      reason   = "Reads what it already published before pushing again."
    },
  ]
}
```

Ask them how many lines they had to change. That number is the check for
prescription 2.

Then the third, `access/envs/prod/iam_role.desk_operator.tf`, which is the
one with an expiry.

```hcl
module "desk_operator" {
  source = "../../modules/persona"

  persona     = "service"
  name        = "desk-operator"
  description = "The concierge in direct mode, bounded, and nothing in repo mode."
  owner       = local.owner
  teams       = ["platform"]

  grants = [
    {
      resource = "waterpark-artifacts"
      access   = "read"
      expires  = "2027-01-01T00:00:00Z"
      reason   = "Direct mode reads the estate. Expires so the desk's read has to be renewed deliberately."
    },
    {
      resource = "waterpark-artifacts"
      access   = "list"
      expires  = "2027-01-01T00:00:00Z"
      reason   = "Direct mode lists the estate. Same expiry as the read beside it."
    },
  ]
}
```

And `access/envs/prod/outputs.tf`, rewritten to read the principals back
from the modules.

```hcl
output "roles" {
  description = "The workload roles this environment declares, by principal name."
  value = {
    (module.site_publisher.role_name) = module.site_publisher.role_arn
    (module.runner_builder.role_name) = module.runner_builder.role_arn
    (module.desk_operator.role_name)  = module.desk_operator.role_arn
  }
}

output "grants" {
  description = "Every grant this environment declares, by principal."
  value = {
    site-publisher = module.site_publisher.grants
    runner-builder = module.runner_builder.grants
    desk-operator  = module.desk_operator.grants
  }
}
```

### 3e. The two humans

**confirm**, then three more files in `access/identity`, which is a
Terraform root of its own with no `floci` variable and no endpoint
override.

`access/identity/ssoadmin_permission_set.platform.tf`

```hcl
module "platform" {
  source = "../modules/persona"

  persona     = "platform"
  name        = "platform"
  description = "Owns the repo and the guardrails, and the security reviewers in CODEOWNERS."

  identity_center = true
  accounts        = var.accounts
  principal_id    = var.platform_group_id
  principal_type  = "GROUP"
  teams           = ["platform"]
}
```

`access/identity/ssoadmin_permission_set.course_author.tf`

```hcl
module "course_author" {
  source = "../modules/persona"

  persona     = "reader"
  name        = "course-author"
  description = "Writes lessons, reads everything, writes nothing in prod."

  identity_center = true
  accounts        = var.accounts
  principal_id    = var.course_author_group_id
  principal_type  = "GROUP"
  teams           = ["course"]
}
```

`access/identity/outputs.tf`

```hcl
output "permission_sets" {
  description = "The permission sets the human principals compile to, by principal name."
  value = {
    platform      = module.platform.permission_set_arn
    course-author = module.course_author.permission_set_arn
  }
}
```

Point out the file names. The type prefix is stripped from the real
resource type, so a human principal is
`ssoadmin_permission_set.<name>.tf`. Point out that both set
`identity_center = true`, which is the flag the module demands before it
renders a human at all, and that this root is live only because Floci runs
no Identity Center.

### 3f. Validate both roots

Read commands, no confirmation needed.

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod validate
terraform -chdir=access/identity init -backend=false
terraform -chdir=access/identity validate
```

`envs/prod` keeps the local backend from lesson 1, so plain `init` works.
`access/identity` has no backend file, so `-backend=false` is what lets it
initialise on a laptop.

Then read the expiry out of the plan.

```sh
terraform -chdir=access/envs/prod plan -no-color | grep -A3 -e DateLessThan -e '"expires" ='
```

Two `DateLessThan` conditions on `aws:CurrentTime` and two `expires` tags
carrying the same date. The condition is what the cloud enforces on every
call. The tag is what a read of the estate can see without parsing a
policy document.

### 3g. The first refusal, at validate

**confirm**, because it edits a file.

```sh
sed -i '' 's/persona     = "service"/persona     = "admin"/' access/envs/prod/iam_role.runner_builder.tf
terraform -chdir=access/envs/prod validate
```

Exits 1, with `persona must be one of reader, platform, service,
deployer. The set is closed (decision 41), so adding one is a module
release rather than a leaf-file edit.` Nothing was planned and nothing was
applied.

### 3h. The second refusal, at plan

**confirm**, then

```sh
sed -i '' 's/persona     = "admin"/persona     = "reader"/' access/envs/prod/iam_role.runner_builder.tf
terraform -chdir=access/envs/prod validate
terraform -chdir=access/envs/prod plan
```

`validate` says the configuration is valid. `plan` prints the whole plan
and then fails with `The reader and platform personas compile to an
Identity Center permission set, and Floci does not run Identity Center.`
Explain why the two land in different places. A wrong name is a shape
problem, so `validate` has it. A validation that reads a second variable
needs the variables to have values, so `plan` has it.

Put it back, **confirm** first.

```sh
sed -i '' 's/persona     = "reader"/persona     = "service"/' access/envs/prod/iam_role.runner_builder.tf
```

## 4. Done when

All of these have to be true, in `../waterpark-i2`.

- `runner-builder` was made by copying `iam_role.site_publisher.tf` and
  changing strings, not by pasting a finished file. Ask them.
- `terraform validate` is green in `access/envs/prod` and in
  `access/identity`, and in `access/modules/persona` if they want the
  third
  (`terraform -chdir=access/modules/persona init -backend=false` first).
- `persona = "admin"` fails `terraform validate` with the closed-set
  message. They saw this in 3g.
- The compare against the checkpoint prints nothing.

  ```sh
  git add -N access
  git diff --stat checkpoint/i2 -- access/envs access/identity access/modules
  ```

Run the validates and the compare yourself and show the output. If the
compare prints lines, read them with the student. A leftover
`iam_policy.site_publisher_read_artifacts.tf` means 3c was skipped, and a
changed leaf file is usually a grant `reason` that does not match.

Two halves of prescription 3 are still open and this lesson does not close
them. The check that fails an `aws_iam_user` anywhere in the repo is one
of the nine rules lesson 3 writes, and the expired grant surfacing in the
watch is lesson 7. Do not claim either.

## 5. Record

**confirm**, then update `.waterpark/profile.json` at the water park
checkout root, appending `"i2"` to its `completed` array (creating the
array if the file lacks one). Leave every other field untouched. The
profile lives in the original checkout, not in the worktree.

```json
{"...": "...", "completed": ["start", "i1", "i2"]}
```

## 6. Hand off

Say the next step is IAM lesson 3, Guardrails in the editor
(https://intentius.io/waterpark/courses/iam/03-guardrails-in-the-editor/),
which writes the nine rules that fail this repo's own mistakes before a
review sees them, including the two layout rules lesson 1 left unenforced.
It starts from `checkpoint/i2` in a worktree of its own, so this one can be
thrown away with `git worktree remove ../waterpark-i2` from the main
checkout, or kept to compare against.
