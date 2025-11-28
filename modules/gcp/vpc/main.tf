resource "google_compute_network" "main" {
  name                    = var.name
  auto_create_subnetworks = var.auto_create_subnetworks
  routing_mode            = var.routing_mode
  mtu                     = var.mtu
  project                 = var.project_id
}
