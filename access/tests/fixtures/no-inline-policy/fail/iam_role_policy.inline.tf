# Fails no-inline-policy. An inline policy has no ARN, so nothing can
# reference it, diff it by name or reuse it.
resource "aws_iam_role_policy" "inline" {
  name = "inline"
  role = "some-role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = ["arn:aws:s3:::waterpark-artifacts/*"]
    }]
  })
}
