# One boundary for the whole estate (decision 36). A boundary caps what an
# identity-based policy can grant, because effective permissions are the
# intersection of the two, so this file is the ceiling every workload role in
# the estate sits under. Splitting it per OU waits until an OU needs it.
#
# The description below is on the policy in the account, so the why travels
# with the artifact rather than staying in the repo. Property III.
resource "aws_iam_policy" "boundary" {
  count = var.sandbox ? 0 : 1

  name        = var.boundary_name
  description = "The estate boundary. Every role water park emits sits inside it. It denies all IAM write, Organizations, Identity Center, the guardrail-path resources by name and boundary detachment, and it allows the service surface an app team plausibly needs. Changing it is a platform PR (decision 36)."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # The ceiling. A role inside the estate may be granted access to
        # these services by its own policy and to nothing else.
        Sid      = "ServiceSurface"
        Effect   = "Allow"
        Action   = local.service_surface
        Resource = "*"
      },
      {
        # Permissions management always goes through the repo, so no identity
        # inside the estate edits an identity, its own included. This is the
        # deny that makes delegation safe, because a satellite that creates a
        # role inside this boundary cannot make it more powerful than this.
        Sid      = "NoIdentityWrite"
        Effect   = "Deny"
        Action   = local.forbidden_actions
        Resource = "*"
      },
      {
        # Detaching the cap would make every other deny pointless, so it is
        # denied on its own. The apply role carries this same boundary, which
        # is how water park cannot escalate water park (decision 12).
        Sid      = "NoBoundaryDetachment"
        Effect   = "Deny"
        Action   = local.boundary_detachment_actions
        Resource = "*"
      },
      {
        # The guardrail path by name. The boundary policy itself, the apply
        # role and the state bucket. These decide what the estate may be, so
        # nothing inside the estate touches them.
        Sid      = "NoGuardrailPath"
        Effect   = "Deny"
        Action   = "*"
        Resource = local.guardrail_resources
      },
    ]
  })

  tags = {
    owner = var.owner

    # The rule pack skips a boundary on no-wildcard-action, because a
    # boundary is a ceiling rather than a grant and a wildcard here narrows
    # nothing. This tag is what marks it.
    guardrail = "boundary"
  }
}
