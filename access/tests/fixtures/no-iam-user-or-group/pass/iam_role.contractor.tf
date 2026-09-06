resource "aws_iam_role" "contractor" {
  name               = "contractor"
  assume_role_policy = "{}"

  tags = {
    owner = "platform"
  }
}
