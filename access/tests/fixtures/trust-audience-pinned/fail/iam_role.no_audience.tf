# Fails trust-audience-pinned. The subject is exact and the audience is not
# mentioned, so a token the issuer minted for some other consumer, carrying
# this subject, can be replayed against this account.
resource "aws_iam_role" "no_audience" {
  name                 = "no-audience"
  permissions_boundary = "arn:aws:iam::000000000000:policy/waterpark-estate-boundary"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = "arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com" }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:sub" = "repo:INTENTIUS/waterpark:ref:refs/heads/main" }
      }
    }]
  })

  tags = {
    owner = "platform"
  }
}
