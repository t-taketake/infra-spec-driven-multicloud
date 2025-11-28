variable "name" {
  description = "Name of the Artifact Registry repository"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Location for the repository"
  type        = string
}

variable "format" {
  description = "Repository format (DOCKER, MAVEN, NPM, etc.)"
  type        = string
  default     = "DOCKER"
}

variable "description" {
  description = "Description of the repository"
  type        = string
  default     = ""
}

variable "immutable_tags" {
  description = "Enable immutable tags (Docker only)"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to apply to the repository"
  type        = map(string)
  default     = {}
}
