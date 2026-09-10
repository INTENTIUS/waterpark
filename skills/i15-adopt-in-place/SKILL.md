---
name: waterpark-i15-adopt-in-place
description: Walk a student through IAM lesson 15, Adopt in place. Use when they finished IAM lesson 11, or lesson 7, and want lesson 15, or when they ask how an existing resource comes under the repo. Makes a role, a bucket and an open security group by hand, watches drift not see them, adopts each with an import block and a resource block reviewed out of generated config, proves with adopt-check that only the estate's tags change, watches the rule pack fail the adopted role, backs the group out with a removed block, and says what walking away costs.
---

# water park, IAM lesson 15, Adopt in place

You are walking a student through IAM lesson 15, Adopt in place
(https://intentius.io/waterpark/courses/iam/15-adopt-in-place/). The
outcome is three resources that predate the repo brought under management
one file at a time with nothing about them changed but the estate's own
tags, the rule pack refusing the adopted role as it would a written one,
and one resource backed out with a `removed` block and still in the
account. About 35 minutes.

This lesson never touches a real AWS account. Every command points at
`http://localhost:4566`, `floci` stays at its default of true, and the
`AWS_ACCESS_KEY_ID=test` pair is the throwaway the provider already uses
rather than a credential. If the student wants to run this against a real
account, say that is the live path, that it needs `-var floci=false` and
the S3 backend, and that a facilitator runs it.

Confirm with the student before creating the worktree, before starting a
Floci container, before the three console commands in step 5b, before
editing `provider.tf`, before writing any file under `access/`, before the
`git checkout` that brings in the check, before each apply and destroy,
and before the teardown. Those steps are marked **confirm**. Reads run
freely, which is every `plan`, `adopt-check`, `drift`, `check` stage,
`list-role-tags`, `describe-security-groups` and `git diff`.

## 1. Say what this is

In two or three sentences say this is lesson 15 of the IAM course, that
fourteen lessons wrote an estate from nothing and this one starts from what
is already there, which is where every real estate starts. Say the
mechanism, an `import` block per resource, a resource block reviewed by
hand out of `terraform plan -generate-config-out`, and a plan that changes
nothing but the tags the estate puts on what it owns, checked by a script.
Link the lesson page above.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Also read `.waterpark/profile.json` at the checkout root if it exists. A
profile file is a claim from a previous run and the check's live calls are
the truth, so when they disagree believe the check. If `completed` does not
carry `"i11"`, say that the checkpoint carries lesson 11's work anyway and
offer to run this. If it does not carry `"i7"` either, say lesson 7 is
where the drift watch comes from and this lesson opens by asking it a
question, and offer to run this anyway.

Require `waterpark.checkout` true and `tools.docker.installed` true. The
check does not report `terraform`, `tflint` or `jq`, so ask for those
directly.

```sh
terraform version
tflint --version
jq --version
```

Terraform 1.9 or newer, any tflint, and any jq. The OPA plugin the rules
run on is what `just access-init` installs in section 3, so `tflint
--version` from the checkout root lists only the bundled ruleset and that
is fine. If tflint is missing, the install line is
`brew install terraform-linters/tap/tflint` on macOS, and the release
binary from https://github.com/terraform-linters/tflint on Linux and
Windows. `jq` is `brew install jq`, `apt install jq` or
`winget install jqlang.jq`, and `adopt-check` and `drift` need it.

Note the check's `floci.reachable`. If it is true, the Start-here stack's
Floci is up on 4566 and this lesson uses it as it is, with IAM enforcement
off, which this lesson never needs. Say so, and skip the container in
section 3. If it is false, section 3 starts one.

## 3. The starting point

**confirm**, then

```sh
git fetch origin --tags
git worktree add ../waterpark-i15 checkpoint/i11
cd ../waterpark-i15
just access-init
```

Every command after this runs from `../waterpark-i15`. If `just
access-init` prints `All plugins are already installed`, that is tflint's
plugin cache and it is fine.

If `floci.reachable` was false, **confirm** and start Floci.

```sh
docker run -d --name wp-i15-floci -p 4566:4566 \
  -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
  ghcr.io/lex00/floci:iam-boundary
```

Either way,

```sh
curl -s --retry 15 --retry-all-errors --retry-delay 1 \
  -o /dev/null -w '%{http_code}\n' http://localhost:4566/
```

`200`.

## 4. Apply the estate

**confirm**, then central first, then the satellite.

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod apply -auto-approve
terraform -chdir=access/satellites/waterpark-runner init
terraform -chdir=access/satellites/waterpark-runner apply -auto-approve
```

`Resources: 18 added` for central and `8 added` for the satellite. If the
stack's Floci already held an estate from an earlier IAM lesson run in the
same session, the counts are lower and the plan is what matters.

## 5. The lesson

### 5a. Nothing yet

Say that the three things about to be made go through no pull request, and
that this is the point.

### 5b. Make three things by hand

**confirm**, then the four `aws` commands from step 2 of the lesson page,
which is `content/courses/iam/15-adopt-in-place.md` in this checkout. Read
them from there. The role ARN, `make_bucket: legacy-uploads`, `true`, and a
group id. Have the student keep `$SG`, two files need it. Say that the
ingress call takes the id rather than the name because the emulator does
not resolve a group by name there.

Then

```sh
access/scripts/drift | tail -1
```

`every watched root matches the account`. Say why the watch is right to say
nothing, and that lesson 7's asymmetry has a second half, adopting is a
file somebody writes, and here are three.

### 5c. Adopt the role

**confirm**, then have the student add `ec2 = endpoints.value` to the
`content` block in `access/envs/prod/provider.tf`, after `s3`, as step 3
shows. Say that the group is the first `ec2` resource the estate touches.

**confirm**, then have them write `access/envs/prod/iam_role.legacy_reporter.tf`
with only the import block from step 3, and run

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod plan -generate-config-out=generated.tf
cat access/envs/prod/generated.tf
```

`Plan: 1 to import, 0 to add, 1 to change, 0 to destroy.`, and the draft
under its two-line review header. Walk the draft against the role, from step 3. The
trust, description, name and tag are the student's. `force_detach_policies`,
`max_session_duration` and `path` are defaults written out,
`permissions_boundary = null` is an absence spelled as a value, and
`tags_all` is computed and never declared. Then have them replace the file
with the reviewed form from step 3, read from the page, and
`rm access/envs/prod/generated.tf`.

### 5d. The check, broken on purpose

**confirm**, then

```sh
git checkout checkpoint/i15 -- \
  access/scripts/adopt-check \
  access/.tflint.d/policies/security.rego \
  access/tests/fixtures/no-open-ingress
access/scripts/adopt-check
```

One `[ok]` row, `the estate adds its tags: env, managed_by, repo`, and
`1 adoption(s), and none changes anything but the estate's own tags.`
Say that this is the plan read for them, and that the three tags are the
provider's `default_tags`, the estate's mark and nothing the role had.

**confirm**, then have the student change `2024` to `2023` in the
description and run the check again. `[FAIL]` with
`the file differs from the account on: description` and exit `2`. Say that
an import whose file is wrong is an edit nobody asked for, dressed as an
adoption. Have them put `2024` back and see `[ok]`.

**confirm**, then

```sh
terraform -chdir=access/envs/prod apply -auto-approve
terraform -chdir=access/envs/prod plan -detailed-exitcode
echo $?
aws --endpoint-url http://localhost:4566 iam list-role-tags --role-name legacy-reporter \
  --query 'Tags[].[Key,Value]' --output text
```

`Import complete`, `1 imported, 0 added, 1 changed`, `0`, and four tags,
`team analytics` plus the estate's three. Run `adopt-check` once more and
the role's row reads `already in state`, because a landed import makes no
importing change in the plan and the check reads the block off the file.

### 5e. The other two

**confirm**, then have the student write the bucket file and the group
file from step 5 of the page, with their own `$SG` in the group's import
block. Say what the drafts would have carried and what the review dropped,
and that the egress rule stays because the account holds it.

```sh
access/scripts/adopt-check
```

Three `[ok]` rows, the role's reading `already in state` and `nothing
changes`, the other two `from` their ids. **confirm**, then the apply and
the replan. `2 imported, 0 added, 2 changed`, then `0`.

### 5f. The refusal as a list

```sh
just access-check
```

Two `Error` lines on `legacy_reporter`, no owner tag and no boundary, one
on `legacy_uploads`, no owner tag, one `Warning` on `legacy_ssh` opening
22 to `0.0.0.0/0` in an inline ingress block, then the CODEOWNERS stage
failing because the adopted role names no team, and `check failed, 2
problem(s)`. Say that being adopted exempts nothing, that the list is day
two with one pull request per line, the team included, and that the
warning is new in this lesson because the rule read only the standalone
shape until now and the inline shape is what generated config writes. This
is also the step to verify the fourth done-when clause, because 5g deletes
the group's file.

### 5g. Back the group out

**confirm**, then `rm access/envs/prod/security_group.legacy_ssh.tf` and
have the student write `removed.legacy_ssh.tf` from step 7. Then

```sh
terraform -chdir=access/envs/prod plan
```

`will no longer be managed by Terraform, but will not be destroyed` and
`Plan: 0 to add, 0 to change, 0 to destroy.` **confirm**, then the apply,
the `describe-security-groups` read, which prints `legacy-ssh`, then
`rm access/envs/prod/removed.legacy_ssh.tf` and the replan, `0`. Say that
the group is exactly where it was and the repo has stopped claiming it.

### 5h. Walking away

```sh
ls access/envs/prod/*.tf
```

Say that the listing is the handover, that every file is HCL the provider
applies directly, and that a team which stops using water park keeps the
directory and drops the rest, which is decision 2's claim and why there is
no export bundle.

### 5i. Compare with the reference repo

```sh
git add -A access .github
git diff --cached --stat checkpoint/i15 -- access .github ':!*README.md' ':!access/envs/prod/*legacy*'
```

Nothing printed means the provider line, the rule and the check are the
reference's. The three adopted files are excluded on purpose, because the
resources they import exist only on this laptop. If `provider.tf` is
named, the `ec2` line is not exactly as step 3 shows it.

## 6. Done when

All five have to be true, and verify each one yourself rather than taking
earlier output on trust.

- `access/scripts/adopt-check` reported three adoptions each changing
  nothing but the estate's tags, and reported `[FAIL]` naming
  `description` when the file misstated the account.
- The applies reported `1 imported` then `2 imported` with the matching
  `changed` counts, and the replan exited 0 after each.
- `list-role-tags` on `legacy-reporter` shows `managed_by`, `repo` and
  `env` beside `team`.
- `access/scripts/check lint` failed on the adopted role's boundary and
  owner tag and warned on the group's open port, read at 5f, before 5g
  removed the group's file.
- After the `removed` block was applied, `describe-security-groups`
  printed `legacy-ssh` and the replan exited 0 with the block deleted.

If `adopt-check` reports `no import block`, no file in the root holds
one, so the file in 5c is missing its block. A landed import reads
`already in state` rather than disappearing. If the plan wants to create a resource
rather than import it, the `id` in the import block does not match the
account, most often the group id. If the check names an attribute other
than `description`, the review in 5c or 5e kept a default, and the draft is
the reference for what the account holds.

## 7. Tear down

**confirm**, then

```sh
terraform -chdir=access/satellites/waterpark-runner destroy -auto-approve
terraform -chdir=access/envs/prod destroy -auto-approve
aws --endpoint-url http://localhost:4566 ec2 delete-security-group --group-id $SG
```

Say that the destroy takes `legacy-reporter` and `legacy-uploads` with it
because they are managed now, and leaves `legacy-ssh` because 5g gave it
back, so the last line removes it by hand. If section 3 started a
container, `docker rm -f wp-i15-floci` as well. Leave the
`../waterpark-i15` worktree.

## 8. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"i15"` to its `completed` array, creating the file and the
array if either is missing. Leave every other field untouched. Write it in
the original checkout rather than in the `../waterpark-i15` worktree.

```json
{"...": "...", "completed": ["start", "i1", "i2", "i3", "i4", "i5", "i6", "i7", "i8", "i9", "i10", "i11", "i15"]}
```

## 9. Hand off

Say the next step is IAM lesson 14, approve the change not the diff
(https://intentius.io/waterpark/courses/iam/14-approve-the-change-not-the-diff/),
where the reviewer approves a plan and its digest and the apply job refuses
anything that moved.
