# Passes, because the rule reads federated statements only. A role trusted by
# an AWS service principal has no subject to pin.
resource "aws_iam_role" "service_trust" {
  name                 = "service-trust"
  permissions_boundary = "arn:aws:iam::000000000000:policy/waterpark-estate-boundary"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    owner = "platform"
  }
}
