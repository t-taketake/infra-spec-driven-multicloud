variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "auto_create_subnetworks" {
  description = "Auto create subnetworks"
  type        = bool
  default     = false
}

variable "routing_mode" {
  description = "Network routing mode (REGIONAL or GLOBAL)"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "routing_mode must be either 'REGIONAL' or 'GLOBAL'."
  }
}

variable "mtu" {
  description = "Maximum Transmission Unit in bytes"
  type        = number
  default     = 1460
  validation {
    condition     = var.mtu >= 1300 && var.mtu <= 8896
    error_message = "MTU must be between 1300 and 8896."
  }
}
