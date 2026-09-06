---
title: "Drift"
id: "I7"
lesson: 7
weight: 7
summary: "A scheduled plan detects drift and a PR restores the declared state."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i7-drift"
# card. empty renders as TODO
goal: "Watch the declared estate against the live one, move the account by hand the way a person in a console would, read a drift report that names the attribute and prints declared beside live, watch a widened trust policy route to a page while a detached policy and a retagged role route to a pull request, and say out loud why restoring is automatic and adopting is not."
done_when: "`access/scripts/drift` exits 0 against the applied estate, exits 2 after `aws iam detach-role-policy` and `aws iam tag-role` with one finding per resource naming the attribute and printing declared beside live, a widened `assume_role_policy` on `desk-operator` comes back `page` while the other two come back `pr`, `access/scripts/reconcile --dry-run` plans one PR per `pr` finding on a branch derived from the address, under the cap of five read out of `access/baseline`, and prints the `page` finding for a human instead of filing it, and `access/scripts/drift` exits 0 again after `terraform apply` puts the account back."
restart_from: "checkpoint/i6"
properties: ["XI", "XIII"]
closes: ["P11"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "35 min"
  needs:
    - "a water park checkout with the tags fetched"
    - "Docker running"
    - "the patched Floci image ghcr.io/lex00/floci:iam-boundary"
    - "terraform 1.9 or newer"
    - "tflint from terraform-linters/tap/tflint, because just access-init runs it"
    - "jq"
    - "gh, to count open reconcile PRs. Without it the dry run says so and carries on"
    - "just access-init run once per clone"
    - "lesson 6 finished or at least read"
---

## Context

- The estate is what the account holds, not what the repo says, and the gap between the two has a name. Accessible Ops XI says the live system is the truth, and lesson 4 named the cost of a tool that hosts its own state. This lesson is the mitigation half of decision 32.
- `drift` runs `terraform plan -detailed-exitcode` over every root that applies, which is `envs/prod` and any satellite root that exists. Exit 0 means every root matches, exit 2 means at least one moved, and exit 1 means the watch itself broke, which is a different thing and is reported as such. `identity/` and `github/` are not on the list, because there is nothing on a laptop for them to have drifted from.
- The plan JSON is read down to resources and attributes, so a finding names the attribute and prints what the repo declares beside what the account holds. A report that said only "site-publisher changed" would send somebody to a console to find out what.
- Severity routes on blast radius rather than on resource type for its own sake. A security group or a changed `assume_role_policy` is `page`, because a widened group is reachable the moment it lands and a changed trust policy changes who may become a principal, which revoking a grant cannot undo. Everything else is `pr`.
- Expired grants come through the same run, read from the persona module's `grants` output, because a grant whose `DateLessThan` has passed grants nothing while the repo still says it exists. That closes the second half of prescription 3, which lesson 2 opened.
- `reconcile` turns a report into the reconcile plan under decision 28's rules, and every rule is held by a mechanism rather than by a prompt. Ownership is structural, because a plan over a root this repo declares cannot contain a resource nobody here declared. One PR per resource and no second while one is open are both lookups, because the branch name is derived from the resource address. The cap is `watcher_max_open_prs` read out of `access/baseline`, which is the five lesson 5 exported.
- Restoring is automatic and adopting is not. A reconcile PR carries no file change at all, because the repo already says what the resource should be, so merging it is what runs the apply that puts the account back. If the change in the account was the right one, nobody merges it and a human edits the file that declares the resource. A watcher that could adopt would be a watcher that ratifies whatever happened.
- The scheduled job proves less than it looks like it proves. `.github/workflows/drift.yml` starts an empty Floci, applies the estate into it and then asks whether the estate matches, so it always does. A green run means the declared estate converges and stays converged and it means nothing about a real account, where drift comes from a human in a console (decision 58). That is why this lesson seeds the drift by hand.
- The watcher that opens reconcile PRs on a schedule is lesson 13. This lesson owns the detection and the rules.

## Do

Lesson 6 made the pull request the only way in. This lesson asks the harder question, which is what happens when something changes the account without going through it at all.

1. Start from the checkpoint lesson 6 left, bring Floci up, and apply the estate so there is something to drift from.

   ```sh
   git fetch origin --tags
   git worktree add ../waterpark-i7 checkpoint/i6
   cd ../waterpark-i7
   just access-init

   docker run -d --name wp-i7-floci -p 4566:4566 \
     -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
     ghcr.io/lex00/floci:iam-boundary

   curl -s --retry 15 --retry-all-errors --retry-delay 1 \
     -o /dev/null -w '%{http_code}\n' http://localhost:4566/

   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod apply -auto-approve
   ```

   `200`, then `Apply complete! Resources: 22 added, 0 changed, 0 destroyed.`

2. Take the two scripts and the scheduled job. This lesson is about using a watch and about the rules it follows, so the watch itself comes from the reference repo rather than being typed.

   ```sh
   git checkout checkpoint/i7 -- \
     access/scripts/drift \
     access/scripts/reconcile \
     access/scripts/README.md \
     .github/workflows/drift.yml
   ```

   `drift` is the plan loop plus the JSON reading plus the severity routing.
   `reconcile` is decision 28's rules, each one held by a mechanism. `README.md`
   under `scripts/` is where the asymmetry is written down, which is the thing
   this lesson exists to make you believe. `drift.yml` is the schedule, and
   step 3 has a fix for it.

   Read the two headers before running anything.

   ```sh
   head -25 access/scripts/drift
   head -32 access/scripts/reconcile
   ```

3. Fix the wait loop in the scheduled job, because it is wrong and it is wrong in an instructive way. Open `.github/workflows/drift.yml` and find the `Wait for Floci` step.

   ```sh
   code=$(curl -s -o /dev/null -m 2 -w '%{http_code}' "$FLOCI_ENDPOINT/" || echo 000)
   [ "$code" != "000" ] && { echo "Floci answered with $code"; exit 0; }
   ```

   Try that reasoning against a port nothing is listening on.

   ```sh
   code=$(curl -s -o /dev/null -m 2 -w '%{http_code}' http://localhost:4599/ || echo 000)
   echo "[$code]"
   ```

   It prints `[000000]`. curl writes `%{http_code}` as `000` on a connection
   failure and then exits non-zero, so the `|| echo 000` appends a second
   `000` and the guard compares `000000` against `000` and lets the loop
   through. The job would carry straight on to a Terraform apply against
   nothing. Replace the two lines with the form `.github/workflows/access.yml`
   already carries.

   ```sh
   code=$(curl -s -o /dev/null -m 2 -w '%{http_code}' "$FLOCI_ENDPOINT/" || true)
   [ -n "$code" ] && [ "$code" != "000" ] && { echo "Floci answered with $code"; exit 0; }
   ```

   ```sh
   code=$(curl -s -o /dev/null -m 2 -w '%{http_code}' http://localhost:4599/ || true)
   echo "[$code]"
   ```

   `[000]`, and the loop waits. This is the same failure the retrying curl in
   step 1 exists to avoid, one layer down. A wait loop that cannot fail is a
   wait loop that does not wait.

4. Watch a converged estate, so the interesting output later has something to be interesting against.

   ```sh
   access/scripts/drift
   echo $?
   ```

   ```text
   drift report, 2026-09-06T04:46:41Z

     every watched root matches the account
   ```

   and `0`. That is `terraform plan -detailed-exitcode` over `envs/prod`, with
   a refresh, so it is the account being read rather than the state file being
   trusted.

5. Move the account underneath it, the way a person in a console would. Nothing here goes through a pull request, which is the point.

   ```sh
   export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1

   aws --endpoint-url http://localhost:4566 iam detach-role-policy \
     --role-name site-publisher \
     --policy-arn arn:aws:iam::000000000000:policy/site-publisher-read-waterpark-artifacts

   aws --endpoint-url http://localhost:4566 iam tag-role \
     --role-name runner-builder --tags Key=owner,Value=intruder
   ```

   One of those takes access away and one of them changes who is on the hook
   for a role. Both are two seconds of work in a console and neither leaves a
   trace anybody reads.

   ```sh
   access/scripts/drift
   echo $?
   ```

   ```text
   drift report, 2026-09-06T04:47:12Z

     [pr] envs/prod  module.runner_builder.aws_iam_role.this[0]
         update
         tags
           declared {"owner":"platform","persona":"service","teams":"platform"}
           live     {"owner":"intruder","persona":"service","teams":"platform"}
         tags_all
           declared {"env":"prod","managed_by":"terraform","owner":"platform","persona":"service","repo":"INTENTIUS/waterpark","teams":"platform"}
           live     {"env":"prod","managed_by":"terraform","owner":"intruder","persona":"service","repo":"INTENTIUS/waterpark","teams":"platform"}

     [pr] envs/prod  module.site_publisher.aws_iam_role_policy_attachment.grant["read-waterpark-artifacts"]
         create
         policy_arn
           declared arn:aws:iam::000000000000:policy/site-publisher-read-waterpark-artifacts
           live     absent
         role
           declared site-publisher
           live     absent

     2 finding(s), 0 of them paging
   ```

   and `2`. Read what the report gives you that an exit code does not. The
   attribute is named, the declared value sits above the live one, and the
   detached policy comes back as an attachment that will be created with
   `absent` on the live side. Nobody has to open a console to find out what
   moved.

   Both are `pr`, because neither is a security group and neither touched a
   trust policy.

6. Read the reconcile plan. Nothing is opened, because `--dry-run` is the default.

   ```sh
   access/scripts/reconcile --dry-run
   ```

   ```text
   reconcile plan

     cap            5 open reconcile PRs at once (access/baseline)
     open already   0
     gh             authenticated

     file   module.runner_builder.aws_iam_role.this[0]
            branch desk/drift/envs-prod/module-runner-builder-aws-iam-role-this-0
            tags, tags_all
     file   module.site_publisher.aws_iam_role_policy_attachment.grant["read-waterpark-artifacts"]
            branch desk/drift/envs-prod/module-site-publisher-aws-iam-role-policy-attachment-grant-r
            policy_arn, role

     2 to file, 0 already open, 0 held by the cap

     This was the dry run. Nothing was branched, committed, pushed or opened.
     Add --open with a gh that can write to file them.
   ```

   The `gh` line is a live probe rather than a claim. Without `gh` on the path
   it reads `gh             not available, so nothing can be opened from here`,
   the plan still prints and nothing else changes, because `--dry-run` opens
   nothing either way.

   Four of decision 28's rules are visible in that output. The cap of five is
   the constant lesson 5 put in `access/baseline`, read out of the applied
   outputs rather than restated here, so a student who changes that one number
   watches this line move. `open already` is a live count against the code
   host. One PR per resource is the branch name, which is derived from the
   resource address, so a second finding for the same resource lands on a
   branch that already exists and is skipped rather than remembered. And
   ownership needed no filter at all, because a plan over a root this repo
   declares cannot contain a resource nobody here declared.

7. Widen a trust policy and watch the routing change.

   ```sh
   aws --endpoint-url http://localhost:4566 iam update-assume-role-policy \
     --role-name desk-operator \
     --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"*"},"Action":"sts:AssumeRole"}]}'

   access/scripts/drift --json | jq -c '.findings[] | {severity, address}'
   ```

   ```text
   {"severity":"page","address":"module.desk_operator.aws_iam_role.this[0]"}
   {"severity":"pr","address":"module.runner_builder.aws_iam_role.this[0]"}
   {"severity":"pr","address":"module.site_publisher.aws_iam_role_policy_attachment.grant[\"read-waterpark-artifacts\"]"}
   ```

   Same estate, same watch, and one of the three now wakes somebody up. The
   line that just changed says any AWS principal may become `desk-operator`.
   A tag that reads `intruder` is wrong and can wait for a review cycle. A
   trust policy that trusts everyone is reachable now, and no later revoke
   undoes who assumed the role in the meantime.

   ```sh
   access/scripts/reconcile --dry-run
   ```

   ```text
     These page a human and are not filed as PRs.
       envs/prod  module.desk_operator.aws_iam_role.this[0]
         assume_role_policy
   ```

   and then the same two files as before, still two. The watch refuses to turn
   a page into paperwork, because a pull request sitting in a queue is the
   wrong response to a trust policy that is open right now.

8. Say the asymmetry out loud, because it is the thing that makes the rest of
   this defensible. Open `access/scripts/README.md` and read the section on
   it, then put the account back.

   ```sh
   terraform -chdir=access/envs/prod apply -auto-approve
   access/scripts/drift
   echo $?
   ```

   `Apply complete! Resources: 1 added, 2 changed, 0 destroyed.`, then `every
   watched root matches the account` and `0`.

   That apply is what a merged reconcile PR would have run. The PR carries no
   file change at all, because the repo already said what those three
   resources should be, so its whole job is to be merged. Restoring the estate
   is a merge.

   Now the other direction. Suppose the tag really should read `intruder`,
   because somebody renamed a team. Nothing automatic happens and nothing
   should. The reconcile PR does not get merged, and a human edits
   `access/envs/prod/iam_role.runner_builder.tf` so the repo says it too.
   Changing what the estate is takes a diff somebody wrote and somebody
   reviewed, through the one path lesson 6 built.

   The two directions are deliberately unequal in effort, and that inequality
   is the whole design. A watcher that could adopt would be a watcher that
   ratifies whatever happened, which is the opposite of managing what you
   declare.

9. Look at the scheduled job, and at what it does not prove.

   ```sh
   sed -n '1,30p' .github/workflows/drift.yml
   ```

   Weekdays at six in the morning UTC, the same cron the desk teammate runs
   on, and on demand. Then read the comment at the top of the file, which says the job
   starts an empty Floci, applies the estate into it and then asks whether the
   estate matches, so it always does. A green run there means the declared
   estate converges and stays converged. It means nothing about an account
   where a human has a console, which is the only place the drift in step 5
   could ever come from. The job's own summary says so too, so a green check
   mark on a Monday morning is not read as more than it is.

10. Compare with the reference repo, then tear down.

    ```sh
    git add -A access .github
    git diff --cached --stat checkpoint/i7 -- access .github \
      ':!access/README.md' ':!.github/workflows/drift.yml'

    terraform -chdir=access/envs/prod destroy -auto-approve
    docker rm -f wp-i7-floci
    ```

    Nothing printed means every file matches the reference file. Two
    exclusions, and both are deliberate. `access/README.md` carries the
    lesson 7 and lesson 8 sections, which this lesson does not have you write.
    `.github/workflows/drift.yml` is excluded because the tag was cut before
    the wait loop in step 3 was fixed, so the reference file still carries the
    `|| echo 000` form and yours does not. That is the one place in this course
    where your tree is deliberately ahead of the checkpoint.

## Self-paced

All of it runs on a laptop, and this is the lesson where that matters most,
because the thing being taught is what an emulator can and cannot stand in
for.

What Floci shows honestly. `terraform plan -detailed-exitcode` with a refresh
reads the account rather than the state file, and Floci answers the reads.
A detached policy, a changed tag and a rewritten trust policy all come back
through the plan with the right attributes and the right exit code, which
plan phase 0 confirmed before this lesson was written. So the detection half
of prescription 11 is real here.

What it cannot show. Prescription 11's check names a hand-edited security
group, and the estate declares none, because the provider block overrides
`iam`, `sts` and `s3` and neither EC2 nor its security groups is one of them.
Declaring one would make the credential-free plan reach for a real account,
which the solo path may not do. So `no-open-ingress` and
`sg-reference-not-cidr` are still warnings with fixtures and nothing live to
ratchet against, and the security group half of the severity routing is
covered by the `assume_role_policy` case in step 7, which is the other `page`
in the same rule. The typed network layer arrives with the account that can
hold it.

The scheduled job is always clean and the lesson says so rather than shipping
a green check mark that means less than it looks like (decision 58). It
applies into a container nothing else touches, so a green run proves
convergence. Drift comes from a human in a console, which is why step 5 is a
human in a console.

`reconcile --open` is not run here. It needs a `gh` that can write and it
would open real pull requests against a real repository, so `--dry-run` is
the default and the lesson stops at the plan. Everything the rules do is
visible in the dry run, because the cap, the branch names and the page refusal
are all decided before anything is opened.

Expired grants surface in the same run and none of the grants in `envs/prod`
carries an `expires`, so that path shows nothing here. It reads the persona
module's `grants` output, which is the same output lesson 2 wrote, and a
student who wants to see it can set `expires` on a grant to a past timestamp
and re-run the watch.

## Live

Twenty minutes, and the room only needs two of the steps.

Run step 4 first, so the room has seen the boring answer. Then run the two
console commands in step 5 in front of them and say what you are doing while
you do it. This is somebody with console access and a good reason, on a
Friday. Then run the watch and read the report out loud, especially the
declared line above the live line. The question to ask before showing the
reconcile plan is what should happen next, and let the room answer before the
script does.

Then step 7, and change one thing. Widen the trust policy first without
telling them what it does, and ask whether that finding should be handled the
same way as a wrong tag. The answer they reach is the severity rule, and it is
better arrived at than read.

Two honesty lines belong in this room. The first is the scheduled job. It runs
on a container it filled itself, so it is always green, and green there means
the estate converges rather than that nothing happened. We seed the drift by
hand for exactly that reason, and the job says it in its own summary. The
second is the asymmetry, and it is worth saying as a decision rather than as a
feature. Putting the estate back is a merge. Changing what the estate is takes
a diff somebody wrote. We could have built a watcher that adopted the console
change into the file automatically, and we did not, because that watcher
ratifies whatever happened.

Live, the same scripts run against a real sandbox account with
`-var floci=false`, somebody in the room widens a security group in the
console, and the watch flags it as a page within the cycle.

## Further reading

- [access/scripts](https://github.com/INTENTIUS/waterpark/blob/main/access/scripts/README.md), the asymmetry and where each Rounds rule is enforced
- [access/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md), "Lesson 7, drift"
- [The estate](../../docs/estate.md), scenario 2
- [The AWS desk](../../docs/aws-desk.md), the watch and the cron it shares
- [Design, agentic](../../docs/design/agentic.md), the watcher that files these in lesson 13
- [Prescriptions](../../docs/prescriptions.md), 3 and 11
- [Decisions](../../docs/decisions.md), 28, 32, 40 and 58
- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A8
