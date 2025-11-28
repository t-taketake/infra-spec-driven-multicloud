variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = null
}

variable "block_public_access" {
  description = "Block all public access"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  type = list(object({
    id              = string
    status          = string
    expiration_days = optional(number)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
  default = null
}

variable "tags" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
  default     = {}
}
