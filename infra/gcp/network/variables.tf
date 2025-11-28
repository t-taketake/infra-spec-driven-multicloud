variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "asia-northeast1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "service" {
  description = "Service name"
  type        = string
}

variable "subnet_a_cidr" {
  description = "Subnet A CIDR"
  type        = string
  default     = "10.1.1.0/24"
}

variable "subnet_b_cidr" {
  description = "Subnet B CIDR"
  type        = string
  default     = "10.1.2.0/24"
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs"
  type        = bool
  default     = false
}

variable "enable_nat_logging" {
  description = "Enable Cloud NAT logging"
  type        = bool
  default     = false
}
