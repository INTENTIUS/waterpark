# Fails boundary-required. A role with no boundary can be given anything a
# later policy edit says, and the boundary is what caps that.
resource "aws_iam_role" "unbounded" {
  name               = "unbounded"
  assume_role_policy = "{}"

  tags = {
    owner = "platform"
  }
}
