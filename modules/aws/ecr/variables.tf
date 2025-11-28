variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type (AES256 or KMS)"
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be either 'AES256' or 'KMS'."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (required if encryption_type is KMS)"
  type        = string
  default     = null
}

variable "lifecycle_policy" {
  description = "Lifecycle policy JSON"
  type        = string
  default     = null
}

variable "repository_policy" {
  description = "Repository policy JSON"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the ECR repository"
  type        = map(string)
  default     = {}
}
