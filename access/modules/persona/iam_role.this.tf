resource "aws_iam_role" "this" {
  count = local.is_workload ? 1 : 0

  name        = var.name
  description = var.description

  # Every role water park emits carries the boundary, applied here so a leaf
  # file never restates it. The lint rule and the cloud enforce the same
  # thing, deliberately twice.
  permissions_boundary = var.permissions_boundary

  # Two trust shapes, one role. A workload inside AWS is trusted by service
  # principal. A workload outside AWS, which is the CI job in lesson 6, is
  # trusted by a declared OIDC provider with the audience and the exact
  # subject pinned. The trust anchor is estate, the issuer is never operated
  # (decision 13).
  assume_role_policy = local.assume_role_policy

  tags = local.tags
}
