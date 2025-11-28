terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.gcp_region
}

# VPC
module "vpc" {
  source = "../../../modules/gcp/vpc"

  name                    = "${var.environment}-${var.service}-vpc"
  project_id              = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  mtu                     = 1460
}

# Subnets
module "subnet_a" {
  source = "../../../modules/gcp/subnet"

  name                     = "${var.environment}-${var.service}-subnet-a"
  project_id               = var.project_id
  network_id               = module.vpc.network_id
  ip_cidr_range            = var.subnet_a_cidr
  region                   = var.gcp_region
  private_ip_google_access = true
  enable_flow_logs         = var.enable_flow_logs
}

module "subnet_b" {
  source = "../../../modules/gcp/subnet"

  name                     = "${var.environment}-${var.service}-subnet-b"
  project_id               = var.project_id
  network_id               = module.vpc.network_id
  ip_cidr_range            = var.subnet_b_cidr
  region                   = var.gcp_region
  private_ip_google_access = true
  enable_flow_logs         = var.enable_flow_logs
}

# Cloud Router
module "cloud_router" {
  source = "../../../modules/gcp/cloud_router"

  name       = "${var.environment}-${var.service}-router"
  project_id = var.project_id
  region     = var.gcp_region
  network_id = module.vpc.network_id
  bgp_asn    = 64514
}

# Cloud NAT
module "cloud_nat" {
  source = "../../../modules/gcp/cloud_nat"

  name                               = "${var.environment}-${var.service}-nat"
  project_id                         = var.project_id
  region                             = var.gcp_region
  router_name                        = module.cloud_router.router_name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  enable_logging                     = var.enable_nat_logging
  log_filter                         = "ERRORS_ONLY"
}
