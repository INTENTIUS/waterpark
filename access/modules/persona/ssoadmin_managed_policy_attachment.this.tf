resource "aws_ssoadmin_managed_policy_attachment" "this" {
  count = local.is_human ? 1 : 0

  instance_arn       = tolist(data.aws_ssoadmin_instances.this[0].arns)[0]
  managed_policy_arn = local.human_managed_policy[var.persona]
  permission_set_arn = aws_ssoadmin_permission_set.this[0].arn
}
