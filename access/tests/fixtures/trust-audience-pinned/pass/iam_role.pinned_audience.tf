# Passes. Audience and subject both pinned with StringEquals.
resource "aws_iam_role" "pinned_audience" {
  name                 = "pinned-audience"
  permissions_boundary = "arn:aws:iam::000000000000:policy/waterpark-estate-boundary"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = "arn:aws:iam::000000000000:oidc-provider/token.actions.githubusercontent.com" }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:INTENTIUS/waterpark:ref:refs/heads/main"
        }
      }
    }]
  })

  tags = {
    owner = "platform"
  }
}
