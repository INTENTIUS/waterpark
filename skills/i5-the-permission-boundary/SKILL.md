---
name: waterpark-i5-the-permission-boundary
description: Walk a student through IAM lesson 5, The permission boundary. Use when they finished IAM lesson 4 and want lesson 5. Builds one estate boundary in access/baseline, applies it to every role through the persona module, exempts it from no-wildcard-action by tag, promotes boundary-required from a warning to an error, and proves the bounded estate still reaches a clean plan on Floci.
---

# water park, IAM lesson 5, The permission boundary

You are walking a student through IAM lesson 5, The permission boundary
(https://intentius.io/waterpark/courses/iam/05-the-permission-boundary/). The
outcome is one boundary that caps the whole estate, on every role, enforced
twice, with `plan -detailed-exitcode` still exiting 0 and the boundary read
back out of the cloud. About 45 minutes.

This lesson never touches a real AWS account. Every command points at
`http://localhost:4566`, `floci` stays at its default of true, and the
`AWS_ACCESS_KEY_ID=test` pair is the throwaway the provider already uses
rather than a credential. If the student wants to run this against a real
account, say that is the live path, that it needs `-var floci=false` and the
S3 backend, and that a facilitator runs it.

Confirm with the student before creating the worktree, before starting the
Floci container, before writing any file under `access/`, and before each
apply and the teardown. Those steps are marked **confirm**. Reads run freely,
which is every `just access-check` stage, `plan`, `get-role`,
`get-policy-version`, `terraform console` and `git diff`.

## 1. Say what this is

In two or three sentences say this is lesson 5 of the IAM course, that lesson
4 applied an estate whose roles carry no ceiling and left one warning
standing, and that this lesson builds the ceiling and turns that warning into
an error. Say what a boundary is, which is a cap on what an identity-based
policy can grant, because effective permissions are the intersection of the
two. Link the lesson page above.

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Also read `.waterpark/profile.json` at the checkout root if it exists. A
profile file is a claim from a previous run and the check's live calls are
the truth, so when they disagree believe the check. If `completed` does not
carry `"i4"`, say lesson 4 is where the apply and the plan stage come from,
and offer to run this anyway since the checkpoint carries lesson 4's work.

Require `waterpark.checkout` true and `tools.docker.installed` true. The
check does not report `terraform` or `tflint`, so ask for those directly.

```sh
terraform version
tflint --version
```

Terraform 1.9 or newer, and any tflint that carries the OPA plugin. If tflint
is missing, the install line is `brew install terraform-linters/tap/tflint`
on macOS, and the release binary from
https://github.com/terraform-linters/tflint on Linux and Windows.

Note the check's `floci.reachable`. It is usually false here, because this
lesson starts its own container in step 3. If it is already true, ask whether
that is the compose stack from `just up` or a leftover from lesson 4, and
reuse it rather than starting a second container on the same port. A Floci
left over from lesson 4 still holds lesson 4's estate, which is fine, but the
local state in the new worktree will not know about it, so prefer a fresh
container.

## 3. The starting point

**confirm**, then

```sh
git fetch origin --tags
git worktree add ../waterpark-i5 checkpoint/i4
cd ../waterpark-i5
just access-init
```

Every command after this runs from `../waterpark-i5`.

**confirm** again, then start Floci.

```sh
docker run -d --name wp-i5-floci -p 4566:4566 \
  -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
  ghcr.io/lex00/floci:iam-boundary

curl -s -o /dev/null -w '%{http_code}\n' http://localhost:4566/
```

The curl prints `200`. Re-run `bash skills/start/check.sh` and require
`floci.reachable` true before going on.

This image matters more in this lesson than in any other. Upstream Floci
2.0.1 accepts a boundary on `CreateRole` and then returns the field as null
on every read, so Terraform never sees what it set and replans forever. On
that image the clean plan this lesson ends on does not exist. The fork build
fixes it. Say this to the student now rather than at the end.

## 4. Apply the unbounded estate

**confirm**, then

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod apply -auto-approve
```

Nineteen resources. Then show there is no ceiling yet.

```sh
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 \
  aws --endpoint-url http://localhost:4566 iam get-role \
  --role-name site-publisher --query 'Role.PermissionsBoundary'
```

It prints `null`. Keep this output. Step 8 shows the same query returning the
boundary, and the pair is the point.

## 5. The lesson

### 5a. Write the baseline module

**confirm** before writing files, then create `access/baseline/` with five
files, `versions.tf`, `variables.tf`, `locals.tf`, `iam_policy.boundary.tf`
and `outputs.tf`.

The bodies are in step 2 of the lesson page, which is
`content/courses/iam/05-the-permission-boundary.md` in this checkout. Read
them from there rather than from memory, so the student's files and the page
agree exactly. Do not fetch them from a URL.

While the student writes them, say what each one is buying.

- `versions.tf` is the same pins the other roots carry, nothing new.
- `variables.tf` holds `boundary_name`, which is deterministic so every stack
  references the boundary by name and nothing hardcodes an ARN. It also holds
  `sandbox`, which is the Sandbox OU exemption. It is a variable on this
  module rather than an environment flag, so an environment that wants no
  boundary says so in its own `baseline.tf` and the decision is greppable.
  `state_bucket` and `apply_role_name` name the guardrail path so the deny
  can point at it.
- `locals.tf` is the content of the boundary, as four lists. All IAM write,
  the org layer and Identity Center in `forbidden_actions`. The four
  detachment actions on their own, because detaching the cap would make every
  other deny pointless. The service surface an app team plausibly needs. The
  guardrail path by ARN, which is the boundary policy itself, the apply role
  and the state bucket. It also holds the two constants, two hours of
  break-glass (decision 37) and five open PRs for the watcher (decision 40).
- `iam_policy.boundary.tf` is one allow and three denies. `count` is the
  sandbox exemption, so a sandbox gets no policy at all rather than a
  permissive one. The `description` is on the object in the account, and each
  deny carries a comment beside it. That is the why standing where it is
  enforced rather than in a document. The `guardrail = "boundary"` tag is
  what step 5c reads.
- `outputs.tf` exports `boundary_arn` for the persona module,
  `forbidden_actions` for the lesson 6 proof checks, and the two constants
  for lessons 10 and 13.

### 5b. Put the new root under the checks, and watch a rule refuse it

**confirm**, then open `access/scripts/check` and add `baseline` to the
`roots` array, between `identity` and `modules/persona`. Then

```sh
just access-check lint
```

Expect seven errors, all `opa_deny_no_wildcard_action` on
`baseline/iam_policy.boundary.tf`, one per wildcard in the service surface.
`s3:*`, `logs:*`, `cloudwatch:*`, `ecr:*`, `sqs:*`, `sns:*` and `dynamodb:*`.

Ask the student whether the rule is wrong before telling them. It is not
wrong about what it sees. In a grant, `s3:*` is unreviewable, because nobody
can say what it allows when the service adds an API next year. In a ceiling,
`s3:*` says a role may be given S3 access by its own policy and nothing more.
Widening a grant widens access. Widening a ceiling still grants nothing.

### 5c. Exempt a boundary, by tag

**confirm**, then have the student open
`access/.tflint.d/policies/security.rego` and add the helper.

```rego
# A permission boundary is a ceiling rather than a grant, so a wildcard in it
# narrows the estate instead of widening it, and no-wildcard-action does not
# apply. The exemption is a tag on the policy rather than a name match, so it
# is deliberate and greppable.
is_boundary(r) if {
	not r.config.tags.unknown
	r.config.tags.value.guardrail == "boundary"
}
```

Then teach `deny_no_wildcard_action` to ask it. The rule needs the tags in
scope, so the schema gains one entry and the body gains one line.

```rego
deny_no_wildcard_action contains issue if {
	some r in terraform.resources("aws_iam_policy", {"policy": "string", "tags": "map(string)"}, {"expand_mode": "none"})
	not is_boundary(r)
	not r.config.policy.unknown
```

An exemption with no fixture is an exemption nobody notices breaking, so
write `access/tests/fixtures/no-wildcard-action/pass/iam_policy.boundary.tf`.

```hcl
# Passes no-wildcard-action even though it carries s3:*, because the
# guardrail = "boundary" tag marks it a ceiling rather than a grant. A
# wildcard in a boundary narrows the estate instead of widening it.
resource "aws_iam_policy" "boundary" {
  name = "example-boundary"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:*"]
      Resource = "*"
    }]
  })

  tags = {
    owner     = "platform"
    guardrail = "boundary"
  }
}
```

Run `just access-check lint` again. `access/baseline` is ok, and the only
thing left is the boundary warning on `modules/persona`, which is still true
because no role carries a boundary yet.

### 5d. Wire the boundary to every role

**confirm**, then three edits.

Write `access/envs/prod/baseline.tf`, which calls the module once with
`owner = local.owner` and `sandbox = false`. The body is in step 5 of the
lesson page.

Add the variable to `access/modules/persona/variables.tf`.

```hcl
variable "permissions_boundary" {
  description = "The estate boundary from access/baseline. Every workload role the module makes sits inside it, so the boundary is applied here rather than restated per grant. Null only in a sandbox, which carries no boundary at all (decision 36)."
  type        = string
  default     = null
}
```

And use it in `access/modules/persona/iam_role.this.tf`, under
`description`.

```hcl
  # Every role water park emits carries the boundary, applied here so a leaf
  # file never restates it. The lint rule and the cloud enforce the same
  # thing, deliberately twice.
  permissions_boundary = var.permissions_boundary
```

Then add the same one line to all three leaf files,
`access/envs/prod/iam_role.site_publisher.tf`,
`iam_role.runner_builder.tf` and `iam_role.desk_operator.tf`, under `teams`
and above `grants`.

```hcl
  permissions_boundary = module.baseline.boundary_arn
```

Say why that line is in a leaf file at all, because it looks like the
opposite of what the module change just bought. It is the dependency edge. It
tells Terraform that `module.baseline` produces something the role module
consumes, so the policy is created before the roles that reference it, in one
apply, with no `depends_on` and no two-phase bootstrap. The ten grants across
those three files still say nothing about the boundary, which is the property
that was wanted.

### 5e. Promote the rule

**confirm**, then rename one function in
`access/.tflint.d/policies/security.rego`.

```rego
deny_boundary_required contains issue if {
```

The prefix is the severity, so `warn_` to `deny_` is the whole promotion.
Then tell the fixture runner the new name, in `access/scripts/check`.

```sh
	"boundary-required:deny_boundary_required"
```

That is the warn cycle from lesson 3 completing. A rule lands as a warning
while the estate does not conform and is promoted once it does, so nothing is
ever merged red.

### 5f. Run the stack, and expect one failure

```sh
just access-check
```

fmt, validate and tflint pass, `boundary-required (error)` passes its
fixtures, and the plan stage from lesson 4 says
`FAIL  envs/prod has an unapplied diff`. That is correct and it is worth
pausing on. The repo declares a boundary the account does not have, and the
check refuses to call the repo green while the cloud disagrees with it.

### 5g. Apply, and prove it

**confirm**, then

```sh
terraform -chdir=access/envs/prod init
terraform -chdir=access/envs/prod apply -auto-approve
terraform -chdir=access/envs/prod plan -detailed-exitcode
echo $?
```

Expect `Apply complete! Resources: 1 added, 3 changed, 0 destroyed.` One
policy created and three roles updated in place, because the roles were
already there from step 4. Then "No changes." and `0`.

Reads run freely from here.

```sh
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1

aws --endpoint-url http://localhost:4566 iam get-role \
  --role-name site-publisher --query 'Role.PermissionsBoundary'

aws --endpoint-url http://localhost:4566 iam get-policy-version \
  --policy-arn arn:aws:iam::000000000000:policy/waterpark-estate-boundary \
  --version-id v1 \
  --query 'PolicyVersion.Document.Statement[?Sid==`NoBoundaryDetachment`]'
```

The first returns a `PermissionsBoundaryArn` ending in
`policy/waterpark-estate-boundary`, where step 4 returned `null`. The second
returns the four detachment actions under a `Deny`.

Say what the second one is. The apply role sits inside this same boundary, so
the thing that applies water park cannot take water park's ceiling off. The
proof check that runs it as a test lands in lesson 6 and reads
`forbidden_actions` out of `baseline` rather than restating the list.

Then run `just access-check` once more, end to end. `check passed`, with no
warning left anywhere.

### 5h. Read the constants

```sh
echo 'module.baseline.break_glass_max_ttl_hours' | terraform -chdir=access/envs/prod console
echo 'module.baseline.watcher_max_open_prs' | terraform -chdir=access/envs/prod console
```

`2` and `5`. Two hours is the break-glass maximum (decision 37) and five is
the watcher's open PR cap (decision 40). One number in one file, so lesson 13
can have a student change one and watch the checks move.

### 5i. Compare with the reference repo

`access/baseline` is new and untracked files do not appear in a diff, so
stage first.

```sh
git add -A access
git diff --cached checkpoint/i5 -- access
```

The only file it should name is `access/README.md`, which is prose. If it
names anything under `baseline`, read the difference with the student rather
than pasting over it. A boundary they can defend line by line is worth more
than a boundary that matches the reference.

## 6. Done when

All three have to be true, and verify each one yourself rather than taking
earlier output on trust.

- `just access-check` passes, the fixture line reads
  `ok    boundary-required (error)`, and no boundary warning appears anywhere
  in the output.
- `terraform -chdir=access/envs/prod plan -detailed-exitcode` exits 0 with
  the boundary applied. Run it again and read `echo $?`.
- `aws iam get-role --role-name site-publisher` against
  `--endpoint-url http://localhost:4566` returns a `PermissionsBoundary`
  block naming `waterpark-estate-boundary`, and the `get-policy-version` call
  in 5g shows that policy denying `iam:DeleteRolePermissionsBoundary` and
  `iam:PutRolePermissionsBoundary`.

If the check fails on tflint, the restart point is 5c or 5e depending on
which rule fired. If the plan exits 2, the restart point is 5g, apply and
read the diff. If `get-role` returns null on a role Terraform says it
bounded, the container is the upstream image rather than the fork, so restart
from step 3 with `ghcr.io/lex00/floci:iam-boundary`.

## 7. Tear down

**confirm**, then

```sh
terraform -chdir=access/envs/prod destroy -auto-approve
docker rm -f wp-i5-floci
```

Leave the `../waterpark-i5` worktree. Lesson 6 starts a fresh one from
`checkpoint/i5`.

## 8. Record

**confirm**, then update `.waterpark/profile.json` at the checkout root,
appending `"i5"` to its `completed` array (creating the array if the file
somehow lacks one). Leave every other field untouched. Write it in the
original checkout rather than in the `../waterpark-i5` worktree.

```json
{"...": "...", "completed": ["start", "i4", "i5"]}
```

## 9. Hand off

Say the next step is IAM lesson 6, one path to prod
(https://intentius.io/waterpark/courses/iam/06-one-path-to-prod/), which
takes the credential-free check stack and the boundary this lesson built and
turns them into the single gated path a change travels, with the proof checks
that read `forbidden_actions` back out of `baseline`.
