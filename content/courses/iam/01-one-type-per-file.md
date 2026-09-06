---
title: "One resource per file"
id: "I1"
lesson: 1
weight: 1
summary: "The repo is Terraform with one resource per file."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i1-one-type-per-file"
# card. empty renders as TODO
goal: "Build the first environment of the access repo from an empty tree. Write one Terraform resource block per file under `access/envs/prod`, name every file after the resource address inside it, wire one provider block that reaches either Floci or a real account, and check in the local backend so a fresh clone runs `terraform init` with no AWS account. Then break the convention on purpose and watch Terraform accept it, which is the gap lesson 3 closes."
done_when: "`terraform fmt -check -recursive access`, `terraform init` and `terraform validate` are all green in `access/envs/prod`, and `git diff checkpoint/i1 -- access/envs access/backends access/scripts` prints nothing. The other half of prescription 1, the rules that fail a two-resource file and a misnamed one in the editor, is built in lesson 3."
restart_from: "checkpoint/i0, the repo before access/ existed"
properties: ["I"]
closes: ["P1", "P2"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "40 min"
  needs: ["a water park checkout on main", "`terraform` 1.9 or newer on the PATH", "`tflint` from `brew install terraform-linters/tap/tflint`", "`just access-init` run once in that checkout", "no Floci and no AWS account"]
  solo: true
  live: true
---

## Context

- The access repo is this repo. It holds Terraform at `access/envs/<env>/<resource_type>.<label>.tf`, one `resource` block per file, with the provider prefix dropped from the type. `aws_iam_role.site_publisher` lives in `iam_role.site_publisher.tf`.
- Terraform already reads every `.tf` in a directory as one module, so nothing assembles anything and there is no generated file. The names buy a reader an index and buy the machine nothing, which is why the machine has to be taught to care about them.
- Terraform will not teach it. `terraform validate` and `terraform fmt` both accept a file called `role.tf` holding four resources. The two rules that refuse it are Rego, run by `tflint-ruleset-opa`, and lesson 3 writes them.
- A file that holds no `resource` block is exempt from the naming rule, which is how `provider.tf`, `variables.tf`, `versions.tf`, `locals.tf` and `outputs.tf` keep their conventional names.
- One provider block covers both targets. The `floci` variable defaults to `true`, so the solo path needs no credential. The checked-in backend is local for the same reason, and `access/scripts/backend s3 envs/prod` swaps in the real one.

## Do

1. Make a worktree at the checkpoint this lesson starts from. Run this in your water park checkout.

   ```sh
   git fetch origin --tags
   git worktree add ../waterpark-i1 checkpoint/i0
   cd ../waterpark-i1
   ```

   `checkpoint/i0` is the repo before `access/` existed, so this directory has `content/` and `skills/` and no estate at all. Every command below runs here. Your original checkout is untouched and stays available as the reference copy.

2. Make the directories, and copy in the plumbing you are not writing by hand. The versions pin, the provider, the variables, the locals and the two backend files never change again across the whole course, so take them from the checkout you cloned rather than typing them. Substitute the real path if your checkout is not `../waterpark`.

   ```sh
   mkdir -p access/envs/prod access/envs/dev access/backends access/scripts
   cp ../waterpark/access/envs/prod/versions.tf ../waterpark/access/envs/prod/provider.tf ../waterpark/access/envs/prod/variables.tf ../waterpark/access/envs/prod/locals.tf access/envs/prod/
   cp ../waterpark/access/backends/backend.local.tf ../waterpark/access/backends/backend.s3.tf access/backends/
   cp ../waterpark/access/scripts/backend access/scripts/backend
   cp ../waterpark/access/.gitignore access/.gitignore
   chmod +x access/scripts/backend
   ```

   Now read `access/envs/prod/provider.tf`. One block, two targets. With `var.floci` true it points `iam`, `sts` and `s3` at `http://localhost:4566`, hands the provider the throwaway `test` key pair, and skips every call that would resolve a real account. With `-var floci=false` the same code talks to `waterpark-prod`. Nothing in this lesson starts Floci, and nothing in this lesson needs it.

3. Write the two buckets, one file each. The estate has a bucket the published site is served from and a bucket the build artifacts land in.

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

   Both carry an `owner` tag, so an access review can answer who to ask about a resource from the tag alone. `local.owner` came in with `locals.tf` in step 2.

4. Write the role. `site-publisher` is the workload that builds the site and writes it to the site bucket.

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

5. Write the policy and the attachment, as two more files. This is the shape the convention forces. Three resources means three files, and a reader who sees `aws_iam_policy.site_publisher_read_artifacts` in a plan can guess the path without searching.

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

   Three files for one grant is the cost of the convention, and lesson 2 is where the module collapses them back into one call. Notice that the grant is already spelled as four named actions rather than `s3:*`, which is the rule lesson 3 writes down.

6. Write the environment's output, so something outside this directory can read the role back by name.

   `access/envs/prod/outputs.tf`

   ```hcl
   output "roles" {
     description = "The workload roles this environment declares, by principal name."
     value = {
       site-publisher = aws_iam_role.site_publisher.arn
     }
   }
   ```

7. Pick the backend and run the checks. The swap script copies one of the two backend files into the env directory and removes the other, because Terraform allows one backend block per root module.

   ```sh
   access/scripts/backend local envs/prod
   terraform fmt -check -recursive access
   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod validate
   ```

   `fmt -check` is silent and exits 0 when every file is formatted. `init` writes `.terraform/` and a lock file, both of which `access/.gitignore` keeps out of the repo. `validate` says the configuration is valid. All three ran with no credential and no account.

8. Compare your tree with the checkpoint the lesson ends at.

   ```sh
   git add -N access
   git diff --stat checkpoint/i1 -- access/envs access/backends access/scripts
   ```

   Nothing printed means your tree is the reference tree. `git add -N` records the new files as intent-to-add so the diff can see them, and stages no content. Drop `--stat` for the line-by-line version. `access/README.md` stays out of the compare because the reference one already describes lessons you have not reached.

9. Break the convention on purpose, and watch nothing complain.

   ```sh
   mv access/envs/prod/iam_role.site_publisher.tf access/envs/prod/role.tf
   cat access/envs/prod/iam_policy.site_publisher_read_artifacts.tf >> access/envs/prod/role.tf
   rm access/envs/prod/iam_policy.site_publisher_read_artifacts.tf
   terraform -chdir=access/envs/prod validate
   terraform fmt -check -recursive access
   ```

   `role.tf` now holds two `resource` blocks and repeats neither address, and both commands still exit 0. That is the honest state of prescription 1 at the end of lesson 1. The convention is real and the enforcement is not. Lesson 3 writes `one-type-per-file` and `path-matches-name`, and against this exact tree they say `role.tf holds 2 resource blocks. One resource per file. Move aws_iam_policy.site_publisher_read_artifacts into its own iam_policy.site_publisher_read_artifacts.tf.` and `role.tf holds aws_iam_role.site_publisher. Rename the file to iam_role.site_publisher.tf, so the path repeats the resource address.`

   Put it back with two commands, or leave the mess, because lesson 2 starts in a fresh worktree of its own.

   ```sh
   git checkout checkpoint/i1 -- access/envs/prod
   rm access/envs/prod/role.tf
   ```

## Self-paced

The whole lesson runs on the laptop. No Floci, no AWS account, no credential anywhere. `terraform init` reaches the provider registry once to download the AWS provider and touches nothing else. The lock file it writes is deliberately not committed, because a lock file records provider hashes for the platforms it was generated on and students take this course on three of them.

`tflint` sits idle here. It is in the setup list because lesson 3 needs it, and because installing it early means one fewer thing to do later. Note the tap, `brew install terraform-linters/tap/tflint` rather than the core formula.

What this lesson cannot show is an applied estate. Nothing here has been created anywhere. Lesson 4 starts Floci and applies, and lesson 5 is the first time IAM itself refuses something.

When you are finished with the worktree, `git worktree remove ../waterpark-i1` from your main checkout takes it away.

## Live

Twelve minutes. The room watches step 5 produce three files for one grant and groan, then watches step 9 pass both checks and stop groaning. Say this while step 9 is on screen. Terraform does not read file names, so every naming convention you have ever worked under was enforced by people remembering, and people stop remembering on a Friday. In lesson 3 we make the machine remember instead.

## Further reading

- [The estate](../../docs/estate.md), the accounts, principals and resources this repo declares
- [Prescriptions](../../docs/prescriptions.md), P1 and P2
- [access/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md), the layout, the two backends and the rule pack in one page
- [The AWS desk](../../docs/aws-desk.md)
- [Decisions](../../docs/decisions.md) 31, 32 and 33
- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A1 and A2
