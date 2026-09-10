# The on-call, on the solo path. A human, so live this is course-author's
# permission set under access/identity carrying a break-glass grant, and the
# standing Identity Center assignment is what makes the grant reachable
# (decision 37). Floci runs no Identity Center, so here the same grant lands
# on a role that stands in for the permission set, and the page says so.
#
# At rest this principal holds nothing. A break-glass grant is a pull request
# that adds one grant here with a granted_at, an expiry no more than the
# baseline TTL later, and a reason, and access/scripts/break-glass writes and
# revokes that block. The cloud ends the access at the expiry whether or not
# anything else runs (decision 8).
module "on_call" {
  source = "../../modules/persona"

  persona     = "service"
  name        = "on-call"
  description = "The on-call's break-glass stand-in on the solo path. Holds nothing at rest, and a grant here is an incident with an expiry."
  owner       = local.owner
  teams       = ["platform"]

  permissions_boundary = module.baseline.boundary_arn
  break_glass_approver = var.break_glass_approver

  grants = []
}
