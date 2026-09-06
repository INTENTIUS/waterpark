variable "owner_org" {
  description = "The GitHub organization the repository lives in."
  type        = string
  default     = "INTENTIUS"
}

variable "repository" {
  description = "The repository whose protection is declared here. The access repo is this repo (decision 33), so there is one."
  type        = string
  default     = "waterpark"
}

variable "protected_branch" {
  description = "The branch the apply job is allowed to run from. It is the same string the apply role's OIDC subject pins, and if the two ever disagree the write path has two doors."
  type        = string
  default     = "main"
}

variable "required_check" {
  description = "The status check a PR must pass before it can merge. It is the name of the PR job in .github/workflows/access.yml."
  type        = string
  default     = "pr"
}

variable "required_approvals" {
  description = "How many approving reviews a PR needs. One, and CODEOWNERS decides whose."
  type        = number
  default     = 1
}
