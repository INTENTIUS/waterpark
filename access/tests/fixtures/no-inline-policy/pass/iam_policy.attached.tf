resource "aws_iam_policy" "attached" {
  name = "attached"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = ["arn:aws:s3:::waterpark-artifacts/*"]
    }]
  })

  tags = {
    owner = "platform"
  }
}
