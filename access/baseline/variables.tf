variable "boundary_name" {
  description = "The deterministic name of the estate boundary. Deterministic so every stack references it by name and nothing hardcodes an ARN."
  type        = string
  default     = "waterpark-estate-boundary"
}

variable "sandbox" {
  description = "Whether this environment is in the Sandbox OU. A sandbox carries no boundary at all, because sandboxes exist to be broken and the live session guide has the room break things there (decision 36). Set this true and the module emits no policy and hands back a null ARN."
  type        = bool
  default     = false
}

variable "owner" {
  description = "Who to ask about the baseline. The guardrail path is platform's by rule."
  type        = string
  default     = "platform"
}

variable "state_bucket" {
  description = "The Terraform state bucket in waterpark-security. On the guardrail path, so the boundary denies touching it."
  type        = string
  default     = "waterpark-terraform-state"
}

variable "apply_role_name" {
  description = "The role the apply job assumes. On the guardrail path, so the boundary denies touching it. water park must not be able to escalate water park (decision 12)."
  type        = string
  default     = "waterpark-apply"
}
