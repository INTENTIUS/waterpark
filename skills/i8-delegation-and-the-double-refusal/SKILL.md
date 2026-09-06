---
name: waterpark-i8-delegation-and-the-double-refusal
description: Walk a student through IAM lesson 8, Delegation and the double refusal. Use when they finished IAM lesson 7, or lesson 5, and want lesson 8. Builds the waterpark-runner satellite as a sibling root with its own registry, moves runner-builder out of envs/prod, reads the central boundary live by name, mints a deploy credential conditioned on iam:PermissionsBoundary, and strips the boundary to get refused twice, by the rule pack at build and by IAM at apply.
---

# water park, IAM lesson 8, Delegation and the double refusal

You are walking a student through IAM lesson 8, Delegation and the double
refusal
(https://intentius.io/waterpark/courses/iam/08-delegation-and-the-double-refusal/).
The outcome is a satellite that declares its own registry and its own role
inside a boundary it does not own, and a proof that stripping that boundary is
refused twice by two things that have never heard of each other. About 50
minutes.

This lesson never touches a real AWS account. Every command points at
`http://localhost:4566`, `floci` stays at its default of true, and the
`AWS_ACCESS_KEY_ID=test` pair is the throwaway the provider already uses
rather than a credential. The one credential this lesson does mint is an IAM
user on the emulator, created and deleted by a script in the same run. If the
student wants to run this against a real account, say that is the live path,
that it needs `-var floci=false` and the S3 backend, and that a facilitator
runs it.

Confirm with the student before creating the worktree, before starting the
Floci container, before writing any file under `access/`, before the
`git checkout` that brings in the scripts, before each apply and destroy,
before minting the deploy credential, and before the teardown. Those steps are
marked **confirm**. Reads run freely, which is every `just access-check`
stage, `plan`, `get-role`, `get-policy`, `satellite-source show` and
`git diff`.

## 1. Say what this is

In two or three sentences say this is lesson 8 of the IAM course, that lessons
1 through 7 built one estate one team owns, and that this lesson hands one
role to somebody else and proves that handing it over gave nothing away. Say
what makes it safe, which is that a boundary caps what an identity-based
policy can grant and IAM lets a credential be allowed `iam:CreateRole` only
when `iam:PermissionsBoundary` equals a named ARN. Role creation
decentralizes and authority does not. Link the lesson page above.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Also read `.waterpark/profile.json` at the checkout root if it exists. A
profile file is a claim from a previous run and the check's live calls are the
truth, so when they disagree believe the check. If `completed` does not carry
`"i7"`, say that the checkpoint carries lesson 7's work anyway and offer to
run this. If it does not carry `"i5"` either, say lesson 5 is where the
boundary comes from and this lesson is mostly about that boundary, and offer
to run it anyway.

Require `waterpark.checkout` true and `tools.docker.installed` true. The check
does not report `terraform`, `tflint` or `jq`, so ask for those directly.

```sh
terraform version
tflint --version
jq --version
```

Terraform 1.9 or newer, any tflint that carries the OPA plugin, and any jq.
If tflint is missing, the install line is
`brew install terraform-linters/tap/tflint` on macOS, and the release binary
from https://github.com/terraform-linters/tflint on Linux and Windows. `jq`
is `brew install jq`, `apt install jq` or `winget install jqlang.jq`, and both
`mint-satellite-credential` and `double-refusal` need it.

Note the check's `floci.reachable`. It is usually false here, because this
lesson starts its own container in step 3. If it is already true, ask whether
that is the compose stack from `just up` or a leftover from an earlier lesson.
A leftover Floci holds an earlier lesson's estate, and the local state in the
new worktree will not know about it, so prefer a fresh container.

## 3. The starting point

**confirm**, then

```sh
git fetch origin --tags
git worktree add ../waterpark-i8 checkpoint/i7
cd ../waterpark-i8
just access-init
```

Every command after this runs from `../waterpark-i8`.

**confirm** again, then start Floci.

```sh
docker run -d --name wp-i8-floci -p 4566:4566 \
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

The image matters more here than anywhere except lesson 5, and for a worse
reason. Upstream Floci 2.0.1 never populates the `iam:PermissionsBoundary`
condition key, so a policy conditioned on it denies `CreateRole` with the
boundary and without it. On that image step 9's refusal still prints, and it
means nothing, because every call is refused. The fork build fixes it. Say
this to the student now rather than at the end.

## 4. Apply the central estate, and look at the role about to move

**confirm**, then

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod apply -auto-approve
```

Twenty two resources. Then

```sh
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1

aws --endpoint-url http://localhost:4566 iam get-role \
  --role-name runner-builder \
  --query 'Role.[RoleName,PermissionsBoundary.PermissionsBoundaryArn]'

grep runner_builder .github/CODEOWNERS
```

The first prints the role and the central boundary ARN. The second prints
`/access/envs/prod/iam_role.runner_builder.tf @INTENTIUS/platform`. Keep both.
Step 5c shows the same file under a different path owned by a different team,
and the boundary ARN unmoved, and that pair is the point of the lesson.

## 5. The lesson

### 5a. Write the satellite root

**confirm** before writing files, then create
`access/satellites/waterpark-runner/` with ten files, `versions.tf`,
`provider.tf`, `variables.tf`, `locals.tf`, `backend.local.tf`, `data.tf`,
`ecr_repository.waterpark_runner.tf`, `iam_role.runner_builder.tf`,
`outputs.tf` and `.tflint.hcl`.

The bodies are in step 2 of the lesson page, which is
`content/courses/iam/08-delegation-and-the-double-refusal.md` in this
checkout. Read them from there rather than from memory, so the student's files
and the page agree exactly. Do not fetch them from a URL.

While the student writes them, say what each one is buying.

- `versions.tf` is the same pins every other root carries, nothing new.
- `provider.tf` is `envs/prod`'s provider plus two things. `ecr` joins the
  endpoint overrides because this root declares a registry, and
  `credentials_from_env` is how the root is pointed at a credential that is
  not the account root, which step 9 needs so that a refusal is a refusal of
  the satellite. The `satellite` default tag is how central reconcile tells a
  foreign resource from a drifted one.
- `variables.tf` holds `boundary_name`, the deterministic name the satellite
  looks the boundary up by, and `credentials_from_env`.
- `locals.tf` is one line. `owner = "runner"`, and nobody in platform is in
  this file.
- `backend.local.tf` is the same solo-path state file every root keeps.
- `data.tf` is half of the delegation contract. It reads the boundary live by
  name, not `terraform_remote_state`, which would hand a satellite read access
  to central state, and not a copied ARN, which goes stale. A satellite that
  plans before central applied the boundary fails, which is the right order
  made unavoidable.
- `ecr_repository.waterpark_runner.tf` is the resource the satellite exists to
  own, with immutable tags because a movable image tag is an artifact that
  cannot be trusted.
- `iam_role.runner_builder.tf` is the whole leaf file, one module call and
  three grants, exactly the shape lesson 2 gave a central principal file. The
  `permissions_boundary` line is what the whole lesson turns on.
- `outputs.tf` exports the registry URL, the roles, the grants for the drift
  watch, and the boundary ARN it consumed.
- `.tflint.hcl` is the other half of the contract. The satellite runs the
  central rule pack, delivered by `TFLINT_OPA_POLICY_DIR` rather than by a
  source line, because the OPA ruleset has no git source of its own. Point at
  the commented clone at a depth of one on a tag and say that is prescription
  10's delivery mechanism, since the ref is what makes a `warn_` becoming a
  `deny_` a deliberate move rather than a surprise.

### 5b. Take runner-builder out of central

**confirm**, then

```sh
rm access/envs/prod/iam_role.runner_builder.tf
```

Then have the student edit `access/envs/prod/outputs.tf`, deleting the
`runner_builder` line from `roles` and the `runner-builder` line from
`grants`, and adding the four-line comment at the top of the file. The body is
in step 3 of the lesson page. Say why the comment is there, which is that a
deletion with no note is the kind of change somebody undoes assuming it was an
accident.

### 5c. Bring in the pieces the lesson does not write, and reroute the review

**confirm**, then

```sh
git checkout checkpoint/i8 -- \
  access/scripts/satellite-source \
  access/scripts/mint-satellite-credential \
  access/scripts/double-refusal \
  access/scripts/check \
  access/scripts/gen-codeowners \
  access/modules/persona/locals.tf \
  access/modules/persona/iam_policy.grant.tf \
  access/modules/persona/variables.tf \
  access/.gitignore
```

Walk the student through what each one is, from step 4 of the page. The three
`modules/persona` files are the `push` grant level, which carries
`ecr:GetAuthorizationToken` as its own statement because the API refuses to
scope it to a resource, and every other level renders exactly the one
statement it always did. `access/scripts/check` gains six lines that pick up
any directory under `satellites/` holding a `versions.tf`, for lint, validate
and a plan after `envs/prod`.

**confirm**, then add one line plus its two comment lines to the bottom of
`access/codeowners.map`. The body is in step 5 of the page. Then

```sh
access/scripts/gen-codeowners
grep runner .github/CODEOWNERS
```

It prints
`/access/satellites/waterpark-runner/iam_role.runner_builder.tf @INTENTIUS/waterpark-runner`,
where step 4 printed the same file under `envs/prod` owned by platform. Nobody
edited CODEOWNERS. The leaf file said `teams = ["runner"]` and the generator
did the rest, which is decision 21 working across a trust boundary rather than
inside one.

### 5d. Apply, in the order that is forced

**confirm**, then central first.

```sh
terraform -chdir=access/envs/prod apply -auto-approve
```

`Apply complete! Resources: 0 added, 0 changed, 5 destroyed.` The role, two
grant policies and two attachments leave the central account, and for a moment
the estate has no `runner-builder` at all.

**confirm**, then the satellite.

```sh
terraform -chdir=access/satellites/waterpark-runner init
terraform -chdir=access/satellites/waterpark-runner apply -auto-approve
terraform -chdir=access/satellites/waterpark-runner plan -detailed-exitcode
echo $?
```

Eight resources added, then "No changes." and `0`. Reads run freely from here.

```sh
aws --endpoint-url http://localhost:4566 iam get-role \
  --role-name runner-builder --query 'Role.PermissionsBoundary'
```

It returns `arn:aws:iam::000000000000:policy/waterpark-estate-boundary`. Ask
the student to grep the satellite directory for that ARN before you say
anything. It is not there. `data.tf` asked the account for a policy by name
and the module put what came back on the role.

If the satellite apply fails on the data source, central has not applied the
boundary. That is the correct failure and the restart point is the central
apply above.

### 5e. The check stack, with a satellite in it

```sh
just access-check
```

`access/satellites/waterpark-runner` appears under validate, under tflint and
under the plan, and the run ends `check passed`. Nothing was added to a list
of roots by hand. The satellite joined by holding a `versions.tf`, which is
what makes a second satellite free.

### 5f. Mint the deploy credential

**confirm**, then

```sh
access/scripts/mint-satellite-credential
```

Read the summary with the student before using the key.
`iam:CreateRole` and `iam:PutRolePermissionsBoundary` allowed only under
`StringEquals iam:PermissionsBoundary` equal to the central boundary ARN,
`iam:DeleteRolePermissionsBoundary` denied outright, and the rest ordinary.

Say the two things about this credential that a student will otherwise ask
later. It is an IAM user in a course whose fifth decision bans IAM users,
because a satellite in the world federates through its own issuer and there is
no OIDC subject on a laptop to bind to, and Floci honors trust policies so a
role trusting an issuer is a role nothing here can become. It is minted and
deleted by a script and never declared, so the rule and the decision both
hold, and lesson 9 builds the issuer side for real. And it does not carry the
estate boundary itself, deliberately, because that boundary denies all IAM
write and a credential inside it could not create the role the satellite
exists to create. Its cap is the condition instead.

Do not print the secret key into a chat log the student is sharing. It is an
emulator key that is deleted at the end of step 5g, but the habit is the
lesson.

### 5g. The double refusal

**confirm**, then

```sh
access/scripts/double-refusal
```

Say what it works on first, which is a copy of the satellite root with the
role and the registry renamed with a `-proof` suffix, so it creates and
destroys its own resources without touching the applied satellite.

Four things happen and all four matter.

The control. It applies the copy as the deploy credential with the boundary in
place, and the role reads back carrying the central ARN. Without this the
refusals prove only that a credential was broken.

Refusal one, at build.

```
      the boundary line is gone, 1 before and 0 after
ok    the rule pack refuses the build
      Error - module "runner_builder" declares a role and names no permissions_boundary. Add permissions_boundary = module.baseline.boundary_arn, or the central boundary ARN a satellite consumes, so the role cannot be made more powerful than the estate allows. (opa_deny_boundary_required)
```

That message comes from the clause lesson 6 added to `boundary-required`, the
one that fires on a module call in an `iam_role.*.tf` file. tflint reads the
calling directory only, so the role inside the module is invisible and the
file name is what says this call produces one.

Refusal two, at apply, with the linter switched off.

```
ok    IAM refuses the call
      AccessDenied: User is not authorized to perform: iam:CreateRole
      not authorized to perform: iam:CreateRole
ok    no unbounded role was created
```

Then it restores, reapplies the real satellite, deletes the credential and
confirms `runner-builder` carries the boundary again, and prints

```
double-refusal passed. Refused at build by the checks and at apply by IAM,
independently, with nobody from platform involved either time.
```

Ask the student which refusal they would keep if they could only have one.
Most people say the linter, because it is the one they would feel. The linter
is defeated by anyone willing to edit a Rego file or pass `--disable-rule`.
The condition sits on a policy attached to a credential the satellite does not
control, and nothing in a satellite repository can reach it.

If the script prints `skip`, either Floci is not answering or the boundary is
not applied, and the restart point is 3 or 5d. If refusal two prints a failure
saying the apply was not refused, the container is the upstream image rather
than the fork, so restart from step 3 with
`ghcr.io/lex00/floci:iam-boundary`.

### 5h. The pinned form, and the separate repo

```sh
access/scripts/satellite-source show
```

It prints `../../modules/persona` and says nothing is fetched. Show the two
switching commands from step 10 of the page, and say the pinned form needs
network and a tag that exists, so leave it on `local`. Terraform takes no
variable in a module source, so this is a file rewrite, the same mechanism as
`access/scripts/backend`.

Then cover what a separate GitHub repository would change, which is in step 10
of the page. Its own PR job running a vendored pack, its own CODEOWNERS, a
deploy credential minted centrally and handed over as a federated role, and
both pins moving together in one PR so a bump shows which new warnings appear
before anything merges. What does not change is the mechanism, and that is why
this repo can teach the lesson without a second repo.

### 5i. Compare with the reference repo

The satellite is new and untracked files do not appear in a diff, so stage
first.

```sh
git add -A access .github
git diff --cached --stat checkpoint/i8 -- access .github ':!*README.md'
```

Nothing printed means every file the student wrote is the reference file. Four
`README.md` files are excluded and they are the only exclusions, `access/`,
`access/.tflint.d/`, `access/modules/persona/` and the satellite's own, all of
them prose the reference tree carries about this lesson that no step asks the
student to write. If the diff names anything else, read the difference with
the student rather than pasting over it.

## 6. Done when

All four have to be true, and verify each one yourself rather than taking
earlier output on trust.

- `access/scripts/double-refusal` exits 0 and its last two lines say it was
  refused at build by the checks and at apply by IAM.
- Refusal one shows `opa_deny_boundary_required` firing on the leaf file whose
  `permissions_boundary` line was deleted.
- Refusal two shows `AccessDenied` on `iam:CreateRole` with the linter off,
  followed by `ok    no unbounded role was created`.
- The satellite came back. `just access-check` ends on
  `ok    satellites/waterpark-runner matches the account, exit 0` and

  ```sh
  aws --endpoint-url http://localhost:4566 iam get-role \
    --role-name runner-builder --query 'Role.PermissionsBoundary'
  ```

  returns the `waterpark-estate-boundary` ARN.

If the check fails on tflint, the restart point is 5a, most likely the
`permissions_boundary` line in the leaf file. If a plan exits 2, the restart
point is 5d. If `double-refusal` skips, the restart point is 3 or 5d. If
refusal two does not fire, the restart point is 3 with the fork image.

## 7. Tear down

**confirm**, then

```sh
terraform -chdir=access/satellites/waterpark-runner destroy -auto-approve
terraform -chdir=access/envs/prod destroy -auto-approve
docker rm -f wp-i8-floci
```

`double-refusal` already deleted the deploy credential, so confirm rather than
assume.

```sh
aws --endpoint-url http://localhost:4566 iam list-users --query 'Users[].UserName'
```

It prints `[]`. Leave the `../waterpark-i8` worktree. Lesson 9 starts a fresh
one from `checkpoint/i8`.

## 8. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"i8"` to its `completed` array (creating the array if the file
somehow lacks one). Leave every other field untouched. Write it in the
original checkout rather than in the `../waterpark-i8` worktree.

```json
{"...": "...", "completed": ["start", "i1", "i2", "i3", "i4", "i5", "i6", "i7", "i8"]}
```

## 9. Hand off

Say the next step is IAM lesson 9, federation trust
(https://intentius.io/waterpark/courses/iam/09-federation-trust/), which
builds the issuer side of the credential this lesson stood in for with an IAM
user, so a satellite's deploy role is assumed by a workload that proves who it
is rather than by a key on a laptop.
