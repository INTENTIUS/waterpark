module "runner_builder" {
  source = "../../modules/persona"

  persona     = "service"
  name        = "runner-builder"
  description = "Builds the sandbox runner image and pushes it."
  owner       = local.owner
  teams       = ["platform"]

  permissions_boundary = module.baseline.boundary_arn

  grants = [
    {
      resource = "waterpark-artifacts"
      access   = "write"
      reason   = "Publishes the runner build's artifacts."
    },
    {
      resource = "waterpark-artifacts"
      access   = "list"
      reason   = "Reads what it already published before pushing again."
    },
  ]
}
