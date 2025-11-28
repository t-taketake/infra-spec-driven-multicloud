variable "name" {
  description = "Name of the Cloud Router"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for the Cloud Router"
  type        = string
}

variable "network_id" {
  description = "ID of the VPC network"
  type        = string
}

variable "bgp_asn" {
  description = "BGP ASN for the router"
  type        = number
  default     = 64514
}
