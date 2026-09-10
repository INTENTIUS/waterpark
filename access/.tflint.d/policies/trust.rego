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
