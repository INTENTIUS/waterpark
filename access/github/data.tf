# The repository is referenced, never declared. water park manages what it
# declares (decision 3), and it does not create its own repo.
data "github_repository" "this" {
  full_name = "${var.owner_org}/${var.repository}"
}
