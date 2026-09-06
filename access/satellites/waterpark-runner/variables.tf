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

variable "region" {
  description = "The region the registry lives in."
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "The environment this satellite deploys into."
  type        = string
  default     = "prod"
}

variable "credentials_from_env" {
  description = "Take the AWS credentials from the environment instead of the throwaway test pair. A satellite deploys as its own credential rather than as the account root, and access/scripts/double-refusal sets this so the IAM refusal is a refusal of the satellite. The solo path leaves it false."
  type        = bool
  default     = false
}

variable "boundary_name" {
  description = "The estate boundary, by name. The satellite reads it live rather than being handed an ARN, because the name is deterministic (decision 36) and an ARN in a satellite file is a copy that can go stale. If central has not applied the boundary yet, this root refuses to plan, which is the correct order."
  type        = string
  default     = "waterpark-estate-boundary"
}
