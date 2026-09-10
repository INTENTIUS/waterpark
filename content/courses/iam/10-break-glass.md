---
title: "Break-glass"
id: "I10"
lesson: 10
weight: 10
summary: "Break-glass access expires cloud-side whatever else fails."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i10-break-glass"
# card. empty renders as TODO
goal: "Give the on-call prod write for two minutes the way a real incident would give it for two hours, as one grant in one file with a `granted_at`, an expiry the cloud enforces and a reason the audit trail reads. Watch three things refuse a grant that lasts too long, watch the drift watch report the leftover once the expiry has passed with the cleanup deliberately not run, then run the sweep and read what the apply job stamps on the artifact that you cannot stamp yourself."
done_when: "`just access-check` passes with `break-glass-ttl` in its fixture stage and the line saying the TTL is one constant in three places, `access/scripts/break-glass grant` on `on-call` applies as one policy carrying `DateLessThan aws:CurrentTime` with the `break_glass`, `granted_at` and `approved_by` tags, a three-hour expiry is refused by `access/scripts/check lint` and by `terraform plan`, `access/scripts/drift` exits 2 with an `expired` finding on the grant once its two minutes have passed, and `access/scripts/break-glass revoke` returns the file to `grants = []` so the apply destroys two resources and the watch exits 0."
restart_from: "checkpoint/i9"
properties: ["VII", "VIII"]
closes: ["P9"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "40 min"
  needs:
    - "a water park checkout with the tags fetched"
    - "Docker running"
    - "the patched Floci image ghcr.io/lex00/floci:iam-boundary"
    - "terraform 1.9 or newer"
    - "tflint from terraform-linters/tap/tflint"
    - "jq"
    - "just access-init run once per clone"
    - "lesson 9 finished or at least read"
---

## Context

- Break-glass is three layers, and the order matters (prescription 9). The grant carries its own expiry, a `DateLessThan aws:CurrentTime` condition on the policy, so the cloud ends the access with nothing alive. A scheduled sweep removes the artifact. The drift watch reports an expired grant as a finding until the sweep's PR merges. Killing the sweep delays cleanup and never extends access (decision 8). That last sentence is the guarantee, and it is honest only because layer 1 is a condition the cloud evaluates rather than a job that has to run.
- The grant is the persona module's own grant shape plus one field. `granted_at` marks a grant as break-glass, `expires` is at most `break_glass_max_ttl_hours` after it, `reason` is required, and the module renders the condition and three tags, `break_glass`, `granted_at` and `approved_by`, onto the policy (decision 60). Lesson 2 gave `desk-operator` an expiring grant with no `granted_at`, and that is a standing grant with a date, which is a different thing.
- The TTL is refused three times and not four. `access/scripts/break-glass` refuses a longer grant before writing it. `break-glass-ttl` refuses one at lint, in the editor. The persona module refuses one at plan. `terraform validate` lets it through, because a validation that reads another variable is evaluated at plan rather than at validate, and the lesson shows that rather than hiding it. The constant lives in `access/baseline`, is restated as the rule's literal and the module's default because neither can read that file, and `check` fails when the three differ.
- The request is a pull request and so is the cleanup (decision 1). `break-glass grant` writes one fenced block into the principal file and stops. Merging is the approval, the apply is what makes it access, and `break-glass sweep` revokes expired blocks the same way, one PR per principal file. Nobody types a timestamp.
- The approver is the reviewer who approved the pull request, and the apply job copies that identity onto the grant's policy after the apply (decision 37). After, because the reviewer is not known when the plan is made and the plan is what was approved (decision 24). The module ignores that one tag on the next plan. On the solo path nobody approved anything and the tag says `unapproved`.
- The on-call is a human. Live, the grant lands on their permission set as an inline policy under the standing account assignment, and the condition is what makes it temporary. Floci runs no Identity Center, so on the solo path the same grant lands on `on-call`, a role under `envs/prod` that holds nothing at rest and stands in for the permission set. The page says so every time it matters.
- What Floci cannot show, said before the steps rather than after. Floci evaluates no condition on an allow, so a policy with a `DateLessThan` on it is denied on the emulator before the expiry as well as after. Everything declared, checked, watched and swept in this lesson is real here. The one thing the emulator cannot show is the access working and then ending, and that drill is live only ([upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md)).
- The lesson 7 watch had a gap this lesson closes. A clean plan skipped the rest of the loop, so an expired grant on a root with no other drift was never reported. Step 8 is where that would have bitten.
- The code-host-down fallback is a CLI confirmation by a second human, and TEAM interop stays open (design/break-glass.md item 4).

## Do

Lesson 9 pinned who may become a principal. This lesson is about access that should exist for two hours and then not, and what has to be true for "and then not" to hold when everything you built is down.

1. Start from the checkpoint lesson 9 left, bring Floci up, and apply central and then the satellite.

   ```sh
   git fetch origin --tags
   git worktree add ../waterpark-i10 checkpoint/i9
   cd ../waterpark-i10
   just access-init

   docker run -d --name wp-i10-floci -p 4566:4566 \
     -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
     ghcr.io/lex00/floci:iam-boundary

   curl -s --retry 15 --retry-all-errors --retry-delay 1 \
     -o /dev/null -w '%{http_code}\n' http://localhost:4566/

   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod apply -auto-approve
   terraform -chdir=access/satellites/waterpark-runner init
   terraform -chdir=access/satellites/waterpark-runner apply -auto-approve
   ```

   `200`, then `Resources: 17 added` and `8 added`. If `just access-init`
   printed `All plugins are already installed`, that is tflint's plugin cache
   from an earlier lesson and it is fine. Then read the constant this
   lesson turns on, out of the applied estate rather than out of a page.

   ```sh
   terraform -chdir=access/envs/prod output break_glass_max_ttl_hours
   ```

   `2`. Lesson 5 put it in `access/baseline` so that a lesson could read it,
   and this is the lesson.

2. Bring in the machinery. The module change, the rule, the script and the two workflow edits are the mechanism rather than the lesson, so take them from the reference tree.

   ```sh
   git checkout checkpoint/i10 -- \
     access/modules/persona/variables.tf \
     access/modules/persona/locals.tf \
     access/modules/persona/iam_policy.grant.tf \
     access/modules/persona/ssoadmin_permission_set_inline_policy.grants.tf \
     access/envs/prod/variables.tf \
     access/.tflint.d/policies/break-glass.rego \
     access/tests/fixtures/break-glass-ttl \
     access/scripts/check \
     access/scripts/break-glass \
     access/scripts/drift \
     .github/workflows/drift.yml \
     .github/workflows/access.yml
   ```

   What each one is.

   The three `modules/persona` files are the grant shape. `variables.tf`
   adds `granted_at` to a grant and three validations behind it, an expiry
   and a reason required, and the expiry no more than
   `break_glass_max_ttl_hours` later. `locals.tf` picks the break-glass
   subset out. `iam_policy.grant.tf` tags that subset with `break_glass`,
   `granted_at` and `approved_by`, and tells Terraform to ignore the last
   one, because step 9 says who writes it.

   `ssoadmin_permission_set_inline_policy.grants.tf` is the human path, a
   permission set's grants rendered as its inline policy, live only.

   `envs/prod/variables.tf` gains `break_glass_approver`, which the apply
   job passes and the solo path leaves at `unapproved`.

   `break-glass.rego` is `break-glass-ttl`, and its fixtures. `check` gains
   the rule and one more line that compares the TTL in `baseline/`, in the
   Rego and in the module's default, because the constant lives in one place
   and the other two are copies it keeps honest.

   `break-glass` is steps 4 to 8. `drift` gains a fix step 8 explains.
   `drift.yml` runs the sweep after the watch. `access.yml` gains the step
   that stamps the approver, which step 9 reads.

   Then apply, and read the two lines that say nothing in the account moved.

   ```sh
   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod apply -auto-approve
   just access-check
   ```

   `Resources: 0 added, 0 changed, 0 destroyed.`, because no grant carries a
   `granted_at` yet and the module renders exactly what it rendered before.
   Then under the rule fixtures,
   `ok    break_glass_max_ttl_hours is 2 in access/baseline, in the rule pack and in modules/persona`
   and `ok    break-glass-ttl (error)`, and `check passed`.

3. Write the on-call. This is the principal the incident hands access to, and at rest it holds nothing. Write `access/envs/prod/iam_role.on_call.tf`.

   ```hcl
   # The on-call, on the solo path. A human, so live this is course-author's
   # permission set under access/identity carrying a break-glass grant, and the
   # standing Identity Center assignment is what makes the grant reachable
   # (decision 37). Floci runs no Identity Center, so here the same grant lands
   # on a role that stands in for the permission set, and the page says so.
   #
   # At rest this principal holds nothing. A break-glass grant is a pull request
   # that adds one grant here with a granted_at, an expiry no more than the
   # baseline TTL later, and a reason, and access/scripts/break-glass writes and
   # revokes that block. The cloud ends the access at the expiry whether or not
   # anything else runs (decision 8).
   module "on_call" {
     source = "../../modules/persona"

     persona     = "service"
     name        = "on-call"
     description = "The on-call's break-glass stand-in on the solo path. Holds nothing at rest, and a grant here is an incident with an expiry."
     owner       = local.owner
     teams       = ["platform"]

     permissions_boundary = module.baseline.boundary_arn
     break_glass_approver = var.break_glass_approver

     grants = []
   }
   ```

   Then add it to the two maps in `access/envs/prod/outputs.tf`, one line in
   each, after the `waterpark_apply` lines.

   ```hcl
       (module.on_call.role_name)         = module.on_call.role_arn
   ```

   ```hcl
       on-call         = module.on_call.grants
   ```

   A new principal file is a new line in CODEOWNERS, and nobody edits
   CODEOWNERS.

   ```sh
   access/scripts/gen-codeowners
   grep on_call .github/CODEOWNERS

   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod apply -auto-approve

   export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
   aws --endpoint-url http://localhost:4566 iam list-attached-role-policies \
     --role-name on-call --query 'AttachedPolicies'
   ```

   `/access/envs/prod/iam_role.on_call.tf @INTENTIUS/platform`, then the init
   prints `- on_call in ../../modules/persona`, because a new module block is
   a module Terraform has not installed yet, then `Resources: 1 added`, then
   `[]`. A role with a boundary, a trust and no
   policy at all. That is what the on-call holds at four on a Friday
   afternoon, and it is the point.

4. Grant. It is late on a Friday and a release broke the site. Two minutes stands in for two hours, so that the expiry passes while you are still in the lesson.

   ```sh
   access/scripts/break-glass grant access/envs/prod/iam_role.on_call.tf \
     waterpark-site write \
     --reason "A release broke the site late on a Friday." \
     --minutes 2
   ```

   ```text
   granted   bg-on-call-20260910T2004Z
     file       access/envs/prod/iam_role.on_call.tf
     grant      write on waterpark-site
     granted_at 2026-09-10T20:04:44Z
     expires    2026-09-10T20:06:44Z
     reason     A release broke the site late on a Friday.

     This is a file change and nothing more. The pull request is the request,
     the merge is the approval, and the apply is what makes it access.
   ```

   Read what it wrote.

   ```sh
   sed -n '/grants = \[/,/^  \]/p' access/envs/prod/iam_role.on_call.tf
   ```

   ```hcl
     grants = [
       # break-glass bg-on-call-20260910T2004Z. Written by access/scripts/break-glass, revoked by its sweep.
       {
         resource   = "waterpark-site"
         access     = "write"
         granted_at = "2026-09-10T20:04:44Z"
         expires    = "2026-09-10T20:06:44Z"
         reason     = "A release broke the site late on a Friday."
       },
       # end break-glass bg-on-call-20260910T2004Z
     ]
   ```

   One grant, the shape lesson 2 gave every grant, with one more field and
   two marker comments that carry an id. The markers are what `revoke` and
   `sweep` find later, so a human can still read the file as a file and the
   script can still find its own work. Now apply it, which is what the merge
   would do.

   ```sh
   terraform -chdir=access/envs/prod plan
   terraform -chdir=access/envs/prod apply -auto-approve
   ```

   `Plan: 2 to add, 0 to change, 0 to destroy.`, a policy and its attachment,
   then the apply. Read the artifact out of the account, the tags and then the
   condition.

   ```sh
   aws --endpoint-url http://localhost:4566 iam list-policy-tags \
     --policy-arn arn:aws:iam::000000000000:policy/on-call-write-waterpark-site \
     --query 'Tags[?Key==`break_glass` || Key==`granted_at` || Key==`expires` || Key==`approved_by`]' \
     --output text

   aws --endpoint-url http://localhost:4566 iam get-policy-version \
     --policy-arn arn:aws:iam::000000000000:policy/on-call-write-waterpark-site \
     --version-id v1 --query 'PolicyVersion.Document.Statement[0].Condition'
   ```

   ```text
   granted_at	2026-09-10T20:04:44Z
   expires	2026-09-10T20:06:44Z
   approved_by	unapproved
   break_glass	true
   ```

   The four tags come back in whatever order the account keeps them.

   ```json
   {
       "DateLessThan": {
           "aws:CurrentTime": "2026-09-10T20:06:44Z"
       }
   }
   ```

   That condition is layer 1. It is on the policy in the account, and the
   account evaluates it on every call, so when the time passes the access
   ends with nothing of yours alive. The `approved_by` tag reads `unapproved`
   because nobody reviewed anything, and step 9 says who fills it in.

   ```sh
   access/scripts/break-glass list
   ```

   `[live] bg-on-call-20260910T2004Z`, with the file and the expiry.

5. Ask for too long, three ways, and get refused three ways.

   The script first.

   ```sh
   access/scripts/break-glass grant access/envs/prod/iam_role.on_call.tf \
     waterpark-artifacts write --reason "Also this." --hours 3
   ```

   `break-glass: that is longer than the baseline TTL of 2 hour(s). Grant for
   less, or grant again when it runs out (decision 37).` and nothing written.
   Then go around the script, the way a person with an editor would. Open
   `access/envs/prod/iam_role.on_call.tf` and move the `expires` line three
   hours after the `granted_at` line, keeping the same format.

   ```sh
   access/scripts/check lint
   ```

   ```text
   iam_role.on_call.tf:24:12: Error - module "on_call" grants write on waterpark-site for 3 hours. A break-glass grant lasts at most 2 hours after granted_at (access/baseline, decision 37). Shorten the expiry, or grant again when it runs out. (opa_deny_break_glass_ttl)
   FAIL  tflint in access/envs/prod
   ```

   That is the editor's refusal, and it read the module call in a principal
   file the way `boundary-required` does. Then the one that happens with the
   linter switched off.

   ```sh
   terraform -chdir=access/envs/prod validate
   terraform -chdir=access/envs/prod plan
   ```

   `validate` prints `Success! The configuration is valid.`, and `plan` prints
   `Error: Invalid value for variable` on the `grants` block, with
   `var.break_glass_max_ttl_hours is 2` and the module's message about the
   TTL. Read those two results against each other. A validation on a variable
   that reads another variable is evaluated when values are known, which is
   plan, so `validate` is not the check here and the page says so rather than
   claiming a fourth refusal. Nothing gets applied with a three-hour grant in
   it. Put the `expires` line back exactly as step 4 wrote it, and run
   `access/scripts/check lint` again until it ends `check passed`.

6. Do not run the cleanup. This is the drill prescription 9 asks for, kill the cleanup mid-grant, and on a laptop the way to kill a scheduled job is to not run it. Read the time, and compare it with the expiry from step 4.

   ```sh
   date -u +%Y-%m-%dT%H:%M:%SZ
   access/scripts/break-glass list
   ```

   If the expiry has not passed yet, read the next paragraph and come back.

   What would be true on a real account right now. Before the expiry the
   on-call can write to the site bucket, and after it they cannot, and no job
   ran between those two facts. The policy is still attached, the file still
   says the grant exists, and the access is gone anyway, because
   `aws:CurrentTime` is the account's clock and not yours. That is the whole
   guarantee, and it is what decision 8 means by a dead cleanup delaying
   cleanup and never extending access.

   What is true on Floci. The emulator evaluates no condition on an allow, so
   the on-call was denied before the expiry too. Everything declared, checked
   and watched here is real, and the one thing the emulator cannot show is
   the access working and then ending. The live section is where that is
   shown, and [upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md)
   has the probe.

7. Once the two minutes have passed, run `list` again.

   ```sh
   access/scripts/break-glass list
   ```

   `[expired] bg-on-call-20260910T2004Z`. The file still says the grant
   exists and the account still holds the policy. On a real account it grants
   nothing. That is the leftover, and it is a finding.

8. Watch the watch find it. This is layer 3.

   ```sh
   access/scripts/drift
   echo $?
   ```

   ```text
   drift report, 2026-09-10T20:06:55Z

     [pr] envs/prod  grant on-call write-waterpark-site
         expired
         expires
           declared 2026-09-10T20:06:44Z
           live     past

     1 finding(s), 0 of them paging
   ```

   and `2`. Nothing in the account differs from the file, and the watch
   reports it anyway, because a grant whose expiry has passed is drift by
   lesson 7's own definition. Lesson 7's script never showed you this case,
   and it could not have. A clean plan skipped the rest of the loop, so an
   expired grant on a root with nothing else wrong was never reported. The
   `drift` step 2 brought in runs the expiry check whatever the plan said,
   and this is the finding that made the fix worth a lesson.

   The finding is `pr`, because an expired grant grants nothing and restoring
   it is not what anyone wants. What is wanted is the sweep.

9. Sweep. This is layer 2, run late.

   ```sh
   access/scripts/break-glass sweep
   ```

   ```text
   break-glass sweep, 2026-09-10T20:06:55Z

     expired  bg-on-call-20260910T2004Z, expired 2026-09-10T20:06:44Z
              access/envs/prod/iam_role.on_call.tf

     file   access/envs/prod/iam_role.on_call.tf
            branch desk/break-glass/on-call

     This was the dry run. Nothing was edited, branched or opened.
     Add --open with a gh that can write to file the sweep, or revoke by id to edit in place:
       access/scripts/break-glass revoke bg-on-call-20260910T2004Z
   ```

   On the schedule this is `.github/workflows/drift.yml` printing the plan
   into the job summary, and a maintainer running it with `--open` where `gh`
   can write, which files one PR per principal file on a branch named for the
   principal. Here, revoke by id, which is what merging that PR would do.

   ```sh
   access/scripts/break-glass revoke bg-on-call-20260910T2004Z
   tail -3 access/envs/prod/iam_role.on_call.tf

   terraform -chdir=access/envs/prod plan
   terraform -chdir=access/envs/prod apply -auto-approve
   access/scripts/drift
   echo $?
   ```

   `revoked`, then the file ends `grants = []` the way step 3 wrote it, then
   `Plan: 0 to add, 0 to change, 2 to destroy.`, the apply, and
   `every watched root matches the account` with `0`. The artifact is gone,
   the file is what it was, and the incident is in git history, the
   conversation and CloudTrail rather than in the account.

   Now read the three layers in the order they actually held. The cloud ended
   the access at 20:06:44 with no job alive. The watch reported the leftover
   at 20:06:55. The sweep removed it whenever somebody got to it. Layer 2 was
   late by design, and the access did not care.

10. The approver, which you cannot write. Open the apply job and read the step step 2 brought in.

    ```sh
    grep -n "Stamp the approver" -B8 -A30 .github/workflows/access.yml | head -60
    ```

    It asks the API which pull request this merge commit closed, reads that
    PR's reviews, takes the last one in state `APPROVED`, and writes its login
    as `approved_by` on every policy tagged `break_glass`, after the apply.
    Read why it is after. The plan the reviewer approved was made before they
    approved it, so the reviewer's name cannot be in that plan, and the
    digest from lesson 6 would refuse a plan that changed to include it. So
    the approval and the artifact name the same human, and the plan that was
    approved is still the plan that was applied. `iam_policy.grant.tf` tells
    Terraform to ignore that one tag on the next plan, and that is the only
    `ignore_changes` in the estate.

    Then the human path, which the solo path validates and never plans.

    ```sh
    terraform -chdir=access/identity init -backend=false
    terraform -chdir=access/identity validate
    ```

    `Success!`. The `identity/` root now carries the permission set inline
    policy the module renders for a human's grants, so the same grant block
    step 4 wrote, put in `ssoadmin_permission_set.course_author.tf` instead,
    lands on the course author's permission set under the standing account
    assignment, with the same condition and the same TTL refusals. Floci
    cannot plan it, and a live session does.

11. Compare with the reference repo, then tear down. The on-call file and the fixtures are new, so stage first.

    ```sh
    git add -A access .github
    git diff --cached --stat checkpoint/i10 -- access .github ':!*README.md'

    terraform -chdir=access/satellites/waterpark-runner destroy -auto-approve
    terraform -chdir=access/envs/prod destroy -auto-approve
    docker rm -f wp-i10-floci
    ```

    Nothing printed means every file you wrote is the reference file, and in
    particular that `revoke` put `iam_role.on_call.tf` back byte for byte.
    The `README.md` files are excluded and they are the only exclusions. If
    the diff names the on-call file, the likeliest cause is the `expires` line
    from step 5 not restored exactly, and `revoke` then left the block in
    place because its marker was still there. Read the difference rather than
    pasting over it.

## Self-paced

The whole lesson runs on Floci, and the honesty line is in step 6, before the expiry rather than after.

What Floci shows. The grant applies and reads back with its `DateLessThan` condition and its tags, `get-policy-version` returns the document as the module wrote it, the script, the rule pack and `plan` each refuse a three-hour grant, `drift` reports the expired grant, and the sweep and the revoke put the file and the account back. Everything about the grant as an artifact is real on the emulator.

What Floci cannot show. Floci evaluates no condition on an allow. A policy carrying `DateLessThan aws:CurrentTime` is denied on the emulator before the expiry as well as after, and so is one carrying `StringEquals aws:RequestedRegion`, which was the control. The fork populates `iam:PermissionsBoundary` for four IAM calls and no global key, and its evaluator has no date operator, so the condition has nothing to match and fails closed. It fails safe, and it means the drill where the on-call writes to the bucket at 20:05 and is refused at 20:07 with no job in between is live only. [upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md) has the probe and the two classes a fork fix would touch, and the lesson is written to work the day it lands.

The human path is validated and never planned. `identity/` targets the management account and Floci runs no Identity Center, so the permission set inline policy exists to be read and checked here and applies only live (decision 27). The `on-call` role is the stand-in, and the page says so at every step where it matters, because a role named for a human is exactly what decision 5 forbids and the reason it exists here is that the emulator gives no other place for the grant to land.

The sweep opens no PR from a laptop unless told to. `sweep` plans by default and `--open` needs a `gh` that can write, the same posture as `reconcile` in lesson 7, and the scheduled job holds `contents: read` and only ever plans. Layer 2 is deliberately the slow one.

## Live

Twenty five minutes, and the room needs steps 4, 6 and 9, plus the one thing the solo path could not do.

Open on step 4 with the two-minute grant on the projector, and read the condition out of the account rather than out of the file. Then do the thing the emulator cannot. As the on-call, before the expiry, write one object into the site bucket, and let the room watch it land.

```sh
aws s3 cp hotfix.html s3://waterpark-site/hotfix.html
```

Then talk through step 5 while the clock runs, and when `date` passes the expiry, run the same command again.

```text
upload failed: ... An error occurred (AccessDenied) when calling the PutObject operation
```

Nothing ran. The policy is still attached, the file still says the grant exists, `list` still says `live` for another second, and the account said no. The line to say is that this is the only layer that has to hold, and it holds because it is not ours. Then run `drift` and `sweep` in front of the room and let somebody notice that both happened after the access was already gone.

Two honesty lines. The first is the emulator. On Floci that first `aws s3 cp` is refused too, before the expiry, because the emulator evaluates no condition on an allow. We found it while writing this lesson, it is in `project/upstream.md`, and the solo path says so at step 6 rather than at the end. The second is the role. `on-call` is a role standing in for a human's permission set, in a course whose fifth decision says humans get permission sets. It exists because Floci runs no Identity Center, and live the grant lands on `course-author`'s permission set through `identity/`, which is where the room should see it applied.

Live, the same code runs against a real account with `-var floci=false`, the apply job stamps the reviewer's login onto the policy after the apply, and `list-policy-tags` on the projector shows `approved_by` naming somebody in the room.

## Further reading

- [access/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md), "Lesson 10, break-glass"
- [access/modules/persona](https://github.com/INTENTIUS/waterpark/blob/main/access/modules/persona/README.md), the grant shape
- [access/scripts](https://github.com/INTENTIUS/waterpark/blob/main/access/scripts/README.md), what each script is for
- [Break-glass](../../docs/design/break-glass.md), the three layers and what is left
- [The estate](../../docs/estate.md), scenario 3
- [Prescriptions](../../docs/prescriptions.md), 9
- [Decisions](../../docs/decisions.md), 1, 5, 8, 24, 27, 37 and 60
- [Upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md), the condition the emulator does not evaluate
- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A9
