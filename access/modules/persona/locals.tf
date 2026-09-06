locals {
  human_personas    = ["reader", "platform"]
  workload_personas = ["service", "deployer"]

  is_human    = contains(local.human_personas, var.persona)
  is_workload = contains(local.workload_personas, var.persona)

  # The grant vocabulary. A leaf file says a level, the module says the
  # actions, so widening read everywhere is one edit here rather than a sweep
  # through the leaves.
  actions = {
    read  = ["s3:GetObject", "s3:GetObjectVersion", "s3:GetBucketLocation"]
    list  = ["s3:ListBucket", "s3:ListBucketVersions"]
    write = ["s3:PutObject", "s3:DeleteObject", "s3:AbortMultipartUpload"]
  }

  # A bucket level acts on the bucket, an object level acts on its contents.
  resource_arns = {
    read  = ["arn:aws:s3:::%s/*"]
    list  = ["arn:aws:s3:::%s"]
    write = ["arn:aws:s3:::%s/*"]
  }

  grants = { for g in var.grants : "${g.access}-${g.resource}" => g }

  tags = {
    owner   = var.owner
    persona = var.persona
    teams   = join(",", var.teams)
  }

  # The permission set a human persona gets. AWS managed for now, because the
  # human half is live only and lesson 11's access review reads it back from
  # the account rather than from here.
  human_managed_policy = {
    reader   = "arn:aws:iam::aws:policy/ReadOnlyAccess"
    platform = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  }

  # A trust with no anchor set, so the federated document below is always
  # evaluable and the choice between the two is a choice between two finished
  # documents rather than between two half-built ones.
  trust = var.federated_trust == null ? {
    provider_arn = ""
    issuer_host  = ""
    audience     = ""
    subjects     = []
  } : var.federated_trust

  service_trust_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = var.trusted_services }
      Action    = "sts:AssumeRole"
    }]
  })

  federated_trust_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.trust.provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      # The condition keys are named after the issuer host, which is why the
      # host is a field here rather than sliced out of the provider ARN. The
      # ARN is not known until the provider is created, and a trust policy
      # that reads "known after apply" is a trust policy nobody reviewed.
      Condition = {
        StringEquals = {
          "${local.trust.issuer_host}:aud" = local.trust.audience
          "${local.trust.issuer_host}:sub" = local.trust.subjects
        }
      }
    }]
  })

  assume_role_policy = var.federated_trust == null ? local.service_trust_json : local.federated_trust_json
}
