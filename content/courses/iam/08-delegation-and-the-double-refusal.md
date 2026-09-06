---
title: "Delegation and the double refusal"
id: "I8"
lesson: 8
weight: 8
summary: "A satellite may create roles only inside the boundary, checked twice."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i8-delegation-and-the-double-refusal"
# card. empty renders as TODO
goal: "Stand up a satellite root that declares its own registry and the role that pushes to it, move `runner-builder` out of the central environment, consume the estate boundary as a live lookup by name rather than a copied ARN, mint the satellite a deploy credential that may create a role only inside that boundary, then strip the boundary and watch two things that have never heard of each other refuse it."
done_when: "`access/scripts/double-refusal` passes, with the build refused by `opa_deny_boundary_required` on a leaf file whose `permissions_boundary` line was deleted, the apply refused by IAM with `AccessDenied` on `iam:CreateRole` with the linter switched off, no unbounded role left in the account, and the satellite restored so that `just access-check` ends on `ok    satellites/waterpark-runner matches the account, exit 0` and `aws iam get-role --role-name runner-builder` returns the central `waterpark-estate-boundary` ARN."
restart_from: "checkpoint/i7"
properties: ["VI"]
closes: ["P8", "P10"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "50 min"
  needs:
    - "a water park checkout with the tags fetched"
    - "Docker running"
    - "the patched Floci image ghcr.io/lex00/floci:iam-boundary"
    - "terraform 1.9 or newer"
    - "tflint from terraform-linters/tap/tflint"
    - "jq"
    - "just access-init run once per clone"
    - "lesson 5 finished or at least read"
---

## Context

- A satellite is a team that declares its own resource and needs a role that acts on it. Under the layout as first written, that role took a second PR in the central repo, which is the ticket queue this whole pattern exists to remove wearing a git costume. The boundary from lesson 5 is what lets the role be created where the resource is.
- The mechanism was already in the repo. A boundary caps what an identity-based policy can grant, and IAM lets you condition role creation on it. A credential can be allowed `iam:CreateRole` only when `iam:PermissionsBoundary` equals a named ARN, and denied `iam:DeleteRolePermissionsBoundary` outright. Role creation decentralizes and authority does not (decision 20).
- Two enforcement layers, deliberately redundant, which is prescription 8. At build the rule pack fails `boundary-required` in the editor. At apply IAM refuses the call. The convenient layer gives fast feedback and the cloud layer gives the guarantee, and neither one knows the other exists.
- `waterpark-runner` is the satellite, a sibling root under `access/` in this repo rather than a second GitHub repository (decision 49). Everything else about it is what a real satellite is, its own provider, its own state, its own team in CODEOWNERS, its own deploy credential, and the shared module and the rule pack arriving under a pinned contract. Step 10 says what a separate repo would change.
- `runner-builder` moves here from `envs/prod`, because [the estate](../../docs/estate.md) scenario 5 says the satellite declares the registry and the role that pushes to it (decision 55). Lessons 1 through 7 are tagged checkpoints of the tree as it was, so nothing earlier moves.
- The shared module is `modules/persona` and not the `workload_role` wrapper decision 10 named. A wrapper forwarding a dozen variables declares them twice and enforces no rule the boundary and the rule pack do not already enforce (decision 53). The workload half of the persona set is the workload role module, and `deployer` is not delegable, so a satellite passes `service`.
- Central identifiers arrive by name, read live. `data.tf` looks the boundary up by its deterministic name, so the satellite gets the boundary that exists rather than one a file claims exists, and a satellite planning before central applied fails loudly instead of creating an unbounded role. `terraform_remote_state` is refused, since it would hand every satellite read access to central state, which is bookkeeping and never the system of record (decisions 32 and 50).
- Prescription 10 is the warn cycle, and here it is a tagging convention rather than a semver feature. A git ref carries no version constraint syntax, so warn-minor and error-major becomes which tag a rule turns from `warn_` to `deny_` on, written down in [.tflint.d](https://github.com/INTENTIUS/waterpark/blob/main/access/.tflint.d/README.md) (decisions 9, 50 and 57). Ratchet baselines are not built and the same file says why.
- `boundary-required` grew a second clause in lesson 6 that fires on a module call in an `iam_role.*.tf` file (decision 56). tflint reads the calling directory only, so without it a satellite leaf file with the boundary line deleted would pass lint and the first refusal would not be real.

## Do

Lesson 7 left an estate that watches itself. This lesson hands one role to somebody else and proves that handing it over gave nothing away.

1. Start from the checkpoint lesson 7 left, bring Floci up, and apply the central estate as it stands.

   ```sh
   git fetch origin --tags
   git worktree add ../waterpark-i8 checkpoint/i7
   cd ../waterpark-i8
   just access-init

   docker run -d --name wp-i8-floci -p 4566:4566 \
     -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
     ghcr.io/lex00/floci:iam-boundary

   curl -s --retry 15 --retry-all-errors --retry-delay 1 \
     -o /dev/null -w '%{http_code}\n' http://localhost:4566/

   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod apply -auto-approve
   ```

   The curl prints `200` and the apply lands twenty two resources. The retry
   flags are there because the container binds the port before it answers on
   it, and the apply behind them would fail rather than print `000`.

   Then look at the role this lesson is about to give away.

   ```sh
   export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1

   aws --endpoint-url http://localhost:4566 iam get-role \
     --role-name runner-builder \
     --query 'Role.[RoleName,PermissionsBoundary.PermissionsBoundaryArn]'

   grep runner_builder .github/CODEOWNERS
   ```

   The first prints the role and the central boundary ARN. The second prints
   `/access/envs/prod/iam_role.runner_builder.tf @INTENTIUS/platform`. Today
   the team that builds the runner image cannot change the role that pushes it
   without a platform review. By step 5 that line names a different team, and
   the boundary ARN in the first command has not moved.

2. Write the satellite root. Ten files under a new `access/satellites/waterpark-runner/` directory, and the file naming rule from lesson 1 still holds, so the registry goes in `ecr_repository.waterpark_runner.tf` and the role in `iam_role.runner_builder.tf`.

   `access/satellites/waterpark-runner/versions.tf`, the same pins every other root carries.

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

   `access/satellites/waterpark-runner/provider.tf`. This is `envs/prod`'s provider plus two things. `ecr` joins the endpoint overrides because this root declares a registry, and `credentials_from_env` is how the root is pointed at a credential that is not the account root.

   ```hcl
   # The same two targets as envs/prod, plus ecr, because this root declares a
   # registry. Floci implements ecr and the patched build applies an
   # aws_ecr_repository and reads it back with its tags, so the registry is
   # declared here rather than deferred (which is what decision 48 left open).
   provider "aws" {
     region = var.region

     # The throwaway pair on the solo path, so a fresh clone plans with no
     # credential of any kind. A satellite in the world deploys as its own
     # credential rather than as the account root, and credentials_from_env is
     # how this root is pointed at one. access/scripts/double-refusal uses it,
     # because a refusal is only a refusal if the caller is the satellite.
     access_key = var.floci && !var.credentials_from_env ? "test" : null
     secret_key = var.floci && !var.credentials_from_env ? "test" : null

     skip_credentials_validation = var.floci
     skip_requesting_account_id  = var.floci
     skip_metadata_api_check     = var.floci
     s3_use_path_style           = var.floci

     dynamic "endpoints" {
       for_each = var.floci ? [var.floci_endpoint] : []

       content {
         iam = endpoints.value
         sts = endpoints.value
         s3  = endpoints.value
         ecr = endpoints.value
       }
     }

     # A satellite marks what it creates, so central reconcile can see that a
     # resource is foreign and leave it to the repo that owns it.
     default_tags {
       tags = {
         managed_by = "terraform"
         repo       = "INTENTIUS/waterpark"
         env        = var.env
         satellite  = "waterpark-runner"
       }
     }
   }
   ```

   That last block is the one lesson 7 will notice. The `satellite` tag is how central reconcile tells a foreign resource from a drifted one and leaves it to the repo that owns it.

   `access/satellites/waterpark-runner/variables.tf`.

   ```hcl
   variable "floci" {
     description = "Point the AWS provider at a local Floci emulator instead of a real account. The solo path leaves this true. The live path passes -var floci=false."
     type        = bool
     default     = true
   }

   variable "floci_endpoint" {
     description = "Where Floci answers. Used only when floci is true."
     type        = string
     default     = "http://localhost:4566"
   }

   variable "region" {
     description = "The region the registry lives in."
     type        = string
     default     = "us-east-1"
   }

   variable "env" {
     description = "The environment this satellite deploys into."
     type        = string
     default     = "prod"
   }

   variable "credentials_from_env" {
     description = "Take the AWS credentials from the environment instead of the throwaway test pair. A satellite deploys as its own credential rather than as the account root, and access/scripts/double-refusal sets this so the IAM refusal is a refusal of the satellite. The solo path leaves it false."
     type        = bool
     default     = false
   }

   variable "boundary_name" {
     description = "The estate boundary, by name. The satellite reads it live rather than being handed an ARN, because the name is deterministic (decision 36) and an ARN in a satellite file is a copy that can go stale. If central has not applied the boundary yet, this root refuses to plan, which is the correct order."
     type        = string
     default     = "waterpark-estate-boundary"
   }
   ```

   `access/satellites/waterpark-runner/locals.tf`.

   ```hcl
   locals {
     # The satellite owns itself. Nobody in platform is in this file, and that is
     # the point of the lesson.
     owner = "runner"
   }
   ```

   `access/satellites/waterpark-runner/backend.local.tf`, the same solo-path state file every other root keeps, and the reason it is a file rather than a flag is lesson 4's.

   ```hcl
   # The solo path keeps state in this directory, so a fresh clone can run
   # terraform init with no AWS account and no credentials.
   #
   # The live path replaces this file with access/backends/backend.s3.tf, which
   # puts state in the waterpark-security account with locking. Swap it with
   # access/scripts/backend. See access/README.md, "State and the two backends".
   terraform {
     backend "local" {
       path = "terraform.tfstate"
     }
   }
   ```

   `access/satellites/waterpark-runner/data.tf`, which is half of the delegation contract and the most important sixteen lines in the directory.

   ```hcl
   # How a satellite consumes a central identifier (decision 50). By name, read
   # live, never through terraform_remote_state.
   #
   # The boundary name is deterministic (decision 36), so the satellite needs one
   # string rather than an ARN somebody copied. Reading it live means the
   # satellite gets the boundary that actually exists rather than the one a file
   # claims exists, and it means a satellite that plans before central has
   # applied the boundary fails loudly rather than creating an unbounded role.
   #
   # terraform_remote_state was the alternative and it is refused. It would hand
   # a satellite read access to the central state file, which is bookkeeping and
   # never the system of record (decision 32), and it would make every satellite
   # a reader of central's internals.
   data "aws_iam_policy" "boundary" {
     name = var.boundary_name
   }
   ```

   `access/satellites/waterpark-runner/ecr_repository.waterpark_runner.tf`, the resource the satellite exists to own.

   ```hcl
   # The registry the sandbox runner image is pushed to. A satellite declares its
   # own resources, which is the half of delegation nobody argues about.
   resource "aws_ecr_repository" "waterpark_runner" {
     name = "waterpark-runner"

     # An image tag that can be moved is an artifact that cannot be trusted, and
     # every deploy this registry feeds is a deploy of whatever the tag points at
     # today.
     image_tag_mutability = "IMMUTABLE"

     tags = {
       owner = local.owner
       role  = "the registry the sandbox runner image is pushed to"
     }
   }
   ```

   `access/satellites/waterpark-runner/iam_role.runner_builder.tf`, the whole leaf file. One module call and a list of grants, exactly the shape lesson 2 gave a central principal file, written by a team platform never reviews.

   ```hcl
   # The whole satellite leaf file. A persona, a boundary and a list of grants.
   #
   # Nobody from platform is involved in this file. The satellite creates the
   # role that pushes to the registry it declares, and the boundary is what makes
   # that safe (decision 20). The role can be given anything inside the estate
   # boundary and nothing outside it, whatever this file says, because effective
   # permissions are the intersection of the two.
   #
   # The module source. In this repo the satellite is a sibling root under
   # access/ (decision 49), so the source is the local path and every command in
   # the lesson works from a fresh clone with no network. A satellite in its own
   # repository consumes the same module as a git source pinned to a tag
   # (decision 50), which is
   #
   #   source = "git::https://github.com/INTENTIUS/waterpark.git//access/modules/persona?ref=checkpoint/i8"
   #
   # and access/scripts/satellite-source swaps between the two. The local path is
   # committed because a checkout has to be green on its own and the tag is cut
   # after these commits land.
   module "runner_builder" {
     source = "../../modules/persona"

     persona     = "service"
     name        = "runner-builder"
     description = "Builds the sandbox runner image and pushes it to the waterpark-runner registry."
     owner       = local.owner
     teams       = ["runner"]

     # The line the whole lesson turns on. Take it out and the rule pack refuses
     # the build, and the deploy credential is refused by IAM at apply, and
     # neither refusal knows about the other.
     permissions_boundary = data.aws_iam_policy.boundary.arn

     grants = [
       {
         resource = aws_ecr_repository.waterpark_runner.name
         access   = "push"
         reason   = "Publishes the runner image to the registry this root declares."
       },
       {
         resource = "waterpark-artifacts"
         access   = "write"
         reason   = "Publishes the build artifacts that go with the image."
       },
       {
         resource = "waterpark-artifacts"
         access   = "list"
         reason   = "Reads what it already published before pushing again."
       },
     ]
   }
   ```

   `access/satellites/waterpark-runner/outputs.tf`.

   ```hcl
   output "registry_url" {
     description = "Where the runner image is pushed."
     value       = aws_ecr_repository.waterpark_runner.repository_url
   }

   output "roles" {
     description = "The workload roles this satellite declares, by principal name."
     value = {
       (module.runner_builder.role_name) = module.runner_builder.role_arn
     }
   }

   output "grants" {
     description = "Every grant this satellite declares. The drift watch reads the expiry from here, the same way it does for envs/prod."
     value = {
       runner-builder = module.runner_builder.grants
     }
   }

   output "boundary_arn" {
     description = "The central boundary this satellite consumed, read live by name. A live read of the role should return exactly this."
     value       = data.aws_iam_policy.boundary.arn
   }
   ```

   `access/satellites/waterpark-runner/.tflint.hcl`, the other half of the contract. The satellite runs the central rule pack, and the comment is most of the file because the mechanism is not obvious.

   ```hcl
   # The satellite runs the central rule pack. This file is half of the
   # delegation contract, and the boundary ARN in data.tf is the other half.
   #
   # The pack itself is Rego, and tflint takes it from a directory named by
   # TFLINT_OPA_POLICY_DIR rather than from a source line, because the OPA
   # ruleset has no git source of its own. So there are two ways to point at it
   # and this repo uses the first.
   #
   #   In this repo, the satellite is a sibling root under access/ (decision 49),
   #   so the pack is already on disk and access/scripts/check exports
   #
   #     TFLINT_OPA_POLICY_DIR=access/.tflint.d/policies
   #
   #   In a satellite that is its own repository, the pack is vendored at the
   #   same pinned ref the shared module comes from (decision 50), and the ref is
   #   what makes an upgrade a deliberate act rather than a surprise.
   #
   #     git clone --depth 1 --branch checkpoint/i8 \
   #       https://github.com/INTENTIUS/waterpark.git .waterpark-guardrails
   #     export TFLINT_OPA_POLICY_DIR=.waterpark-guardrails/access/.tflint.d/policies
   #
   # Severity is the function-name prefix in the Rego, deny_ for an error and
   # warn_ for a warning, which is how a new rule reaches a satellite as a
   # warning first and becomes an error only at a later pinned ref (decision 9).
   # See access/.tflint.d/README.md.
   config {
     call_module_type = "none"
   }

   plugin "terraform" {
     enabled = false
   }

   plugin "opa" {
     enabled = true
     version = "0.8.0"
     source  = "github.com/terraform-linters/tflint-ruleset-opa"
   }
   ```

   That clone at a depth of one on a tag is prescription 10's delivery mechanism (decision 57). tflint has no git source for a Rego pack, so the pin is a ref a satellite moves to on purpose, and a rule that turns from `warn_` to `deny_` reaches it only when it does.

3. Take `runner-builder` out of the central environment, because two roots declaring the same role name is one root too many.

   ```sh
   rm access/envs/prod/iam_role.runner_builder.tf
   ```

   Then edit `access/envs/prod/outputs.tf`. Delete the `runner_builder` line from `roles` and the `runner-builder` line from `grants`, and put the reason at the top of the file where the next reader will find it.

   ```hcl
   # runner-builder is not here. It moved to access/satellites/waterpark-runner
   # in lesson 8, because the satellite declares the registry and the role that
   # pushes to it (estate.md scenario 5). Central keeps the boundary, the
   # personas and the guardrails, and it does not keep a satellite's workload.
   output "roles" {
   ```

   A deletion with no note is the kind of change that gets undone by somebody who assumes it was an accident.

4. Bring in the pieces this lesson does not write. The scripts and the module change are machinery rather than the lesson, so take them from the reference tree by name rather than typing them.

   ```sh
   git checkout checkpoint/i8 -- \
     access/scripts/satellite-source \
     access/scripts/mint-satellite-credential \
     access/scripts/double-refusal \
     access/scripts/check \
     access/scripts/gen-codeowners \
     access/modules/persona/locals.tf \
     access/modules/persona/iam_policy.grant.tf \
     access/modules/persona/variables.tf \
     access/.gitignore
   ```

   What each one is.

   `satellite-source` rewrites the module source line between the local path and `git::https://github.com/INTENTIUS/waterpark.git//access/modules/persona?ref=<tag>`. Terraform takes no variable in a module source, so swapping is a file rewrite, the same mechanism and for the same reason as `access/scripts/backend`.

   `mint-satellite-credential` and `double-refusal` are steps 8 and 9, and reading them before you run them is worth the four minutes.

   `check` gains six lines. Any directory under `satellites/` holding a `versions.tf` joins the lint and validate roots by existing, and joins the plan stage after `envs/prod`, because the satellite reads the boundary live and cannot plan before central has applied it. A satellite running weaker checks than central would make the delegation contract a suggestion.

   `gen-codeowners` stops printing a second error on a file that named a team the map does not carry, which is noise the next step would otherwise produce.

   The three `modules/persona` files are the `push` grant level. A satellite that declares its own registry needs a level that means it, because a satellite writing raw actions is a leaf file that is no longer near-data. `push` carries one action the service refuses to scope to a resource, `ecr:GetAuthorizationToken`, which mints the registry login and is account wide by the API's own design, so it renders as a second statement rather than as a wildcard smuggled into the first. Every level with nothing account wide renders exactly the one statement it always did, so no existing policy moved.

   `.gitignore` gains the working directory `double-refusal` builds and destroys, which holds a credential while it runs.

5. Route the satellite's review to the satellite. Add one line to the bottom of `access/codeowners.map`.

   ```
   # The satellite reviews its own files, which is the whole point of lesson 8.
   # Nobody from platform is on this line.
   runner: @INTENTIUS/waterpark-runner
   ```

   Then regenerate, and read the line that moved.

   ```sh
   access/scripts/gen-codeowners
   grep runner .github/CODEOWNERS
   ```

   It prints
   `/access/satellites/waterpark-runner/iam_role.runner_builder.tf @INTENTIUS/waterpark-runner`,
   where step 1 printed the same file under `envs/prod` owned by platform. Nobody
   edited CODEOWNERS to make that happen. The leaf file said `teams = ["runner"]`
   and the generator did the rest, which is decision 21 doing its job across a
   trust boundary rather than inside one.

6. Apply central first, then the satellite, in that order and for a reason.

   ```sh
   terraform -chdir=access/envs/prod apply -auto-approve
   ```

   `Apply complete! Resources: 0 added, 0 changed, 5 destroyed.` The role, its
   two grant policies and their two attachments leave the central account. For a
   moment the estate has no `runner-builder` at all, which is what a move looks
   like when the name is the identity.

   ```sh
   terraform -chdir=access/satellites/waterpark-runner init
   terraform -chdir=access/satellites/waterpark-runner apply -auto-approve
   terraform -chdir=access/satellites/waterpark-runner plan -detailed-exitcode
   echo $?
   ```

   Eight resources added, then "No changes." and `0`. That clean replan is the
   registry earning its place, because an `aws_ecr_repository` on the patched
   image applies and reads its tags back, which is what decision 48 deferred and
   this lesson lifts.

   Now read the role out of the account rather than out of state.

   ```sh
   aws --endpoint-url http://localhost:4566 iam get-role \
     --role-name runner-builder --query 'Role.PermissionsBoundary'
   ```

   It returns `arn:aws:iam::000000000000:policy/waterpark-estate-boundary`. No
   file in `satellites/waterpark-runner/` holds that ARN. `data.tf` asked the
   account for a policy by name and the module put what came back on the role,
   so the boundary the satellite is under is the boundary that exists rather
   than the boundary a satellite file claims exists.

   If this step fails with a data source error, central has not applied the
   boundary and that is the correct failure. A satellite that could plan without
   it would be a satellite that could create an unbounded role.

7. Run the whole check stack and watch the satellite appear in it.

   ```sh
   just access-check
   ```

   `access/satellites/waterpark-runner` shows up under validate, under tflint
   and under the plan, and `check passed` at the end. Nothing was added to a
   list of roots by hand. The satellite joined by holding a `versions.tf`, which
   is the property that makes a second satellite free.

8. Mint the credential the satellite deploys with, and read what it is allowed to do before using it.

   ```sh
   access/scripts/mint-satellite-credential
   ```

   It prints an access key and the three things that matter. `iam:CreateRole`
   and `iam:PutRolePermissionsBoundary` are allowed only under
   `StringEquals iam:PermissionsBoundary` equal to the central boundary ARN,
   `iam:DeleteRolePermissionsBoundary` is denied outright, and the rest is the
   ordinary role, policy and registry calls an apply needs. That condition is
   the cloud half of the delegation contract, and it is four lines of JSON.

   Two things about this credential are worth saying out loud.

   It is an IAM user, and decision 5 bans IAM users from the estate while the
   rule pack fails one written in HCL. A satellite in the world federates
   through its own issuer and assumes a deploy role, and there is no OIDC
   subject on a laptop to bind to. Floci honors trust policies, so a role
   trusting an issuer is a role nothing here can become. This user stands in for
   that role, it is minted and deleted by a script, and it is never declared, so
   the rule and the decision both still hold. Lesson 9 is where the issuer side
   of this gets built for real.

   It does not carry the estate boundary itself, and that is deliberate rather
   than an oversight. The estate boundary denies all IAM write, so a credential
   inside it could not create the role the satellite exists to create. Its cap
   is the condition instead, which is narrower and aimed at exactly one thing,
   the shape of the roles it may make.

9. Strip the boundary and get refused twice.

   ```sh
   access/scripts/double-refusal
   ```

   The script works on a copy of the satellite root with the role and the
   registry renamed with a `-proof` suffix, so it can create and destroy its own
   resources without touching the satellite you just applied. Renaming is the
   only difference from the real files. Then it does four things.

   The control first. It applies the copy as the deploy credential with the
   boundary in place, and the role is created and reads back carrying the
   central ARN. Without this the refusals below would prove only that a
   credential was broken.

   ```
   == the control, so the refusals below are about the boundary and not the key
   ok    the satellite created runner-builder-proof, and it carries arn:aws:iam::000000000000:policy/waterpark-estate-boundary
   ok    torn down again, so the refusals below are a create rather than an update
   ```

   Refusal one, at build. It deletes the `permissions_boundary` line and runs
   tflint with the central pack.

   ```
   == refusal one, at build
         the boundary line is gone, 1 before and 0 after
   ok    the rule pack refuses the build
         Error - module "runner_builder" declares a role and names no permissions_boundary. Add permissions_boundary = module.baseline.boundary_arn, or the central boundary ARN a satellite consumes, so the role cannot be made more powerful than the estate allows. (opa_deny_boundary_required)
   ```

   That message comes from the clause lesson 6 added, the one that fires on a
   module call in an `iam_role.*.tf` file. tflint reads the calling directory
   only, so the `aws_iam_role` inside the module is invisible from here and the
   file name is what says this call produces one. Without that clause a leaf
   file could drop the line and nothing would fire until IAM refused the call.

   Refusal two, at apply, with the linter switched off. This is the satellite
   defeating its own guardrails, which is the case the second layer exists for.

   ```
   == refusal two, at apply, with the linter switched off
   ok    IAM refuses the call
         AccessDenied: User is not authorized to perform: iam:CreateRole
         not authorized to perform: iam:CreateRole
   ok    no unbounded role was created
   ```

   Then it restores, reapplies the real satellite, deletes the credential and
   confirms `runner-builder` carries the boundary again.

   ```
   double-refusal passed. Refused at build by the checks and at apply by IAM,
   independently, with nobody from platform involved either time.
   ```

   Read the two refusals against each other. The first is a linter reading HCL
   in a directory, and it can be defeated by anyone willing to edit a Rego file
   or pass `--disable-rule`. The second is IAM reading a condition on a policy
   attached to a credential the satellite does not control, and nothing in the
   satellite repository can reach it. The first is the one contributors feel and
   the second is the one that is true.

10. Look at the pinned form, and at what a separate repository would change.

    ```sh
    access/scripts/satellite-source show
    ```

    It prints `../../modules/persona` and says nothing is fetched. The pinned
    form is one command away.

    ```sh
    access/scripts/satellite-source git checkpoint/i8
    access/scripts/satellite-source local
    ```

    The `git` form rewrites the source to
    `git::https://github.com/INTENTIUS/waterpark.git//access/modules/persona?ref=checkpoint/i8`
    and prints the matching clone for the rule pack. The local path is what
    ships, because a checkout has to be green on its own and the tag is cut
    after the commit that introduces it lands. Leave it on `local` before going
    on, since the pinned form needs network and a tag that exists.

    Four things would change if `waterpark-runner` were its own GitHub
    repository, and none of them is the boundary.

    Its own PR job, running the vendored pack rather than the one on disk. Its
    own CODEOWNERS, generated from its own leaf files rather than from this
    repo's `codeowners.map`. Its deploy credential minted centrally and handed
    over as a federated role rather than by a script on a laptop. And both pins
    moving together in one PR, the module source and the vendored rule pack, so
    a bump is planned like any other change and shows exactly which new warnings
    appear before anything is merged.

    What does not change is the mechanism. The boundary is read live by name,
    the credential is conditioned on it, and the two refusals stand. That is why
    this repo can teach the lesson without a second repo (decision 49).

11. Compare with the reference repo, then tear down. The satellite is new, and untracked files do not appear in a diff, so stage first.

    ```sh
    git add -A access .github
    git diff --cached --stat checkpoint/i8 -- access .github ':!*README.md'

    terraform -chdir=access/satellites/waterpark-runner destroy -auto-approve
    terraform -chdir=access/envs/prod destroy -auto-approve
    docker rm -f wp-i8-floci
    ```

    Nothing printed means every file you wrote is the reference file. Four
    `README.md` files are excluded and they are the only exclusions, `access/`,
    `access/.tflint.d/`, `access/modules/persona/` and the satellite's own. Each
    is prose the reference tree carries about this lesson and none of them is
    something a step above asked you to write. If the diff names anything else,
    read the difference rather than pasting over it.

## Self-paced

The whole lesson is self-paced, and it is the second place in the course where the emulator being right decides whether the lesson exists at all.

The first run of this proof, recorded in issue 46, failed. Upstream Floci 2.0.1 never populates the `iam:PermissionsBoundary` condition key, so a policy conditioned on it denies `CreateRole` with the boundary and without it. Every call is refused, which looks like a pass and proves nothing. The image `ghcr.io/lex00/floci:iam-boundary` is a fork build that fixes both boundary bugs, so the control in step 9 can succeed and the refusal in step 9 can be a refusal of the thing that changed. [compose/README.md](https://github.com/INTENTIUS/waterpark/blob/main/compose/README.md) names the fork and the branch and [upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md) has both runs side by side.

What this lesson proves and what it does not. It proves that a credential conditioned on `iam:PermissionsBoundary` creates a bounded role and is refused a bounded role's unbounded twin, that the rule pack catches the same thing earlier, and that neither refusal depends on the other. It does not prove federation, because the deploy credential is an IAM user standing in for a role a laptop has no subject to assume. That is lesson 9. It does not prove cross-repository review either, because CODEOWNERS here is one file for one repo.

The registry is real ECR on the patched image rather than a bucket standing in for one. The repository applies, its tags read back, and the immediate replan exits 0, which is what let decision 48's deferral be lifted here.

The ratchet baseline half of prescription 10 is not built, and [.tflint.d](https://github.com/INTENTIUS/waterpark/blob/main/access/.tflint.d/README.md) says so rather than leaving you to find out. tflint has no first-class baseline file, so recording pre-existing violations in a shrink-only checked-in file means wrapping `tflint --format=json`, which [guardrail rollout](../../docs/design/guardrail-rollout.md) already names as a spike. This estate has nothing to ratchet against, because every rule here was green before it was promoted. A satellite with a real backlog needs the wrapper.

## Live

Thirty minutes, and the room only needs two of the eleven steps.

Start on step 5, with the CODEOWNERS line from step 1 still on the screen. Same file, same role, two different teams approving it, and nobody edited a dotfile to move it. That is the cheapest possible demonstration of what delegation actually costs, which is one line in a map file.

Then spend the rest on step 9. Run `double-refusal` once, whole, and let it print. Then ask the room which of the two refusals they would keep if they could only have one. The answer people reach for is the linter, because it is the one they would feel, and the answer is the other one. Then ask what a compromised satellite runner defeats. It defeats the linter completely and the condition not at all.

Two honesty lines belong here. The first is the image, again, and it is sharper in this lesson than in lesson 5. On the release build this proof passes for the wrong reason, because every `CreateRole` is denied whether or not the boundary is there, and a green run would be a lie. We found it, we fixed it, and both runs are in `project/upstream.md`. The second is the credential. This is an IAM user with a long-lived access key, in a course whose fifth decision bans IAM users. It stands in for a federated deploy role because there is no issuer on a laptop, it lives for the length of one script, and lesson 9 builds the thing it is standing in for.

Live, the same code runs against a real sandbox account with `-var floci=false`, and the room can watch the same `AccessDenied` come back from real IAM.

## Further reading

- [access/satellites/waterpark-runner](https://github.com/INTENTIUS/waterpark/blob/main/access/satellites/waterpark-runner/README.md), the satellite and its contract
- [access/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md), "Lesson 8, delegation and the double refusal"
- [access/.tflint.d](https://github.com/INTENTIUS/waterpark/blob/main/access/.tflint.d/README.md), the tagging convention and what ratchet baselines would cost
- [Delegation](../../docs/design/delegation.md)
- [Guardrail rollout](../../docs/design/guardrail-rollout.md)
- [The estate](../../docs/estate.md), scenario 5
- [Prescriptions](../../docs/prescriptions.md), 8 and 10
- [Decisions](../../docs/decisions.md), 9, 10, 20, 36, 42, 46, 49, 50, 53, 55, 56 and 57
- [Upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md), the condition key that was never populated
