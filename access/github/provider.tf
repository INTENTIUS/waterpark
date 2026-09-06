# This root is live only, the same way access/identity is. There is no
# emulator for a code host, so the checks validate and lint this directory on
# every run and only a real token ever plans or applies it.
#
# The token is read from GITHUB_TOKEN by the provider itself and is never
# named in a variable here, because a variable is a thing a plan can print.
provider "github" {
  owner = var.owner_org
}
