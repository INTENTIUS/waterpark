resource "aws_s3_bucket" "tagged" {
  bucket = "waterpark-tagged"

  tags = {
    owner = "platform"
  }
}
