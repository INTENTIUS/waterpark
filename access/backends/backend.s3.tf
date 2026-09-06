# The real backend. State lives in the waterpark-security account, in its own
# bucket, with locking, and it is never the system of record (decision 32).
#
# Copy this file into an env directory in place of backend.local.tf when you
# run the live path. access/scripts/backend does the swap.
terraform {
  backend "s3" {
    bucket       = "waterpark-terraform-state"
    key          = "access/envs/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
