# The whole satellite leaf file. A persona, a boundary and a list of grants.
#
# Nobody from platform is involved in this file. The satellite creates the
# role that pushes to the registry it declares, and the boundary is what makes
# that safe (decision 20). The role can be given anything inside the estate
# boundary and nothing outside it, whatever this file says, because effective
# permissions are the intersection of the two.
#
# The module source. In this repo the satellite is a sibling root under
# access/ (decision 49), so the source is the local path and every command in
# the lesson works from a fresh clone with no network. A satellite in its own
# repository consumes the same module as a git source pinned to a tag
# (decision 50), which is
#
#   source = "git::https://github.com/INTENTIUS/waterpark.git//access/modules/persona?ref=checkpoint/i8"
#
# and access/scripts/satellite-source swaps between the two. The local path is
# committed because a checkout has to be green on its own and the tag is cut
# after these commits land.
module "runner_builder" {
  source = "../../modules/persona"

  persona     = "service"
  name        = "runner-builder"
  description = "Builds the sandbox runner image and pushes it to the waterpark-runner registry."
  owner       = local.owner
  teams       = ["runner"]

  # The line the whole lesson turns on. Take it out and the rule pack refuses
  # the build, and the deploy credential is refused by IAM at apply, and
  # neither refusal knows about the other.
  permissions_boundary = data.aws_iam_policy.boundary.arn

  grants = [
    {
      resource = aws_ecr_repository.waterpark_runner.name
      access   = "push"
      reason   = "Publishes the runner image to the registry this root declares."
    },
    {
      resource = "waterpark-artifacts"
      access   = "write"
      reason   = "Publishes the build artifacts that go with the image."
    },
    {
      resource = "waterpark-artifacts"
      access   = "list"
      reason   = "Reads what it already published before pushing again."
    },
  ]
}
