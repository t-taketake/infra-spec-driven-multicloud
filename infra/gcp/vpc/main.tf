terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

module "vpc" {
  source = "../../../modules/gcp/vpc"

  name       = var.vpc_name
  project_id = var.project_id
}
