---
title: "The permission boundary"
id: "I5"
lesson: 5
weight: 5
summary: "The permission boundary caps every role and the apply role itself."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i5-the-permission-boundary"
# card. empty renders as TODO
goal: "Write one permission boundary for the whole estate in a baseline module, put it on every role the persona module makes, exempt it from the wildcard rule because a ceiling is not a grant, promote boundary-required from a warning to an error, and prove the bounded estate still reaches a clean plan with the boundary read back out of the cloud."
done_when: "`just access-check` passes with `boundary-required (error)` and no boundary warning left anywhere, `terraform -chdir=access/envs/prod plan -detailed-exitcode` exits 0 with the boundary applied, and `aws iam get-role --role-name site-publisher` returns a `PermissionsBoundary` block naming `waterpark-estate-boundary`, whose policy document denies `iam:DeleteRolePermissionsBoundary` and `iam:PutRolePermissionsBoundary`."
restart_from: "checkpoint/i4"
properties: ["VI", "III"]
closes: ["P7"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "45 min"
  needs:
    - "a water park checkout with the tags fetched"
    - "Docker running"
    - "the patched Floci image ghcr.io/lex00/floci:iam-boundary"
    - "terraform 1.9 or newer"
    - "tflint from terraform-linters/tap/tflint"
    - "just access-init run once per clone"
    - "lesson 4 finished or at least read"
  solo: true
  live: true
---

## Context

- A boundary caps what an identity-based policy can grant, because effective permissions are the intersection of the two. A role inside the estate cannot be made more powerful than the boundary says, whatever its own policy claims, and that is what makes delegating role creation safe in lesson 8.
- One boundary covers the whole estate and it lives in `access/baseline/` as an `aws_iam_policy` under a deterministic name, so every stack references it by name and nothing hardcodes an ARN (decision 36). Splitting per OU waits until an OU needs it.
- It denies all IAM write, Organizations, Identity Center, the guardrail-path resources by name and boundary detachment, and it allows the service surface an app team plausibly needs. The guardrail path is the boundary policy itself, the apply role and the state bucket, which is decision 12 standing in the policy rather than in a document. Water park must not be able to escalate water park.
- The Sandbox OU carries no boundary at all, because sandboxes exist to be broken and the live session guide has the room break things there. The exemption is a module variable rather than an environment flag. `sandbox = true` and the module emits no policy and hands back a null ARN.
- The why travels with the artifact. The policy `description` is on the object in the account, and each `Deny` carries a comment saying what it stops. That is property III standing where it is enforced.
- Two enforcement layers, deliberately redundant. At build, `boundary-required` fails a role declared without one, in the editor. At apply, IAM refuses the call. The convenient layer gives fast feedback and the cloud layer gives the guarantee.
- `boundary-required` landed as a warning in lesson 3, because the boundary it asks for did not exist. Promoting it here is the warn cycle decision 9 asks for, and the promotion is a one-word edit in the Rego plus one line in `access/scripts/check`.
- `baseline/` also holds the constants later lessons read, the two hour break-glass maximum (decision 37) and the watcher's cap of five open PRs (decision 40), as outputs rather than as numbers on a page.

## Do

Lesson 4 applied an estate whose roles carry no ceiling, and left one warning standing in the check stack. This lesson builds the ceiling and turns the warning into an error.

1. Start from the checkpoint lesson 4 left, bring Floci up, and apply the unbounded estate so you can watch the boundary land on roles that already exist.

   ```sh
   git fetch origin --tags
   git worktree add ../waterpark-i5 checkpoint/i4
   cd ../waterpark-i5
   just access-init

   docker run -d --name wp-i5-floci -p 4566:4566 \
     -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
     ghcr.io/lex00/floci:iam-boundary

   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod apply -auto-approve
   ```

   Then confirm there is no ceiling yet.

   ```sh
   AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 \
     aws --endpoint-url http://localhost:4566 iam get-role \
     --role-name site-publisher --query 'Role.PermissionsBoundary'
   ```

   It prints `null`. Every command from here on uses that same three-variable prefix for the AWS CLI, and none of it is a credential.

2. Write the baseline module. Four files under a new `access/baseline/` directory, and the file naming rule from lesson 1 still holds, so the policy goes in `iam_policy.boundary.tf`.

   `access/baseline/versions.tf`, the same pins the other roots carry.

   ```hcl
   terraform {
     required_version = ">= 1.9.0"

     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 6.0"
       }
     }
   }
   ```

   `access/baseline/variables.tf`. `boundary_name` is deterministic so nothing hardcodes an ARN. `sandbox` is the Sandbox OU exemption, and it is a variable on this module rather than an environment flag, so an environment that wants no boundary says so in its own `baseline.tf` and the decision is greppable. `state_bucket` and `apply_role_name` are the guardrail path, named here so the deny below can name them.

   ```hcl
   variable "boundary_name" {
     description = "The deterministic name of the estate boundary. Deterministic so every stack references it by name and nothing hardcodes an ARN."
     type        = string
     default     = "waterpark-estate-boundary"
   }

   variable "sandbox" {
     description = "Whether this environment is in the Sandbox OU. A sandbox carries no boundary at all, because sandboxes exist to be broken and the live session guide has the room break things there (decision 36). Set this true and the module emits no policy and hands back a null ARN."
     type        = bool
     default     = false
   }

   variable "owner" {
     description = "Who to ask about the baseline. The guardrail path is platform's by rule."
     type        = string
     default     = "platform"
   }

   variable "state_bucket" {
     description = "The Terraform state bucket in waterpark-security. On the guardrail path, so the boundary denies touching it."
     type        = string
     default     = "waterpark-terraform-state"
   }

   variable "apply_role_name" {
     description = "The role the apply job assumes. On the guardrail path, so the boundary denies touching it. water park must not be able to escalate water park (decision 12)."
     type        = string
     default     = "waterpark-apply"
   }
   ```

   `access/baseline/locals.tf`. This is the content of the boundary, as four lists plus the two constants later lessons read.

   ```hcl
   locals {
     # The constants later lessons read from here rather than from a page.
     #
     # Break-glass carries a cloud-side expiry and the maximum is two hours, and
     # a check refuses a longer one (decision 37). The watcher holds at most five
     # open PRs, and the PR job counts them so the cap holds when the prompt is
     # ignored (decision 40). Both live here so a student can change one number
     # in one place and watch the checks move with it.
     break_glass_max_ttl_hours = 2
     watcher_max_open_prs      = 5

     # Everything the boundary denies, as one list the I6 proof checks consume.
     # These are the actions no role inside the estate may hold, whatever its
     # own policy says.
     forbidden_actions = [
       # All IAM write. Permissions management goes through the repo, so an
       # identity inside the estate never edits an identity.
       "iam:Add*",
       "iam:Attach*",
       "iam:Create*",
       "iam:Delete*",
       "iam:Detach*",
       "iam:Put*",
       "iam:Remove*",
       "iam:Set*",
       "iam:Tag*",
       "iam:Untag*",
       "iam:Update*",
       "iam:Upload*",

       # The org layer. Accounts are vended elsewhere and policies are the
       # management account's (decision 11).
       "organizations:*",

       # Identity Center and the identity store behind it. Human access is
       # central without exception, because a permission set's blast radius is
       # every account it is assigned into.
       "sso:*",
       "sso-directory:*",
       "identitystore:*",
     ]

     # Detaching the cap is the one move that would make every other deny
     # pointless, so it gets its own statement rather than hiding in the list.
     boundary_detachment_actions = [
       "iam:DeleteRolePermissionsBoundary",
       "iam:DeleteUserPermissionsBoundary",
       "iam:PutRolePermissionsBoundary",
       "iam:PutUserPermissionsBoundary",
     ]

     # The service surface an app team plausibly needs. A boundary is a ceiling
     # rather than a grant, so these are the services a role may be given access
     # to by its own policy, not access it holds.
     service_surface = [
       "s3:*",
       "logs:*",
       "cloudwatch:*",
       "ecr:*",
       "sqs:*",
       "sns:*",
       "dynamodb:*",
       "ssm:GetParameter",
       "ssm:GetParameters",
       "ssm:GetParametersByPath",
       "secretsmanager:GetSecretValue",
       "secretsmanager:DescribeSecret",
       "kms:Decrypt",
       "kms:Encrypt",
       "kms:GenerateDataKey",
       "sts:AssumeRole",
       "sts:GetCallerIdentity",
       "sts:TagSession",
     ]

     # The guardrail path, by name. The boundary policy itself, the state bucket
     # and the apply role. Nothing inside the estate touches the things that
     # decide what the estate may be.
     guardrail_resources = [
       "arn:aws:iam::*:policy/${var.boundary_name}",
       "arn:aws:iam::*:role/${var.apply_role_name}",
       "arn:aws:s3:::${var.state_bucket}",
       "arn:aws:s3:::${var.state_bucket}/*",
     ]
   }
   ```

   `access/baseline/iam_policy.boundary.tf`, the policy itself. Four statements, one allow and three denies, each carrying its reason beside it.

   ```hcl
   resource "aws_iam_policy" "boundary" {
     count = var.sandbox ? 0 : 1

     name        = var.boundary_name
     description = "The estate boundary. Every role water park emits sits inside it. It denies all IAM write, Organizations, Identity Center, the guardrail-path resources by name and boundary detachment, and it allows the service surface an app team plausibly needs. Changing it is a platform PR (decision 36)."

     policy = jsonencode({
       Version = "2012-10-17"
       Statement = [
         {
           # The ceiling. A role inside the estate may be granted access to
           # these services by its own policy and to nothing else.
           Sid      = "ServiceSurface"
           Effect   = "Allow"
           Action   = local.service_surface
           Resource = "*"
         },
         {
           # Permissions management always goes through the repo, so no identity
           # inside the estate edits an identity, its own included. This is the
           # deny that makes delegation safe, because a satellite that creates a
           # role inside this boundary cannot make it more powerful than this.
           Sid      = "NoIdentityWrite"
           Effect   = "Deny"
           Action   = local.forbidden_actions
           Resource = "*"
         },
         {
           # Detaching the cap would make every other deny pointless, so it is
           # denied on its own. The apply role carries this same boundary, which
           # is how water park cannot escalate water park (decision 12).
           Sid      = "NoBoundaryDetachment"
           Effect   = "Deny"
           Action   = local.boundary_detachment_actions
           Resource = "*"
         },
         {
           # The guardrail path by name. The boundary policy itself, the apply
           # role and the state bucket. These decide what the estate may be, so
           # nothing inside the estate touches them.
           Sid      = "NoGuardrailPath"
           Effect   = "Deny"
           Action   = "*"
           Resource = local.guardrail_resources
         },
       ]
     })

     tags = {
       owner = var.owner

       # The rule pack skips a boundary on no-wildcard-action, because a
       # boundary is a ceiling rather than a grant and a wildcard here narrows
       # nothing. This tag is what marks it.
       guardrail = "boundary"
     }
   }
   ```

   The `count` is the sandbox exemption. Set `sandbox = true` and there is no policy at all, not a permissive one.

   `access/baseline/outputs.tf`, what the rest of the estate reads.

   ```hcl
   output "boundary_arn" {
     description = "The estate boundary, for every role the persona module makes. Null in a sandbox, which carries no boundary at all (decision 36)."
     value       = var.sandbox ? null : aws_iam_policy.boundary[0].arn
   }

   output "boundary_name" {
     description = "The deterministic boundary name, so another stack can reference it without a hardcoded ARN."
     value       = var.boundary_name
   }

   output "forbidden_actions" {
     description = "What the boundary denies. The lesson 6 proof checks read this list rather than re-stating it."
     value       = local.forbidden_actions
   }

   output "break_glass_max_ttl_hours" {
     description = "The longest a break-glass grant may last. Two hours, enforced cloud-side by an aws:CurrentTime condition (decision 37)."
     value       = local.break_glass_max_ttl_hours
   }

   output "watcher_max_open_prs" {
     description = "How many open PRs the watcher may hold at once. Five, counted by the PR job so the cap holds when the prompt is ignored (decision 40)."
     value       = local.watcher_max_open_prs
   }
   ```

3. Put the new root under the checks, and watch a rule you wrote in lesson 3 refuse the boundary. Open `access/scripts/check` and add `baseline` to the `roots` array, between `identity` and `modules/persona`. Then

   ```sh
   just access-check lint
   ```

   Seven errors, all `opa_deny_no_wildcard_action` on `baseline/iam_policy.boundary.tf`, one per wildcard in the service surface. `s3:*`, `logs:*`, `cloudwatch:*`, `ecr:*`, `sqs:*`, `sns:*` and `dynamodb:*`. The rule is right about what it sees and wrong about what it means. In a grant, `s3:*` is unreviewable because nobody can say what it will allow when the service adds an API next year. In a ceiling, `s3:*` says a role may be given S3 access by its own policy and nothing more, and every action outside the list is refused however the grant is written. Widening a grant widens access. Widening a ceiling still grants nothing.

4. Exempt a boundary, by tag rather than by name. Open `access/.tflint.d/policies/security.rego` and add the helper.

   ```rego
   # A permission boundary is a ceiling rather than a grant, so a wildcard in it
   # narrows the estate instead of widening it, and no-wildcard-action does not
   # apply. The exemption is a tag on the policy rather than a name match, so it
   # is deliberate and greppable.
   is_boundary(r) if {
   	not r.config.tags.unknown
   	r.config.tags.value.guardrail == "boundary"
   }
   ```

   Then teach `deny_no_wildcard_action` to ask it. The rule needs the tags in scope, so the schema gains one entry and the body gains one line.

   ```rego
   deny_no_wildcard_action contains issue if {
   	some r in terraform.resources("aws_iam_policy", {"policy": "string", "tags": "map(string)"}, {"expand_mode": "none"})
   	not is_boundary(r)
   	not r.config.policy.unknown
   ```

   An exemption with no fixture is an exemption nobody will notice breaking, so give it one. Write `access/tests/fixtures/no-wildcard-action/pass/iam_policy.boundary.tf`.

   ```hcl
   # Passes no-wildcard-action even though it carries s3:*, because the
   # guardrail = "boundary" tag marks it a ceiling rather than a grant. A
   # wildcard in a boundary narrows the estate instead of widening it.
   resource "aws_iam_policy" "boundary" {
     name = "example-boundary"

     policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect   = "Allow"
         Action   = ["s3:*"]
         Resource = "*"
       }]
     })

     tags = {
       owner     = "platform"
       guardrail = "boundary"
     }
   }
   ```

   Run `just access-check lint` again. `access/baseline` is ok, and the only thing left is the boundary warning on `modules/persona`, which is still true, because no role carries a boundary yet.

5. Call the module from the environment. Write `access/envs/prod/baseline.tf`.

   ```hcl
   # The estate boundary and the constants later lessons read. One boundary for
   # the whole estate, so this call is the only place it is made (decision 36).
   module "baseline" {
     source = "../../baseline"

     owner = local.owner

     # waterpark-prod is not a sandbox. A Sandbox OU environment sets this true
     # and gets no boundary at all.
     sandbox = false
   }
   ```

6. Apply the boundary to every role the persona module makes, so no grant restates it and no leaf file can forget it. Add the variable to `access/modules/persona/variables.tf`.

   ```hcl
   variable "permissions_boundary" {
     description = "The estate boundary from access/baseline. Every workload role the module makes sits inside it, so the boundary is applied here rather than restated per grant. Null only in a sandbox, which carries no boundary at all (decision 36)."
     type        = string
     default     = null
   }
   ```

   And use it in `access/modules/persona/iam_role.this.tf`, under `description`.

   ```hcl
     # Every role water park emits carries the boundary, applied here so a leaf
     # file never restates it. The lint rule and the cloud enforce the same
     # thing, deliberately twice.
     permissions_boundary = var.permissions_boundary
   ```

7. Name it once in each leaf file. Add the same line to all three of `access/envs/prod/iam_role.site_publisher.tf`, `iam_role.runner_builder.tf` and `iam_role.desk_operator.tf`, under `teams` and above `grants`.

   ```hcl
     permissions_boundary = module.baseline.boundary_arn
   ```

   A leaf file mentioning the boundary looks like the opposite of what step 6 just bought, so it is worth saying why it is there. That line is the dependency edge. It is what tells Terraform that `module.baseline` produces something `module.site_publisher` consumes, so the policy is created before the roles that reference it, in one apply, with no `depends_on` and no two-phase bootstrap. Ten grants across three files still say nothing about the boundary, which is the property that was wanted. One line per principal file, always the same line, is what buys the ordering.

8. Promote the rule. In `access/.tflint.d/policies/security.rego`, rename one function.

   ```rego
   deny_boundary_required contains issue if {
   ```

   The prefix is the severity, so `warn_` to `deny_` is the whole promotion. Then tell the fixture runner the new function name, in `access/scripts/check`.

   ```sh
   	"boundary-required:deny_boundary_required"
   ```

   That is the warn cycle from lesson 3 completing. A rule lands as a warning while the estate does not conform, and is promoted once it does. Nothing was ever merged red.

9. Run the whole stack, and expect it to fail in exactly one place.

   ```sh
   just access-check
   ```

   fmt, validate and tflint pass, `boundary-required (error)` passes its fixtures, and the plan stage you added in lesson 4 says `FAIL  envs/prod has an unapplied diff`. That is correct. The repo now declares a boundary the account does not have. The check is refusing to call a repo green when the cloud disagrees with it.

10. Apply, and prove it.

    ```sh
    terraform -chdir=access/envs/prod init
    terraform -chdir=access/envs/prod apply -auto-approve
    terraform -chdir=access/envs/prod plan -detailed-exitcode
    echo $?
    ```

    `Apply complete! Resources: 1 added, 3 changed, 0 destroyed.` One policy created, three roles updated in place. Then "No changes." and `0`.

    Now read the ceiling back out of the cloud rather than out of state.

    ```sh
    export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1

    aws --endpoint-url http://localhost:4566 iam get-role \
      --role-name site-publisher --query 'Role.PermissionsBoundary'

    aws --endpoint-url http://localhost:4566 iam get-policy-version \
      --policy-arn arn:aws:iam::000000000000:policy/waterpark-estate-boundary \
      --version-id v1 \
      --query 'PolicyVersion.Document.Statement[?Sid==`NoBoundaryDetachment`]'
    ```

    The first prints a `PermissionsBoundaryArn` ending in `policy/waterpark-estate-boundary`, where step 1 printed `null`. The second prints the four detachment actions under a `Deny`. That second command is the sharp end of prescription 7, standing in the account. The apply role sits inside this same boundary, so the thing that applies water park cannot take water park's ceiling off. The proof check that runs it as a test lands in lesson 6, which reads `forbidden_actions` out of `baseline` rather than restating the list.

    Then `just access-check` again, end to end. `check passed`, with no warning left anywhere.

11. Read the two constants the baseline exports, because lessons 10 and 13 will read them from here rather than from a page.

    ```sh
    echo 'module.baseline.break_glass_max_ttl_hours' | terraform -chdir=access/envs/prod console
    echo 'module.baseline.watcher_max_open_prs' | terraform -chdir=access/envs/prod console
    ```

    `2` and `5`. Two hours is the break-glass maximum from decision 37 and five is the watcher's open PR cap from decision 40. Both are one number in one file, so lesson 13 can have a student change one and watch the checks move with it.

12. Compare with the reference repo, then tear down. `access/baseline` is new, and untracked files do not appear in a diff, so stage first.

    ```sh
    git add -A access
    git diff --cached checkpoint/i5 -- access

    terraform -chdir=access/envs/prod destroy -auto-approve
    docker rm -f wp-i5-floci
    ```

    The only file the diff should name is `access/README.md`, which is the prose the reference repo carries for what you just built. If it names anything under `baseline`, read the difference rather than pasting over it. A boundary you can defend line by line is worth more than a boundary that matches ours.

## Self-paced

The whole lesson is self-paced, and this is the one place in the course where the emulator being right matters more than usual.

Upstream Floci 2.0.1 accepts a permission boundary on `CreateRole` without error and then returns the field as `null` on every read. Terraform never sees the boundary it just set, plans the same in-place update forever, and no bounded estate can ever reach a clean plan. On that image step 10 would exit 2 rather than 0, every time, and this lesson would have to teach a permanent diff as expected. The image `ghcr.io/lex00/floci:iam-boundary` is a fork build that fixes it, `GetRole` returns the block, and the clean plan is a real one. [compose/README.md](https://github.com/INTENTIUS/waterpark/blob/main/compose/README.md) names the fork and the branch, and [upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md) has both runs side by side.

What this lesson proves and what it does not. It proves the boundary exists, that every role carries it, that the estate still converges with it, and that the account returns it on read. It does not prove that a caller is refused, because the `test` key pair resolves to root and acts unrestricted. The refusal is lesson 8, where the same patched image populates the `iam:PermissionsBoundary` condition key and a `CreateRole` without the boundary is denied for real.

Two things in the boundary point at resources the estate does not declare yet. The guardrail deny names `waterpark-apply` and `waterpark-terraform-state` by ARN, and neither is a resource in `envs/prod`, because the apply role and the state bucket live in accounts this course reaches in lesson 6 and lesson 7. A deny on a name that does not exist yet costs nothing and stops being a no-op the day it does.

Two things issue 43 asked for are deferred on purpose. The registry `waterpark-runner` and the default-deny security groups are not declared in `envs/prod`, because the Floci provider block overrides three endpoints, `iam` and `sts` and `s3`, and neither ECR nor EC2 is one of them. Declaring them would make the credential-free plan reach for a real account, which is the one thing the solo path may not do. `no-open-ingress` and `sg-reference-not-cidr` stay warnings for the same reason, with fixtures but nothing live to ratchet against. The typed network layer arrives with the account that can hold it.

Floci runs no Organizations, so the org policy set that sits above this boundary is live only.

## Live

Twenty minutes, and it is worth spending them in this order.

Start on step 3. Run `just access-check lint` with `baseline` in the roots and the exemption not yet written, and let the room read seven errors that say `s3:*` is not reviewable. Ask whether the rule is wrong. It is not wrong about what it sees. Then write the tag, re-run, and watch it go quiet. A guardrail that cannot be exempted deliberately gets exempted accidentally, and a tag with a fixture is the deliberate version.

Then step 9. Run the full check with the boundary declared and not applied, and show the plan stage failing on `envs/prod has an unapplied diff`. That is lesson 4's stage earning its place. Apply, and read "1 added, 3 changed" out loud. The three roles were already there and gained a ceiling in place.

Two honesty lines belong in this room. The first is the image. This is a patched fork build of Floci, not the release, and on the release the clean plan you are about to see does not exist, because upstream never returns the boundary on read. We found it, we fixed it, and it is written down in `project/upstream.md` with both runs. The second is the state file, again. The boundary you just applied is in the account and also in `terraform.tfstate`, and only one of those is the truth. Read it back with `get-role` in front of the room rather than trusting the apply output, because that is the habit lesson 7 depends on.

Live, the same code runs against a real sandbox account with `-var floci=false`, and the room can then try `aws iam delete-role-permissions-boundary` against a role and be refused by IAM rather than by a linter.

## Further reading

- [access/baseline](https://github.com/INTENTIUS/waterpark/blob/main/access/baseline/README.md), the boundary and the constants
- [access/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md), "The boundary" and "The rule pack"
- [Delegation](../../docs/design/delegation.md)
- [Threat model](../../docs/threat-model.md)
- [Guardrail rollout](../../docs/design/guardrail-rollout.md), the warn discipline a boundary change lands under
- [Decisions](../../docs/decisions.md), 9, 11, 12, 36, 37 and 40
- [Upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md), the two boundary bugs
- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A6 and A7
