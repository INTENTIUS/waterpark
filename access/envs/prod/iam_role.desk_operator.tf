module "desk_operator" {
  source = "../../modules/persona"

  persona     = "service"
  name        = "desk-operator"
  description = "The concierge in direct mode, bounded, and nothing in repo mode."
  owner       = local.owner
  teams       = ["platform"]

  grants = [
    {
      resource = "waterpark-artifacts"
      access   = "read"
      expires  = "2027-01-01T00:00:00Z"
      reason   = "Direct mode reads the estate. Expires so the desk's read has to be renewed deliberately."
    },
    {
      resource = "waterpark-artifacts"
      access   = "list"
      expires  = "2027-01-01T00:00:00Z"
      reason   = "Direct mode lists the estate. Same expiry as the read beside it."
    },
  ]
}
