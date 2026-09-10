# Fails break-glass-ttl. Six hours is three times the baseline TTL, and a
# grant that outlives the incident is standing access with a date on it.
module "long_incident" {
  source = "../../../../modules/persona"

  persona     = "service"
  name        = "long-incident"
  description = "A break-glass grant that lasts too long."
  teams       = ["platform"]

  permissions_boundary = "arn:aws:iam::000000000000:policy/waterpark-estate-boundary"

  grants = [
    {
      resource   = "waterpark-site"
      access     = "write"
      granted_at = "2026-09-10T20:00:00Z"
      expires    = "2026-09-11T02:00:00Z"
      reason     = "A release broke the site."
    },
  ]
}
