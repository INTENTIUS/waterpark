# Fails no-wildcard-action. s3:* grants whatever S3 adds next year, and
# nobody reviewing this diff can say what that is.
resource "aws_iam_policy" "wildcard" {
  name = "wildcard"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:*"]
      Resource = ["arn:aws:s3:::waterpark-artifacts/*"]
    }]
  })

  tags = {
    owner = "platform"
  }
}
