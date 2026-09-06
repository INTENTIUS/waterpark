output "registry_url" {
  description = "Where the runner image is pushed."
  value       = aws_ecr_repository.waterpark_runner.repository_url
}

output "roles" {
  description = "The workload roles this satellite declares, by principal name."
  value = {
    (module.runner_builder.role_name) = module.runner_builder.role_arn
  }
}

output "grants" {
  description = "Every grant this satellite declares. The drift watch reads the expiry from here, the same way it does for envs/prod."
  value = {
    runner-builder = module.runner_builder.grants
  }
}

output "boundary_arn" {
  description = "The central boundary this satellite consumed, read live by name. A live read of the role should return exactly this."
  value       = data.aws_iam_policy.boundary.arn
}
