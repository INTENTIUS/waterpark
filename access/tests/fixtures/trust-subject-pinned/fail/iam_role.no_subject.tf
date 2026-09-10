# Fails trust-subject-pinned. The audience is pinned and the subject is not
# mentioned, so any token the issuer mints for this account can become the
# role. This is a trust in the issuer rather than in a workload.
resource "aws_iam_role" "no_subject" {
  name                 = "no-subject"
  permissions_boundary = "arn:aws:iam::000000000000:policy/waterpark-estate-boundary"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = "arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com" }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
      }
    }]
  })

  tags = {
    owner = "platform"
  }
}
