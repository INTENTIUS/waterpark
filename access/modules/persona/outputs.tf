output "kind" {
  description = "human or workload, decided by the persona."
  value       = local.is_human ? "human" : "workload"
}

output "role_arn" {
  description = "The role a workload persona compiles to. Null for a human persona."
  value       = local.is_workload ? aws_iam_role.this[0].arn : null
}

output "role_name" {
  description = "The role name a workload persona compiles to. Null for a human persona."
  value       = local.is_workload ? aws_iam_role.this[0].name : null
}

output "permission_set_arn" {
  description = "The permission set a human persona compiles to. Null for a workload persona."
  value       = local.is_human ? aws_ssoadmin_permission_set.this[0].arn : null
}

output "grants" {
  description = "The rendered grants, by access level and resource, with the policy ARN and the expiry that scripts/proofs reads."
  value = {
    for k, g in local.grants : k => {
      resource   = g.resource
      access     = g.access
      expires    = g.expires
      reason     = g.reason
      policy_arn = local.is_workload ? aws_iam_policy.grant[k].arn : null
    }
  }
}
