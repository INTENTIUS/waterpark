---
title: "One path to prod"
id: "I6"
lesson: 6
weight: 6
summary: "The PR is the only path to the estate."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i6-one-path-to-prod"
# card. empty renders as TODO
goal: "Declare the role the pipeline federates into and prove against IAM that it cannot take its own boundary off, generate CODEOWNERS out of the principal files so review routing is derived rather than authored, write the workflow whose PR job holds no credential and whose apply job runs on push to main alone, and turn the fork-PR property into a check that fails the moment a secret or an id-token request reaches a job a pull request can trigger."
done_when: "`just access-check` passes with `ok    .github/CODEOWNERS matches the principal files` and `ok    no job reachable from pull_request names a secret or asks to federate`, `access/scripts/check codeowners` fails on a hand edit to `.github/CODEOWNERS` and passes again after `access/scripts/gen-codeowners`, changing the apply role's `teams` reroutes its line in the generated file with nobody editing that file, `access/scripts/check workflow` fails with `job pr runs on pull_request and names a secret` and then with `job pr runs on pull_request and asks for id-token: write` when each is injected, and `access/scripts/prove-no-detach` exits 0 with `iam:DeleteRolePermissionsBoundary` and `iam:PutRolePermissionsBoundary` denied on `waterpark-apply`."
restart_from: "checkpoint/i5"
properties: ["IV", "IX", "XIV", "II"]
closes: ["P5", "P6", "P7"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "75 min"
  needs:
    - "a water park checkout with the tags fetched"
    - "Docker running"
    - "the patched Floci image ghcr.io/lex00/floci:iam-boundary"
    - "terraform 1.9 or newer"
    - "tflint from terraform-linters/tap/tflint"
    - "jq"
    - "gh, logged in, to read one finished run"
    - "just access-init run once per clone"
    - "lesson 5 finished or at least read"
---

## Context

- Two jobs and one file. `pr` runs on `pull_request`, names no secret, asks for no `id-token`, caps itself at `contents: read`, and gets its AWS from a Floci service container inside its own job. `apply` runs on push to main only, carries `if: github.event_name == 'push'` so a pull request cannot reach it at all, and is gated by the `prod` environment. Nothing else in the repository writes to the estate.
- The whole path needs no AWS account, because both jobs talk to Floci in the runner (decision 51). What that proves is the digest check and the shape of the pipeline rather than a cloud apply, and the page says which.
- A plan is a diff against an account, so a job planning against the wrong account is reviewing the wrong thing. A CI Floci starts empty, and a plan against empty is the whole estate rather than the change. So each job builds the account it is meant to review against first. The `pr` job checks the pull request's base sha out into a worktree, applies it, carries the resulting `terraform.tfstate` into the tree under review, and only then plans the head. The `apply` job rebuilds from the merged pull request's own base sha and plans the merge commit, so the two plans have identical inputs.
- That is also why `check` grew `--plan-mode`. On a laptop a non-empty plan is something nobody applied and the stage fails. In CI the account was filled from the base minutes earlier, so a non-empty plan is exactly the change proposed and the stage records it and stays green (decision 52). The workflow passes `access/scripts/check --plan-mode ci`.
- The digest travels with the plan that produced it, as an artifact named `access-plan-<head sha>`. A digest committed by the pull request was rejected, because a digest is taken against a particular account and a student whose Floci already holds the estate computes a different one from an empty CI container. The apply job resolves the merged pull request, finds the successful `pr` run on that head sha, downloads by that key and refuses on a mismatch or on no artifact at all.
- CODEOWNERS is generated, never authored (decision 21). `gen-codeowners` reads the `teams` list out of every principal file, maps each name to a GitHub handle through `access/codeowners.map`, and routes the guardrail paths to platform by rule, last in the file so they win. Team names in a leaf file are estate names because a team outlives a code host, and the map is the one place the two vocabularies meet.
- The fork-PR property is a grep rather than a promise. `check workflow` treats every job not gated to `push` as reachable from a pull request and fails one that names `secrets.` or asks for `id-token: write`, which are the two ways a cloud credential gets into a job an untrusted author triggers.
- `waterpark-apply` carries the estate boundary, and the estate boundary denies all IAM write and the guardrail path by name, which includes `role/waterpark-apply`. Against a real account this role could not apply the estate it exists to apply (decision 58). The taught path never hits it, because the job uses the Floci `test` credentials and never assumes the role, and the file says so rather than shipping a role that quietly cannot work.
- Access Analyzer answers `UnknownOperationException` on Floci, so `proofs` prints one named skip line and claims nothing. The proofs in this lesson are live only, and the script says that out loud in place of a verdict.
- Branch protection lives in `access/github` and is validated and linted on every check and never applied on the solo path, the same way `identity/` is, because there is no emulator for a code host.

## Do

Lesson 5 left a bounded estate that a person applies from a laptop. This lesson makes the pull request the only way in.

1. Start from the checkpoint lesson 5 left, bring Floci up, and apply the bounded estate so the plan stage has an account to compare against.

   ```sh
   git fetch origin --tags
   git worktree add ../waterpark-i6 checkpoint/i5
   cd ../waterpark-i6
   just access-init

   docker run -d --name wp-i6-floci -p 4566:4566 \
     -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
     ghcr.io/lex00/floci:iam-boundary

   curl -s --retry 15 --retry-all-errors --retry-delay 1 \
     -o /dev/null -w '%{http_code}\n' http://localhost:4566/

   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod apply -auto-approve
   just access-check
   ```

   The curl prints `200`, the apply lands twenty resources and `just access-check`
   ends on `check passed`. The retry flags are there because the container binds
   the port before it answers on it, and the apply behind them would fail rather
   than print `000`.

2. Copy the parts of this checkpoint that are not this lesson. Lesson 6's tree is large and most of it is machinery rather than teaching, so take it from the reference repo in one step and read it rather than typing it.

   ```sh
   git checkout checkpoint/i6 -- \
     access/modules/persona \
     access/github \
     access/scripts/gen-codeowners \
     access/scripts/plan-digest \
     access/scripts/render-delta \
     access/scripts/proofs \
     access/scripts/prove-no-detach \
     access/.tflint.d/policies \
     access/tests/fixtures/boundary-required \
     access/tests/fixtures/path-matches-name \
     access/envs/prod/outputs.tf \
     scripts/check_md_links.py
   ```

   What each of those is, and why it is not the lesson.

   - `access/modules/persona` gains `federated_trust`, which is the second trust shape a workload role can carry. A role inside AWS is trusted by service principal and a job outside AWS is trusted by a declared OIDC provider with the audience and the exact subjects pinned. The module refuses a `*` in a subject and refuses a trust with no subject at all. Federation trust in general is lesson 9, and this lesson only consumes it.
   - `access/github` is branch protection on `main` as code, with the `pr` job as the required check, one required review, code-owner review required and no exemption for administrators. It is live only, so nothing here applies it.
   - The five scripts are the pipeline's tools. `gen-codeowners` emits the routing, `plan-digest` is the digest an approval binds to, `render-delta` turns plan JSON into the semantic access delta, `proofs` asks Access Analyzer and `prove-no-detach` is prescription 7's check. You run four of them below.
   - `access/.tflint.d/policies` carries two rule changes with their fixtures. `path-matches-name` now drops any known provider prefix, so `github_branch_protection.main` lives in `branch_protection.main.tf`. `boundary-required` now also fires on a principal file that makes a role and names no boundary, which tflint could not see before because it reads the calling directory only. That second one is the build half of the double refusal and lesson 8 needs it.
   - `access/envs/prod/outputs.tf` gains the apply role ARN, the boundary ARN and the two baseline constants, so `prove-no-detach` and `reconcile` read them rather than restating them.
   - `scripts/check_md_links.py` learns to skip `.terraform`, because `access/github` pulls the `integrations/github` provider whose shipped README carries relative links into its own repository, and that README is not this repo's to fix.

3. Write the trust anchor and the apply role. Two files under `access/envs/prod/`, plus one variable.

   `access/envs/prod/iam_openid_connect_provider.actions.tf`. An OIDC provider is account scoped, so the anchor the `waterpark-prod` apply role trusts belongs in `waterpark-prod` beside the role rather than in `access/identity`, which targets the management account (decision 54).

   ```hcl
   # The trust anchor the apply job federates through. GitHub Actions mints a
   # token per job, the provider below is what makes that token mean something
   # in this account, and no static AWS key exists anywhere in the pipeline.
   #
   # water park declares trust anchors and never operates an issuer (decision
   # 13). An OIDC provider is an account-scoped resource, so the anchor the
   # waterpark-prod apply role trusts is declared in waterpark-prod beside the
   # role rather than in access/identity, which targets waterpark-mgmt.
   resource "aws_iam_openid_connect_provider" "actions" {
     url = "https://${var.actions_oidc_host}"

     # The audience the workflow asks for, and the only one this account honors.
     client_id_list = ["sts.amazonaws.com"]

     # The issuer's root CA thumbprint. AWS ignores it for the well-known
     # issuers now, and it is still required by the API, so it is named here
     # rather than computed at apply time.
     thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

     tags = {
       owner = local.owner
       role  = "the trust anchor the apply job federates through"
     }
   }
   ```

   The issuer host is one string, in `access/envs/prod/variables.tf`, between `floci_endpoint` and `region`.

   ```hcl
   variable "actions_oidc_host" {
     description = "The GitHub Actions OIDC issuer host. It is the provider's URL and the prefix of the aud and sub condition keys, so it is one string here rather than three spellings across the estate."
     type        = string
     default     = "token.actions.githubusercontent.com"
   }
   ```

   `access/envs/prod/iam_role.waterpark_apply.tf`. This is the whole declaration of what runs at the end of the path, and the comment carries the cost as well as the design.

   ```hcl
   # The apply role. One path to prod ends here, and this file is the only
   # declaration of what runs at the end of it.
   #
   # It is trusted by the GitHub Actions issuer alone, for one repository, on
   # one branch, with the audience pinned. There is no service principal, no
   # static key and no second subject, so the only thing on earth that can
   # become this role is a job on main in INTENTIUS/waterpark.
   #
   # It carries the estate boundary, because water park must not be able to
   # escalate water park (decision 12). The boundary denies boundary detachment
   # outright and denies the guardrail path by name, and this role is on that
   # path, so it cannot rewrite the fence it stands behind.
   # access/scripts/prove-no-detach is the proof, and it is prescription 7's
   # check.
   #
   # The cost, named out loud. The estate boundary also denies all IAM write
   # (decision 36), so against a real account this role could not apply the
   # estate it is meant to apply. On the taught path that never bites, because
   # the apply job runs against a Floci service container with the throwaway
   # test credentials (decision 51) and never assumes this role. A real account
   # needs an apply-specific boundary, one that permits IAM write inside the
   # estate while keeping the detachment and guardrail-path denies, and that is
   # a second boundary decision 36 has not taken yet. The lesson says so rather
   # than shipping a role that quietly cannot work.
   module "waterpark_apply" {
     source = "../../modules/persona"

     persona     = "deployer"
     name        = "waterpark-apply"
     description = "The role the apply job federates into. One repository, one branch, its own boundary, and no policy until the boundary question in decision 36 is settled."
     owner       = local.owner
     teams       = ["platform"]

     permissions_boundary = module.baseline.boundary_arn

     federated_trust = {
       provider_arn = aws_iam_openid_connect_provider.actions.arn
       issuer_host  = var.actions_oidc_host
       audience     = "sts.amazonaws.com"

       # The exact subject, not a pattern. This is the whole trust boundary of
       # the write path, so a wildcard here would hand the estate to any branch
       # of any repository the issuer serves. The module refuses one.
       subjects = ["repo:INTENTIUS/waterpark:ref:refs/heads/main"]
     }

     # No grants. See the cost above.
     grants = []
   }
   ```

   Then

   ```sh
   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod validate
   ```

   `Success! The configuration is valid.` The `init` is there because step 2 changed the persona module and Terraform has to reinstall it.

4. Read what a reviewer is actually being asked to approve, before applying anything. Right now the repo declares two resources the account does not have, which is exactly the shape of a pull request.

   ```sh
   terraform -chdir=access/envs/prod plan -out=tfplan
   terraform -chdir=access/envs/prod show -json tfplan > plan.json

   access/scripts/render-delta plan.json
   access/scripts/plan-digest plan.json
   access/scripts/proofs plan.json
   ```

   The delta reads

   ```text
   Access delta

     No grant changes. Nothing gains or loses access.

     Principals
       + waterpark-apply

     Other resources
       + aws_iam_openid_connect_provider.actions
   ```

   That is the translation prescription 14 asks for. A Terraform plan says an `aws_iam_role` will be created, which is a fact about Terraform. The access fact is that a new principal appears and no grant moves, and a reviewer can hold that in their head.

   `plan-digest` prints `sha256:` and sixty-four hex characters. Run the plan and the digest again and the same string comes back, because the digest is taken over a normalised reading of the plan with the timestamp and the prior state dropped rather than over the file's bytes. That stability is the whole mechanism the apply job leans on.

   `proofs` prints a skip.

   ```text
   skip  Access Analyzer did not answer, so no proof ran and none is claimed.
         Floci lists accessanalyzer and implements none of the policy APIs.
         Verified on ghcr.io/lex00/floci:iam-boundary, 2026-09-05.
         Run this against a real account for the verdict:
           access/scripts/proofs --live tfplan.json
   ```

   Read that line rather than skipping past it. A proof step that quietly returned green on an emulator that answers nothing would be worse than no proof step at all.

5. Apply, read the trust policy back out of the cloud, and prove the boundary holds.

   ```sh
   terraform -chdir=access/envs/prod apply -auto-approve

   export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
   aws --endpoint-url http://localhost:4566 iam get-role \
     --role-name waterpark-apply \
     --query 'Role.AssumeRolePolicyDocument.Statement[0]'
   ```

   `Apply complete! Resources: 2 added, 0 changed, 0 destroyed.` and then the trust document as IAM holds it.

   ```json
   {
       "Action": "sts:AssumeRoleWithWebIdentity",
       "Condition": {
           "StringEquals": {
               "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
               "token.actions.githubusercontent.com:sub": [
                   "repo:INTENTIUS/waterpark:ref:refs/heads/main"
               ]
           }
       },
       "Effect": "Allow",
       "Principal": {
           "Federated": "arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com"
       }
   }
   ```

   One repository, one branch, one audience, and a `sub` that is a string rather than a pattern. Now the proof.

   ```sh
   access/scripts/prove-no-detach
   echo $?
   ```

   Twelve `ok` lines and `prove-no-detach passed. The apply role cannot detach its own boundary.`, exit 0. Read the sequence rather than the verdict. It reads the boundary off the applied role, shows that the `test` key pair cannot assume `waterpark-apply` at all because the trust names the issuer and not a key, mints a stand-in user carrying the same boundary with an allow-everything policy, checks that the stand-in works and can reach S3, and only then asks it to detach a boundary and gets `AccessDenied`. The controls before the refusal are what make the refusal mean something. Without them a deny would prove only that somebody minted a broken credential.

   The stand-in exists because Floci honours trust policies and there is no web identity token on a laptop, so nothing here can become the apply role. An identity allowed everything and capped by the estate boundary is the apply role's shape, and it is the shape the deny has to hold against. The script deletes the user when it exits. Decision 5 bans IAM users from the estate and the rule pack fails one in HCL, and a credential minted for a proof and destroyed at the end of it is not an estate identity.

6. Generate the review routing. First the map, `access/codeowners.map`.

   ```text
   # team name in a principal file : the GitHub handle that reviews for it.
   #
   # A leaf file's teams are estate names, because the estate is not a GitHub
   # concept and a team can outlive the code host. This file is the one place
   # the two vocabularies meet, so moving to another host is an edit here rather
   # than a sweep through every principal file.
   #
   # A team named in a principal file and missing here is a hard failure in
   # access/scripts/gen-codeowners, because silently routing a team's access to
   # nobody is worse than not generating the file at all.

   platform: @INTENTIUS/platform
   course: @INTENTIUS/course-authors
   ```

   Then

   ```sh
   access/scripts/gen-codeowners
   cat .github/CODEOWNERS
   ```

   `wrote .github/CODEOWNERS`, and the file carries a line for every principal file including `iam_role.waterpark_apply.tf`, which you wrote two steps ago and never mentioned to CODEOWNERS.

   Now watch the routing follow the estate. Change `teams` in `access/envs/prod/iam_role.waterpark_apply.tf` from `["platform"]` to `["course"]` and

   ```sh
   access/scripts/gen-codeowners --stdout | grep waterpark_apply
   ```

   ```text
   /access/envs/prod/iam_role.waterpark_apply.tf @INTENTIUS/course-authors
   ```

   That is the first half of prescription 5, standing rather than asserted. Nobody edited a dotfile and the review moved. Put `["platform"]` back before going on.

   The second half is the hand edit. Append a line to `.github/CODEOWNERS` by hand and run the stage that will run in CI.

   ```sh
   printf '/access/envs/prod/iam_role.waterpark_apply.tf @someone-else\n' >> .github/CODEOWNERS
   access/scripts/gen-codeowners --check
   echo $?
   ```

   ```text
   gen-codeowners: .github/CODEOWNERS does not match the principal files.
   --- .github/CODEOWNERS
   +++ -
   @@ -29,4 +29,3 @@
    /access/github/** @INTENTIUS/platform
    /.github/workflows/access.yml @INTENTIUS/platform
    /.github/CODEOWNERS @INTENTIUS/platform
   -/access/envs/prod/iam_role.waterpark_apply.tf @someone-else
   Run: access/scripts/gen-codeowners
   ```

   and `1`. The quietest way to change who approves access is a one-line edit to a dotfile nobody reads, and this is what makes that edit loud. That same call becomes a stage of the check stack in step 8. Regenerate and go on.

   ```sh
   access/scripts/gen-codeowners
   ```

7. Write the workflow's shape. This is the part of `.github/workflows/access.yml` that carries the whole argument, and it is short, because the argument is about what the two jobs are allowed to be rather than about what they do.

   ```yaml
   name: access

   on:
     pull_request:
       paths:
         - "access/**"
         - ".github/workflows/access.yml"
         - ".github/CODEOWNERS"
     push:
       branches: [main]
       paths:
         - "access/**"
         - ".github/workflows/access.yml"
         - ".github/CODEOWNERS"
     workflow_dispatch:

   permissions:
     contents: read

   concurrency:
     group: access-${{ github.ref }}
     cancel-in-progress: false

   env:
     TERRAFORM_VERSION: 1.15.8
     TFLINT_VERSION: v0.64.0
     FLOCI_ENDPOINT: http://localhost:4566

   jobs:
     pr:
       if: github.event_name != 'push'
       runs-on: ubuntu-latest

       permissions:
         contents: read

       services:
         floci:
           image: ghcr.io/lex00/floci:iam-boundary
           ports:
             - 4566:4566
           env:
             FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED: "true"

       steps:
         - uses: actions/checkout@v4
           with:
             fetch-depth: 0

         - name: The check stack
           run: access/scripts/check --plan-mode ci

     apply:
       if: github.event_name == 'push'
       runs-on: ubuntu-latest

       environment: prod

       permissions:
         contents: read
         actions: read

       services:
         floci:
           image: ghcr.io/lex00/floci:iam-boundary
           ports:
             - 4566:4566
           env:
             FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED: "true"

       steps:
         - uses: actions/checkout@v4
           with:
             fetch-depth: 0

         - name: Apply
           run: terraform -chdir=access/envs/prod apply -input=false -no-color tfplan
   ```

   Four things in there are the lesson. The `pr` job names no secret and asks for no `id-token`, so there is no credential a fork PR can reach. Its AWS is a service container in its own job, so it needs no account to plan against. The `apply` job carries `if: github.event_name == 'push'`, so it does not run on a pull request at all rather than running and refusing. And `environment: prod` is the gate a maintainer attaches required reviewers to.

   The `pr` job's own `permissions` block is worth a second. `GITHUB_TOKEN` is not a secret in the sense above, and the job uses it as `github.token`. On a fork PR GitHub issues it read-only whatever the workflow asks, and this block caps it at `contents: read` besides.

8. Write the fork-PR check. It lives in `access/scripts/check`, alongside the stages from lessons 3 and 4, and two smaller stages come with it because they are in the same file. The script is tab indented, so keep the tabs.

   First the header, which now lists five stages and one option. Replace the usage block at the top.

   ```sh
   # Everything a PR job would run over access/, in the order it runs it.
   #
   #   access/scripts/check              the whole stack, in the order CI runs it
   #   access/scripts/check lint         just tflint over the real roots
   #   access/scripts/check fixtures     just the rule fixtures
   #   access/scripts/check codeowners   just the generated CODEOWNERS comparison
   #   access/scripts/check workflow     just the fork-PR property over the workflow
   #   access/scripts/check plan         just the credential-free plan against Floci
   #
   # One option, and it changes what a non-empty plan means.
   #
   #   access/scripts/check --plan-mode ci
   #
   # The same command runs in the editor, from an agent and in CI, and produces
   # the same diagnostic. That is prescription 4.
   ```

   Then put `access/github` under the checks. Rewrite the comment above `roots` and add one entry after `identity`.

   ```sh
   # The Terraform roots and modules the checks cover. envs/dev is a README
   # until a lesson needs it. identity and github are live only and are checked
   # here on every run, because a rule that is not checked is a rule that has
   # already drifted.
   roots=(
   	envs/prod
   	identity
   	github
   	baseline
   	modules/persona
   )
   ```

   Then two new stages, straight after `run_fixtures` and before the `floci_endpoint` line.

   ```sh
   # CODEOWNERS is generated, not authored (decision 21). This stage is what
   # makes that true rather than aspirational, because a hand edit to the routing
   # is otherwise the quietest possible way to change who approves access.
   run_codeowners() {
   	say "== generated CODEOWNERS"
   	if "$access_root/scripts/gen-codeowners" --check; then
   		ok ".github/CODEOWNERS matches the principal files"
   	else
   		fail ".github/CODEOWNERS was hand edited or a principal file moved"
   	fi
   }

   # Prescription 6's test, as a grep rather than as a promise. A fork PR must
   # not be able to reach a credentialed job, and there are exactly two ways this
   # workflow could stop being true: a job that runs on pull_request naming a
   # secret, or one asking for id-token: write to federate into a cloud.
   #
   # The reading is deliberately blunt. Any job that is not gated to push is
   # treated as reachable from a pull request, because that is what GitHub does.
   run_workflow() {
   	say "== the fork-PR property"
   	local wf="$access_root/../.github/workflows/access.yml"
   	if [ ! -f "$wf" ]; then
   		fail "no .github/workflows/access.yml to check"
   		return
   	fi

   	if ! sed -n '/^on:/,/^[a-z]/p' "$wf" | grep -q 'pull_request'; then
   		ok "the workflow does not run on pull_request at all"
   		return
   	fi

   	# Split into job blocks. A job key sits at two spaces under jobs:, and its
   	# block runs to the next one.
   	local blocks
   	blocks="$(awk '
   		/^jobs:/ { injobs = 1; next }
   		injobs && /^[^[:space:]#]/ { injobs = 0 }
   		injobs && /^  [a-zA-Z0-9_-]+:/ { name = $1; sub(/:$/, "", name); print "@@job@@" name }
   		injobs { print }
   	' "$wf")"

   	local job="" gated=0 bad=0 seen=0
   	local line
   	while IFS= read -r line; do
   		case "$line" in
   		"@@job@@"*)
   			job="${line#@@job@@}"
   			gated=0
   			seen=$((seen + 1))
   			continue
   			;;
   		esac
   		case "$line" in
   		*"github.event_name == 'push'"*) gated=1 ;;
   		esac
   		if [ "$gated" -eq 0 ] && [ -n "$job" ]; then
   			case "$line" in
   			*'secrets.'*)
   				fail "job $job runs on pull_request and names a secret"
   				bad=1
   				;;
   			*'id-token:'*'write'*)
   				fail "job $job runs on pull_request and asks for id-token: write"
   				bad=1
   				;;
   			esac
   		fi
   	done <<EOF
   $blocks
   EOF

   	if [ "$seen" -eq 0 ]; then
   		fail "could not read any job out of .github/workflows/access.yml"
   		return
   	fi
   	[ "$bad" -eq 0 ] && ok "no job reachable from pull_request names a secret or asks to federate"
   }
   ```

   Then teach the plan stage what a diff means where it is running. In `run_plan`, replace the `2)` arm.

   ```sh
   	2)
   		if [ "$plan_mode" = ci ]; then
   			ok "envs/prod plans the change this branch proposes, exit 2"
   		else
   			fail "envs/prod has an unapplied diff. Run terraform -chdir=access/envs/prod plan"
   		fi
   		;;
   ```

   And declare the option, straight after `run_plan` and before the `case "${1:-all}"` dispatch.

   ```sh
   # What a plan that is not empty means depends on the account it ran against.
   #
   #   laptop   the default. Floci already holds the applied estate, so a diff is
   #            something nobody applied and the stage fails until it is applied.
   #   ci       the account is a service container this job filled from the base
   #            branch, so a diff is exactly the change the pull request proposes.
   #            The stage records it and stays green. Binding that change to an
   #            approval is the digest step's job, not this one's.
   #
   # Set with --plan-mode ci or ACCESS_PLAN_MODE=ci.
   plan_mode="${ACCESS_PLAN_MODE:-laptop}"

   while [ $# -gt 0 ]; do
   	case "$1" in
   	--plan-mode)
   		plan_mode="${2:-}"
   		shift 2 || true
   		;;
   	--plan-mode=*)
   		plan_mode="${1#--plan-mode=}"
   		shift
   		;;
   	*) break ;;
   	esac
   done

   case "$plan_mode" in
   laptop | ci) ;;
   *)
   	echo "check: unknown --plan-mode $plan_mode. It is laptop or ci." >&2
   	exit 2
   	;;
   esac
   ```

   Last, the dispatch. Two new arms and the usage line.

   ```sh
   fixtures) run_fixtures ;;
   codeowners) run_codeowners ;;
   workflow) run_workflow ;;
   plan) run_plan ;;
   all)
   	run_fmt
   	run_validate
   	run_lint
   	run_fixtures
   	run_codeowners
   	run_workflow
   	run_plan
   	;;
   *)
   	echo "usage: access/scripts/check [--plan-mode laptop|ci] [all|fmt|validate|lint|fixtures|codeowners|workflow|plan]" >&2
   	exit 2
   	;;
   esac
   ```

9. Break the workflow twice and watch the check catch it. First the property as it stands.

   ```sh
   access/scripts/check workflow
   ```

   ```text
   == the fork-PR property
   ok    no job reachable from pull_request names a secret or asks to federate
   ```

   Now put a cloud credential where a fork could reach it. Add an `env` block to the `pr` job's check step.

   ```yaml
         - name: The check stack
           env:
             AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
           run: access/scripts/check --plan-mode ci
   ```

   ```sh
   access/scripts/check workflow
   ```

   ```text
   == the fork-PR property
   FAIL  job pr runs on pull_request and names a secret
   ```

   Take that back out, and try the other door. Add `id-token: write` to the `pr` job's `permissions` block.

   ```text
   == the fork-PR property
   FAIL  job pr runs on pull_request and asks for id-token: write
   ```

   Take that back out too. Those are the two ways a cloud credential gets into a job an untrusted author can trigger, and prescription 6 now has a test instead of a paragraph. Try the same two edits inside the `apply` job and the check stays quiet, because that job is gated to `push` and a pull request cannot reach it.

10. Take the rest of the workflow, then run the whole stack.

    ```sh
    git checkout checkpoint/i6 -- .github/workflows/access.yml
    just access-check
    ```

    What the checkout adds is the body of the two jobs rather than their shape. The `pr` job gains the wait loop, the terraform and tflint setup, the step that applies the pull request's base sha into the job's Floci and carries the state across, the saved plan and its digest, the satellite plan loop, the delta, the proofs, the guardrail severity block, the job summary, the label and comment attempts and the artifact upload. The `apply` job gains the step that resolves which pull request this commit closed, the artifact download by head sha, the rebuild from the same base, the re-plan, the digest comparison and the convergence check. Read them once. None of it changes the two facts step 7 wrote down, and `check workflow` says so.

    `just access-check` ends on `check passed`, with `ok    .github/CODEOWNERS matches the principal files`, `ok    no job reachable from pull_request names a secret or asks to federate` and `ok    envs/prod matches the account, exit 0`.

    Now that the routing has a stage of its own, do the hand edit from step 6 once more against it.

    ```sh
    printf '/access/envs/prod/iam_role.waterpark_apply.tf @someone-else\n' >> .github/CODEOWNERS
    access/scripts/check codeowners
    access/scripts/gen-codeowners
    access/scripts/check codeowners
    ```

    `FAIL  .github/CODEOWNERS was hand edited or a principal file moved`, then `ok    .github/CODEOWNERS matches the principal files`. That is the second half of prescription 5, and it now runs in CI on every pull request rather than only when somebody remembers.

11. Read the path running for real, on a run this repository already has. Nothing on a laptop can show you two jobs choosing not to run.

    ```sh
    gh run view 34011731889 --repo INTENTIUS/waterpark
    gh run view 34011867194 --repo INTENTIUS/waterpark
    ```

    The first is a `pull_request` run. `pr` ran for one minute and fifty-five seconds and `apply` shows `0s`, and the artifact `access-plan-170a2586358d6a62e0d9f0fc3dc31427b23c21bb` is listed under it, keyed by that branch's head commit. The second is the push to main that merged it. There `apply` ran and `pr` shows `0s`. The same file, two events, and each job runs on exactly one of them.

    Then read the stack the `pr` job ran, which is the stack you just ran.

    ```sh
    gh run view 34011731889 --repo INTENTIUS/waterpark --log |
      grep -v '36;1m' | grep 'The check stack'
    ```

    Same stage names and the same `ok` lines, with one difference. The plan stage reads `ok    envs/prod plans the change this branch proposes, exit 2` rather than `exit 0`, because that job filled its Floci from the base branch and a diff there is the pull request. That is `--plan-mode ci` earning its keep.

    Then the half a laptop cannot have at all.

    ```sh
    gh run view 34011867194 --repo INTENTIUS/waterpark --log |
      grep -v '36;1m' |
      grep -E "rebuilds its account|head was|pr job ran as|approved  sha256|recomputed sha256|plan being applied"
    ```

    ```text
    this apply rebuilds its account from bbfc3e76a9f6167bc068a54a4ac61f6870ef61a7
    the merged PR's head was 170a2586358d6a62e0d9f0fc3dc31427b23c21bb
    its pr job ran as 34011731889
    approved  sha256:5efa75eb20bf154a5ecb05448348749c2f06f102014eded9470b58621883b221
    recomputed sha256:5efa75eb20bf154a5ecb05448348749c2f06f102014eded9470b58621883b221
    The plan being applied is the plan that was approved.
    ```

    Read the first three lines together. The apply job did not trust the plan the PR job saved. It rebuilt the same account from the same base commit, planned again, and only then compared. Two identical inputs give the same digest by construction, so a mismatch is not noise, it is something that actually moved between approval and apply, and the job refuses. The whole `pr` job summary, with the severity block, the access delta, the proof verdict and the digest, is on the run page at `https://github.com/INTENTIUS/waterpark/actions/runs/34011731889`.

12. Compare with the reference repo, then tear down. The plan artifacts are not part of the tree, so remove them first, and stage before diffing because most of what you added is new files.

    ```sh
    rm -f plan.json access/envs/prod/tfplan
    git add -A access .github scripts
    git diff --cached --stat checkpoint/i6 -- access .github scripts ':!access/README.md'

    terraform -chdir=access/envs/prod destroy -auto-approve
    docker rm -f wp-i6-floci
    ```

    Nothing printed means every file you wrote is the reference file. `access/README.md` is excluded because the reference repo's prose for `access/` describes lessons 7 and 8 as well, and none of it is something this lesson has you write. If the diff names anything else, read the difference rather than pasting over it.

## Self-paced

Everything above runs on a laptop except the two `gh run view` calls, and those read a finished run rather than starting one.

What the solo path proves. The apply role exists, carries the boundary, is trusted by the issuer and nothing else, and is refused when an identity of its shape tries to detach a boundary. The routing is derived from the principal files and a hand edit fails a check. The workflow's fork-PR property is a test that fires on both of the two ways it could break. The delta and the digest are computed over a real plan against a real IAM implementation.

What it does not prove. Nothing on a laptop runs two GitHub Actions jobs, so the digest comparison, the artifact keyed by head sha and the `environment: prod` gate are read from a finished run rather than reproduced. Step 11 is that reading, and it is a real run of this workflow rather than a screenshot.

The apply job in that run applied into a Floci service container that died with the job. So it proves the pipeline and the refusal, and it proves nothing about persistence in an account (decision 51). Lesson 7 is where an account that outlives a job starts to matter, and it seeds its drift on a laptop for exactly this reason.

Access Analyzer is live only. The patched Floci build lists `accessanalyzer` among its services and answers `UnknownOperationException` to `validate-policy`, `check-no-new-access` and `check-access-not-granted` alike, which is why `proofs` prints a skip that names the image and the date rather than a verdict. `check-no-new-access` against the base branch and `check-access-not-granted` over the boundary's forbidden list are what decision 22 asks for post-merge-queue, and they have never run on the solo path. `access/scripts/proofs --live` is the command, and it needs an account.

`access/github` is validated and linted on every check and never applied here. There is no emulator for a code host, and the honest version of that rule is the one that says so rather than a softened one that happens to run on a laptop. Applying it live needs a `GITHUB_TOKEN` with admin rights on the repository, which is a person running a command rather than a job holding a credential, and `access/github/README.md` says why.

The apply role's boundary is a known contradiction (decision 58). On a real account the estate boundary would deny `waterpark-apply` the IAM write it needs, and step 5's `prove-no-detach` shows exactly that when it reads `iam:GetRole on waterpark-apply is denied` as one of its `ok` lines. That deny is right and it is also the deny that would stop the role working. The taught path never hits it because the job talks to Floci as `test` and never assumes the role.

## Live

Twenty five minutes, in three moves.

Open on step 9, not on the workflow. Put `${{ secrets.AWS_ACCESS_KEY_ID }}` into the `pr` job in front of the room and run `access/scripts/check workflow`. Then delete it, add `id-token: write` instead, and run it again. Two edits, two refusals, and the room has seen prescription 6 as a test rather than as a paragraph. Then move both edits into the `apply` job and show the check going quiet, and ask why that is correct.

Then step 5, and let `prove-no-detach` print its whole run rather than its verdict. The controls are the interesting part. Point at `the test credential cannot assume waterpark-apply, because the trust names the issuer and not a key` and at `iam:GetRole on waterpark-apply is denied`, then read the honesty line straight off the page. This role carries a boundary that would stop it applying the estate on a real account. We know, it is decision 58, and the fix is a second boundary the course has not taken. A pattern that hides that would be teaching something we do not believe.

Then step 11 on the projector, both runs side by side. `pr` ran and `apply` did not, then `apply` ran and `pr` did not. Then the two digest lines. The line to say is that the apply job did not trust the digest it was handed. It rebuilt the same account from the same commit and recomputed, because an approval that binds to a number somebody else calculated binds to nothing.

The second honesty line belongs here too. That apply ran against a container that no longer exists. What the room watched is a pipeline refusing a plan it did not approve, which is the thing worth watching, and not an estate persisting anywhere.

Live, the same workflow points at a real account with `-var floci=false`, the OIDC tiers become real, `proofs --live` returns a verdict, and `access/github` gets applied once by a maintainer with a personal token.

## Further reading

- [access/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md), "Lesson 6, one path to prod"
- [access/github](https://github.com/INTENTIUS/waterpark/blob/main/access/github/README.md), branch protection and its cost
- [access/scripts](https://github.com/INTENTIUS/waterpark/blob/main/access/scripts/README.md), what each script is for
- [The AWS desk](../../docs/aws-desk.md), the apply job
- [Threat model](../../docs/threat-model.md)
- [Design, agentic](../../docs/design/agentic.md), why a PR job counts rather than trusts
- [Prescriptions](../../docs/prescriptions.md), 5, 6, 7 and 14
- [Decisions](../../docs/decisions.md), 12, 21, 22, 24, 51, 52, 54 and 58
- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A20, A17, A12 and A3b
