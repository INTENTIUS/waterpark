# The satellite runs the central rule pack. This file is half of the
# delegation contract, and the boundary ARN in data.tf is the other half.
#
# The pack itself is Rego, and tflint takes it from a directory named by
# TFLINT_OPA_POLICY_DIR rather than from a source line, because the OPA
# ruleset has no git source of its own. So there are two ways to point at it
# and this repo uses the first.
#
#   In this repo, the satellite is a sibling root under access/ (decision 49),
#   so the pack is already on disk and access/scripts/check exports
#
#     TFLINT_OPA_POLICY_DIR=access/.tflint.d/policies
#
#   In a satellite that is its own repository, the pack is vendored at the
#   same pinned ref the shared module comes from (decision 50), and the ref is
#   what makes an upgrade a deliberate act rather than a surprise.
#
#     git clone --depth 1 --branch checkpoint/i8 \
#       https://github.com/INTENTIUS/waterpark.git .waterpark-guardrails
#     export TFLINT_OPA_POLICY_DIR=.waterpark-guardrails/access/.tflint.d/policies
#
# Severity is the function-name prefix in the Rego, deny_ for an error and
# warn_ for a warning, which is how a new rule reaches a satellite as a
# warning first and becomes an error only at a later pinned ref (decision 9).
# See access/.tflint.d/README.md.
config {
  call_module_type = "none"
}

plugin "terraform" {
  enabled = false
}

plugin "opa" {
  enabled = true
  version = "0.8.0"
  source  = "github.com/terraform-linters/tflint-ruleset-opa"
}
