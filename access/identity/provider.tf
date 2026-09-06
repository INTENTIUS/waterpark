# This root is live only. Identity Center lives in waterpark-mgmt and Floci
# does not run it, so there is no floci variable here and no endpoint
# override. The checks validate this directory on every run. Only a real
# account ever plans or applies it.
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      managed_by = "terraform"
      repo       = "INTENTIUS/waterpark"
      env        = "identity"
    }
  }
}
