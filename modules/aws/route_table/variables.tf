variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "name" {
  description = "Name of the route table"
  type        = string
}

variable "route_table_type" {
  description = "Type of route table (public or private)"
  type        = string
  validation {
    condition     = contains(["public", "private"], var.route_table_type)
    error_message = "route_table_type must be either 'public' or 'private'."
  }
}

variable "gateway_id" {
  description = "Internet Gateway ID (for public route tables)"
  type        = string
  default     = null
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID (for private route tables)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with this route table"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
