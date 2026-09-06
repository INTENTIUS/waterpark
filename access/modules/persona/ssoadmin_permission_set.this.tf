resource "aws_ssoadmin_permission_set" "this" {
  count = local.is_human ? 1 : 0

  name             = var.name
  description      = var.description
  instance_arn     = tolist(data.aws_ssoadmin_instances.this[0].arns)[0]
  session_duration = "PT4H"

  tags = local.tags
}
