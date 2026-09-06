# The same two targets as envs/prod, plus ecr, because this root declares a
# registry. Floci implements ecr and the patched build applies an
# aws_ecr_repository and reads it back with its tags, so the registry is
# declared here rather than deferred (which is what decision 48 left open).
provider "aws" {
  region = var.region

  # The throwaway pair on the solo path, so a fresh clone plans with no
  # credential of any kind. A satellite in the world deploys as its own
  # credential rather than as the account root, and credentials_from_env is
  # how this root is pointed at one. access/scripts/double-refusal uses it,
  # because a refusal is only a refusal if the caller is the satellite.
  access_key = var.floci && !var.credentials_from_env ? "test" : null
  secret_key = var.floci && !var.credentials_from_env ? "test" : null

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
      ecr = endpoints.value
    }
  }

  # A satellite marks what it creates, so central reconcile can see that a
  # resource is foreign and leave it to the repo that owns it.
  default_tags {
    tags = {
      managed_by = "terraform"
      repo       = "INTENTIUS/waterpark"
      env        = var.env
      satellite  = "waterpark-runner"
    }
  }
}
