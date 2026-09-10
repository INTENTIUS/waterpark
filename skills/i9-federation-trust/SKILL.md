---
name: waterpark-i9-federation-trust
description: Walk a student through IAM lesson 9, Federation trust. Use when they finished IAM lesson 8, or lesson 6, and want lesson 9. Federates site-publisher through the GitHub Actions trust anchor with the exact subject pinned, refuses a wildcard at validate, writes the trust-subject-pinned and trust-audience-pinned rules with fixtures, pages on a hand-edited trust policy and a widened anchor, runs the rotation check over an account with nothing to rotate and then one with a key, and forges a token to show what the emulator cannot refuse.
---

# water park, IAM lesson 9, Federation trust

You are walking a student through IAM lesson 9, Federation trust
(https://intentius.io/waterpark/courses/iam/09-federation-trust/). The
outcome is a workload that federates through a declared trust anchor with the
issuer, the audience and the exact subject pinned, two rules that refuse a
trust anybody could match, a drift watch that pages on a changed trust or
anchor, and a rotation check that reads the account for static secrets. About
40 minutes.

This lesson never touches a real AWS account. Every command points at
`http://localhost:4566`, `floci` stays at its default of true, and the
`AWS_ACCESS_KEY_ID=test` pair is the throwaway the provider already uses
rather than a credential. The one IAM user this lesson makes is made by hand
on the emulator in step 5g and deleted in the same step. If the student wants
to run this against a real account, say that is the live path, that it needs
`-var floci=false` and the S3 backend, and that a facilitator runs it.

Confirm with the student before creating the worktree, before starting the
Floci container, before writing any file under `access/`, before the
`git checkout` that brings in the machinery, before each apply and destroy,
before the two console edits in step 5f, before creating the user in step 5g,
before the edit to the workflow in step 5i, and before the teardown. Those
steps are marked **confirm**. Reads run freely, which is every
`just access-check` stage, `validate`, `plan`, `get-role`, `drift`,
`rotation`, the forged `assume-role-with-web-identity` call and `git diff`.

## 1. Say what this is

In two or three sentences say this is lesson 9 of the IAM course, that lesson
8 handed a role to somebody else, and that this lesson is about the sentence
in every role that says who may become it at all. Say what a federated trust
is, which is three pins, the issuer the statement points at, the audience
under `StringEquals`, and the exact subject under `StringEquals` spelled out
in full, and that who may become a principal is the one edit revoking a grant
cannot undo. Link the lesson page above.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Also read `.waterpark/profile.json` at the checkout root if it exists. A
profile file is a claim from a previous run and the check's live calls are the
truth, so when they disagree believe the check. If `completed` does not carry
`"i8"`, say that the checkpoint carries lesson 8's work anyway and offer to
run this. If it does not carry `"i6"` either, say lesson 6 is where the trust
anchor and the apply role come from and this lesson reuses that anchor, and
offer to run it anyway.

Require `waterpark.checkout` true and `tools.docker.installed` true. The check
does not report `terraform`, `tflint` or `jq`, so ask for those directly.

```sh
terraform version
tflint --version
jq --version
```

Terraform 1.9 or newer, any tflint, and any jq. The OPA plugin the rules
run on is what `just access-init` installs in section 3, so `tflint
--version` from the checkout root lists only the bundled ruleset and that is
fine. If tflint is missing, the install line is
`brew install terraform-linters/tap/tflint` on macOS, and the release binary
from https://github.com/terraform-linters/tflint on Linux and Windows. `jq`
is `brew install jq`, `apt install jq` or `winget install jqlang.jq`, and
`drift` and `rotation` both need it.

Note the check's `floci.reachable`. It is usually false here, because this
lesson starts its own container in step 3. If it is already true, ask whether
that is the compose stack from `just up` or a leftover from an earlier lesson.
A leftover Floci holds an earlier lesson's estate, and the local state in the
new worktree will not know about it, so prefer a fresh container.

## 3. The starting point

**confirm**, then

```sh
git fetch origin --tags
git worktree add ../waterpark-i9 checkpoint/i8
cd ../waterpark-i9
just access-init
```

Every command after this runs from `../waterpark-i9`.

**confirm** again, then start Floci.

```sh
docker run -d --name wp-i9-floci -p 4566:4566 \
  -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
  ghcr.io/lex00/floci:iam-boundary
```

```sh
curl -s --retry 15 --retry-all-errors --retry-delay 1 \
  -o /dev/null -w '%{http_code}\n' http://localhost:4566/
```

The curl prints `200`. The retry flags are there because the container binds
the port before it answers on it, so the same curl without them prints `000`
the first time. Re-run `bash skills/start/check.sh` and require
`floci.reachable` true before going on.

Say one thing about the emulator now rather than at the end. Everything this
lesson declares, checks and watches is real on Floci. The one thing it cannot
do is refuse a forged token, because its `AssumeRoleWithWebIdentity` is a
stub, and step 5h runs the forged call on purpose so the student sees the
gap rather than assumes it closed.

## 4. Apply the estate, and read the two trust policies

**confirm**, then central first, then the satellite.

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod apply -auto-approve
terraform -chdir=access/satellites/waterpark-runner init
terraform -chdir=access/satellites/waterpark-runner apply -auto-approve
```

`Resources: 17 added` for central and `8 added` for the satellite. Then

```sh
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1

aws --endpoint-url http://localhost:4566 iam get-role \
  --role-name waterpark-apply \
  --query 'Role.AssumeRolePolicyDocument.Statement[0].[Principal,Condition]'

aws --endpoint-url http://localhost:4566 iam get-role \
  --role-name site-publisher \
  --query 'Role.AssumeRolePolicyDocument.Statement[0].[Principal,Condition]'
```

The apply role prints a `Federated` principal and a `StringEquals` block with
`aud` and `sub` pinned, which lesson 6 wrote. The publisher prints
`{"Service": ["codebuild.amazonaws.com"]}` and `null`. Say that nothing in this
estate runs on CodeBuild, that the trust is a placeholder carried since lesson
2, and that it is the last one in `envs/prod`. Keep both outputs. Step 5a
shows the publisher with the apply role's shape.

## 5. The lesson

### 5a. Federate the publisher

**confirm** before writing, then have the student replace
`access/envs/prod/iam_role.site_publisher.tf` with the body in step 2 of the
lesson page, which is `content/courses/iam/09-federation-trust.md` in this
checkout. Read it from there rather than from memory, so the student's file
and the page agree exactly. Do not fetch it from a URL.

While the student writes it, say what changed and what did not. The grants
did not move. Only the trust did, and the anchor it points at is the one
lesson 6 declared beside `waterpark-apply`, so no new resource is created.
The subject is `repo:INTENTIUS/waterpark:environment:github-pages`, because
`.github/workflows/hugo.yml` publishes the site from the `github-pages`
deployment environment and nothing else does. A job on `main` that is not in
that environment carries a token whose `sub` is a different string.

**confirm**, then apply and read it back from the account.

```sh
terraform -chdir=access/envs/prod apply -auto-approve
terraform -chdir=access/envs/prod plan -detailed-exitcode
echo $?

aws --endpoint-url http://localhost:4566 iam get-role \
  --role-name site-publisher \
  --query 'Role.AssumeRolePolicyDocument.Statement[0].[Principal,Condition]'
```

`Resources: 0 added, 1 changed, 0 destroyed.`, then `0`, then the
`Federated` principal with `aud` and `sub` under `StringEquals`, the subject
as a whole string. Walk the three pins with the student against that output.

### 5b. Loosen it and get refused

**confirm**, then have the student edit the `subjects` line to
`["repo:INTENTIUS/*"]` and run

```sh
terraform -chdir=access/envs/prod validate
```

It prints `Error: Invalid value for variable` and then

```
A federated trust subject carries no wildcard. Name the branch or the
environment in full, because a wildcard sub claim trusts every repository the
issuer serves (prescription 12).
```

Say that this is `modules/persona` refusing at validate, before plan, before
the PR job, and before the editor saves if `terraform-ls` is on. Have the
student put the exact subject back and run validate until it prints
`Success! The configuration is valid.` Do not go on with a wildcard in the
file. Mention that after 5e the module refuses an empty `audience` and an
`issuer_host` carrying `https://` the same way, and that the fixtures 5e
brings in cover both.

### 5c. Write the trust rules

**confirm** before writing, then have the student write
`access/.tflint.d/policies/trust.rego`. The body is in step 4 of the lesson
page. Read it from there.

While the student writes it, say the three things the page calls out.
`policy_statements` and `statement_actions` are defined in `security.rego`
in the same package, so this file reuses them. `pinning_operators` is one
operator, and `StringLike` is refused even with no star in it, because a
pattern operator is a wildcard waiting for somebody to add one. `conditions`
flattens a string or a list, because IAM allows both and the module writes
the list form. The audience rule has two more clauses over the provider
itself, an empty `client_id_list` and a url that is not `https`.

### 5d. Write the subject fixtures

**confirm**, then have the student write the four files under
`access/tests/fixtures/trust-subject-pinned/`, `fail/iam_role.wildcard_subject.tf`,
`fail/iam_role.no_subject.tf`, `pass/iam_role.pinned_subject.tf` and
`pass/iam_role.service_trust.tf`. The bodies are in step 5 of the lesson
page.

Point at the second passing fixture. `desk-operator` and `runner-builder`
are still trusted by a service principal, and a rule that fired on them
would fire on every role in every account that has never heard of OIDC. The
rule reads federated statements only.

### 5e. Bring in the machinery, and run the stack

**confirm**, then

```sh
git checkout checkpoint/i9 -- \
  access/tests/fixtures/trust-audience-pinned \
  access/scripts/check \
  access/scripts/rotation \
  access/scripts/drift \
  access/modules/persona/variables.tf \
  access/baseline/locals.tf \
  access/baseline/outputs.tf \
  access/envs/prod/outputs.tf \
  .github/workflows/drift.yml
```

Walk the student through what each one is, from step 6 of the page. The
audience fixtures are the same shape as the four they wrote with the other
pin missing. `check` gains the two rules in its fixture table and a
workflow-level scan that step 5i shows. `rotation` is step 5g. `drift` gains
the OIDC provider in its `page` list. `modules/persona/variables.tf` adds two
validations beside the wildcard refusal step 5b already hit, an empty
`audience` and an `issuer_host` with a scheme. The baseline and the two
`outputs.tf` carry
`static_secret_max_age_days` through to where `rotation` reads it.
`drift.yml` runs `rotation` after the watch on the same cron.

**confirm**, then apply once more, because the new output has to land in
state before the plan stage can be clean.

```sh
terraform -chdir=access/envs/prod apply -auto-approve
```

`0 added, 0 changed, 0 destroyed.` and `static_secret_max_age_days = 90`
among the outputs. Say that nothing in the account moved, and that
`plan -detailed-exitcode` counts a new output as a change until an apply
records it. Then

```sh
just access-check
```

`trust-subject-pinned (error)` and `trust-audience-pinned (error)` under the
rule fixtures, the fork-PR line ending `and the workflow level grants
neither`, and `check passed` at the end. Then run the failing fixture by hand
so the student sees the three messages.

```sh
TFLINT_OPA_POLICY_DIR=$PWD/access/.tflint.d/policies \
  tflint --chdir=access/tests/fixtures/trust-subject-pinned/fail \
    --config=$PWD/access/.tflint.hcl \
    --only=opa_deny_trust_subject_pinned \
    --minimum-failure-severity=notice --format=compact
```

Three issues. `no_subject` fires once, `wildcard_subject` fires twice, once
for the operator and once for the star, and each message carries its own
fix. The path in front of each line depends on where the student stands, so
compare the messages rather than the prefix.

If the fixture stage fails on one of the two new rules, the restart point is
5c or 5d, and the message names which fixture disagreed.

### 5f. Edit the trust by hand, and watch the severity

**confirm**, then the two console edits.

```sh
aws --endpoint-url http://localhost:4566 iam update-assume-role-policy \
  --role-name site-publisher \
  --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Federated":"arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com"},"Action":"sts:AssumeRoleWithWebIdentity","Condition":{"StringEquals":{"token.actions.githubusercontent.com:aud":"sts.amazonaws.com"},"StringLike":{"token.actions.githubusercontent.com:sub":"repo:INTENTIUS/*"}}}]}'

aws --endpoint-url http://localhost:4566 iam add-client-id-to-open-id-connect-provider \
  --open-id-connect-provider-arn arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com \
  --client-id other.example.com

access/scripts/drift
echo $?
```

Two findings, both `[page]`, one on `aws_iam_openid_connect_provider.actions`
with `client_id_list` declared beside live and one on
`module.site_publisher.aws_iam_role.this[0]` with `assume_role_policy`
declared beside live, then `2 finding(s), 2 of them paging` and exit `2`.

Say why these page where lesson 7's detached policy filed a PR. A reconcile
PR for either would put the trust back without anyone asking who widened it
or why. The anchor is on the page list since this lesson, because an anchor
that honors a second audience is a role that trusts a second issuer's
consumers, one level up.

**confirm**, then restore with the apply and confirm the watch is quiet.

```sh
terraform -chdir=access/envs/prod apply -auto-approve
access/scripts/drift
echo $?
```

`0 added, 2 changed, 0 destroyed.`, then `every watched root matches the
account` and `0`.

### 5g. The rotation check

```sh
access/scripts/rotation
echo $?
```

`window 90 days`, `trust anchors 1, nothing to rotate behind them`,
`access keys none in the account`, the closing line that every principal is
a role or a permission set, and exit `0`. Say that this is the estate as
declared, and why, which is that workloads get a token per job through the
anchor, humans get an Identity Center session, and decision 5 leaves no user
to hold a key.

**confirm**, then make a user and a key by hand.

```sh
aws --endpoint-url http://localhost:4566 iam create-user --user-name console-made
aws --endpoint-url http://localhost:4566 iam create-access-key --user-name console-made \
  --query AccessKey.AccessKeyId --output text

access/scripts/rotation
echo $?
```

One key, `[within]`, `0 day(s) old`, and exit `0`, with the last line saying
every key is inside the window and every key is a user this repo does not
declare, which the drift watch owns. Say that this check answers "how old"
and nothing else. Then

```sh
access/scripts/rotation --max-age-days 0
echo $?
```

The header now reads `window 0 days (--max-age-days)`, then `[rotate]`,
`1 key(s) over the window`, and exit `2`. A key at the window is
over it, so zero is the estate's own policy as a number, and the ninety in
`access/baseline` is for the secrets lesson 10 adds.

Do not print the secret access key into a chat log the student is sharing.
The `--query` above prints only the key id, and the habit is the lesson.

**confirm**, then clean up.

```sh
aws --endpoint-url http://localhost:4566 iam delete-access-key --user-name console-made \
  --access-key-id "$(aws --endpoint-url http://localhost:4566 iam list-access-keys \
    --user-name console-made --query 'AccessKeyMetadata[0].AccessKeyId' --output text)"
aws --endpoint-url http://localhost:4566 iam delete-user --user-name console-made
access/scripts/rotation | tail -1
```

`nothing to rotate.` again.

### 5h. Forge a token

```sh
aws --endpoint-url http://localhost:4566 sts assume-role-with-web-identity \
  --role-arn arn:aws:iam::000000000000:role/site-publisher \
  --role-session-name forged \
  --web-identity-token not.a.real.token \
  --query '[SubjectFromWebIdentityToken,Provider,Audience,AssumedRoleUser.Arn]'
```

It succeeds and prints `web-identity-subject`, `accounts.google.com`,
`sts.amazonaws.com` and an assumed-role ARN for `site-publisher/forged`. Say
plainly that it should not have. Real STS fetches the issuer's signing keys
from the discovery document behind the anchor's URL, checks the signature
and refuses with `InvalidIdentityToken` before `aud` or `sub` is read.
Floci's stub mints credentials for any non-empty token and evaluates no
condition. It fails open.

So the solo path proves the trust is declared, pinned, checked twice and
watched, and it cannot prove a bad token is refused. This lesson runs the
call so the student sees the gap. The live section of the page is where the
refusal gets shown against a real account.

### 5i. Close the gap in the fork-PR check

**confirm**, then have the student add `id-token: write` under the
workflow-level `permissions:` block at the top of
`.github/workflows/access.yml`, the block above `jobs:`, and run

```sh
access/scripts/check workflow
```

```
FAIL  the workflow-level permissions block asks for id-token: write, which every job inherits, the pr job included
```

Say that before this lesson that edit passed, because lesson 6's check read
each job's own block and never the top of the file, and a grant at the top is
inherited by every job that does not override it, the `pr` job included.
Have the student delete the line and run the check again until it ends
`check passed`.

### 5j. Compare with the reference repo

The rule file and the fixtures are new, and untracked files do not appear in
a diff, so stage first.

```sh
git add -A access .github
git diff --cached --stat checkpoint/i9 -- access .github ':!*README.md'
```

Nothing printed means every file the student wrote is the reference file.
The `README.md` files are excluded and they are the only exclusions, prose
the reference tree carries about this lesson that no step asks the student
to write. If the diff names anything else, read the difference with the
student rather than pasting over it. The likeliest is a wildcard left in
`iam_role.site_publisher.tf` from step 5b, or the `id-token` line left in
the workflow from step 5i.

## 6. Done when

All five have to be true, and verify each one yourself rather than taking
earlier output on trust.

- `just access-check` ends `check passed` with `trust-subject-pinned (error)`
  and `trust-audience-pinned (error)` in its fixture stage.
- With `["repo:INTENTIUS/*"]` in the publisher's `subjects`,
  `terraform -chdir=access/envs/prod validate` refuses with a message naming
  prescription 12, and with the exact subject back it prints `Success!`.
- `aws iam get-role --role-name site-publisher` returns a trust whose
  principal is the actions provider ARN and whose `aud` and `sub` are both
  under `StringEquals`.
- After the two console edits `access/scripts/drift` exits 2 with two `page`
  findings, and after the apply it exits 0.
- `access/scripts/rotation` exits 0 on the applied estate and exits 2 under
  `--max-age-days 0` with a key made by hand.

If the fixture stage fails, the restart point is 5c or 5d. If validate does
not refuse the wildcard, the worktree is not at `checkpoint/i8` and the
restart point is 3. If the drift findings come back `pr`,
`access/scripts/drift` did not arrive in 5e. If rotation exits 1, Floci is
not answering and the restart point is 3.

## 7. Tear down

**confirm**, then

```sh
terraform -chdir=access/satellites/waterpark-runner destroy -auto-approve
terraform -chdir=access/envs/prod destroy -auto-approve
docker rm -f wp-i9-floci
```

Confirm the hand-made user is gone rather than assume it.

```sh
aws --endpoint-url http://localhost:4566 iam list-users --query 'Users[].UserName'
```

It prints `[]` if the container is still up, and a connection error if it is
already gone, and either is fine. Leave the `../waterpark-i9` worktree.
Lesson 10 starts a fresh one from `checkpoint/i9`.

## 8. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"i9"` to its `completed` array (creating the array if the file
somehow lacks one). Leave every other field untouched. Write it in the
original checkout rather than in the `../waterpark-i9` worktree.

```json
{"...": "...", "completed": ["start", "i1", "i2", "i3", "i4", "i5", "i6", "i7", "i8", "i9"]}
```

## 9. Hand off

Say the next step is IAM lesson 10, break-glass
(https://intentius.io/waterpark/courses/iam/10-break-glass/), where a grant
carries a cloud-side expiry a dead cleanup job can delay but never extend,
and where the signing material for that grant is the first static secret
this lesson's rotation check gets to age.
