# The apply role. One path to prod ends here, and this file is the only
# declaration of what runs at the end of it.
#
# It is trusted by the GitHub Actions issuer alone, for one repository, on
# one branch, with the audience pinned. There is no service principal, no
# static key and no second subject, so the only thing on earth that can
# become this role is a job on main in INTENTIUS/waterpark.
#
# It carries the estate boundary, because water park must not be able to
# escalate water park (decision 12). The boundary denies boundary detachment
# outright and denies the guardrail path by name, and this role is on that
# path, so it cannot rewrite the fence it stands behind.
# access/scripts/prove-no-detach is the proof, and it is prescription 7's
# check.
#
# The cost, named out loud. The estate boundary also denies all IAM write
# (decision 36), so against a real account this role could not apply the
# estate it is meant to apply. On the taught path that never bites, because
# the apply job runs against a Floci service container with the throwaway
# test credentials (decision 51) and never assumes this role. A real account
# needs an apply-specific boundary, one that permits IAM write inside the
# estate while keeping the detachment and guardrail-path denies, and that is
# a second boundary decision 36 has not taken yet. The lesson says so rather
# than shipping a role that quietly cannot work.
module "waterpark_apply" {
  source = "../../modules/persona"

  persona     = "deployer"
  name        = "waterpark-apply"
  description = "The role the apply job federates into. One repository, one branch, its own boundary, and no policy until the boundary question in decision 36 is settled."
  owner       = local.owner
  teams       = ["platform"]

  permissions_boundary = module.baseline.boundary_arn

  federated_trust = {
    provider_arn = aws_iam_openid_connect_provider.actions.arn
    issuer_host  = var.actions_oidc_host
    audience     = "sts.amazonaws.com"

    # The exact subject, not a pattern. This is the whole trust boundary of
    # the write path, so a wildcard here would hand the estate to any branch
    # of any repository the issuer serves. The module refuses one.
    subjects = ["repo:INTENTIUS/waterpark:ref:refs/heads/main"]
  }

  # No grants. See the cost above.
  grants = []
}
