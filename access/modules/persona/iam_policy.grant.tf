resource "aws_iam_policy" "grant" {
  for_each = local.is_workload ? local.grants : {}

  name        = "${var.name}-${each.key}"
  description = coalesce(each.value.reason, "${each.value.access} on ${each.value.resource} for ${var.name}")

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([{
      Effect   = "Allow"
      Action   = local.actions[each.value.access]
      Resource = [for pattern in local.resource_arns[each.value.access] : format(pattern, each.value.resource)]

      # An expiry is a condition the cloud enforces, not a job that has to
      # run. The tag below carries the same date so a read of the estate can
      # see it without parsing the policy.
      Condition = each.value.expires == null ? null : {
        DateLessThan = { "aws:CurrentTime" = each.value.expires }
      }
      }],

      # The one or two actions a service refuses to scope to a resource, when
      # the level needs them. Empty for every level that does not, so the
      # policy is byte for byte the one statement it always was.
      [for action_set in [lookup(local.account_wide_actions, each.value.access, [])] : {
        Effect   = "Allow"
        Action   = action_set
        Resource = "*"
        Condition = each.value.expires == null ? null : {
          DateLessThan = { "aws:CurrentTime" = each.value.expires }
        }
      } if length(action_set) > 0]
    )
  })

  tags = merge(local.tags, {
    expires = coalesce(each.value.expires, "never")
    reason  = coalesce(each.value.reason, "not stated")
    }, each.value.granted_at == null ? {} : {
    # A break-glass grant says when it was granted and who approved it, on
    # the artifact, so the audit trail is readable from the account alone.
    # The apply job stamps approved_by after the apply, because the reviewer
    # is not known when the plan is made and the plan is what was approved.
    break_glass = "true"
    granted_at  = each.value.granted_at
    approved_by = var.break_glass_approver
  })

  lifecycle {
    # The apply job writes approved_by from the merged pull request's review,
    # after the apply, so the next plan must not put it back to unapproved.
    ignore_changes = [tags["approved_by"]]
  }
}
