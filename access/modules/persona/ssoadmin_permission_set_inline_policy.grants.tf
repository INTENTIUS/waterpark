# A human persona's grants, rendered as the permission set's inline policy.
# Live only, like everything Identity Center, so on the solo path this is
# validated and never planned. The human path of break-glass is a grant with
# a granted_at on a permission set (decision 37), and the standing account
# assignment is what makes it reachable. The condition is what makes it
# temporary.
resource "aws_ssoadmin_permission_set_inline_policy" "grants" {
  count = local.is_human && length(var.grants) > 0 ? 1 : 0

  instance_arn       = tolist(data.aws_ssoadmin_instances.this[0].arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this[0].arn

  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [for k, g in local.grants : {
      Effect   = "Allow"
      Action   = local.actions[g.access]
      Resource = [for pattern in local.resource_arns[g.access] : format(pattern, g.resource)]
      Condition = g.expires == null ? null : {
        DateLessThan = { "aws:CurrentTime" = g.expires }
      }
    }]
  })
}
