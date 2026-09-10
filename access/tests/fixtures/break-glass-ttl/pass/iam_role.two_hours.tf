# Passes. Exactly the baseline TTL, with a reason, and a standing grant
# beside it that the rule does not read because it carries no granted_at.
module "two_hours" {
  source = "../../../../modules/persona"

  persona     = "service"
  name        = "two-hours"
  description = "A break-glass grant inside the TTL."
  teams       = ["platform"]

  permissions_boundary = "arn:aws:iam::000000000000:policy/waterpark-estate-boundary"

  grants = [
    {
      resource   = "waterpark-site"
      access     = "write"
      granted_at = "2026-09-10T20:00:00Z"
      expires    = "2026-09-10T22:00:00Z"
      reason     = "A release broke the site."
    },
    {
      resource = "waterpark-artifacts"
      access   = "read"
      expires  = "2027-01-01T00:00:00Z"
      reason   = "A standing grant with an expiry is not break-glass."
    },
  ]
}
