---
name: waterpark-i10-break-glass
description: Walk a student through IAM lesson 10, Break-glass. Use when they finished IAM lesson 9, or lesson 6, and want lesson 10. Writes the on-call stand-in, grants prod write for two minutes with access/scripts/break-glass, reads the DateLessThan condition and the tags back from the account, gets a three-hour grant refused by the script, the rule pack and plan, leaves the cleanup unrun past the expiry, watches drift report the leftover, sweeps and revokes, and reads how the apply job stamps the approver.
---

# water park, IAM lesson 10, Break-glass

You are walking a student through IAM lesson 10, Break-glass
(https://intentius.io/waterpark/courses/iam/10-break-glass/). The outcome is
a grant that exists for an incident, ends on its own, and leaves a trail,
with the three layers of prescription 9 seen in the order they actually
hold. About 40 minutes, and two of them are a clock running.

This lesson never touches a real AWS account. Every command points at
`http://localhost:4566`, `floci` stays at its default of true, and the
`AWS_ACCESS_KEY_ID=test` pair is the throwaway the provider already uses
rather than a credential. If the student wants to run this against a real
account, say that is the live path, that it needs `-var floci=false` and the
S3 backend, and that a facilitator runs it.

Confirm with the student before creating the worktree, before starting the
Floci container, before the `git checkout` that brings in the machinery,
before writing any file under `access/`, before each apply and destroy,
before the grant in step 5c, before the hand edit in step 5d, before the
revoke in step 5g, and before the teardown. Those steps are marked
**confirm**. Reads run freely, which is every `just access-check` stage,
`validate`, `plan`, `output`, `list-policy-tags`, `get-policy-version`,
`break-glass list`, `break-glass sweep` without `--open`, `drift` and
`git diff`.

## 1. Say what this is

In two or three sentences say this is lesson 10 of the IAM course, that
lesson 9 pinned who may become a principal, and that this lesson is about
access that should exist for two hours and then not, and what has to be true
for "and then not" to hold when everything the student built is down. Name
the three layers, the expiry on the policy that the cloud enforces, the sweep
that removes the artifact, and the watch that reports the leftover, and say
that killing the sweep delays cleanup and never extends access. Link the
lesson page above.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Also read `.waterpark/profile.json` at the checkout root if it exists. A
profile file is a claim from a previous run and the check's live calls are the
truth, so when they disagree believe the check. If `completed` does not carry
`"i9"`, say that the checkpoint carries lesson 9's work anyway and offer to
run this. If it does not carry `"i6"` either, say lesson 6 is where the apply
job comes from and step 5h reads a step of it, and offer to run this anyway.

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
`drift` needs it.

Note the check's `floci.reachable`. It is usually false here, because this
lesson starts its own container in step 3. If it is already true, ask whether
that is the compose stack from `just up` or a leftover from an earlier lesson.
A leftover Floci holds an earlier lesson's estate, and the local state in the
new worktree will not know about it, so prefer a fresh container.

## 3. The starting point

**confirm**, then

```sh
git fetch origin --tags
git worktree add ../waterpark-i10 checkpoint/i9
cd ../waterpark-i10
just access-init
```

Every command after this runs from `../waterpark-i10`.

**confirm** again, then start Floci.

```sh
docker run -d --name wp-i10-floci -p 4566:4566 \
  -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
  ghcr.io/lex00/floci:iam-boundary
```

```sh
curl -s --retry 15 --retry-all-errors --retry-delay 1 \
  -o /dev/null -w '%{http_code}\n' http://localhost:4566/
```

The curl prints `200`. Re-run `bash skills/start/check.sh` and require
`floci.reachable` true before going on.

Say the emulator's limit now rather than at the end. Everything this lesson
declares, checks, watches and sweeps is real on Floci. The one thing Floci
cannot do is evaluate a condition on an allow, so the grant is denied on the
emulator before its expiry as well as after, and the drill where the access
works and then ends is live only. Step 5e is where the page says it.

## 4. Apply the estate, and read the constant

**confirm**, then central first, then the satellite.

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod apply -auto-approve
terraform -chdir=access/satellites/waterpark-runner init
terraform -chdir=access/satellites/waterpark-runner apply -auto-approve
```

`Resources: 17 added` for central and `8 added` for the satellite. Then

```sh
terraform -chdir=access/envs/prod output break_glass_max_ttl_hours
```

`2`. Say that lesson 5 put it in `access/baseline` so a lesson could read
it, and this is the lesson.

## 5. The lesson

### 5a. Bring in the machinery

**confirm**, then

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

Walk the student through what each one is, from step 2 of the lesson page,
which is `content/courses/iam/10-break-glass.md` in this checkout. The three
module files are the grant shape, `granted_at` and its validations, the
break-glass subset, and the three tags with `approved_by` ignored on the
next plan. The inline policy file is the human path, live only.
`envs/prod/variables.tf` gains `break_glass_approver`. The Rego and its
fixtures are `break-glass-ttl`. `check` gains the rule and the line that
compares the TTL in three places. `break-glass` is the script. `drift` gains
the fix 5f explains. The two workflows gain the sweep and the approver
stamp.

**confirm**, then

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod apply -auto-approve
just access-check
```

`Resources: 0 added, 0 changed, 0 destroyed.`, because no grant carries a
`granted_at` yet. Then under the rule fixtures the line
`ok    break_glass_max_ttl_hours is 2 in access/baseline, in the rule pack and in modules/persona`,
`ok    break-glass-ttl (error)`, and `check passed`.

### 5b. Write the on-call

**confirm** before writing, then have the student write
`access/envs/prod/iam_role.on_call.tf`. The body is in step 3 of the lesson
page. Read it from there rather than from memory. Do not fetch it from a
URL. Then have them add the two lines to the two maps in
`access/envs/prod/outputs.tf`, after the `waterpark_apply` lines, as step 3
shows them.

Say what the file is while they write it. A human, live, whose grant lands
on their permission set under `access/identity`, and a role here because
Floci runs no Identity Center. At rest it holds nothing, and a break-glass
grant is a pull request that adds one grant to it.

**confirm**, then

```sh
access/scripts/gen-codeowners
grep on_call .github/CODEOWNERS

terraform -chdir=access/envs/prod apply -auto-approve

export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
aws --endpoint-url http://localhost:4566 iam list-attached-role-policies \
  --role-name on-call --query 'AttachedPolicies'
```

`/access/envs/prod/iam_role.on_call.tf @INTENTIUS/platform`, then
`Resources: 1 added`, then `[]`. A role with a boundary, a trust and no
policy, which is what the on-call holds at four on a Friday afternoon.

### 5c. Grant

**confirm**, then

```sh
access/scripts/break-glass grant access/envs/prod/iam_role.on_call.tf \
  waterpark-site write \
  --reason "A release broke the site late on a Friday." \
  --minutes 2
```

It prints `granted`, the id, the file, the grant, `granted_at`, `expires`
two minutes later, and the reason, then two lines saying this is a file
change and nothing more. Note the id and the expiry, because 5e and 5g use
them. Then

```sh
sed -n '/grants = \[/,/^  \]/p' access/envs/prod/iam_role.on_call.tf
```

One grant block fenced by two marker comments carrying the id. Say that the
markers are what `revoke` and `sweep` find later, and that two minutes stand
in for two hours so the expiry passes inside the lesson.

**confirm**, then

```sh
terraform -chdir=access/envs/prod plan
terraform -chdir=access/envs/prod apply -auto-approve
```

`Plan: 2 to add, 0 to change, 0 to destroy.`, then the apply. Reads run
freely from here.

```sh
aws --endpoint-url http://localhost:4566 iam list-policy-tags \
  --policy-arn arn:aws:iam::000000000000:policy/on-call-write-waterpark-site \
  --query 'Tags[?Key==`break_glass` || Key==`granted_at` || Key==`expires` || Key==`approved_by`]' \
  --output text

aws --endpoint-url http://localhost:4566 iam get-policy-version \
  --policy-arn arn:aws:iam::000000000000:policy/on-call-write-waterpark-site \
  --version-id v1 --query 'PolicyVersion.Document.Statement[0].Condition'

access/scripts/break-glass list
```

Four tags, `granted_at`, `expires`, `approved_by` reading `unapproved`, and
`break_glass` reading `true`. Then the `DateLessThan` on `aws:CurrentTime`
with the expiry. Then `[live]` with the id. Say that the condition is layer
1, on the policy in the account, evaluated on every call, so the access
ends with nothing of the student's alive.

### 5d. Too long, three refusals

```sh
access/scripts/break-glass grant access/envs/prod/iam_role.on_call.tf \
  waterpark-artifacts write --reason "Also this." --hours 3
```

`break-glass: that is longer than the baseline TTL of 2 hour(s). Grant for
less, or grant again when it runs out (decision 37).` and nothing written.

**confirm**, then have the student open the on-call file and move the
`expires` value three hours after the `granted_at` value, same format. Keep
the original value, because it has to go back exactly.

```sh
access/scripts/check lint
```

One `Error` line naming `module "on_call"`, `for 3 hours`, and
`(opa_deny_break_glass_ttl)`, then `FAIL  tflint in access/envs/prod`.

```sh
terraform -chdir=access/envs/prod validate
terraform -chdir=access/envs/prod plan
```

`validate` prints `Success! The configuration is valid.` and `plan` prints
`Error: Invalid value for variable` on the `grants` block with
`var.break_glass_max_ttl_hours is 2`. Say why the two differ, which is that
a validation reading another variable is evaluated when values are known,
at plan, so `validate` is not the check here and the page claims three
refusals rather than four.

Have the student put the `expires` value back exactly, then run
`access/scripts/check lint` until it ends `check passed`. If the value is
not restored exactly, 5g's revoke will still work, because the markers are
what it reads, but the compare in 5i may differ.

### 5e. Do not run the cleanup

```sh
date -u +%Y-%m-%dT%H:%M:%SZ
access/scripts/break-glass list
```

Say that this is the drill prescription 9 asks for, kill the cleanup
mid-grant, and that on a laptop the way to kill a scheduled job is to not
run it. Then say what is true on a real account right now, from step 6 of
the page. Before the expiry the on-call can write to the bucket, after it
they cannot, no job ran between those two facts, and the policy and the
file are both unchanged.

Then say what is true on Floci. The emulator evaluates no condition on an
allow, so the on-call was denied before the expiry too. Everything
declared, checked and watched here is real, and the one thing the emulator
cannot show is the access working and then ending.

Wait until `date` is past the expiry from 5c. If the student wants to use
the time, 5h can be read now and come back to.

### 5f. The leftover, and the watch

```sh
access/scripts/break-glass list
access/scripts/drift
echo $?
```

`[expired]` with the id, then a drift report with one `[pr]` finding,
`grant on-call write-waterpark-site`, `expired`, the declared expiry and
`live     past`, then `1 finding(s), 0 of them paging` and exit `2`.

Say that nothing in the account differs from the file and the watch reports
it anyway, because an expired grant is drift by lesson 7's own definition.
Then say that lesson 7's script never showed this case, because a clean plan
skipped the rest of the loop and an expired grant on an otherwise clean root
was never reported, and that the `drift` 5a brought in runs the expiry check
whatever the plan said.

### 5g. Sweep and revoke

```sh
access/scripts/break-glass sweep
```

`expired` with the id, the file, `branch desk/break-glass/on-call`, then the
dry-run lines ending with the exact `revoke` command. Say that on the
schedule this is `drift.yml` printing the plan into the job summary, and
that a maintainer runs it with `--open` where `gh` can write.

**confirm**, then

```sh
access/scripts/break-glass revoke <the id>
tail -3 access/envs/prod/iam_role.on_call.tf

terraform -chdir=access/envs/prod plan
terraform -chdir=access/envs/prod apply -auto-approve
access/scripts/drift
echo $?
```

`revoked`, the file ending `grants = []`, then
`Plan: 0 to add, 0 to change, 2 to destroy.`, the apply,
`every watched root matches the account` and `0`.

Read the three layers with the student in the order they held. The cloud
ended the access at the expiry with nothing alive. The watch reported the
leftover afterwards. The sweep removed it whenever somebody got to it, late
by design, and the access did not care.

### 5h. The approver, and the human path

```sh
grep -n "Stamp the approver" -B8 -A30 .github/workflows/access.yml | head -60
```

Walk the step. It asks which pull request the merge commit closed, reads its
reviews, takes the last `APPROVED` one, and writes that login as
`approved_by` on every policy tagged `break_glass`, after the apply. Say why
after, from step 10 of the page. The plan was made before the reviewer
approved it, so their name cannot be in it, and lesson 6's digest would
refuse a plan that changed to include it. The module ignores that one tag on
the next plan, and it is the only `ignore_changes` in the estate.

```sh
terraform -chdir=access/identity init -backend=false
terraform -chdir=access/identity validate
```

`Success!`. Say that `identity/` now carries the permission set inline
policy the module renders for a human's grants, so the same block put in
`ssoadmin_permission_set.course_author.tf` lands on the course author's
permission set live, with the same condition and the same refusals, and
that Floci cannot plan it.

### 5i. Compare with the reference repo

```sh
git add -A access .github
git diff --cached --stat checkpoint/i10 -- access .github ':!*README.md'
```

Nothing printed means every file the student wrote is the reference file,
and that `revoke` put the on-call file back byte for byte. The `README.md`
files are the only exclusions. If the on-call file is named, the likeliest
cause is the `expires` value from 5d not restored exactly. Read the
difference with the student rather than pasting over it.

## 6. Done when

All five have to be true, and verify each one yourself rather than taking
earlier output on trust.

- `just access-check` ends `check passed` with `break-glass-ttl (error)` in
  its fixture stage and the line saying the TTL is one constant in three
  places.
- The grant applied as one policy whose `get-policy-version` shows
  `DateLessThan` on `aws:CurrentTime` and whose tags carry `break_glass`,
  `granted_at` and `approved_by`.
- A three-hour expiry was refused by `access/scripts/check lint` with
  `opa_deny_break_glass_ttl` and by `terraform plan` with
  `Invalid value for variable`.
- `access/scripts/drift` exited 2 with an `expired` finding on
  `grant on-call write-waterpark-site` once the two minutes had passed.
- After `revoke` the file ends `grants = []`, the apply destroyed two
  resources, and `access/scripts/drift` exits 0.

If the fixture stage fails on the constant line, one of the three copies of
the TTL was edited and the restart point is 5a. If `plan` did not refuse the
three-hour grant, `modules/persona/variables.tf` did not arrive in 5a. If
`drift` reports nothing after the expiry, `access/scripts/drift` did not
arrive in 5a. If the compare names the on-call file, the restart point is
5d's restore.

## 7. Tear down

**confirm**, then

```sh
terraform -chdir=access/satellites/waterpark-runner destroy -auto-approve
terraform -chdir=access/envs/prod destroy -auto-approve
docker rm -f wp-i10-floci
```

Leave the `../waterpark-i10` worktree. Lesson 11 starts a fresh one from
`checkpoint/i10`.

## 8. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"i10"` to its `completed` array (creating the array if the file
somehow lacks one). Leave every other field untouched. Write it in the
original checkout rather than in the `../waterpark-i10` worktree.

```json
{"...": "...", "completed": ["start", "i1", "i2", "i3", "i4", "i5", "i6", "i7", "i8", "i9", "i10"]}
```

## 9. Hand off

Say the next step is IAM lesson 11, offboard and the access review
(https://intentius.io/waterpark/courses/iam/11-offboard-and-access-review/),
where a principal leaves in one pull request and one apply with nothing left
referencing them, and where a scheduled review reads the live account for
what every principal can reach.
