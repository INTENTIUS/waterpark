# runner-builder is not here. It moved to access/satellites/waterpark-runner
# in lesson 8, because the satellite declares the registry and the role that
# pushes to it (estate.md scenario 5). Central keeps the boundary, the
# personas and the guardrails, and it does not keep a satellite's workload.
output "roles" {
  description = "The workload roles this environment declares, by principal name."
  value = {
    (module.site_publisher.role_name)  = module.site_publisher.role_arn
    (module.desk_operator.role_name)   = module.desk_operator.role_arn
    (module.waterpark_apply.role_name) = module.waterpark_apply.role_arn
    (module.on_call.role_name)         = module.on_call.role_arn
  }
}

output "grants" {
  description = "Every grant this environment declares, by principal. scripts/proofs reads the expiry from here."
  value = {
    site-publisher  = module.site_publisher.grants
    desk-operator   = module.desk_operator.grants
    waterpark-apply = module.waterpark_apply.grants
    on-call         = module.on_call.grants
  }
}

output "boundary_arn" {
  description = "The estate boundary this environment applied. A satellite reads the boundary by name rather than from here, and this output is what a live read compares against."
  value       = module.baseline.boundary_arn
}

output "apply_role_arn" {
  description = "The role the apply job federates into. scripts/prove-no-detach names it."
  value       = module.waterpark_apply.role_arn
}

output "watcher_max_open_prs" {
  description = "How many reconcile PRs may stand open at once, passed through from baseline so scripts/reconcile reads the constant rather than restating it (decision 40)."
  value       = module.baseline.watcher_max_open_prs
}

output "break_glass_max_ttl_hours" {
  description = "The longest a break-glass grant may last, passed through from baseline (decision 37)."
  value       = module.baseline.break_glass_max_ttl_hours
}

output "static_secret_max_age_days" {
  description = "The rotation window, passed through from baseline so scripts/rotation reads the constant rather than restating it (decision 39)."
  value       = module.baseline.static_secret_max_age_days
}
