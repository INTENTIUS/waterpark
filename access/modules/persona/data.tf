# Identity Center is live only. Floci does not run it, so this data source is
# read in the access/identity/ root and nowhere on the solo path.
data "aws_ssoadmin_instances" "this" {
  count = local.is_human ? 1 : 0
}
