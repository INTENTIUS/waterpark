---
title: "Approve the change, not the diff"
id: "I14"
lesson: 14
weight: 14
summary: "The reviewer approves a plan and its digest, and the apply refuses anything else."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i14-approve-the-change-not-the-diff"
# card. empty renders as TODO
goal: "Make the change a pull request would make, save the plan, and read the two things a reviewer is handed, the access delta and the digest. Then move the account underneath the approved plan and watch the digest change, move the state and watch Terraform refuse the saved plan on its own, plan the same change from two separate emulators and get one digest, and rename a role to see what a replacement looks like when the delta is honest about it."
done_when: >-
  `access/scripts/render-delta` on the saved plan reads `site-publisher`
  `+ write on waterpark-artifacts`, the digest for the same in-place change
  planned against two separate Floci containers is one string while each
  plan's `before` carries its own `create_date` and `unique_id`, a hand
  edit to the account changes the digest and the normalised diff names
  `assume_role_policy` or `tags`, `terraform apply tfplan` after the state
  moved fails with `Saved plan is stale`, and a rename renders a
  Replacements section naming `name` as what forced it.
restart_from: "checkpoint/i15"
properties: ["VIII", "XIV", "VII"]
closes: ["P14"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "35 min"
  needs:
    - "a water park checkout with the tags fetched"
    - "Docker running, and the Start-here stack up or not, since this lesson starts a second container either way"
    - "the patched Floci image ghcr.io/lex00/floci:iam-boundary"
    - "terraform 1.9 or newer"
    - "tflint from terraform-linters/tap/tflint"
    - "jq"
    - "just access-init run once per clone"
    - "lesson 6 finished or at least read, since this lesson reads the jobs it built"
---

## Context

- The reviewer approves a plan. Not the diff of the files, which says what somebody typed, and not the words in the description, which say what somebody meant, but the saved plan, which says what the apply will do, rendered as the access delta and bound by a digest (decisions 24 and 35). The PR job saves the plan and records its digest, and the apply job recomputes the digest over its own plan and refuses when the two differ.
- The digest is over a normalised reading of the plan. The resource changes sorted by address, the timestamp and the prior state dropped, and on an update in place only the attributes that differ from before. That last reduction was learned the hard way. The first in-place update the pipeline ever merged, lesson 9's trust change, was refused by the apply job, because a role's `create_date` and `unique_id` from the PR job's container had been copied into the after-value and the apply job's container had its own (decision 63). This lesson proves the fix with two containers.
- There are two refusals and they are different facts. The digest refuses when the estate moved between approval and apply, which is the account being touched by something other than the plan. Terraform refuses a saved plan whose state moved, `Saved plan is stale`, which is the state being touched by another operation. The check and the applier agree, and neither depends on the other.
- A change that replaces a resource rather than updating it waits for a person. Terraform names replacements in the plan, and on IAM a replacement means an ARN changes underneath whatever trusts it. `render-delta` lists them on their own with the attribute that forced each, and the PR job writes them into the summary and labels the pull request, because "approve the change" includes the part where something stops existing.
- The gate is declared before it is configured. The apply job carries `environment: prod`, which is where a maintainer adds required reviewers in the repository settings. On this repository the environment exists and has no reviewers, so the merge is the approval today, and the page says so rather than claiming a gate the settings do not hold.
- No standing apply server runs. The apply is a job on a push to `main`, and it rebuilds the account it plans against from the merged pull request's base, the same way the PR job did, which is why the two digests are comparable at all. [pr-automation](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/pr-automation.md) has the argument.
- Provenance is a stated gap. The digest proves the plan did not move, not who produced it. An OIDC-attested build checked before apply is the follow-on nobody has scheduled, and property XIV is half closed until then.

## Do

Lesson 6 built two jobs and said the whole lesson was the difference between them. This lesson takes the object that travels from one to the other and reads it.

1. Start from the checkpoint lesson 15 left, get an emulator, and apply central. The satellite stays out of this lesson, because the digest covers `envs/prod` and that is what the apply job applies.

   ```sh
   git fetch origin --tags
   git worktree add ../waterpark-i14 checkpoint/i15
   cd ../waterpark-i14
   just access-init
   ```

   If the Start-here stack is up, its Floci answers on 4566 and this lesson
   uses it, enforcement off and all, because nothing here is refused by IAM.
   If it is down, start the container the earlier lessons started.

   ```sh
   docker run -d --name wp-i14-floci -p 4566:4566 \
     -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
     ghcr.io/lex00/floci:iam-boundary
   ```

   Either way,

   ```sh
   curl -s --retry 15 --retry-all-errors --retry-delay 1 \
     -o /dev/null -w '%{http_code}\n' http://localhost:4566/
   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod apply -auto-approve
   export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
   ```

   `200`, then `Resources: 18 added`.

2. Bring in the two files this lesson changes, the delta with its replacement section and the workflow with its replacement label, then read the two jobs before running anything, because every step below is one of their steps done by hand.

   ```sh
   git checkout checkpoint/i14 -- access/scripts/render-delta .github/workflows/access.yml
   grep -n 'Save the plan\|Find the approved plan\|Compare the digest\|environment: prod\|Label a replacement' .github/workflows/access.yml
   gh api repos/INTENTIUS/waterpark/environments/prod --jq '{name, protection_rules: (.protection_rules | length)}'
   ```

   The PR job saves the plan, digests it and uploads both as an artifact
   keyed by the head commit. The apply job finds the merged pull request,
   downloads that artifact, replans against an account it rebuilt from the
   same base, recomputes, and compares. `environment: prod` is the line
   between, and the API answers `{"name":"prod","protection_rules":0}`. The
   environment exists so it can be configured, and nobody has. On this
   repository the merge is the approval, and the digest is what makes that
   approval mean the plan rather than the diff.

3. Make the change a pull request would make, and save the plan. Give `site-publisher` write on the artifacts bucket by adding a fourth grant to `access/envs/prod/iam_role.site_publisher.tf`, after the `read` grant.

   ```hcl
       {
         resource = "waterpark-artifacts"
         access   = "write"
         reason   = "Publishes the checkpoint bundle after a lesson lands."
       },
   ```

   ```sh
   terraform -chdir=access/envs/prod plan -out=tfplan
   terraform -chdir=access/envs/prod show -json tfplan > plan.json
   access/scripts/render-delta plan.json
   access/scripts/plan-digest plan.json
   ```

   `Plan: 2 to add, 0 to change, 0 to destroy.`, then

   ```
   Access delta

     site-publisher
       + write on waterpark-artifacts


     Other resources
       + module.site_publisher.aws_iam_role_policy_attachment.grant["write-waterpark-artifacts"]
   ```

   and a digest, `sha256:a5c9fd50...`. Those two things are what the PR
   job puts in front of a reviewer. The delta is the plan translated into a
   sentence about access, which is what the reviewer is being asked to
   approve. The digest is the plan's fingerprint, which is what the
   approval binds to. Read what the fingerprint is over.

   ```sh
   access/scripts/plan-digest --normalise plan.json | jq -c '.resource_changes[] | {address, actions, after: (.after | keys)}'
   ```

   Two creates, each with its whole after-value, and no timestamp, no
   provider version and no prior state anywhere in it.

4. Move the account underneath the approved plan. This is the case the digest exists for. The reviewer approved `sha256:a5c9fd50...`, and between the approval and the apply somebody touches the account.

   ```sh
   aws --endpoint-url http://localhost:4566 iam tag-role --role-name site-publisher --tags Key=owner,Value=intruder
   terraform -chdir=access/envs/prod plan -out=tfplan2
   terraform -chdir=access/envs/prod show -json tfplan2 > plan2.json
   access/scripts/plan-digest plan2.json
   diff <(access/scripts/plan-digest --normalise plan.json) <(access/scripts/plan-digest --normalise plan2.json) | head -12
   ```

   `Plan: 2 to add, 1 to change, 0 to destroy.`, a different digest, and a
   diff that names it, an `update` on
   `module.site_publisher.aws_iam_role.this[0]` whose after-value carries
   `tags`. The apply job at this point prints `The plan moved between
   approval and apply. Refusing (decisions 24 and 35).` and exits 1, with
   that same diff under it. The reviewer approved two creates. The apply
   would have done three things, and the third was never in front of
   anyone. Put the account back and confirm the digest comes back with it.

   ```sh
   aws --endpoint-url http://localhost:4566 iam tag-role --role-name site-publisher --tags Key=owner,Value=platform
   terraform -chdir=access/envs/prod plan -out=tfplan3
   terraform -chdir=access/envs/prod show -json tfplan3 > plan3.json
   access/scripts/plan-digest plan3.json
   ```

   `sha256:a5c9fd50...` again. The digest is the change and nothing else,
   so undoing the intrusion restores it exactly.

5. Now the other refusal, which is Terraform's own. Apply the change, then try to apply the saved plan from step 3 anyway.

   ```sh
   terraform -chdir=access/envs/prod apply -auto-approve
   terraform -chdir=access/envs/prod apply tfplan
   ```

   `Resources: 2 added`, then

   ```
   Error: Saved plan is stale

   The given plan file can no longer be applied because the state was changed by
   another operation after the plan was created.
   ```

   This one is not the digest. It is Terraform refusing to apply a plan
   whose state has moved since the plan was made, and it would refuse even
   if the digest matched, because the two check different things. The
   digest asks whether the estate the reviewer saw is the estate being
   applied to. Terraform asks whether the state the plan was computed from
   is the state it would write. Decision 24 calls the second one native, and
   it is the reason the saved plan and not a re-plan is what the apply job
   applies.

6. Prove the digest does not belong to a container. Start a second emulator on another port, put a second worktree at the same commit on it, and plan the same in-place change in both.

   ```sh
   docker run -d --name wp-i14-b -p 4567:4566 \
     -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
     ghcr.io/lex00/floci:iam-boundary
   curl -s --retry 15 --retry-all-errors --retry-delay 1 \
     -o /dev/null -w '%{http_code}\n' http://localhost:4567/
   git worktree add ../waterpark-i14-b checkpoint/i15
   git -C ../waterpark-i14-b checkout checkpoint/i14 -- access/scripts/render-delta
   export TF_VAR_floci_endpoint=http://localhost:4567
   terraform -chdir=../waterpark-i14-b/access/envs/prod init
   terraform -chdir=../waterpark-i14-b/access/envs/prod apply -auto-approve
   unset TF_VAR_floci_endpoint
   ```

   `18 added` in the second container. Now the same edit in both
   worktrees. Change the description on `site-publisher` in
   `access/envs/prod/iam_role.site_publisher.tf` from
   `Builds the site and writes it to the site bucket.` to
   `Builds the site and writes it to the site bucket, on every push to main.`
   in this worktree and in `../waterpark-i14-b`, then plan both.

   ```sh
   terraform -chdir=access/envs/prod plan -out=tfplan4
   terraform -chdir=access/envs/prod show -json tfplan4 > plan-a.json
   TF_VAR_floci_endpoint=http://localhost:4567 terraform -chdir=../waterpark-i14-b/access/envs/prod plan -out=tfplan
   terraform -chdir=../waterpark-i14-b/access/envs/prod show -json tfplan > plan-b.json
   access/scripts/plan-digest plan-a.json
   access/scripts/plan-digest plan-b.json
   for f in plan-a.json plan-b.json; do jq -c '.resource_changes[] | select(.change.actions == ["update"]) | .change.before | {create_date, unique_id}' $f; done
   access/scripts/plan-digest --normalise plan-a.json | jq -c '.resource_changes[] | {address, actions, after}'
   ```

   `1 to change` in both, then one digest printed twice, then two
   `before` values that differ in both fields, then an after-value that is
   only `description`. Each container created its own `site-publisher` at
   its own moment with its own id, an in-place update copies every
   unchanged attribute forward, and the digest keeps only what changes.
   Now read what the digest did before lesson 11 fixed it.

   ```sh
   git show checkpoint/i10:access/scripts/plan-digest > old-digest
   bash old-digest plan-a.json
   bash old-digest plan-b.json
   ```

   Two different strings for one change. That is what refused the apply of
   pull request 89 on `main`, the first in-place update this pipeline ever
   merged, and the apply job's log has the diff, `create_date` and
   `unique_id` and nothing else. The PR job and the apply job each build
   the same base in their own container by design, and a digest that
   remembered the container would refuse every update forever.

7. Rename a role, and read what a replacement looks like. Put the description back in both worktrees, then in this one change `name = "site-publisher"` to `name = "site-publisher-v2"` and plan.

   ```sh
   terraform -chdir=access/envs/prod plan -out=tfplan5
   terraform -chdir=access/envs/prod show -json tfplan5 > plan5.json
   access/scripts/render-delta plan5.json
   ```

   The plan says `must be replaced` on the role and every grant policy,
   with `# forces replacement` beside `name`, and the delta ends with a
   section the earlier lessons never printed.

   ```
     Replacements. These are destroyed and created again under the same
     address, and on IAM that changes an ARN underneath whatever trusts it.
     A replacement waits for a person, and the PR job says so.
       ! module.site_publisher.aws_iam_policy.grant["list-waterpark-site"]   forced by name
       ! module.site_publisher.aws_iam_policy.grant["read-waterpark-artifacts"]   forced by name
       ! module.site_publisher.aws_iam_policy.grant["write-waterpark-artifacts"]   forced by name
       ! module.site_publisher.aws_iam_policy.grant["write-waterpark-site"]   forced by name
       ! module.site_publisher.aws_iam_role.this[0]   forced by name
       ! module.site_publisher.aws_iam_role_policy_attachment.grant["list-waterpark-site"]   forced by policy_arn, role
       ...
   ```

   Read the top of the same delta. It lists `site-publisher-v2` with four
   grants marked `!` and a `Principals` block with `! site-publisher-v2`,
   which read quickly says a new role with four grants, which is true and
   is not the story. The story is that
   `site-publisher` stops existing, its ARN with it, and the GitHub Actions
   trust anchor that names its subject, the CODEOWNERS line derived from
   its file, and anything live that trusts the old ARN all break at apply.
   The replacements section is the delta refusing to let a rename read as a
   grant. In the PR job that section lands in the summary under
   `### Replacement: this plan destroys and recreates` and the pull request
   gets the `replacement` label, which is the person the replacement waits
   for being told. Do not apply it. Put the name back.

8. Say the two things the digest cannot say, out loud. It proves the plan did not move between approval and apply. It does not prove who produced the plan, because a PR job's Terraform is whatever the pull request's checkout runs, and a pull request can change the workflow, which is why lesson 6 routes that path to platform review and labels it. An attested build checked before apply would close that, nobody has scheduled it, and property XIV is half closed until someone does. And it does not prove the apply landed on the account the reviewer imagined, because on this repository the apply job's account is a container it built from the base commit, which proves the digest check and nothing about a real account, which is lesson 6's honesty line and still true.

9. Take the step 3 grant back out of `iam_role.site_publisher.tf`, so the leaf file is the checkpoint's again, then compare with the reference repo and tear down both worktrees and the second container.

   ```sh
   git add -A access .github
   git diff --cached --stat checkpoint/i14 -- access .github ':!*README.md'

   terraform -chdir=access/envs/prod destroy -auto-approve
   TF_VAR_floci_endpoint=http://localhost:4567 terraform -chdir=../waterpark-i14-b/access/envs/prod destroy -auto-approve
   docker rm -f wp-i14-b
   cd .. && git -C waterpark-i14 worktree remove --force ../waterpark-i14-b
   ```

   Nothing printed means the delta and the workflow are the reference's
   and the leaf file is back to what the checkpoint holds. The saved plans
   and the old digest are ignored by name. If the diff names
   `iam_role.site_publisher.tf`, the grant from step 3, the description from
   step 6 or the name from step 7 is still in it. If you started your own
   container in step 1, `docker rm -f wp-i14-floci` as well.

## Self-paced

The whole lesson runs on the emulator and makes no model turn, and it needs two containers for step 6, which is the one step that cannot be shown with one. The Start-here stack's Floci serves as the first, enforcement off, because nothing here is refused by IAM.

What the emulator proves and what it does not. Every plan, digest and refusal here is Terraform and a script reading Terraform's own JSON, so they are the same on a real account. What the emulator cannot show is the two jobs running, which happen on GitHub on every access pull request, and the page reads their steps instead. Lesson 6's status row records the digest check running for real on pull request 71 and its merge, and lesson 11's records the refusal on pull request 89 and the fix.

The `prod` environment on this repository has no required reviewers. That is a fact about the settings and not about the design, and the page says it because a lesson that claimed a gate the settings do not hold would be teaching the diff rather than the change.

## Live

Twenty five minutes, in three moves, and the room needs steps 4, 6 and 7.

Open on step 4 with the digest from step 3 on the projector as the thing the room has just approved. Tag the role from a second window, replan, and let the room watch the string change and the diff name the tag. The line to say is that the reviewer approved two creates and the apply would have done three, and nobody was ever asked about the third.

Then step 6 on two containers side by side, and the two `before` values with their different ids, and then one digest. Then the old digest and two strings, and say that this refused a real merge on this repository's `main` on 2026-09-10, and that the log is in the status page's row for lesson 11. A digest that remembers the machine it was computed on is a digest that refuses every update forever, and the honest fix was to hash the change and not the world around it.

Close on step 7, and read the top of the delta first, `site-publisher-v2` gains four grants, and ask the room to approve it. Then scroll to the replacements section. The honesty line is that the delta was telling the truth both times, and that the second truth is the one a reviewer is paid to read.

Live, the same pull request runs both jobs on GitHub, the replacement label lands on it, and a maintainer who has added required reviewers to the `prod` environment watches the apply job wait for them.

## Further reading

- [access/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md), "Lesson 6, one path to prod" and "Lesson 14, approve the change, not the diff"
- [access/scripts](https://github.com/INTENTIUS/waterpark/blob/main/access/scripts/README.md), `plan-digest` and `render-delta`
- [PR automation](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/pr-automation.md), why no standing apply server
- [The AWS desk](../../docs/aws-desk.md), the digest
- [Prescriptions](../../docs/prescriptions.md), 14
- [Decisions](../../docs/decisions.md), 6, 23, 24, 31, 35 and 63
- [Lesson 6, one path to prod](06-one-path-to-prod.md), the two jobs
- [Lesson 9, federation trust](09-federation-trust.md), the merge whose apply was refused
