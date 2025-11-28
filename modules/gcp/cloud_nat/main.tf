resource "google_compute_router_nat" "main" {
  name                               = var.name
  router                             = var.router_name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat

  dynamic "subnetwork" {
    for_each = var.subnetworks
    content {
      name                    = subnetwork.value.name
      source_ip_ranges_to_nat = subnetwork.value.source_ip_ranges_to_nat
    }
  }

  log_config {
    enable = var.enable_logging
    filter = var.log_filter
  }
}
