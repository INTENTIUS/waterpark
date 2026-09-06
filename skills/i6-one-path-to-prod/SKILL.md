---
name: waterpark-i6-one-path-to-prod
description: Walk a student through IAM lesson 6, One path to prod. Use when they finished IAM lesson 5 and want lesson 6. Declares the waterpark-apply role and its OIDC trust anchor, proves on Floci that it cannot detach its own boundary, generates .github/CODEOWNERS from the principal files, writes the two-job access workflow whose PR job holds no credential, and turns the fork-PR property into a check that fails on an injected secret and on an injected id-token request.
---

# water park, IAM lesson 6, One path to prod

You are walking a student through IAM lesson 6, One path to prod
(https://intentius.io/waterpark/courses/iam/06-one-path-to-prod/). The outcome
is a repository where the pull request is the only way into the estate, with
generated review routing, a credential-free PR job, a gated apply job and
three checks that hold each of those facts. About 75 minutes.

This lesson never touches a real AWS account. Every command points at
`http://localhost:4566`, `floci` stays at its default of true, and the
`AWS_ACCESS_KEY_ID=test` pair is the throwaway the provider already uses
rather than a credential. Two steps read a finished GitHub Actions run with
`gh`, which is read only. If the student wants the live path, say it needs
`-var floci=false`, a real account for the OIDC tiers and `proofs --live`,
and that a facilitator runs it.

Confirm with the student before creating the worktree, before starting the
Floci container, before writing or copying any file under `access/` or
`.github/`, and before each apply and the teardown. Those steps are marked
**confirm**. Reads run freely, which is every `just access-check` stage,
`plan`, `show -json`, `render-delta`, `plan-digest`, `proofs`,
`prove-no-detach`, `get-role`, `gh run view` and `git diff`.

Never open a pull request, push a branch or write anything to GitHub in this
lesson. The two `gh run view` calls are reads of runs that already exist.

## 1. Say what this is

In two or three sentences say this is lesson 6 of the IAM course, that lesson
5 left a bounded estate a person applies from a laptop, and that this lesson
makes the pull request the only way in. Name the three things it closes,
which are generated CODEOWNERS, a credential-free PR check stack and an apply
role that cannot detach its own boundary. Link the lesson page above.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Also read `.waterpark/profile.json` at the checkout root if it exists. A
profile file is a claim from a previous run and the check's live calls are the
truth, so when they disagree believe the check. If `completed` does not carry
`"i5"`, say lesson 5 is where the boundary and the plan stage come from, and
offer to run this anyway since the checkpoint carries lesson 5's work.

Require `waterpark.checkout` true and `tools.docker.installed` true. The check
does not report `terraform`, `tflint`, `jq` or `gh`, so ask for those
directly.

```sh
terraform version
tflint --version
jq --version
gh auth status
```

Terraform 1.9 or newer, and any tflint that carries the OPA plugin. If tflint
is missing, the install line is `brew install terraform-linters/tap/tflint` on
macOS, and the release binary from
https://github.com/terraform-linters/tflint on Linux and Windows. `jq` is used
by `render-delta`, `plan-digest` and `proofs`. `gh` is used by 4j only,
and an unauthenticated `gh` still reads a public run, so a failing
`gh auth status` is not a blocker here.

Note the check's `floci.reachable`. It is usually false, because this lesson
starts its own container in step 3. If it is already true, ask whether that is
the compose stack from `just up` or a leftover from lesson 5, and prefer a
fresh container rather than a second one on the same port.

## 3. The starting point

**confirm**, then

```sh
git fetch origin --tags
git worktree add ../waterpark-i6 checkpoint/i5
cd ../waterpark-i6
just access-init
```

Every command after this runs from `../waterpark-i6`.

**confirm** again, then start Floci.

```sh
docker run -d --name wp-i6-floci -p 4566:4566 \
  -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
  ghcr.io/lex00/floci:iam-boundary

curl -s --retry 15 --retry-all-errors --retry-delay 1 \
  -o /dev/null -w '%{http_code}\n' http://localhost:4566/
```

The curl prints `200`. The retry flags are there because the container binds
the port before it answers on it, so the same curl without them prints `000`
the first time. Re-run `bash skills/start/check.sh` and require
`floci.reachable` true before going on.

**confirm**, then apply the bounded estate, so the plan stage has an account
to compare against.

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod apply -auto-approve
just access-check
```

Twenty resources, and `check passed`. If the check fails here, the student is
not on `checkpoint/i5` and the restart point is the worktree.

## 4. The lesson

### 4a. Copy what this lesson does not write

**confirm** before writing files, then

```sh
git checkout checkpoint/i6 -- \
  access/modules/persona \
  access/github \
  access/scripts/gen-codeowners \
  access/scripts/plan-digest \
  access/scripts/render-delta \
  access/scripts/proofs \
  access/scripts/prove-no-detach \
  access/.tflint.d/policies \
  access/tests/fixtures/boundary-required \
  access/tests/fixtures/path-matches-name \
  access/envs/prod/outputs.tf \
  scripts/check_md_links.py
```

Say what each one is and why it is not the lesson, using step 2 of the lesson
page. The short version.

- `modules/persona` gains `federated_trust`, the second trust shape a workload
  role can carry. It refuses a `*` in a subject and refuses a trust with no
  subject at all. Federation trust in general is lesson 9 and this lesson only
  consumes it.
- `access/github` is branch protection on `main` as code, live only.
- The five scripts are the pipeline's tools. The student runs four of them.
- `.tflint.d/policies` carries two rule changes with fixtures. `path-matches-name`
  now drops any known provider prefix. `boundary-required` now also fires on a
  principal file that makes a role and names no boundary, which is the build
  half of the double refusal lesson 8 needs.
- `envs/prod/outputs.tf` exports the apply role ARN, the boundary ARN and the
  two baseline constants.
- `scripts/check_md_links.py` learns to skip `.terraform`.

Do not run `just access-check` between this step and 4b. `outputs.tf` now
references a module that does not exist yet, which is the next thing the
student writes.

### 4b. The trust anchor and the apply role

**confirm**, then three files. The bodies are in step 3 of the lesson page,
which is `content/courses/iam/06-one-path-to-prod.md` in this checkout. Read
them from there rather than from memory, so the student's files and the page
agree exactly. Do not fetch them from a URL.

- `access/envs/prod/iam_openid_connect_provider.actions.tf`, the trust anchor.
  An OIDC provider is account scoped, so it lives in `waterpark-prod` beside
  the role that trusts it rather than in `access/identity`, which targets the
  management account (decision 54).
- `actions_oidc_host` in `access/envs/prod/variables.tf`, between
  `floci_endpoint` and `region`. One string, because it is the provider's URL
  and the prefix of both condition keys.
- `access/envs/prod/iam_role.waterpark_apply.tf`, the apply role. One
  repository, one branch, the audience pinned and the subject spelled out. It
  carries `permissions_boundary = module.baseline.boundary_arn` and no grants.

Read the cost comment in that last file with the student rather than past it.
The estate boundary denies all IAM write, so against a real account this role
could not apply the estate it exists to apply (decision 58). The taught path
never hits it because the job talks to Floci as `test` and never assumes the
role. A real account needs an apply-specific boundary that decision 36 has not
taken.

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod validate
```

`Success! The configuration is valid.` The `init` is needed because 4a changed
the persona module.

### 4c. Read what a reviewer would be asked to approve

The repo now declares two resources the account does not have, which is the
shape of a pull request. Reads run freely.

```sh
terraform -chdir=access/envs/prod plan -out=tfplan
terraform -chdir=access/envs/prod show -json tfplan > plan.json

access/scripts/render-delta plan.json
access/scripts/plan-digest plan.json
access/scripts/proofs plan.json
```

The delta names `+ waterpark-apply` under Principals,
`+ aws_iam_openid_connect_provider.actions` under Other resources, and says
`No grant changes. Nothing gains or loses access.` Say what that buys. The
plan says an `aws_iam_role` will be created, which is a fact about Terraform.
The delta says a new principal appears and no grant moves, which is a fact
about access.

`plan-digest` prints `sha256:` and sixty-four hex characters. Have the student
re-run the plan and the digest and watch the same string come back, because
the digest is over a normalised reading with the timestamp and the prior state
dropped rather than over the file. That stability is what the apply job leans
on.

`proofs` prints a skip naming the image and the date. Read it out rather than
skipping it. Access Analyzer answers `UnknownOperationException` on Floci, so
these proofs are live only, and a proof step that returned green on an
emulator answering nothing would be worse than no proof step.

### 4d. Apply, and prove the boundary holds

**confirm**, then

```sh
terraform -chdir=access/envs/prod apply -auto-approve

export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
aws --endpoint-url http://localhost:4566 iam get-role \
  --role-name waterpark-apply \
  --query 'Role.AssumeRolePolicyDocument.Statement[0]'
```

`Apply complete! Resources: 2 added, 0 changed, 0 destroyed.` Then the trust
document as IAM holds it, with `sts:AssumeRoleWithWebIdentity`, the `aud` and
`sub` condition keys named after the issuer host, and one exact subject.

```sh
access/scripts/prove-no-detach
echo $?
```

Twelve `ok` lines, `prove-no-detach passed. The apply role cannot detach its own
boundary.` and exit 0. Walk the sequence rather than the verdict, because the
controls are what make the refusal mean anything.

1. It reads the boundary off the applied role.
2. It shows the `test` key pair cannot assume `waterpark-apply` at all,
   because the trust names the issuer and not a key.
3. It mints a stand-in user with the same boundary and an allow-everything
   policy, then checks the credential works and can reach S3.
4. Only then it asks that credential to detach a boundary and gets
   `AccessDenied`.

Say why the stand-in exists. Floci honours trust policies and there is no web
identity token on a laptop, so nothing here can become the apply role. An
identity allowed everything and capped by the estate boundary is the apply
role's shape. The script deletes the user when it exits, and a credential
minted for a proof and destroyed at the end of it is not an estate identity.

### 4e. Generate the review routing

**confirm**, then write `access/codeowners.map`. The body is in step 6 of the
lesson page. Two lines of map under a comment saying why the file exists.

```sh
access/scripts/gen-codeowners
cat .github/CODEOWNERS
```

`wrote .github/CODEOWNERS`. Point out that it carries a line for
`iam_role.waterpark_apply.tf`, which the student wrote two steps ago and never
mentioned to CODEOWNERS.

Then show the routing following the estate. Change `teams` in
`access/envs/prod/iam_role.waterpark_apply.tf` from `["platform"]` to
`["course"]`, then

```sh
access/scripts/gen-codeowners --stdout | grep waterpark_apply
```

It prints `@INTENTIUS/course-authors`. That is the first half of prescription
5 standing rather than asserted. Put `["platform"]` back before going on, and
check that the student did.

Then the hand edit.

```sh
printf '/access/envs/prod/iam_role.waterpark_apply.tf @someone-else\n' >> .github/CODEOWNERS
access/scripts/gen-codeowners --check
echo $?
```

`gen-codeowners: .github/CODEOWNERS does not match the principal files.`, the
diff, `Run: access/scripts/gen-codeowners` and `1`. The quietest way to change
who approves access is a one-line edit to a dotfile nobody reads, and this is
what makes it loud. That same call becomes a stage of the check stack in 4g,
which is why it is not `check codeowners` yet. Then

```sh
access/scripts/gen-codeowners
```

### 4f. The workflow's shape

**confirm**, then have the student write `.github/workflows/access.yml` with
the skeleton in step 7 of the lesson page. It is short on purpose. The
argument is about what the two jobs are allowed to be rather than what they
do.

Say the four things that are the lesson.

- The `pr` job names no secret and asks for no `id-token`, so there is no
  credential a fork PR can reach.
- Its AWS is a Floci service container in its own job, so it needs no account
  to plan against (decision 51).
- The `apply` job carries `if: github.event_name == 'push'`, so it does not
  run on a pull request at all rather than running and refusing.
- `environment: prod` is the gate a maintainer attaches required reviewers to.

`GITHUB_TOKEN` is not a secret in that sense and the job uses it as
`github.token`. On a fork PR GitHub issues it read-only whatever the workflow
asks, and the `permissions` block caps it at `contents: read` besides.

### 4g. The fork-PR check

**confirm**, then have the student edit `access/scripts/check`. The exact
snippets and where each goes are in step 8 of the lesson page. There are six
edits.

1. The header usage block, now five stages and one option.
2. `github` added to the `roots` array after `identity`, with the rewritten
   comment above it.
3. `run_codeowners`, straight after `run_fixtures`.
4. `run_workflow`, after that and before the `floci_endpoint` line.
5. The `2)` arm of `run_plan`, which now asks `plan_mode`.
6. The `plan_mode` declaration and argument loop before the dispatch, and the
   two new dispatch arms with the new usage line.

The file is tab indented. If the student's paste turns tabs into spaces, the
script still runs and the checkpoint compare in 4j will name the file, so say
this now rather than at the end.

`run_workflow` is the piece that matters. It treats every job not gated to
`push` as reachable from a pull request, because that is what GitHub does, and
fails one that names `secrets.` or asks for `id-token: write`. Those are the
two ways a cloud credential gets into a job an untrusted author triggers.

### 4h. Break the workflow twice

Reads run freely.

```sh
access/scripts/check workflow
```

`ok    no job reachable from pull_request names a secret or asks to federate`.

**confirm**, then have the student put a cloud credential where a fork could
reach it, by adding an `env` block to the `pr` job's check step.

```yaml
      - name: The check stack
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        run: access/scripts/check --plan-mode ci
```

```sh
access/scripts/check workflow
```

`FAIL  job pr runs on pull_request and names a secret`. Have them take it out,
then add `id-token: write` to the `pr` job's `permissions` block and run the
same command. `FAIL  job pr runs on pull_request and asks for id-token:
write`. Have them take that out too, and verify the file is back by running
`access/scripts/check workflow` once more.

If the student is curious, move either edit into the `apply` job and watch the
check stay quiet. That is correct, because a pull request cannot reach a job
gated to `push`.

### 4i. The rest of the workflow, then the whole stack

**confirm**, then

```sh
git checkout checkpoint/i6 -- .github/workflows/access.yml
just access-check
```

Say what the checkout added, which is the body of the two jobs rather than
their shape. The `pr` job gains the wait loop, the terraform and tflint setup,
the step that applies the pull request's base sha into its Floci and carries
the state across, the saved plan and its digest, the satellite plan loop, the
delta, the proofs, the guardrail severity block, the job summary, the label
and comment attempts and the artifact upload. The `apply` job gains the step
that resolves which pull request this commit closed, the artifact download by
head sha, the rebuild from the same base, the re-plan, the digest comparison
and the convergence check.

`check passed`, with `ok    .github/CODEOWNERS matches the principal files`,
`ok    no job reachable from pull_request names a secret or asks to federate`
and `ok    envs/prod matches the account, exit 0`.

Now that the routing has a stage of its own, **confirm** and do the hand edit
from 4e once more against it.

```sh
printf '/access/envs/prod/iam_role.waterpark_apply.tf @someone-else\n' >> .github/CODEOWNERS
access/scripts/check codeowners
access/scripts/gen-codeowners
access/scripts/check codeowners
```

`FAIL  .github/CODEOWNERS was hand edited or a principal file moved`, then
`ok    .github/CODEOWNERS matches the principal files`. That is the second
half of prescription 5, running in CI on every pull request rather than only
when somebody remembers.

### 4j. Read the path running for real

Nothing on a laptop shows two jobs choosing not to run. These are reads of
runs this repository already has.

```sh
gh run view 34011731889 --repo INTENTIUS/waterpark
gh run view 34011867194 --repo INTENTIUS/waterpark
```

The first is a `pull_request` run where `pr` ran and `apply` shows `0s`, with
the artifact `access-plan-170a2586358d6a62e0d9f0fc3dc31427b23c21bb` listed
under it, keyed by that branch's head commit. The second is the push to main
that merged it, where `apply` ran and `pr` shows `0s`.

```sh
gh run view 34011731889 --repo INTENTIUS/waterpark --log |
  grep -v '36;1m' | grep 'The check stack'
```

The same stage names and the same `ok` lines the student just ran, with one
difference. The plan stage reads
`ok    envs/prod plans the change this branch proposes, exit 2` rather than
`exit 0`, because that job filled its Floci from the base branch and a diff
there is the pull request. That is `--plan-mode ci`.

```sh
gh run view 34011867194 --repo INTENTIUS/waterpark --log |
  grep -v '36;1m' |
  grep -E "rebuilds its account|head was|pr job ran as|approved  sha256|recomputed sha256|plan being applied"
```

Six lines. The apply job resolved the merged pull request, rebuilt the same
account from the same base commit, re-planned, and only then compared the two
digests. Say the point. An approval that binds to a number somebody else
calculated binds to nothing, so the apply job recomputes. Two identical inputs
give the same digest by construction, and a mismatch means something actually
moved.

Say the honesty line too. That apply ran against a service container that died
with the job, so it proves the pipeline and the refusal and nothing about
persistence in an account (decision 51).

The whole `pr` job summary, with the severity block, the access delta, the
proof verdict and the digest, is at
https://github.com/INTENTIUS/waterpark/actions/runs/34011731889 for a student
who wants to see it rendered.

### 4k. Compare with the reference repo

The plan artifacts are not part of the tree, and most of what the student
added is new files, so remove the artifacts and stage first.

```sh
rm -f plan.json access/envs/prod/tfplan
git add -A access .github scripts
git diff --cached --stat checkpoint/i6 -- access .github scripts ':!access/README.md'
```

Nothing printed means every file the student wrote is the reference file.
`access/README.md` is excluded because the reference repo's prose for
`access/` describes lessons 7 and 8 as well, and none of it is something this
lesson writes. If the diff names `access/scripts/check`, the likely cause is
spaces where the file uses tabs. If it names anything else, read the
difference with the student rather than pasting over it.

## 5. Done when

All five have to be true, and verify each one yourself rather than taking
earlier output on trust.

- `just access-check` passes, and its output carries
  `ok    .github/CODEOWNERS matches the principal files` and
  `ok    no job reachable from pull_request names a secret or asks to federate`.
- `access/scripts/check codeowners` fails on a hand-edited `.github/CODEOWNERS`
  and passes again after `access/scripts/gen-codeowners`.
- Changing the apply role's `teams` reroutes its line in
  `gen-codeowners --stdout` with nobody editing `.github/CODEOWNERS`.
- `access/scripts/check workflow` fails with
  `job pr runs on pull_request and names a secret` when a secret is injected
  into the `pr` job, and with
  `job pr runs on pull_request and asks for id-token: write` when
  `id-token: write` is, and passes with neither present.
- `access/scripts/prove-no-detach` exits 0, and its output shows
  `iam:DeleteRolePermissionsBoundary on waterpark-apply is denied` and
  `iam:PutRolePermissionsBoundary on waterpark-apply is denied, so it cannot
  be swapped either`.

If `check workflow` fails when nothing is injected, the restart point is 4h
and one of the two edits is still in the file. If `check codeowners` fails
after a regenerate, the restart point is 4e and a principal file's `teams` did
not go back. If `prove-no-detach` reports the boundary is not applied, the
restart point is 4d. If `get-role` returns a null boundary on a role Terraform
says it bounded, the container is the upstream image rather than the fork, so
restart from step 3 with `ghcr.io/lex00/floci:iam-boundary`.

## 6. Tear down

**confirm**, then

```sh
terraform -chdir=access/envs/prod destroy -auto-approve
docker rm -f wp-i6-floci
```

Leave the `../waterpark-i6` worktree. Lesson 7 starts a fresh one from
`checkpoint/i6`.

## 7. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"i6"` to its `completed` array (creating the array if the file
somehow lacks one). Leave every other field untouched. Write it in the
original checkout rather than in the `../waterpark-i6` worktree.

```json
{"...": "...", "completed": ["start", "i1", "i2", "i3", "i4", "i5", "i6"]}
```

## 8. Hand off

Say the next step is IAM lesson 7, drift
(https://intentius.io/waterpark/courses/iam/07-drift/), which takes the
estate this lesson made a pipeline for and asks the harder question, which is
what happens when the account moves and the repo does not.
