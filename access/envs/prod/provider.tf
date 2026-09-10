# One provider, two targets. With floci true the provider talks to a local
# emulator on port 4566 and never resolves a real account, so the whole solo
# path runs with no credentials. With floci false the same code talks to the
# real waterpark-prod account and the skips all fall away.
provider "aws" {
  region = var.region

  access_key = var.floci ? "test" : null
  secret_key = var.floci ? "test" : null

  skip_credentials_validation = var.floci
  skip_requesting_account_id  = var.floci
  skip_metadata_api_check     = var.floci
  s3_use_path_style           = var.floci

  dynamic "endpoints" {
    for_each = var.floci ? [var.floci_endpoint] : []

    content {
      iam = endpoints.value
      sts = endpoints.value
      s3  = endpoints.value
      ec2 = endpoints.value
    }
  }

  default_tags {
    tags = {
      managed_by = "terraform"
      repo       = "INTENTIUS/waterpark"
      env        = var.env
    }
  }
}
