# Fails break-glass-ttl twice. No expiry, so nothing ends it, and no reason,
# so nothing explains it.
module "open_ended" {
  source = "../../../../modules/persona"

  persona     = "service"
  name        = "open-ended"
  description = "A break-glass grant with no end and no reason."
  teams       = ["platform"]

  permissions_boundary = "arn:aws:iam::000000000000:policy/waterpark-estate-boundary"

  grants = [
    {
      resource   = "waterpark-site"
      access     = "write"
      granted_at = "2026-09-10T20:00:00Z"
    },
  ]
}
