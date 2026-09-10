---
title: "Offboard and the access review"
id: "I11"
lesson: 11
weight: 11
summary: "Offboarding removes every reference in one PR and the review reads the estate."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i11-offboard-and-access-review"
# card. empty renders as TODO
goal: "Ask the account who can reach a bucket and what expires, and watch a policy somebody attached in a console show up in the answer because nothing here reads a file. Read the quarterly review artifact and what it says it did not see. Then take a course author out of the estate in one change with nothing left naming them, take a workload out for real with the account read before and after, and put both back from the checkpoint."
done_when: "`access/scripts/whocan waterpark-artifacts` lists five grants read from the account including `runner-builder` from the satellite root, and a sixth line naming a policy attached by hand as not written by the repo until it is detached, `access/scripts/access-review` prints an artifact whose Principals table has five rows with `waterpark-runner` in the From column and whose unused-access section is a named skip, `access/scripts/offboard course-author` leaves `terraform -chdir=access/identity validate` green and the grep for the name empty, `access/scripts/offboard desk-operator` plans five to destroy and after the apply `aws iam get-role --role-name desk-operator` returns `NoSuchEntity` while `access/scripts/drift` exits 0, and both principals are back from `checkpoint/i10` so the compare is silent."
restart_from: "checkpoint/i10"
properties: ["IX", "XIII"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "35 min"
  needs:
    - "a water park checkout with the tags fetched"
    - "Docker running"
    - "the patched Floci image ghcr.io/lex00/floci:iam-boundary"
    - "terraform 1.9 or newer"
    - "tflint from terraform-linters/tap/tflint"
    - "jq"
    - "just access-init run once per clone"
    - "lesson 10 finished or at least read"
---

## Context

- Everything on the read side reads the account and never a file (decision 42). `whocan`, `expiring` and `access-review` go through `get-role`, `list-attached-role-policies`, `list-policy-tags` and `get-policy-version`, so a role the satellite created is in every answer whichever repo declared it, and so is a policy somebody attached in a console. That closes the cross-repo reachability question by not needing an answer to it.
- The grant's access level and its resource are read off the policy name the persona module writes, `<principal>-<access>-<resource>`, and the expiry, the reason and the break-glass marks off its tags. A policy whose name does not follow that convention was not written by the module, and the scripts say so rather than parsing it into a level it never had.
- Offboard removes a principal's file and every reference to it in one change. The declared side is the leaf file, the output lines that name it, the variable a human's assignment reads, and the CODEOWNERS line derived from it. `terraform plan` is the proof, because a dangling reference fails a plan, and a grep for the name outside a comment is the second proof. One PR, one apply, zero references (estate.md scenario 4).
- The preview reads the account for what the apply will take away, the role, its boundary and its attached policies, so the reviewer of the PR knows what leaves. For `access/identity` the preview says the root is live only rather than pretending to read Identity Center from a laptop (decision 27).
- The review is an artifact a compliance reviewer accepts. It lists every principal and what it can reach, what expires ninety days out, unused access when an analyzer answers, humans as declared because Identity Center is read only live, the rotation check from lesson 9, and what it did not see. It runs quarterly on `.github/workflows/access-review.yml` against a Floci the job filled itself, which proves the shape and nothing about a real account (decision 61).
- The satellite's roles are in the review because the account holds them. The module ref the satellite pins is in its HCL, and the review reads no HCL, so the artifact says it did not see that rather than reading it anyway.
- The read-only queries stay scripts under `access/scripts/` and the desk's estate pane calls them. There is no separate Q&A page. `LIVE=true` drops the endpoint override so the same scripts read a real account as the security account's reviewer.
- Two principals leave in this lesson and both come back. `course-author` is the scenario, a human whose root is live only, so the proof is validate and grep. `desk-operator` is the workload the account can show leaving and returning, so the proof is a plan, an apply and a read. Restoring from the checkpoint is what makes the compare at the end silent.

## Do

Lesson 10 gave somebody access for two hours. This lesson is about the two questions a reviewer asks every quarter, who can reach what, and is everyone here still supposed to be, and about answering the second one with a deletion.

1. Start from the checkpoint lesson 10 left, bring Floci up, and apply central and then the satellite.

   ```sh
   git fetch origin --tags
   git worktree add ../waterpark-i11 checkpoint/i10
   cd ../waterpark-i11
   just access-init

   docker run -d --name wp-i11-floci -p 4566:4566 \
     -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
     ghcr.io/lex00/floci:iam-boundary

   curl -s --retry 15 --retry-all-errors --retry-delay 1 \
     -o /dev/null -w '%{http_code}\n' http://localhost:4566/

   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod apply -auto-approve
   terraform -chdir=access/satellites/waterpark-runner init
   terraform -chdir=access/satellites/waterpark-runner apply -auto-approve
   ```

   `200`, then `Resources: 18 added` and `8 added`. If `just access-init`
   printed `All plugins are already installed`, that is tflint's plugin cache
   and it is fine.

2. Bring in the read side. Five scripts and a workflow, and none of them is what the lesson teaches, so take them from the reference tree.

   ```sh
   git checkout checkpoint/i11 -- \
     access/scripts/lib-live.sh \
     access/scripts/whocan \
     access/scripts/expiring \
     access/scripts/offboard \
     access/scripts/access-review \
     access/scripts/rotation \
     .github/workflows/access-review.yml
   ```

   `lib-live.sh` is the read side the other four share, sourced and never
   run. It talks to the account, folds a role's tags and its attached
   policies with their tags and documents into one object per role, and
   reads the level and the resource off a policy name. `rotation` changes by
   one line, so that `LIVE=true` is the one switch every read script honors.
   Read the header of each script before running it.

   ```sh
   head -12 access/scripts/whocan
   head -14 access/scripts/offboard
   head -12 access/scripts/access-review
   ```

3. Ask who can reach the artifacts bucket.

   ```sh
   export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
   access/scripts/whocan waterpark-artifacts
   ```

   ```text
   who can reach waterpark-artifacts, read from the account at 2026-09-10T20:20:14Z

     site-publisher  read
         persona service, owner platform, from prod
         expires never
         Picks up the checkpoint bundle a lesson restarts from.
     desk-operator  list
         persona service, owner platform, from prod
         expires 2027-01-01T00:00:00Z
         Direct mode lists the estate. Same expiry as the read beside it.
     desk-operator  read
         persona service, owner platform, from prod
         expires 2027-01-01T00:00:00Z
         Direct mode reads the estate. Expires so the desk's read has to be renewed deliberately.
     runner-builder  write
         persona service, owner runner, from waterpark-runner
         expires never
         Publishes the build artifacts that go with the image.
     runner-builder  list
         persona service, owner runner, from waterpark-runner
         expires never
         Reads what it already published before pushing again.
   ```

   Five grants, and the last two come from the satellite. Nothing in this
   script opened `access/satellites/`. It asked the account for every role
   and every attached policy, and `runner-builder` is in the account because
   lesson 8 applied it there, so it is in the answer. The `from` column is a
   tag the satellite's provider wrote, and it is the only thing that says
   which root declared the role.

   Now attach something by hand, the way a person in a console would, and ask
   again.

   ```sh
   aws --endpoint-url http://localhost:4566 iam create-policy \
     --policy-name console-read \
     --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["s3:GetObject"],"Resource":"arn:aws:s3:::waterpark-artifacts/*"}]}' \
     --query Policy.Arn --output text
   aws --endpoint-url http://localhost:4566 iam attach-role-policy \
     --role-name on-call \
     --policy-arn arn:aws:iam::000000000000:policy/console-read

   access/scripts/whocan waterpark-artifacts | grep -A2 on-call
   ```

   ```text
     on-call  attached policy console-read, not written by the repo
         persona service, owner platform, from prod
         expires never
   ```

   A sixth line. The script could not read a level off the name, because the
   persona module did not write that name, and it says so instead of guessing.
   This is the whole reason the review reads the account. A review built from
   the HCL would have said the on-call holds nothing, and it would have been
   describing the repo rather than the estate. Lesson 7's watch sees the same
   thing from the other side.

   ```sh
   access/scripts/drift | head -8
   ```

   The attachment shows as drift on `on-call`, because a plan over the root
   that declares the role sees a policy the file does not. Detach it and
   delete it, so the rest of the lesson reads a clean account.

   ```sh
   aws --endpoint-url http://localhost:4566 iam detach-role-policy \
     --role-name on-call --policy-arn arn:aws:iam::000000000000:policy/console-read
   aws --endpoint-url http://localhost:4566 iam delete-policy \
     --policy-arn arn:aws:iam::000000000000:policy/console-read
   access/scripts/drift | tail -1
   ```

   `every watched root matches the account`.

4. Ask what expires.

   ```sh
   access/scripts/expiring
   echo $?
   access/scripts/expiring --within 120
   echo $?
   ```

   The first prints `nothing is past its expiry or inside the window.` and
   `0`, because the default window is thirty days. The second prints the two
   `desk-operator` grants as `[soon]` with their `2027-01-01` expiry and exits
   `2`, because they fall inside a hundred and twenty days of the day this
   lesson was written. A grant already past its expiry would print `[past]`
   and it would also be the drift finding lesson 10 showed. Same fact, read
   from the tags here and from the plan there.

5. Read the review. This is the artifact a reviewer accepts, and it is worth reading whole once.

   ```sh
   access/scripts/access-review | tee review.md
   ```

   About nine seconds, because every fact in it is a read. Then the parts
   worth pointing at.

   The Principals table has five rows, and the `From` column reads `prod` on
   four of them and `waterpark-runner` on `runner-builder`. The `Trust` column
   reads `federated` with the exact subject on `site-publisher` and
   `waterpark-apply`, which is lesson 9, and `service` on the rest. The
   `Boundary` column reads `yes` on every row, which is lesson 5, and a row
   reading `none` is a finding.

   The grants table is `whocan` over every resource at once, with the reason
   beside each row, which is where lesson 2's `reason` field was always going.

   `## Unused access` reads `Skipped.` and says why. Access Analyzer's
   unused-access analyzer is what turns "can reach" into "has not reached in
   ninety days", and Floci does not run one, so the section says so rather
   than printing an empty table that looks like a clean bill.

   `## Humans` lists `course-author` and `platform` and says they are listed
   as declared under `access/identity`, not as read, because Identity Center
   is read only live.

   `## What this review did not see` closes it. A resource nobody has
   permission to read, the module ref the satellite pins, and anything since
   the read. A review that does not say what it could not see is a review
   that is asking to be trusted.

   Then the shape the desk reads.

   ```sh
   access/scripts/access-review --json | jq '{principals: (.principals | length), grants: (.grants | length), humans: .humans.declared}'
   ```

   `5`, `8`, and the two names.

6. Offboard the course author. This is estate.md scenario 4, the departure, and the preview is what the PR reviewer reads first.

   ```sh
   access/scripts/offboard --preview course-author
   ```

   ```text
   offboard course-author

   == declared, under access/identity
     delete   access/identity/ssoadmin_permission_set.course_author.tf
     remove   access/identity/outputs.tf:5:    course-author = module.course_author.permission_set_arn
     remove   access/identity/variables.tf, the variable "course_author_group_id" block
     regen    .github/CODEOWNERS, line 20 routes this file today

   == live, in the account
     skip     access/identity is live only. Identity Center runs in the management account and not on a laptop,
              so the permission set and its assignments are read on the live path, not here.

     This was the preview. Nothing was changed. Run without --preview to make the change,
     then terraform -chdir=access/identity plan is the proof.
   ```

   Four references. The leaf file, an output line, a variable block that
   exists only because this human's assignment reads a group id, and a
   CODEOWNERS line the generator derived. The script found the leaf file by
   the layout's own promise, `ssoadmin_permission_set.course_author.tf`, and
   then grepped the root for the module address. The live half is a skip
   with a reason, because reading Identity Center from here would be
   pretending.

   Now make the change.

   ```sh
   access/scripts/offboard course-author

   terraform -chdir=access/identity init -backend=false
   terraform -chdir=access/identity validate
   grep -rn "course.author" access --include='*.tf' .github/CODEOWNERS | grep -v ':[[:space:]]*#'
   access/scripts/check codeowners
   ```

   `deleted`, `edited` twice, `regen`, then
   `none. Nothing under access/ or in CODEOWNERS names course-author outside a comment.`
   Then `Success!`, then nothing from the grep, then
   `ok    .github/CODEOWNERS matches the principal files`. Validate is the
   proof here because the root is live only, and a dangling reference would
   have failed it. Live, `terraform -chdir=access/identity plan` shows the
   permission set and its assignments leaving, the apply removes them, and
   the person's sessions end when their next one is refused.

   Put the author back from the checkpoint, because the estate keeps its
   author and the lesson only borrowed the departure.

   ```sh
   git checkout checkpoint/i10 -- access/identity .github/CODEOWNERS
   access/scripts/check codeowners
   ```

7. Offboard a workload for real, so the account can show it leaving. `desk-operator` is the desk in direct mode, which lesson 12 says is nothing in repo mode, so it is the one this estate can spare for twenty minutes.

   ```sh
   access/scripts/offboard --preview desk-operator
   ```

   ```text
   == live, in the account
     role     arn:aws:iam::000000000000:role/desk-operator
              boundary arn:aws:iam::000000000000:policy/waterpark-estate-boundary
     policy   desk-operator-list-waterpark-artifacts
     policy   desk-operator-read-waterpark-artifacts
     removes  the role, 2 grant policies and their attachments, at apply
   ```

   This time the live half is a read. The role, its boundary, the two grant
   policies, and what the apply takes away. That last line is what a PR
   reviewer approves, and it came from the account rather than from the file
   the PR deletes.

   ```sh
   access/scripts/offboard desk-operator
   terraform -chdir=access/envs/prod plan
   ```

   `Plan: 0 to add, 0 to change, 5 to destroy.`, the role, two policies and
   two attachments, each `(because ... is not in configuration)`. That is the
   proof the preview promised. Nothing else in the root referenced the
   module, or the plan would have failed on it instead of planning.

   ```sh
   terraform -chdir=access/envs/prod apply -auto-approve

   aws --endpoint-url http://localhost:4566 iam get-role --role-name desk-operator
   access/scripts/drift
   echo $?
   access/scripts/access-review | grep -c '^| `'
   ```

   `Resources: 0 added, 0 changed, 5 destroyed.`, then
   `An error occurred (NoSuchEntity) when calling the GetRole operation: The role with name desk-operator cannot be found.`,
   then `every watched root matches the account` and `0`, then `10`, which
   is four principal rows and six grant rows where step 5 counted five and
   eight. One PR, one apply, and the account, the watch and the review all
   agree that nothing named `desk-operator` is left.

   Put it back, which is the same mechanism in reverse. The files come from
   the checkpoint and the apply does the rest.

   ```sh
   git checkout checkpoint/i10 -- \
     access/envs/prod/iam_role.desk_operator.tf \
     access/envs/prod/outputs.tf \
     .github/CODEOWNERS
   terraform -chdir=access/envs/prod apply -auto-approve
   access/scripts/drift | tail -1
   ```

   `Resources: 5 added`, then `every watched root matches the account`.

8. Read the schedule, and what it proves.

   ```sh
   sed -n '1,10p' .github/workflows/access-review.yml
   ```

   The job starts an empty Floci, applies the estate into it, runs the review
   and uploads the artifact for four hundred days. So the artifact is the
   review the declared estate produces, quarterly, and it says nothing about
   a real account, the same honesty lesson 7's drift job carries. Live, the
   same script runs as the security account's reviewer with `LIVE=true`, the
   unused-access section fills, and the humans section is a read rather than
   a listing.

9. Compare with the reference repo, then tear down. Both offboards were restored from the checkpoint, so the only new things are the scripts and the workflow.

   ```sh
   git add -A access .github
   git diff --cached --stat checkpoint/i11 -- access .github ':!*README.md'

   terraform -chdir=access/satellites/waterpark-runner destroy -auto-approve
   terraform -chdir=access/envs/prod destroy -auto-approve
   docker rm -f wp-i11-floci
   ```

   Nothing printed means every file is the reference file. The `README.md`
   files are the only exclusions. If the diff names `identity/` or
   `desk_operator`, one of the two restores in steps 6 and 7 did not run, and
   the checkout line there is the fix.

## Self-paced

The whole lesson runs on Floci, and two things are declared rather than read.

What Floci shows. Every read the scripts make, `list-roles`, `get-role`, `list-attached-role-policies`, `list-policy-tags`, `get-policy-version`, `list-entities-for-policy`, answers on the emulator with the tags and documents the module wrote, so `whocan`, `expiring` and the review are real here. A policy attached by hand appears in all three and in the drift watch. A workload's offboard applies and reads back as `NoSuchEntity`.

What Floci cannot show. Identity Center, so the course author's offboard is proven by validate and grep and the permission set is never planned, and the review lists humans as declared rather than as read. Access Analyzer's unused-access analyzer, so the review's unused-access section is a skip with a reason. Both are named on the artifact and on the page rather than left for a reviewer to discover (decision 27).

The review is nine seconds of reads on a five-role estate and it scales with the number of policies, because every document is fetched. A larger estate caches or paginates, and the job that runs it quarterly has an hour.

## Live

Twenty minutes, in two moves, and the review on the projector for the whole of it.

Open on step 3 with the review's Principals table already on screen. Attach a policy from the console to any role while the room watches, run `whocan` on the resource it names, and let somebody find the new line. Then ask what a review built from the repo would have said. That is decision 42 in one gesture, and it is the reason the review reads the account.

Then step 7, whole. Preview, offboard, plan, apply, `get-role`. The line to say at the preview is that the reviewer of this PR is approving the `removes` line, which came from the account, and not the deletion, which came from the file. The line to say at `NoSuchEntity` is that nothing had to remember to revoke anything, because the principal's whole existence was one file and the file is gone.

Live, the same scripts run with `LIVE=true` as the security account's reviewer, `access/identity` plans for real so the course author's permission set leaves the management account, and the unused-access section names grants nobody has used in ninety days, which is the burndown list lesson 13's watcher turns into PRs.

## Further reading

- [access/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md), "Lesson 11, offboard and the access review"
- [access/scripts](https://github.com/INTENTIUS/waterpark/blob/main/access/scripts/README.md), what each script is for
- [Design, agentic](../../docs/design/agentic.md), the read-side verbs
- [Design, delegation](../../docs/design/delegation.md), cross-repo reachability retired
- [The estate](../../docs/estate.md), scenario 4
- [Decisions](../../docs/decisions.md), 27, 42 and 61
- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A10, A11 and D0
