variable "floci" {
  description = "Point the AWS provider at a local Floci emulator instead of a real account. The solo path leaves this true. The live path passes -var floci=false."
  type        = bool
  default     = true
}

variable "floci_endpoint" {
  description = "Where Floci answers. Used only when floci is true."
  type        = string
  default     = "http://localhost:4566"
}

variable "actions_oidc_host" {
  description = "The GitHub Actions OIDC issuer host. It is the provider's URL and the prefix of the aud and sub condition keys, so it is one string here rather than three spellings across the estate."
  type        = string
  default     = "token.actions.githubusercontent.com"
}

variable "region" {
  description = "The region the estate lives in."
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "The environment this directory declares. One of prod or dev."
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["prod", "dev"], var.env)
    error_message = "env must be prod or dev. Each env is one directory under access/envs."
  }
}

variable "break_glass_approver" {
  description = "Who approved the break-glass grants in this apply. The apply job passes the reviewer of the merged pull request (decision 37). The solo path leaves the default, and the tag on the grant says unapproved."
  type        = string
  default     = "unapproved"
}
