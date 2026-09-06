resource "aws_iam_role" "site_publisher" {
  name        = "site-publisher"
  description = "Builds the site and writes it to the site bucket."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    owner   = local.owner
    persona = "service"
  }
}
