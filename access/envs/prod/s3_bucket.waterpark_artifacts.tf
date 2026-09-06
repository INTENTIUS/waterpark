resource "aws_s3_bucket" "waterpark_artifacts" {
  bucket = "waterpark-artifacts"

  tags = {
    owner = local.owner
    role  = "build artifacts and the lesson checkpoints"
  }
}
