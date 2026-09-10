---
title: "Federation trust"
id: "I9"
lesson: 9
weight: 9
summary: "Trust policies are declared resources with the strictest checks."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i9-federation-trust"
# card. empty renders as TODO
goal: "Federate the last workload in `envs/prod` whose identity was a placeholder, through the trust anchor lesson 6 already declared, with the issuer, the audience and the exact subject pinned. Then write the two rules that refuse a trust anybody could match, watch the drift watch page rather than file a PR when a trust policy or an anchor is edited by hand, run the rotation check over an account that holds nothing to rotate and then over one that does, and forge a token to see the one thing the emulator cannot refuse."
done_when: "`just access-check` passes with `trust-subject-pinned` and `trust-audience-pinned` in its fixture stage, `terraform -chdir=access/envs/prod validate` refuses a wildcard subject on `site-publisher` with a message naming prescription 12, `aws iam get-role --role-name site-publisher` returns a trust whose principal is the actions provider with `aud` and `sub` both under `StringEquals`, `access/scripts/drift` exits 2 with two `page` findings after the trust policy and the anchor are edited by hand and 0 again after the apply, and `access/scripts/rotation` exits 0 on the applied estate and 2 under `--max-age-days 0` with a key made by hand."
restart_from: "checkpoint/i8"
properties: ["X", "V"]
closes: ["P12"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "40 min"
  needs:
    - "a water park checkout with the tags fetched"
    - "Docker running"
    - "the patched Floci image ghcr.io/lex00/floci:iam-boundary"
    - "terraform 1.9 or newer"
    - "tflint from terraform-linters/tap/tflint"
    - "jq"
    - "just access-init run once per clone"
    - "lesson 8 finished or at least read"
---

## Context

- A federated trust is three pins. The issuer is the `aws_iam_openid_connect_provider` the statement's `Principal` points at. The audience is the `aud` claim the issuer mints for this account, held with `StringEquals`. The subject is the exact workload, one repository on one branch or in one deployment environment, one namespace and service account, one SPIFFE path, held with `StringEquals` and spelled out in full. CI OIDC, Kubernetes service-account tokens and SPIRE SVIDs are the same mechanism with a different string in the third pin, and the repo never operates any of the three issuers (decision 13).
- The anchor lives beside the roles that trust it. An OIDC provider is account scoped, so it is declared in `envs/prod` next to `waterpark-apply` and `site-publisher`, and `identity/` holds none (decision 59). A second issuer is one more provider file in the same directory.
- Who may become a principal is the one edit that revoking a grant cannot undo, which is why this is the most checked thing in the repo. The obvious failure is a star in the subject. The quiet one is `StringLike` with no star, because a pattern operator is a wildcard waiting for somebody to add one, and the rule refuses it either way.
- Two layers, and they have not heard of each other, the same shape as `boundary-required` and IAM in lesson 8. A leaf file goes through `modules/persona`, whose `federated_trust` variable refuses a wildcard subject, an empty audience and an issuer host carrying a scheme at `terraform validate`. A raw `aws_iam_role` is read by two Rego rules at lint, `trust-subject-pinned` and `trust-audience-pinned`, each with a failing and a passing fixture.
- The drift watch from lesson 7 already routes a changed `assume_role_policy` to `page`. This lesson adds the anchor itself to that list, because a provider that gained a client id or lost its issuer is the same edit one level up. Neither is filed as a reconcile PR. Somebody wakes up, which is prescription 12's "flagged within one cycle".
- Credentials are short-lived everywhere. Workloads get a token per job, humans get an Identity Center session, and decision 5 bans IAM users, so a conforming account holds nothing to rotate. `access/scripts/rotation` reads the account anyway, because a console can make a user in ten seconds, and it lists every access key with its age against `static_secret_max_age_days` from `access/baseline`. It rides the drift watch's cron (decision 39), so one schedule drives both and lesson 13 teaches it once. Break-glass signing material joins the list in lesson 10.
- The agent sandbox is never a federation subject (decision 15). Nothing in this lesson mounts a token into one.
- The satellite's deploy credential from lesson 8 stays a script-minted user on the solo path. Its federated form is a `deployer` role trusted by the satellite's own issuer subject and carrying the conditioned `CreateRole` policy, and that role cannot sit inside the estate boundary, because the boundary denies all IAM write. That is the same second boundary decision 58 has not taken, and the lesson says so rather than shipping a role that cannot work.
- Roles Anywhere, in one paragraph. A fleet with an existing PKI and no OIDC issuer can federate X.509 certificates through an `aws_rolesanywhere_trust_anchor` and a profile, and the trust policy on the role then names the trust anchor ARN in a condition the same way these name a subject. It is the same three pins with a certificate authority where the issuer goes. This estate has no such fleet and the course builds nothing for it.
- A plan-tier read-only role, a second federated principal that can plan and never apply, is described on the lesson 6 page and not built. The two federated principals in this estate are the apply role and the publisher.

## Do

Lesson 8 handed a role to somebody else. This lesson is about the sentence in every role that says who may become it at all.

1. Start from the checkpoint lesson 8 left, bring Floci up, and apply central and then the satellite, in that order.

   ```sh
   git fetch origin --tags
   git worktree add ../waterpark-i9 checkpoint/i8
   cd ../waterpark-i9
   just access-init

   docker run -d --name wp-i9-floci -p 4566:4566 \
     -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \
     ghcr.io/lex00/floci:iam-boundary

   curl -s --retry 15 --retry-all-errors --retry-delay 1 \
     -o /dev/null -w '%{http_code}\n' http://localhost:4566/

   terraform -chdir=access/envs/prod init
   terraform -chdir=access/envs/prod apply -auto-approve
   terraform -chdir=access/satellites/waterpark-runner init
   terraform -chdir=access/satellites/waterpark-runner apply -auto-approve
   ```

   `200`, then `Resources: 17 added` for central and `8 added` for the
   satellite. Then read the two trust policies this lesson is about.

   ```sh
   export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1

   aws --endpoint-url http://localhost:4566 iam get-role \
     --role-name waterpark-apply \
     --query 'Role.AssumeRolePolicyDocument.Statement[0].[Principal,Condition]'

   aws --endpoint-url http://localhost:4566 iam get-role \
     --role-name site-publisher \
     --query 'Role.AssumeRolePolicyDocument.Statement[0].[Principal,Condition]'
   ```

   The apply role prints a `Federated` principal and a `StringEquals` block
   with the `aud` and the `sub` pinned, which is what lesson 6 wrote. The
   publisher prints `{"Service": "codebuild.amazonaws.com"}` and `null`. Nothing
   in this estate runs on CodeBuild. That trust is a placeholder the estate
   has carried since lesson 2, and it is the last one in `envs/prod`.

2. Federate the publisher. The site really is built by a GitHub Actions job, in the `github-pages` deployment environment that `.github/workflows/hugo.yml` names, so that job is the subject and nothing else is. Replace `access/envs/prod/iam_role.site_publisher.tf` with this.

   ```hcl
   # The site is built by a GitHub Actions job and nothing else, so the role that
   # publishes it is trusted by the GitHub Actions issuer and nothing else. The
   # subject is the deployment environment the publish job runs in, spelled out
   # in full, so a job on any other branch, in any other environment or from any
   # other repository the same issuer serves gets a token that names the wrong
   # subject and is refused at STS.
   #
   # Before lesson 9 this role was trusted by a service principal standing in
   # for a workload the estate had not federated yet. Federating it costs no new
   # resource, because the trust anchor already exists beside waterpark-apply,
   # and it removes the last workload in envs/prod whose identity was a
   # placeholder.
   module "site_publisher" {
     source = "../../modules/persona"

     persona     = "service"
     name        = "site-publisher"
     description = "Builds the site and writes it to the site bucket."
     owner       = local.owner
     teams       = ["platform"]

     permissions_boundary = module.baseline.boundary_arn

     federated_trust = {
       provider_arn = aws_iam_openid_connect_provider.actions.arn
       issuer_host  = var.actions_oidc_host
       audience     = "sts.amazonaws.com"

       # The publish job runs in the github-pages environment, so that is the
       # subject, and a job that is not in that environment is not the publisher.
       subjects = ["repo:INTENTIUS/waterpark:environment:github-pages"]
     }

     grants = [
       {
         resource = "waterpark-site"
         access   = "write"
         reason   = "Publishes the built site."
       },
       {
         resource = "waterpark-site"
         access   = "list"
         reason   = "Compares the build against what is already published."
       },
       {
         resource = "waterpark-artifacts"
         access   = "read"
         reason   = "Picks up the checkpoint bundle a lesson restarts from."
       },
     ]
   }
   ```

   The grants did not move. Only the trust did, and the trust anchor it points
   at is the one lesson 6 declared, so no new resource is created. Apply it and
   read it back out of the account rather than out of the file.

   ```sh
   terraform -chdir=access/envs/prod apply -auto-approve
   terraform -chdir=access/envs/prod plan -detailed-exitcode
   echo $?

   aws --endpoint-url http://localhost:4566 iam get-role \
     --role-name site-publisher \
     --query 'Role.AssumeRolePolicyDocument.Statement[0].[Principal,Condition]'
   ```

   `Resources: 0 added, 1 changed, 0 destroyed.`, then `0`, then

   ```json
   [
       {
           "Federated": "arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com"
       },
       {
           "StringEquals": {
               "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
               "token.actions.githubusercontent.com:sub": [
                   "repo:INTENTIUS/waterpark:environment:github-pages"
               ]
           }
       }
   ]
   ```

   Read it against the three pins. The issuer is the anchor's ARN. The
   audience is under `StringEquals`. The subject is under `StringEquals` and it
   is a whole string, not a prefix. A job in this repository on `main` that is
   not in the `github-pages` environment carries a token whose `sub` reads
   `repo:INTENTIUS/waterpark:ref:refs/heads/main`, and that string is not this
   string, so STS refuses it.

3. Loosen it and get refused before anything is applied. Edit the `subjects` line to a prefix with a star.

   ```hcl
       subjects = ["repo:INTENTIUS/*"]
   ```

   ```sh
   terraform -chdir=access/envs/prod validate
   ```

   ```text
   Error: Invalid value for variable

   A federated trust subject carries no wildcard. Name the branch or the
   environment in full, because a wildcard sub claim trusts every repository the
   issuer serves (prescription 12).
   ```

   That is `modules/persona` refusing at validate, which runs before plan,
   before the PR job and before the editor saves if `terraform-ls` is on. Put
   the exact subject back and run validate again until it says `Success!`.
   The module refuses two more shapes the same way, an empty `audience` and an
   `issuer_host` that carries `https://`, and the fixtures in step 5 cover
   both.

4. Write the trust rules. The module protects a leaf file, and a raw `aws_iam_role` written outside the module is read by nobody until this file exists. Write `access/.tflint.d/policies/trust.rego`.

   ```rego
   # The trust pack. Two rules over the one edit that cannot be undone by
   # revoking a grant, which is who may become a principal at all.
   #
   # A federated trust policy names an issuer, an audience and a subject. The
   # issuer is the aws_iam_openid_connect_provider the statement's Principal
   # points at. The audience is the aud claim the issuer mints, and the subject
   # is the exact workload. Pinning all three is prescription 12, and a wildcard
   # in the subject trusts every repository, branch or service account the
   # issuer serves. water park declares trust anchors and never operates an
   # issuer (decision 13), so the anchor is the whole of what the repo can get
   # right, and these rules are where it is checked.
   #
   # Both rules read the assume_role_policy of a raw aws_iam_role. A principal
   # file goes through modules/persona, whose federated_trust variable refuses a
   # wildcard subject and an empty audience at validate, so the two layers
   # agree, deliberately twice, the same way boundary-required and IAM do.
   #
   # Severity is the function-name prefix. deny_ is an error, warn_ is a
   # warning (decision 9). Both land as errors, because the estate already
   # conforms and a trust policy is not a rule to warn about.
   package tflint

   import rego.v1

   federated_actions := {"sts:AssumeRoleWithWebIdentity"}

   # The operators that pin a value. Anything else, StringLike above all, is a
   # pattern, and a pattern in a subject condition is a wildcard even when no
   # star is written, because a later edit can add one without changing the
   # operator.
   pinning_operators := {"StringEquals"}

   as_list(x) := x if is_array(x)

   as_list(x) := [x] if is_string(x)

   trust_statements(doc) := [st |
   	some st in policy_statements(doc)
   	st.Effect == "Allow"
   	some act in statement_actions(st)
   	act in federated_actions
   ]

   # Every condition on a statement, flattened to operator, key, value.
   conditions(st) := [{"op": op, "key": key, "value": v} |
   	some op, keys in st.Condition
   	some key, raw in keys
   	some v in as_list(raw)
   ]

   sub_conditions(st) := [c | some c in conditions(st); endswith(c.key, ":sub")]

   aud_conditions(st) := [c | some c in conditions(st); endswith(c.key, ":aud")]

   federated_roles := terraform.resources("aws_iam_role", {"assume_role_policy": "string"}, {"expand_mode": "none"})

   # A subject that is not pinned is a trust in the issuer rather than in a
   # workload. Three ways to get there, and each one is named so the fix is
   # the fix for that one.
   deny_trust_subject_pinned contains issue if {
   	some r in federated_roles
   	not r.config.assume_role_policy.unknown
   	doc := json.unmarshal(r.config.assume_role_policy.value)
   	some st in trust_statements(doc)
   	count(sub_conditions(st)) == 0
   	issue := tflint.issue(
   		sprintf(
   			"aws_iam_role.%s trusts a federated issuer with no subject condition, so every token the issuer mints can become it. Add a StringEquals <issuer>:sub condition naming the exact workload.",
   			[r.name],
   		),
   		r.config.assume_role_policy.range,
   	)
   }

   deny_trust_subject_pinned contains issue if {
   	some r in federated_roles
   	not r.config.assume_role_policy.unknown
   	doc := json.unmarshal(r.config.assume_role_policy.value)
   	some st in trust_statements(doc)
   	some c in sub_conditions(st)
   	not c.op in pinning_operators
   	issue := tflint.issue(
   		sprintf(
   			"aws_iam_role.%s matches its subject with %s. A subject is pinned with StringEquals and spelled out in full, because a pattern trusts every workload it happens to match.",
   			[r.name, c.op],
   		),
   		r.config.assume_role_policy.range,
   	)
   }

   deny_trust_subject_pinned contains issue if {
   	some r in federated_roles
   	not r.config.assume_role_policy.unknown
   	doc := json.unmarshal(r.config.assume_role_policy.value)
   	some st in trust_statements(doc)
   	some c in sub_conditions(st)
   	regex.match(`[*?]`, c.value)
   	issue := tflint.issue(
   		sprintf(
   			"aws_iam_role.%s trusts the subject %q, which carries a wildcard. Name the repository and branch, the namespace and service account, or the SPIFFE path in full (prescription 12).",
   			[r.name, c.value],
   		),
   		r.config.assume_role_policy.range,
   	)
   }

   # The audience is what stops a token minted for somebody else being replayed
   # here. A federated statement pins it with StringEquals, and the provider it
   # points at lists it, so a token has to name this account on purpose.
   deny_trust_audience_pinned contains issue if {
   	some r in federated_roles
   	not r.config.assume_role_policy.unknown
   	doc := json.unmarshal(r.config.assume_role_policy.value)
   	some st in trust_statements(doc)
   	count([c | some c in aud_conditions(st); c.op in pinning_operators]) == 0
   	issue := tflint.issue(
   		sprintf(
   			"aws_iam_role.%s trusts a federated issuer with no StringEquals <issuer>:aud condition. Pin the audience the issuer mints for this account, so a token minted for another consumer cannot be replayed here.",
   			[r.name],
   		),
   		r.config.assume_role_policy.range,
   	)
   }

   deny_trust_audience_pinned contains issue if {
   	some r in terraform.resources("aws_iam_openid_connect_provider", {"client_id_list": "list(string)"}, {"expand_mode": "none"})
   	not r.config.client_id_list.unknown
   	count(r.config.client_id_list.value) == 0
   	issue := tflint.issue(
   		sprintf(
   			"aws_iam_openid_connect_provider.%s lists no client id, so it honors no audience at all. Name the audience the workflows ask for, sts.amazonaws.com for GitHub Actions.",
   			[r.name],
   		),
   		r.config.client_id_list.range,
   	)
   }

   deny_trust_audience_pinned contains issue if {
   	some r in terraform.resources("aws_iam_openid_connect_provider", {"url": "string"}, {"expand_mode": "none"})
   	not r.config.url.unknown
   	not startswith(r.config.url.value, "https://")
   	issue := tflint.issue(
   		sprintf(
   			"aws_iam_openid_connect_provider.%s names an issuer that is not https. A trust anchor whose discovery document travels in the clear is an anchor anyone on the path can rewrite.",
   			[r.name],
   		),
   		r.config.url.range,
   	)
   }
   ```

   `policy_statements` and `statement_actions` are not defined here. They
   live in `security.rego` in the same package, which is where
   `no-wildcard-action` reads a policy document, and a trust policy is a
   policy document. Three things in the file are worth a second read.

   `pinning_operators` is one operator. `StringLike` is refused even when no
   star is written, and the second clause says why in its message.

   `conditions` flattens whatever shape the statement carries. A condition
   value in IAM is a string or a list of strings, and the module writes the
   list form, so the rule reads both.

   The audience rule has two more clauses over the provider itself, because
   an anchor with an empty `client_id_list` honors no audience and an anchor
   that is not `https` is an anchor anyone on the path can rewrite.

5. Give each rule a failing and a passing fixture, because a rule change without a fixture change is a rule nobody tested. Write the four files under `access/tests/fixtures/trust-subject-pinned/`, two in `fail/` and two in `pass/`.

   `fail/iam_role.wildcard_subject.tf`

   ```hcl
   # Fails trust-subject-pinned twice over. StringLike is a pattern, and the
   # pattern carries a star, so every branch of every repository under
   # INTENTIUS can become this role.
   resource "aws_iam_role" "wildcard_subject" {
     name                 = "wildcard-subject"
     permissions_boundary = "arn:aws:iam::000000000000:policy/waterpark-estate-boundary"

     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect    = "Allow"
         Principal = { Federated = "arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com" }
         Action    = "sts:AssumeRoleWithWebIdentity"
         Condition = {
           StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
           StringLike   = { "token.actions.githubusercontent.com:sub" = "repo:INTENTIUS/*" }
         }
       }]
     })

     tags = {
       owner = "platform"
     }
   }
   ```

   `fail/iam_role.no_subject.tf`

   ```hcl
   # Fails trust-subject-pinned. The audience is pinned and the subject is not
   # mentioned, so any token the issuer mints for this account can become the
   # role. This is a trust in the issuer rather than in a workload.
   resource "aws_iam_role" "no_subject" {
     name                 = "no-subject"
     permissions_boundary = "arn:aws:iam::000000000000:policy/waterpark-estate-boundary"

     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect    = "Allow"
         Principal = { Federated = "arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com" }
         Action    = "sts:AssumeRoleWithWebIdentity"
         Condition = {
           StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
         }
       }]
     })

     tags = {
       owner = "platform"
     }
   }
   ```

   `pass/iam_role.pinned_subject.tf`

   ```hcl
   # Passes. The issuer, the audience and the exact subject, one repository on
   # one branch, all pinned with StringEquals. A SPIFFE subject or a Kubernetes
   # service account is the same shape with a different string.
   resource "aws_iam_role" "pinned_subject" {
     name                 = "pinned-subject"
     permissions_boundary = "arn:aws:iam::000000000000:policy/waterpark-estate-boundary"

     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect    = "Allow"
         Principal = { Federated = "arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com" }
         Action    = "sts:AssumeRoleWithWebIdentity"
         Condition = {
           StringEquals = {
             "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
             "token.actions.githubusercontent.com:sub" = "repo:INTENTIUS/waterpark:ref:refs/heads/main"
           }
         }
       }]
     })

     tags = {
       owner = "platform"
     }
   }
   ```

   `pass/iam_role.service_trust.tf`

   ```hcl
   # Passes, because the rule reads federated statements only. A role trusted by
   # an AWS service principal has no subject to pin.
   resource "aws_iam_role" "service_trust" {
     name                 = "service-trust"
     permissions_boundary = "arn:aws:iam::000000000000:policy/waterpark-estate-boundary"

     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect    = "Allow"
         Principal = { Service = "codebuild.amazonaws.com" }
         Action    = "sts:AssumeRole"
       }]
     })

     tags = {
       owner = "platform"
     }
   }
   ```

   The second passing fixture is the one that matters for the rest of the
   estate. `desk-operator` and `runner-builder` are still trusted by a service
   principal, and a rule that fired on them would be a rule that fires on
   every role in every account that has never heard of OIDC.

6. Bring in the pieces this lesson does not write. The audience fixtures are the same shape as the four above with the other pin missing, and the rest is machinery.

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

   What each one is.

   `check` gains the two rules in its fixture table, and one more thing.
   Lesson 6's fork-PR check read `permissions` inside each job and never at
   the top of the file, so a workflow-level `id-token: write`, which every
   job inherits, passed it. Step 11 shows the fix.

   `rotation` is step 9. `drift` gains `aws_iam_openid_connect_provider` in
   its `page` list, and step 8 shows why.

   `modules/persona/variables.tf` is the three validations step 3 hit.
   `baseline/locals.tf` and the two `outputs.tf` carry the new constant,
   `static_secret_max_age_days`, through to where `rotation` reads it.

   `drift.yml` runs `rotation` after the watch on the same cron and fails the
   job when a key stands over the window. Against the job's own container the
   answer is always none, for the same reason the watch there is always clean,
   and the job comment says so.

7. Run the whole check stack, and then run one fixture by hand to see the messages the stack summarises.

   ```sh
   just access-check
   ```

   `trust-subject-pinned (error)` and `trust-audience-pinned (error)` appear
   under the rule fixtures, the fork-PR line now says `and the workflow level
   grants neither`, and the run ends `check passed`. The fixture stage prints
   one `ok` per rule, so run the failing fixture yourself to see the refusals.

   ```sh
   TFLINT_OPA_POLICY_DIR=$PWD/access/.tflint.d/policies \
     tflint --chdir=access/tests/fixtures/trust-subject-pinned/fail \
       --config=$PWD/access/.tflint.hcl \
       --only=opa_deny_trust_subject_pinned \
       --minimum-failure-severity=notice --format=compact
   ```

   Three issues, and the path in front of each depends on where you stand.

   ```text
   iam_role.no_subject.tf:8:24: Error - aws_iam_role.no_subject trusts a federated issuer with no subject condition, so every token the issuer mints can become it. Add a StringEquals <issuer>:sub condition naming the exact workload. (opa_deny_trust_subject_pinned)
   iam_role.wildcard_subject.tf:8:24: Error - aws_iam_role.wildcard_subject matches its subject with StringLike. A subject is pinned with StringEquals and spelled out in full, because a pattern trusts every workload it happens to match. (opa_deny_trust_subject_pinned)
   iam_role.wildcard_subject.tf:8:24: Error - aws_iam_role.wildcard_subject trusts the subject "repo:INTENTIUS/*", which carries a wildcard. Name the repository and branch, the namespace and service account, or the SPIFFE path in full (prescription 12). (opa_deny_trust_subject_pinned)
   ```

   The wildcard fixture fires twice, once for the operator and once for the
   star, and each message carries its own fix. That is prescription 4 again,
   a guardrail that only says no is a bad guardrail.

8. Edit the trust by hand, the way a person in a console would, and watch the severity. Two moves. Widen the publisher's subject to a prefix, and add a second audience to the anchor.

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

   ```text
   drift report, 2026-09-10T19:37:01Z

     [page] envs/prod  aws_iam_openid_connect_provider.actions
         update
         client_id_list
           declared ["sts.amazonaws.com"]
           live     ["other.example.com","sts.amazonaws.com"]

     [page] envs/prod  module.site_publisher.aws_iam_role.this[0]
         update
         assume_role_policy
           declared {"Statement":[{"Action":"sts:AssumeRoleWithWebIdentity","Condition":{"StringEquals":{"token.actions.githubusercontent.com:aud":"sts.amazonaws.com","token.actions.githubusercontent.com:sub":["repo:INTENTIUS/waterpark:environment:github-pages"]}},"Effect":"Allow","Principal":{"Federated":"arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com"}}],"Version":"2012-10-17"}
           live     {"Statement":[{"Action":"sts:AssumeRoleWithWebIdentity","Condition":{"StringEquals":{"token.actions.githubusercontent.com:aud":"sts.amazonaws.com"},"StringLike":{"token.actions.githubusercontent.com:sub":"repo:INTENTIUS/*"}},"Effect":"Allow","Principal":{"Federated":"arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com"}}],"Version":"2012-10-17"}

     2 finding(s), 2 of them paging
   ```

   and `2`. In lesson 7 a detached policy and a retagged role came back `pr`,
   and the reconcile plan would have filed one pull request each. These two
   come back `page`, and `reconcile` prints them for a human and files
   nothing. A widened trust is not paperwork. The anchor is on that list
   since this lesson, because an anchor that honors a second audience is a
   role that trusts a second issuer's consumers, one level up from the trust
   policy.

   Put the account back the way lesson 7 did, with the apply, and confirm the
   watch is quiet.

   ```sh
   terraform -chdir=access/envs/prod apply -auto-approve
   access/scripts/drift
   echo $?
   ```

   `Resources: 0 added, 2 changed, 0 destroyed.`, then
   `every watched root matches the account` and `0`.

9. Run the rotation check, over an account that holds nothing to rotate and then over one that does.

   ```sh
   access/scripts/rotation
   echo $?
   ```

   ```text
   rotation check, 2026-09-10T19:35:48Z

     window        90 days (access/baseline)
     trust anchors 1, nothing to rotate behind them
     access keys   none in the account

     nothing to rotate. Every principal in this account is a role or a permission set.
   ```

   and `0`. That is the estate as declared. Every workload gets a token per
   job through the anchor on the second line, every human gets an Identity
   Center session, and decision 5 leaves no user to hold a key. Now make one
   the way a console would.

   ```sh
   aws --endpoint-url http://localhost:4566 iam create-user --user-name console-made
   aws --endpoint-url http://localhost:4566 iam create-access-key --user-name console-made \
     --query AccessKey.AccessKeyId --output text

   access/scripts/rotation
   echo $?
   ```

   ```text
     access keys   1

     [within] console-made  AKIA...
         Active, created 2026-09-10T19:35:49.669816+00:00, 0 day(s) old

     every key is inside the window, and every key is a user this repo does not declare (decision 5). The drift watch owns that finding.
   ```

   and `0`, because the key is a minute old and the window is ninety days.
   The last line is the honest one. This check answers "how old" and nothing
   else, and the user existing at all is a different finding that belongs to
   a different watch. Now ask the question the estate actually poses, which
   is whether any static secret may stand at all.

   ```sh
   access/scripts/rotation --max-age-days 0
   echo $?
   ```

   ```text
     [rotate] console-made  AKIA...
         Active, created 2026-09-10T19:35:49.669816+00:00, 0 day(s) old

     1 key(s) over the window. Rotate them, or better, remove the user and federate the workload.
   ```

   and `2`. A key at the window is over it, so a window of zero is the
   estate's own policy stated as a number. The ninety in `access/baseline` is
   for the secrets lesson 10 adds, and the drift job would fail on this line.
   Clean up.

   ```sh
   aws --endpoint-url http://localhost:4566 iam delete-access-key --user-name console-made \
     --access-key-id "$(aws --endpoint-url http://localhost:4566 iam list-access-keys \
       --user-name console-made --query 'AccessKeyMetadata[0].AccessKeyId' --output text)"
   aws --endpoint-url http://localhost:4566 iam delete-user --user-name console-made
   access/scripts/rotation | tail -1
   ```

   `nothing to rotate.` again.

10. Forge a token, and see the one thing the emulator cannot refuse.

    ```sh
    aws --endpoint-url http://localhost:4566 sts assume-role-with-web-identity \
      --role-arn arn:aws:iam::000000000000:role/site-publisher \
      --role-session-name forged \
      --web-identity-token not.a.real.token \
      --query '[SubjectFromWebIdentityToken,Provider,Audience,AssumedRoleUser.Arn]'
    ```

    ```json
    [
        "web-identity-subject",
        "accounts.google.com",
        "sts.amazonaws.com",
        "arn:aws:sts::000000000000:assumed-role/site-publisher/forged"
    ]
    ```

    It worked, and it should not have. The token is three words with dots in
    them. Real STS fetches the issuer's signing keys from the discovery
    document behind the anchor's URL, checks the signature, and refuses before
    the `aud` and `sub` conditions are ever read. Floci's
    `AssumeRoleWithWebIdentity` is a stub that mints credentials for any
    non-empty token, reports the provider as `accounts.google.com` whatever the
    anchor declared, and evaluates no condition at all. It fails open.

    So the solo path proves that the trust is declared, pinned, checked twice
    and watched. It cannot prove that a bad token is refused, and this lesson
    runs the forged call rather than leaving you to assume the emulator would
    have caught it. Against a real account the same command returns
    `InvalidIdentityToken`, and the live section is where that gets shown.

11. Close the gap lesson 6 left in the fork-PR check. Open `.github/workflows/access.yml` and add one line to the workflow-level block at the top, the one above `jobs:`.

    ```yaml
    permissions:
      contents: read
      id-token: write
    ```

    ```sh
    access/scripts/check workflow
    ```

    ```text
    FAIL  the workflow-level permissions block asks for id-token: write, which every job inherits, the pr job included
    ```

    Before this lesson that edit passed. The check read each job's own block
    and never the top of the file, and a grant at the top of the file is
    inherited by every job that does not override it, the `pr` job included.
    An untrusted author could federate. Delete the line, run the check again,
    and it ends `check passed`. Every fixture in the estate now covers a
    workflow-level `permissions` and `env` as well as a job-level one.

12. Compare with the reference repo, then tear down. The fixtures and the rule file are new, and untracked files do not appear in a diff, so stage first.

    ```sh
    git add -A access .github
    git diff --cached --stat checkpoint/i9 -- access .github ':!*README.md'

    terraform -chdir=access/satellites/waterpark-runner destroy -auto-approve
    terraform -chdir=access/envs/prod destroy -auto-approve
    docker rm -f wp-i9-floci
    ```

    Nothing printed means every file you wrote is the reference file. The
    `README.md` files are excluded and they are the only exclusions, because
    each is prose the reference tree carries about this lesson and none is
    something a step above asked you to write. If the diff names anything
    else, read the difference rather than pasting over it.

## Self-paced

The whole lesson runs on Floci, and the honesty line is in step 10 rather than at the end.

What Floci shows. `aws_iam_openid_connect_provider` applies and reads back, `get-open-id-connect-provider` round-trips the url, the client ids and the thumbprint, a role trusting it applies and plans clean, `update-assume-role-policy` and `add-client-id-to-open-id-connect-provider` land as drift the watch reports, and `list-access-keys` returns a create date the rotation check can age. Everything declared, checked and watched in this lesson is real on the emulator.

What Floci cannot show. `AssumeRoleWithWebIdentity` is a stub, recorded in [upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md). It mints credentials for any non-empty token, hardcodes the provider and the subject, and enforces no `aud` or `sub` condition. The one thing a federated trust exists to do, refuse a token that was not minted by the issuer for this workload, does not happen here. Step 10 runs the forged call on purpose so nobody leaves believing the emulator would have caught it. A fork fix in Floci's STS would close this, and the lesson is written to work the day it lands.

What this lesson builds and what it does not. It federates one workload that has an issuer, writes the rules that refuse a trust anybody could match, pages on a changed trust or anchor, and reads the account for static secrets on the watch's schedule. It does not federate the satellite's deploy credential from lesson 8. That credential's federated form is a `deployer` role that carries the conditioned `CreateRole` policy and cannot sit inside the estate boundary, because the boundary denies all IAM write, which is the second boundary decision 58 has not taken. The lesson names it rather than shipping a role that could not work.

The rotation check reads the account as the throwaway root, which is what every script here does on the solo path. On a real account it needs `iam:ListUsers` and `iam:ListAccessKeys`, which the security account's reviewer role holds and nothing inside the estate boundary does, and `ROTATION_LIVE=true` skips the endpoint override.

## Live

Twenty five minutes, in three moves, and the room needs steps 3, 8 and 10.

Open on step 3. Put `repo:INTENTIUS/*` in the publisher's subject on the projector and run `validate`. The refusal names the prescription. Then change the operator to `StringLike` with the exact subject and no star, and run the fixture from step 7 on a copy of the raw role. The room expects that one to pass, and the line to say is that a pattern operator is a wildcard waiting for somebody to add the star, so the rule does not wait.

Then step 8, both console edits, one `drift`. Ask the room what a reconcile PR for either finding would look like, and let somebody notice that merging it would put the trust back without anyone asking who widened it or why. That is why these page. The apply restores the account and the question of who did it is the question a page exists to ask.

Then step 10, and here the live path shows what the solo path cannot. Run the forged call against the real sandbox account.

```sh
aws sts assume-role-with-web-identity \
  --role-arn arn:aws:iam::<account>:role/site-publisher \
  --role-session-name forged \
  --web-identity-token not.a.real.token
```

`An error occurred (InvalidIdentityToken)`. The token was never a token, and STS said so before it read a single condition. Then say the honesty line straight off the page. On the emulator that same command succeeds, because the STS there is a stub, and we run it on the solo path on purpose so a student sees the gap rather than assumes it closed.

The second honesty line is the satellite. Lesson 8 minted an IAM user to stand in for a federated deploy role, and this lesson did not replace it. The replacement is a role that cannot sit inside the estate boundary, and that is decision 58's open question wearing a different hat. A course that hid that would be teaching something we do not believe.

Live, the same code runs against a real account with `-var floci=false`, the rotation check runs with `ROTATION_LIVE=true` as the security account's reviewer, and the drift job's cron fires against the account rather than against a container it filled itself.

## Further reading

- [access/README.md](https://github.com/INTENTIUS/waterpark/blob/main/access/README.md), "Lesson 9, federation trust"
- [access/.tflint.d](https://github.com/INTENTIUS/waterpark/blob/main/access/.tflint.d/README.md), the rule pack and its contract
- [access/scripts](https://github.com/INTENTIUS/waterpark/blob/main/access/scripts/README.md), what each script is for
- [Workload identity](../../docs/design/workload-identity.md)
- [The estate](../../docs/estate.md), the principals
- [Prescriptions](../../docs/prescriptions.md), 12
- [Decisions](../../docs/decisions.md), 5, 13, 15, 39, 54, 58 and 59
- [Upstream](https://github.com/INTENTIUS/waterpark/blob/main/project/upstream.md), the web identity stub
- [Issues](https://github.com/INTENTIUS/waterpark/blob/main/project/archive/issues.md) A17 and A18
