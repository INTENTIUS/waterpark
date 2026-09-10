# Fails trust-audience-pinned. An anchor with an empty client id list honors
# no audience, so the aud condition on every role that trusts it has nothing
# to match against.
resource "aws_iam_openid_connect_provider" "no_audience" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = []
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    owner = "platform"
  }
}
