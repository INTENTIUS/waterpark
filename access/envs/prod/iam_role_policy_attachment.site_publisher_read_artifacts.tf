resource "aws_iam_role_policy_attachment" "site_publisher_read_artifacts" {
  role       = aws_iam_role.site_publisher.name
  policy_arn = aws_iam_policy.site_publisher_read_artifacts.arn
}
