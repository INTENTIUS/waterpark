# The provider prefix left on. The rule wants branch_protection.main.tf,
# because a reader predicting a path from a resource address drops the
# provider the same way for every provider.
resource "github_branch_protection" "main" {
  repository_id = "waterpark"
  pattern       = "main"
}
