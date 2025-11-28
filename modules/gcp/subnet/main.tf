resource "google_compute_subnetwork" "main" {
  name                     = var.name
  ip_cidr_range            = var.ip_cidr_range
  region                   = var.region
  network                  = var.network_id
  project                  = var.project_id
  private_ip_google_access = var.private_ip_google_access

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = var.flow_logs_aggregation_interval
      flow_sampling        = var.flow_logs_sampling
      metadata             = var.flow_logs_metadata
    }
  }
}
