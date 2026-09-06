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
