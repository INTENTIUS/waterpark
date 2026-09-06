---
title: "Deploy to Floci"
id: "I4"
lesson: 4
weight: 4
summary: "The estate deploys to Floci with no account."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i4-deploy-to-floci"
# card. empty renders as TODO
goal: "Apply the estate you have been declaring for three lessons against a local Floci, with no AWS account and no credentials anywhere, prove it converged with a plan that exits 0, read one role back out of the cloud and match it against the file that declared it, then add that same credential-free plan to the check stack a PR job runs."
done_when: "`terraform -chdir=access/envs/prod plan -detailed-exitcode` exits 0 straight after the apply, with no AWS credential in the environment and no account behind it, and `aws iam get-role --role-name site-publisher` returns the `RoleName`, `Description` and `owner` tag that `access/envs/prod/iam_role.site_publisher.tf` declared."
restart_from: "checkpoint/i3"
properties: ["XI", "I"]
closes: ["P6 (part)"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "30 min"
  needs:
    - "a water park checkout with the tags fetched"
    - "Docker running"
    - "the patched Floci image ghcr.io/lex00/floci:iam-boundary"
    - "terraform 1.9 or newer"
    - "tflint from terraform-linters/tap/tflint"
    - "just access-init run once per clone"
  solo: true
  live: true
---

## Context

- One variable picks the target. `floci` defaults to true, which points the provider's `iam`, `sts` and `s3` endpoints at `http://localhost:4566`, hands it the throwaway `test` key pair and skips every call that would resolve a real account. The live path passes `-var floci=false` and the same code talks to `waterpark-prod`.
- The backend that ships checked in is the local one, `access/envs/prod/backend.local.tf`, so a fresh clone runs `terraform init` with no account, no credentials and no bucket to create first. `access/scripts/backend s3 envs/prod` swaps in the S3 backend for the live path, and exactly one backend file is present at a time.
- Terraform hosts a state file, which is the thing Accessible Ops XI warns about. This lesson names the cost out loud rather than hiding it (decision 32). On the live path state lives in `waterpark-security` with locking, it is never the system of record, and every read of the estate in these lessons goes to the cloud instead.
- `plan -detailed-exitcode` exits 0 for no changes, 2 for a diff and 1 for an error. A green apply that has not converged gets caught rather than believed.
- `aws iam get-role` reads a role back out of the cloud rather than out of state. The file predicted it.
- Floci runs no Organizations, no Identity Center and no Access Analyzer, and the verdicts are recorded in [upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md).
- A failed apply stops where it failed and leaves behind what it already made, with no rollback. The answer is a small change planned first, not a bigger apply.
- The provider lock file is not committed, because it records provider hashes for the platforms it was generated on and students run this on three of them.

## Do

Lessons 1 to 3 declared an estate and checked it without ever talking to a cloud. This is where it runs.

1. Start from the checkpoint lesson 3 left, in a worktree of its own, so your own branch stays where it is.

   ```sh
   git fetch origin --tags
   git worktree add ../waterpark-i4 checkpoint/i3
   cd ../waterpark-i4
   just access-init
   ```

   `just access-init` is `cd access && tflint --init`, which installs the OPA ruleset the rule pack runs on. It is once per clone and says "All plugins are already installed" if you have done it before.

2. Start Floci with IAM enforcement on, and prove it answers.

   ```sh
   docker run -d --name wp-i4-floci -p 4566:4566 \
     -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
     ghcr.io/lex00/floci:iam-boundary

   curl -s -o /dev/null -w '%{http_code}\n' http://localhost:4566/
   ```

   The curl prints `200`. The image is a patched fork build rather than the upstream release, and lesson 5 is where that matters. [compose/README.md](https://github.com/INTENTIUS/waterpark/blob/main/compose/README.md) says which two bugs it fixes, and `just up` pulls the same image.

3. Initialize with the local backend, and read what it tells you.

   ```sh
   terraform -chdir=access/envs/prod init
   ```

   The first line back is `Successfully configured the backend "local"`. That is the cost this lesson names. Terraform is about to write `access/envs/prod/terraform.tfstate`, a JSON file that lists every resource it manages, and Accessible Ops XI says the live system is the truth. Water park does not pretend the file is not there. It is gitignored, it is bookkeeping and never the system of record, and on the live path `access/scripts/backend s3 envs/prod` puts it in the `waterpark-terraform-state` bucket in `waterpark-security`, encrypted and locked. Every read in the rest of this lesson goes to the cloud instead of to that file.

4. Apply.

   ```sh
   terraform -chdir=access/envs/prod apply -auto-approve
   ```

   Nineteen resources land. Three workload roles, the grant policies `modules/persona` expands from each leaf file's access levels, an attachment per grant, and the two buckets. No credential was asked for and no account exists.

5. Prove it converged, and make the tool say so rather than saying it yourself.

   ```sh
   terraform -chdir=access/envs/prod plan -detailed-exitcode
   echo $?
   ```

   "No changes. Your infrastructure matches the configuration." and `0`. A run that left something unapplied would print `2` here even though the apply was green, which is the whole reason this flag is in the command.

6. Read a role back out of the cloud and hold it against the file.

   ```sh
   AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 \
     aws --endpoint-url http://localhost:4566 iam get-role --role-name site-publisher
   ```

   Open `access/envs/prod/iam_role.site_publisher.tf` beside it. `RoleName` is the `name`. `Description` is the `description`, word for word. The `owner` and `persona` and `teams` tags are what `modules/persona` builds from `owner`, `persona` and `teams`, and `managed_by`, `repo` and `env` come from the provider's `default_tags`. `AssumeRolePolicyDocument` trusts `codebuild.amazonaws.com`, which is the module's `trusted_services` default, not anything the leaf file said. `PermissionsBoundary` is absent, and that is lesson 5.

   The three `test` variables are the throwaway pair the provider already uses. They are not a credential, and nothing in this lesson has one.

7. Put that plan in the check stack, so a PR job runs it too. Open `access/scripts/check` and add the stage below after `run_fixtures`.

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

   Then wire it in. Add `plan) run_plan ;;` to the `case` at the bottom, add `run_plan` as the last line of the `all` branch, and put `plan` in the usage string and the comment header beside `fmt`, `lint` and `fixtures`.

   The skip is the point of the shape. Floci not being up is a reason to say so and carry on, not a reason to fail a PR.

8. Run the one stage, then the whole stack.

   ```sh
   just access-check plan
   just access-check
   ```

   The first prints `ok    envs/prod matches the account, exit 0`. The second runs fmt, validate, tflint, the rule fixtures and now the plan, and ends on `check passed`. One warning survives it, `aws_iam_role.this carries no permissions_boundary`, on `modules/persona`. It is a warning rather than an error because the boundary it asks for does not exist yet. Lesson 5 builds it and promotes the rule.

   Nothing in that command holds a credential. That is the half of prescription 6 this lesson closes. The fork-PR test that proves no credentialed job is reachable lands in lesson 6.

9. Compare with the reference repo.

   ```sh
   git diff checkpoint/i4 -- access
   ```

   The only file left is `access/README.md`, which is the prose the reference repo carries for the same steps you just ran.

10. Tear down. Floci keeps everything in memory, so removing the container removes the account, but destroy first so state and cloud agree at the end rather than only at the start.

    ```sh
    terraform -chdir=access/envs/prod destroy -auto-approve
    docker rm -f wp-i4-floci
    ```

    Leave the worktree. Lesson 5 starts a fresh one from `checkpoint/i4`.

## Self-paced

Everything in this lesson is self-paced. Floci runs the AWS APIs in process, so the Terraform is real, the IAM is real and the account is not.

Three things it does not run, and each one is a lesson that says so. There is no Organizations, so the multi-account layer is live only. There is no Identity Center, so the human principals in `access/identity/` are validated on every check and applied only against a real account. There is no Access Analyzer, so the `validate-policy` proofs in lesson 6 are live only.

Two more limits worth knowing before you trust a green run. The provider overrides three endpoints, `iam` and `sts` and `s3`, so anything outside those three is not declared in `envs/prod` yet. And the `test` key pair resolves to `arn:aws:iam::000000000000:root`, which acts unrestricted even with enforcement on, so what you proved here is that the estate converges, not that a caller is refused. Refusal gets proven in lesson 8, where Floci does answer the question.

## Live

Fifteen minutes, and the room watches one terminal.

Run the apply, then the `plan -detailed-exitcode`, and say the number out loud. Zero means the account matches the file. Then `get-role` beside `iam_role.site_publisher.tf` on the other half of the screen, line by line, until somebody says it before you do.

Two honesty lines belong in this room. The first is that the Floci image is a patched fork build, `ghcr.io/lex00/floci:iam-boundary`, not the upstream release. Upstream 2.0.1 never returns a role's permission boundary on read, so the clean plan you are about to show would not be clean on it, and lesson 5 would have nothing to demonstrate. The fix is ours and it is linked from `compose/README.md`.

The second is the state file. Point at `access/envs/prod/terraform.tfstate` and say that Terraform hosts state, that Accessible Ops XI counts that against it, and that a backend with no state file scores better on this property. The mitigations are real and they are not the same as the cost not existing. State goes to `waterpark-security` with locking, it is never read as truth, and lesson 7 makes the drift watch compare what the repo declares against what the cloud holds.

Live, the same code runs against a real sandbox account with `-var floci=false` and the S3 backend from `access/scripts/backend s3 envs/prod`.

## Further reading

- [access/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md), "Deploy to Floci" and "State and the two backends"
- [Upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md), both "Floci as a Terraform target" runs
- [compose/README.md](https://github.com/INTENTIUS/waterpark/blob/main/compose/README.md), the Floci image note
- [The estate](../../docs/estate.md), accounts and resources
- [Decisions](../../docs/decisions.md), 32
- [Multi-account](../../docs/design/multi-account.md), item 3
- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A13
