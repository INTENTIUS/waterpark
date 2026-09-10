locals {
  # The constants later lessons read from here rather than from a page.
  #
  # Break-glass carries a cloud-side expiry and the maximum is two hours, and
  # a check refuses a longer one (decision 37). The watcher holds at most five
  # open PRs, and the PR job counts them so the cap holds when the prompt is
  # ignored (decision 40). Both live here so a student can change one number
  # in one place and watch the checks move with it.
  break_glass_max_ttl_hours = 2
  watcher_max_open_prs      = 5

  # The longest a static secret may stand before the rotation check flags
  # it. Credentials are short-lived everywhere in this estate, so this
  # number governs the few that cannot be, and the check runs on the watch's
  # schedule (decision 39).
  static_secret_max_age_days = 90

  # Everything the boundary denies, as one list the I6 proof checks consume.
  # These are the actions no role inside the estate may hold, whatever its
  # own policy says.
  forbidden_actions = [
    # All IAM write. Permissions management goes through the repo, so an
    # identity inside the estate never edits an identity.
    "iam:Add*",
    "iam:Attach*",
    "iam:Create*",
    "iam:Delete*",
    "iam:Detach*",
    "iam:Put*",
    "iam:Remove*",
    "iam:Set*",
    "iam:Tag*",
    "iam:Untag*",
    "iam:Update*",
    "iam:Upload*",

    # The org layer. Accounts are vended elsewhere and policies are the
    # management account's (decision 11).
    "organizations:*",

    # Identity Center and the identity store behind it. Human access is
    # central without exception, because a permission set's blast radius is
    # every account it is assigned into.
    "sso:*",
    "sso-directory:*",
    "identitystore:*",
  ]

  # Detaching the cap is the one move that would make every other deny
  # pointless, so it gets its own statement rather than hiding in the list.
  boundary_detachment_actions = [
    "iam:DeleteRolePermissionsBoundary",
    "iam:DeleteUserPermissionsBoundary",
    "iam:PutRolePermissionsBoundary",
    "iam:PutUserPermissionsBoundary",
  ]

  # The service surface an app team plausibly needs. A boundary is a ceiling
  # rather than a grant, so these are the services a role may be given access
  # to by its own policy, not access it holds.
  service_surface = [
    "s3:*",
    "logs:*",
    "cloudwatch:*",
    "ecr:*",
    "sqs:*",
    "sns:*",
    "dynamodb:*",
    "ssm:GetParameter",
    "ssm:GetParameters",
    "ssm:GetParametersByPath",
    "secretsmanager:GetSecretValue",
    "secretsmanager:DescribeSecret",
    "kms:Decrypt",
    "kms:Encrypt",
    "kms:GenerateDataKey",
    "sts:AssumeRole",
    "sts:GetCallerIdentity",
    "sts:TagSession",
  ]

  # The guardrail path, by name. The boundary policy itself, the state bucket
  # and the apply role. Nothing inside the estate touches the things that
  # decide what the estate may be.
  guardrail_resources = [
    "arn:aws:iam::*:policy/${var.boundary_name}",
    "arn:aws:iam::*:role/${var.apply_role_name}",
    "arn:aws:s3:::${var.state_bucket}",
    "arn:aws:s3:::${var.state_bucket}/*",
  ]
}
