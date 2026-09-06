resource "aws_iam_policy" "site_publisher_read_artifacts" {
  name        = "site-publisher-read-artifacts"
  description = "Read on waterpark-artifacts for site-publisher, so a build can pick up the checkpoint bundle."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketLocation",
        "s3:ListBucket",
      ]
      Resource = [
        aws_s3_bucket.waterpark_artifacts.arn,
        "${aws_s3_bucket.waterpark_artifacts.arn}/*",
      ]
    }]
  })

  tags = {
    owner = local.owner
  }
}
