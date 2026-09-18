variable "name_prefix" {
  description = "Prefix used for the S3 bucket name"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix)) && length(var.name_prefix) <= 40
    error_message = "name_prefix must contain only lowercase letters, numbers, and hyphens and must not exceed 40 characters."
  }
}

variable "versioning_enabled" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "reader_arns" {
  description = "ARNs allowed to read from the S3 bucket"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to S3 resources"
  type        = map(string)
  default     = {}
}
