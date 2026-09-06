# The provider prefix is dropped, whichever provider it is. A
# github_branch_protection lives in branch_protection.<label>.tf, the same
# way an aws_iam_role lives in iam_role.<label>.tf.
resource "github_branch_protection" "main" {
  repository_id = "waterpark"
  pattern       = "main"
}
