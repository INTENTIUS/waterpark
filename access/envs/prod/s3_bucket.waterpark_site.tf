resource "aws_s3_bucket" "waterpark_site" {
  bucket = "waterpark-site"

  tags = {
    owner = local.owner
    role  = "the bucket the published site is served from"
  }
}
