resource "aws_iam_role_policy_attachment" "attached" {
  role       = "some-role"
  policy_arn = aws_iam_policy.attached.arn
}
