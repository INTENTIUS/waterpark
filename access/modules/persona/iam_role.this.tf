resource "aws_iam_role" "this" {
  count = local.is_workload ? 1 : 0

  name        = var.name
  description = var.description

  # Every role water park emits carries the boundary, applied here so a leaf
  # file never restates it. The lint rule and the cloud enforce the same
  # thing, deliberately twice.
  permissions_boundary = var.permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = var.trusted_services }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}
