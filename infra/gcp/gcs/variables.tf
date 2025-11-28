variable "bucket_name" {
  description = "Name of the GCS bucket"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Location for the bucket"
  type        = string
  default     = "US"
}
