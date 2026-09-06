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
