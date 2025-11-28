variable "repository_name" {
  description = "Name of the Artifact Registry repository"
  type        = string
  default     = "app-repo"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Location for the repository"
  type        = string
  default     = "us-central1"
}
