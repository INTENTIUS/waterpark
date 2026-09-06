module "platform" {
  source = "../modules/persona"

  persona     = "platform"
  name        = "platform"
  description = "Owns the repo and the guardrails, and the security reviewers in CODEOWNERS."

  identity_center = true
  accounts        = var.accounts
  principal_id    = var.platform_group_id
  principal_type  = "GROUP"
  teams           = ["platform"]
}
