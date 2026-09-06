---
title: "Guardrails in the editor"
id: "I3"
lesson: 3
weight: 3
summary: "The guardrails run in the editor, for the agent and in the PR job alike."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i3-guardrails-in-the-editor"
# card. empty renders as TODO
goal: "Write the rule pack that refuses this repo's own mistakes. Two layout rules that close the half of prescription 1 lesson 1 left open, then a security rule with its failing and passing fixture, then the rest of the pack and the check script that runs all of it. Break the estate on purpose four times and watch the right rule fire each time, with a message that names the fix."
done_when: "`just access-check` ends with `check passed`, having proved all nine rules against their own failing and passing fixtures, six as errors and three as warnings, and `git diff checkpoint/i3 -- access/.tflint.hcl access/.tflint.d access/tests access/scripts` prints nothing. The editor half of prescription 4 is the same binary in language-server mode and is documented below rather than demonstrated."
restart_from: "checkpoint/i2, the tree lesson 2 ends at"
properties: ["II"]
closes: ["P4"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "45 min"
  needs: ["a water park checkout on main", "`terraform` 1.9 or newer on the PATH", "`tflint` from `brew install terraform-linters/tap/tflint`", "`just access-init` run once in that checkout", "no Floci and no AWS account"]
  solo: true
  live: true
---

## Context

- `terraform validate` catches shape and types. It has no opinion about file names, wildcard actions, inline policies, missing tags or IAM users, which is why lesson 1 could break the layout convention and stay green.
- The rules are Rego, run by [tflint-ruleset-opa](https://github.com/terraform-linters/tflint-ruleset-opa) and living in `access/.tflint.d/policies`. The OPA ruleset hands a policy the declaration range of every block, file name included, so the two layout rules are Rego like the rest rather than a side script.
- Severity is the Rego function-name prefix, `deny_` for an error and `warn_` for a warning. That is the whole mechanism behind the warn cycle decision 9 asks for, so promoting a rule is a one-word edit.
- Nine rules. Six errors, `one-type-per-file`, `path-matches-name`, `no-wildcard-action`, `no-inline-policy`, `no-iam-user-or-group` and `tag-owner-required`. Three warnings, `boundary-required` until lesson 5 builds the boundary and promotes it, and `no-open-ingress` and `sg-reference-not-cidr` because the estate declares no security groups yet. `no-open-ingress` is in the pack because prescription 4 names it, not because anything here has an ingress rule.
- The same script runs in the editor, from an agent and in a PR job, and needs no credential. Access Analyzer `validate-policy` is the part that cannot follow, because it is a cloud API and Floci runs none.

## Do

1. Make a worktree at the checkpoint this lesson starts from. Run this in your water park checkout.

   ```sh
   git worktree add ../waterpark-i3 checkpoint/i2
   cd ../waterpark-i3
   ```

   `checkpoint/i2` is the tree lesson 2 ends at, three workload principals and two humans, all of them clean and none of them checked by anything but `terraform validate`.

2. Write the tflint config, then install the plugin it names.

   `access/.tflint.hcl`

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

   The bundled `terraform` ruleset is off on purpose. This pack is nine opinions about this estate, and mixing it with a general style ruleset makes the output impossible to read. `call_module_type = "none"` keeps tflint looking at the files as written rather than at an expanded module tree, which is what makes a rule about file names possible.

   ```sh
   cd access
   tflint --init
   export TFLINT_OPA_POLICY_DIR="$PWD/.tflint.d/policies"
   ```

   `tflint --init` fetches the OPA ruleset into `~/.tflint.d/plugins`, once per machine. In your main checkout `just access-init` is the same command. Every tflint command below runs from `access/` with that variable exported.

3. Write the two layout rules. This is the other half of prescription 1, four lessons' worth of convention finally enforced.

   `access/.tflint.d/policies/layout.rego`

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

   `expected_file` is the whole convention in one line. Strip `aws_` off the type, join it to the label, add `.tf`. Note that `deny_path_matches_name` is defined twice, once for resource blocks and once for module calls, and Rego unions the two. That is why a leaf principal file is held to the same promise even though it declares no resource of its own.

4. Run it over the three roots, and see nothing.

   ```sh
   tflint --chdir=envs/prod --config="$PWD/.tflint.hcl" --format=compact
   tflint --chdir=identity --config="$PWD/.tflint.hcl" --format=compact
   tflint --chdir=modules/persona --config="$PWD/.tflint.hcl" --format=compact
   ```

   Three silent exits. The estate already conforms, which is the only honest order to add a rule in.

5. Now break it twice, and see the message name the fix.

   ```sh
   mv envs/prod/s3_bucket.waterpark_site.tf envs/prod/site.tf
   tflint --chdir=envs/prod --config="$PWD/.tflint.hcl" --format=compact
   mv envs/prod/site.tf envs/prod/s3_bucket.waterpark_site.tf
   ```

   `site.tf holds aws_s3_bucket.waterpark_site. Rename the file to s3_bucket.waterpark_site.tf, so the path repeats the resource address.` Then the module-call half.

   ```sh
   cat envs/prod/iam_role.desk_operator.tf >> envs/prod/iam_role.runner_builder.tf
   tflint --chdir=envs/prod --config="$PWD/.tflint.hcl" --format=compact
   git -C .. checkout checkpoint/i2 -- access/envs/prod/iam_role.runner_builder.tf
   ```

   `iam_role.runner_builder.tf holds module "desk_operator". Name the module "runner_builder", or rename the file, so the path predicts the address.` Worth noticing what did not fire. `one-type-per-file` counts `resource` blocks, and two module calls in one file are not two resource blocks, so the file-name rule is the one that catches it. Rules cover each other rather than each covering everything.

6. Write the first security rule and the two fixtures that prove it. Every rule in the pack gets this pair, which is prescription 4's check.

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

   Run each with only that one rule enabled, so the fixture proves its own rule and nothing else.

   ```sh
   tflint --chdir=tests/fixtures/no-wildcard-action/fail --config="$PWD/.tflint.hcl" --only=opa_deny_no_wildcard_action --format=compact
   tflint --chdir=tests/fixtures/no-wildcard-action/pass --config="$PWD/.tflint.hcl" --only=opa_deny_no_wildcard_action --format=compact
   ```

   The first exits 2 and names the fix. The second is silent. The rule id is the Rego function name with `opa_` in front, which is also the id an editor shows.

7. Bring in the other five security rules, the rest of the fixtures, the check script and its two `just` recipes. You have written the pattern twice now, and the remaining rules are the same shape against different resource types.

   ```sh
   cd ..
   git checkout checkpoint/i3 -- access/.tflint.d/policies/security.rego access/tests access/scripts/check justfile
   ```

   Read `access/scripts/check` before running it. It is everything a PR job runs, in the order it runs it, and it is 150 lines of bash with no credential in it anywhere. Four stages, `fmt`, `validate`, `lint` and `fixtures`, each runnable alone. The `rules` array is the whole severity contract in one place, pairing a fixture directory with the Rego function that implements it, so promoting `boundary-required` in lesson 5 is one word in the policy and one word here.

   The justfile gains two recipes.

   ```make
   # The access repo's checks: fmt, validate, tflint and the rule fixtures
   access-check *args:
       access/scripts/check {{args}}

   # Install the tflint plugins the access checks need. Once per clone
   access-init:
       cd access && tflint --init
   ```

8. Run the whole stack.

   ```sh
   just access-check
   ```

   Four stages, the last of them nine `ok` lines, then `check passed`. Two things in that output are worth stopping on. The `tflint` stage prints a warning against `modules/persona/iam_role.this.tf`, because no role carries a permission boundary yet, and the run passes anyway. That is `--minimum-failure-severity=error` doing its job, and it is what lets a rule land before the estate is ready for it. And the fixtures stage says `(error)` or `(warning)` beside each rule, read straight off the Rego function name.

9. Break the estate one more time, with the rule prescription 3 has been waiting on since lesson 2.

   ```sh
   printf 'resource "aws_iam_user" "contractor" {\n  name = "contractor"\n}\n' > access/envs/prod/iam_user.contractor.tf
   just access-check lint
   rm access/envs/prod/iam_user.contractor.tf
   ```

   `aws_iam_user.contractor declares an IAM user or group. Humans get an Identity Center permission set under access/identity, workloads get a role from modules/persona (decision 5).` An error, so the stage ends with `check failed, 1 problem(s)` and `just` adds its own `error: Recipe access-check failed` line underneath, which is the recipe reporting a non-zero exit rather than a second problem. The boundary warning is in the same output and still fails nothing. `terraform validate` would have accepted that file without comment.

10. Compare your tree with the checkpoint this lesson ends at.

    ```sh
    git add -N access
    git diff --stat checkpoint/i3 -- access/.tflint.hcl access/.tflint.d access/tests access/scripts
    ```

    Nothing printed means the rule pack, the fixtures and the check script are the reference ones.

## Self-paced

Everything in the check stack runs on the laptop with no credential. `fmt` and `validate` are Terraform, `lint` and `fixtures` are tflint, and none of them opens a socket to a cloud. That is the credential-free half of prescription 6, and lesson 4 adds the fifth stage, a plan against Floci, which says so and moves on when Floci is not up rather than failing.

The editor half of prescription 4 is real and this lesson documents it rather than demonstrating it, which is the honest way round. `tflint --langserver` is a language server carrying exactly these nine rules, and it is a separate process from `terraform-ls`, which serves `validate`, completion and formatting. An editor that runs both gets `Success! The configuration is valid.` from one and `opa_deny_no_wildcard_action` from the other, on the same rule ids `access/scripts/check` prints, before the commit. An editor that runs only `terraform-ls` gets none of the nine. Nothing in a check script can prove which of those two an editor is doing, so the lesson proves the rules and names the setup instead of pretending the setup is checkable.

Two parts of this lesson's issue are open rather than built, and the page would rather say so than imply otherwise.

- Access Analyzer `validate-policy` over the documents rendered from `terraform plan -json` is live only. Floci runs no Access Analyzer, so the self-paced path cannot run it at all, and no recorded run against a real account has been made yet. The patched Floci image lists `accessanalyzer` among its enabled services, which the upstream image did not, and that has not been probed.
- The catalog page mapping these rule ids to the parliament and cloudsplaining finding taxonomies does not exist yet, and neither does a Mend run pointed at this repo.

## Live

Fifteen minutes. The room watches step 4 produce three silent exits, which is boring on purpose, then watches step 5 rename one file and get a sentence back that says exactly what to type. Then step 9. Say this while the IAM user error is on screen. This rule is nine lines of Rego and it is the only reason nobody in this organization will ever again create a long-lived access key by accident, and it costs nothing to run, and it ran before the commit rather than after the review.

## Further reading

- [Guardrail rollout](../../docs/design/guardrail-rollout.md), the warn cycle and ratchet baselines
- [Prescriptions](../../docs/prescriptions.md), P4 and the credential-free half of P6
- [access/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md), the rule table with every severity and what it fails
- [access/tests/fixtures/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/tests/fixtures/README.md), why a fixture is never applied
- [tflint-ruleset-opa](https://github.com/terraform-linters/tflint-ruleset-opa)
- [Decisions](../../docs/decisions.md) 9, 10 and 31
- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A3
