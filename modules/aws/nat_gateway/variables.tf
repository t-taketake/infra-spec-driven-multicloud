variable "name" {
  description = "Name of the NAT Gateway"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID for NAT Gateway"
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID (for dependency)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
