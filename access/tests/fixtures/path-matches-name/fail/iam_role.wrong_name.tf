# Fails path-matches-name. The file says wrong_name and the resource says
# right_name, so the path no longer predicts the address.
resource "aws_iam_role" "right_name" {
  name               = "right-name"
  assume_role_policy = "{}"
}
