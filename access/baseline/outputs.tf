output "boundary_arn" {
  description = "The estate boundary, for every role the persona module makes. Null in a sandbox, which carries no boundary at all (decision 36)."
  value       = var.sandbox ? null : aws_iam_policy.boundary[0].arn
}

output "boundary_name" {
  description = "The deterministic boundary name, so another stack can reference it without a hardcoded ARN."
  value       = var.boundary_name
}

output "forbidden_actions" {
  description = "What the boundary denies. The lesson 6 proof checks read this list rather than re-stating it."
  value       = local.forbidden_actions
}

output "break_glass_max_ttl_hours" {
  description = "The longest a break-glass grant may last. Two hours, enforced cloud-side by an aws:CurrentTime condition (decision 37)."
  value       = local.break_glass_max_ttl_hours
}

output "watcher_max_open_prs" {
  description = "How many open PRs the watcher may hold at once. Five, counted by the PR job so the cap holds when the prompt is ignored (decision 40)."
  value       = local.watcher_max_open_prs
}

output "static_secret_max_age_days" {
  description = "The longest a static secret may stand before scripts/rotation flags it. Ninety days, on the watch's weekday schedule (decision 39)."
  value       = local.static_secret_max_age_days
}
