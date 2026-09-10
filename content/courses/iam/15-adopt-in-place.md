---
title: "Adopt in place"
id: "I15"
lesson: 15
weight: 15
summary: "An import block brings what already exists under management, one file at a time, and changes nothing about it."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i15-adopt-in-place"
# card. empty renders as TODO
goal: "Make three things the way a console would, a role, a bucket and a security group with an open port, and watch the drift watch not see them. Then bring each under management with an `import` block and a resource block reviewed out of generated config, prove with a script that the only thing the apply changes is the tags the estate puts on what it owns, watch the rule pack refuse the adopted role the same way it would refuse a written one, back the group out with a `removed` block and find it still in the account, and say what walking away costs, which is nothing."
done_when: >-
  `access/scripts/adopt-check` reports three adoptions each changing nothing
  but the estate's own tags and fails one whose file misstates the account
  by naming the attribute, the apply reports `3 imported, 0 added, 3
  changed` and the replan exits 0, `aws iam list-role-tags` on
  `legacy-reporter` shows `managed_by`, `repo` and `env` beside the one tag
  it had, `access/scripts/check lint` fails on the adopted role's missing
  boundary and owner tag and warns on the group's open port, and after a
  `removed` block is applied `legacy-ssh` is still in the account and the
  replan still exits 0.
restart_from: "checkpoint/i11"
properties: ["I", "XII"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "35 min"
  needs:
    - "a water park checkout with the tags fetched"
    - "Docker running, or the Start-here stack up, whose Floci this lesson can use as it is"
    - "the patched Floci image ghcr.io/lex00/floci:iam-boundary"
    - "terraform 1.9 or newer"
    - "tflint from terraform-linters/tap/tflint"
    - "jq"
    - "just access-init run once per clone"
    - "lesson 11 finished or at least read"
---

## Context

- Adopt in place is import from live, one resource at a time (decision 38). An `import` block names the resource and its id, `terraform plan -generate-config-out` writes a first draft of the resource block from what the account holds, and you review that draft by hand into the one-file-per-resource layout, with `region`, `tags_all`, every null and every provider default dropped. The import block and the resource block share the file, because the file is the resource's whole story.
- Nothing about the resource changes on day one, and on this estate that sentence has one exception, which the lesson turns into a check. The provider's `default_tags` put `managed_by`, `repo` and `env` on everything the estate owns, so the plan for an import is never empty here. `access/scripts/adopt-check` reads the plan and passes an import whose only change is `tags_all`, and fails one that would change anything else, naming the attribute, because an apply would then edit the account rather than adopt it (decision 62).
- Adoption exempts nothing. An adopted role with no boundary and no owner tag fails the same rules a written one would, and the failing check after an adoption is day two's list. This is what one at a time buys. A bulk import declares a pile nobody has read, and the checks would refuse the pile all at once with nobody to answer for any of it.
- The drift watch cannot see a resource the repo does not declare. Lesson 7 said restoring is automatic and adopting is not, and this lesson is the other half of that sentence. Adopting is a file somebody wrote, planned and had reviewed, which is Accessible Ops XIII read from the outside in.
- A `removed` block with `lifecycle { destroy = false }` takes a resource out of state and leaves it in the account. It is applied once and then deleted from the repo, because after the apply it has nothing left to say.
- The estate stays in native form, so walking away means keeping the HCL and dropping everything else. There is no export bundle because there is nothing proprietary to export from, which is decision 2 and Accessible Ops I, and this lesson is the test of both.
- The adopted files are yours and never the repo's. The resources they import exist only where your hand made them, so they stay on your laptop, the reference tree carries the mechanism and no adoption, and the compare at the end excludes them.
- The group is the first `ec2` resource the estate has touched, so the provider gains an `ec2` endpoint for the emulator, the way lesson 8's satellite gained `ecr`. The inline `ingress` shape generated config writes is one the rule pack did not read until this lesson, and now `no-open-ingress` does.

## Do

Fourteen lessons wrote an estate from nothing. This one starts from what is already there, which is where every real estate starts.

1. Start from the checkpoint lesson 11 left, get an emulator, and apply central and then the satellite.

   ```sh
   git fetch origin --tags
   git worktree add ../waterpark-i15 checkpoint/i11
   cd ../waterpark-i15
   just access-init
   ```

   If the Start-here stack is up, its Floci already answers on port 4566
   and this lesson can use it as it is, so skip the `docker run` below. It
   runs with IAM enforcement off, which this lesson never needs, and it
   holds whatever earlier Fountain lessons left, which is nothing this
   lesson names. If the stack is down, start the container the earlier
   lessons started.

   ```sh
   docker run -d --name wp-i15-floci -p 4566:4566 \
     -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
     ghcr.io/lex00/floci:iam-boundary
   ```

   Either way, then

   ```sh
   curl -s --retry 15 --retry-all-errors --retry-delay 1 \
     -o /dev/null -w '%{http_code}\n' http://localhost:4566/

   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod apply -auto-approve
   terraform -chdir=access/satellites/waterpark-runner init
   terraform -chdir=access/satellites/waterpark-runner apply -auto-approve
   ```

   `200`, then `Resources: 18 added` and `8 added`.

2. Make three things the way a console would. A role for a reporting job somebody set up in 2024, a bucket it writes to, and a security group with port 22 open to the world. None of them goes through a pull request, and that is the point.

   ```sh
   export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1

   aws --endpoint-url http://localhost:4566 iam create-role --role-name legacy-reporter \
     --description "Made in the console in 2024." \
     --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]}' \
     --tags Key=team,Value=analytics --query Role.Arn --output text

   aws --endpoint-url http://localhost:4566 s3 mb s3://legacy-uploads

   SG=$(aws --endpoint-url http://localhost:4566 ec2 create-security-group \
     --group-name legacy-ssh --description "ssh from anywhere" --query GroupId --output text)
   aws --endpoint-url http://localhost:4566 ec2 authorize-security-group-ingress \
     --group-id $SG --protocol tcp --port 22 --cidr 0.0.0.0/0 --query Return
   echo $SG
   ```

   The ARN, `make_bucket: legacy-uploads`, `true`, and a group id like
   `sg-4ebfc472f9999f8c2`. Keep the id, two files below need it. The
   ingress call takes the id rather than the name, because the emulator
   does not resolve a group by name on that call.

   Now ask the watch.

   ```sh
   access/scripts/drift | tail -1
   ```

   `every watched root matches the account`. Three things the estate knows
   nothing about, and the watch is right to say nothing, because it compares
   what the repo declares against what the account holds and the repo
   declares none of them. Lesson 7 called this the asymmetry. Restoring is
   automatic, adopting is a file, and here are three files to write.

3. Adopt the role. Give the provider its first `ec2` endpoint while you are in `envs/prod`, since the group needs it. Open `access/envs/prod/provider.tf` and add one line inside the `content` block after `s3`.

   ```hcl
       content {
         iam = endpoints.value
         sts = endpoints.value
         s3  = endpoints.value
         ec2 = endpoints.value
       }
   ```

   Then write `access/envs/prod/iam_role.legacy_reporter.tf` with only the
   import block in it, and let Terraform draft the rest.

   ```hcl
   import {
     to = aws_iam_role.legacy_reporter
     id = "legacy-reporter"
   }
   ```

   ```sh
   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod plan -generate-config-out=generated.tf
   cat access/envs/prod/generated.tf
   ```

   `Plan: 1 to import, 0 to add, 1 to change, 0 to destroy.`, a warning
   that config generation is experimental, and the draft.

   ```hcl
   # __generated__ by Terraform from "legacy-reporter"
   resource "aws_iam_role" "legacy_reporter" {
     assume_role_policy = jsonencode({
       Statement = [{
         Action = "sts:AssumeRole"
         Effect = "Allow"
         Principal = {
           Service = "lambda.amazonaws.com"
         }
       }]
       Version = "2012-10-17"
     })
     description           = "Made in the console in 2024."
     force_detach_policies = false
     max_session_duration  = 3600
     name                  = "legacy-reporter"
     path                  = "/"
     permissions_boundary  = null
     tags = {
       team = "analytics"
     }
     tags_all = {
       team = "analytics"
     }
   }
   ```

   Read it against the role you made. The trust policy, the description,
   the name and the tag are yours. `force_detach_policies`,
   `max_session_duration` and `path` are the provider's defaults written
   out, `permissions_boundary = null` is an absence spelled as a value, and
   `tags_all` is what the provider computes and must never be declared. The
   review is dropping all of that. Replace the file with this, which is the
   import block and what the account actually holds.

   ```hcl
   # Adopted in lesson 15. This role existed before the repo did, made in a
   # console, and the import block below is what brought it under management.
   # Everything under the block is what the account held on the day, reviewed
   # out of terraform plan -generate-config-out and nothing else.
   import {
     to = aws_iam_role.legacy_reporter
     id = "legacy-reporter"
   }

   resource "aws_iam_role" "legacy_reporter" {
     name        = "legacy-reporter"
     description = "Made in the console in 2024."

     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect    = "Allow"
         Principal = { Service = "lambda.amazonaws.com" }
         Action    = "sts:AssumeRole"
       }]
     })

     tags = {
       team = "analytics"
     }
   }
   ```

   ```sh
   rm access/envs/prod/generated.tf
   ```

   `generated.tf` is in `.gitignore` already, because a draft is never the
   file.

4. Bring in the check, and run it before and after breaking the file on purpose.

   ```sh
   git checkout checkpoint/i15 -- \
     access/scripts/adopt-check \
     access/.tflint.d/policies/security.rego \
     access/tests/fixtures/no-open-ingress
   access/scripts/adopt-check
   ```

   ```
   adopt check, access/envs/prod

     [ok] aws_iam_role.legacy_reporter  from legacy-reporter
         the estate adds its tags: env, managed_by, repo

     1 adoption(s), and none changes anything but the estate's own tags.
   ```

   That is the plan, read for you. One import, and the one change is three
   tags the provider's `default_tags` put on everything the estate owns,
   which is the estate's mark and nothing the role had. Now misstate the
   account. Change `2024` to `2023` in the description, and run it again.

   ```
     [FAIL] aws_iam_role.legacy_reporter  from legacy-reporter
         the estate adds its tags: env, managed_by, repo
         the file differs from the account on: description
         fix the file, because an apply would edit the account

     1 of 1 adoption(s) would change the account. Adopt in place means the file says what is there.
   ```

   Exit `2`. An import whose file is wrong is not an adoption, it is an edit
   nobody asked for, dressed as one, and the check names the attribute so
   you fix the file rather than the account. Put `2024` back, see `[ok]`
   again, and apply.

   ```sh
   terraform -chdir=access/envs/prod apply -auto-approve
   terraform -chdir=access/envs/prod plan -detailed-exitcode
   echo $?
   aws --endpoint-url http://localhost:4566 iam list-role-tags --role-name legacy-reporter \
     --query 'Tags[].[Key,Value]' --output text
   ```

   `aws_iam_role.legacy_reporter: Import complete [id=legacy-reporter]`,
   `Resources: 1 imported, 0 added, 1 changed, 0 destroyed.`, then `0`, then
   four tags, `team analytics` as it was and the estate's three beside it.
   The role's trust, name and description did not move, and the account
   says so.

5. Adopt the other two, in one apply. Write `access/envs/prod/s3_bucket.legacy_uploads.tf`.

   ```hcl
   # Adopted in lesson 15. See iam_role.legacy_reporter.tf.
   import {
     to = aws_s3_bucket.legacy_uploads
     id = "legacy-uploads"
   }

   resource "aws_s3_bucket" "legacy_uploads" {
     bucket = "legacy-uploads"
   }
   ```

   And `access/envs/prod/security_group.legacy_ssh.tf`, with your group id
   from step 2 in the import block.

   ```hcl
   # Adopted in lesson 15. See iam_role.legacy_reporter.tf.
   import {
     to = aws_security_group.legacy_ssh
     id = "sg-4ebfc472f9999f8c2"
   }

   resource "aws_security_group" "legacy_ssh" {
     name        = "legacy-ssh"
     description = "ssh from anywhere"
     vpc_id      = "vpc-default-us-east-1"

     ingress {
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
     }

     egress {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
     }
   }
   ```

   Both are the generated draft reviewed the same way, and you can prove
   that by running `-generate-config-out` again first if you like. The
   bucket's draft carries `bucket_namespace`, `force_destroy`,
   `object_lock_enabled` and `region`, all defaults, and the group's
   carries the same `tags_all` and `region` plus an egress rule the account
   made for it. The egress stays, because the account holds it.

   ```sh
   access/scripts/adopt-check
   terraform -chdir=access/envs/prod apply -auto-approve
   terraform -chdir=access/envs/prod plan -detailed-exitcode
   echo $?
   ```

   Three `[ok]` rows, the first one now reading `nothing changes on import`
   because it is already in, `Resources: 2 imported, 0 added, 2 changed`,
   and `0`.

6. Run the check stack, and read the refusal as a list.

   ```sh
   just access-check
   ```

   ```
   iam_role.legacy_reporter.tf:10:1: Error - aws_iam_role.legacy_reporter carries no owner tag. Add tags = { owner = local.owner }, or pass owner to modules/persona. (opa_deny_tag_owner_required)
   s3_bucket.legacy_uploads.tf:7:1: Error - aws_s3_bucket.legacy_uploads carries no owner tag. Add tags = { owner = local.owner }, or pass owner to modules/persona. (opa_deny_tag_owner_required)
   iam_role.legacy_reporter.tf:10:1: Error - aws_iam_role.legacy_reporter carries no permissions_boundary. Every role water park emits sits inside the estate boundary from access/baseline. (opa_deny_boundary_required)
   security_group.legacy_ssh.tf:16:19: Warning - aws_security_group.legacy_ssh opens 22 to 0.0.0.0/0 in an inline ingress block. Name the source security group, and declare the rule as its own aws_vpc_security_group_ingress_rule so it has an address a review can point at. (opa_warn_no_open_ingress)
   FAIL  tflint in access/envs/prod
   ```

   Two errors on the role, one on the bucket, a warning on the group, and
   `check failed`. Nothing about being adopted exempts a resource from the
   rules, and that is what one at a time is for. This list is day two. A
   boundary on the role, an owner on both, and a source group instead of the
   world, each its own pull request with the plan showing exactly that
   change. The warning is new in this lesson. `no-open-ingress` read only
   the standalone rule shape until now, and the inline shape is what
   generated config writes, so an adopted group with an open port would
   have slipped past a rule written to catch it. Step 4 brought the widened
   rule and its fixtures in.

7. Back the group out without destroying it. Delete its file and write `access/envs/prod/removed.legacy_ssh.tf`.

   ```sh
   rm access/envs/prod/security_group.legacy_ssh.tf
   ```

   ```hcl
   # Back the group out of management without destroying it. The block is
   # applied once and then deleted from the repo, because there is nothing left
   # for it to say.
   removed {
     from = aws_security_group.legacy_ssh

     lifecycle {
       destroy = false
     }
   }
   ```

   ```sh
   terraform -chdir=access/envs/prod plan
   terraform -chdir=access/envs/prod apply -auto-approve
   aws --endpoint-url http://localhost:4566 ec2 describe-security-groups --group-ids $SG \
     --query 'SecurityGroups[0].GroupName' --output text
   rm access/envs/prod/removed.legacy_ssh.tf
   terraform -chdir=access/envs/prod plan -detailed-exitcode
   echo $?
   ```

   `# aws_security_group.legacy_ssh will no longer be managed by Terraform, but will not be destroyed`
   and `Plan: 0 to add, 0 to change, 0 to destroy.`, then the apply, then
   `legacy-ssh` from the account, then `0` with the block gone. The group is
   exactly where it was, the repo has stopped claiming it, and the watch has
   stopped watching it. That is the reverse of step 5 and it cost the account
   nothing either way.

8. Say what walking away costs.

   ```sh
   ls access/envs/prod/*.tf
   ```

   That listing is the handover. Every file is HCL the provider applies
   directly, the import blocks are Terraform's own syntax, and nothing in
   the directory is a format this course invented. A team that stops using
   water park keeps the directory and drops the checks, the scripts and the
   workflow, and the estate is exactly as manageable as it was, which is
   decision 2's whole claim and the reason there is no export bundle to
   build.

9. Compare with the reference repo, then tear down. The three adopted files are yours and not the repo's, because the resources they import exist only where your hand made them, so the compare leaves them out.

   ```sh
   git add -A access .github
   git diff --cached --stat checkpoint/i15 -- access .github ':!*README.md' ':!access/envs/prod/*legacy*'

   terraform -chdir=access/satellites/waterpark-runner destroy -auto-approve
   terraform -chdir=access/envs/prod destroy -auto-approve
   aws --endpoint-url http://localhost:4566 ec2 delete-security-group --group-id $SG
   ```

   Nothing printed means the provider line, the rule and the check are the
   reference's. The destroy takes `legacy-reporter` and `legacy-uploads`
   with it, because they are managed now and that is what managed means,
   and it leaves `legacy-ssh`, because step 7 gave it back, so the last
   line removes it by hand. If you started your own container in step 1,
   `docker rm -f wp-i15-floci` as well.

## Self-paced

The whole lesson runs on the emulator, and it runs on the Start-here stack's Floci without enforcement, because nothing here is a refusal by IAM. Every import, every plan and the `removed` block behave on Floci as they do on a real account, which plan phase 0 verified before any IAM lesson was written and this lesson leans on.

Two things a real account adds. Real resources carry more than a console fixture does, so the generated draft is longer and the review is more work, and that is the honest cost of one at a time. And on a real account the three default tags land on resources other teams can see, which is why adopting is a pull request somebody reviews rather than a script somebody runs.

The adopted files never join the reference tree. The compare excludes them and the checkpoint carries none, because a checked-in import of a resource that exists only on one laptop would fail every other laptop's plan and the CI job's too.

## Live

Twenty minutes, and the room needs steps 2, 4 and 6.

Open on step 2 with the three console fixtures already made, and run `drift` in front of the room. The line to say is that the watch is right to say nothing, because it watches what the repo declares and the repo does not know these exist. Then step 4 whole, with the `2023` edit typed live. The check names the attribute, and the line to say is that an import whose file is wrong is an edit nobody asked for, and the only defence is a check that reads the plan rather than a reviewer who trusts the word adopt.

Then step 6, and let the room read the four lines. The honesty line is that adopting a resource earns it nothing, that the checks fail it exactly as they would fail a new file, and that the failing list is the work, one pull request each, which is the only way a real estate has ever been brought to conform.

Live, the same files import from a real sandbox account, the generated drafts are longer, and the room can watch a role that predates the repo acquire the repo's tags and nothing else.

## Further reading

- [access/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md), "Lesson 15, adopt in place"
- [access/scripts](https://github.com/INTENTIUS/waterpark/blob/main/access/scripts/README.md), `adopt-check`
- [Lesson 7, drift](07-drift.md), the asymmetry this lesson completes
- [Decisions](../../docs/decisions.md), 2, 3, 38 and 62
- [Upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md), plan phase 0's import verification
- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A14 and A21
- [Landscape](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/landscape.md), IAMbic
