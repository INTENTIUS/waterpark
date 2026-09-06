---
name: waterpark-i3-guardrails-in-the-editor
description: Walk a student through IAM lesson 3, Guardrails in the editor. Use when they finished IAM lesson 2 and want lesson 3, or want the tflint rule pack and its fixtures. Writes the tflint config, the two layout rules and one security rule with its fixtures, brings in the rest of the pack and the check script, and breaks the estate to watch each rule fire.
---

# water park, IAM lesson 3, Guardrails in the editor

You are walking a student through IAM lesson 3, Guardrails in the editor
(https://intentius.io/waterpark/courses/iam/03-guardrails-in-the-editor/).
The outcome is nine rules, each with a failing and a passing fixture, a
check script that runs all of it with no credential, and four deliberate
breaks the student has watched the right rule catch. About 45 minutes.

This lesson spends no money and touches no AWS account. Do not start
Floci, do not run `terraform apply` or `terraform plan`, and do not ask
for AWS credentials. Nothing in the check stack opens a socket to a cloud.

Confirm with the student before creating the worktree, before installing
the tflint plugin, and before anything that writes, deletes or checks out
a file. Those steps are marked **confirm**. Running `tflint`,
`access/scripts/check` and `git diff` runs freely.

## 1. Say what this is

In three or four sentences say this is lesson 3 of the IAM course, that
`terraform validate` has no opinion about file names, wildcard actions,
inline policies, missing tags or IAM users, and that this lesson writes
the nine rules that do. Say severity is the Rego function-name prefix,
`deny_` for an error and `warn_` for a warning, which is the whole
mechanism behind promoting a rule later. Link the lesson page above.

Ask which OS and shell they are on. `git`, `terraform`, `tflint` and
`just` are identical everywhere. `mv`, `cat >>`, `rm`, `printf >` and
`export` are not, so give the PowerShell forms when that is what they are
using.

| bash or zsh | PowerShell |
|---|---|
| `export NAME="$PWD/x"` | `$env:NAME = "$PWD/x"` |
| `mv a b` | `Move-Item a b` |
| `cat a >> b` | `Get-Content a \| Add-Content b` |
| `rm f` | `Remove-Item f` |

## 2. Check the ground

Run the same check Start here uses.

```sh
bash skills/start/check.sh
```

Windows runs
`powershell -ExecutionPolicy Bypass -File skills/start/check.ps1` instead.

Also read `.waterpark/profile.json` at the checkout root if it exists. It
is a claim from a previous run, and the check's live reads are the truth,
so when they disagree believe the check.

From the check, require `waterpark.checkout` true and note
`waterpark.root` and whether `just` is installed. Nothing else in the
check matters here. No Fountain, no inference key, no runner, no Floci.

If the profile's `completed` array does not contain `i2`, say so and offer
lesson 2 first
(https://intentius.io/waterpark/courses/iam/02-personas-and-principals/).
This lesson still works, because it starts from `checkpoint/i2` rather
than from what lesson 2 left behind.

The check does not report `terraform` or `tflint`. Both are required here.

```sh
terraform version
tflint --version
```

Terraform must be 1.9.0 or newer. If `tflint` is missing, **confirm**,
then install it. On macOS it comes from the tap and not from core,
`brew install terraform-linters/tap/tflint`. On Windows and Linux, the
release archive for their platform from
https://github.com/terraform-linters/tflint/releases, unpacked onto the
PATH. Do not go on without it, because every step from 3b down needs it.

## 3. The lesson

### 3a. The worktree

**confirm**, then, from the water park checkout,

```sh
git worktree add ../waterpark-i3 checkpoint/i2
cd ../waterpark-i3
```

`checkpoint/i2` is the tree lesson 2 ends at. If the tag is unknown, run
`git fetch origin --tags` and try again.

### 3b. The config and the plugin

**confirm**, then have the student write `access/.tflint.hcl`.

```hcl
config {
  call_module_type = "none"
}

plugin "terraform" {
  enabled = false
}

# The custom rules are Rego, under .tflint.d/policies. Severity is the
# function-name prefix, deny_ for an error and warn_ for a warning, which is
# how a new rule lands as a warning first (decision 9).
plugin "opa" {
  enabled = true
  version = "0.8.0"
  source  = "github.com/terraform-linters/tflint-ruleset-opa"
}
```

Say why the bundled `terraform` ruleset is off. This pack is nine opinions
about this estate, and mixing it with a general style ruleset makes the
output unreadable. `call_module_type = "none"` keeps tflint looking at the
files as written rather than at an expanded module tree, which is what
makes a rule about file names possible at all.

**confirm** before the next one, because it downloads a plugin.

```sh
cd access
tflint --init
export TFLINT_OPA_POLICY_DIR="$PWD/.tflint.d/policies"
```

`tflint --init` fetches the OPA ruleset into `~/.tflint.d/plugins`, once
per machine, and says `All plugins are already installed` if it is there
from a previous lesson. In the main checkout `just access-init` is the
same command. Every tflint command below runs from `access/` with that
variable exported, so if the student opens a new terminal, export it
again.

### 3c. The two layout rules

**confirm**, then have the student write
`access/.tflint.d/policies/layout.rego`. Offer the content. This is the
half of prescription 1 that lesson 1 left unenforced, so do not rush it.

```rego
# The two layout rules. They are prescription 1, one resource per file and
# the path is the index, checked in the editor rather than in review.
#
# Severity is the function-name prefix. deny_ is an error, warn_ is a
# warning, which is how a new rule lands as a warning first (decision 9).
package tflint

import rego.v1

layout_resources := terraform.resources("*", {}, {"expand_mode": "none"})

base_name(path) := parts[count(parts) - 1] if {
	parts := split(path, "/")
}

expected_file(r) := sprintf("%s.%s.tf", [trim_prefix(r.type, "aws_"), r.name])

deny_one_type_per_file contains issue if {
	some r in layout_resources
	siblings := [x |
		some x in layout_resources
		x.decl_range.filename == r.decl_range.filename
	]
	count(siblings) > 1
	issue := tflint.issue(
		sprintf(
			"%s holds %d resource blocks. One resource per file. Move %s.%s into its own %s.",
			[base_name(r.decl_range.filename), count(siblings), r.type, r.name, expected_file(r)],
		),
		r.decl_range,
	)
}

deny_path_matches_name contains issue if {
	some r in layout_resources
	base_name(r.decl_range.filename) != expected_file(r)
	issue := tflint.issue(
		sprintf(
			"%s holds %s.%s. Rename the file to %s, so the path repeats the resource address.",
			[base_name(r.decl_range.filename), r.type, r.name, expected_file(r)],
		),
		r.decl_range,
	)
}

# A leaf principal file holds a module call rather than a resource block, and
# the same promise applies. iam_role.site_publisher.tf holds the call that
# produces aws_iam_role.site_publisher.
deny_path_matches_name contains issue if {
	some m in terraform.module_calls({}, {"expand_mode": "none"})
	base := base_name(m.decl_range.filename)
	regex.match(`^[a-z0-9_]+\.[a-z0-9_]+\.tf$`, base)
	label := split(trim_suffix(base, ".tf"), ".")[1]
	label != m.name
	issue := tflint.issue(
		sprintf(
			"%s holds module %q. Name the module %q, or rename the file, so the path predicts the address.",
			[base, m.name, label],
		),
		m.decl_range,
	)
}
```

Point at `expected_file`. Strip `aws_` off the type, join it to the label,
add `.tf`, and that is the whole convention. Point out that
`deny_path_matches_name` is defined twice and Rego unions the two, which
is how a leaf file holding a module call is held to the same promise.

Then run it over the three roots. Reads, no confirmation.

```sh
tflint --chdir=envs/prod --config="$PWD/.tflint.hcl" --format=compact
tflint --chdir=identity --config="$PWD/.tflint.hcl" --format=compact
tflint --chdir=modules/persona --config="$PWD/.tflint.hcl" --format=compact
```

Three silent exits. Say why that is the right order, a rule goes in after
the thing it guards already conforms.

### 3d. Break the layout twice

**confirm**, then

```sh
mv envs/prod/s3_bucket.waterpark_site.tf envs/prod/site.tf
tflint --chdir=envs/prod --config="$PWD/.tflint.hcl" --format=compact
mv envs/prod/site.tf envs/prod/s3_bucket.waterpark_site.tf
```

Expect `site.tf holds aws_s3_bucket.waterpark_site. Rename the file to
s3_bucket.waterpark_site.tf, so the path repeats the resource address.`

**confirm**, then the module-call half.

```sh
cat envs/prod/iam_role.desk_operator.tf >> envs/prod/iam_role.runner_builder.tf
tflint --chdir=envs/prod --config="$PWD/.tflint.hcl" --format=compact
git -C .. checkout checkpoint/i2 -- access/envs/prod/iam_role.runner_builder.tf
```

Expect `iam_role.runner_builder.tf holds module "desk_operator". Name the
module "runner_builder", or rename the file, so the path predicts the
address.` Ask the student which rule did not fire and why.
`one-type-per-file` counts `resource` blocks, and two module calls are not
two resource blocks, so the naming rule is the one that catches it.

### 3e. One security rule and its two fixtures

**confirm**, then three files.

`access/.tflint.d/policies/security.rego`

```rego
# The security pack. Every rule here has a failing and a passing fixture
# under access/tests/fixtures, and every rule carries a fix in its message,
# because a guardrail that only says no is a bad guardrail (prescription 4).
#
# Severity is the function-name prefix. deny_ is an error, warn_ is a
# warning. A new rule lands as a warning and is promoted in a later lesson
# once the estate conforms (decision 9).
package tflint

import rego.v1

policy_statements(doc) := doc.Statement if is_array(doc.Statement)

policy_statements(doc) := [doc.Statement] if is_object(doc.Statement)

statement_actions(st) := st.Action if is_array(st.Action)

statement_actions(st) := [st.Action] if is_string(st.Action)

# A wildcard action is not reviewable, because nobody can say what it grants
# next year when the service adds an API.
deny_no_wildcard_action contains issue if {
	some r in terraform.resources("aws_iam_policy", {"policy": "string"}, {"expand_mode": "none"})
	not r.config.policy.unknown
	doc := json.unmarshal(r.config.policy.value)
	some st in policy_statements(doc)
	st.Effect == "Allow"
	some act in statement_actions(st)
	contains(act, "*")
	issue := tflint.issue(
		sprintf(
			"aws_iam_policy.%s allows %q. Name the actions, or say an access level in a grant and let modules/persona expand it.",
			[r.name, act],
		),
		r.config.policy.range,
	)
}
```

`access/tests/fixtures/no-wildcard-action/fail/iam_policy.wildcard.tf`

```hcl
# Fails no-wildcard-action. s3:* grants whatever S3 adds next year, and
# nobody reviewing this diff can say what that is.
resource "aws_iam_policy" "wildcard" {
  name = "wildcard"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:*"]
      Resource = ["arn:aws:s3:::waterpark-artifacts/*"]
    }]
  })

  tags = {
    owner = "platform"
  }
}
```

`access/tests/fixtures/no-wildcard-action/pass/iam_policy.named.tf`

```hcl
resource "aws_iam_policy" "named" {
  name = "named"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:GetObjectVersion",
      ]
      Resource = ["arn:aws:s3:::waterpark-artifacts/*"]
    }]
  })

  tags = {
    owner = "platform"
  }
}
```

Then run each pair with only that one rule enabled.

```sh
tflint --chdir=tests/fixtures/no-wildcard-action/fail --config="$PWD/.tflint.hcl" --only=opa_deny_no_wildcard_action --format=compact
tflint --chdir=tests/fixtures/no-wildcard-action/pass --config="$PWD/.tflint.hcl" --only=opa_deny_no_wildcard_action --format=compact
```

The first exits 2 and names the fix, the second is silent. Point out that
the rule id is the Rego function name with `opa_` in front, and that it is
the same id an editor shows.

### 3f. The rest of the pack

**confirm**, then

```sh
cd ..
git checkout checkpoint/i3 -- access/.tflint.d/policies/security.rego access/tests access/scripts/check justfile
```

Say why this one is a checkout. The student has written the pattern twice,
and the other five security rules are the same shape against different
resource types.

Have them read `access/scripts/check` before running it. Four stages,
`fmt`, `validate`, `lint` and `fixtures`, each runnable alone, no
credential anywhere. The `rules` array pairs a fixture directory with the
Rego function that implements it, so the severity contract is in one place
and promoting a rule in lesson 5 is one word in the policy and one word
here.

### 3g. Run the whole stack

```sh
just access-check
```

Expect four stages, nine `ok` lines in the last of them, then
`check passed`. Two things to stop on. The `tflint` stage prints a warning
against `modules/persona/iam_role.this.tf`, because no role carries a
permission boundary yet, and the run passes anyway, which is
`--minimum-failure-severity=error` doing its job. And the fixtures stage
prints `(error)` or `(warning)` beside each rule, read straight off the
Rego function name.

If `just` is not installed, `access/scripts/check` is the same thing.

### 3h. The rule prescription 3 was waiting on

**confirm**, then

```sh
printf 'resource "aws_iam_user" "contractor" {\n  name = "contractor"\n}\n' > access/envs/prod/iam_user.contractor.tf
just access-check lint
rm access/envs/prod/iam_user.contractor.tf
```

Expect `aws_iam_user.contractor declares an IAM user or group.`, then
`check failed, 1 problem(s)`, then a `error: Recipe access-check failed`
line from `just` itself, which is the recipe reporting the non-zero exit
rather than a second problem. The boundary warning is in the same output
and still fails nothing. Say that `terraform validate` would have accepted
that file without a word.

Make sure the `rm` actually ran before the done-when check.

## 4. Done when

Both of these have to be true, in `../waterpark-i3`.

- `just access-check` ends with `check passed`, and the fixtures stage
  lists all nine rules as `ok`, six marked `(error)` and three marked
  `(warning)`.
- The compare against the checkpoint prints nothing.

  ```sh
  git add -N access
  git diff --stat checkpoint/i3 -- access/.tflint.hcl access/.tflint.d access/tests access/scripts
  ```

Run both yourself and show the output. If the check fails, read the stage
name. `fmt` means a file needs `terraform fmt -recursive access`,
`validate` means 3d left a file broken, `lint` means 3h left the IAM user
behind, and a fixture failure names its own rule.

Two parts of this lesson's issue are open and this skill does not pretend
otherwise. Access Analyzer `validate-policy` is a cloud API and Floci runs
none, so it is live only and no recorded run exists yet. The catalog page
mapping these rule ids to the parliament and cloudsplaining taxonomies has
not been written. Say both if the student asks about the issue's build
list.

The editor half of prescription 4 is real and this lesson documents it
rather than proving it. `tflint --langserver` carries exactly these nine
rules and is a separate process from `terraform-ls`, which serves
`validate` and completion. An editor running both shows the same rule ids
the script prints, before the commit. An editor running only
`terraform-ls` shows none of them. If the student wants it set up, help
them, but do not claim the lesson checked it, because no check script can
see inside an editor.

## 5. Record

**confirm**, then update `.waterpark/profile.json` at the water park
checkout root, appending `"i3"` to its `completed` array (creating the
array if the file lacks one). Leave every other field untouched. The
profile lives in the original checkout, not in the worktree.

```json
{"...": "...", "completed": ["start", "i1", "i2", "i3"]}
```

## 6. Hand off

Say the next step is IAM lesson 4, Deploy to Floci
(https://intentius.io/waterpark/courses/iam/04-deploy-to-floci/), which
starts the emulator, applies this estate for the first time, and adds a
fifth stage to the check script, a credential-free plan that says so and
moves on when Floci is not up. It starts from `checkpoint/i3` in a
worktree of its own, so this one can be thrown away with
`git worktree remove ../waterpark-i3` from the main checkout, or kept to
compare against.
