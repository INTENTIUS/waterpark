# The registry the sandbox runner image is pushed to. A satellite declares its
# own resources, which is the half of delegation nobody argues about.
resource "aws_ecr_repository" "waterpark_runner" {
  name = "waterpark-runner"

  # An image tag that can be moved is an artifact that cannot be trusted, and
  # every deploy this registry feeds is a deploy of whatever the tag points at
  # today.
  image_tag_mutability = "IMMUTABLE"

  tags = {
    owner = local.owner
    role  = "the registry the sandbox runner image is pushed to"
  }
}
