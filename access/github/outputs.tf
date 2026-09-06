output "protected_branch" {
  description = "The branch the apply job runs from, so a reader can compare it against the OIDC subject the apply role pins."
  value       = var.protected_branch
}

output "required_check" {
  description = "The status check a PR must pass. It is the PR job's name in .github/workflows/access.yml."
  value       = var.required_check
}
