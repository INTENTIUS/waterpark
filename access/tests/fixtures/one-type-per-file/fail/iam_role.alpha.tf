# Fails one-type-per-file. Two resource blocks in one file, so the diff of a
# change to beta names a file called alpha.
resource "aws_iam_role" "alpha" {
  name               = "alpha"
  assume_role_policy = "{}"
}

resource "aws_iam_role" "beta" {
  name               = "beta"
  assume_role_policy = "{}"
}
