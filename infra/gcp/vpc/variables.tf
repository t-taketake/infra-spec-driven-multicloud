variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "main-vpc"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}
