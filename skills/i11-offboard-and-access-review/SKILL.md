---
name: waterpark-i11-offboard-and-access-review
description: Walk a student through IAM lesson 11, Offboard and the access review. Use when they finished IAM lesson 10, or lesson 8, and want lesson 11. Brings in the read-side scripts, asks whocan and expiring against the account, watches a console-attached policy appear, reads the review artifact and what it did not see, offboards course-author with validate and grep as the proof, offboards desk-operator with a five-resource destroy and a NoSuchEntity read back, and restores both from the checkpoint.
---

# water park, IAM lesson 11, Offboard and the access review

You are walking a student through IAM lesson 11, Offboard and the access
review
(https://intentius.io/waterpark/courses/iam/11-offboard-and-access-review/).
The outcome is a review artifact read from the account and never from a
file, and a principal leaving in one change with nothing left naming them.
About 35 minutes.

This lesson never touches a real AWS account. Every command points at
`http://localhost:4566`, `floci` stays at its default of true, and the
`AWS_ACCESS_KEY_ID=test` pair is the throwaway the provider already uses
rather than a credential. If the student wants to run this against a real
account, say that is the live path, that it needs `-var floci=false`,
`LIVE=true` for the read scripts and the S3 backend, and that a facilitator
runs it.

Confirm with the student before creating the worktree, before starting the
Floci container, before the `git checkout` that brings in the scripts,
before the console edits in step 5b, before each offboard that is not a
preview, before each apply and destroy, before each restore from the
checkpoint, and before the teardown. Those steps are marked **confirm**.
Reads run freely, which is every `whocan`, `expiring`, `access-review`,
`offboard --preview`, `drift`, `plan`, `validate`, `get-role` and
`git diff`.

## 1. Say what this is

In two or three sentences say this is lesson 11 of the IAM course, that
lesson 10 gave somebody access for two hours, and that this lesson is about
the two questions a reviewer asks every quarter, who can reach what, and is
everyone here still supposed to be, and about answering the second one with
a deletion. Say the one rule everything here follows, which is that the read
side reads the account and never a file, so a satellite's role and a policy
somebody attached in a console both show up. Link the lesson page above.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Also read `.waterpark/profile.json` at the checkout root if it exists. A
profile file is a claim from a previous run and the check's live calls are the
truth, so when they disagree believe the check. If `completed` does not carry
`"i10"`, say that the checkpoint carries lesson 10's work anyway and offer to
run this. If it does not carry `"i8"` either, say lesson 8 is where the
satellite comes from and this lesson shows its role in the review, and offer
to run this anyway.

Require `waterpark.checkout` true and `tools.docker.installed` true. The check
does not report `terraform`, `tflint` or `jq`, so ask for those directly.

```sh
terraform version
tflint --version
jq --version
```

Terraform 1.9 or newer, any tflint, and any jq. The OPA plugin the rules run
on is what `just access-init` installs in section 3, so `tflint --version`
from the checkout root lists only the bundled ruleset and that is fine. If
tflint is missing, the install line is
`brew install terraform-linters/tap/tflint` on macOS, and the release binary
from https://github.com/terraform-linters/tflint on Linux and Windows. `jq`
is `brew install jq`, `apt install jq` or `winget install jqlang.jq`, and
every read script in this lesson needs it.

Note the check's `floci.reachable`. It is usually false here, because this
lesson starts its own container in step 3. If it is already true, ask whether
that is the compose stack from `just up` or a leftover from an earlier lesson.
A leftover Floci holds an earlier lesson's estate, and the local state in the
new worktree will not know about it, so prefer a fresh container.

## 3. The starting point

**confirm**, then

```sh
git fetch origin --tags
git worktree add ../waterpark-i11 checkpoint/i10
cd ../waterpark-i11
just access-init
```

Every command after this runs from `../waterpark-i11`. If `just access-init`
prints `All plugins are already installed`, that is tflint's plugin cache
from an earlier lesson on this machine, and it is fine.

**confirm** again, then start Floci.

```sh
docker run -d --name wp-i11-floci -p 4566:4566 \
  -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
  ghcr.io/lex00/floci:iam-boundary
```

```sh
curl -s --retry 15 --retry-all-errors --retry-delay 1 \
  -o /dev/null -w '%{http_code}\n' http://localhost:4566/
```

The curl prints `200`. Re-run `bash skills/start/check.sh` and require
`floci.reachable` true before going on.

Say the two things the emulator cannot show, now rather than at the end.
Identity Center, so the course author's offboard is proven by validate and
grep rather than by an apply, and Access Analyzer's unused-access analyzer,
so the review's unused-access section is a skip with a reason. Everything
else the scripts read is real here.

## 4. Apply the estate

**confirm**, then central first, then the satellite.

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod apply -auto-approve
terraform -chdir=access/satellites/waterpark-runner init
terraform -chdir=access/satellites/waterpark-runner apply -auto-approve
```

`Resources: 18 added` for central and `8 added` for the satellite.

## 5. The lesson

### 5a. Bring in the read side

**confirm**, then

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

Say what each one is, from step 2 of the lesson page, which is
`content/courses/iam/11-offboard-and-access-review.md` in this checkout.
`lib-live.sh` is the shared read side, sourced and never run. `rotation`
changes by one line so `LIVE=true` is the one switch. Then have the student
read the three headers the page names.

```sh
head -12 access/scripts/whocan
head -14 access/scripts/offboard
head -12 access/scripts/access-review
```

### 5b. Who can reach the artifacts bucket

```sh
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
access/scripts/whocan waterpark-artifacts
```

Five grants, sorted by principal. `desk-operator` list and read with their
`2027-01-01` expiry, `runner-builder` list and write with
`from waterpark-runner`, and `site-publisher` read. Point at the
`runner-builder` lines and say that nothing opened
`access/satellites/`. The script asked the account, the satellite's role is
in the account, so it is in the answer, and the `from` line is a tag the
satellite's provider wrote.

**confirm**, then the console edit.

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

`on-call  attached policy console-read, not written by the repo`. Say that
the script could not read a level off that name because the persona module
did not write it, and it says so instead of guessing, and that a review
built from the HCL would have said the on-call holds nothing. Then

```sh
access/scripts/drift | tail -1
```

`every watched root matches the account`. Say that the watch is blind to
this, because the module declares one attachment resource per grant and
each owns only its own, so a plan sees nothing when a policy it never
declared is attached beside them, and that this is why the review reads
the account rather than a bug in the watch. **confirm**, then clean up.

```sh
aws --endpoint-url http://localhost:4566 iam detach-role-policy \
  --role-name on-call --policy-arn arn:aws:iam::000000000000:policy/console-read
aws --endpoint-url http://localhost:4566 iam delete-policy \
  --policy-arn arn:aws:iam::000000000000:policy/console-read
access/scripts/whocan waterpark-artifacts | grep -c on-call
```

`0`.

### 5c. What expires

```sh
access/scripts/expiring
echo $?
access/scripts/expiring --within 120
echo $?
```

Nothing inside thirty days and exit `0`, then the two `desk-operator`
grants as `[soon]` with their `2027-01-01` expiry and exit `2`. If the date
has moved past the point where a hundred and twenty days no longer reaches
January 2027, widen the window and say so. The page was written on
2026-09-10.

### 5d. The review

```sh
access/scripts/access-review | tee review.md
```

About nine seconds. Walk the artifact with the student, from step 5 of the
page. Five rows in Principals with `waterpark-runner` in the From column on
`runner-builder`, `federated` with the exact subject on two rows, `yes` in
every Boundary cell. The grants table with the reason beside each row.
`## Unused access` reading `Skipped.` with why. `## Humans` listing the two
as declared, not as read. `## What this review did not see` at the end, and
say why a review that does not say what it could not see is asking to be
trusted.

```sh
access/scripts/access-review --json | jq '{principals: (.principals | length), grants: (.grants | length), humans: .humans.declared}'
```

`5`, `8`, and `course-author` and `platform`.

### 5e. Offboard the course author

```sh
access/scripts/offboard --preview course-author
```

Four references under `access/identity`, the leaf file, the output line,
the `course_author_group_id` variable block and the CODEOWNERS line, then
the live half as a skip saying `access/identity` is live only. Say that the
script found the leaf file by the layout's promise and that the skip is
honest rather than lazy.

**confirm**, then

```sh
access/scripts/offboard course-author

terraform -chdir=access/identity init -backend=false
terraform -chdir=access/identity validate
grep -rn "course.author" access --include='*.tf' .github/CODEOWNERS | grep -v ':[[:space:]]*#'
access/scripts/check codeowners
```

`deleted`, two `edited`, `regen`, the `none.` line, then `Success!`, then
nothing from the grep, then the codeowners stage ending on its `ok` line and
`check passed`. Say that validate is the proof here because the root is live only,
and that live the plan shows the permission set and its assignments leaving.

**confirm**, then restore.

```sh
git checkout checkpoint/i10 -- access/identity .github/CODEOWNERS
access/scripts/check codeowners
```

### 5f. Offboard a workload for real

```sh
access/scripts/offboard --preview desk-operator
```

The declared half prints first, four lines as for the author. Then the live
half is a read. The role ARN, its boundary, two policies,
and `removes  the role, 2 grant policies and their attachments, at apply`.
Say that the `removes` line is what the PR reviewer approves and that it
came from the account.

**confirm**, then

```sh
access/scripts/offboard desk-operator
terraform -chdir=access/envs/prod plan
```

`Plan: 0 to add, 0 to change, 5 to destroy.` Say that nothing else
referenced the module, or the plan would have failed on it.

**confirm**, then

```sh
terraform -chdir=access/envs/prod apply -auto-approve

aws --endpoint-url http://localhost:4566 iam get-role --role-name desk-operator
access/scripts/drift
echo $?
access/scripts/access-review | grep -c '^| `'
```

`5 destroyed`, then `NoSuchEntity`, then `every watched root matches the
account` and `0`, then `10`, four principal rows and six grant rows. Read
the line from the page: one PR, one apply, and the account, the watch and
the review all agree that nothing named `desk-operator` is left.

**confirm**, then restore.

```sh
git checkout checkpoint/i10 -- \
  access/envs/prod/iam_role.desk_operator.tf \
  access/envs/prod/outputs.tf \
  .github/CODEOWNERS
terraform -chdir=access/envs/prod apply -auto-approve
access/scripts/drift | tail -1
```

`Resources: 5 added`, then `every watched root matches the account`.

### 5g. The schedule

```sh
sed -n '1,10p' .github/workflows/access-review.yml
```

Read the comment with the student. The job applies the estate into its own
Floci and reviews that, so the artifact is the review the declared estate
produces and says nothing about a real account, the same honesty as lesson
7's drift job. Live, `LIVE=true` and the security account's reviewer.

### 5h. Compare with the reference repo

```sh
git add -A access .github
git diff --cached --stat checkpoint/i11 -- access .github ':!*README.md'
```

Nothing printed means every file is the reference file. The `README.md`
files are the only exclusions. If `identity/` or `desk_operator` is named,
one of the two restores did not run, and the checkout line in 5e or 5f is
the fix.

## 6. Done when

All five have to be true, and verify each one yourself rather than taking
earlier output on trust.

- `access/scripts/whocan waterpark-artifacts` listed five grants including
  `runner-builder` with `from waterpark-runner`, and a sixth line for the
  hand-attached policy reading `not written by the repo` until it was
  detached, while `drift` stayed clean throughout.
- `access/scripts/access-review` printed a Principals table with five rows,
  `waterpark-runner` in the From column, and an unused-access section that
  is a named skip.
- After `offboard course-author`, `terraform -chdir=access/identity
  validate` printed `Success!` and the grep printed nothing.
- After `offboard desk-operator`, the plan said `5 to destroy`, and after the
  apply `get-role` returned `NoSuchEntity` while `drift` exited 0.
- Both principals are back from `checkpoint/i10` and the compare in 5h
  printed nothing.

If `whocan` shows fewer than five, the satellite was not applied and the
restart point is 4. If the review's Principals table is short, the same. If
the grep after the course author's offboard finds a line, read it, and if it
is not a comment the restart point is 5e with the reference `offboard`. If
the compare names a file, the restart point is the restore in 5e or 5f.

## 7. Tear down

**confirm**, then

```sh
terraform -chdir=access/satellites/waterpark-runner destroy -auto-approve
terraform -chdir=access/envs/prod destroy -auto-approve
docker rm -f wp-i11-floci
```

Leave the `../waterpark-i11` worktree. Lesson 12 starts a fresh one from
`checkpoint/i11`.

## 8. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"i11"` to its `completed` array, creating the file and the array
if either is missing, which on a fresh clone they are. Leave every other
field untouched. Write it in the original checkout rather than in the
`../waterpark-i11` worktree.

```json
{"...": "...", "completed": ["start", "i1", "i2", "i3", "i4", "i5", "i6", "i7", "i8", "i9", "i10", "i11"]}
```

## 9. Hand off

Say the next step is IAM lesson 12, the concierge
(https://intentius.io/waterpark/courses/iam/12-the-concierge/), where the
desk takes a request in words, edits one file, runs the plan and the proofs,
and opens the pull request, holding nothing that can write to the cloud.
