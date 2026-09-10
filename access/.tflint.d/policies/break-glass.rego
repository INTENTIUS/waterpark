# The break-glass rule. A grant that exists for an incident carries its own
# expiry, and the expiry is at most the baseline TTL after it was granted
# (decision 37, prescription 9).
#
# The rule reads the grants list on a module call in a principal file, the
# same way boundary-required reads the boundary line, because tflint reads
# the calling directory only and the policy the grant becomes is inside the
# module. modules/persona refuses the same three shapes at validate, so the
# two layers agree, deliberately twice.
#
# The TTL is restated here, because Rego reads the directory it is pointed
# at and nothing else, and it is restated as the module's default for the
# same reason one level down. access/scripts/check compares both with
# break_glass_max_ttl_hours in access/baseline and fails when they differ,
# so the constant still lives in one place and these are copies the check
# keeps honest.
package tflint

import rego.v1

break_glass_max_ttl_hours := 2

grants_schema := {"grants": "list(object({resource=string, access=string, expires=optional(string), reason=optional(string), granted_at=optional(string)}))"}

principal_calls := [m |
	some m in terraform.module_calls(grants_schema, {"expand_mode": "none"})
	regex.match(`(^|/)(iam_role|ssoadmin_permission_set)\.[a-z0-9_]+\.tf$`, m.decl_range.filename)
	m.config.grants
	not m.config.grants.unknown
]

break_glass_grants(m) := [g |
	some g in m.config.grants.value
	g.granted_at != null
]

deny_break_glass_ttl contains issue if {
	some m in principal_calls
	some g in break_glass_grants(m)
	g.expires == null
	issue := tflint.issue(
		sprintf(
			"module %q grants %s on %s for an incident with no expires. A break-glass grant carries its own expiry, so the cloud ends it when every job is dead (prescription 9).",
			[m.name, g.access, g.resource],
		),
		m.config.grants.range,
	)
}

deny_break_glass_ttl contains issue if {
	some m in principal_calls
	some g in break_glass_grants(m)
	g.reason == null
	issue := tflint.issue(
		sprintf(
			"module %q grants %s on %s for an incident with no reason. Say what the incident is, because the reason is what the audit trail reads.",
			[m.name, g.access, g.resource],
		),
		m.config.grants.range,
	)
}

deny_break_glass_ttl contains issue if {
	some m in principal_calls
	some g in break_glass_grants(m)
	g.expires != null
	ttl_hours := (time.parse_rfc3339_ns(g.expires) - time.parse_rfc3339_ns(g.granted_at)) / 3600000000000
	ttl_hours > break_glass_max_ttl_hours
	issue := tflint.issue(
		sprintf(
			"module %q grants %s on %s for %v hours. A break-glass grant lasts at most %v hours after granted_at (access/baseline, decision 37). Shorten the expiry, or grant again when it runs out.",
			[m.name, g.access, g.resource, ttl_hours, break_glass_max_ttl_hours],
		),
		m.config.grants.range,
	)
}
