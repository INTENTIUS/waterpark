# Passes. The issuer, the audience and the exact subject, one repository on
# one branch, all pinned with StringEquals. A SPIFFE subject or a Kubernetes
# service account is the same shape with a different string.
resource "aws_iam_role" "pinned_subject" {
  name                 = "pinned-subject"
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
