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
    {
      resource = "waterpark-artifacts"
      access   = "list"
      reason   = "Sees which checkpoint bundles exist before picking one."
    },
  ]
}
