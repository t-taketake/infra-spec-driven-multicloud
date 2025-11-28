variable "name" {
  description = "Name of the subnet"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "network_id" {
  description = "ID of the VPC network"
  type        = string
}

variable "ip_cidr_range" {
  description = "IP CIDR range for the subnet"
  type        = string
}

variable "region" {
  description = "Region for the subnet"
  type        = string
}

variable "private_ip_google_access" {
  description = "Enable Private Google Access"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_logs_aggregation_interval" {
  description = "Flow logs aggregation interval"
  type        = string
  default     = "INTERVAL_5_SEC"
}

variable "flow_logs_sampling" {
  description = "Flow logs sampling rate"
  type        = number
  default     = 0.5
}

variable "flow_logs_metadata" {
  description = "Flow logs metadata"
  type        = string
  default     = "INCLUDE_ALL_METADATA"
}
