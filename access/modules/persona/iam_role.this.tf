resource "aws_iam_role" "this" {
  count = local.is_workload ? 1 : 0

  name        = var.name
  description = var.description

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
