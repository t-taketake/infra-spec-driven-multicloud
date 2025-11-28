variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "service" {
  description = "Service name"
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_a_cidr" {
  description = "Public subnet A CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_c_cidr" {
  description = "Public subnet C CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_a_cidr" {
  description = "Private subnet A CIDR"
  type        = string
  default     = "10.0.11.0/24"
}

variable "private_subnet_c_cidr" {
  description = "Private subnet C CIDR"
  type        = string
  default     = "10.0.12.0/24"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
