# Fails trust-subject-pinned twice over. StringLike is a pattern, and the
# pattern carries a star, so every branch of every repository under
# INTENTIUS can become this role.
resource "aws_iam_role" "wildcard_subject" {
  name                 = "wildcard-subject"
  permissions_boundary = "arn:aws:iam::000000000000:policy/waterpark-estate-boundary"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = "arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com" }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
        StringLike   = { "token.actions.githubusercontent.com:sub" = "repo:INTENTIUS/*" }
      }
    }]
  })

  tags = {
    owner = "platform"
  }
}
