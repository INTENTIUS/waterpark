# The trust anchor the apply job federates through. GitHub Actions mints a
# token per job, the provider below is what makes that token mean something
# in this account, and no static AWS key exists anywhere in the pipeline.
#
# water park declares trust anchors and never operates an issuer (decision
# 13). An OIDC provider is an account-scoped resource, so the anchor the
# waterpark-prod apply role trusts is declared in waterpark-prod beside the
# role rather than in access/identity, which targets waterpark-mgmt.
resource "aws_iam_openid_connect_provider" "actions" {
  url = "https://${var.actions_oidc_host}"

  # The audience the workflow asks for, and the only one this account honors.
  client_id_list = ["sts.amazonaws.com"]

  # The issuer's root CA thumbprint. AWS ignores it for the well-known
  # issuers now, and it is still required by the API, so it is named here
  # rather than computed at apply time.
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    owner = local.owner
    role  = "the trust anchor the apply job federates through"
  }
}
