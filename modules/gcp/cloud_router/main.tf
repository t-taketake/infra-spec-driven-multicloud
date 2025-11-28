resource "google_compute_router" "main" {
  name    = var.name
  region  = var.region
  network = var.network_id
  project = var.project_id

  bgp {
    asn = var.bgp_asn
  }
}
