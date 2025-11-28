terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

module "gcs" {
  source = "../../../modules/gcp/gcs"

  bucket_name = var.bucket_name
  project_id  = var.project_id
  location    = var.location
}
