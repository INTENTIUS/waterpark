# The security pack. Every rule here has a failing and a passing fixture
# under access/tests/fixtures, and every rule carries a fix in its message,
# because a guardrail that only says no is a bad guardrail (prescription 4).
#
# Severity is the function-name prefix. deny_ is an error, warn_ is a
# warning. A new rule lands as a warning and is promoted in a later lesson
# once the estate conforms (decision 9).
package tflint

import rego.v1

inline_policy_types := {
	"aws_iam_role_policy",
	"aws_iam_user_policy",
	"aws_iam_group_policy",
}

no_identity_types := {
	"aws_iam_user",
	"aws_iam_group",
	"aws_iam_access_key",
	"aws_iam_user_login_profile",
	"aws_iam_user_policy_attachment",
	"aws_iam_group_policy_attachment",
	"aws_iam_group_membership",
}

owner_tagged_types := {
	"aws_iam_role",
	"aws_iam_policy",
	"aws_s3_bucket",
	"aws_ecr_repository",
	"aws_ssoadmin_permission_set",
}

open_cidrs := {"0.0.0.0/0", "::/0"}

policy_statements(doc) := doc.Statement if is_array(doc.Statement)

policy_statements(doc) := [doc.Statement] if is_object(doc.Statement)

statement_actions(st) := st.Action if is_array(st.Action)

statement_actions(st) := [st.Action] if is_string(st.Action)

owner_tagged(r) if r.config.tags.unknown

owner_tagged(r) if {
	not r.config.tags.unknown
	r.config.tags.value.owner != ""
}

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

# An inline policy has no ARN, so nothing can reference it, diff it by name or
# reuse it. Use aws_iam_policy plus an attachment.
deny_no_inline_policy contains issue if {
	some t in inline_policy_types
	some r in terraform.resources(t, {}, {"expand_mode": "none"})
	issue := tflint.issue(
		sprintf(
			"%s.%s is an inline policy. Declare an aws_iam_policy and attach it, so the grant has an ARN a review can name.",
			[t, r.name],
		),
		r.decl_range,
	)
}

# Humans get permission sets and workloads get roles. There are no IAM users
# and no IAM groups (decision 5, prescription 3).
deny_no_iam_user_or_group contains issue if {
	some t in no_identity_types
	some r in terraform.resources(t, {}, {"expand_mode": "none"})
	issue := tflint.issue(
		sprintf(
			"%s.%s declares an IAM user or group. Humans get an Identity Center permission set under access/identity, workloads get a role from modules/persona (decision 5).",
			[t, r.name],
		),
		r.decl_range,
	)
}

# An access review answers "who do I ask about this" from the tag alone.
deny_tag_owner_required contains issue if {
	some t in owner_tagged_types
	some r in terraform.resources(t, {"tags": "map(string)"}, {"expand_mode": "none"})
	not owner_tagged(r)
	issue := tflint.issue(
		sprintf(
			"%s.%s carries no owner tag. Add tags = { owner = local.owner }, or pass owner to modules/persona.",
			[t, r.name],
		),
		r.decl_range,
	)
}

# Warning today. Lesson 5 builds the boundary and promotes this to deny_,
# which is the warn cycle decision 9 asks for.
warn_boundary_required contains issue if {
	some r in terraform.resources("aws_iam_role", {"permissions_boundary": "string"}, {"expand_mode": "none"})
	not r.config.permissions_boundary
	issue := tflint.issue(
		sprintf(
			"aws_iam_role.%s carries no permissions_boundary. Every role water park emits sits inside the estate boundary from access/baseline.",
			[r.name],
		),
		r.decl_range,
	)
}

# Warning, because the estate declares no security groups yet, so the rule has
# no live coverage to ratchet against.
warn_no_open_ingress contains issue if {
	some r in terraform.resources("aws_vpc_security_group_ingress_rule", {"cidr_ipv4": "string", "cidr_ipv6": "string"}, {"expand_mode": "none"})
	some key in ["cidr_ipv4", "cidr_ipv6"]
	attr := r.config[key]
	not attr.unknown
	attr.value in open_cidrs
	issue := tflint.issue(
		sprintf(
			"aws_vpc_security_group_ingress_rule.%s opens %s to %s. Name the source security group with referenced_security_group_id.",
			[r.name, key, attr.value],
		),
		attr.range,
	)
}

# Warning, same reason as no-open-ingress.
warn_sg_reference_not_cidr contains issue if {
	some r in terraform.resources("aws_vpc_security_group_ingress_rule", {"cidr_ipv4": "string"}, {"expand_mode": "none"})
	r.config.cidr_ipv4
	issue := tflint.issue(
		sprintf(
			"aws_vpc_security_group_ingress_rule.%s names a raw CIDR. Reference the source security group with referenced_security_group_id, so the rule survives a renumbering.",
			[r.name],
		),
		r.config.cidr_ipv4.range,
	)
}
