terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

module "artifact_registry" {
  source = "../../../modules/gcp/artifact_registry"

  name       = var.repository_name
  project_id = var.project_id
  location   = var.location
}
