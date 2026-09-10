---
name: waterpark-i14-approve-the-change-not-the-diff
description: Walk a student through IAM lesson 14, Approve the change, not the diff. Use when they finished IAM lesson 15, or lesson 6, and want lesson 14, or when they ask what the apply job compares. Saves a plan and reads its delta and digest, moves the account and watches the digest change with the diff naming why, moves the state and watches Terraform refuse the saved plan, plans one change from two emulators and gets one digest against the old one's two, renames a role and reads the replacements section, and says what the digest cannot say. No model turns.
---

# water park, IAM lesson 14, Approve the change, not the diff

You are walking a student through IAM lesson 14, Approve the change, not
the diff
(https://intentius.io/waterpark/courses/iam/14-approve-the-change-not-the-diff/).
The outcome is the object that travels from the PR job to the apply job,
read by hand, with both refusals shown, the digest proven to belong to the
change and not the container, and a replacement read as what it is. About
35 minutes and no model turns.

This lesson never touches a real AWS account. Every command points at a
local emulator, `floci` stays at its default of true, and the
`AWS_ACCESS_KEY_ID=test` pair is the throwaway the provider already uses.
If the student wants to run this against a real account, say that is the
live path and a facilitator runs it.

Confirm with the student before creating each worktree, before starting a
container, before the `git checkout` that brings in the two files, before
each edit to a leaf file, before the hand edits to the account in step 5c,
before each apply and destroy, and before the teardown. Those steps are
marked **confirm**. Reads run freely, which is every `plan`, `show`,
`render-delta`, `plan-digest`, `diff`, `grep`, `gh api` and `git diff`.

## 1. Say what this is

In two or three sentences say this is lesson 14 of the IAM course, that
lesson 6 built two jobs and said the whole lesson was the difference between
them, and that this lesson takes the object that travels between them, the
saved plan with its delta and its digest, and reads it. Say the rule, the
reviewer approves a plan and not a diff, and the apply job refuses anything
that is not that plan. Link the lesson page above.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Also read `.waterpark/profile.json` at the checkout root if it exists. A
profile file is a claim from a previous run and the check's live calls are
the truth, so when they disagree believe the check. If `completed` does not
carry `"i15"`, say the checkpoint carries lesson 15's work anyway and offer
to run this. If it does not carry `"i6"` either, say lesson 6 is where the
two jobs come from and this lesson reads their steps, and offer to carry
on.

Require `waterpark.checkout` true and `tools.docker.installed` true. The
check does not report `terraform`, `tflint` or `jq`, so ask for those
directly.

```sh
terraform version
tflint --version
jq --version
```

Terraform 1.9 or newer, any tflint, and any jq. `gh` is used once for a
read of the environment and can be skipped if missing. `docker` is needed
whatever the stack is doing, because step 5e starts a second container.

Note the check's `floci.reachable`. If it is true, the Start-here stack's
Floci is up on 4566 and the lesson uses it as the first emulator, with IAM
enforcement off, which this lesson never needs. If it is false, section 3
starts one.

## 3. The starting point

**confirm**, then

```sh
git fetch origin --tags
git worktree add ../waterpark-i14 checkpoint/i15
cd ../waterpark-i14
just access-init
```

Every command after this runs from `../waterpark-i14`. If `floci.reachable`
was false, **confirm** and start the container from step 1 of the lesson
page, which is `content/courses/iam/14-approve-the-change-not-the-diff.md`
in this checkout. Either way, the curl, `200`.

## 4. Apply central

**confirm**, then

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod apply -auto-approve
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
```

`Resources: 18 added`. Say the satellite stays out because the digest
covers `envs/prod`, which is what the apply job applies.

## 5. The lesson

### 5a. Read the two jobs

The `grep` and the `gh api` from step 2 of the page. Walk the five lines,
save, find, compare, environment, label. `{"name":"prod","protection_rules":0}`,
and say that the environment exists so it can be configured and nobody
has, so on this repository the merge is the approval and the digest is
what makes that mean the plan.

**confirm**, then the checkout of the two files from step 2.

### 5b. The change, the delta, the digest

**confirm**, then have the student add the fourth grant to
`access/envs/prod/iam_role.site_publisher.tf` from step 3 of the page,
after the `read` grant. Then the four commands. `Plan: 2 to add`, the delta
with `site-publisher` `+ write on waterpark-artifacts`, and a digest. Say
what each is for, the delta is what the reviewer approves and the digest is
what the approval binds to. Then the `--normalise` read, two creates with
whole after-values and no timestamp or prior state.

### 5c. The account moves

**confirm**, then the `tag-role` from step 4, the replan, the digest and
the diff. `2 to add, 1 to change`, a different digest, and a diff naming an
`update` on `module.site_publisher.aws_iam_role.this[0]` with `tags`. Say
what the apply job prints here, `The plan moved between approval and
apply. Refusing (decisions 24 and 35).`, and that the reviewer approved
two creates while the apply would have done three.

**confirm**, then the `tag-role` back to `platform`, the replan and the
digest. The same digest as 5b. Say that the digest is the change and
nothing else.

### 5d. Terraform's own refusal

**confirm**, then the apply and then `terraform -chdir=access/envs/prod apply tfplan`.
`2 added`, then `Error: Saved plan is stale`. Walk the difference from step
5 of the page. The digest asks whether the estate the reviewer saw is the
one being applied to, Terraform asks whether the state the plan was
computed from is the one it would write, and they check different things.

### 5e. Two containers, one digest

**confirm**, then the second container on 4567, the second worktree at
`checkpoint/i15` with the reference `render-delta` checked into it, and its
apply with `TF_VAR_floci_endpoint` set, from step 6. `18 added`.

**confirm**, then the description edit in both worktrees, exactly as step 6
spells it, and the two plans, two `show`s, two digests, the two `before`
reads and the `--normalise` read. `1 to change` twice, one digest twice,
two `before` values with different `create_date` and `unique_id`, and an
after-value that is only `description`.

Then the old digest from `checkpoint/i10`, two different strings. Say
that this refused pull request 89's apply on `main`, the first in-place
update the pipeline merged, and that a digest which remembers the container
refuses every update forever. If the student's `TF_VAR_floci_endpoint` is
still exported, the first worktree's plan goes to the wrong container and
the numbers differ, so `unset` it as the page does.

### 5f. A replacement

**confirm**, then the description back in both worktrees and the rename in
this one, then the plan and the delta from step 7. `must be replaced` on
the role and every grant policy, and the `Replacements` section listing
each with `forced by name` or `forced by policy_arn, role`. Read the top of
the delta first with the student, `site-publisher-v2` gains four grants,
and then the section, and say that the delta was telling the truth both
times and the second truth is the one a reviewer is paid to read. Say what
the PR job does, the summary section and the `replacement` label. Do not
apply. **confirm**, then the name back.

### 5g. What the digest cannot say

Read step 8 with the student. Not who produced the plan, which is
property XIV half closed until an attested build is checked before apply,
and not which account the apply landed on, which on this repository is a
container the job built.

### 5h. Compare with the reference repo

```sh
git add -A access .github
git diff --cached --stat checkpoint/i14 -- access .github ':!*README.md'
```

Nothing printed means the delta and the workflow are the reference's and
the leaf file is back. If `iam_role.site_publisher.tf` is named, one of
the three edits is still in it, and the checkpoint's copy is the fix.

## 6. Done when

All five have to be true, and verify each one yourself rather than taking
earlier output on trust.

- `render-delta` on the saved plan in 5b read `site-publisher`
  `+ write on waterpark-artifacts`.
- In 5e the two digests were one string, the two `before` values differed
  in `create_date` and `unique_id`, and the old digest gave two strings.
- In 5c the digest changed after the `tag-role` and the diff named `tags`,
  and it came back after the tag was restored.
- In 5d `terraform apply tfplan` failed with `Saved plan is stale`.
- In 5f the delta printed a `Replacements` section with `forced by name`.

If the two digests in 5e differ, the edits are not byte for byte the same,
or one plan went to the wrong container, check `TF_VAR_floci_endpoint`. If
5d does not refuse, the apply before it did not run. If 5f prints no
replacements section, the reference `render-delta` did not arrive in 5a.

## 7. Tear down

**confirm**, then the destroys, the second container and the second
worktree from step 9 of the page. If section 3 started a container,
`docker rm -f wp-i14-floci` as well. Leave the `../waterpark-i14`
worktree.

## 8. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"i14"` to its `completed` array, creating the file and the
array if either is missing. Leave every other field untouched. Write it in
the original checkout rather than in the `../waterpark-i14` worktree.

```json
{"...": "...", "completed": ["start", "i1", "i2", "i3", "i4", "i5", "i6", "i7", "i8", "i9", "i10", "i11", "i15", "i14"]}
```

## 9. Hand off

Say that the IAM course's remaining lessons, 12 and 13, are the concierge
and the watcher, and that both wait on the AWS desk, which is not built,
so their pages are placeholders for now. Say the same of Fountain lessons
7 to 9, and that every other lesson in both courses is written.
