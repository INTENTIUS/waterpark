module "site_publisher" {
  source = "../../modules/persona"

  persona     = "service"
  name        = "site-publisher"
  description = "Builds the site and writes it to the site bucket."
  owner       = local.owner
  teams       = ["platform"]

  permissions_boundary = module.baseline.boundary_arn

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
