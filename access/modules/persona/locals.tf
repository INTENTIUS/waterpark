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
}
