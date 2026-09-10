variable "persona" {
  description = "Which archetype this principal instantiates. The set is four and it is closed (decision 41). reader and platform are human and compile to a permission set. service and deployer are workloads and compile to a role."
  type        = string

  validation {
    condition     = contains(["reader", "platform", "service", "deployer"], var.persona)
    error_message = "persona must be one of reader, platform, service, deployer. The set is closed (decision 41), so adding one is a module release rather than a leaf-file edit."
  }

  validation {
    condition     = var.identity_center || !contains(["reader", "platform"], var.persona)
    error_message = "The reader and platform personas compile to an Identity Center permission set, and Floci does not run Identity Center. Human principals live under access/identity/ and are live only (prescription 3). Set identity_center to true only in a root that talks to a real account."
  }
}

variable "name" {
  description = "The principal's name, exactly as the estate spells it."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,62}$", var.name))
    error_message = "name is lower case letters, digits and hyphens, as the estate spells it."
  }
}

variable "description" {
  description = "What this principal is for, in one sentence. Property III, the why lives where it is enforced."
  type        = string
}

variable "owner" {
  description = "Who to ask about this principal. Becomes the owner tag every guardrail requires."
  type        = string
  default     = "platform"
}

variable "teams" {
  description = "Team scoping. Teams are module parameters rather than personas of their own (decision 41)."
  type        = list(string)
  default     = []
}

variable "grants" {
  description = "Typed access statements. access is a level rather than a list of actions, and the module expands it. expires is an RFC3339 date the cloud enforces, and an expired grant is drift. reason sits beside the expiry so a reviewer can read why."
  type = list(object({
    resource = string
    access   = string
    expires  = optional(string)
    reason   = optional(string)
  }))
  default = []

  validation {
    condition     = alltrue([for g in var.grants : contains(["read", "list", "write", "push"], g.access)])
    error_message = "Every grant's access is one of read, list, write, push. The module expands the level to actions."
  }

  validation {
    condition     = alltrue([for g in var.grants : g.expires == null || can(formatdate("YYYY-MM-DD", g.expires))])
    error_message = "A grant's expires is an RFC3339 timestamp, for example 2027-01-01T00:00:00Z."
  }

  validation {
    condition     = length(distinct([for g in var.grants : "${g.access}-${g.resource}"])) == length(var.grants)
    error_message = "Two grants name the same access level on the same resource. Say it once."
  }
}

variable "permissions_boundary" {
  description = "The estate boundary from access/baseline. Every workload role the module makes sits inside it, so the boundary is applied here rather than restated per grant. Null only in a sandbox, which carries no boundary at all (decision 36)."
  type        = string
  default     = null
}

variable "trusted_services" {
  description = "The AWS services allowed to assume a workload role, when the role is not federated. A workload that runs outside AWS names federated_trust instead (lesson 9)."
  type        = list(string)
  default     = ["codebuild.amazonaws.com"]
}

variable "identity_center" {
  description = "Whether this root can reach Identity Center. Floci cannot run it, so the human personas are live only (prescription 3) and the solo path leaves this false."
  type        = bool
  default     = false
}

variable "accounts" {
  description = "The account ids a human persona is assigned into. Empty on the solo path."
  type        = list(string)
  default     = []
}

variable "principal_id" {
  description = "The Identity Store id the permission set is assigned to, for a human persona."
  type        = string
  default     = ""
}

variable "principal_type" {
  description = "GROUP or USER, for a human persona's assignment."
  type        = string
  default     = "GROUP"

  validation {
    condition     = contains(["GROUP", "USER"], var.principal_type)
    error_message = "principal_type is GROUP or USER."
  }
}

variable "federated_trust" {
  description = "An OIDC trust anchor for a workload role, in place of the service principals in trusted_services. provider_arn is an aws_iam_openid_connect_provider, issuer_host is that provider's host and is what the aud and sub condition keys are named after, audience is the aud claim the issuer mints, and subjects are the exact sub claims allowed. A trust anchor is estate and the issuer is never operated (decision 13), so a subject is spelled out rather than matched."
  type = object({
    provider_arn = string
    issuer_host  = string
    audience     = string
    subjects     = list(string)
  })
  default = null

  validation {
    condition     = var.federated_trust == null || alltrue([for s in try(var.federated_trust.subjects, []) : !strcontains(s, "*")])
    error_message = "A federated trust subject carries no wildcard. Name the branch or the environment in full, because a wildcard sub claim trusts every repository the issuer serves (prescription 12)."
  }

  validation {
    condition     = var.federated_trust == null || length(try(var.federated_trust.subjects, [])) > 0
    error_message = "A federated trust names at least one subject. A trust with no subject condition trusts the issuer rather than a workload."
  }

  validation {
    condition     = var.federated_trust == null || try(var.federated_trust.audience, "") != ""
    error_message = "A federated trust pins an audience. Without one a token the issuer minted for another consumer can be replayed here (prescription 12)."
  }

  validation {
    condition     = var.federated_trust == null || can(regex("^[a-z0-9.-]+(/[A-Za-z0-9._~-]+)*$", try(var.federated_trust.issuer_host, "")))
    error_message = "issuer_host is the issuer's host and path with no scheme and no wildcard, for example token.actions.githubusercontent.com, because it is the prefix of the aud and sub condition keys."
  }
}
