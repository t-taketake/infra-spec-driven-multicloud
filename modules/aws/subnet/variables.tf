variable "name" {
  description = "Name of the subnet"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
}

variable "map_public_ip_on_launch" {
  description = "Map public IP on launch"
  type        = bool
  default     = false
}

variable "map_public_ip_on_launch" {
  description = "Whether to auto-assign public IPs"
  type        = bool
  default     = false
}

variable "subnet_type" {
  description = "Type of subnet (public or private)"
  type        = string
  validation {
    condition     = contains(["public", "private"], var.subnet_type)
    error_message = "subnet_type must be either 'public' or 'private'."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
