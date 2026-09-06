---
name: waterpark-i7-drift
description: Walk a student through IAM lesson 7, Drift. Use when they finished IAM lesson 6 and want lesson 7. Brings in access/scripts/drift and reconcile, fixes the wait loop in the scheduled job, seeds drift by hand against Floci with detach-role-policy and tag-role, reads a report that names the attribute and prints declared beside live, widens a trust policy to watch the severity route to a page, reads the reconcile plan under decision 28's rules, and states the asymmetry between restoring and adopting.
---

# water park, IAM lesson 7, Drift

You are walking a student through IAM lesson 7, Drift
(https://intentius.io/waterpark/courses/iam/07-drift/). The outcome is a watch
that compares the declared estate against the live one, a report that names
what moved, a severity rule the student watches fire, a reconcile plan under
rules held by mechanisms, and one sentence they can say about why restoring is
automatic and adopting is not. About 35 minutes.

This lesson never touches a real AWS account. Every command points at
`http://localhost:4566`, `floci` stays at its default of true, and the
`AWS_ACCESS_KEY_ID=test` pair is the throwaway the provider already uses
rather than a credential.

Confirm with the student before creating the worktree, before starting the
Floci container, before writing or copying any file under `access/` or
`.github/`, before each `aws iam` call that changes the account, and before
each apply and the teardown. Those steps are marked **confirm**. Reads run
freely, which is `access/scripts/drift`, `access/scripts/reconcile --dry-run`,
`terraform plan`, `head`, `sed` and `git diff`.

Never run `access/scripts/reconcile --open`. It opens real pull requests
against a real repository. `--dry-run` is the default and it is where this
lesson stops. If the student asks, say `--open` needs a `gh` that can write
and belongs to the watcher in lesson 13.

## 1. Say what this is

In two or three sentences say this is lesson 7 of the IAM course, that
lesson 6 made the pull request the only way into the estate, and that this
lesson asks what happens when something changes the account without going
through it at all. Say that the estate is what the account holds rather than
what the repo says, which is Accessible Ops XI, and that lesson 4 named the
state file as a cost while this lesson is the mitigation. Link the lesson page
above.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Also read `.waterpark/profile.json` at the checkout root if it exists. A
profile file is a claim from a previous run and the check's live calls are the
truth, so when they disagree believe the check. If `completed` does not carry
`"i6"`, say lesson 6 is where the apply role and the check stack come from,
and offer to run this anyway since the checkpoint carries lesson 6's work.

Require `waterpark.checkout` true and `tools.docker.installed` true. The check
does not report `terraform`, `jq`, `tflint` or `gh`, so ask for those directly.

```sh
terraform version
jq --version
tflint --version
gh auth status
```

Terraform 1.9 or newer. `jq` is what `drift` and `reconcile` read the plan
JSON with, and neither runs without it. No stage in this lesson runs tflint,
but step 3's `just access-init` is `tflint --init`, so the recipe fails without
it. `gh` is what `reconcile` counts open reconcile PRs with. Without it the
dry run still works and its third line reads
`gh             not available, so nothing can be opened from here` rather than
`gh             authenticated`, so say that before the student reads it as a
mistake.

Note the check's `floci.reachable`. It is usually false, because this lesson
starts its own container in step 3. If it is already true, ask whether that is
the compose stack from `just up` or a leftover from lesson 6, and prefer a
fresh container rather than a second one on the same port. A Floci carrying
lesson 6's estate would make step 4 report drift it should not.

## 3. The starting point

**confirm**, then

```sh
git fetch origin --tags
git worktree add ../waterpark-i7 checkpoint/i6
cd ../waterpark-i7
just access-init
```

Every command after this runs from `../waterpark-i7`.

**confirm** again, then start Floci.

```sh
docker run -d --name wp-i7-floci -p 4566:4566 \
  -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
  ghcr.io/lex00/floci:iam-boundary

curl -s --retry 15 --retry-all-errors --retry-delay 1 \
  -o /dev/null -w '%{http_code}\n' http://localhost:4566/
```

The curl prints `200`. Re-run `bash skills/start/check.sh` and require
`floci.reachable` true before going on.

**confirm**, then apply the estate, because a watch needs something to watch.

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod apply -auto-approve
```

`Apply complete! Resources: 22 added, 0 changed, 0 destroyed.`

## 4. The lesson

### 4a. Take the watch and the schedule

**confirm** before writing files, then

```sh
git checkout checkpoint/i7 -- \
  access/scripts/drift \
  access/scripts/reconcile \
  access/scripts/README.md \
  .github/workflows/drift.yml
```

This lesson is about using a watch and about the rules it follows, so the
watch itself is not typed. Say what each file is.

- `drift` is the plan loop, the JSON reading down to attributes, and the
  severity routing.
- `reconcile` is decision 28's rules, each one held by a mechanism rather than
  by a prompt.
- `access/scripts/README.md` is where the asymmetry is written down, which is
  the thing this lesson exists to make the student believe.
- `.github/workflows/drift.yml` is the schedule, and 4b has a fix for it.

Have the student read the two headers before running anything.

```sh
head -25 access/scripts/drift
head -32 access/scripts/reconcile
```

### 4b. Fix the wait loop in the scheduled job

**confirm**, then open `.github/workflows/drift.yml` and find the
`Wait for Floci` step. It reads

```sh
code=$(curl -s -o /dev/null -m 2 -w '%{http_code}' "$FLOCI_ENDPOINT/" || echo 000)
[ "$code" != "000" ] && { echo "Floci answered with $code"; exit 0; }
```

Have the student try that reasoning against a port nothing is listening on,
before telling them what is wrong.

```sh
code=$(curl -s -o /dev/null -m 2 -w '%{http_code}' http://localhost:4599/ || echo 000)
echo "[$code]"
```

`[000000]`. curl writes `%{http_code}` as `000` on a connection failure and
then exits non-zero, so `|| echo 000` appends a second `000`, and the guard
compares `000000` against `000` and lets the loop through on the first
attempt. The job would carry straight on to a Terraform apply against nothing.

**confirm**, then replace the two lines with the form
`.github/workflows/access.yml` already carries.

```sh
code=$(curl -s -o /dev/null -m 2 -w '%{http_code}' "$FLOCI_ENDPOINT/" || true)
[ -n "$code" ] && [ "$code" != "000" ] && { echo "Floci answered with $code"; exit 0; }
```

```sh
code=$(curl -s -o /dev/null -m 2 -w '%{http_code}' http://localhost:4599/ || true)
echo "[$code]"
```

`[000]`, and the loop waits. Say that this is the same failure the retrying
curl in step 3 avoids, one layer down. A wait loop that cannot fail is a wait
loop that does not wait. This is also the one file where the student's tree
ends up ahead of `checkpoint/i7`, and 4h's compare excludes it for that
reason.

### 4c. Watch a converged estate

```sh
access/scripts/drift
echo $?
```

`every watched root matches the account` and `0`. Say what that command
actually did, which is `terraform plan -detailed-exitcode` with a refresh over
`envs/prod`, so it read the account rather than trusting the state file.
`identity/` and `github/` are not watched, because there is nothing on a
laptop for them to have drifted from.

### 4d. Move the account by hand

**confirm**, then

```sh
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1

aws --endpoint-url http://localhost:4566 iam detach-role-policy \
  --role-name site-publisher \
  --policy-arn arn:aws:iam::000000000000:policy/site-publisher-read-waterpark-artifacts

aws --endpoint-url http://localhost:4566 iam tag-role \
  --role-name runner-builder --tags Key=owner,Value=intruder
```

Say what those are while they run. One takes access away and one changes who
is on the hook for a role. Both are a few seconds in a console, neither went
through a pull request, and that is the entire scenario.

```sh
access/scripts/drift
echo $?
```

Exit 2 and two findings, both `[pr]`, ending on
`2 finding(s), 0 of them paging`. Read the report with the student rather than
the exit code. The attribute is named, the declared value sits above the live
one, and the detached policy comes back as an attachment that will be created
with `absent` on the live side. Nobody has to open a console to find out what
moved. Both are `pr` because neither is a security group and neither touched a
trust policy.

### 4e. The reconcile plan

Reads run freely, and `--dry-run` is the default.

```sh
access/scripts/reconcile --dry-run
```

Two `file` lines, `2 to file, 0 already open, 0 held by the cap`, and the
closing note saying nothing was branched, committed, pushed or opened.

Point at four of decision 28's rules standing in that output.

- `cap            5 open reconcile PRs at once (access/baseline)` is the
  constant lesson 5 exported, read out of the applied outputs rather than
  restated. A student who changes that one number watches this line move.
- `open already` is a live count against the code host, so the cap holds
  across cycles rather than within one run.
- The branch name is derived from the resource address, so one PR per resource
  and no second while one is open are both lookups rather than bookkeeping the
  script has to keep.
- Ownership needed no filter, because a plan over a root this repo declares
  cannot contain a resource nobody here declared.

Do not pass `--open`.

### 4f. Widen a trust policy and watch the routing change

**confirm**, then

```sh
aws --endpoint-url http://localhost:4566 iam update-assume-role-policy \
  --role-name desk-operator \
  --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"*"},"Action":"sts:AssumeRole"}]}'

access/scripts/drift --json | jq -c '.findings[] | {severity, address}'
```

Three findings now, and `desk_operator` comes back `page` while the other two
stay `pr`. Ask the student why before saying it. A tag reading `intruder` is
wrong and can wait for a review cycle. A trust policy saying any AWS principal
may become `desk-operator` is reachable right now, and no later revoke undoes
who assumed the role in the meantime. Severity routes on blast radius.

```sh
access/scripts/reconcile --dry-run
```

The `page` finding is printed under
`These page a human and are not filed as PRs.` and the same two `pr` findings
are still the only ones filed. The watch refuses to turn a page into
paperwork, because a pull request sitting in a queue is the wrong response to
a trust policy that is open now.

### 4g. Say the asymmetry, then put the account back

Have the student read the asymmetry section of `access/scripts/README.md`.

**confirm**, then

```sh
terraform -chdir=access/envs/prod apply -auto-approve
access/scripts/drift
echo $?
```

`Apply complete! Resources: 1 added, 2 changed, 0 destroyed.`, then
`every watched root matches the account` and `0`.

Now say both halves, because this is the point of the lesson.

That apply is what a merged reconcile PR would have run. The PR carries no
file change at all, because the repo already said what those resources should
be, so its whole job is to be merged. Restoring the estate is a merge.

The other direction is deliberately harder. If the tag really should read
`intruder` because somebody renamed a team, nothing automatic happens and
nothing should. The reconcile PR is not merged, and a human edits
`access/envs/prod/iam_role.runner_builder.tf` so the repo says it too, through
the one path lesson 6 built. A watcher that could adopt would be a watcher
that ratifies whatever happened, which is the opposite of managing what you
declare.

Ask the student to say that back in their own words before moving on. If they
cannot, the lesson has not landed yet and 4g is the place to stay.

### 4h. The scheduled job, and what it does not prove

```sh
sed -n '1,30p' .github/workflows/drift.yml
```

Weekdays at six in the morning UTC, the same cron the desk teammate runs on,
and on demand. Then read the comment at the top of the file with the student.
The job starts an empty Floci, applies the estate into it and then asks
whether the estate matches, so it always does. A green run means the declared
estate converges and stays converged, and it means nothing about an account
where a human has a console, which is the only place the drift in 4d could
ever come from (decision 58). The job's own summary says so, so a green check
mark on a Monday morning is not read as more than it is.

### 4i. Compare with the reference repo

```sh
git add -A access .github
git diff --cached --stat checkpoint/i7 -- access .github \
  ':!access/README.md' ':!.github/workflows/drift.yml'
```

Nothing printed means every file matches the reference file. Two exclusions
and both are deliberate. `access/README.md` carries the lesson 7 and lesson 8
sections, which this lesson does not write. `.github/workflows/drift.yml` is
excluded because the tag was cut before the wait loop fix in 4b, so the
reference file still carries the `|| echo 000` form and the student's does
not. Say that out loud rather than letting it look like an accident.

## 5. Done when

All five have to be true, and verify each one yourself rather than taking
earlier output on trust.

- `access/scripts/drift` exits 0 against the freshly applied estate and prints
  `every watched root matches the account`.
- After `aws iam detach-role-policy` and `aws iam tag-role` it exits 2 with one
  finding per resource, each naming the attribute and printing `declared`
  above `live`, and ends on `2 finding(s), 0 of them paging`.
- After `aws iam update-assume-role-policy` on `desk-operator`,
  `access/scripts/drift --json` reports that finding as `page` while the other
  two remain `pr`.
- `access/scripts/reconcile --dry-run` prints
  `cap            5 open reconcile PRs at once (access/baseline)`, plans one
  PR per `pr` finding on a branch derived from the resource address, and
  prints the `page` finding under
  `These page a human and are not filed as PRs.` rather than filing it.
- `access/scripts/drift` exits 0 again after
  `terraform -chdir=access/envs/prod apply -auto-approve`.

If `drift` exits 1 rather than 2, the watch broke rather than finding drift,
and the restart point is step 3 with a fresh container. If it exits 0 right
after 4d, the `aws` calls went somewhere other than Floci, so check the
`--endpoint-url` and the three environment variables. If `reconcile` says it
could not read `watcher_max_open_prs`, the estate is not applied and the
restart point is step 3's apply.

## 6. Tear down

**confirm**, then

```sh
terraform -chdir=access/envs/prod destroy -auto-approve
docker rm -f wp-i7-floci
```

Leave the `../waterpark-i7` worktree. Lesson 8 starts a fresh one from
`checkpoint/i7`.

## 7. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"i7"` to its `completed` array (creating the array if the file
somehow lacks one). Leave every other field untouched. Write it in the
original checkout rather than in the `../waterpark-i7` worktree.

```json
{"...": "...", "completed": ["start", "i1", "i2", "i3", "i4", "i5", "i6", "i7"]}
```

## 8. Hand off

Say the next step is IAM lesson 8, delegation and the double refusal
(https://intentius.io/waterpark/courses/iam/08-delegation-and-the-double-refusal/),
where a satellite creates its own roles and cannot make them more powerful
than the estate allows, and stripping the boundary is refused twice by two
things that have never heard of each other.
