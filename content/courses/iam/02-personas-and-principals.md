---
title: "Personas and principals"
id: "I2"
lesson: 2
weight: 2
summary: "Humans get permission sets and workloads get roles."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i2-personas-and-principals"
# card. empty renders as TODO
goal: "Replace lesson 1's raw role, policy and attachment with one call to a shared persona module, then add two more workload principals by copying that file and changing a few strings. Declare the two human principals in `access/identity`, where they are validated on every run and applied only against a real account. Then prove the two refusals, an unknown persona name at `terraform validate` and a human persona in a root that cannot reach Identity Center at `terraform plan`."
done_when: "`runner-builder` was made by copying `iam_role.site_publisher.tf` and changing strings, `terraform validate` is green in `access/envs/prod`, `access/identity` and `access/modules/persona`, `persona = \"admin\"` fails `terraform validate` with the closed-set message rather than applying something surprising, and `git diff checkpoint/i2 -- access/envs access/identity access/modules` prints nothing."
restart_from: "checkpoint/i1, the tree lesson 1 ends at"
properties: ["V"]
closes: ["P2", "P3"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "45 min"
  needs: ["a water park checkout on main", "`terraform` 1.9 or newer on the PATH", "`tflint` from `brew install terraform-linters/tap/tflint`", "`just access-init` run once in that checkout", "no Floci and no AWS account"]
  solo: true
  live: true
---

## Context

- Humans are `aws_ssoadmin_permission_set` and `aws_ssoadmin_account_assignment`. Workloads are `aws_iam_role`. There are no IAM users and no IAM groups (decision 5).
- A persona is a call to `access/modules/persona`, so a principal file is that call plus a list of grants and nothing else. Each principal is one file, still named for the address it produces, so `iam_role.site_publisher.tf` holds the call that renders `aws_iam_role.site_publisher`.
- The persona set is four and it is closed. `reader` and `platform` are the human ones, `service` and `deployer` the workload ones, and `platform` is the one that owns the guardrail path. Team scoping is a module parameter rather than a persona of its own, and there is no standing admin, because permissions management always goes through the repo (decision 41).
- Grant policies are rendered by the module. No leaf file declares an `aws_iam_policy`, which is why lesson 1's policy file disappears here and never comes back.
- A grant is a typed access level rather than a list of actions. An expiry becomes a `DateLessThan` condition on `aws:CurrentTime` in the rendered document, which the cloud enforces whether or not any job runs, plus an `expires` tag carrying the same date so a read of the estate can see it without parsing the policy. Lesson 7 is where an expired grant surfaces as drift.
- Human principals live in `access/identity` and are live only, because Floci runs no Identity Center. The module refuses a human persona unless the root sets `identity_center = true`, which is prescription 3 standing as written rather than being softened for the emulator.

## Do

1. Make a worktree at the checkpoint this lesson starts from. Run this in your water park checkout.

   ```sh
   git worktree add ../waterpark-i2 checkpoint/i1
   cd ../waterpark-i2
   ```

   `checkpoint/i1` is the tree lesson 1 ends at, so `access/envs/prod` already holds the role, the policy and the attachment as three separate files.

2. Bring in the module and the plumbing of the second root. The module is about three hundred lines and reading it is the lesson, not typing it, so take it from the checkpoint this lesson ends at.

   ```sh
   git checkout checkpoint/i2 -- access/modules/persona access/identity/provider.tf access/identity/variables.tf access/identity/versions.tf access/identity/README.md
   ```

   Now read two files before writing anything.

   `access/modules/persona/variables.tf` carries the two refusals this lesson proves. The first `validation` block on `persona` names the four and nothing else. The second says a human persona needs `identity_center` true.

   `access/modules/persona/locals.tf` carries the grant vocabulary. `read`, `list` and `write` each expand to a list of actions and a list of ARN patterns, so widening what read means anywhere in the estate is one edit in this file rather than a sweep through the leaves.

3. Delete the two files the module makes redundant.

   ```sh
   rm access/envs/prod/iam_policy.site_publisher_read_artifacts.tf
   rm access/envs/prod/iam_role_policy_attachment.site_publisher_read_artifacts.tf
   ```

   The grant survives. It moves from a hand-written policy document into a typed access level the module expands, and the module renders the `aws_iam_policy` and the attachment on its own.

4. Rewrite `access/envs/prod/iam_role.site_publisher.tf` as one module call plus its grants.

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

   The file name did not change, because the rule reads the same for a module call. `iam_role.site_publisher.tf` holds the call that produces `aws_iam_role.site_publisher`, so the path still predicts the address.

5. Make the second principal the way a first-time contributor would, by copying the sibling and changing strings. This is the whole of prescription 2, so do it literally rather than pasting a finished file.

   ```sh
   cp access/envs/prod/iam_role.site_publisher.tf access/envs/prod/iam_role.runner_builder.tf
   ```

   Then change five things in the copy. The module label to `runner_builder`, the `name` to `runner-builder`, the `description` to what it does, and the grants to write and list on `waterpark-artifacts`. The persona stays `service`. Nothing else needs touching.

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

6. Add the third principal, and give its grants an expiry. `desk-operator` is the concierge in direct mode, and its read of the estate is the one grant in the estate that should have to be renewed on purpose.

   `access/envs/prod/iam_role.desk_operator.tf`

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

7. Rewrite `access/envs/prod/outputs.tf` so it reads the three principals back from the module rather than from a resource address.

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

8. Declare the two humans, in the other root. `access/identity` is a Terraform root of its own with no `floci` variable and no endpoint override, because Identity Center lives in `waterpark-mgmt` and Floci does not run it.

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

   The type prefix is stripped from the real resource type, which is why these files are `ssoadmin_permission_set.<name>.tf` and not `iam_...`. Both set `identity_center = true`, which is the flag the module demands before it will render a human at all.

9. Validate both roots. The module source changed, so `init` has to run again.

   ```sh
   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod validate
   terraform -chdir=access/identity init -backend=false
   terraform -chdir=access/identity validate
   ```

   `envs/prod` keeps the local backend lesson 1 checked in, so plain `init` works. `access/identity` has no backend file at all, and `-backend=false` is what makes it usable on a laptop. It initialises the module and the provider and skips the backend, so a root that will only ever be applied against a real organization is still checked on every run.

10. Read the expiry back out of the plan. This runs offline, with no Floci and no account, because a plan of an empty state creates everything and refreshes nothing.

    ```sh
    terraform -chdir=access/envs/prod plan -no-color | grep -A3 -e DateLessThan -e '"expires" ='
    ```

    Two `DateLessThan` conditions on `aws:CurrentTime`, and two `expires` tags carrying the same date. The condition is what the cloud enforces, on every call, whether or not any job is running. The tag is what a read of the estate can see without parsing a policy document. Lesson 7 is where that tag becomes drift.

11. Prove the first refusal. Change one string in a leaf file.

    ```sh
    sed -i '' 's/persona     = "service"/persona     = "admin"/' access/envs/prod/iam_role.runner_builder.tf
    terraform -chdir=access/envs/prod validate
    ```

    (GNU `sed` wants `sed -i` with no argument. Editing the file by hand is the same thing.) `validate` exits 1 and says `persona must be one of reader, platform, service, deployer. The set is closed (decision 41), so adding one is a module release rather than a leaf-file edit.` Nothing was planned, nothing was applied, and the message names the fix.

12. Prove the second refusal, which fires later and for a different reason. Put a human persona in the workload root.

    ```sh
    sed -i '' 's/persona     = "admin"/persona     = "reader"/' access/envs/prod/iam_role.runner_builder.tf
    terraform -chdir=access/envs/prod validate
    terraform -chdir=access/envs/prod plan
    ```

    `validate` says the configuration is valid. `plan` prints the whole plan and then fails, because a validation that reads a second variable is checked when the variables have values rather than when the syntax is checked. The message is `The reader and platform personas compile to an Identity Center permission set, and Floci does not run Identity Center. Human principals live under access/identity/ and are live only (prescription 3). Set identity_center to true only in a root that talks to a real account.` Put the file back with `sed -i '' 's/persona     = "reader"/persona     = "service"/' access/envs/prod/iam_role.runner_builder.tf`.

    Two refusals, two moments. A wrong name is caught by shape, so `validate` has it. A wrong combination of values is caught when the values exist, so `plan` has it. Worth knowing which is which before you go looking for one in the wrong place.

13. Compare your tree with the checkpoint this lesson ends at.

    ```sh
    git add -N access
    git diff --stat checkpoint/i2 -- access/envs access/identity access/modules
    ```

    Nothing printed means your leaf files are the reference leaf files. `access/README.md` stays out of the compare because the reference one already describes lessons you have not reached.

## Self-paced

Everything here runs on the laptop, with no Floci and no AWS account. `terraform plan` in step 10 reaches nothing, because there is no state to refresh and every resource is a create.

`access/identity` is the honest limit. It is validated on every run and it is never planned or applied without a real organization, because Identity Center is one of the two AWS services Floci does not emulate. The lesson does not pretend otherwise and the module does not soften the rule for the emulator. It refuses instead, which is what step 12 shows.

The other thing you cannot see yet is the check that would catch an `aws_iam_user` in this repo. `no-iam-user-or-group` is one of the nine rules lesson 3 writes, so the second half of prescription 3 is open until then, and the expired-grant half stays open until lesson 7 builds the watch.

## Live

Fifteen minutes. The room watches lesson 1's three files become one module call, then watches step 5 make a whole new principal out of `cp` and four edits. Then step 11, which is the one to slow down for. Say this while the error is on screen. The persona set is closed on purpose, so the only way to invent a new kind of principal is to release the module, which means a review by the people who own the guardrails rather than a line in a pull request nobody reads.

## Further reading

- [Personas](../../docs/design/personas.md), the closed set and why teams are a parameter
- [The estate](../../docs/estate.md), the five principals this lesson declares
- [Prescriptions](../../docs/prescriptions.md), P2 and P3
- [access/modules/persona/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/modules/persona/README.md), the module's own contract
- [access/identity/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/identity/README.md), why the human half is live only
- [Decisions](../../docs/decisions.md) 5 and 41
- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A4 and A5
