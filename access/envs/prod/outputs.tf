output "roles" {
  description = "The workload roles this environment declares, by principal name."
  value = {
    site-publisher = aws_iam_role.site_publisher.arn
  }
}
