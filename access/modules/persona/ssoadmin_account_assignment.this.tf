resource "aws_ssoadmin_account_assignment" "this" {
  for_each = local.is_human ? toset(var.accounts) : toset([])

  instance_arn       = tolist(data.aws_ssoadmin_instances.this[0].arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this[0].arn
  principal_id       = var.principal_id
  principal_type     = var.principal_type
  target_id          = each.value
  target_type        = "AWS_ACCOUNT"
}
