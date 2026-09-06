# Fails no-iam-user-or-group. Humans get an Identity Center permission set
# and workloads get a role. An IAM user is a long-lived key waiting to leak,
# and a satellite that could mint one would be minting a human (decision 5).
resource "aws_iam_user" "contractor" {
  name = "contractor"
}
