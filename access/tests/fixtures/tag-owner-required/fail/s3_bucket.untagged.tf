# Fails tag-owner-required. An access review that finds this bucket has
# nobody to ask about it.
resource "aws_s3_bucket" "untagged" {
  bucket = "waterpark-untagged"
}
