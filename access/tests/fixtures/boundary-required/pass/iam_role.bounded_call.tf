# The same principal file with the one line that makes delegation safe. The
# ARN is a literal here because a fixture is never applied; a real leaf file
# names module.baseline.boundary_arn, or the central ARN a satellite reads.
module "bounded_call" {
  source = "../../../../modules/persona"

  persona     = "service"
  name        = "bounded-call"
  description = "A workload role declared inside the estate boundary."
  teams       = ["platform"]

  permissions_boundary = "arn:aws:iam::000000000000:policy/waterpark-estate-boundary"
}
