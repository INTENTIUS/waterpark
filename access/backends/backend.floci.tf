# State in the emulator's own S3, for the solo path.
#
# The local backend keeps state in the directory it was applied from, which is
# fine for one person at one keyboard and no good at all for a watcher. A
# scheduled run wakes on whatever computer it is given, and a computer with no
# state plans to create an estate that already exists. So the solo path gets
# the same shape the live path has, which is state in a bucket, and the bucket
# happens to be Floci's.
#
# The endpoint is not here, because a backend block takes no variables and the
# same file has to work from a laptop and from a sandbox. Terraform's S3
# backend reads AWS_ENDPOINT_URL_S3, so the environment says where Floci is
# and this file says nothing about it.
#
# Swap it in with access/scripts/backend floci envs/prod, then init.
terraform {
  backend "s3" {
    bucket = "waterpark-terraform-state"
    key    = "access/envs/prod/terraform.tfstate"
    region = "us-east-1"

    # The emulator is not an account, so none of the checks a real backend
    # runs against one can pass. The live backend leaves every one of these
    # alone, which is the difference between the two files.
    use_path_style              = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_lockfile                = true
  }
}
