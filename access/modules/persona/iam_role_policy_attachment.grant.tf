resource "aws_iam_role_policy_attachment" "grant" {
  for_each = local.is_workload ? local.grants : {}

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.grant[each.key].arn
}
