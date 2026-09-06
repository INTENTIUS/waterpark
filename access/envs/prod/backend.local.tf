# The solo path keeps state in this directory, so a fresh clone can run
# terraform init with no AWS account and no credentials.
#
# The live path replaces this file with access/backends/backend.s3.tf, which
# puts state in the waterpark-security account with locking. Swap it with
# access/scripts/backend. See access/README.md, "State and the two backends".
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
