output "roles" {
  description = "The workload roles this environment declares, by principal name."
  value = {
    (module.site_publisher.role_name) = module.site_publisher.role_arn
    (module.runner_builder.role_name) = module.runner_builder.role_arn
    (module.desk_operator.role_name)  = module.desk_operator.role_arn
  }
}

output "grants" {
  description = "Every grant this environment declares, by principal. scripts/proofs reads the expiry from here."
  value = {
    site-publisher = module.site_publisher.grants
    runner-builder = module.runner_builder.grants
    desk-operator  = module.desk_operator.grants
  }
}
