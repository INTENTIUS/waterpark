# Passes no-wildcard-action even though it carries s3:*, because the
# guardrail = "boundary" tag marks it a ceiling rather than a grant. A
# wildcard in a boundary narrows the estate instead of widening it.
resource "aws_iam_policy" "boundary" {
  name = "example-boundary"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:*"]
      Resource = "*"
    }]
  })

  tags = {
    owner     = "platform"
    guardrail = "boundary"
  }
}
