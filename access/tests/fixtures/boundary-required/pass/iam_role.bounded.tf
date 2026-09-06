resource "aws_iam_role" "bounded" {
  name                 = "bounded"
  assume_role_policy   = "{}"
  permissions_boundary = "arn:aws:iam::000000000000:policy/waterpark-estate-boundary"

  tags = {
    owner = "platform"
  }
}
