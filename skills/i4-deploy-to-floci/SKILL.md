---
name: waterpark-i4-deploy-to-floci
description: Walk a student through IAM lesson 4, Deploy to Floci. Use when they finished IAM lesson 3 and want lesson 4. Applies the access repo against a local Floci with no AWS account, proves convergence with plan -detailed-exitcode, reads a role back with aws iam get-role, and adds the credential-free plan stage to the check stack.
---

# water park, IAM lesson 4, Deploy to Floci

You are walking a student through IAM lesson 4, Deploy to Floci
(https://intentius.io/waterpark/courses/iam/04-deploy-to-floci/). The outcome
is the estate applied against a local emulator with no AWS account anywhere,
a plan that exits 0, one role read back out of the cloud and matched against
the file that declared it, and the same plan wired into the check stack a PR
job runs. About 30 minutes.

This lesson never touches a real AWS account. Every command below points at
`http://localhost:4566`, the `terraform` runs keep `floci` at its default of
true, and the `AWS_ACCESS_KEY_ID=test` pair is the throwaway the provider
already uses rather than a credential. If the student asks to run any of this
against a real account, stop and say that is the live path, that it needs
`-var floci=false` and the S3 backend, and that a facilitator runs it.

Confirm with the student before creating the worktree, before starting the
Floci container, before applying, before editing `access/scripts/check`, and
before the teardown. Those steps are marked **confirm**. Reads run freely,
which is `plan`, `get-role`, `git diff` and every `just access-check` stage.

## 1. Say what this is

In two or three sentences say this is lesson 4 of the IAM course, that
lessons 1 to 3 declared an estate and checked it without ever talking to a
cloud, and that this is where it runs. Say the target is Floci, which runs
the AWS APIs in process, so the Terraform is real, the IAM is real and the
account is not. Link the lesson page above.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Also read `.waterpark/profile.json` at the checkout root if it exists. A
profile file is a claim from a previous run and the check's live calls are
the truth, so when they disagree believe the check.

Require, before doing anything else, `waterpark.checkout` true and
`tools.docker.installed` true. The check does not report `terraform` or
`tflint`, so ask for those two directly.

```sh
terraform version
tflint --version
```

Terraform 1.9 or newer, and any tflint that carries the OPA plugin. If
tflint is missing, the install line is `brew install terraform-linters/tap/tflint`
on macOS, and the release binary from
https://github.com/terraform-linters/tflint on Linux and Windows.

Note the check's `floci.reachable`. It will usually be false at this point,
because the lesson starts its own container in step 4. If it is already true,
ask whether that is the compose stack from `just up` or a container from an
earlier lesson, and reuse it rather than starting a second one on the same
port.

## 3. The starting point

**confirm**, then create the worktree. The student's own branch stays where
it is and the lesson works on the checkpoint lesson 3 left.

```sh
git fetch origin --tags
git worktree add ../waterpark-i4 checkpoint/i3
cd ../waterpark-i4
just access-init
```

Every command after this runs from `../waterpark-i4`. `just access-init` is
`cd access && tflint --init`, which installs the OPA ruleset the rule pack
runs on. It prints "All plugins are already installed" when the student has
done it before, and that is fine.

If `git worktree add` fails because the path exists, offer a different
directory name rather than removing whatever is there.

## 4. Start Floci

**confirm**, then

```sh
docker run -d --name wp-i4-floci -p 4566:4566 \
  -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
  ghcr.io/lex00/floci:iam-boundary

curl -s --retry 15 --retry-all-errors --retry-delay 1 \
  -o /dev/null -w '%{http_code}\n' http://localhost:4566/
```

The curl prints `200`. The retry flags are there because the container binds
the port before it answers on it, so the same curl without them prints `000`
the first time. Say before running it that this starts a container and pulls
an image the first time.

The image is a patched fork build rather than the upstream Floci release.
Upstream 2.0.1 never returns a role's permission boundary on read, which
makes a bounded estate replan forever, and lesson 5 depends on the fix. The
compose stack pulls the same image and `compose/README.md` explains it.

Re-run `bash skills/start/check.sh` and require `floci.reachable` true before
going on. That is the check reporting it rather than you assuming it.

## 5. The lesson

### 5a. Init, and name the state file

**confirm**, then

```sh
terraform -chdir=access/envs/prod init
```

It prints `Successfully configured the backend "local"`, two lines in.

Say the cost out loud here, because it is half of what this lesson teaches.
Terraform hosts a state file. Accessible Ops XI says the live system is the
truth and counts a tool that hosts its own state against it, and water park
does not pretend otherwise (decision 32). The file is
`access/envs/prod/terraform.tfstate`, it is gitignored, it is bookkeeping and
never the system of record, and on the live path
`access/scripts/backend s3 envs/prod` puts it in the
`waterpark-terraform-state` bucket in `waterpark-security` with locking.
Every read in the rest of this lesson goes to the cloud instead of to that
file.

### 5b. Apply

**confirm**, then

```sh
terraform -chdir=access/envs/prod apply -auto-approve
```

Nineteen resources land. Three workload roles, the grant policies
`modules/persona` expands from each leaf file's access levels, an attachment
per grant, and the two buckets. Point out that no credential was asked for
and no account exists.

If the apply stops partway, say what actually happened rather than retrying
blindly. A failed apply leaves behind what it already made, with no rollback.
Read the error, fix the one thing, and apply again.

### 5c. Prove it converged

Reads run freely.

```sh
terraform -chdir=access/envs/prod plan -detailed-exitcode
echo $?
```

Expect "No changes. Your infrastructure matches the configuration." and `0`.
`-detailed-exitcode` exits 0 for no changes, 2 for a diff and 1 for an error,
so a green apply that has not converged prints `2` here rather than being
believed.

If it prints `2`, show the student the diff the plan printed and stop. Do not
apply again to make the number go away.

### 5d. Read a role back out of the cloud

```sh
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 \
  aws --endpoint-url http://localhost:4566 iam get-role --role-name site-publisher
```

Open `access/envs/prod/iam_role.site_publisher.tf` and walk the two side by
side. `RoleName` is the `name`. `Description` is the `description`, word for
word. The `owner`, `persona` and `teams` tags are what `modules/persona`
builds. `managed_by`, `repo` and `env` come from the provider's
`default_tags`. `AssumeRolePolicyDocument` trusts `codebuild.amazonaws.com`,
which is the module's `trusted_services` default rather than anything the
leaf file said. `PermissionsBoundary` is absent, and that is lesson 5.

Say that the three `test` variables are the throwaway pair the provider
already uses. They are not a credential.

### 5e. Add the plan to the check stack

**confirm** before editing the file, then have the student open
`access/scripts/check` and add this stage after `run_fixtures`.

```sh
floci_endpoint="${FLOCI_ENDPOINT:-http://localhost:4566}"

# The plan a PR job runs. It reaches Floci and no cloud, so it holds no
# credential, which is the half of prescription 6 lesson 4 closes. Skipped
# with a line rather than a failure when Floci is not up, because the rest of
# the stack is still worth running.
run_plan() {
	say "== terraform plan against Floci"
	if [ "$(curl -s -o /dev/null -m 3 -w '%{http_code}' "$floci_endpoint/" 2>/dev/null)" = "000" ]; then
		say "skip  Floci is not answering on $floci_endpoint. Start it with:"
		say "      docker run -d --name wp-access-floci -p 4566:4566 \\"
		say "        -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \\"
		say "        ghcr.io/lex00/floci:iam-boundary"
		return
	fi

	terraform -chdir=envs/prod init -input=false -no-color >/dev/null 2>&1
	terraform -chdir=envs/prod plan -detailed-exitcode -input=false -no-color >/dev/null 2>&1
	case $? in
	0) ok "envs/prod matches the account, exit 0" ;;
	2) fail "envs/prod has an unapplied diff. Run terraform -chdir=access/envs/prod plan" ;;
	*) fail "terraform plan against Floci errored" ;;
	esac
}
```

Then four small wiring edits in the same file. Add `plan) run_plan ;;` to
the `case` at the bottom, under `fixtures) run_fixtures ;;`. Add `run_plan`
as the last line of the `all` branch. Change the usage string to
`usage: access/scripts/check [all|fmt|validate|lint|fixtures|plan]`. And in
the comment header at the top of the file, add `, plan` to the end of the
first line and this line under the `fixtures` one, spaced to line up with it.

```sh
#   access/scripts/check plan       just the credential-free plan against Floci
```

The file is tab indented. Keep it that way, because `terraform fmt` does not
touch it but a mixed-indent shell function is a nuisance to read.

Now run it.

```sh
just access-check plan
just access-check
```

The first prints `ok    envs/prod matches the account, exit 0`. The second
runs fmt, validate, tflint, the rule fixtures and the plan, and ends on
`check passed`. One warning survives, `aws_iam_role.this carries no
permissions_boundary` on `modules/persona`. It is a warning rather than an
error because the boundary it asks for does not exist yet, and lesson 5
builds it and promotes the rule.

Say that nothing in `just access-check` holds a credential. That is the half
of prescription 6 this lesson closes.

### 5f. Compare with the reference repo

```sh
git diff checkpoint/i4 -- access
```

The only file left is `access/README.md`, which is the prose the reference
repo carries for the same steps. If anything under `access/scripts` still
differs, the wiring in 5e is incomplete, so read the diff with the student
and fix it there.

## 6. Done when

Both of these have to be true, and verify them yourself rather than taking
the earlier output on trust.

- `terraform -chdir=access/envs/prod plan -detailed-exitcode` exits 0 straight
  after the apply, with no AWS credential in the environment and no account
  behind it. Run it again and read `echo $?`.
- `aws iam get-role --role-name site-publisher`, against
  `--endpoint-url http://localhost:4566`, returns the `RoleName`,
  `Description` and `owner` tag that
  `access/envs/prod/iam_role.site_publisher.tf` declared. Read the file and
  the response and say which three values you compared.

If the plan exits 2, the restart point is 5b, apply again and re-read the
diff. If `get-role` errors, the restart point is step 4, because Floci is not
answering.

## 7. Tear down

**confirm**, then

```sh
terraform -chdir=access/envs/prod destroy -auto-approve
docker rm -f wp-i4-floci
```

Floci keeps everything in memory, so removing the container removes the
account, but destroy first so state and cloud agree at the end rather than
only at the start.

Leave the `../waterpark-i4` worktree in place. Lesson 5 starts a fresh one
from `checkpoint/i4`, and the student may want to look back at this one.

## 8. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"i4"` to its `completed` array (creating the array if the file
somehow lacks one). Leave every other field untouched. Write it in the
original checkout rather than in the `../waterpark-i4` worktree.

```json
{"...": "...", "completed": ["start", "i1", "i2", "i3", "i4"]}
```

## 9. Hand off

Say the next step is IAM lesson 5, the permission boundary
(https://intentius.io/waterpark/courses/iam/05-the-permission-boundary/),
which builds the one boundary the whole estate sits under, puts it on every
role, and turns the warning that survived `just access-check` into an error.
