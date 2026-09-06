resource "aws_iam_policy" "grant" {
  for_each = local.is_workload ? local.grants : {}

  name        = "${var.name}-${each.key}"
  description = coalesce(each.value.reason, "${each.value.access} on ${each.value.resource} for ${var.name}")

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = local.actions[each.value.access]
      Resource = [for pattern in local.resource_arns[each.value.access] : format(pattern, each.value.resource)]

      # An expiry is a condition the cloud enforces, not a job that has to
      # run. The tag below carries the same date so a read of the estate can
      # see it without parsing the policy.
      Condition = each.value.expires == null ? null : {
        DateLessThan = { "aws:CurrentTime" = each.value.expires }
      }
    }]
  })

  tags = merge(local.tags, {
    expires = coalesce(each.value.expires, "never")
    reason  = coalesce(each.value.reason, "not stated")
  })
}
