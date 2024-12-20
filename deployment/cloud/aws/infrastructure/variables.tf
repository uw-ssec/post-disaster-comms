variable "project_name" {
  description = "The name of the project -- used for tagging"
  type        = string
}

variable "neighborhood" {
  description = "The neighborhood of the project -- used for tagging"
  type        = string
}

variable "stage" {
  description = "Which stage this infrastructure's being deployed to - dev, beta, prod, etc."
  type        = string

  validation {
    condition     = can(regex("^(dev|beta|prod)$", var.stage))
    error_message = "Stage must be one of dev, beta, or prod"
  }
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "instance_type" {
  description = "The instance type to use for the server"
  type        = string
  default     = "t3.medium"
}

variable "volume_size" {
  description = "The instance type to use for the server"
  type        = string
  default     = 16
}

variable "ops_group_name" {
  description = "The name of the admin group"
  type        = string
  default     = "ssec-eng"
}

variable "github_organization" {
  description = "Organization that the GitHub repo belongs to"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo name that this project lives in"
  type        = string
}