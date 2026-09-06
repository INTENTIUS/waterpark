# The estate boundary and the constants later lessons read. One boundary for
# the whole estate, so this call is the only place it is made (decision 36).
module "baseline" {
  source = "../../baseline"

  owner = local.owner

  # waterpark-prod is not a sandbox. A Sandbox OU environment sets this true
  # and gets no boundary at all.
  sandbox = false
}
