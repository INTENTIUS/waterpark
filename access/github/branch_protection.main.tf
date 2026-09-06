# Merge rights are grant rights (principle 6, threat-model boundary 1), so
# the rules that decide who can merge are estate and are declared here rather
# than clicked in a settings page (decision 19).
#
# Everything the PR job proves is worth nothing if a change can reach main
# without passing it. This resource is what closes that door, and the drift
# watch is what notices when someone opens it again.
resource "github_branch_protection" "main" {
  repository_id = data.github_repository.this.node_id
  pattern       = var.protected_branch

  # The PR job. Credential-free, and the only gate a fork PR can satisfy,
  # which is the point of prescription 6.
  required_status_checks {
    strict   = true
    contexts = [var.required_check]
  }

  required_pull_request_reviews {
    required_approving_review_count = var.required_approvals

    # CODEOWNERS decides whose approval counts, and CODEOWNERS is generated
    # from the principal files (decision 21). Without this line the routing is
    # documentation.
    require_code_owner_reviews = true

    # An approval on an old push is an approval of a diff nobody read.
    dismiss_stale_reviews = true
  }

  # A force push rewrites the audit trail, which is the one thing git gives
  # this pattern for free.
  allows_force_pushes = false
  allows_deletions    = false

  # Nobody is exempt, administrators included. An exemption is the whole
  # control with a name on it.
  enforce_admins = true
}
