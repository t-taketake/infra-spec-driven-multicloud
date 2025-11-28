variable "name" {
  description = "Name of the Cloud NAT"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for the Cloud NAT"
  type        = string
}

variable "router_name" {
  description = "Name of the Cloud Router"
  type        = string
}

variable "nat_ip_allocate_option" {
  description = "NAT IP allocation option"
  type        = string
  default     = "AUTO_ONLY"
}

variable "source_subnetwork_ip_ranges_to_nat" {
  description = "Source subnetwork IP ranges to NAT"
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "subnetworks" {
  description = "List of subnetworks to NAT"
  type = list(object({
    name                    = string
    source_ip_ranges_to_nat = list(string)
  }))
  default = []
}

variable "enable_logging" {
  description = "Enable NAT logging"
  type        = bool
  default     = false
}

variable "log_filter" {
  description = "Log filter for NAT"
  type        = string
  default     = "ERRORS_ONLY"
}
