variable "region" {
  description = "The region Identity Center is delegated in."
  type        = string
  default     = "us-east-1"
}

variable "accounts" {
  description = "The account ids the human personas are assigned into. Empty until a live session fills it in."
  type        = list(string)
  default     = []
}

variable "platform_group_id" {
  description = "The Identity Store group id for platform."
  type        = string
  default     = ""
}

variable "course_author_group_id" {
  description = "The Identity Store group id for course authors."
  type        = string
  default     = ""
}
